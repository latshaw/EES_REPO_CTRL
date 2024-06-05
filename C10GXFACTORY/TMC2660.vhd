--
--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {TMC2660} architecture {behavior}}

--11/4/2020, changed the definition of DRVI_CONFIG to match the input low current command
--
-- 1/10/22, looking into this module futher and the requirments for the TMC chip
-- I believe that the intial counters for this module are very conservative and we
-- should be able to drive this module with a 125 Mhz to 50 Mhz clocks and stay
-- within the timing requirements imposed by the TMC stepper dirver chip.
--
--10/18/22, changed to make DRVCTRL and specifically the microsteps to be dynamicaly changeable.


-- 1/23/23, CHOPCONG and MRES restored to hard coded values for deployment. register maps remain in the
-- event that future debugging is needed.
--
-- 5/28/2024, more effort on looking into optimizing chopper settings
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE WORK.COMPONENTS.ALL;

ENTITY TMC2660 IS
PORT(CLOCK : IN STD_LOGIC;
	 RESET : IN STD_LOGIC;
	 CHOPCONF_IN : IN STD_LOGIC_VECTOR(15 downto 0); -- chopper control
	 MRES : IN STD_LOGIC_VECTOR(3 downto 0); -- specify microstep resolution
	 DRVI : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- specify current scale
	 DRVI_CONFIG : IN STD_LOGIC;			 -- 0 = use DRVI as specified current scale, 1 = set current scale to lowest (0000)
	 START_CONFIG : IN STD_LOGIC; -- set HI to start state machine
	 SDO : IN STD_LOGIC;		  -- SDO is (not used?)
	 INHIBIT : IN STD_LOGIC;      -- directly connected to ouput SEN (not used?)
	 CSN : OUT STD_LOGIC;
	 SCK : OUT STD_LOGIC;
	 SDI : OUT STD_LOGIC;
	 SEN : OUT STD_LOGIC;	 -- loop back INHIBIT 
	 CONFIG_DONE : OUT STD_LOGIC
	 
	 );
	 
	 
END TMC2660;

--}} End of automatically maintained section

ARCHITECTURE BEHAVIOR OF TMC2660 IS

--CONSTANT CHOPCONF			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"901b4";
--CONSTANT SGCSCONF			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"d001f";
--CONSTANT DRVCONF 			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"ef010";
--CONSTANT DRVCTRL 			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"00000";
--CONSTANT SMARTEN 			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"a8202";
--
--CONSTANT SHCSCONF 			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"c140f";

--CONSTANT CHOPCONF			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"90135"; -- baseline spreadCycle
------------------------- best so far CONSTANT CHOPCONF			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"92135"; -- baseline spreadCycle WITH random off time
--CONSTANT SGCSCONF			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"d050f";
SIGNAL SGCSCONF				: STD_LOGIC_VECTOR(19 DOWNTO 0);
CONSTANT DRVCONF			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"ef060";
--CONSTANT DRVCTRL			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"00000";
SIGNAL DRVCTRL			: STD_LOGIC_VECTOR(19 DOWNTO 0); -- micro steps are desired to be dynamic for debugging.
CONSTANT SMARTEN			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"a0000";
CONSTANT SHCSCONF 			: STD_LOGIC_VECTOR(19 DOWNTO 0) := x"c140f";


SIGNAL CHOPCONF				: STD_LOGIC_VECTOR(19 downto 0);
SIGNAL EN_SHIFT_REG			: STD_LOGIC;
SIGNAL LD_SHIFT_REG			: STD_LOGIC;
SIGNAL INP_SHIFT_REG			: STD_LOGIC_VECTOR(19 DOWNTO 0);

SIGNAL CLR_DATA_COUNT			: STD_LOGIC;
SIGNAL EN_DATA_COUNT			: STD_LOGIC;
SIGNAL DATA_COUNT			: STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL EN_SCLK_COUNT			: STD_LOGIC;
SIGNAL SCLK_COUNT			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL CLR_SHIFT_DATA_COUNT		: STD_LOGIC;
SIGNAL EN_SHIFT_DATA_COUNT		: STD_LOGIC;
SIGNAL SHIFT_DATA_COUNT			: STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL EN_CS_WAIT_COUNT			: STD_LOGIC;
SIGNAL CS_WAIT_COUNT			: STD_LOGIC_VECTOR(9 DOWNTO 0);

SIGNAL EN_DRVI				: STD_LOGIC;
SIGNAL DRVI_BUF				: STD_LOGIC_VECTOR(4 DOWNTO 0);
SIGNAL DRVI_MUX				: STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL START_CONFIG_BUF0		: STD_LOGIC;
SIGNAL START_CONFIG_BUF1		: STD_LOGIC;
SIGNAL START_VALID			: STD_LOGIC;

