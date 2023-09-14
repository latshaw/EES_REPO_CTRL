-- Originally writen by Rama,
-- modified 3/23/21 by JAL to incorporate changes form 80 Mhz clock to 125 MHz clock



LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY FCC_DATA_IN IS

PORT( RESET 			: IN STD_LOGIC;
		CLOCK 			: IN STD_LOGIC;
		FIBER_IN_DATA	: IN STD_LOGIC;
		CRC_DONE 		: IN STD_LOGIC;
		CRC_IN 			: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		
		CRC_DATA 		: OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
		DENOM 			: OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		START_CRC 		: OUT STD_LOGIC;		
		TRACK_ON 		: OUT STD_LOGIC;---------USED FOR POFF/RF OFF ON FC		
		DETA_DISC		: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);----"00"--DETA, "01"--DISC, "10"--PZT, "11" --INVALID
		DETA 				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		DISC 				: OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
		PZT 				: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		SLOW_MODE		: OUT STD_LOGIC
		
--		STEPS : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
		);
		
END ENTITY FCC_DATA_IN;

ARCHITECTURE BEHAVIOR OF FCC_DATA_IN IS

SIGNAL EN_PZT					: STD_LOGIC;

SIGNAL EN_DETA					: STD_LOGIC;

SIGNAL EN_DISC					: STD_LOGIC;

SIGNAL EN_FCC_MODE			: STD_LOGIC;

SIGNAL EN_COMMAND				: STD_LOGIC;

SIGNAL EN_STEPS				: STD_LOGIC;

SIGNAL ONE						: STD_LOGIC;

SIGNAL FIBER_IN_DATA_BUF0	: STD_LOGIC;
SIGNAL FIBER_IN_DATA_BUF1	: STD_LOGIC;
SIGNAL FIBER_IN_DATA_BUF2	: STD_LOGIC;

SIGNAL FCC_START_DATA_EN	: STD_LOGIC;

SIGNAL FCC_MODE				: STD_LOGIC_VECTOR(2 DOWNTO 0);

--SIGNAL COMMAND					: STD_LOGIC_VECTOR(23 DOWNTO 0);

--SIGNAL DISC_IN					: STD_LOGIC_VECTOR(27 DOWNTO 0);

SIGNAL EN_CRC_DATA			: STD_LOGIC;


SIGNAL CLR_BIT_COUNT			: STD_LOGIC;
SIGNAL EN_BIT_COUNT			: STD_LOGIC;
SIGNAL BIT_COUNT				: STD_LOGIC_VECTOR(5 DOWNTO 0);

SIGNAL CLR_CLK_COUNT			: STD_LOGIC;
SIGNAL EN_CLK_COUNT			: STD_LOGIC;

-- clock count was modified to support 125 Mhz clock 
-- SIGNAL CLK_COUNT			: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL CLK_COUNT				: STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL EN_SHIFT_REG			: STD_LOGIC;
SIGNAL CLR_SHIFT_REG			: STD_LOGIC;
SIGNAL FCC_DATA				: STD_LOGIC_VECTOR(39 DOWNTO 0);

SIGNAL CRC_DATA_OUT			: STD_LOGIC_VECTOR(39 DOWNTO 0);

SIGNAL WAIT_COUNT				: STD_LOGIC;

SIGNAL CLR_LOOP_COUNT		: STD_LOGIC;
SIGNAL EN_LOOP_COUNT			: STD_LOGIC;
SIGNAL LOOP_COUNT				: STD_LOGIC_VECTOR(5 DOWNTO 0);
	
SIGNAL CLR_CURRENT_COUNT	: STD_LOGIC;
SIGNAL EN_CURRENT_COUNT		: STD_LOGIC;
SIGNAL CURRENT_COUNT			: STD_LOGIC_VECTOR(5 DOWNTO 0);


TYPE STATE_TYPE IS (INIT, RCV_FIRST_BIT, RCV_DATA, LOAD_CRC_DATA, INIT_CRC, WAIT_CRC, CRC_CHECK, LOAD_DATA);
SIGNAL STATE					: STATE_TYPE;


