-- JAL
-- 12/22/21
-- goal is to make a generic i2c which is able to read and write data over the i2c bus 
-- with the hopes of using this to write to a 32k bit EEPROM.
--
--
-- Overall Desciption: Very simple I2C module which allows for writes and reads.
-- the way we do this is we keep bit lists that indicate what we want the I2C line
-- to do. Brief descriptions of each are proivded below. Each list can be thought
-- of as time slots that indicate what actions the I2C line should be doing for that time slot.
-- 
-- oe_list : tells us which who should control the SDA line for each time slot
-- m2s	  : tells us which time slots are for sending data from the master to the slave
-- s2m	  : tells us which time slots are for receiving data from the slave (to the master)
-- scl_hi  : tells us which time slots the SCL line should be masked out. (SCL_buffer is always clocking)
-- s2m_ack : tells us which time slots we expect the slave to pull the sda line low.
-- bit_len : initalized to all HI. Once we see a LO this tells us which time slot to send the stop condition.
--
-- Once a go pulse is recieved, all lists will be shifted for each time slot.
-- ths <signal>_i are index bits used to help keep the code clean. the Most Significant bit of each
-- list is the active time slot. 
--
-- 1/2/22, appears to be working with mem.py python script. I can manually read write registers and I can 
-- use the python script to easily read out the saved mac address.
-- currently no attempts are being made to have a crc32 or hash, that is up to the user to decide/check.
-- maybe we should have a boot up check? or just have a default mac? or varry mac address values by more than 1 bit
-- and have a default ip selected if no matching macs.
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY i2c IS
	generic (testBench : STD_LOGIC := '0'); 
	PORT
	(	
		clock     : IN  	STD_LOGIC; -- input clock
		reset_n   : IN  	STD_LOGIC; -- active low reset
		GO			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
		ADDR 	 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address, typically hardwired
		RNW		 : IN  	STD_LOGIC;
		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); 
		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0);
	   DONE		 : OUT	STD_LOGIC;
		SCL 		 : OUT 	STD_LOGIC; 
		SDA 		 : INOUT STD_LOGIC 
	);
END i2c;

ARCHITECTURE rtl OF i2c IS 
	-- state machine enumeration
	type enum is (IDLE, START, START_CON, EDGE_NEG_START, EDGE_POS, SHIFT, EDGE_NEG, DONE_CHECK, STOP);
	signal STATE : ENUM := IDLE;
	--
	signal SCL_Buffer, go_pulse : STD_LOGIC :='0';
	--
	signal oe_list, m2s, s2m, s2m_ack, bit_len, SR_ack, SR_read : STD_LOGIC_VECTOR(35 downto 0) := (others => '0');
	--
	Signal count_FULL, count_Half : UNSIGNED(15 downto 0) := (others => '0');
	--
	-- INDEX terms
	signal oe_list_i, m2s_i, s2m_i, scl_hi_i, s2m_ack_i, bit_len_i, read_bit, sda_ovrd : STD_LOGIC;
	--
