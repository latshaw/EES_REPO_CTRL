LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY AD7328_CONTROL IS
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 TMPCLD_ADC_SDO : IN STD_LOGIC;
		 TMPWRM_ADC_SDO : IN STD_LOGIC;
		 TMP_ADC_SDI : OUT STD_LOGIC;
		 TMP_ADC_CLK : OUT STD_LOGIC;
		 TMP_ADC_CS : OUT STD_LOGIC;
		 TMPWRM_FLTR_EN: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_FLTR_EN: OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_DATA : OUT REG16_ARRAY;
		 TMPWRM_DATA : OUT REG16_ARRAY		 		 
		 );
END ENTITY AD7328_CONTROL;

ARCHITECTURE BEHAVIOR OF AD7328_CONTROL IS



SIGNAL CONTROL_REG_VAL			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL SEQ_REG_VAL				: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL EN_SHIFT_REG				: STD_LOGIC;
SIGNAL LOAD_SHIFT_REG			: STD_LOGIC;
SIGNAL INP_SHIFT_REG				: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL SHIFT_REG_OUTPUT			: STD_LOGIC;
SIGNAL SEL_INP_SHIFT_REG		: STD_LOGIC;

SIGNAL CLEAR_CLK_COUNT			: STD_LOGIC;
SIGNAL EN_CLK_COUNT				: STD_LOGIC;
SIGNAL CLK_COUNT					: STD_LOGIC_VECTOR(2 DOWNTO 0);

SIGNAL CLEAR_DELAY_COUNT		: STD_LOGIC;
SIGNAL EN_DELAY_COUNT				: STD_LOGIC;
SIGNAL DELAY_COUNT				: STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL CLEAR_BIT_COUNT			: STD_LOGIC;
SIGNAL EN_BIT_COUNT				: STD_LOGIC;
SIGNAL BIT_COUNT					: STD_LOGIC_VECTOR(3 DOWNTO 0);

SIGNAL EN_TMP_REG					: STD_LOGIC;
SIGNAL TMPCLD_OUT					: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL TMPWRM_OUT					: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL TMP_CLD_REG				: REG13_ARRAY;
SIGNAL EN_TMP_CLD_REG			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL TMP_WRM_REG				: REG13_ARRAY;
SIGNAL EN_TMP_WRM_REG			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_DATA_REG				: STD_LOGIC;
SIGNAL ONE							: STD_LOGIC;

SIGNAL CNTRL_COUNT				: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL CLEAR_CNTRL_COUNT		: STD_LOGIC;
SIGNAL EN_CNTRL_COUNT			: STD_LOGIC;			

--TYPE STATE_TYPE IS (INIT, CS_LOW, LOAD_CNTRL_REG, SCLK_LOW_CNTRL, SCLK_HIGH_CNTRL, WAIT_CS, CONVERT, SCLK_DATA_LOW, SCLK_DATA_HIGH, T_QUIET);  
TYPE STATE_TYPE IS (INIT, CS_LOW, LOAD_CNTRL_REG, SCLK_LOW_CNTRL, SCLK_HIGH_CNTRL, WAIT_CS, CONVERT, SCLK_DATA_HIGH, SCLK_DATA_LOW, T_QUIET);  
SIGNAL STATE : STATE_TYPE;

attribute ENUM_ENCODING: STRING;
attribute ENUM_ENCODING of STATE_TYPE:type is "0000000001 0000000010 0000000100 0000001000 0000010000 0000100000 0001000000 0010000000 0100000000 1000000000" ;

BEGIN

--enable registers for low pass filtering

wrm_wind_en: regne
		generic map(n => 8) 
		port map(clock => clock,
				   reset => reset, 	
					clear => '1',
					en		=> '1',
					input => EN_TMP_WRM_REG,
					output => TMPWRM_FLTR_EN
				  );
				  
cld_wind_en: regne
		generic map(n => 8) 
		port map(clock => clock,
				   reset => reset, 	
					clear => '1',
					en		=> '1',
					input => EN_TMP_CLD_REG,
					output => TMPCLD_FLTR_EN
				  );

	ONE <= '1';

