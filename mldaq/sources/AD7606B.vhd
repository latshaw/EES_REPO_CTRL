-- JAL 11/8/21
-- SPI module for AD7606B
-- 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY AD7606B IS 
		generic(genric_clkrate : UNSIGNED(31 downto 0) := x"07735940";      -- how many clock ticks make 1 second (not used?)
				  generic_half_spi_rate  : UNSIGNED(3 downto 0) := x"1");		 -- how many clock ticks are desired per half period for spi (how many clocks are desired for SPI LOW), min value is 1
	PORT
	(
		clock 	: IN STD_LOGIC;  -- clock should match clock rate generic
		reset_n  : IN STD_LOGIC;  -- active low reset
		go			: IN STD_LOGIC;  -- pulse HI to initiated conversion process
		
		-- SPI signals	
		adc_busy : IN STD_LOGIC;  -- signal from ADC indicating ADC is busy with conversion
		nCONVST	: OUT STD_LOGIC;
		nCS		: OUT STD_LOGIC;
		SCLK		: OUT STD_LOGIC;
		SDO_A		: IN  STD_LOGIC;	
		SDO_B		: IN  STD_LOGIC;	
		
		V1			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V2			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V3			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V4			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V5			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V6			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V7			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V8			: OUT STD_LOGIC_VECTOR(15 downto 0);	
		
		-- different from ADC busy, this lets a higher module know that the data in v1-v8 is stable and the adc is ready for the next GO pulse
		busy 		: OUT std_logic	
	);
END AD7606B;

ARCHITECTURE AD7606B OF AD7606B IS 

signal v_buffer_A,v_buffer_B  : STD_LOGIC_VECTOR(15 downto 0);
signal v1_buffer, v1_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v2_buffer, v2_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v3_buffer, v3_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v4_buffer, v4_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v5_buffer, v5_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v6_buffer, v6_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v7_buffer, v7_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);
signal v8_buffer, v8_buffer_mux : STD_LOGIC_VECTOR(15 downto 0);

signal state      : STD_LOGIC_VECTOR(3 downto 0);
signal state_next, state_last : STD_LOGIC_VECTOR(3 downto 0);

