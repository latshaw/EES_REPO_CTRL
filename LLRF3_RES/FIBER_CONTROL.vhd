LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY FIBER_CONTROL IS

PORT(RESET 			: IN STD_LOGIC;
	  CLOCK 			: IN STD_LOGIC;
	  
	  TRACK_ON 		: IN STD_LOGIC;----this is not inhibit, tuner track_on bit----'0'-tracking disabled, '1'-tracking enabled
	  DETA_DISC 	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	  
	  
	  DETA 			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  DISC 			: IN STD_LOGIC_VECTOR(27 DOWNTO 0);
	  PZT				: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--	  DISC_MODE : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
	  FIB_MODE 		: IN STD_LOGIC;
	  
	  STEP_HZ 		: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	  
	  DONE_MOVE 	: IN STD_LOGIC;
	  
	  DISC_HI 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  DISC_LO 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  
	  DETA_HI 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  DETA_LO 		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  
	  PZT_HI			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  PZT_LO			: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  STOP			: IN STD_LOGIC;
	  
--	  DETA_HZ : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  
	  
	  
	  STEPS 			: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	  DIR 			: OUT STD_LOGIC;
	  MOVE 			: OUT STD_LOGIC;
	  DONE_ISA 		: OUT STD_LOGIC;
	  FIB_MODE_OUT : OUT STD_LOGIC
	  );
	  
END ENTITY FIBER_CONTROL;

ARCHITECTURE BEHAVIOR OF FIBER_CONTROL IS

SIGNAL EN_DETA				: STD_LOGIC;
SIGNAL DETUNE_ANGLE		: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL DETA_IN				: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL DETA_LO_REG		: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL DETA_HI_REG		: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL DISC_LO_REG		: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL DISC_HI_REG		: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL EN_DISC				: STD_LOGIC;
SIGNAL DISCRIMINATOR		: STD_LOGIC_VECTOR(27 DOWNTO 0);
SIGNAL DISC_IN				: STD_LOGIC_VECTOR(27 DOWNTO 0);

SIGNAL PZT_LO_REG			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL PZT_HI_REG			: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL PZT_IN				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL PZT_V				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL EN_PZT				: STD_LOGIC;

SIGNAL DIR_IN				: STD_LOGIC;

SIGNAL EN_STEPS			: STD_LOGIC;
SIGNAL EN_DIR				: STD_LOGIC;





TYPE STATE_TYPE IS (INIT, DETA_LD1, DETA_HI_CHK, INIT_TRACK, INIT_MOVE, DONE_WAIT, DETA_NEW, DETA_LD2, DETA_LO_CHK);
SIGNAL STATE				: STATE_TYPE;

TYPE STATE1_TYPE IS (DISC_INIT, DISC_LD1, DISC_HI_CHK, DISC_TRACK, DISC_MOVE, DONE_WAIT1, DISC_NEW, DISC_LD2, DISC_LO_CHK);
SIGNAL STATE1				: STATE1_TYPE;

TYPE STATE2_TYPE IS (PZT_INIT, PZT_LD1, PZT_HI_CHK, PZT_TRACK, PZT_MOVE, DONE_WAIT2, PZT_NEW, PZT_LD2, PZT_LO_CHK);
SIGNAL STATE2				: STATE2_TYPE;

BEGIN

DONE_ISA 	<= '0';

DETA_IN 		<= (NOT DETA) WHEN DETA(15) = '1' ELSE DETA;
DISC_IN 		<= (NOT DISC) WHEN DISC(27) = '1' ELSE DISC;
PZT_IN		<= (NOT PZT) WHEN PZT(15) = '1' ELSE PZT;


--------REGISTERING DETA HIGH AND LOW VALUES FOR GDR CONTROL----------------

DETUNE_ANGLE_HI_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_DETA,	
					INPUT		=>	DETA_HI,
					OUTPUT	=> DETA_HI_REG
					);
					
DETUNE_ANGLE_LO_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_DETA,	
					INPUT		=>	DETA_LO,
					OUTPUT	=> DETA_LO_REG
					);
					
					
					
--------REGISTERING DETA HIGH AND LOW VALUES FOR GDR CONTROL----------------

DISCRIMINATOR_HI_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_DISC,	
					INPUT		=>	DISC_HI,
					OUTPUT	=> DISC_HI_REG
					);
					
DISCRIMINATOR_LO_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_DISC,	
					INPUT		=>	DISC_LO,
					OUTPUT	=> DISC_LO_REG
					);

					
-------REGISTERING PZT HIGH AND LOW VALUES FOR PZT CONTROL----------------

PZTCTRL_HI_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_PZT,	
					INPUT		=>	PZT_HI,
					OUTPUT	=> PZT_HI_REG
					);
					
PZTCTRL_LO_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_PZT,	
					INPUT		=>	PZT_LO,
					OUTPUT	=> PZT_LO_REG
					);




-----------------------------detune angle and direction register--------------------------


