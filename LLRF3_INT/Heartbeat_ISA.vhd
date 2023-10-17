
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Heartbeat_ISA IS 
	PORT
	(	
		clock  : IN  	STD_LOGIC; -- input clock (assumed 100 MHz), see 6/22/21 note, upadted for 125 Mhz
		reset  : IN  	STD_LOGIC; -- active low reset
		LED	 : OUT 	STD_LOGIC  -- Led out
		
	);
END Heartbeat_ISA;


ARCHITECTURE rtl OF Heartbeat_ISA IS 
--
-- Add Signals here if needed
--
BEGIN
--=================================================
-- Simple Counter
--=================================================
--
-- JAL 6/22/21, counters changed for 125 Mhz
-- old half count 00BEBC20
-- old full count 017D7840
-- want this to not be a perfect second (because epics polls at one second).
-- shoudl be 1/3 Hz
	process (clock, reset)
		variable counter : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
	begin
		IF (reset = '0') THEN
			counter 	:= x"00000000";
			LED 		<= '0';
		ELSIF (clock = '1' AND clock'event) THEN
			IF 	counter <= x"0B2D05E0" THEN	LED <= '1'; counter := counter + 1;
			ELSif counter <= x"165A0BC0" THEN	LED <= '0'; counter := counter + 1;
			ELSE											LED <= '0'; counter := x"00000000";
			END IF;
		END IF;
	end process;

END rtl;