TYPE STATE_TYPE IS (INIT, DRVI_LOAD, DATA_LOAD, CSN_LOW, CSN_WAIT, SCLK_HIGH, SCLK_LOW, DATA_CHECK, DATA_LD_DONE);
SIGNAL STATE					: STATE_TYPE;

BEGIN
-- MOSFETS are disabled when Enable pin is pulled hi
--		SEN LOW to enable stepper driver
--		SEN HI to disable stepper driver
SEN <= INHIBIT;	
	
	START_BUF0: FLIP_FLOP
	PORT MAP(CLOCK 	=> CLOCK,
		  	 RESET 	=> RESET,
		  	 CLEAR  => '1',
		  	 EN 	=> '1',
		  	 INP 	=> START_CONFIG,
		  	 OUP 	=> START_CONFIG_BUF0
		  	 );
			   
	START_BUF1: FLIP_FLOP
	PORT MAP(CLOCK 	=> CLOCK,
		  	 RESET 	=> RESET,
		  	 CLEAR  => '1',
		  	 EN 	=> '1',
		  	 INP 	=> START_CONFIG_BUF0,
		  	 OUP 	=> START_CONFIG_BUF1
		  	 );		
			 
	-- look for rising edge to start the state  machine
	START_VALID <= START_CONFIG_BUF0 AND (NOT START_CONFIG_BUF1); 
			   
	SHIFT_REG_DATA: SHIFT_LEFT_REG -- changed from old SHIFT_REG module on 7/7/2020
	GENERIC MAP(N => 20)
	PORT MAP(CLOCK 	=> CLOCK,
		 	 RESET	=> RESET,
		 	 EN		=> EN_SHIFT_REG,
			 CLEAR   => '1', -- never clear
		 	 LOAD	=> LD_SHIFT_REG,
		 	 INP	=> INP_SHIFT_REG,
		 	 OUTPUT	=> SDI
		 	 );
			  
	DRVI_REG: REGNE
		GENERIC MAP(N => 5) 
		PORT MAP(CLOCK 	=> CLOCK,
			  	 RESET 	=> RESET,
			  	 CLEAR  => '1',
			  	 EN		=> EN_DRVI,
			  	 INPUT	=> DRVI,
			  	 OUTPUT => DRVI_BUF
				 );

	-- 11/4/2020, changed from below. low current is the input signal to DRVI_CONFIG
	--DRVI_MUX <= DRVI_BUF WHEN DRVI_CONFIG = '1' ELSE "00000";	
	DRVI_MUX <= DRVI_BUF WHEN DRVI_CONFIG = '0' ELSE "00010"; -- 2/16/23, adjusted so that minimum hold current is not fall below motors minimum needed coil current.	
	SGCSCONF <= X"d05" & "000" & DRVI_MUX;			  
	--10/18/22, lower 4 bits determine microstep. 0000=256 microsteps, 1000=full step.
	DRVCTRL <= x"0000" & MRES;
	-- 1/23/23, after debuging, hard coding to 16 micro steps per full step
	--1/25/223, 64 micro step per full step to give us more torque.
	--DRVCTRL <= x"0000" & x"2";
	-- 10/28/22, changed CHOPCONF to be dynamicaly changed
	--CHOPCONF <= "1000" & CHOPCONF_IN;
	-- 1/23/23, after debuging, hard coding chopper configuration to constant off mode.
	--CHOPCONF <= "1000" & x"5004";
	-- 2/13/23, playing with just blanking time
	--CHOPCONF <= "100" & CHOPCONF(1 downto 0) & "000" & x"1b4"; -- x"901b4" in orginal code it was this
	CHOPCONF <= "1000" & CHOPCONF_IN(15 downto 0); -- x"901b4" in orginal code it was this
	
	WITH DATA_COUNT SELECT
	INP_SHIFT_REG <= CHOPCONF WHEN "000",
					 SGCSCONF WHEN "001",
					 DRVCONF WHEN "010",
					 DRVCTRL WHEN "011",
					 SMARTEN WHEN "100",
					 x"00000" WHEN OTHERS;
					 
	DATA_COUNTER: COUNTER
		GENERIC MAP(N => 3)
		PORT MAP(CLOCK		=> CLOCK,
			  	 RESET		=> RESET,
			  	 CLEAR		=> CLR_DATA_COUNT,
			  	 en		=> EN_DATA_COUNT,
			  	 COUNT		=> DATA_COUNT
			 	 );
				  
						 
	CS_HIGH_WAIT_COUNTER: COUNTER
		GENERIC MAP(N => 10)
		PORT MAP(CLOCK		=> CLOCK,
			  	 RESET		=> RESET,
			  	 CLEAR		=> '1',
			  	 en		=> EN_CS_WAIT_COUNT,
			  	 COUNT		=> CS_WAIT_COUNT
			 	 );
				  
	SCLK_COUNTER: COUNTER
		GENERIC MAP(N => 8)
		PORT MAP(CLOCK		=> CLOCK,
			  	 RESET		=> RESET,
			  	 CLEAR		=> '1',
			  	 en		=> EN_SCLK_COUNT,
			  	 COUNT		=> SCLK_COUNT
			 	 );
				  
	SHIFT_DATA_COUNTER: COUNTER
		GENERIC MAP(N => 5)
		PORT MAP(CLOCK		=> CLOCK,
			  	 RESET		=> RESET,
			  	 CLEAR		=> CLR_SHIFT_DATA_COUNT,
			  	 en		=> EN_SHIFT_DATA_COUNT,
			  	 COUNT		=> SHIFT_DATA_COUNT
			 	 );
				  
				  
	PROCESS(CLOCK, RESET)
	BEGIN
		IF RESET = '0' THEN
			STATE <= INIT;
		ELSIF (CLOCK = '1' AND CLOCK' EVENT) THEN 
			CASE STATE IS
				
				WHEN INIT			=> IF START_VALID = '1' THEN STATE <= DRVI_LOAD;
									   ELSE STATE <= INIT;
									   END IF;
				
				--WHEN DATA_LOAD		=> IF CS_WAIT_COUNT = "11" THEN STATE <= CSN_LOW;
--								       ELSE STATE <= DATA_LOAD;
--									   END IF;
				WHEN DRVI_LOAD		=> STATE <= DATA_LOAD;

				WHEN DATA_LOAD		=> STATE <= CSN_LOW;
										   
				WHEN CSN_LOW		=> STATE <= CSN_WAIT;
				
				WHEN CSN_WAIT		=> STATE <= SCLK_LOW;
				
				WHEN SCLK_LOW		=> 	IF SCLK_COUNT = "01111111" THEN STATE <= SCLK_HIGH;											
										ELSE STATE <= SCLK_LOW;
										END IF;
											
				WHEN SCLK_HIGH		=> 	IF SCLK_COUNT = "11111111" THEN STATE <= SCLK_LOW;
											IF SHIFT_DATA_COUNT = "10011" THEN STATE <= DATA_CHECK;
											ELSE STATE <= SCLK_LOW;
											END IF;
								   		ELSE STATE <= SCLK_HIGH;
								   		END IF;			
									
				WHEN DATA_CHECK		=> 	IF 	CS_WAIT_COUNT = "1111111111" THEN 
											IF DATA_COUNT = "100" THEN STATE <= DATA_LD_DONE;
								   			ELSE STATE <= DATA_LOAD;
								   			END IF;
										ELSE STATE <= DATA_CHECK;
										END IF;	
								   
				WHEN DATA_LD_DONE	=> STATE <= INIT;
				
			END CASE;
		END IF;
	END PROCESS;
	
	
	EN_CS_WAIT_COUNT		<= '1' WHEN STATE = DATA_CHECK ELSE '0';
	EN_DATA_COUNT			<= '1' WHEN STATE = DATA_CHECK AND CS_WAIT_COUNT = "1111111111" ELSE '0';
	CLR_DATA_COUNT			<= '0' WHEN STATE = DATA_LD_DONE ELSE '1';	
	EN_SCLK_COUNT			<= '1' WHEN STATE = SCLK_HIGH OR STATE = SCLK_LOW ELSE '0';
	EN_SHIFT_DATA_COUNT		<= '1' WHEN STATE = SCLK_HIGH AND SCLK_COUNT = "11111111" ELSE '0';
	CLR_SHIFT_DATA_COUNT	<= '0' WHEN STATE = DATA_CHECK ELSE '1';
	LD_SHIFT_REG			<= '1' WHEN STATE = DATA_LOAD ELSE '0';
	EN_SHIFT_REG			<= '1' WHEN STATE = SCLK_HIGH AND SCLK_COUNT = "11111111" ELSE '0';
	SCK						<= '0' WHEN STATE = SCLK_LOW ELSE '1';

	CSN						<= '0' WHEN STATE = CSN_LOW OR STATE = CSN_WAIT OR STATE = SCLK_HIGH OR STATE = SCLK_LOW ELSE '1';
	CONFIG_DONE				<= '1' WHEN ((STATE = DATA_LD_DONE) OR (STATE = INIT)) ELSE '0'; -- 4/3/23, changed configuration done to be hi when done or in init state
	EN_DRVI					<= '1' WHEN STATE = DRVI_LOAD ELSE '0';	
		
									   
END BEHAVIOR;
