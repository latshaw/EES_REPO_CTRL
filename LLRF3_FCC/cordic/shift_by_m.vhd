-------------shift by m number of bits-------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity shift_by_m is
	generic(n : integer := 26);
	port(d_in	: in std_logic_vector(n-1 downto 0);
		 m 		: in	 integer range 0 to 25;
		 d_out	: out std_logic_vector(n-1 downto 0)
		  );
end entity shift_by_m;
architecture behavior of shift_by_m is
begin
with m select
	d_out		<=	d_in when 0,
					d_in(25)&d_in(25 downto 1) when 1,
					d_in(25)&d_in(25)&d_in(25 downto 2) when 2,
					d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 3) when 3,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 4) when 4,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 5) when 5,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 6) when 6,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 7) when 7,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 8) when 8,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 9) when 9,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 10) when 10,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 11) when 11,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 12) when 12,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 13) when 13,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 14) when 14,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 15) when 15,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 16) when 16,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 17) when 17,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 18) when 18,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 19) when 19,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 20) when 20,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 21) when 21,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 22) when 22,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 23) when 23,
					d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25)&d_in(25 downto 24) when 24,
					(others	=>	'0') when others;					
--process(m, d_in)
--begin
--		if m = 0 then
--			d_out <= d_in;
--		elsif (m = n or m > n) then
--			d_out <= (others => '0');			
--		elsif m = 1 then 
--			d_out(n-1)<= d_in(n-1);
--			d_out(n-2 downto 0) 	<= d_in(n-1 downto 1);
--		else
--			d_out(n-1 downto n-m) 	<= (others => d_in(n-1));
--			d_out(n-m-1 downto 0)	<= d_in(n-1 downto m);
--		end if;
--end process;
end architecture behavior; 
----------------end of shift by m number of bits-----------------------