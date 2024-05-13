library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ads8353 is
	port(clock : in std_logic;
		 nreset : in std_logic;
	
		 sdo_a : in std_logic;
		 sdo_b : in std_logic;
		 
		 ncs : out std_logic;
		 sclk : out std_logic;
		 sdi : out std_logic;
		 
		 data_cha : out std_logic_vector(15 downto 0);
		 data_chb : out std_logic_vector(15 downto 0)
		 );
end entity ads8353;
architecture behavior of ads8353 is

signal inp_din_reg_d, inp_din_reg_q : std_logic_vector(15 downto 0);
signal inp_din_reg					:	std_logic_vector(15 downto 0);
signal din_cnt_d, din_cnt_q			: integer range 0 to 2;
signal sclk_cnt_d, sclk_cnt_q		: integer range 0 to 7;
signal bit_cnt_d, bit_cnt_q			: integer range 0 to 31;
signal sdo_a_d, sdo_a_q				: std_logic;
signal data_cha_d, data_cha_q		: std_logic_vector(31 downto 0);
signal data_a_d, data_a_q			: std_logic_vector(15 downto 0);
signal sclk_d, sclk_q				: std_logic;
signal ncs_d, ncs_q					: std_logic;
signal sdi_d, sdi_q					: std_logic;
signal sdo_b_d, sdo_b_q				: std_logic;
signal data_chb_d, data_chb_q		: std_logic_vector(31 downto 0);
signal data_b_d, data_b_q			: std_logic_vector(15 downto 0);
type state_type is (init, cs_low, cs_low_wait, ctrl_ld, ctrl_sclk_high, ctrl_sclk_low, cs_high, cs_high_wait, cs_low_data, cs_low_data_wait, data_sclk_high, data_sclk_low, cs_high_data, cs_high_data_wait, data_acq); 
signal state_d, state_q			: state_type;
begin	
sdi			<=	sdi_q;
ncs			<=	ncs_q;
sclk		<=	sclk_q;
sdo_a_d		<=	sdo_a;
sdo_b_d		<=	sdo_b;
data_cha	<=	data_a_q;
data_chb	<=	data_b_q;
with din_cnt_q select
inp_din_reg		<= x"8040" when 0,--cfr
						x"9ff8" when 1,--ref_dac_a
						x"aff8" when 2,--ref_dac_b
						x"0000" when others;			   
process(clock, nreset)
begin
	if(nreset	= '0') then
		state_q			<=	init;
		sdi_q			<=	'0';
		sclk_q			<=	'0';
		ncs_q			<=	'1';
		inp_din_reg_q	<=	(others	=>	'0');
		sclk_cnt_q		<=	0;
		bit_cnt_q		<=	0;
		din_cnt_q		<=	0;
		data_cha_q		<=	(others	=>	'0');
		data_a_q		<=	(others	=>	'0');
		data_chb_q		<=	(others	=>	'0');
		data_b_q		<=	(others	=>	'0');
		sdo_a_q			<=	'0';
		sdo_b_q			<=	'0';
	elsif(rising_edge(clock)) then
		state_q			<=	state_d;
		sdi_q				<=	sdi_d;
		sclk_q			<=	sclk_d;
		ncs_q				<=	ncs_d;
		inp_din_reg_q	<=	inp_din_reg_d;
		sclk_cnt_q		<=	sclk_cnt_d;
		bit_cnt_q		<=	bit_cnt_d;
		din_cnt_q		<=	din_cnt_d;
		data_cha_q		<=	data_cha_d;
		data_a_q			<=	data_a_d;
		data_chb_q		<=	data_chb_d;
		data_b_q			<=	data_b_d;
		sdo_a_q			<=	sdo_a_d;
		sdo_b_q			<=	sdo_b_d;
	end if;
end process;	
				 
