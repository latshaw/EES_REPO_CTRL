-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE WORK.COMPONENTS.ALL;

library altera;
use altera.altera_syn_attributes.all;

entity resonance_control_fpga_rev_pr is
	port
	(
-- {ALTERA_IO_BEGIN} DO NOT REMOVE THIS LINE!

		clock : in std_logic; -- 100 MHz clock, C10_CLKUSR
		reset : in std_logic; -- Switch 1, C10 Reset
			
		m10_reset : in std_logic;
		hb_fpga : out std_logic;
		
		sfp_sda_0 : inout std_logic;
		sfp_scl_0 : out std_logic;
		sfp_refclk_p : in std_logic;		
		sfp_tx_0_p : out std_logic;
		sfp_rx_0_p : in std_logic;
		
		FIBER_1 : in std_logic;
		FIBER_2 : in std_logic;
		FIBER_3 : in std_logic;
		FIBER_4 : in std_logic;
		FIBER_5 : in std_logic;
		FIBER_6 : in std_logic;
		FIBER_7 : in std_logic;
		FIBER_8 : in std_logic;
		
		ADC_DOUT : out std_logic;
		ADC_DIN : in std_logic;
		ADC_CS : out std_logic;
		ADC_SCLK : out std_logic;
		
		STEP1 : out std_logic;
		STEP2 : out std_logic;
		STEP3 : out std_logic;
		STEP4 : out std_logic;

		DIR1 : out std_logic;
		DIR2 : out std_logic;
		DIR3 : out std_logic;
		DIR4 : out std_logic;
		
		SDI1 : out std_logic;
		SDI2 : out std_logic;
		SDI3 : out std_logic;
		SDI4 : out std_logic;
		
		SCLK1 : out std_logic;
		SCLK2 : out std_logic;
		SCLK3 : out std_logic;
		SCLK4 : out std_logic;
		
		SDO1 : in std_logic;
		SDO2 : in std_logic;
		SDO3 : in std_logic;
		SDO4 : in std_logic;
		
		CSN1 : out std_logic;
		CSN2 : out std_logic;
		CSN3 : out std_logic;
		CSN4 : out std_logic;
		
		EN1 : out std_logic;
		EN2 : out std_logic;
		EN3 : out std_logic;
		EN4 : out std_logic;
		
		HFLF1 : in std_logic;
		LFLF1 : in std_logic;
		HFLF2 : in std_logic;
		LFLF2 : in std_logic;
		HFLF3 : in std_logic;
		LFLF3 : in std_logic;
		HFLF4 : in std_logic;
		LFLF4 : in std_logic;
		
		STEP1_1 : out std_logic;
		STEP2_1 : out std_logic;
		STEP3_1 : out std_logic;
		STEP4_1 : out std_logic;
		
		DIR1_1 : out std_logic;
		DIR2_1 : out std_logic;
		DIR3_1 : out std_logic;
		DIR4_1 : out std_logic;
		
		SDI1_1 : out std_logic;
		SDI2_1 : out std_logic;
		SDI3_1 : out std_logic;
		SDI4_1 : out std_logic;

		SCLK1_1 : out std_logic;
		SCLK2_1 : out std_logic;
		SCLK3_1 : out std_logic;
		SCLK4_1 : out std_logic;
		
		SDO1_1 : in std_logic;
		SDO2_1 : in std_logic;
		SDO3_1 : in std_logic;
		SDO4_1 : in std_logic;
			
		CSN1_1 : out std_logic;
		CSN2_1 : out std_logic;
		CSN3_1 : out std_logic;
		CSN4_1 : out std_logic;
		
		EN1_1 : out std_logic;
		EN2_1 : out std_logic;
		EN3_1 : out std_logic;
		EN4_1 : out std_logic;
		
		HFLF1_1 : in std_logic;
		LFLF1_1 : in std_logic;
		HFLF2_1 : in std_logic;
		LFLF2_1 : in std_logic;
		HFLF3_1 : in std_logic;
		LFLF3_1 : in std_logic;
		HFLF4_1 : in std_logic;
		LFLF4_1 : in std_logic;
		
		LED_SDA : inout std_logic;
		LED_SCL : out std_logic;
		
		OE_CONT1 : out std_logic;
		OE_CONT1_1 : out std_logic;
		SDA_M1 : inout std_logic;
		SDA_M1_1 : inout std_logic;
		DIR_CONT1 : out std_logic;
		DIR_CONT1_1 : out std_logic;
		
		GA1 : out std_logic;
		GA0 : out std_logic;
		FMC2_SDA : inout std_logic;
		FMC2_SCL : out std_logic;
		SCLM1 : inout std_logic;
		SCLM1_1 : inout std_logic;
		
		gpio_led_1			:	out std_logic;
		gpio_led_2			:	out std_logic;
		gpio_led_3			:	out std_logic
		
-- {ALTERA_IO_END} DO NOT REMOVE THIS LINE!

	);

