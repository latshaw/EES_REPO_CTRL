library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.all;

entity ad9653_ddr_acq is
port(	reset				:	in	std_logic;
		adc_bit_clk		:	in std_logic;
		adc_data_clk	:	in std_logic;
		
		pll_lock			:	in	std_logic;
		adc_data_in		:	in	std_logic_vector(8 downto 0);
		fclk_out			:	out std_logic_vector(7 downto 0);
		adca_out			:	out std_logic_vector(15 downto 0);
		adcb_out			:	out std_logic_vector(15 downto 0);
		adcc_out			:	out std_logic_vector(15 downto 0);
		adcd_out			:	out std_logic_vector(15 downto 0);
		data_match		:	out std_logic
		);
end entity ad9653_ddr_acq;
architecture behavior of ad9653_ddr_acq is


signal adca0_bit_d			:	std_logic_vector(7 downto 0);
signal adca0_bit_q			:	std_logic_vector(7 downto 0);
signal adca1_bit_d			:	std_logic_vector(7 downto 0);
signal adca1_bit_q			:	std_logic_vector(7 downto 0);
signal adca_data_d			:	std_logic_vector(15 downto 0);
signal adca_data_q			:	std_logic_vector(15 downto 0);
signal adcb0_bit_d			:	std_logic_vector(7 downto 0);
signal adcb0_bit_q			:	std_logic_vector(7 downto 0);
signal adcb1_bit_d			:	std_logic_vector(7 downto 0);
signal adcb1_bit_q			:	std_logic_vector(7 downto 0);
signal adcb_data_d			:	std_logic_vector(15 downto 0);
signal adcb_data_q			:	std_logic_vector(15 downto 0);

signal adcc0_bit_d			:	std_logic_vector(7 downto 0);
signal adcc0_bit_q			:	std_logic_vector(7 downto 0);
signal adcc1_bit_d			:	std_logic_vector(7 downto 0);
signal adcc1_bit_q			:	std_logic_vector(7 downto 0);
signal adcc_data_d			:	std_logic_vector(15 downto 0);
signal adcc_data_q			:	std_logic_vector(15 downto 0);
signal adcd0_bit_d			:	std_logic_vector(7 downto 0);
signal adcd0_bit_q			:	std_logic_vector(7 downto 0);
signal adcd1_bit_d			:	std_logic_vector(7 downto 0);
signal adcd1_bit_q			:	std_logic_vector(7 downto 0);
signal adcd_data_d			:	std_logic_vector(15 downto 0);
signal adcd_data_q			:	std_logic_vector(15 downto 0);

signal fclk_bit_d				:	std_logic_vector(7 downto 0);
signal fclk_bit_q				:	std_logic_vector(7 downto 0);
signal fclk_d					:	std_logic_vector(7 downto 0);
signal fclk_q					:	std_logic_vector(7 downto 0);
begin

adca0_bit_d(0)			<=	adc_data_in(0);
adca1_bit_d(0)			<=	adc_data_in(1);
adcb0_bit_d(0)			<=	adc_data_in(2);
adcb1_bit_d(0)			<=	adc_data_in(3);
adcc0_bit_d(0)			<=	adc_data_in(4);
adcc1_bit_d(0)			<=	adc_data_in(5);
adcd0_bit_d(0)			<=	adc_data_in(6);
adcd1_bit_d(0)			<=	adc_data_in(7);
fclk_bit_d(0)			<=	adc_data_in(8);

bit_ff_gen: for i in 0 to 6 generate
	adca0_bit_d(i+1)	<=	adca0_bit_q(i);
	adca1_bit_d(i+1)	<=	adca1_bit_q(i);
	adcb0_bit_d(i+1)	<=	adcb0_bit_q(i);
	adcb1_bit_d(i+1)	<=	adcb1_bit_q(i);
	adcc0_bit_d(i+1)	<=	adcc0_bit_q(i);
	adcc1_bit_d(i+1)	<=	adcc1_bit_q(i);
	adcd0_bit_d(i+1)	<=	adcd0_bit_q(i);
	adcd1_bit_d(i+1)	<=	adcd1_bit_q(i);
	fclk_bit_d(i+1)	<=	fclk_bit_q(i);
end generate;	

process(reset, adc_bit_clk)
begin
	if(reset = '0') then
			adca0_bit_q		<=	(others => '0');
			adca1_bit_q		<=	(others => '0');
			adcb0_bit_q		<=	(others => '0');
			adcb1_bit_q		<=	(others => '0');
			adcc0_bit_q		<=	(others => '0');
			adcc1_bit_q		<=	(others => '0');
			adcd0_bit_q		<=	(others => '0');
			adcd1_bit_q		<=	(others => '0');
			fclk_bit_q		<=	(others => '0');
	elsif(rising_edge(adc_bit_clk)) then
			adca0_bit_q		<=	adca0_bit_d;
			adca1_bit_q		<=	adca1_bit_d;
			adcb0_bit_q		<=	adcb0_bit_d;
			adcb1_bit_q		<=	adcb1_bit_d;
			adcc0_bit_q		<=	adcc0_bit_d;
			adcc1_bit_q		<=	adcc1_bit_d;
			adcd0_bit_q		<=	adcd0_bit_d;
			adcd1_bit_q		<=	adcd1_bit_d;
			fclk_bit_q		<=	fclk_bit_d;
	end if;
end process;

fclk_d		<=	fclk_bit_q;

adca_data_d	<=	adca1_bit_q & adca0_bit_q;
adcb_data_d	<=	adcb1_bit_q & adcb0_bit_q;
adcc_data_d	<=	adcc1_bit_q & adcc0_bit_q;
adcd_data_d	<=	adcd1_bit_q & adcd0_bit_q;

process(reset,adc_data_clk)
begin
		if(reset = '0') then
				adca_data_q		<=	(others => '0');
				adcb_data_q		<=	(others => '0');
				adcc_data_q		<=	(others => '0');
				adcd_data_q		<=	(others => '0');
				fclk_q			<=	(others => '0');
			elsif(rising_edge(adc_data_clk)) then
				adca_data_q		<=	adca_data_d;
				adcb_data_q		<=	adcb_data_d;
				adcc_data_q		<=	adcc_data_d;
				adcd_data_q		<=	adcd_data_d;
				fclk_q			<=	fclk_d;
		end if;
end process;

adca_out		<=	adca_data_q;		
adcb_out		<=	adcb_data_q;	
adcc_out		<=	adcc_data_q;	
adcd_out		<=	adcd_data_q;	
fclk_out		<=	fclk_q;

data_match	<=	'1' when fclk_q = x"98" and adca_data_q = x"0234" and adcb_data_q = x"5493" and adcc_data_q = x"8453" and adcd_data_q = x"0375" else '0'; 





end architecture behavior; 		