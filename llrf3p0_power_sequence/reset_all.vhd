library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_init is
	port(clock	: in std_logic;
			reset	: in std_logic;
			
			reset_out	: out std_logic
			);
end entity reset_init;

architecture behavior of reset_init is

signal rst_cnt_d, rst_cnt_q	:	unsigned(15 downto 0);
signal rst_out_d, rst_out_q	:	std_logic;

begin


rst_cnt_d	<=	rst_cnt_q + 1 when rst_cnt_q /= x"FFFF" else
					rst_cnt_q;
					
rst_out_d	<=	'0' when rst_cnt_q /= x"FFFF" else '1';

reset_out	<=	rst_out_q;


process(clock, reset)
begin
		if(reset = '0') then
			rst_cnt_q	<=	(others	=>	'0');	
			rst_out_q	<=	'0';
		elsif(rising_edge(clock)) then
			rst_cnt_q	<=	rst_cnt_d;
			rst_out_q	<=	rst_out_d;
		end if;
end process;

end architecture behavior;		