-- {ALTERA_ATTRIBUTE_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_ATTRIBUTE_END} DO NOT REMOVE THIS LINE!
end resonance_control_fpga_rev_pr;

architecture ppl_type of resonance_control_fpga_rev_pr is
-- add components

COMPONENT TMC2660
PORT(CLOCK : IN STD_LOGIC;
	 RESET : IN STD_LOGIC;
	 DRVI : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- specify current scale
	 DRVI_CONFIG : IN STD_LOGIC;			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG : IN STD_LOGIC; -- set HI to start state machine
	 SDO : IN STD_LOGIC;		  -- SDO is (not used?)
	 INHIBIT : IN STD_LOGIC;      -- directly connected to ouput SEN (not used?)
	 CSN : OUT STD_LOGIC;
	 SCK : OUT STD_LOGIC;
	 SDI : OUT STD_LOGIC;
	 SEN : OUT STD_LOGIC;	 -- loop back INHIBIT 
	 CONFIG_DONE : OUT STD_LOGIC
	 );
END COMPONENT;

			

signal clk_50, config_start, inhibit : STD_LOGIC;
signal config_done : STD_LOGIC_VECTOR(7 downto 0);

-- {ALTERA_COMPONENTS_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_COMPONENTS_END} DO NOT REMOVE THIS LINE!
begin
-- {ALTERA_INSTANTIATION_BEGIN} DO NOT REMOVE THIS LINE!
-- {ALTERA_INSTANTIATION_END} DO NOT REMOVE THIS LINE!


--=======================================================
-- Time Base test (1, PASS) and Limit Switches (2, PASS)
--=======================================================
-- (1) Goal, test on board 100 MHz clock and reset with simple counter
-- will incrment LEDs on C10 board at half second steps (8 seconds to go from all off to all 4 on)
-- 
-- (2) Goal, visual check for limit swithces. Limit switches are active low and when all switches are open
-- the LEDs should read 1111 (all HI). Whenever a limit switch is flipped a low will be asserted for that LED.
-- the limit switch on the stepper test box (left to right) should match the LEDS (left to right)


process (clock, reset, HFLF1, HFLF2, HFLF3, HFLF4, HFLF1_1, HFLF2_1, HFLF3_1, HFLF4_1, LFLF1, LFLF2, LFLF3, LFLF4, LFLF1_1, LFLF2_1, LFLF3_1, LFLF4_1)
	variable counter     :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
	variable led_control :  STD_LOGIC_VECTOR(3 downto 0) := x"0";
	variable limitMonitor : STD_LOGIC := '0';
