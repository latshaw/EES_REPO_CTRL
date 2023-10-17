-- HDL for ARC ADC, ADS8353 from Rama
-- 7/2/2021

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ads8353_arc is
	port(clock : in std_logic;
		 nreset : in std_logic;
	
		 sdo_a : in std_logic;
		 sdo_b : in std_logic;
		 
		 ncs : out std_logic;
		 sclk : out std_logic;
		 sdi : out std_logic;
		 
		 busy : out std_logic; -- adc is busy, JAL
		 
		 data_cha : out std_logic_vector(15 downto 0);
		 data_chb : out std_logic_vector(15 downto 0)
		 );
end entity ads8353_arc;
architecture behavior of ads8353_arc is

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


-- Added by JAL, to let us know when new data is being loaded
-- this will help with loading waveforms. 
busy <= '1' when ncs_q = '0' else '0';
	
end architecture behavior;