TMP_REG_GEN: FOR I IN 0 TO 7 GENERATE

		TMP_CLD_REG_GEN: REGNE
				GENERIC MAP(N => 13) 
				PORT MAP(CLOCK	=> CLOCK,
						 RESET	=> RESET,
						 CLEAR	=> ONE,
						 EN		=> EN_TMP_CLD_REG(I),
						 INPUT	=> TMPCLD_OUT(12 DOWNTO 0),
						 OUTPUT	=> TMP_CLD_REG(I)
						);

TMPCLD_DATA(I)(15 DOWNTO 13) <= (OTHERS => TMP_CLD_REG(I)(12));
TMPCLD_DATA(I)(12 DOWNTO 0) <= TMP_CLD_REG(I);


						
		TMP_WRM_REG_GEN: REGNE
				GENERIC MAP(N => 13) 
				PORT MAP(CLOCK	=> CLOCK,
						 RESET	=> RESET,
						 CLEAR	=> ONE,
						 EN		=> EN_TMP_WRM_REG(I),
						 INPUT	=> TMPWRM_OUT(12 DOWNTO 0),
						 OUTPUT	=> TMP_WRM_REG(I)
						);						
						
TMPWRM_DATA(I)(15 DOWNTO 13) <= (OTHERS => TMP_WRM_REG(I)(12));
TMPWRM_DATA(I)(12 DOWNTO 0) <= TMP_WRM_REG(I);

END GENERATE;					
						
						
EN_TMP_CLD_REG(0) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "010" AND EN_DATA_REG = '1') ELSE '0';					
EN_TMP_CLD_REG(1) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "011" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_CLD_REG(2) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "110" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_CLD_REG(3) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "111" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_CLD_REG(4) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "101" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_CLD_REG(5) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "100" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_CLD_REG(6) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "001" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_CLD_REG(7) <= '1' WHEN (TMPCLD_OUT(15 DOWNTO 13) = "000" AND EN_DATA_REG = '1') ELSE '0';
						
EN_TMP_WRM_REG(0) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "010" AND EN_DATA_REG = '1') ELSE '0';						
EN_TMP_WRM_REG(1) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "011" AND EN_DATA_REG = '1') ELSE '0';						
EN_TMP_WRM_REG(2) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "110" AND EN_DATA_REG = '1') ELSE '0';						
EN_TMP_WRM_REG(3) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "111" AND EN_DATA_REG = '1') ELSE '0';						
EN_TMP_WRM_REG(4) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "101" AND EN_DATA_REG = '1') ELSE '0';						
EN_TMP_WRM_REG(5) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "100" AND EN_DATA_REG = '1') ELSE '0';						
EN_TMP_WRM_REG(6) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "001" AND EN_DATA_REG = '1') ELSE '0';
EN_TMP_WRM_REG(7) <= '1' WHEN (TMPWRM_OUT(15 DOWNTO 13) = "000" AND EN_DATA_REG = '1') ELSE '0';
						

	SEQ_REG_VAL		<= x"FFE0";
	CONTROL_REG_VAL <= x"8014";
	
	INP_SHIFT_REG	<= CONTROL_REG_VAL WHEN CNTRL_COUNT = "01" ELSE
					   SEQ_REG_VAL WHEN CNTRL_COUNT = "00" ELSE
					   (OTHERS => '0');

SHIFT_REG_CNTRL: SHIFT_REG
	GENERIC MAP(N => 16)
	PORT MAP(CLOCK 	=> CLOCK,
			 RESET 	=> RESET, 
			 EN		=> EN_SHIFT_REG, 	
			 LOAD	=> LOAD_SHIFT_REG,
			 INP	=> INP_SHIFT_REG, 
			 OUTPUT => SHIFT_REG_OUTPUT
			);

	TMP_ADC_SDI	<= SHIFT_REG_OUTPUT;
	
	
