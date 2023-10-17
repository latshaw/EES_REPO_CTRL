LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY RESETS IS
	PORT(CLOCK : IN STD_LOGIC;
		 BRD_RESET : IN STD_LOGIC;
		 ISA_RESET_FPGA : IN STD_LOGIC;
		 REG_RESET : IN STD_LOGIC;
		 RESET : OUT STD_LOGIC
		);
END ENTITY RESETS;

ARCHITECTURE BEHAVIOR OF RESETS IS

SIGNAL EN_RESET_TIMER	: STD_LOGIC;
SIGNAL RESET_COUNT		: STD_LOGIC_VECTOR(4 DOWNTO 0); 
SIGNAL RESET_TIMER		: STD_LOGIC;

signal reg_reset1			: std_logic;
signal reg_reset2			: std_logic;

SIGNAL ONE					: STD_LOGIC;

BEGIN

	ONE	<= '1';
	
	
	Reg_reset_FF1: latch_n
	port map(clock	=> clock,
				reset	=> BRD_RESET,
				clear	=> '1',
				en		=> '1', 
				inp	=> REG_RESET, 
				oup	=> reg_reset1 
				);
				
	Reg_reset_FF2: latch_n
	port map(clock	=> clock,
				reset	=> BRD_RESET,
				clear	=> '1',
				en		=> '1', 
				inp	=> reg_reset1, 
				oup	=> reg_reset2 
				);
		
	


	RESET_TIMER_COUNTER: COUNTER
		GENERIC MAP(N => 5)
		PORT MAP(CLOCK	=> CLOCK,
			 	 RESET	=> BRD_RESET,
				 CLEAR	=> ONE,
			 	 ENABLE	=> EN_RESET_TIMER,
			 	 COUNT	=> RESET_COUNT
				);
	
	
	EN_RESET_TIMER	<= '1' WHEN (RESET_COUNT /= "11111") ELSE '0';
	
--	reset_timer		<= '1' when en_reset_timer = '1' else '0';
	
	-- reset if we have a reset request from epics or if the active low board level reset is being placed or for 31*8 = 248 ns after board reset
	RESET	<= '0' when reg_reset2 = '1' OR BRD_RESET = '0' OR RESET_COUNT /= "11111" ELSE '1';

--reset	<= brd_reset;



END ARCHITECTURE BEHAVIOR;


		 