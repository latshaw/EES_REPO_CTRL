LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY DAC8568_CONTROL IS

PORT(CLOCK : IN STD_LOGIC;
	 RESET : IN STD_LOGIC;
	 DATA : IN REG16_ARRAY;
	 
	 
	 SCLK : OUT STD_LOGIC;
	 DIN : OUT STD_LOGIC;
	 SYNC : OUT STD_LOGIC
	 
	 
	 );
END ENTITY DAC8568_CONTROL;

ARCHITECTURE BEHAVIOR OF DAC8568_CONTROL IS


----data stream for enabling internal reference
--0xxx_1001_xxxx_110x_xxxx_xxxx_xxxx_xxxx
SIGNAL DAC_DATA_BUF : REG16_ARRAY;

signal data1 : std_logic_vector(31 downto 0);
signal data2 : std_logic_vector(31 downto 0);
signal data3 : std_logic_vector(31 downto 0);
signal data4 : std_logic_vector(31 downto 0);
signal data5 : std_logic_vector(31 downto 0);
signal data6 : std_logic_vector(31 downto 0);
signal data7 : std_logic_vector(31 downto 0);
signal data8 : std_logic_vector(31 downto 0);

signal REF_EN : std_logic_vector(31 downto 0);

SIGNAL LOAD_DAC_REG : STD_LOGIC;
SIGNAL DAC_REG_EN : STD_LOGIC;
SIGNAL DAC_REG_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL EN_DAC_DATA : STD_LOGIC;
SIGNAL DAC_DATA : STD_LOGIC;
SIGNAL DATA_IN : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL DATA_IN_LOAD	:	STD_LOGIC;

SIGNAL EN_DAC_CNT : STD_LOGIC;
SIGNAL DAC_CNT : STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL EN_SCLK_CNT : STD_LOGIC;
SIGNAL CLR_SCLK_CNT : STD_LOGIC;
SIGNAL SCLK_CNT : STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL EN_SYNC_CNT : STD_LOGIC;
SIGNAL SYNC_CNT : STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL EN_SCLK_DIV_CNT	: STD_LOGIC;
SIGNAL CLR_SCLK_DIV_CNT	: STD_LOGIC;
SIGNAL SCLK_DIV_CNT		: STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL ONE	: STD_LOGIC;

TYPE STATE_TYPE IS (INIT, REF_ENABLE, SCLK_REF_HIGH, SCLK_REF_LOW, DATA_INIT_LOAD, DATA_INIT, DATA_LOAD, SCLK_DATA_HIGH, SCLK_DATA_LOW, TWAIT, DATA_NEW_WAIT);
SIGNAL STATE : STATE_TYPE;



BEGIN

ONE <= '1';

REF_EN <= "00001001000010100000000000000000";

--data1 <= "00000000000011111111111111110000";
--data2 <= "00000000000111100110011001010000";
--data3 <= "00000000001011001100110011000000";
--data4 <= "00000000001110110011001100100000";
--data5 <= "00000000010010011001100110010000";
--data6 <= "00000000010101111111111111110000";
--data7 <= "00000000011001100110011001100000";
--data8 <= "00000000011100110011001100110000";

DAC_DATA_REG_GEN_I: FOR I IN 0 TO 7 GENERATE
	DAC_DATA_REGI: REGNE
			GENERIC MAP(N => 16) 
			PORT MAP(CLOCK		=> CLOCK,
						RESET		=> RESET,
						CLEAR		=> '1',
						EN			=>	DATA_IN_LOAD,
						INPUT		=> DATA(I),
						OUTPUT	=> DAC_DATA_BUF(I)
						);
END GENERATE;

DAC_DATA_LATCH: latch_n
	port MAP(clock => CLOCK,
			 reset => RESET,
			 clear => ONE,
			 en    => EN_DAC_DATA,
			 inp   => ONE,	
			 oup   => DAC_DATA	
			);

SCLK_CNTR: counter
		generic map(n => 5)
		port map(clock	=> CLOCK,
				 reset	=> RESET,
				 clear	=> CLR_SCLK_CNT,
				 enable => EN_SCLK_CNT,
				 count  => SCLK_CNT
				);
				
SYNC_CNTR: counter
		generic map(n => 4)
		port map(clock	=> CLOCK,
				 reset	=> RESET,
				 clear	=> ONE,
				 enable => EN_SYNC_CNT,
				 count  => SYNC_CNT
				);
				
SCLK_DIV_CNTR: counter
		generic map(n => 4)
		port map(clock	=> CLOCK,
				 reset	=> RESET,
				 clear	=> CLR_SCLK_DIV_CNT,
				 enable => EN_SCLK_DIV_CNT,
				 count  => SCLK_DIV_CNT
				);


DAC_ADDR_CNTR: counter
		generic map(n => 3)
		port map(clock	=> CLOCK,
				 reset	=> RESET,
				 clear	=> ONE,
				 enable => EN_DAC_CNT,
				 count  => DAC_CNT
				);


DAC_REG_IN <= DATA_IN WHEN DAC_DATA = '1' ELSE REF_EN;

