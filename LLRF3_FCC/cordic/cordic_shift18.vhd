library ieee;
use ieee.std_logic_1164.all;
use work.components.ALL;

entity cordic_shift18 is
port(data_in 	: in reg18_26;
	 data_out	: out reg18_26
	 );
end entity cordic_shift18;

architecture behavior of cordic_shift18 is
begin
data_out(0)(25)					<= data_in(0)(25);
data_out(0)(24 downto 0)		<= data_in(0)(25 downto 1);

data_out(1)(25 downto 24)		<= (others => data_in(1)(25));
data_out(1)(23 downto 0)		<= data_in(1)(25 downto 2);

data_out(2)(25 downto 23)		<= (others => data_in(2)(25));
data_out(2)(22 downto 0)		<= data_in(2)(25 downto 3);

data_out(3)(25 downto 22)		<= (others => data_in(3)(25));
data_out(3)(21 downto 0)		<= data_in(3)(25 downto 4);

data_out(4)(25 downto 21)		<= (others => data_in(4)(25));
data_out(4)(20 downto 0)		<= data_in(4)(25 downto 5);

data_out(5)(25 downto 20)		<= (others => data_in(5)(25));
data_out(5)(19 downto 0)		<= data_in(5)(25 downto 6);

data_out(6)(25 downto 19)		<= (others => data_in(6)(25));
data_out(6)(18 downto 0)		<= data_in(6)(25 downto 7);

data_out(7)(25 downto 18)		<= (others => data_in(7)(25));
data_out(7)(17 downto 0)			<= data_in(7)(25 downto 8);

data_out(8)(25 downto 17)		<= (others => data_in(8)(25));
data_out(8)(16 downto 0)			<= data_in(8)(25 downto 9);

data_out(9)(25 downto 16)		<= (others => data_in(9)(25));
data_out(9)(15 downto 0)			<= data_in(9)(25 downto 10);

data_out(10)(25 downto 15)		<= (others => data_in(10)(25));
data_out(10)(14 downto 0)		<= data_in(10)(25 downto 11);

data_out(11)(25 downto 14)		<= (others => data_in(11)(25));
data_out(11)(13 downto 0)		<= data_in(11)(25 downto 12);

data_out(12)(25 downto 13)		<= (others => data_in(12)(25));
data_out(12)(12 downto 0)		<= data_in(12)(25 downto 13);

data_out(13)(25 downto 12)		<= (others => data_in(13)(25));
data_out(13)(11 downto 0)		<= data_in(13)(25 downto 14);

data_out(14)(25 downto 11)		<= (others => data_in(14)(25));
data_out(14)(10 downto 0)		<= data_in(14)(25 downto 15);

data_out(15)(25 downto 10)		<= (others => data_in(15)(25));
data_out(15)(9 downto 0)		<=	data_in(15)(25 downto 16);

data_out(16)(25 downto 9)		<= (others => data_in(16)(25));
data_out(16)(8 downto 0)		<=	data_in(16)(25 downto 17);

data_out(17)(25 downto 8)		<= (others => data_in(17)(25));
data_out(17)(7 downto 0)		<=	data_in(17)(25 downto 18);
	
end architecture;