DETUNE_ANGLE_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_DETA,	
					INPUT		=>	DETA_IN,
					OUTPUT	=> DETUNE_ANGLE
					);
					
					
					
-------------------DISC REGISTER --------------------



DISCRIMINATOR_REG: REGNE
		GENERIC MAP(N => 28) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_DISC,	
					INPUT		=>	DISC_IN,
					OUTPUT	=> DISCRIMINATOR
					);


-------------------PZT REGISTER --------------------



PZT_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_PZT,	
					INPUT		=>	PZT_IN,
					OUTPUT	=> PZT_V
					);										

					

--DETUNE_ANGLE_ACC: REGNE
--		GENERIC MAP(N => 16) 
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,	
--					CLEAR		=> '1',
--					EN			=>	EN_DETA_ACC,	
--					INPUT		=>	DETA_ACC_IN,
--					OUTPUT	=> DETA_ACC
--					);					
					
--DETA_ACC_IN <= DETA_ACC - X"016C" WHEN SEL_DETA_ACC = '0' ELSE DETUNE_ANGLE;

--DETA_ACC_IN <= DETA_ACC - DETA_SUB WHEN SEL_DETA_ACC = '0' ELSE DETUNE_ANGLE;


--DETA_SUB <= DETA_HZ WHEN DETA_DISC = '0' ELSE x"0001";

--DISC_SUB <= X"0001" WHEN DISC_MODE = "11" ELSE
--				X"0001" WHEN DISC_MODE = "10" ELSE
--				X"001A" WHEN DISC_MODE = "01" ELSE
--				X"0106";
					
					
DIR_IN <= DETA(15) WHEN DETA_DISC = "00" ELSE
			 DISC(27) WHEN DETA_DISC = "01" ELSE
			 PZT(15)  WHEN DETA_DISC = "10" ELSE
			 '0';					
					
DIR_FF: LATCH_N
	PORT MAP(CLOCK => CLOCK,
				RESET => RESET,
				CLEAR => '1',
				EN => EN_DIR,
				INP => DIR_IN,
				OUP => DIR
				);
				
STEPS_HZ_REG: REGNE
		GENERIC MAP(N => 32) 
		PORT MAP(CLOCK		=> CLOCK,
					RESET		=> RESET,	
					CLEAR		=> '1',
					EN			=>	EN_STEPS,	
					INPUT		=>	STEP_HZ,
					OUTPUT	=> STEPS
					);
					

					

			
------------------------PROCESS CONTROL FOR GDR---------------------------------	

	PROCESS(CLOCK, RESET, DETA_DISC, TRACK_ON, FIB_MODE, STOP)
		BEGIN
			IF (RESET = '0' OR DETA_DISC /= "00" OR FIB_MODE = '0' OR TRACK_ON = '0' OR STOP = '1') THEN
				STATE <= INIT;
			ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
				
				CASE STATE IS
				
					WHEN INIT 				=> IF DETUNE_ANGLE = DETA_IN THEN STATE <= INIT;
													ELSE STATE <= DETA_LD1;
													END IF;
																															
					WHEN DETA_LD1 			=> STATE <= DETA_HI_CHK;
					
					WHEN DETA_HI_CHK		=> IF DETUNE_ANGLE > DETA_HI_REG THEN STATE <= INIT_TRACK;
													ELSE STATE <= INIT;
													END IF;
													
					WHEN INIT_TRACK		=> STATE <= INIT_MOVE;
					
					WHEN INIT_MOVE			=> STATE <= DONE_WAIT;
					
					WHEN DONE_WAIT			=> IF DONE_MOVE = '1' THEN STATE <= DETA_NEW;
													ELSE STATE <= DONE_WAIT;
													END IF;
													
					WHEN DETA_NEW			=> IF DETUNE_ANGLE = DETA_IN THEN STATE <= DETA_NEW;
													ELSE STATE <= DETA_LD2;
													END IF;
													
					WHEN DETA_LD2			=> STATE <= DETA_LO_CHK;
													
					WHEN DETA_LO_CHK		=> IF DETUNE_ANGLE < DETA_LO_REG THEN STATE <= INIT;
													ELSE STATE <= INIT_TRACK;
													END IF;
													
					WHEN OTHERS				=> STATE <= INIT;								
																												
				END CASE;
			END IF;
		END PROCESS;
		
---------------------------END OF PROCESS FOR GDR------------------------------------------

					
EN_DETA 	<= '1' WHEN STATE = DETA_LD1 OR STATE = DETA_LD2 ELSE '0';

EN_DISC 	<= '1' WHEN STATE1 = DISC_LD1 OR STATE1 = DISC_LD2 ELSE '0';

EN_PZT 	<= '1' WHEN STATE2 = PZT_LD1 OR STATE2 = PZT_LD2 ELSE '0';

MOVE <= '1' WHEN STATE = INIT_TRACK OR STATE = INIT_MOVE OR STATE1 = DISC_TRACK OR STATE1 = DISC_MOVE OR STATE2 = PZT_TRACK OR STATE2 = PZT_MOVE ELSE '0';

