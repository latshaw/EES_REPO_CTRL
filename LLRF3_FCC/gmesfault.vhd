library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gmesfault is
	port(clock	:	in std_logic;
			reset	:	in std_logic;
			strobe	:	in std_logic;
			rfsw	:	in	std_logic;
			gmes	:	in	std_logic_vector(17 downto 0);
			gmeslvl	:	in	std_logic_vector(17 downto 0);
			gmestmr	:	in	std_logic_vector(15 downto 0);
			fltclr	:	in	std_logic;
			gmesmsk	:	in	std_logic;
			gmesstat	:	out std_logic_vector(1 downto 0)-----(0) present, (1) latched
			);
end entity gmesfault;
architecture behavior of gmesfault is

type reg_record is record
rfsw		:	std_logic;
gmes		:	unsigned(17 downto 0);
gmeslvl	:	unsigned(17 downto 0);
gmestmr	:	integer range 0 to 2**28-1;
gmescnt	:	integer range 0 to 2**28-1;
fltclr	:	std_logic;
gmesstat	:	std_logic_vector(1 downto 0);
end record reg_record;
signal d,q			:	reg_record;
begin

d.rfsw		<=	rfsw;
d.gmes		<=	unsigned(gmes);
d.gmeslvl	<=	unsigned(gmeslvl);
d.gmestmr	<=	to_integer(unsigned(gmestmr&x"000"));
d.fltclr		<=	fltclr;

process(clock, reset)
begin
	if(reset = '0') then
		q.rfsw		<=	'0';
		q.gmes		<=	(others	=>	'0');
		q.gmeslvl	<=	(others	=>	'0');
		q.gmestmr	<=	0;
		q.gmescnt	<=	0;
		q.fltclr		<=	'0';
		q.gmesstat	<=	"00";
	elsif(rising_edge(clock)) then
		if (strobe = '1') then
			q				<=	d;
		end if;	
	end if;
end process;

d.gmescnt	<=	0 when q.rfsw = '1' or (q.rfsw = '0' and q.gmes < q.gmeslvl) else
					q.gmescnt + 1 when q.rfsw = '0' and q.gmes > q.gmeslvl and q.gmescnt /= q.gmestmr else
					q.gmescnt;
					
d.gmesstat(0)	<=	'1' when q.gmescnt = q.gmestmr else '0';
d.gmesstat(1)	<=	'1' when q.gmesstat(0) = '1' else
						'0' when q.fltclr = '1' else
						q.gmesstat(1);

gmesstat			<=	q.gmesstat;						
		




end architecture behavior;			
			
			