begin
	if reset = '0' then
		-- active low reset
		counter := x"00000000";
		led_control := x"0";
		limitMonitor := '0';
	else
		if (clock'event and clock = '1') then
			--check to see if .5 second(s) have passed
			if counter >= x"02FAF080" OR (limitMonitor = '1') then
				-- check to see if 8 seconds have passed
				if (led_control = "1111") OR (limitMonitor = '1') then
					-- Stay in this state until reset
					counter := x"FFFFFFFF";
					limitMonitor := '1';
					led_control(3 downto 0) := "1111";
				else
					--if not, increment counter (will see in LEDS)
					led_control := led_control + 1;
					counter := x"00000000";
					limitMonitor := '0';
				end if;
				
			else
				--counter has not exceeded, incrmenet counter, keep leds the same
				counter := counter + 1;
				limitMonitor := '0';
				led_control := led_control;
			end if;
		end if;
	end if;
		--update leds
		if limitMonitor = '0' then
			hb_fpga    <= led_control(0); --left most         (D1,  Heart Beat)
			gpio_led_1 <= led_control(1); --Second from left  (D16, Pin N1)
			gpio_led_2 <= led_control(2); --Second from right (D17, Pin T1)
			gpio_led_3 <= led_control(3); --right most        (D18, Pin R2)
		else
			--relay limit switches to LEDs (the order should match the stepper test board)
			hb_fpga    <= (LFLF2 AND LFLF2_1) AND (LFLF4 AND LFLF4_1);
			gpio_led_1 <= (HFLF2 AND HFLF2_1) AND (HFLF4 AND HFLF4_1);
			gpio_led_2 <= (LFLF1 AND LFLF1_1) AND (LFLF3 AND LFLF3_1);
			gpio_led_3 <= (HFLF1 AND HFLF1_1) AND (HFLF3 AND HFLF3_1);
		end if;	
end process;


--=======================================================
-- Stepper Test, load SPI (3, PASS), move stepper (4, PASS)
--=======================================================
--Goal, configure steppers over SPI, Test, Enable, Direction and step

--produce 50 MHz clock for TMC module (SCLK is at 400 KHz)
process (clock, reset)
	variable counter     :  STD_LOGIC_VECTOR(3 downto 0) := x"0";
begin
	if reset = '0' then
		counter := x"0";
		clk_50 <= '0';
	else
		if clock'event and clock = '1' then
			if (counter >= x"0") AND (counter < x"2") then
				clk_50 <= '1';
				counter := counter + 1;
			elsif (counter >= x"2") AND (counter < x"4") then
				clk_50 <= '0';
				counter := counter + 1;
			else
				clk_50 <= '0';
				counter := x"0";
			end if;
		end if;
	end if;
end process;

-- instantiate component
	TMC_U27: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO1,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN1,
	 SCK => SCLK1,
	 SDI => SDI1,
	 SEN => EN1,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(0)
	 );
	 
-- instantiate component
	TMC_U28: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO2,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN2,
	 SCK => SCLK2,
	 SDI => SDI2,
	 SEN => EN2,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(1)
	 );
	 
	TMC_U29: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO3,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN3,
	 SCK => SCLK3,
	 SDI => SDI3,
	 SEN => EN3,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(2)
	 );
	 
	TMC_U26: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO4,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN4,
	 SCK => SCLK4,
	 SDI => SDI4,
	 SEN => EN4,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(3)
	 );
	
--- other hald of the steppers

-- instantiate component
	TMC_U1: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO1_1,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN1_1,
	 SCK => SCLK1_1,
	 SDI => SDI1_1,
	 SEN => EN1_1,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(4)
	 );
	 
-- instantiate component
	TMC_U34: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO2_1,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN2_1,
	 SCK => SCLK2_1,
	 SDI => SDI2_1,
	 SEN => EN2_1,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(5)
	 );
	 
	TMC_U40: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO3_1,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN3_1,
	 SCK => SCLK3_1,
	 SDI => SDI3_1,
	 SEN => EN3_1,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(6)
	 );
	 
	TMC_U46: TMC2660
	PORT MAP(CLOCK => clk_50,
	 RESET => reset,
	 DRVI=> "00111", -- specify current scale
	 DRVI_CONFIG => '1',			 -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
	 START_CONFIG => config_start, -- set HI to start state machine
	 SDO => SDO4_1,		  -- SDO is (not used?)
	 INHIBIT => inhibit,      -- directly connected to ouput SEN (not used?)
	 CSN => CSN4_1,
	 SCK => SCLK4_1,
	 SDI => SDI4_1,
	 SEN => EN4_1,	 -- loop back INHIBIT 
	 CONFIG_DONE => config_done(7)
	 );	


process (clock, reset)
	variable counter     :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
	variable done : STD_LOGIC := '0';
begin
	if reset = '0' then
		counter := x"00000000";
		done := '0';
		config_start <= '0';
	else
		if clock'event and clock = '1' then
			if (counter >= x"02FAF080") OR (done = '1') then
				config_start <= '0';
				counter := x"FFFFFFFF";
				done := '1';
			else
				config_start <= '1';
				counter := x"00000000";
				counter := counter + 1;
				done := '0';
			end if;
		end if;
	end if;