EN_DIR <= '1' WHEN STATE1 = DISC_LD1 OR STATE1 = DISC_LD2 OR STATE = DETA_LD1 OR STATE = DETA_LD2 OR STATE2 = PZT_LD1 OR STATE2 = PZT_LD2 ELSE '0';

EN_STEPS <= '1' WHEN STATE1 = DISC_LD1 OR STATE1 = DISC_LD2 OR STATE = DETA_LD1 OR STATE = DETA_LD2 OR STATE2 = PZT_LD1 OR STATE2 = PZT_LD2 ELSE '0';

FIB_MODE_OUT <= FIB_MODE ;



------------------------PROCESS CONTROL FOR SEL---------------------------------	

	PROCESS(CLOCK, RESET, DETA_DISC, TRACK_ON, FIB_MODE, STOP)
		BEGIN
			IF (RESET = '0' OR DETA_DISC /= "01" OR FIB_MODE = '0' OR TRACK_ON = '0' OR STOP = '1') THEN
				STATE1 <= DISC_INIT;
			ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
				
				CASE STATE1 IS
				
					WHEN DISC_INIT				=> IF DISCRIMINATOR = DISC_IN THEN STATE1 <= DISC_INIT;
														ELSE STATE1 <= DISC_LD1;
														END IF;
					
					WHEN DISC_LD1				=> STATE1 <= DISC_HI_CHK;
					
					WHEN DISC_HI_CHK			=> IF DISCRIMINATOR > (x"000" & DISC_HI_REG) THEN STATE1 <= DISC_TRACK;
														ELSE STATE1 <= DISC_INIT;
														END IF;
												
					WHEN DISC_TRACK			=> STATE1 <= DISC_MOVE;
					
					WHEN DISC_MOVE				=> STATE1 <= DONE_WAIT1;
					
					WHEN DONE_WAIT1			=> IF DONE_MOVE = '1' THEN STATE1 <= DISC_NEW;
														ELSE STATE1 <= DONE_WAIT1;
														END IF;
														
					WHEN DISC_NEW				=> IF DISCRIMINATOR = DISC_IN THEN STATE1 <= DISC_NEW;
														ELSE STATE1 <= DISC_LD2;
														END IF;
														
					WHEN DISC_LD2				=> STATE1 <= DISC_LO_CHK;
					
					WHEN DISC_LO_CHK			=> IF DISCRIMINATOR < (x"000" & DISC_LO_REG) THEN STATE1 <= DISC_INIT;
														ELSE STATE1 <= DISC_TRACK;
														END IF;
														
					WHEN OTHERS					=> STATE1 <= DISC_INIT;
													
				END CASE;
			END IF;
		END PROCESS;
		

		
---------------------------END OF PROCESS FOR SEL------------------------------------------


------------------------PROCESS CONTROL FOR PZT---------------------------------	

	PROCESS(CLOCK, RESET, DETA_DISC, TRACK_ON, FIB_MODE, STOP)
		BEGIN
			IF (RESET = '0' OR DETA_DISC /= "10" OR FIB_MODE = '0' OR TRACK_ON = '0' OR STOP = '1') THEN
				STATE2 <= PZT_INIT;
			ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
				
				CASE STATE2 IS
				
					WHEN PZT_INIT				=> IF PZT_V = PZT_IN THEN STATE2 <= PZT_INIT;
														ELSE STATE2 <= PZT_LD1;
														END IF;
					
					WHEN PZT_LD1				=> STATE2 <= PZT_HI_CHK;
					
					WHEN PZT_HI_CHK			=> IF PZT_V > PZT_HI_REG THEN STATE2 <= PZT_TRACK;
														ELSE STATE2 <= PZT_INIT;
														END IF;
												
					WHEN PZT_TRACK				=> STATE2 <= PZT_MOVE;
					
					WHEN PZT_MOVE				=> STATE2 <= DONE_WAIT2;
					
					WHEN DONE_WAIT2			=> IF DONE_MOVE = '1' THEN STATE2 <= PZT_NEW;
														ELSE STATE2 <= DONE_WAIT2;
														END IF;
														
					WHEN PZT_NEW				=> IF (PZT_V = PZT_IN AND PZT_V /= X"7FFF") THEN STATE2 <= PZT_NEW;
														ELSE STATE2 <= PZT_LD2;
														END IF;
														
					WHEN PZT_LD2				=> STATE2 <= PZT_LO_CHK;
					
					WHEN PZT_LO_CHK			=> IF PZT_V < PZT_LO_REG THEN STATE2 <= PZT_INIT;
														ELSE STATE2 <= PZT_TRACK;
														END IF;
														
					WHEN OTHERS					=> STATE2 <= PZT_INIT;
													
				END CASE;
			END IF;
		END PROCESS;
		

		
---------------------------END OF PROCESS FOR PZT------------------------------------------




END ARCHITECTURE BEHAVIOR;
	  
	  