library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity noniq_dac is
port(clock	: in std_logic;
	 reset	: in std_logic;

	 i_in		: in std_logic_vector(13 downto 0);
	 q_in		: in std_logic_vector(13 downto 0);
	 tx_en	: in std_logic;
	 
	 d_out	: out std_logic_vector(13 downto 0)
	 
	 );
end entity noniq_dac;

architecture behavior of noniq_dac is

signal iq_count_d	: 	std_logic_vector(2 downto 0);
signal iq_count_q	: 	std_logic_vector(2 downto 0);

signal i_mul_lut_d		: 	std_logic_vector(15 downto 0);
signal i_mul_lut_q		: 	std_logic_vector(15 downto 0);
signal q_mul_lut_d		: 	std_logic_vector(15 downto 0);
signal q_mul_lut_q		: 	std_logic_vector(15 downto 0);

signal i_in_d		: 	std_logic_vector(13 downto 0);
signal i_in_q		: 	std_logic_vector(13 downto 0);
signal q_in_d		: 	std_logic_vector(13 downto 0);
signal q_in_q		: 	std_logic_vector(13 downto 0);

signal i_mul_d		: 	std_logic_vector(29 downto 0);
signal i_mul_q		: 	std_logic_vector(29 downto 0);
signal q_mul_d		: 	std_logic_vector(29 downto 0);
signal q_mul_q		: 	std_logic_vector(29 downto 0);
signal i_out_d		:	std_logic_vector(13 downto 0);
signal i_out_q		:	std_logic_vector(13 downto 0);
signal q_out_d		:	std_logic_vector(13 downto 0);
signal q_out_q		:	std_logic_vector(13 downto 0);

signal d_out_d		: std_logic_vector(13 downto 0);
signal d_out_q		: std_logic_vector(13 downto 0);

signal d_tx_d		: std_logic_vector(13 downto 0);
signal d_tx_q		: std_logic_vector(13 downto 0);

signal iq_add_d	: std_logic_vector(14 downto 0);
signal iq_add_q	: std_logic_vector(14 downto 0);

begin

i_in_d	<=	i_in;
q_in_d	<= q_in;
with iq_count_q select
i_mul_lut_d	<= x"0000" when "001",-------cos(450) 	* 1024 = 0 * 1024 = 0
			x"02d4" when "010",-------cos(675) 	* 1024 = 0.707 * 1024 = 724
			x"fc00" when "011",-------cos(900) 	* 1024 = -1 * 1024 = -1024
			x"02d4" when "100",-------cos(1125) * 1024 = 0.707 * 1024 = 724
			x"0000" when "101",-------cos(1350) * 1024 = 0 *1024 = 0
			x"fd2c" when "110",-------cos(1575) * 1024 = -0.707 * 1024 = -724
			x"0400" when "111",-------cos(1800) * 1024 = 1*1024 = 1024
			x"fd2c" when others;------cos(225)  * 1024 = -0.707 * 1024 = -724
with iq_count_q select			
q_mul_lut_d	<= x"0400" when "001",-------sin(450) 	* 1024 = 1 * 1024 = 1024
			x"fd2c" when "010",-------sin(675) 	* 1024 = -0.707 * 1024 = -724
			x"0000" when "011",-------sin(900) 	* 1024 = 0 * 1024 = 0
			x"02d4" when "100",-------sin(1125) * 1024 = 0.707 * 1024 = 724
			x"fc00" when "101",-------sin(1350) * 1024 = -1 *1024 = -1024
			x"02d4" when "110",-------sin(1575) * 1024 = 0.707 * 1024 = 724
			x"0000" when "111",-------sin(1800) * 1024 = 0*1024 = 0			
			x"fd2c" when others;------sin(225)  * 1024 = -0.707 * 1024 = -724			
			
i_mul_d		<= std_logic_vector(signed(i_in_q) * signed(i_mul_lut_q));
q_mul_d		<= std_logic_vector(signed(q_in_q) * signed(q_mul_lut_q));

i_out_d		<=	("01" & x"fff") when i_mul_q(29) = '0' and i_mul_q(28 downto 23) /= "000000" else
					("10" & x"000") when i_mul_q(29) = '1' and i_mul_q(28 downto 23) /= "111111" else
					i_mul_q(23 downto 10);-------dividing by 1024
q_out_d		<=	("01" & x"fff") when q_mul_q(29) = '0' and q_mul_q(28 downto 23) /= "000000" else
					("10" & x"000") when q_mul_q(29) = '1' and q_mul_q(28 downto 23) /= "111111" else
					q_mul_q(23 downto 10);-------dividing by 1024
				
iq_add_d		<= (i_out_q(13) & i_out_q) + (q_out_q(13) & q_out_q);
				
d_out_d		<= ("01" & x"fff") when iq_add_q(14) = '0' and iq_add_q(13) = '1' else
					("10" & x"000") when iq_add_q(14) = '1' and iq_add_q(13) = '0' else
					iq_add_q(13 downto 0);
d_tx_d		<= ("10" & x"000") when tx_en = '0' else (d_out_q(13) & d_out_q(12 downto 0));------2's complement to straight binary
d_out			<= d_tx_q;

iq_count_d	<= iq_count_q + '1';

process(clock,reset)
begin
	if (reset = '0') then
		iq_count_q	<= (others 	=>	'0');
		i_in_q		<=	(others 	=> '0');
		q_in_q		<=	(others	=> '0');
		i_mul_q		<= (others	=> '0');
		q_mul_q		<= (others 	=> '0');
		i_mul_lut_q	<=	(others	=>	'0');
		q_mul_lut_q	<=	(others	=>	'0');
		i_out_q		<=	(others 	=> '0');
		q_out_q		<=	(others	=> '0');
		iq_add_q		<= (others 	=>	'0');
		d_out_q		<=	(others	=>	'0');
		d_tx_q		<= (others	=> '0');
	elsif rising_edge(clock) then
		iq_count_q	<=	iq_count_d;
		i_in_q		<=	i_in_d;
		q_in_q		<=	q_in_d;
		i_mul_q		<=	i_mul_d;
		q_mul_q		<=	q_mul_d;
		i_mul_lut_q	<=	i_mul_lut_d;
		q_mul_lut_q	<=	q_mul_lut_d;
		i_out_q		<= i_out_d;
		q_out_q		<=	q_out_d;
		iq_add_q		<=	iq_add_d;
		d_out_q		<= d_out_d;
		d_tx_q		<= d_tx_d;
	end if;
end process;	
	
end architecture behavior;	
