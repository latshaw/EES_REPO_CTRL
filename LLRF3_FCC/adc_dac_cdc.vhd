library ieee;
use ieee.std_logic_1164.all;

entity adc_dac_cdc is
	port(reset			:	in std_logic;
			adc_clk		:	in std_logic;
			dac_clk		:	in std_logic;
			strobe_in	:	in std_logic;
			i_in			:	in std_logic_vector(17 downto 0);
			q_in			:	in std_logic_vector(17 downto 0);
			i_out			:	out std_logic_vector(17 downto 0);
			q_out			:	out std_logic_vector(17 downto 0);
			strobe_out	:	out std_logic
			);
end entity adc_dac_cdc;
architecture behavior of adc_dac_cdc is
signal i_in_adc			:	std_logic_vector(17 downto 0);	
signal q_in_adc			:	std_logic_vector(17 downto 0);
signal strobe_buf			:	std_logic;

signal i_out_d, i_out_q	:	std_logic_vector(17 downto 0);
signal q_out_d, q_out_q	:	std_logic_vector(17 downto 0);

signal strobe_dac			:	std_logic_vector(1 downto 0);
signal dac_data_valid	:	std_logic;

begin
process(adc_clk, reset)
begin
	if(reset = '0') then
		i_in_adc		<=	(others	=>	'0');
		q_in_adc		<=	(others	=>	'0');
		strobe_buf	<=	'0';
		strobe_out	<=	'0';
	elsif(rising_edge(adc_clk)) then
		strobe_buf	<=	strobe_in;
		strobe_out	<=	strobe_buf;
		if(strobe_in = '1') then
			i_in_adc	<=	i_in;
			q_in_adc	<=	q_in;
		end if;
	end if;
end process;

--dac_data_valid	<=	not strobe_dac(2) and strobe_dac(1);
i_out_d	<=	i_in_adc when dac_data_valid = '1' else i_out_q;
q_out_d	<=	q_in_adc when dac_data_valid = '1' else q_out_q;	

process(dac_clk, reset)
begin
	if(reset = '0') then
		i_out_q		<=	(others	=>	'0');
		q_out_q		<=	(others	=>	'0');
		strobe_dac	<=	(others	=>	'0');
		dac_data_valid	<=	'0';
	elsif(rising_edge(dac_clk)) then
		strobe_dac	<=	strobe_dac(0)&strobe_buf;
		dac_data_valid	<=	not strobe_dac(1) and strobe_dac(0);
		i_out_q		<=	i_out_d;
		q_out_q		<=	q_out_d;			
	end if;
end process;

i_out		<=	i_out_q;
q_out		<=	q_out_q;


end architecture behavior;			