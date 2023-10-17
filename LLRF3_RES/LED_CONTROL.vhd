-- LLRF 3.0, module for LED control
--
-- Latshaw, 11/17/2020
--
-- This module communicates over an I2C bus with a TI, 16 expander to 16 leds.
-- Wire up clock with 100 MHz (or slower) and with an active low reset
-- 
--
-- 3/12/21, updated values for 125 Mhz clock rate
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY LED_CONTROL IS
	generic (testBench : STD_LOGIC := '0'); 
	PORT
	(	
		clock      : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n    : IN  	STD_LOGIC; -- active low reset
		LED_TOP	  : IN  	STD_LOGIC_VECTOR(7 downto 0); -- upper LED on front panel
		LED_BOTTOM : IN  	STD_LOGIC_VECTOR(7 downto 0); -- lower LED on front panel
		SCL 		  : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
		SDA 		  : INOUT STD_LOGIC -- data line (data is bi directional), LED_SDA
	);
END LED_CONTROL;

ARCHITECTURE rtl OF LED_CONTROL IS 
	-- components here
	component gen_i2c IS
	generic (testBench : STD_LOGIC := '0');
	PORT
	(	
		clock     : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n   : IN  	STD_LOGIC; -- active low reset
		EN			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
		ADDR 	 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address
		RW			 : IN  	STD_LOGIC; -- read/write, read = HI, writes = LOW
		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); -- input data, lsByte sent first
		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0); -- read data (leave OPEN if not used)
		P_width 	 : IN  	STD_LOGIC_VECTOR(1 downto 0); --Choose how many bytes to transmit
		S_ACK		 : OUT 	STD_LOGIC; -- Status for ack, HI= ack recieved, LO = no ack
		SCL 		 : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz)
		SDA 		 : INOUT STD_LOGIC;  -- data line (data is bi directional)
		rdy       : OUT   STD_LOGIC;
		dir		 : OUT   STD_LOGIC
	);
	END component;
	
	-- signals here
	signal count_FULL, count_Half : STD_LOGIC_VECTOR(31 downto 0);
	signal DATA_LED : STD_LOGIC_VECTOR(23 downto 0);
	signal ADDR_LED : STD_LOGIC_VECTOR(6 downto 0);
	signal EN_LED : STD_LOGIC;
	--
BEGIN
	--
	--===================================================
	--		Couter Generates (shorter if in test bench mode)
	--===================================================
	--
	gen_counter_tb1 : if testBench = '1' generate
		-- use smaller counters to speed up test bench
		count_FULL	<= x"00000140";
		count_Half	<= x"000000A0";
	end generate gen_counter_tb1;
	--
	gen_counter_normal1 : if testBench = '0' generate
		-- real count values to support I2C
		count_FULL	<= x"005F5E10"; -- 100 Mhz value 0098967F, 125 Mhz values
		count_Half	<= x"002FAF08"; -- 100 Mhz value 004C4B40, 125 Mhz values
	end generate gen_counter_normal1;
	--
	--===================================================
	--		16 LED expansion (I2C)
	--===================================================
	--
	 LED_i2c : gen_i2c
	 generic map (testBench=>testBench)
	 PORT MAP	(	
		clock   => clock,
		reset_n => reset_n,
		EN		  => EN_LED,
		ADDR 	  => ADDR_LED,
		RW		  => '0', --writes only in this configuration
		DATA	  => DATA_LED,
		DATA_R  => open,
		P_width => "10", -- 3 bytes
		S_ACK	  => open,
		SCL 	  => SCL,
		SDA 	  => SDA,
		rdy     => open,
		dir	  => open
	);
	
	--
	--===================================================
	--		Main Process
	--===================================================
	--
	-- Main process for 16 LEDs on the panels
	--		1) Configure all ports to outputs (happens once upon reset)
	--		2) Update 16 expander outputs with desired LED data (happens on an interval)
	--
	--	Notes:
	-- I2C packet : address + rnw + port_configure + port0 + port1
	-- I2C packet : address + rnw + port_configure + LED_BOTTOM + LED_TOP
	-- for LED_TOP, LED_BOTTOM  (leds are left to right when facing the front of the chassis):
	-- port0, bottom:  15 downto 8
	-- port1, top:      7 downto 0
	--
		process (clock, reset_n)
			variable counter    :  STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
			variable counter2   :  STD_LOGIC_VECTOR(7 downto 0) := x"00";
			variable hold_LED   :  STD_LOGIC := '0';
		begin
			if (reset_n = '0') then
				counter  := x"00000000";
				counter2 := x"00"; 
				ADDR_LED <= "0100000";
				DATA_LED <= (others => '0');
				EN_LED <= '0';  -- intiated I2C packet
				hold_LED := '0';-- after expander is configured set this Hi (expander only needs to be configured at turn on).
			else
				if clock'event and clock = '1' then
					--
					-- At power on, we will need to configure the internal registers
					-- of the 16 IO expander chip as outputs only
					--
					-- I2C bus will send a packet every time EN is pulsed HI
					-- update rate is 1/(50 ms + 50 ms) = 10 Hz 
					--
					IF    counter <= count_Half THEN	
						counter := counter + 1;
						EN_LED <= '0'; -- 50 ms low
					ELSIF counter <= count_FULL THEN
						counter := counter + 1;
						EN_LED <= '1'; -- 50 ms hi
					ELSE
						counter := x"00000000";
						EN_LED <= '1';
						--for initial configuration
						if counter2 < x"07" then
							counter2 := counter2 + 1;
							hold_LED := '0';
						else
							-- expander is configured, set hold_LED to 1 (expander configuration done)
							hold_LED := '1';
							-- we techniacally only need to confiugre cmd register 0x7 with 0's
							-- however this sets all internal registers to 0's
							counter2 := x"07";
						end if;
						--
					END IF;
					--
					-- This determines what packet will be sent when EN us pulsed HI
					IF hold_LED = '0' THEN
						--if expander configuration is NOT done
						-- then configure that register with 0's
						-- this will confiugre 8 internal registers (0 through 7)
						DATA_LED <= counter2 & x"00" & x"00";
					ELSE
						--if expander configuration is done
						--then begin to display led outputs
						DATA_LED <= x"02" & LED_BOTTOM & LED_TOP;
					END IF;
					--
				end if; -- end rising edge
			end if; -- end reset catch
		end process;
		--===================================================
		--		Output Notes to the IO Expander (front panel LEDs)
		--===================================================
		--
		-- LED_TOP(7 downto 0) will output to one of the 8 - LED boards
		-- LED_BOTTOM(7 downto 0) will output to the other 8 - LED boards 
--
END rtl;