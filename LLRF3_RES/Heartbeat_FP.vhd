
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Heartbeat_FP IS 
	PORT
	(	
		clock  : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset  : IN  	STD_LOGIC; -- active low reset
		isa_oe : IN 	STD_LOGIC; 
		hb_dig : OUT 	STD_LOGIC; -- always blinks
		hb_ioc : OUT 	STD_LOGIC  -- only blinks when there is a change in isa_oe
	);
END Heartbeat_FP;


ARCHITECTURE rtl OF Heartbeat_FP IS 
--
--
--
BEGIN
--=================================================
-- Simple Counter and Activity Monitor
--=================================================
--
-- loop through and blink LEDs, then wait for isa_oe to change state (i.e isa bus data)
-- then restart led blink. In this way the activity on the led can be monitored
-- (technically if all reads or all writes occur the LED will never blink).
--
	process (clock, reset)
		variable counter : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
		variable LED, last, save : STD_LOGIC := '0';  
	begin
		IF (reset = '0') THEN
			counter 	:= x"00000000";
			LED 		:= '0';
			last		:= '0';
			save		:= '0';
			hb_dig	<= '0';
			hb_ioc	<= '0';
		ELSIF (clock = '1' AND clock'event) THEN
			-- controls LED blink rate (simple LED counter), short pulses (250 ms on, 250 ms off)
			-- 00BEBC20
			-- 017D7840
			--
			-- 6/28/21, on for .8sec, off for .4 sec (to be off cycle with polling)
			-- assumes 125 Mhz clock 
			IF 	counter <= x"05F5E100" THEN	LED := '1'; counter := counter + 1;
			ELSif counter <= x"08F0D180" THEN	LED := '0'; counter := counter + 1;
			ELSE											LED := '0'; counter := x"00000000";
			END IF;
			-- 
			-- watches for isa_oe activity
			IF 	(save = '1') and (counter > x"00000000") THEN
				-- continue to output hb_IOC with the LED until the counter resets
				save   := '1';
				hb_ioc <= LED;
			ELSif (isa_oe /= last) THEN -- checks for a difference (rising edge or falling edge)
				-- activity has just occured
				-- begin outputting hb_ioc with LED's value
				save   := '1';
				hb_ioc <= LED;
			ELSE
				-- either no activity was detected or the counter
				-- has just reset. Regargless, do not output
				-- the LED. We will stay in this state until
				-- more activity occurs
				save   := '0';
				hb_ioc <= '0';
			END IF;
			-- update last bit
			last := isa_oe;
			-- hb_dig always blinks
			hb_dig <= LED;
			--
		END IF;
	end process;

END rtl;