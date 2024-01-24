library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity digio_test is
	port(clock	:	in std_logic;
			reset	:	in std_Logic;
			
			dig_in	:	in std_Logic_vector(18 downto 0);
			dig_out	:	out std_logic_vector(18 downto 0);
			dig_tst	:	out std_logic
			);
end entity digio_test;
architecture behavior of digio_test is
signal test_cnt_d, test_cnt_q		:	std_logic_vector(18 downto 0);
signal dig_tst_d						:	std_logic;
signal dig_in_q						:	std_logic_vector(18 downto 0);
begin
test_cnt_d	<=	std_logic_vector(unsigned(test_cnt_q) + 1);
dig_tst_d	<=	'1' when dig_in_q	= ("010"&x"aaaa") or dig_in_q = ("101"&x"5555")	else '0';
process(clock, reset)
begin
	if(reset	=	'0') then
		dig_out		<=	(others	=>	'0');
		dig_in_q		<=	(others	=>	'0');
		test_cnt_q	<=	(others	=>	'0');
		dig_tst		<=	'0';
	elsif(rising_edge(clock)) then
		dig_out		<=	test_cnt_q;
		dig_in_q		<=	dig_in;
		test_cnt_q	<=	test_cnt_d;
		dig_tst		<=	dig_tst_d;
	end if;
end process;
end architecture behavior;	