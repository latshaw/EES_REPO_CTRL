LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

ENTITY HEARTBEAT_ISA IS

PORT(CLOCK	: IN STD_LOGIC;
	  RESET	: IN STD_LOGIC;
	  	  
	  HB_ISA	: OUT STD_LOGIC
	  );
	  
END ENTITY HEARTBEAT_ISA;

ARCHITECTURE BEHAVIOR OF HEARTBEAT_ISA IS

TYPE STATE_TYPE IS (S0, S1, S2, S3);
SIGNAL Y						: STATE_TYPE;

SIGNAL EN_HB_COUNT		: STD_LOGIC;
SIGNAL CLR_HB_COUNT		: STD_LOGIC;
SIGNAL HB_COUNT, hb_count_d			: STD_LOGIC_VECTOR(26 DOWNTO 0);


BEGIN

process(clock, reset)
begin
	if(reset = '0') then
		hb_count	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		hb_count	<=	hb_count_d;
	end if;
end process;
hb_count_d	<=	(others	=>	'0') when clr_hb_count = '0' else
					std_logic_vector(unsigned(hb_count) + 1) when en_hb_count = '1' else
					hb_count;


					
	PROCESS(CLOCK, RESET)
	BEGIN
		IF RESET = '0' THEN Y <= S0;
		ELSIF (CLOCK = '1' AND CLOCK'EVENT) THEN
			CASE Y IS
			
				WHEN S0	=>	IF HB_COUNT	= "110" & X"ACFC00" THEN Y <= S1;
								ELSE Y <= S0;
								END IF;
								
				WHEN S1	=> IF HB_COUNT = "110" & X"ACFC00" THEN Y <= S2;
								ELSE Y <= S1;
								END IF;
								
				WHEN S2	=>	IF HB_COUNT = "110" & X"ACFC00" THEN Y <= S3;
								ELSE Y <= S2;
								END IF;
								
				WHEN S3	=> IF HB_COUNT = "110" & X"ACFC00" THEN Y <= S0;
								ELSE Y <= S3;
								END IF;
									
				WHEN OTHERS	=> Y <= S0;
				
			END CASE;
			
		END IF;
	END PROCESS;
		
CLR_HB_COUNT 	<= '0' WHEN ((Y = S0 OR Y = S1 OR Y = S2 OR Y = S3) AND HB_COUNT = "110" & X"ACFC00")	ELSE '1';	

EN_HB_COUNT 	<= '1' WHEN ((Y = S0 OR Y = S1 OR Y = S2 OR Y = S3) AND HB_COUNT /= "110" & X"ACFC00")	ELSE '0';


HB_ISA			<= '1' WHEN Y = S0 OR Y = S2 ELSE '0';
									

END ARCHITECTURE BEHAVIOR;