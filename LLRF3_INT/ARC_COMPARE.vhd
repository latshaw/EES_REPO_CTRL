LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY ARC_COMPARE IS
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 ARC_DATA : IN REG16_ARRAY; -- arc input data (channel specific)
		 ARC_LIMIT : IN REG16_ARRAY; -- specify arc limit (fault if over this limit, channel specific)
		 ARC_TIMER : IN REG16_ARRAY; -- number of continous ticks before issuing an arc fault (channel specific)
		 MASK_ARC_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- not used
		 ARC_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- set hi to clear that channels fault (channel specific)
		 ARC_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- latch an arc fault has existed for the specified interval (channel specific)
		 ARC_STATUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- unfiltered value of fault check (channel specific)
		 );
END ENTITY ARC_COMPARE;

ARCHITECTURE BEHAVIOR OF ARC_COMPARE IS

SIGNAL ARC_STATUS_INT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_CHECK			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_COUNTER			: REG16_ARRAY;
SIGNAL EN_ARC_COUNTER		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CLEAR_ARC_COUNTER	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_TIMER_CHECK		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL ONE					: STD_LOGIC;

BEGIN



ONE		<= '1';
-- for each of the 8 channels, check to see if the arc data is greater than the set limit
-- HI means over the limit, LOW means less than or equal to the limit
GEN_ARC_CHECK_STATUS: FOR I IN 0 TO 7 GENERATE

	ARC_CHECK(I) <= '1' WHEN ARC_DATA(I) > ARC_LIMIT(I) ELSE '0';

	
END GENERATE;

	ARC_STATUS <= ARC_CHECK;


ARC_COUNTER_GEN: FOR I IN 0 TO 7 GENERATE

--clear counter if ARC_CHECK goes low (not over limit)
CLEAR_ARC_COUNTER(I) <= '0' WHEN (ARC_FAULT_CLEAR(I) = '1') OR (ARC_CHECK(I) = '0' AND ARC_TIMER_CHECK(I) = '0') ELSE '1';
--enable counter if ARC_CHECK remains hi
EN_ARC_COUNTER(I) <= '1' WHEN (ARC_CHECK(I) = '1' AND ARC_TIMER_CHECK(I) = '0' ) ELSE '0';
 
	-- This counter counts how many ticks the ARC_CHECK is in an 'over the limit' condition
	ARC_COUNTI: COUNTER
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK,
				 RESET	=> RESET,
				 CLEAR	=> CLEAR_ARC_COUNTER(I), -- to clear, input a LOW
				 ENABLE	=> EN_ARC_COUNTER(I),	-- enable counter if HI
				 COUNT	=> ARC_COUNTER(I)
				);
		
	-- check to see if the acr counter has reached the specified input time
	-- this means that ARC_CHECK has been in a continous fault condiiton for ARC_TIMER ticks
	ARC_TIMER_CHECK(I) <= '1' WHEN ARC_COUNTER(I) = ARC_TIMER(I) ELSE '0'; 


END GENERATE;


ARC_FAULT_GEN: FOR I IN 0 TO 7 GENERATE
	
	ARC_FAULT_LATCHI: LATCH_N
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 CLEAR	=> NOT ARC_FAULT_CLEAR(I), -- command to clear a latched event
			 EN		=> ARC_TIMER_CHECK(I), -- if hi, means we have been over the limit for the specified number of ticks
			 INP	=> ONE,
			 OUP	=> ARC_FAULT(I) -- channel specific arc output
			);

END GENERATE; 


END ARCHITECTURE BEHAVIOR;