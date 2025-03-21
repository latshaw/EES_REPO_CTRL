LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;
use ieee.numeric_std.all;

-- modifed by JAL on 2/10/2020, we upgrade to 16 bit adc. the legacy code was using 12 bit + sign
-- the new adc are 16 bit with values in 2's complement.
-- 11/15/24, added a timer to only trip IF in this fault for xx clocks (assume 8ns ticks)

ENTITY TMP_COMPARE IS
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 TMPCLD_DATA : IN REG16_ARRAY; -- input channel temperature
		 TMPWRM_DATA : IN REG16_ARRAY;		 
		 TMPCLD_LIMIT : IN REG16_ARRAY; -- fault if above this limit
		 TMPWRM_LIMIT : IN REG16_ARRAY;
		 MASK_TMP_FAULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);--MASK_TMP_FAULT[7..0]--TMPWRM_MASK,[15..8]--TMPCLD_MASK
		 TMPCLD_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- set HI to clear fault
		 TMPWRM_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0); 
		 
		 TMPCLD_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		 -- latched faults
		 TMPCLD_STATUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		 -- unlatched, current fault
		 TMPWRM_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_STATUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)		 
		 );
END ENTITY TMP_COMPARE;

ARCHITECTURE BEHAVIOR OF TMP_COMPARE IS

TYPE REG28_ARRAY IS ARRAY(7 DOWNTO 0) OF UNSIGNED(27 DOWNTO 0);

SIGNAL TMPCLD_CHECK		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_CHECK		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL ONE				: STD_LOGIC;

signal not_TMPCLD_FAULT_CLEAR : STD_LOGIC_VECTOR(7 DOWNTO 0);
signal not_TMPWRM_FAULT_CLEAR : STD_LOGIC_VECTOR(7 DOWNTO 0);

signal cold_fault_count, cold_fault_count_d : REG28_ARRAY;
signal warm_fault_count, warm_fault_count_d : REG28_ARRAY;

BEGIN

ONE <= '1';

GEN_TMP_FAULT: FOR I IN 0 TO 7 GENERATE
--check to see if over limit, signal is HI if over limit


--TMPCLD_CHECK(I) <= '1' WHEN ((TMPCLD_DATA(I)(14 DOWNTO 0) > TMPCLD_LIMIT(I)(14 DOWNTO 0)) AND (TMPCLD_DATA(I)(15) = TMPCLD_LIMIT(I)(15))) OR
--							        (TMPCLD_DATA(I)(15) = '0' AND TMPCLD_LIMIT(I)(15) = '1') ELSE '0';

TMPCLD_CHECK(I) <= '1' WHEN cold_fault_count(I) = x"FFFFFFF" else '0';

cold_fault_count_d(I) <= cold_fault_count(I) + 1 when ((TMPCLD_DATA(I)(14 DOWNTO 0) > TMPCLD_LIMIT(I)(14 DOWNTO 0)) AND (TMPCLD_DATA(I)(15) = TMPCLD_LIMIT(I)(15))) OR
							        (TMPCLD_DATA(I)(15) = '0' AND TMPCLD_LIMIT(I)(15) = '1') else x"0000000";								  
									
									  
TMPCLD_STATUS(I) <= '1' WHEN ((TMPCLD_DATA(I)(14 DOWNTO 0) > TMPCLD_LIMIT(I)(14 DOWNTO 0)) AND (TMPCLD_DATA(I)(15) = TMPCLD_LIMIT(I)(15))) OR
							        (TMPCLD_DATA(I)(15) = '0' AND TMPCLD_LIMIT(I)(15) = '1') ELSE '0';
										
not_TMPCLD_FAULT_CLEAR(I) <= NOT TMPCLD_FAULT_CLEAR(I);

	-- if overlimit condition occurs, latch fault
	TMPCLD_FAULT_LATCHI: LATCH_N
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 CLEAR	=> not_TMPCLD_FAULT_CLEAR(I),
			 EN		=> TMPCLD_CHECK(I),
			 INP	=> ONE,
			 OUP	=> TMPCLD_FAULT(I)
			);
		
--check to see if over limit, signal is HI if over limit	
-- check to see if adc channel is > limit AND the adc sign bit and limit sign bit are the same 
--		trip in these cases 1) neg limit and adc content is negative with a greater magnitude (trip in this case)
--								  2) pos limit and adc content is positive with a greater magnitude (trip in this case)
-- OR
-- check if adc is a positive value and the limit is a negative value (trip in this case)
--TMPWRM_CHECK(I) <= '1' WHEN ((TMPWRM_DATA(I)(14 DOWNTO 0) > TMPWRM_LIMIT(I)(14 DOWNTO 0)) AND (TMPWRM_DATA(I)(15) = TMPWRM_LIMIT(I)(15))) OR
--							        (TMPWRM_DATA(I)(15) = '0' AND TMPWRM_LIMIT(I)(15) = '1') ELSE '0';

TMPWRM_CHECK(I) <= '1' WHEN warm_fault_count(I) = x"FFFFFFF" else '0';

warm_fault_count_d(I) <= warm_fault_count(I) + 1 when ((TMPWRM_DATA(I)(14 DOWNTO 0) > TMPWRM_LIMIT(I)(14 DOWNTO 0)) AND (TMPWRM_DATA(I)(15) = TMPWRM_LIMIT(I)(15))) OR
							        (TMPWRM_DATA(I)(15) = '0' AND TMPWRM_LIMIT(I)(15) = '1') else x"0000000";	
									  
TMPWRM_STATUS(I) <= '1' WHEN ((TMPWRM_DATA(I)(14 DOWNTO 0) > TMPWRM_LIMIT(I)(14 DOWNTO 0)) AND (TMPWRM_DATA(I)(15) = TMPWRM_LIMIT(I)(15))) OR
							        (TMPWRM_DATA(I)(15) = '0' AND TMPWRM_LIMIT(I)(15) = '1') ELSE '0';
	
	not_TMPWRM_FAULT_CLEAR(I) <= NOT TMPWRM_FAULT_CLEAR(I);
	
	-- if overlimit condition occurs, latch fault
	TMPWRM_FAULT_LATCHI: LATCH_N
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 CLEAR	=> not_TMPWRM_FAULT_CLEAR(I),
			 EN		=> TMPWRM_CHECK(I),
			 INP	=> ONE,
			 OUP	=> TMPWRM_FAULT(I)
			);			
			
	process(CLOCK, RESET)
	begin
		if RESET = '0' then
			cold_fault_count(I) <= (others	=>	'0');
			warm_fault_count(I) <= (others	=>	'0');
		elsif CLOCK'event and CLOCK='1' then 
			cold_fault_count(I) <= cold_fault_count_d(I);
			warm_fault_count(I) <= warm_fault_count_d(I);
		end if; -- end reset
	end process;
	
END GENERATE;

END ARCHITECTURE BEHAVIOR;