process(state_q, sdi_q, sclk_q, ncs_q, sdi_q, inp_din_reg_q, inp_din_reg, sclk_cnt_q, bit_cnt_q, din_cnt_q, data_cha_q, data_chb_q, sdo_a_q, sdo_b_q, data_a_q, data_b_q)
begin
	state_d			<=	state_q;
	sdi_d			<=	sdi_q;
	sclk_d			<=	sclk_q;
	ncs_d			<=	ncs_q;
	sdi_d			<=	sdi_q;
	inp_din_reg_d	<=	inp_din_reg_q;
	sclk_cnt_d		<=	sclk_cnt_q;
	bit_cnt_d		<=	bit_cnt_q;
	din_cnt_d		<=	din_cnt_q;
	data_cha_d		<=	data_cha_q;
	data_a_d		<=	data_a_q;
	data_chb_d		<=	data_chb_q;
	data_b_d		<=	data_b_q;
	case state_q is				
		when init				=> 
			sdi_d		<=	'0';
			sclk_d		<=	'1';
			ncs_d		<=	'1';
			state_d 	<= cs_low;				
		when cs_low				=> 
			ncs_d		<=	'0';
			state_d 	<= cs_low_wait; 				
		when cs_low_wait		=> 
			state_d <= ctrl_ld;				
		when ctrl_ld			=>
			sdi_d			<=	inp_din_reg_q(15);
			inp_din_reg_d	<=	inp_din_reg;	
			state_d 			<= 	ctrl_sclk_high;				
		when ctrl_sclk_high		=>
			sclk_d	<=	'1';	
			sdi_d		<=	inp_din_reg_q(15);
			sclk_cnt_d	<=	sclk_cnt_q + 1; 
			if sclk_cnt_q = 3 then
				state_d <= ctrl_sclk_low;
			end if;										  
		when ctrl_sclk_low		=> 	
			sclk_d		<=	'0';
			sdi_d		<=	inp_din_reg_q(15);			
			if sclk_cnt_q = 7 then
				inp_din_reg_d	<=	inp_din_reg_q(14 downto 0) & '0';
				sclk_cnt_d		<=	0;				
				if bit_cnt_q = 31 then
					bit_cnt_d	<=	0;
					state_d 	<= cs_high;
				else
					bit_cnt_d	<=	bit_cnt_q + 1;
					state_d 	<= ctrl_sclk_high;
				end if;
			else
				sclk_cnt_d	<=	sclk_cnt_q + 1;
			end if;										
		when cs_high			=> 
			ncs_d		<=	'1';
			sdi_d		<=	inp_din_reg_q(15);
			sclk_d		<=	'1';
			state_d 	<= cs_high_wait;				
		when cs_high_wait		=>
			sdi_d		<=	inp_din_reg_q(15);
			if din_cnt_q = 2 then
				state_d 	<= cs_low_data;
				din_cnt_d	<=	0;
			else
				state_d 	<= cs_low;
				din_cnt_d	<=	din_cnt_q + 1;
			end if;									   
		when cs_low_data		=> 
			ncs_d		<=	'0';
			sdi_d		<=	'0';
			state_d		<= cs_low_data_wait;				
		when cs_low_data_wait	=>
			state_d		<= data_sclk_high;				
		when data_sclk_high		=>
			sclk_cnt_d	<=	sclk_cnt_q + 1;
			sclk_d	<=	'1';
			if sclk_cnt_q = 3 then
				state_d <= data_sclk_low;
				data_cha_d	<=	data_cha_q(30 downto 0) & sdo_a_q;
				data_chb_d	<=	data_chb_q(30 downto 0) & sdo_b_q;
			end if;									   
		when data_sclk_low		=> 
			sclk_d	<=	'0';			
			if sclk_cnt_q = 7 then
			   	sclk_cnt_d	<=	0;				
				if bit_cnt_q = 31 then
					bit_cnt_d	<=	0;
					state_d 	<= cs_high_data;
				else 
					bit_cnt_d	<=	bit_cnt_q + 1;
					state_d		<= data_sclk_high;
				end if;
			else
				sclk_cnt_d	<=	sclk_cnt_q + 1;
			end if;										
		when cs_high_data		=> 
			ncs_d		<=	'1';
			sclk_d		<=	'1';
			state_d 	<= cs_high_data_wait;				
		when cs_high_data_wait	=>
			state_d		 <= data_acq;				
		when data_acq			=>
			state_d		<= cs_low_data;
			data_a_d	<=	data_cha_q(15 downto 0);
			data_b_d	<=	data_chb_q(15 downto 0);	
	end case;
