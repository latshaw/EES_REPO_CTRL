library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;
use work.all;

entity rdmux8to1 is
	port(clock	:	in std_logic;
		reset		:	in	std_logic;
		data_in	:	in	reg18_8;
		addr_in	:	in std_logic_vector(2 downto 0);
		data_out	:	out std_logic_vector(17 downto 0)
		);
end entity rdmux8to1;
architecture behavior of rdmux8to1 is
signal addr_int	:	integer range 0 to 7;

begin
addr_int	<=	to_integer(unsigned(addr_in));

process(clock, reset)
begin
	if(reset = '0') then
		data_out	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		data_out	<=	data_in(addr_int);
	end if;
end process;	



end architecture;		
		
		