end process;

--pull hi to let the motor 'free wheel'
--pull low to engage stepper
inhibit <= '0';-- when CONFIG_DONE = '1' else '0';
--(3) done

--(4) use U27 to drive stepper. DIR = 0 -> CCW, DIR = 1 -> CW rotation
-- DEDGE = 0, so we only step on rising edge.

process (clock, reset)
	variable counter     :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
	variable counter2    :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
begin
	if reset = '0' then
		counter  := x"00000000";
		counter2 := x"00000000";
		STEP1 <= '0'; DIR1 <='0';
		STEP2 <= '0'; DIR2 <='0';
		STEP3 <= '0'; DIR3 <='0';
		STEP4 <= '0'; DIR4 <='0';
		--other half
		STEP1_1 <= '0'; DIR1_1 <='0';
		STEP2_1 <= '0'; DIR2_1 <='0';
		STEP3_1 <= '0'; DIR3_1 <='0';
		STEP4_1 <= '0'; DIR4_1 <='0';
	else
		if clock'event and clock = '1' then
			--control STEP
			if    (counter <= x"0000C350") then  counter := counter + 1; STEP1   <= '1'; STEP2   <= '1'; STEP3   <= '1'; STEP4   <= '1';
																							 STEP1_1 <= '1'; STEP2_1 <= '1'; STEP3_1 <= '1'; STEP4_1 <= '1';
			elsif (counter <= x"000186A0") then  counter := counter + 1; STEP1   <= '0'; STEP2   <= '0'; STEP3   <= '0'; STEP4   <= '0';
																							 STEP1_1 <= '0'; STEP2_1 <= '0'; STEP3_1 <= '0'; STEP4_1 <= '0';
			else                                 counter := x"00000000"; STEP1   <= '0'; STEP2   <= '0'; STEP3   <= '0'; STEP4   <= '0';
																							 STEP1_1 <= '0'; STEP2_1 <= '0'; STEP3_1 <= '0'; STEP4_1 <= '0';
			end if;
			--control DIR
			if    (counter2 <= x"30000000") then  counter2 := counter2 + 1; DIR1   <= '1'; DIR2   <= '1'; DIR3   <= '1'; DIR4   <= '1'; 
																							    DIR1_1 <= '1'; DIR2_1 <= '1'; DIR3_1 <= '1'; DIR4_1 <= '1';
			elsif (counter2 <= x"60000000") then  counter2 := counter2 + 1; DIR1   <= '0'; DIR2   <= '0'; DIR3   <= '0'; DIR4   <= '0';
																								 DIR1_1 <= '0'; DIR2_1 <= '0'; DIR3_1 <= '0'; DIR4_1 <= '0';
			else                                  counter2 := x"00000000";  DIR1   <= '0'; DIR2   <= '0'; DIR3   <= '0'; DIR4   <= '0'; 
																								 DIR1_1 <= '0'; DIR2_1 <= '0'; DIR3_1 <= '0'; DIR4_1 <= '0'; 
			end if;	
		end if;
	end if;
end process;

--process (clock, reset)
--	variable counter     :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
--	variable counter2    :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
--	variable DIR1_buffer : STD_LOGIC := '0';
--begin
--	if reset = '0' then
--		counter  := x"00000000";
--		counter2 := x"00000000";
--		DIR1_buffer  := '0';
--		STEP1 <= '0';
--	else
--		if clock'event and clock = '1' then
--			if (counter2 <= x"30000000") then
--				
--				counter2 := counter2 + 1;
--				DIR1_buffer  := DIR1_buffer;
--								
--				if (counter <= x"0000C350") then
--					counter := counter + 1;
--					STEP1 <= '1';
--				elsif (counter >= x"000186A0") then
--					counter := x"00000000";
--					STEP1 <= '0';
--				else
--					counter := counter + 1;
--					STEP1 <= '0';
--				end if;			
--			else
--				counter2 := x"00000000";
--				DIR1_buffer  := NOT(DIR1_buffer);
--				STEP1 <= '0';
--			end if;
--		end if;
--	end if;
--	
--	DIR1 <= DIR1_buffer;
--end process;
-- (4) done, all motors pass basic test (SPI program, turn motors both ways)

end;