BEGIN
--
--=================================================
-- Counter (changed to generics?)
--=================================================
--
-- real count values to support I2C
count_FULL	<= x"01F4"; -- , old 100 Mhz number of ticks 0D48
count_Half	<= x"00FA"; -- , old 100 Mhz number of ticks 09C4
--count_adv	<= x"007D"; -- , old 100 Mhz number of ticks 04B0
--
--=================================================
-- Generate SCL clock
--=================================================
-- to keep timing, the SCL_buffer signal will aways be clocking
-- however the output SCL clock may be masked.
--
	process(clock, reset_n, SCL_Buffer)
		variable counter    		: UNSIGNED(15 downto 0) := (others => '0');
	begin
		if reset_n = '0' then
			counter    := (others => '0');
			SCL_Buffer <= '0';
		else
			if (clock = '1' and clock'event) then
				if (counter <= count_Half) then
					SCL_Buffer <= '0'; 
					counter := counter + 1;
				elsif (counter >= count_Half) and (counter <= count_FULL) then
					SCL_Buffer <= '1'; 
					counter := counter + 1;
				else
					SCL_Buffer <= '0';
					counter := (others => '0');
				end if;
			end if; -- end rising edge detection
		end if;--end reset check
	end process;
--
--=================================================
-- Enable Pulse detection (rising edge)
--=================================================
--
-- simple rising edge detection for the go pulse
--
	process (clock, reset_n)
		variable last_bit : STD_LOGIC := '0';
	begin
		IF (reset_n = '0') OR (GO='0') THEN
			last_bit := '0';
			go_pulse <= '0';
		ELSIF (clock = '1' AND clock'event) THEN
			go_pulse <= NOT(last_bit) AND GO;
			last_bit := GO;
		END IF;
	end process;
--	
--=================================================
-- Main I2C State Machine
--=================================================
	process (clock, reset_n)
		--
		variable scl_neg_edge : STD_LOGIC;
		variable scl_pos_edge : STD_LOGIC;
		variable scl_buffer_last : STD_LOGIC;
		variable rnw_c : STD_LOGIC;
	begin
		if reset_n = '0' then
			--
			STATE <= IDLE;
			sda_ovrd <= '1';
			scl_neg_edge := '0';
			scl_pos_edge := '0';
			scl_buffer_last := '0';
			rnw_c := '0';
			--	
		elsif (clock = '0') and (clock'event) then
				--
				scl_neg_edge := scl_buffer_last AND NOT(SCL_Buffer); -- positive edge detection of scl 
				scl_pos_edge := NOT(scl_buffer_last) AND SCL_Buffer; -- negative edge detection of scl
				scl_buffer_last := SCL_Buffer;
				--
				case STATE is 
				when IDLE   => 
					-- Wait for go pule, then go to next state, else stay in this state
					-- We build the packets in this state
					IF go_pulse='1' THEN
						STATE <= START;
					ELSE
						STATE <= IDLE;
					END IF;
					sda_ovrd <= '1';
					rnw_c := RNW;
					-- I2C Notes:
					-- 		START 	STOP
					-- SDA	10			01
					-- SCL	11			11
					IF RNW = '1' THEN
						oe_list    <= x"FF" & "0" & x"FF" & "0" & x"FF" & "0" & x"00" & "1";
						s2m		  <= x"00" & "0" & x"00" & "0" & x"00" & "0" & x"FF" & "0";
					ELSE
						oe_list    <= x"FF" & "0" & x"FF" & "0" & x"FF" & "0" & x"FF" & "0";
						s2m		  <= x"00" & "0" & x"00" & "0" & x"00" & "0" & x"00" & "0";
					END IF;
					--				  addr   rnw   ack byte                 ack   byte                 ack   byte	           ACK/NACK
					m2s		  <= ADDR & "0" & "0" & DATA(23 downto 16) & "0" & DATA(15 downto 8) & "0" & DATA(7 downto 0) & RNW;
					-- NOTE: the i2c chip performs reads by writing an address, thus the rnw bit is always 0
					-- after the addr bits.
					--
					s2m_ack	  <= x"00" & "1" & x"00" & "1" & x"00" & "1" & x"00" & NOT(RNW);
					bit_len 	  <= (others =>  '1');
					--
				when START =>
					-- This state syncs us up with the SCL buffer clock which ensures
					-- that we issue the 'start condition' at the begining of the rising
					-- edge and not midway through (or at the end) of its high half period.
					--
					IF scl_neg_edge='1' THEN
						STATE <= START_CON;
					ELSE
						STATE <= START;
					END IF;
					sda_ovrd <= '1';
					--
				when START_CON => 
					-- initiate a start condition by bringing SDA LOW and keeping SCL HI. This is done
					-- at the positive edge of SCL.
					--
					IF scl_pos_edge='1' THEN
						STATE <= EDGE_NEG_START;
						sda_ovrd <= '0';
					ELSE
						STATE <= START_CON;
						sda_ovrd <= '1';
					END IF;
					--
				when EDGE_NEG_START   => 
					-- data does not need to be shifted for first sent bit
					IF scl_neg_edge='1' THEN
--						IF bit_len = x"FF8000000" THEN
--							STATE <= SHIFT;
--						ELSE
							STATE <= EDGE_POS;
						--END IF;
					ELSE
						STATE <= EDGE_NEG_START;
					END IF;
					--
					sda_ovrd <= '0';
					--
				when EDGE_NEG   => 
					-- wait for falling edge of SCL to shift in new data, then go to next state
					-- data must remain unchanged during SCL HI periods
					IF scl_neg_edge='1' THEN
						STATE <= SHIFT;
					ELSE
						STATE <= EDGE_NEG;
					END IF;
					--
					sda_ovrd <= '0';
					--
				when SHIFT => 
					-- shift in new data and go to next state.
					--
					STATE <= EDGE_POS;
					-- shift lists
					oe_list    <= oe_list(34 downto 0) & "0"; 
					m2s		  <= m2s(34 downto 0)     & "0";	 
					s2m		  <= s2m(34 downto 0)     & "0";	 
					--scl_hi	  <= scl_hi(34 downto 0)  & "0"; 
					s2m_ack	  <= s2m_ack(34 downto 0) & "0"; 
					bit_len 	  <= bit_len(34 downto 0) & "0"; 
					--
					sda_ovrd <= '0';
					--
				when EDGE_POS => -- wait for rising edge of SCL, then go to next state
					--
					IF scl_pos_edge='1' THEN
						STATE <= DONE_CHECK;
					ELSE
						STATE <= EDGE_POS;
					END IF;
					--
					sda_ovrd <= '0';
					--
				when DONE_CHECK  =>
					-- check to see if bit_len is 0, if so then go to IDLE (done with this packet)
					-- else wait for next edge
					--
					IF rnw_c = '0' THEN
						IF bit_len_i='0' THEN
							STATE <= STOP;
						ELSE
							STATE <= EDGE_NEG;
						END IF;
						--
						sda_ovrd <= '0';
						--
					ELSE
						-- for reads only, issue a restart (without a stop condition)
						IF bit_len = x"FF8000000" THEN
							STATE <= START;
							--				addr read   ack   data_r  nack  
							m2s     <= ADDR & "1" & "0" & x"00" & "1" & x"00" & "0" & x"00" & "0";
							oe_list <= x"FF"      & "0" & x"00" & "1" & x"00" & "0" & x"00" & "0";
							s2m	  <= x"00"      & "0" & x"ff" & "0" & x"00" & "0" & x"00" & "0";
							s2m_ack <= x"00"      & "1" & x"00" & "0" & x"00" & "0" & x"00" & "0";
							bit_len <= x"ff"      & "1" & x"ff" & "1" & x"00" & "0" & x"00" & "0";
							--
							-- read not write check, set to zero so that we don't repeat this read packet
							rnw_c := '0';
							sda_ovrd <= '1';
							--
						ELSE
							--
							sda_ovrd <= '0';
							--
							IF bit_len_i='0' THEN
								STATE <= STOP;
							ELSE
								STATE <= EDGE_NEG;
							END IF;
						END IF;						
					END IF;
					--
					
					--
				when STOP =>
					--
					IF scl_pos_edge='1' THEN
						STATE <= IDLE;
						sda_ovrd <= '1';
					ELSE
						STATE <= STOP;
						sda_ovrd <= '0';
					END IF;
					--
				when others => --something went wrong, go to IDLE
					--
					STATE <= IDLE;
					--
					sda_ovrd <= '1';
					--
				end case;					
		end if;
	end process;
	--
	--=================================================
	-- Read data shift registers
	--=================================================
	-- goal is to shift in read bits when appropriate
	-- SR_ack is the shift register for acknowledgements from the slave. We expect these to be zeros
	-- SR_read is the read bits from the slave.
	process(clock, reset_n)
		variable scl_pos_edge : STD_LOGIC;
		variable scl_buffer_last : STD_LOGIC;
	begin
		if (reset_n='0') then
			SR_ack  <= (others => '0');
			SR_read <= (others => '0');
			scl_buffer_last := '0';
			scl_pos_edge := '0';
			--
		elsif (clock='1' and clock'event) then
			--
			scl_pos_edge := NOT(scl_buffer_last) AND SCL_Buffer; -- pos edge detection of scl
			scl_buffer_last := SCL_Buffer;
			--
			IF ((scl_pos_edge='1') AND (s2m_i = '1')) THEN
				SR_ack  <= SR_ack(34 downto 0)  & (read_bit AND s2m_ack_i);
				--SR_read <= SR_read(34 downto 0) & (read_bit AND s2m_i);
				SR_read <= SR_read(34 downto 0) & SDA;
			END IF;
			--
		end if;
	end process;
	--
	--=================================================
	-- Combinational
	--=================================================
	--
	-- assigning these to help the code be more clear. the _i stands for the bit index
	-- when bit_len_i='0', we need to generate a stop condition.
	oe_list_i  <= '1' when  (bit_len_i='0') else oe_list(35);
	m2s_i      <= sda_ovrd when ((STATE=IDLE) OR (STATE=START) OR (STATE=START_CON) OR (STATE=EDGE_NEG_START) OR (bit_len_i='0') OR (STATE=STOP)) else m2s(35);
	s2m_i      <= s2m(35);   
	s2m_ack_i  <= s2m_ack(35);
	bit_len_i  <= bit_len(35);
	--
	scl_hi_i <= '1' when ((STATE=IDLE) OR (STATE=START) OR (STATE=START_CON) OR (STATE=STOP)) else '0';
	SCL      <= SCL_Buffer OR scl_hi_i;
	SDA      <=  m2s_i when oe_list_i = '1' else 'Z'; -- sda is inout, if reading, must place in HIGH Z
	read_bit <= '1'    when oe_list_i = '1' else SDA; -- sda is inout, only write if not in HIGH Z
	--
	-- note, only looks at the lower 8 bits (which is all i need for the 32k eeprom byte reads)
	DATA_R <= x"0000" & SR_read(7 downto 0);
	DONE <= '1' when STATE = IDLE else '0';
	--
	--
	--
	--
END rtl;