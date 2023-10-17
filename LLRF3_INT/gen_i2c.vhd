-- Generic I2C Module
-- 8/5/2020
-- James Latshaw
--
-- Follow standad I2C protocal with ack feedback
-- does not support reading, clock streching, or multiple master arbitration
-- for future use, P_width, use to only send a subset of the total packets
-- s_ack, use to monitor acknolwedgements to ensure that writes are good

-- 3/12/21, updated values for 125 Mhz clock, still need to test, ensure timing works out correctly.
-- also note, that we are stepping this down to <100 kHz (not 400 Khz).

-- 6/25/21, JAL updated I2C speed to support a faster clock (does not appear to have been needed).

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY gen_i2c IS
	generic (testBench : STD_LOGIC := '0'); 
	PORT
	(	
		clock     : IN  	STD_LOGIC; -- input clock
		reset_n   : IN  	STD_LOGIC; -- active low reset
		EN			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
		ADDR 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address
		RW			 : IN  	STD_LOGIC; -- read/write, read = HI, writes = LOW
		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); -- input data, msByte sent first
		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0); -- read data (leave OPEN if not used)
		P_width 	 : IN  	STD_LOGIC_VECTOR(1 downto 0); --Choose how many bytes to transmit (00 1 data byet, 01 2 data bytes, 10 or 11 3 data bytes)
		S_ACK		 : OUT 	STD_LOGIC; -- Status for ack, HI= ack recieved, LO = no ack
		SCL 		 : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz)
		SDA 		 : INOUT STD_LOGIC; -- data line (data is bi directional)
		rdy		 : out   STD_LOGIC; -- HI means in IDLE state, ready for next packet
		dir		 : out   STD_LOGIC  -- Hi means data sent to sensor, low meaans data from sensor 
	);
END gen_i2c;

ARCHITECTURE rtl OF gen_i2c IS 
	-- state machine enumeration
	type enum is (INIT, START, ADDR_S, ACK, DATA_S, STOP, PACKET_S, PACKET_R);
	signal STATE, NEXT_STATE : ENUM := INIT;
	--
	signal SCL_Buffer, SCL_advanced, en_pulse, SDA_buffer, SCL_HOLD : STD_LOGIC :='0';
	--
	--signal COUNT_byte : STD_LOGIC_VECTOR(1 downto 0);
	--signal DATA_byte : STD_LOGIC_VECTOR(7 downto 0);
	-- Packet to transmit
	signal packet : STD_LOGIC_VECTOR(35 downto 0) := (others => '0');
	--
	Signal count_FULL, count_Half, count_adv		: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	--
	signal DATA_R_buffer : STD_LOGIC_VECTOR(23 downto 0);
	--
	signal ack_expected, SDA_IN, oe_reads : STD_LOGIC;
	--
BEGIN
--
--=================================================
-- Couter Generates (shorter if in test bench mode)
--=================================================
--
	gen_counter_tb : if testBench = '1' generate
		-- use smaller counters to speed up test bench
		count_FULL	<= x"0003";
		count_Half	<= x"0002";
		count_adv	<= x"0001";
	end generate gen_counter_tb;
	--
	gen_counter_normal : if testBench = '0' generate
		-- real count values to support I2C
		count_FULL	<= x"01F4"; -- , old 100 Mhz number of ticks 0D48
		count_Half	<= x"00FA"; -- , old 100 Mhz number of ticks 09C4
		count_adv	<= x"007D"; -- , old 100 Mhz number of ticks 04B0
	end generate gen_counter_normal;