DATA_IN <= "000000000000" & DAC_DATA_BUF(7) & "0000" WHEN DAC_CNT = "000" ELSE
		   "000000000001" & DAC_DATA_BUF(0) & "0000" WHEN DAC_CNT = "001" ELSE
		   "000000000010" & DAC_DATA_BUF(6) & "0000" WHEN DAC_CNT = "010" ELSE
		   "000000000011" & DAC_DATA_BUF(2) & "0000" WHEN DAC_CNT = "011" ELSE
		   "000000000100" & DAC_DATA_BUF(5) & "0000" WHEN DAC_CNT = "100" ELSE
		   "000000000101" & DAC_DATA_BUF(1) & "0000" WHEN DAC_CNT = "101" ELSE		   
		   "000000000110" & DAC_DATA_BUF(4) & "0000" WHEN DAC_CNT = "110" ELSE
		   "000000000111" & DAC_DATA_BUF(3) & "0000" WHEN DAC_CNT = "111" ELSE		   
		   
		   (OTHERS => '0');
		   
DAC_DATA_IN_REG: SHIFT_REG 
	GENERIC MAP(N => 32)
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 EN		=> DAC_REG_EN,
			 LOAD	=> LOAD_DAC_REG,
			 INP	=> DAC_REG_IN,
			 OUTPUT => DIN
			);
			
			
	PROCESS(CLOCK, RESET)
	BEGIN
	
		IF (RESET = '0') THEN
			STATE <= INIT;
		ELSIF (CLOCK = '1' AND CLOCK'EVENT) THEN

			CASE STATE IS

				WHEN INIT => STATE <= REF_ENABLE;
												
				WHEN REF_ENABLE => STATE <= SCLK_REF_HIGH;
				
				WHEN SCLK_REF_HIGH => IF SCLK_DIV_CNT = "0111" THEN STATE <= SCLK_REF_LOW;
											 ELSE STATE <= SCLK_REF_HIGH;
											 END IF;
				
				WHEN SCLK_REF_LOW => IF SCLK_DIV_CNT = "1111" THEN 
												IF SCLK_CNT = "11111" THEN STATE <= DATA_INIT_LOAD; 
												ELSE STATE <= SCLK_REF_HIGH;
												END IF;
											ELSE STATE <= SCLK_REF_LOW;
											END IF;
				WHEN DATA_INIT_LOAD	=>	STATE	<=	DATA_INIT;							
				
				WHEN DATA_INIT => IF(SYNC_CNT = "1111") THEN STATE <= DATA_LOAD;
								  ELSE STATE <= DATA_INIT;
								  END IF;
								  
				WHEN DATA_LOAD => STATE <= SCLK_DATA_HIGH;
								  
				WHEN SCLK_DATA_HIGH => IF SCLK_DIV_CNT = "0111" THEN STATE <= SCLK_DATA_LOW;
											  ELSE STATE <= SCLK_DATA_HIGH;
											  END IF;
				
				WHEN SCLK_DATA_LOW => IF SCLK_DIV_CNT = "1111" THEN 
												IF(SCLK_CNT = "11111") THEN STATE <= TWAIT;
												ELSE STATE <= SCLK_DATA_HIGH;
												END IF;
											 ELSE STATE <= SCLK_DATA_LOW;
											 END IF; 
									  
				WHEN TWAIT => IF DAC_CNT = "111" THEN STATE <= DATA_NEW_WAIT;
									ELSE STATE <= DATA_INIT;
									END IF;
									
				WHEN DATA_NEW_WAIT	=> IF DAC_DATA_BUF = DATA THEN STATE <= DATA_NEW_WAIT;
												ELSE STATE <= DATA_INIT_LOAD;
												END IF;
				
			END CASE;
		END IF;
	END PROCESS;
				
SYNC <= '0' WHEN STATE = REF_ENABLE OR STATE = SCLK_REF_HIGH OR STATE = SCLK_REF_LOW OR STATE = DATA_LOAD OR
			STATE = SCLK_DATA_HIGH OR STATE = SCLK_DATA_LOW OR STATE = TWAIT ELSE '1';

SCLK <= '0' WHEN STATE = SCLK_REF_LOW OR STATE = SCLK_DATA_LOW ELSE '1';

DAC_REG_EN <= '1' WHEN (STATE = SCLK_DATA_LOW AND SCLK_DIV_CNT = "1011") OR (STATE = SCLK_REF_LOW AND SCLK_DIV_CNT = "1011") ELSE '0';

EN_SYNC_CNT <= '1' WHEN (STATE = DATA_INIT) ELSE '0';

EN_SCLK_CNT <= '1' WHEN (STATE = SCLK_REF_LOW AND SCLK_DIV_CNT = "1111") OR (STATE = SCLK_DATA_LOW AND SCLK_DIV_CNT = "1111") ELSE '0';
CLR_SCLK_CNT	<= '0' WHEN STATE = DATA_LOAD ELSE '1';

EN_SCLK_DIV_CNT <= '1' WHEN STATE = SCLK_REF_LOW OR STATE = SCLK_REF_HIGH OR STATE = SCLK_DATA_HIGH OR STATE = SCLK_DATA_LOW ELSE '0';
CLR_SCLK_DIV_CNT	<= '0' WHEN STATE = DATA_LOAD ELSE '1';

								
EN_DAC_CNT <= '1' WHEN STATE = TWAIT ELSE '0';

LOAD_DAC_REG <= '1' WHEN STATE = REF_ENABLE OR STATE = DATA_LOAD ELSE '0';

EN_DAC_DATA <= '1' WHEN (STATE = SCLK_REF_LOW AND SCLK_CNT = "11111") ELSE '0';

DATA_IN_LOAD	<=	'1' WHEN STATE = DATA_INIT_LOAD ELSE '0';


END ARCHITECTURE BEHAVIOR;