
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iir_lpfk7 is
port(clock 	:   in std_logic;
	  reset :   in std_logic;
	  load	:	in std_logic;
	  d_in	: 	in std_logic_vector(17 downto 0);
      d_out	:	out std_logic_vector(17 downto 0)
	  );	  
end entity iir_lpfk7;
architecture behavior of iir_lpfk7 is

signal d_in_ext			: 	std_logic_vector(34 downto 0);
signal shift    		: 	std_logic_vector(34 downto 0);
signal fltr_d			: 	std_logic_vector(34 downto 0);
signal fltr_q			: 	std_logic_vector(34 downto 0);
signal d_out_d			:	std_logic_vector(17 downto 0);

begin
-- extend the input to 34 bits (bottom 16 are round off bits)
d_in_ext(34 downto 18) 		<= (others => d_in(17));
d_in_ext(17 downto 0)  	<= d_in;

-- shift by k=9
shift(34 downto 28)         <= (others => fltr_q(34));
shift(27 downto 0)          <= fltr_q(34 downto 7);
-- filter equation
fltr_d 		                <= std_logic_vector(signed(fltr_q) - signed(shift) + signed(d_in_ext));
d_out_d                     <=	"01"&x"ffff" when fltr_q(34) = '0' and fltr_q(33 downto 24) /= "00"&x"00" else
											"10"&x"0000" when fltr_q(34) = '1' and fltr_q(33 downto 24) /= "11"&x"ff" else	
											fltr_q(24 downto 7);	
process(clock, reset)
begin
	if(reset =	'0') then
		  fltr_q		<=	(others	=>	'0');
		  d_out		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
		  fltr_q	    <=	fltr_d;
		  d_out			<=	d_out_d;
	   end if;
	end if;
end process;
end architecture behavior;