CLD_DATA_REG: SHIFT_LEFT_REG
	GENERIC MAP(N => 16)
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 EN		=> EN_TMP_REG,
			 INP	=> TMPCLD_ADC_SDO,
			 OUTPUT	=> TMPCLD_OUT
			);
			
WRM_DATA_REG: SHIFT_LEFT_REG
	GENERIC MAP(N => 16)
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 EN		=> EN_TMP_REG,
			 INP	=> TMPWRM_ADC_SDO,
			 OUTPUT	=> TMPWRM_OUT
			);
			
			
CNTRL_REG_COUNTER : COUNTER
		GENERIC MAP(N => 2)
		PORT MAP(CLOCK	=> CLOCK,
				 RESET	=> RESET,
				 CLEAR	=> CLEAR_CNTRL_COUNT,
				 ENABLE	=> EN_CNTRL_COUNT,
				 COUNT	=> CNTRL_COUNT
				);				
			
			

					
	
CLK_COUNTER : COUNTER
		GENERIC MAP(N => 3)
		PORT MAP(CLOCK	=> CLOCK,
				 RESET	=> RESET,
				 CLEAR	=> CLEAR_CLK_COUNT,
				 ENABLE	=> EN_CLK_COUNT,
				 COUNT	=> CLK_COUNT
				);	
				
DELAY_COUNTER : COUNTER
		GENERIC MAP(N => 4)
		PORT MAP(CLOCK	=> CLOCK,
				 RESET	=> RESET,
				 CLEAR	=> CLEAR_DELAY_COUNT,
				 ENABLE	=> EN_DELAY_COUNT,
				 COUNT	=> DELAY_COUNT
				);	