------------REGISTER STRUCTURE--------
----1000-----FCC MODE & Detune Angle(deta(15..0) & deta_disc_select----"00"-deta, "01"-disc, "10"-pzt,"11"-invalid, track_enable)
----1001-----DISCRIMINATOR
----1010-----pzt value


--denom <= "100000111";



BEGIN

DENOM <= "100000111";

ONE <= '1';


-------DETECTING RISING EDGE OF START SIGNAL FROM FIBER (START BIT FOR DATA)-----------

	FCC_START_DET_FF0: LATCH_N 
		PORT MAP(CLOCK	=> CLOCK, 
					RESET	=> RESET,
					CLEAR	=> ONE, 
					EN		=> ONE,
					INP	=> FIBER_IN_DATA,
					OUP	=> FIBER_IN_DATA_BUF0
					);

	FCC_START_DET_FF1: LATCH_N 
		PORT MAP(CLOCK	=> CLOCK, 
					RESET	=> RESET,
					CLEAR	=> ONE, 
					EN		=> ONE,
					INP	=> FIBER_IN_DATA_BUF0,
					OUP	=> FIBER_IN_DATA_BUF1
					);
					
	FCC_START_DET_FF2: LATCH_N 
		PORT MAP(CLOCK	=> CLOCK, 
					RESET	=> RESET,
					CLEAR	=> ONE, 
					EN		=> ONE,
					INP	=> FIBER_IN_DATA_BUF1,
					OUP	=> FIBER_IN_DATA_BUF2
					);
					
	FCC_START_DATA_EN <= '1' WHEN (FIBER_IN_DATA_BUF1 = '1' AND FIBER_IN_DATA_BUF2 = '0') ELSE '0'; ---RISING EDGE DETECTION

	-------END OF DETECTING FALLING EDGE OF START SIGNAL FROM FIBER (START BIT FOR DATA)-----------

	------LEFT SHIFT REGISTER FOR DATA INPUT---------
	
	
	DATA_SHIFT_REG: SHIFT_REG
	GENERIC MAP(N => 40)
	PORT MAP(CLOCK 	=> CLOCK,
				RESET 	=> RESET,
				CLR 		=> CLR_SHIFT_REG,
				EN 		=> EN_SHIFT_REG,
				INP 		=> FIBER_IN_DATA_BUF2,
				OUTPUT 	=> FCC_DATA 
				);
	------END OF LEFT SHIFT REGISTER FOR DATA INPUT---------
	
	
	
	---------REGISTER FOR LATCHING 36 BITS OF INPUT DATA----------
	
	CRC_DATA_REG: REGNE
		GENERIC MAP(N => 40) 
		PORT MAP(CLOCK		=> CLOCK,	
					RESET		=> RESET,	
					CLEAR		=> ONE, 
					EN			=>	EN_CRC_DATA,
					INPUT		=>	FCC_DATA,
					OUTPUT	=> CRC_DATA_OUT
					);
					
	CRC_DATA <= CRC_DATA_OUT;
	
	
	------CLOCK COUNTER------------------------  counter updated to 5 bit, 3/23/21 JAL
	
	CLK_COUNTER: COUNTER
		GENERIC MAP(N => 5)
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,
					CLEAR  	=> CLR_CLK_COUNT,
					EN			=> EN_CLK_COUNT,
					COUNT		=> CLK_COUNT
					);
	------END OF CLOCK COUNTER------------------------
	
	------LOOP COUNTER------------------------
	
	LOOP_COUNTER: COUNTER
		GENERIC MAP(N => 6)
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,
					CLEAR  	=> CLR_LOOP_COUNT,
					EN			=> EN_LOOP_COUNT,
					COUNT		=> LOOP_COUNT
					);
	------END OF CLOCK COUNTER------------------------
	
	------LOOP WAIT COUNTER------------------------
	
	LOOP_WAIT_COUNTER: COUNTER
		GENERIC MAP(N => 6)
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,
					CLEAR  	=> CLR_CURRENT_COUNT,
					EN			=> EN_CURRENT_COUNT,
					COUNT		=> CURRENT_COUNT
					);
	------END OF CLOCK COUNTER------------------------
	
