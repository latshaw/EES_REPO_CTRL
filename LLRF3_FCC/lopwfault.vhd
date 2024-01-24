library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lopwfault is
	port(clock	:	in std_logic;
			reset	:	in std_logic;
			strobe	:	in std_logic;			
			lopw	:	in	std_logic_vector(15 downto 0);
			lopwth	:	in	std_logic_vector(15 downto 0);
			lopwtmr	:	in	std_logic_vector(15 downto 0);
			fltclr	:	in	std_logic;
			lopwmsk	:	in	std_logic;
			lopwstat	:	out std_logic_vector(1 downto 0)-----(0) present, (1) latched
			);
end entity lopwfault;
architecture behavior of lopwfault is

type reg_record is record

lopw_2c	:	std_logic_vector(15 downto 0);
lopw		:	unsigned(15 downto 0);
lopwth	:	unsigned(15 downto 0);
lopwtmr	:	integer range 0 to 2**26-1;
lopwcnt	:	integer range 0 to 2**26-1;
fltclr	:	std_logic;
lopwmsk	:	std_logic;
lopwstat	:	std_logic_vector(1 downto 0);
end record reg_record;
signal d,q			:	reg_record;
signal lopw_2c		:	std_logic_vector(15 downto 0);
begin

d.lopw_2c		<=	lopw(15) & lopw(14 downto 0);

d.lopw		<=	unsigned(q.lopw_2c);
d.lopwth	<=	unsigned(lopwth);
d.lopwtmr	<=	to_integer(unsigned(lopwtmr&x"00"&"00"));
d.fltclr		<=	fltclr;
d.lopwmsk	<=	lopwmsk;

process(clock, reset)
begin
	if(reset = '0') then
		q.lopw_2c	<=	(others	=>	'0');
		q.lopw		<=	(others	=>	'0');
		q.lopwth		<=	(others	=>	'0');
		q.lopwtmr	<=	0;
		q.lopwcnt	<=	0;
		q.fltclr		<=	'0';
		q.lopwmsk	<=	'0';
		q.lopwstat	<=	"00";
	elsif(rising_edge(clock)) then
		if (strobe = '1') then
			q				<=	d;
		end if;	
	end if;
end process;

d.lopwcnt	<=	0 when (q.lopw > q.lopwth) else
					q.lopwcnt + 1 when  q.lopw < q.lopwth and q.lopwcnt /= q.lopwtmr else
					q.lopwcnt;
					
d.lopwstat(0)	<=	'1' when q.lopwcnt = q.lopwtmr and q.lopwmsk = '0' else '0';
d.lopwstat(1)	<=	'1' when q.lopwstat(0) = '1' else
						'0' when q.fltclr = '1' else
						q.lopwstat(1);

lopwstat			<=	q.lopwstat;						
		




end architecture behavior;			
			
			