BIT_COUNTER : COUNTER
		GENERIC MAP(N => 4)
		PORT MAP(CLOCK	=> CLOCK,
				 RESET	=> RESET,
				 CLEAR	=> CLEAR_BIT_COUNT,
				 ENABLE	=> EN_BIT_COUNT,
				 COUNT	=> BIT_COUNT
				);
	
	PROCESS(CLOCK, RESET)
	BEGIN 
		IF(RESET = '0') THEN
			STATE <= INIT;
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
			
			CASE STATE IS
		
				WHEN INIT =>	STATE <= CS_LOW;
							 
				WHEN CS_LOW	=>	STATE <= LOAD_CNTRL_REG;
				
				WHEN LOAD_CNTRL_REG => STATE <= SCLK_HIGH_CNTRL;
				
				WHEN SCLK_HIGH_CNTRL =>	IF(CLK_COUNT = "011") THEN	STATE <= SCLK_LOW_CNTRL;
										ELSE STATE <= SCLK_HIGH_CNTRL;
										END IF;						
											
				
				WHEN SCLK_LOW_CNTRL => IF(CLK_COUNT = "111") THEN 
											IF(BIT_COUNT = "1111") THEN																					
												IF(CNTRL_COUNT = "01") THEN STATE <= WAIT_CS;
												ELSE STATE <= CS_LOW;
												END IF;
											ELSE											
												STATE <= SCLK_HIGH_CNTRL;
											END IF;
										ELSE											
											STATE <= SCLK_LOW_CNTRL;
										END IF;	
										
				WHEN WAIT_CS => IF DELAY_COUNT = "0100" THEN STATE <= CONVERT;
								ELSE STATE <= WAIT_CS;
								END IF;	
										
				WHEN CONVERT =>	IF(DELAY_COUNT = "0010") THEN STATE <= SCLK_DATA_HIGH;
								ELSE STATE <= CONVERT;
								END IF;
								
				WHEN SCLK_DATA_HIGH => 	IF(CLK_COUNT = "011") THEN STATE <= SCLK_DATA_LOW;
										ELSE STATE <= SCLK_DATA_HIGH;
										END IF;
										
				WHEN SCLK_DATA_LOW =>	IF(CLK_COUNT = "111") THEN
											IF(BIT_COUNT = "1111") THEN STATE <= T_QUIET;
											ELSE STATE <= SCLK_DATA_HIGH;
											END IF;
										ELSE
											STATE <= SCLK_DATA_LOW;
										END IF;
										
				WHEN T_QUIET =>	IF(DELAY_COUNT = "1001") THEN STATE <= WAIT_CS;
								ELSE STATE <= T_QUIET;
								END IF;
								
				WHEN OTHERS		=> STATE <= INIT;
								
			END CASE;
		END IF;
	END PROCESS;
	
	
	--TMP_ADC_CS <= '1' WHEN STATE = INIT OR (STATE = T_QUIET) ELSE '0';
	TMP_ADC_CS <= '1' WHEN STATE = INIT OR (STATE = SCLK_LOW_CNTRL AND CLK_COUNT = "111" AND BIT_COUNT = "1111") OR (STATE = T_QUIET) ELSE '0';
	
	--TMP_ADC_CS <= '0' WHEN STATE = CS_LOW OR STATE = CONVERT OR (STATE = SCLK_LOW_CNTRL AND CLK_COUNT /= "111") ELSE '1';
	
	
	CLEAR_CLK_COUNT <= '0' WHEN STATE = CONVERT OR STATE = INIT ELSE '1';
	EN_CLK_COUNT <= '1' WHEN ((STATE = SCLK_HIGH_CNTRL OR STATE = SCLK_DATA_HIGH) AND (CLK_COUNT/= "011" OR CLK_COUNT = "011")) OR ((STATE = SCLK_LOW_CNTRL OR STATE = SCLK_DATA_LOW) AND (CLK_COUNT/= "111")) ELSE '0' ;
	
	CLEAR_BIT_COUNT <= '0' WHEN STATE = INIT OR STATE = CONVERT ELSE '1';
	EN_BIT_COUNT <= '1' WHEN (STATE = SCLK_LOW_CNTRL OR STATE = SCLK_DATA_LOW) AND CLK_COUNT = "111" AND (BIT_COUNT /= "1111" OR BIT_COUNT = "1111") ELSE '0';
	
	CLEAR_DELAY_COUNT <= '0' WHEN (STATE = WAIT_CS AND DELAY_COUNT = "0100") OR (STATE = CONVERT AND DELAY_COUNT = "0010") OR (STATE = T_QUIET AND DELAY_COUNT = "1001") ELSE '1';
	EN_DELAY_COUNT <= '1' WHEN (STATE = WAIT_CS AND DELAY_COUNT /= "0100") OR (STATE = CONVERT AND DELAY_COUNT /= "0010") OR (STATE = T_QUIET AND DELAY_COUNT /= "1001") ELSE '0';
	
	LOAD_SHIFT_REG <= '1' WHEN STATE = LOAD_CNTRL_REG ELSE '0';
	EN_SHIFT_REG <= '1' WHEN STATE = SCLK_HIGH_CNTRL AND BIT_COUNT /= "0000" AND CLK_COUNT = "010" ELSE '0';
	
	TMP_ADC_CLK <= '0' WHEN STATE = SCLK_LOW_CNTRL OR STATE = SCLK_DATA_LOW ELSE '1';
	
	EN_DATA_REG <= '1' WHEN (STATE = SCLK_DATA_LOW AND CLK_COUNT = "111" AND BIT_COUNT = "1111") ELSE '0';
	
	EN_TMP_REG <= '1' WHEN (STATE = SCLK_DATA_HIGH AND CLK_COUNT = "010") ELSE '0'; 
	
	EN_CNTRL_COUNT <= '1' WHEN STATE = SCLK_LOW_CNTRL AND CLK_COUNT = "111" AND BIT_COUNT = "1111" AND (CNTRL_COUNT = "00" OR CNTRL_COUNT = "01") ELSE '0'; 
	CLEAR_CNTRL_COUNT <= '0' WHEN STATE = SCLK_LOW_CNTRL AND CLK_COUNT = "111" AND BIT_COUNT = "1111" AND CNTRL_COUNT = "01" ELSE '1';
	
	
	
	
END ARCHITECTURE BEHAVIOR;