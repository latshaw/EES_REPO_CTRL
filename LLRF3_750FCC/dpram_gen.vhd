library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram_gen is
	generic(n	:	integer	:=	12;
				w	:	integer	:=	18);				
	port(wr_clock	:	in std_logic;
		rd_clock		:	in	std_logic;
		wr_addr		:	in std_logic_vector(n-1 downto 0);
		rd_addr		:	in	std_logic_vector(n-1 downto 0);
		data_in		:	in std_logic_vector(w-1 downto 0);
		we				:	in	std_logic;
		data_out		:	out std_logic_vector(w-1 downto 0)
		);
end entity dpram_gen;
architecture behavior of dpram_gen is

type dpram_block is array(0 to 2**n-1) of std_logic_vector(w-1 downto 0);
signal dpram		:	dpram_block;

signal wraddr		:	integer range 0 to 2**n-1;
signal rdaddr		:	integer range 0 to 2**n-1;

begin
wraddr	<=	to_integer(unsigned(wr_addr));
rdaddr	<=	to_integer(unsigned(rd_addr));

process(wr_clock)
begin
	if(rising_edge(wr_clock)) then
		if(we = '1') then
			dpram(wraddr)	<=	data_in;
		end if;
	end if;
end process;	
process(rd_clock)
begin
	if(rising_edge(rd_clock)) then
--		rdaddr	<=	to_integer(unsigned(rd_addr));		
			data_out	<=	dpram(rdaddr);			
	end if;
end process;
--data_out	<=	dpram(rdaddr);	
end architecture behavior;		
		