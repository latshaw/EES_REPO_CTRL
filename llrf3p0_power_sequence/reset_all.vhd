library ieee;
use ieee.std_logic_1164.all;

entity reset_all is
	port(clock	:	in std_logic;
			reset	:	in std_logic;
			c10_reset_in	:	in std_logic;
			
			reset_out	:	out std_logic
			);
end entity reset_all;

architecture behavior of reset_all is


signal reset_q				:	std_logic;
signal c10_reset_d, c10_reset_q	:	std_logic_vector(2 downto 0);
signal reset_out_d, reset_out_q	:	std_logic;

begin



c10_reset_d(0)		<=	c10_reset_in;
c10_reset_d(2 downto 1)	<=	c10_reset_q(1 downto 0);


--reset_out_d		<=	'0' when (c10_reset_q(2) = '1' and c10_reset_q(1) = '0') or reset_q = '0' else '1'; 

reset_out_d		<=	not (c10_reset_q(2) and not c10_reset_q(1) ) or reset_q; 


process(clock)
begin
	if(rising_edge(clock)) then
			reset_q		<=	reset;
			c10_reset_q	<=	c10_reset_q(1 downto 0)&c10_reset_in;
			reset_out_q	<=	reset_out_d;
			reset_out	<=	reset_out_q;
	end if;
end process;


	








end architecture behavior;			