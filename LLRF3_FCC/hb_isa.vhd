library ieee;
use ieee.std_logic_1164.all;

entity hb_isa is
	port(clock	:	in	std_logic;
			reset	:	in	std_logic;
			
			hrtbt	:	out std_logic
			);
end entity hb_isa;
architecture behavior of hb_isa is
type reg_record is record
cnt			:	integer range 0 to 2**28-1;
hb				:	std_logic;
hrtbt			:	std_logic;
end record reg_record;			
signal d, q		:	reg_record;
begin			

d.cnt			<=	0 when q.cnt = 186999999 else 
					q.cnt + 1;
d.hb			<=	not q.hb when q.cnt = 0 else q.hb;
d.hrtbt		<=	q.hb;
hrtbt			<=	q.hrtbt;

process(clock, reset)
begin
	if(reset = '0') then
		q.cnt		<=	0;
		q.hb		<=	'0';
		q.hrtbt	<=	'0';
	elsif(rising_edge(clock)) then
		q			<=	d;
	end if;
end process;
end architecture behavior;	