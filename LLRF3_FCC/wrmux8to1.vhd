library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;
use work.all;

entity wrmux8to1 is
	port(clock	:	in std_logic;
		reset		:	in	std_logic;
		data_in	:	in	std_logic_vector(17 downto 0);
		addr_in	:	in std_logic_vector(6 downto 0);
		strobe		:	in	std_logic;
		strobe_out	:	out std_logic_vector(7 downto 0);
		addr_out		:	out std_logic_vector(6 downto 0);
		data_out	:	out reg18_8
		);
end entity wrmux8to1;
architecture behavior of wrmux8to1 is

type reg_record is record
data					:	reg18_8;
strobe					:	std_logic_vector(7 downto 0);
addr				:	std_logic_vector(6 downto 0);
end record reg_record;

signal d,q			:	reg_record;
signal addr_int	:	integer range 0 to 7;
signal data_int	:	reg18_8;

begin
addr_int	<=	to_integer(unsigned(addr_in(6 downto 4)));
--d.strobe		<=	strobe;
data_int_gen: for i in 0 to 7 generate
	d.data(i)	<=	data_in when strobe = '1' and addr_int = i else q.data(i);
	d.strobe(i)	<=	'1' when strobe = '1' and addr_int = i else '0';
end generate;


d.addr		<=	addr_in;

addr_out		<=	q.addr;
strobe_out	<=	q.strobe;
data_out	<=	q.data;	

process(clock, reset)
begin
	if(reset = '0') then
		q.data	<=	(others	=>	(others	=>	'0'));
		q.strobe		<=	(others	=>	'0');
		q.addr	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		q			<=	d;	
	end if;
end process;





end architecture;		
		
		