WAIT_COUNT <= '1' WHEN CURRENT_COUNT = LOOP_COUNT ELSE '0';
	
	------BIT COUNTER------------------------
	
	BIT_COUNTER: COUNTER
		GENERIC MAP(N => 6)
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,
					CLEAR  	=> CLR_BIT_COUNT,
					EN			=> EN_BIT_COUNT,
					COUNT		=> BIT_COUNT
					);
	------END OF BIT COUNTER------------------------
	

---------DISCRIMINATOR REGISTER-----------
	
	DISCRIMINATOR_REG: REGNE
		GENERIC MAP(N => 28) 
		PORT MAP(CLOCK		=> CLOCK,	
					RESET		=> RESET,	
					CLEAR		=> ONE, 
					EN			=>	EN_DISC,
					INPUT		=>	CRC_DATA_OUT(35 DOWNTO 8),
					OUTPUT	=> DISC
					);
					
					
--------------------SLOW BIT FOR LOWER ACCELERATION AND VELOCITY-------------------

	SLOW_DETA_FF: LATCH_N 
		PORT MAP(CLOCK	=> CLOCK, 
					RESET	=> RESET,
					CLEAR	=> ONE, 
					EN		=> EN_DETA,
					INP	=> CRC_DATA_OUT(27),
					OUP	=> SLOW_MODE
					);
					
					

	---------DETUNE ANGLE REGISTER-----------
	
	DETUNE_ANGLE_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,	
					RESET		=> RESET,	
					CLEAR		=> ONE, 
					EN			=>	EN_DETA,
					INPUT		=>	CRC_DATA_OUT(26 DOWNTO 11),
					OUTPUT	=> DETA
					);	
					
	---------PZT REGISTER-----------
	
	PZT_INFO_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,	
					RESET		=> RESET,	
					CLEAR		=> ONE, 
					EN			=>	EN_PZT,
					INPUT		=>	CRC_DATA_OUT(23 DOWNTO 8),
					OUTPUT	=> PZT
					);	

					
	---------MODE REGISTER-----------
	
	FCC_MODE_REG: REGNE
		GENERIC MAP(N => 3) 
		PORT MAP(CLOCK		=> CLOCK,	
					RESET		=> RESET,	
					CLEAR		=> ONE, 
					EN			=>	EN_DETA,
					INPUT		=>	CRC_DATA_OUT(10 DOWNTO 8),
					OUTPUT	=> FCC_MODE
					);
					

	TRACK_ON <= FCC_MODE(0);
	DETA_DISC <= FCC_MODE(2 DOWNTO 1);
					

					
					
					

	PROCESS(CLOCK, RESET)
	BEGIN
		
		IF(RESET = '0') THEN
			STATE <= INIT;
		ELSIF(CLOCK = '1' AND CLOCK' EVENT) THEN
	
			CASE STATE IS
			
				WHEN INIT				=> IF FCC_START_DATA_EN = '1' THEN STATE <= RCV_FIRST_BIT;
												ELSE STATE <= INIT;
												END IF;
												
												-- this is used to 'center' the input data so that we sample the incoming bit
												-- in the middle.
												-- for 80 Mhz clock, 8 ticks in (of 16 total) was the middle (was "0111")
												-- for 125 Mhz clock, 12 ticks in (of 25 total) is the new middle (now is "01100")
				WHEN RCV_FIRST_BIT	=> IF CLK_COUNT = "01100" THEN STATE <= RCV_DATA;
												ELSE STATE <= RCV_FIRST_BIT;
												END IF;
												
												-- *******************
												-- will need to change counter to be 24 downt to 0 (to work with 125 Mhz clock).
												-- will need to change 'center' from 8 to 11-12 (0 index) so that it is in the middle
												-- for 80 MHz clock we used: (BIT_COUNT = "100111" AND CLK_COUNT = "1111")
												-- CLK_COUNT is used to divide the 80M/16 = 5 MHz
												-- CLK_COUNT is changed so we can divide 125/25 = 5 MHz
												-- *********************
				WHEN RCV_DATA			=> IF (BIT_COUNT = "100111" AND CLK_COUNT = "11000") THEN STATE <= LOAD_CRC_DATA;
												ELSE STATE <= RCV_DATA;
												END IF;
												
				WHEN LOAD_CRC_DATA	=> STATE <= INIT_CRC;
												
				WHEN INIT_CRC			=> STATE <= WAIT_CRC;

				WHEN WAIT_CRC			=> IF (CRC_DONE = '1') THEN STATE <= CRC_CHECK;
												ELSE STATE <= WAIT_CRC;
												END IF;
																							
				WHEN CRC_CHECK			=> IF (CRC_IN /= "00000000") THEN
													IF(WAIT_COUNT = '1') THEN STATE <= INIT;
													ELSE STATE <= CRC_CHECK;
													END IF;
												ELSE STATE <= LOAD_DATA;
												END IF;
												
				WHEN LOAD_DATA			=> STATE <= INIT;
																								
			END CASE;
		
		END IF;
		
	END PROCESS;
	
	-- changes for switch from 80 Mhz clock to 125
	-- 'centering' clk count 	= 01100
	-- 'max clock count' 		= 11000
	
	EN_LOOP_COUNT		<= '1' WHEN (STATE = CRC_CHECK AND WAIT_COUNT = '1') ELSE '0';
	CLR_LOOP_COUNT 	<= '0' WHEN STATE = LOAD_DATA ELSE '1';
	
	EN_CURRENT_COUNT	<= '1' WHEN STATE = CRC_CHECK AND CLK_COUNT = "11000" ELSE '0';
	CLR_CURRENT_COUNT	<= '0' WHEN (STATE = CRC_CHECK AND WAIT_COUNT = '1') ELSE '1';
	
	
	EN_BIT_COUNT 	<= '1' WHEN (STATE = RCV_FIRST_BIT AND CLK_COUNT = "01100") OR (STATE = RCV_DATA AND CLK_COUNT = "11000") ELSE '0';
	CLR_BIT_COUNT 	<= '0' WHEN (BIT_COUNT = "100111" AND CLK_COUNT = "11000") ELSE '1';
	
	EN_CLK_COUNT 	<= '1' WHEN (STATE = RCV_FIRST_BIT) OR (STATE = RCV_DATA) OR (STATE = CRC_CHECK AND CRC_IN /= "00000000") ELSE '0';

	-- added (CLK_COUNT = "11000") to counter clear list so that the counter clears at this value on the next rising edge.
	-- previously, the counter was 4 bits so once it incremented past 1111 it would be 0000. Here, we are clearning once ever
	-- 25 ticks so we need to reset the counter at this point.
	CLR_CLK_COUNT 	<= '0' WHEN (STATE = RCV_FIRST_BIT AND CLK_COUNT = "01100") OR (STATE = CRC_CHECK AND WAIT_COUNT = '1') OR (STATE = INIT_CRC) OR (CLK_COUNT = "11000") ELSE '1';
	
	EN_SHIFT_REG	<= '1' WHEN (STATE = RCV_FIRST_BIT AND CLK_COUNT = "01100") OR (STATE = RCV_DATA AND CLK_COUNT = "11000") ELSE '0';
	CLR_SHIFT_REG	<= '0' WHEN (STATE = INIT_CRC) ELSE '1';
	
	START_CRC 		<= '1' WHEN (STATE = INIT_CRC) ELSE '0';
	
	EN_CRC_DATA		<= '1' WHEN (STATE = LOAD_CRC_DATA) ELSE '0';
	
	EN_DISC			<= '1' WHEN (STATE = LOAD_DATA AND CRC_DATA_OUT(39 DOWNTO 36) = "1001") ELSE '0';
	
	EN_DETA			<= '1' WHEN (STATE = LOAD_DATA AND CRC_DATA_OUT(39 DOWNTO 36) = "1000") ELSE '0';
	
	EN_PZT			<= '1' WHEN (STATE = LOAD_DATA AND CRC_DATA_OUT(39 DOWNTO 36) = "1010") ELSE '0';	
	
	
	
	
	
	
END ARCHITECTURE BEHAVIOR;