end process;	
end architecture behavior;
--LIBRARY IEEE;
--USE IEEE.STD_LOGIC_1164.ALL;
--USE WORK.COMPONENTS.ALL;
--
--ENTITY ADS8353 IS
--	PORT(CLOCK : IN STD_LOGIC;
--		 nRESET : IN STD_LOGIC;
--	
--		 SDO_A : IN STD_LOGIC;
--		 SDO_B : IN STD_LOGIC;
--		 
--		 nCS : OUT STD_LOGIC;
--		 SCLK : OUT STD_LOGIC;
--		 SDI : OUT STD_LOGIC;
--		 
--		 DATA_CHA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
--		 DATA_CHB : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
--		 );
--END ENTITY ADS8353;
--
--ARCHITECTURE BEHAVIOR OF ADS8353 IS
--
--SIGNAL INP_DIN_REG		: STD_LOGIC_VECTOR(15 DOWNTO 0);
--SIGNAL EN_DIN_REG		: STD_LOGIC;
--SIGNAL LD_DIN_REG		: STD_LOGIC;
--SIGNAL DIN				: STD_LOGIC;
--
--SIGNAL CLR_DIN_CNT		: STD_LOGIC;
--SIGNAL EN_DIN_CNT		: STD_LOGIC;
--SIGNAL DIN_CNT			: STD_LOGIC_VECTOR(1 DOWNTO 0);
--
--SIGNAL EN_SCLK_CNT		: STD_LOGIC;
--SIGNAL SCLK_CNT			: STD_LOGIC_VECTOR(2 DOWNTO 0);
--
--SIGNAL EN_BIT_CNT		: STD_LOGIC;
--SIGNAL BIT_CNT			: STD_LOGIC_VECTOR(4 DOWNTO 0);
--
--SIGNAL SDO_A_BUF		: STD_LOGIC;
--SIGNAL EN_DOUT_CHA		: STD_LOGIC;
--SIGNAL DATA_CHA_BUF			: STD_LOGIC_VECTOR(31 DOWNTO 0);
--
--SIGNAL SCLK_BUF			: STD_LOGIC;
--SIGNAL nCS_BUF			: STD_LOGIC;
--SIGNAL SDI_BUF			: STD_LOGIC;
--
--SIGNAL SDO_B_BUF		: STD_LOGIC;
--SIGNAL EN_DOUT_CHB		: STD_LOGIC;
--SIGNAL DATA_CHB_BUF		: STD_LOGIC_VECTOR(31 DOWNTO 0);
--
--SIGNAL EN_DATA_BUF		: STD_LOGIC;
--
--TYPE STATE_TYPE IS (INIT, CS_LOW, CS_LOW_WAIT, CTRL_LD, CTRL_SCLK_HIGH, CTRL_SCLK_LOW, CS_HIGH, CS_HIGH_WAIT, CS_LOW_DATA, CS_LOW_DATA_WAIT, DATA_SCLK_HIGH, DATA_SCLK_LOW, CS_HIGH_DATA, CS_HIGH_DATA_WAIT, DATA_ACQ); 
--SIGNAL STATE			: STATE_TYPE;
--
--BEGIN
--	
--	
--	
-------SHIFT LEFT REGISTER FOR SENDING CONFIGURATION DATA TO ADC-----------
--	
--CFG_DATA_COUNTER: COUNTER
--		GENERIC MAP(N => 2)
--		PORT MAP(CLOCK		=> CLOCK,
--			  	 RESET		=> nRESET,
--			  	 CLEAR		=> CLR_DIN_CNT,
--			  	 ENABLE		=> EN_DIN_CNT,
--			  	 COUNT		=> DIN_CNT
--			 	 );	
--	
-------CFR <= 0X8060;
-------REF_DAC_A <= 0X9FF0;
-------REF_DAC_B <= 0XAFF0;
--
--WITH DIN_CNT SELECT
--INP_DIN_REG		<= X"8040" WHEN "00",
--				   X"9FF8" WHEN "01",
--				   X"AFF8" WHEN "10",
--				   X"0000" WHEN OTHERS;			   
--
--ADC_DIN_REG: SHIFT_LEFT_REG_ADS8353
--	GENERIC MAP(N => 16)
--	PORT MAP(CLOCK	=> CLOCK,
--		  	 RESET	=> nRESET,
--		  	 EN		=> EN_DIN_REG,
--		  	 LOAD	=> LD_DIN_REG,
--		  	 INP	=> INP_DIN_REG,
--		  	 OUTPUT	=> DIN
--		  	 );
--			   
--SDI_FF: FLIP_FLOP 
--	PORT MAP(CLOCK	=> CLOCK,
--		  	 RESET	=> nRESET,
--		  	 CLEAR	=> '1',
--		  	 EN		=> '1',
--		  	 INP	=> SDI_BUF,
--		  	 OUP	=> SDI
--		  	 );			   
--
--SCLK_COUNTER: COUNTER
--		GENERIC MAP(N => 3)
--		PORT MAP(CLOCK		=> CLOCK,
--			  	 RESET		=> nRESET,
--			  	 CLEAR		=> '1',
--			  	 ENABLE		=> EN_SCLK_CNT,
--			  	 COUNT		=> SCLK_CNT
--			 	 );
--				  
--SCLK_FF: FLIP_FLOP 
--	PORT MAP(CLOCK	=> CLOCK,
--		  	 RESET	=> nRESET,
--		  	 CLEAR	=> '1',
--		  	 EN		=> '1',
--		  	 INP	=> SCLK_BUF,
--		  	 OUP	=> SCLK
--		  	 );
--			   
--nCS_FF: FLIP_FLOP 
--	PORT MAP(CLOCK	=> CLOCK,
--		  	 RESET	=> nRESET,
--		  	 CLEAR	=> '1',
--		  	 EN		=> '1',
--		  	 INP	=> nCS_BUF,
--		  	 OUP	=> nCS
--		  	 );
--			   
--BIT_COUNTER: COUNTER
--		GENERIC MAP(N => 5)
--		PORT MAP(CLOCK		=> CLOCK,
--			  	 RESET		=> nRESET,
--			  	 CLEAR		=> '1',
--			  	 ENABLE		=> EN_BIT_CNT,
--			  	 COUNT		=> BIT_CNT
--			 	 );
--				  
--SDOA_FF: FLIP_FLOP 
--	PORT MAP(CLOCK	=> CLOCK,
--		  	 RESET	=> nRESET,
--		  	 CLEAR	=> '1',
--		  	 EN		=> '1',
--		  	 INP	=> SDO_A,
--		  	 OUP	=> SDO_A_BUF
--		  	 );			   
--				  
--CONV_DATA_CHA: SHIFT_LEFT_REG
--	GENERIC MAP(N => 32)
--	PORT MAP(CLOCK	=> CLOCK,
--		 	 RESET	=> nRESET,
--		 	 EN		=> EN_DOUT_CHA,
--		 	 INP	=> SDO_A_BUF,
--		 	 OUTPUT	=> DATA_CHA_BUF
--		 	 );
--			  
--CHA_DATA_BUF: REGNE
--		GENERIC MAP(N => 16) 
--		PORT MAP(CLOCK	=> CLOCK,
--			  	 RESET	=> nRESET,
--			  	 CLEAR	=> '1',
--			  	 EN		=> EN_DATA_BUF,
--			  	 INPUT	=> DATA_CHA_BUF(15 DOWNTO 0),
--			  	 OUTPUT	=> DATA_CHA
--				 );
--			  
--SDOB_FF: FLIP_FLOP 
--	PORT MAP(CLOCK	=> CLOCK,
--		  	 RESET	=> nRESET,
--		  	 CLEAR	=> '1',
--		  	 EN		=> '1',
--		  	 INP	=> SDO_B,
--		  	 OUP	=> SDO_B_BUF
--		  	 );			   
--				  
--CONV_DATA_CHB: SHIFT_LEFT_REG
--	GENERIC MAP(N => 32)
--	PORT MAP(CLOCK	=> CLOCK,
--		 	 RESET	=> nRESET,
--		 	 EN		=> EN_DOUT_CHB,
--		 	 INP	=> SDO_B_BUF,
--		 	 OUTPUT	=> DATA_CHB_BUF
--		 	 );
--			  
--CHB_DATA_BUF: REGNE
--		GENERIC MAP(N => 16) 
--		PORT MAP(CLOCK	=> CLOCK,
--			  	 RESET	=> nRESET,
--			  	 CLEAR	=> '1',
--			  	 EN		=> EN_DATA_BUF,
--			  	 INPUT	=> DATA_CHB_BUF(15 DOWNTO 0),
--			  	 OUTPUT	=> DATA_CHB
--				 );
--				 
--				 
--	PROCESS(CLOCK, nRESET)
--	BEGIN
--		IF nRESET = '0' THEN
--			STATE <= INIT;
--		ELSIF (CLOCK = '1' AND CLOCK' EVENT) THEN
--			
--			CASE STATE IS
--				
--				WHEN INIT				=> STATE <= CS_LOW;
--				
--				WHEN CS_LOW				=> STATE <= CS_LOW_WAIT;
--				
--				WHEN CS_LOW_WAIT		=> STATE <= CTRL_LD;
--				
--				WHEN CTRL_LD			=> STATE <= CTRL_SCLK_HIGH;
--				
--				WHEN CTRL_SCLK_HIGH		=> IF SCLK_CNT = "011" THEN STATE <= CTRL_SCLK_LOW;
--											ELSE STATE <= CTRL_SCLK_HIGH;
--			  								END IF;
--										  
--				WHEN CTRL_SCLK_LOW		=> IF SCLK_CNT = "111" THEN
--												IF BIT_CNT = "11111" THEN STATE <= CS_HIGH;
--												ELSE STATE <= CTRL_SCLK_HIGH;
--												END IF;
--											ELSE STATE <= CTRL_SCLK_LOW;
--											END IF;
--										
--				WHEN CS_HIGH			=> STATE <= CS_HIGH_WAIT;
--				
--				WHEN CS_HIGH_WAIT		=> IF DIN_CNT = "10" THEN STATE <= CS_LOW_DATA;
--									   		ELSE STATE <= CS_LOW;
--									   		END IF;
--									   
--				WHEN CS_LOW_DATA		=> STATE <= CS_LOW_DATA_WAIT;
--				
--				WHEN CS_LOW_DATA_WAIT	=> STATE <= DATA_SCLK_HIGH;
--				
--				WHEN DATA_SCLK_HIGH		=> IF SCLK_CNT = "011" THEN STATE <= DATA_SCLK_LOW;
--									  	 	ELSE STATE <= DATA_SCLK_HIGH;
--									   		END IF;
--									   
--				WHEN DATA_SCLK_LOW		=> IF SCLK_CNT = "111" THEN
--												IF BIT_CNT = "11111" THEN STATE <= CS_HIGH_DATA;
--										   		ELSE STATE <= DATA_SCLK_HIGH;
--												END IF;
--											ELSE STATE <= DATA_SCLK_LOW;
--											END IF;
--										
--				WHEN CS_HIGH_DATA		=> STATE <= CS_HIGH_DATA_WAIT;
--				
--				WHEN CS_HIGH_DATA_WAIT	=> STATE <= DATA_ACQ;
--				
--				WHEN DATA_ACQ			=> STATE <= CS_LOW_DATA;
--				
--				WHEN OTHERS				=> STATE <= INIT;
--				
--			END CASE;
--		END IF;
--	END PROCESS;
--										   
--												
--SCLK_BUF	<= '0' WHEN STATE = DATA_SCLK_LOW OR STATE = CTRL_SCLK_LOW ELSE '1';
--EN_SCLK_CNT	<= '1' WHEN STATE = CTRL_SCLK_HIGH OR STATE = CTRL_SCLK_LOW OR STATE = DATA_SCLK_HIGH OR STATE = DATA_SCLK_LOW ELSE '0';
--	
--EN_BIT_CNT	<= '1' WHEN (STATE = CTRL_SCLK_LOW OR STATE = DATA_SCLK_LOW) AND SCLK_CNT = "111" ELSE '0';
--	
--EN_DIN_CNT	<= '1' WHEN STATE = CS_HIGH_WAIT ELSE '0';
--CLR_DIN_CNT	<= '0' WHEN (STATE = CS_HIGH_WAIT AND DIN_CNT = "10") ELSE '1';
--	
--nCS_BUF		<= '1' WHEN STATE = INIT OR STATE = CS_HIGH OR STATE = CS_HIGH_WAIT OR STATE = CS_HIGH_DATA OR STATE = CS_HIGH_DATA_WAIT ELSE '0';
--
--LD_DIN_REG	<= '1' WHEN STATE = CTRL_LD ELSE '0';
--EN_DIN_REG	<= '1' WHEN STATE = CTRL_SCLK_LOW AND SCLK_CNT = "111" ELSE '0';	
--
--EN_DATA_BUF	<= '1' WHEN STATE = DATA_ACQ ELSE '0';												
--												
--EN_DOUT_CHA	<= '1' WHEN STATE = DATA_SCLK_HIGH AND SCLK_CNT = "011" ELSE '0';												
--EN_DOUT_CHB	<= '1' WHEN STATE = DATA_SCLK_HIGH AND SCLK_CNT = "011" ELSE '0';
--	
--SDI_BUF		<= DIN WHEN STATE = CTRL_LD OR STATE = CTRL_SCLK_HIGH OR STATE = CTRL_SCLK_LOW OR STATE = CS_HIGH OR STATE = CS_HIGH_WAIT ELSE '0';
--	
--	
--END ARCHITECTURE BEHAVIOR;	