--
--=================================================
-- SCL (100 Mhz to 400 kHz)
--=================================================
	-- 100 M / 400 k = 250, thus 250 100 MHz clocks in one 400 KHz clock
	-- thus, we need 125 LOW coutns and 125 HIGH counts
	process(clock, reset_n, SCL_Buffer)
	variable counter    		: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
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
-- Advanced a quarter cycle ahead of SCL_Buffer
--=================================================
	-- 100 M / 400 k = 250, thus 250 100 MHz clocks in one 400 KHz clock
	-- thus, we need 125 LOW coutns and 125 HIGH counts
	-- the differecne with this is that we initiate 60 coutns in
	-- This is nearly 1/4 cycle advanced when compared to SCL_buffer
	--
	process(clock, reset_n, SCL_advanced)
	variable counter    		: STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	begin
		if reset_n = '0' then
			counter := count_adv; -- <-- initiate 60 coutns in
			SCL_advanced <= '0';
		else
			if (clock = '1' and clock'event) then
				if (counter <= count_Half) then
					SCL_advanced <= '0'; 
					counter := counter + 1;
				elsif (counter >= count_Half) and (counter <= count_FULL) then
					SCL_advanced <= '1'; 
					counter := counter + 1;
				else
					SCL_advanced <= '0';
					counter := (others => '0');
				end if;
			end if; -- end rising edge detection
		end if;--end reset check
	end process;
--
--=================================================
-- Enable Pluse detection
--=================================================
--
	process (clock, reset_n, EN, STATE)
		variable last_bit, hold_EN : STD_LOGIC := '0';
	begin
		IF (reset_n = '0') OR (EN='0') THEN
			last_bit := '0';
			en_pulse <= '0';
			hold_EN  := '0';
		ELSE
			IF (clock = '1' AND clock'event) THEN
				IF (EN='1' AND last_bit='0') OR (hold_EN='1') THEN
					hold_EN  := '1';
					en_pulse <= '1';
					last_bit := EN;
				ELSE
					hold_EN  := '0';
					en_pulse <= '0';
					last_bit := EN;
				END IF;
			END IF;
		END IF;
	end process;
--	
-- at pulse register this packet (leave open for testing)
-- packet includes Z values during acknowldges
--packet <= ADDR & RW & "0" & DATA(7 downto 0) & "0" & DATA(15 downto 8) & "0" & DATA(23 downto 16) & "0" & DATA(31 downto 24) & "0";
--	
--=================================================
-- Main I2C State Machine
--=================================================
	process (SCL_advanced, reset_N, STATE, NEXT_STATE, SDA_buffer, P_width)
		variable bit_count : STD_LOGIC_VECTOR(3 downto 0) := x"0";
		variable COUNT_byte : STD_LOGIC_VECTOR(1 downto 0) := "00";
		variable counter : STD_LOGIC_VECTOR(7 downto 0) := x"00";
		variable counter_MAX, counter_MAX_R : STD_LOGIC_VECTOR(7 downto 0) := x"00";
	begin
		if reset_n = '0' then
			NEXT_STATE <= INIT;
			counter   := (others => '0');
			SDA_BUFFER <= '1';
			ack_expected <= '0';
			DATA_R_buffer <= (others => '0');
			counter_MAX   := (others => '0');
			counter_MAX_R := (others => '0');
			dir <= '1';
			oe_reads <= '0';
		else
			-- we want to make changes to the SDA whenever SCL clock is LOW
			-- per I2C specifications
			if (SCL_advanced = '1') and (SCL_advanced'event) then
				--
				case STATE is 
				--
				when INIT   => IF   en_pulse = '1' THEN NEXT_STATE <= START;
									ELSE 							 NEXT_STATE <= INIT;
									END IF;
									SDA_BUFFER <= '1';
									-- check for read or write
									IF RW ='0' THEN -- writes
										packet <= ADDR & RW & "Z" & DATA(23 downto 16) & "Z" & DATA(15 downto 8) & "Z" & DATA(7 downto 0) & "Z";
									ELSE -- reads
										packet(35 downto 28) <= ADDR & RW;
										packet(27 downto  0) <= (others =>'Z');
									END IF; 
									--
									counter   := (others => '0');
									-- set counter_MAX and packet based on P_width
									-- note, not zero indexed because we want to transmit all bits (otherwise last bit won't be sent)
									-- reads have one less bit
									IF    P_width = "00" then	counter_MAX := x"11"; counter_MAX_R := x"11"; -- 9*2 = 18 bits (2 data bytes)
									ELSIF P_width = "01" then	counter_MAX := x"1A"; counter_MAX_R := x"1A"; -- 9*3 = 27 bits (3 data byets)
									ELSE 								counter_MAX := x"23"; counter_MAX_R := x"22"; -- 9*4 = 36 bits (4 data byets)
									END IF;
									--
									ack_expected <= '0';
									DATA_R_buffer <= DATA_R_buffer;
									dir <= '1';
									oe_reads <= '0';
				--
				when START  => IF RW = '0' THEN NEXT_STATE <= PACKET_S; ELSE NEXT_STATE <= PACKET_R; END IF;
									SDA_BUFFER <= '0';
									counter   := (others => '0');
									ack_expected <= '0';
									DATA_R_buffer <= (others => '0'); -- set to zeros
									dir <= '1';
									oe_reads <= '0';
				--
				when PACKET_S => --for writes
									packet <= packet(34 downto 0) & '0';
									IF counter <= counter_MAX THEN
										-- Check for ack bit, only occurs at the end of each byte (9th bit)
										IF (counter = x"08" OR counter = x"11"  OR counter = x"1A"  OR counter = x"23" ) THEN
											ack_expected <= '1'; -- and ack is expected, try to read from SDA
											dir <= '0';
										ELSE
											ack_expected <= '0'; -- no ack expected
											dir <= '1';
										END IF;
										counter := counter + 1;
										NEXT_STATE <= PACKET_S;
										SDA_BUFFER <= packet(35);
									ELSE
										counter := x"00";
										NEXT_STATE <= STOP;
										SDA_BUFFER <= '0'; -- low for stop condition
										ack_expected <= '0';
										dir <= '1';
									END IF;
									DATA_R_buffer <= DATA_R_buffer;
									oe_reads <= '0';
				when PACKET_R => --for reads
									packet <= packet(34 downto 0) & '0';
									--
									IF counter <= counter_MAX THEN
										-- Check for ack bit, only occurs at the end of each byte (9th bit)
										IF (counter = x"08" OR counter = x"11"  OR counter = x"1A"  OR counter = x"23" ) THEN
											ack_expected <= '1'; -- and ack is expected, try to read from SDA
											DATA_R_buffer <= DATA_R_buffer; -- don't read in ack bit
											dir <= '0';
											oe_reads <= '1'; -- to help read in sda bit
										ELSE
											ack_expected <= '0'; -- no ack expected
											-- ignore the address bits in the data readback and do not read the last ack bit
											IF (counter <= x"08") OR (counter = counter_MAX) THEN
												DATA_R_buffer <= DATA_R_buffer;
												dir <= '1'; -- sending address
												oe_reads <= '0';
											ELSE
												DATA_R_buffer(23 downto 0) <= DATA_R_buffer(22 downto 0) & SDA_IN; -- read in bit
												dir <= '0'; -- rxing data
												oe_reads <= '1'; -- set SDA to hi Z so we can read bit
											END IF;
										END IF;
										counter := counter + 1;
										NEXT_STATE <= PACKET_R;
										SDA_BUFFER <= packet(35);
									ELSE
										counter := x"00";
										NEXT_STATE <= STOP;
										SDA_BUFFER <= '0'; -- low for stop condition
										ack_expected <= '0';
										dir <= '1';
										oe_reads <= '0';
									END IF;
				--
				when STOP   => NEXT_STATE <= INIT;
									SDA_BUFFER <= '1';
									counter   := (others => '0');
									ack_expected <= '0';
									DATA_R_buffer <= DATA_R_buffer;
									dir <= '1';
									oe_reads <= '0';
				--
				when others => NEXT_STATE <= INIT;
									SDA_BUFFER <= '1';
									counter   := (others => '0');
									ack_expected <= '0';
									DATA_R_buffer <= DATA_R_buffer;
									dir <= '1';
									oe_reads <= '0';
				--
				end case;					
			end if; -- end rising edge capture
		end if; -- reset
	end process;
	--
	-- update for next state
	STATE <= NEXT_STATE;
	-- I2C Notes:
	-- 		START 	STOP
	-- SDA	10			X01
	-- SCL	11			111
	--
	-- Note: states change at SCL_advanced rate, however we only want to update
	-- the SCL output with the rising edge of the SCL_buffer signal. This will
	-- allow the SDA address/data bits to be in the center of the output SCL pulse
	process (SCL_Buffer, STATE, reset_n, SCL_HOLD)
	begin
		if reset_n = '0' then
			SCL_HOLD <= '0';
		else
			if (SCL_Buffer = '1' and SCL_Buffer'event) then
				--
				if (STATE = INIT) OR (STATE = START) OR (STATE = STOP) THEN
					SCL_HOLD <= '0';
				ELSE
					SCL_HOLD <= '1';
				END IF;			
				--
				-- only asses ack on rising edge of sclk
				--detect ack bits, only when SDA_BUFFER is HI Z
				IF ack_expected = '1' THEN S_ACK  <= SDA; -- ack bits should be low
				ELSE								S_ACK  <= '1';
				END IF;
			end if;
		end if;
	end process;
	--
	DATA_R <= DATA_R_buffer;
	SDA    <= SDA_BUFFER when oe_reads ='0' else 'Z'; -- will be HI Z when ack_expected = 1 or rxing data
	SDA_IN <= SDA when oe_reads = '1' else '1'; -- only read SDA_In whenever SDA_BUFFER is at HI Z (during reads)
	SCL    <= SCL_Buffer when SCL_HOLD='1' ELSE '1';
	--
	rdy <= '1' when STATE = INIT ELSE '0';
	--
	--SCL <= SCL_Buffer when (STATE /= INIT) AND (STATE /= START) AND (STATE /= STOP)  ELSE '1';
	--
	--
	--
END rtl;