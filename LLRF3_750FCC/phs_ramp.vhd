library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity phs_ramp is
	port(clock	:	in std_logic;
		reset	:	in std_logic;
		strobe	:	in std_logic;
		pset	:	in std_logic_vector(17 downto 0);
		prmpr	:	in std_logic_vector(17 downto 0);
		prmp	:	out std_logic_vector(17 downto 0)
		);
end entity phs_ramp;
architecture behavior of phs_ramp is
type reg_record is record
prmpr_cnt	:	unsigned(17 downto 0);
prmpr		:	unsigned(17 downto 0);
prmp		:	signed(17 downto 0);
pset		:	signed(17 downto 0);
end record reg_record;
signal d,q	:	reg_record;
signal prmpr_cnt_en	:	std_logic;
begin
	
d.pset			<=	signed(pset);		
d.prmpr			<=	unsigned(prmpr);
d.prmpr_cnt		<=	(others	=>	'0') when q.prmpr /= ("00"&x"0000") and q.prmpr_cnt = q.prmpr - 1 else
					q.prmpr_cnt + 1 when q.prmpr /= "00"&x"0000" and q.prmpr_cnt /= q.prmpr - 1 else	
					q.prmpr_cnt;
prmpr_cnt_en	<=	'1' when q.prmpr_cnt = q.prmpr - 1 and q.prmpr /= ("00"&x"0000") else '0';					
					
d.prmp			<=	q.prmp + 1 when q.prmp < q.pset and prmpr_cnt_en = '1' else
					q.prmp - 1 when q.prmp > q.pset and prmpr_cnt_en = '1' else
					q.prmp;
					
process(clock, reset)
begin
	if(reset = '0') then
		q.prmpr_cnt		<=	(others	=>	'0');
		q.prmp			<=	(others	=>	'0');
		q.pset			<=	(others	=>	'0');
		q.prmpr			<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(strobe = '1') then
			q				<=	d;
		end if;	
	end if;
end process;

prmp			<=	std_logic_vector(q.prmp);
	
end architecture behavior;	