signal clock_counter : UNSIGNED(31 downto 0); -- will help produce SPI clock and determine when to sample SDO bits
signal spi_track     : UNSIGNED( 3 downto 0); -- will determine which tick of the SPI clock we are currently on (tick 0 to 15)
signal v_track       : UNSIGNED( 3 downto 0); -- will determine which ADC we are sampling (register v#)

signal busy_d : STD_LOGIC_VECTOR(2 downto 0); -- delayed busy signal

signal en_clock_counter : STD_LOGIC;
signal en_spi_tick      : STD_LOGIC;

--
BEGIN 
--===================================================
-- Notes and Terminology
--===================================================
-- This module will read 8 registers off of the AD7606B ADC. Each regiter is 16 bits with naming V1 through V8.
-- We will be reading these registers via the SPI protocol. A conversion will be issued by pulsing nCONVT HI.
-- The ADC will set adc_busy HI until the conversion has completed.Then the registers may be read off of the ADC sequentially.
-- nCS will then be lowered, and 16 SCLK pulses will be isseued for each register. On the rising edge of each SCLK, a SDO bit
-- will be sent from the ADC to the FPGA. This will be saved and shifted into a register. After all 8 registers are read, nCS 
-- will be raised. each of the regiters, V1 through V8 will be buffered and then sent to the output of this module.
-- V1 throuhg V4 will be sent over SDO_A and V5 through V8 will be sent over SDO_B. (V1 and V5 are sent at the same time, V2 and V6 are sent at the same time, etc).
-- 
-- GO : a risinged edge for GO indicates the beginning of the conversion and read process. This should pulse at the f sample rate.
-- 
-- 
-- BUSY: (different then adc_busy) means that the module is perfoming the covnersion and read process. The busy signal will
-- be HI for 2 clock ticks after reads are completed. In this way, the outpyt if the busy signal can be used to trigeer the GO (external to this module)
-- 
-- TICK: A term ment to describe the passage of time in terms of digital clock events, often during the rising edge of said clock.
-- 		clock tick: for a 125 Mhz clock this is 8ns of time
--			half spi tick: counting in terms of clock ticks, this is half the time needed for 1 spi tick.
--								There are multiple clock ticks in a signle 'half spi tick.' 
--								We want the SPI CLOCK to be half HI and half LOW. This will determine 
--								the timing of SCLK and inform when to sample SDOUT.
-- 

--===================================================
-- Clock Counter
--===================================================
-- When en_spi_tick is HI, then a half SPI period event has occured
--
	process (clock, reset_n)
		variable count_1   :  UNSIGNED(3 downto 0)  := x"0";
		begin
			if (reset_n = '0')then
				en_spi_tick   <=  '0';
				count_1         := x"0";
			elsif clock'event and clock = '1' then					
					IF    (count_1 >= generic_half_spi_rate) THEN	
						count_1       := x"0";
						en_spi_tick <= '1';
					ELSE
						count_1 := count_1 + 1;
						en_spi_tick <= '0';
					END IF;
				end if; -- end rising edge
	end process;
-------
--===================================================
-- Main State Machine
--===================================================
-- 
--
	process (clock, reset_n, state)
		variable count   :  UNSIGNED(3 downto 0)  := x"0";
			
		begin
			if (reset_n = '0') then
				state <= x"0";
				spi_track  <= x"0";
				v_track 	  <= x"0"; 
				count := x"0";
			elsif clock'event and clock = '1' then					
					CASE state is
					when x"0"   => -- stay in IDLE until we receive a go pulse
										IF (go='1') THEN
											state      <= x"1"; -- next state
											spi_track  <= x"0";
											v_track 	  <= x"0";
										ELSE
											state      <= x"0"; -- stay in this state
											spi_track  <= x"0";
											v_track 	  <= x"0";
										END IF;
										count := x"0";
					when x"1"   =>  -- Pulse CONVST state
									IF (count >= x"8") THEN
										count := x"0";
										state <= x"A"; -- busy will go HI when we leave this state
									ELSE
										state <= x"1"; -- else, stay in this state
										count := count + 1;
									END IF;
					when x"2"   => 						  -- wait for ADC_BUSY (to go Low)
									IF (adc_busy='0') and (en_spi_tick='1') THEN
										state <= x"3"; 
										count := x"0";
									ELSE
										state <= x"2"; -- else stay in this state
										count := x"0";
									END IF;
					when x"3"   => 						  -- allow CSn to go low befor SCLK goes low
									IF (adc_busy='0') and (en_spi_tick='1') THEN -- shouldn't need the busy check, but it won't hurt anything
										state <= x"4"; -- now ready to pulse sclk low
										count := x"0";
									ELSE
										state <= x"3"; -- else stay in this state
										count := x"0";
									END IF;
					when x"4"   => -- SCLK LOW, include check for ADC_BUSY to be LOW (1st half spi tick)
									IF (en_spi_tick='1') THEN
										state <= x"5"; -- go to next state
									ELSE
										state <= x"4"; -- stay in this state until en_spi_tick
									END IF;
									count := x"0";
					when x"5"   => -- SCLK HI													 (2nd half spi tick)
									IF (en_spi_tick='1') THEN
										state <= x"6"; -- go to next state
									ELSE
										state <= x"5"; -- stay in this state until en_spi_tick
									END IF;
									count := x"0";
					when x"6"   => 
						-- =========================== Check if 16 full SCLK periods have passed (will take 1 tick, thus minimum value for generic_half_spi_rate is 1)
						-- STATE 6
						-- This state needs to occur within 1 clock tick 
						--		check if 16 SCLK periods have passed (if so increment v register track)
						--		check if 8 v registers have been read (if so, then done)
						--	
						IF spi_track = x"F" THEN -- Full SCLK period check
							-- 16 full SCLK periods have occured, ready for next ADC register
							spi_track  <= x"0"; -- reset sclk tracker
							-- 
							IF v_track = x"3" THEN -- all 8 v register checks (read 2 at a time, one on SDO_A and one on SDO_B lines)
								state <= x"9";
								v_track 	  <= x"3"; -- all 8 registers have been read
							ELSE
								state <= x"7"; -- else, pull CSn hi to before sending next SCLK
								v_track 	  <= v_track  + 1; 
							END IF;
							--
						ELSE
							state <= x"4"; -- else, send next SCLK
							spi_track  <= spi_track  + 1;
							--
						END IF;
						count := x"0";
						--
						-- END STATE 6
						-- ===========================
					when x"7"   => -- CSn HI
									IF (en_spi_tick='1') THEN
										state <= x"8"; -- go to next state
									ELSE
										state <= x"7"; -- stay in this state until en_spi_tick
									END IF;
									count := x"0";
					when x"8"   => -- CSn LOW (CSN should go low before sclk)
									IF (en_spi_tick='1') and (count >= x"4") THEN
										state <= x"4"; -- go to next state, begin new frame
										count := x"0";
									ELSE
										state <= x"8"; -- stay in this state until en_spi_tick
										count := count + 1;
									END IF;
					when x"A"   => -- busy HI check
									IF (adc_busy='1') THEN
										state <= x"2"; -- busy is now HI, now wait until busy goes low
										count := x"0";
									ELSE
										state <= x"A"; -- stay in this state until busy is HI
										count := x"0";
									END IF;
					when others => -- Begin to release busy signal in state 9
								IF (en_spi_tick='1') THEN
									state <= x"0"; -- go to next state
								ELSE
									state <= x"9"; -- stay in this state until en_spi_tick
								END IF;
								count := x"0";
					end CASE;
				end if; -- end rising edge
	end process;
	
	nCONVST <= '0' when (state=x"1") else '1'; -- nCONVST <= '0' when ((state=x"1")or(state=x"2")) else '1';
	nCS     <= '1' when ((state=x"0")or(state=x"1")or(state=x"2")or(state=x"7")or(state=x"9")or(state=x"A")) else '0'; --nCS     <= '1' when ((state=x"0")or(state=x"1")or(state=x"2")or(state=x"7")) else '0';
	SCLK	  <= '0' when state=x"4" else '1';
				
-------	
--===================================================
--  DOUT bit capture
--===================================================
-- capture DOUT bit after the rising edge of the SCLK is issued
	process (clock,SDO_A, SDO_B)
		begin
			--if (reset_n = '0') or (state = x"1") then -- reset for each frame (makes debug easier)
			if (reset_n = '0') then -- reset for each frame (makes debug easier)
				v1_buffer <= x"0000";
				v2_buffer <= x"0000";
				v3_buffer <= x"0000";
				v4_buffer <= x"0000";
				v5_buffer <= x"0000";
				v6_buffer <= x"0000";
				v7_buffer <= x"0000";
				v8_buffer <= x"0000";
				state_last <= x"0";
			elsif clock'event and clock = '1' then		
				 -- effectively will shift in new bit at state transition (from SCLK LOW - > HI)
				 -- shift in new SDO bit
				IF ((state = x"5") AND (state_last = x"4") AND (v_track = x"0")) THEN
					v1_buffer <= v1_buffer(14 downto 0) & SDO_A; 
					v5_buffer <= v5_buffer(14 downto 0) & SDO_B; 
				END IF;
				--
				IF ((state = x"5") AND (state_last = x"4") AND (v_track = x"1")) THEN
					v2_buffer <= v2_buffer(14 downto 0) & SDO_A; 
					v6_buffer <= v6_buffer(14 downto 0) & SDO_B; 
				END IF;
				--
				IF ((state = x"5") AND (state_last = x"4") AND (v_track = x"2")) THEN
					v3_buffer <= v3_buffer(14 downto 0) & SDO_A; 
					v7_buffer <= v7_buffer(14 downto 0) & SDO_B; 
				END IF;
				--
				IF ((state = x"5") AND (state_last = x"4") AND (v_track = x"3")) THEN
					v4_buffer <= v4_buffer(14 downto 0) & SDO_A; 
					v8_buffer <= v8_buffer(14 downto 0) & SDO_B; 
				END IF;	
				--
				state_last <= state;
				--
			end if;
	end process;
	
	-- for each channel, there is a flip flip which registers the v_buffer_A/B value at each rising edge.
	-- this value is in the v*_buffer_mux signal which is 1 of 2 inputs into a mux.
	-- the mux has its output tied back to one of the inputs.
	-- the mux will select v*_buffer_mux signal whenever there is new data available on the buffer, otherwise
	-- the mux will select its output, v_buffer.
--		PROCESS (clock)
--   BEGIN
--		IF (clock'event AND clock = '1') THEN
--         v1_buffer_mux <= v_buffer_A;
--			v2_buffer_mux <= v_buffer_A;
--			v3_buffer_mux <= v_buffer_A;
--			v4_buffer_mux <= v_buffer_A;
--			v5_buffer_mux <= v_buffer_B;
--			v6_buffer_mux <= v_buffer_B;
--			v7_buffer_mux <= v_buffer_B;
--			v8_buffer_mux <= v_buffer_B;
--      END IF;
--	END PROCESS;
--	--
--	-- SDO A Line
--	--
--	v1_buffer <= v1_buffer_mux when (v_track= x"0") AND (state = x"5") else v1_buffer;	
--	v2_buffer <= v2_buffer_mux when (v_track= x"1") AND (state = x"5") else v2_buffer;												  
--	v3_buffer <= v3_buffer_mux when (v_track= x"2") AND (state = x"5") else v3_buffer;													 
--	v4_buffer <= v4_buffer_mux when (v_track= x"3") AND (state = x"5") else v4_buffer;													  
--	--
--	-- SDO_B line
--	--
--	v5_buffer <= v5_buffer_mux when (v_track= x"0") AND (state = x"5") else v5_buffer;													  
--	v6_buffer <= v6_buffer_mux when (v_track= x"1") AND (state = x"5") else v6_buffer;													  
--	v7_buffer <= v7_buffer_mux when (v_track= x"2") AND (state = x"5") else v7_buffer;													  
--	v8_buffer <= v8_buffer_mux when (v_track= x"3") AND (state = x"5") else v8_buffer;
--						  
---- made latch :(
--	-- SDO_A line
--	v1_buffer <= v_buffer_A when v_track=x"0" else v1_buffer;
--	v2_buffer <= v_buffer_A when v_track=x"1" else v2_buffer;
--	v3_buffer <= v_buffer_A when v_track=x"2" else v3_buffer;
--	v4_buffer <= v_buffer_A when v_track=x"3" else v4_buffer;
--	-- SDO_B line
--	v5_buffer <= v_buffer_B when v_track=x"0" else v5_buffer;
--	v6_buffer <= v_buffer_B when v_track=x"1" else v6_buffer;
--	v7_buffer <= v_buffer_B when v_track=x"2" else v7_buffer;
--	v8_buffer <= v_buffer_B when v_track=x"3" else v8_buffer;
	
-------
--===================================================
--  Buffer Outputs / delayed busy signal
--===================================================
-- Register ADC register outputs once all data has been read
-- NOTE: as of 12/13/21, the ADC boards have the inputs to the instrumentation amp swapped
-- which means that the ADC is seeing the 'negative' of the sampled waveform. To correct this
-- we will implement invert and add 1 to make these registered values be positive.
--
--
	process (clock)
		begin
			if clock'event and clock = '1' then			
				IF state = x"9" THEN
					v1<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v1_buffer))+1);
					v2<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v2_buffer))+1);
					v3<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v3_buffer))+1);
					v4<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v4_buffer))+1);
					v5<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v5_buffer))+1);
					v6<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v6_buffer))+1);
					v7<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v7_buffer))+1);
					v8<=STD_LOGIC_VECTOR(UNSIGNED(NOT(v8_buffer))+1);					
				END IF;
			end if;
	end process;
	
	-- delayed busy signal:
	-- if we are in any state but the IDLE state, shift in a 1
	-- otherwise shift in a 0
	-- busy will be an OR with the current and previosu 3 ticks
	-- which will produce a slight lag
	process (clock)
		begin
			if clock'event and clock = '1' then			
				IF state = x"0" THEN
					busy_d <= busy_d(1 downto 0) & '0';
				ELSE	
					busy_d <= busy_d(1 downto 0) & '1';
				END IF;
			end if;
	end process;
	
	busy <= '1' when ((busy_d(0)='1')OR(busy_d(1)='1')OR(busy_d(2)='1')) else '0';

-------
--===================================================
--  
--===================================================
-------
END AD7606B;