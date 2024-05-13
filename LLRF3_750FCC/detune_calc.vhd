library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity detune_calc is
	port(reset		:	in std_logic;
			clock		:	in std_logic;
			load		:	in std_logic;
			prbphs	:	in std_logic_vector(17 downto 0);
			fwdphs	:	in std_logic_vector(17 downto 0);
			tdoff		:	in std_logic_vector(17 downto 0);
			dtnerr	:	out std_logic_vector(17 downto 0);
			detune	:	out std_logic_vector(17 downto 0);
			cfqea		:	out std_logic_vector(17 downto 0)
			);
end entity detune_calc;
architecture behavior of detune_calc is
type reg_record is record
prb		:	std_logic_vector(17 downto 0);
fwd		:	std_logic_vector(17 downto 0);
cfqe		:	std_logic_vector(17 downto 0);
deta		:	std_logic_vector(17 downto 0);
end record reg_record;
signal d,q	:	reg_record;
begin
d.prb				<=	prbphs;
d.fwd				<=	fwdphs;
d.cfqe			<=	std_logic_vector(unsigned(fwdphs) - unsigned(prbphs)) when load = '1' else
						q.cfqe;
d.deta			<=	std_logic_vector(unsigned(fwdphs) - unsigned(prbphs) - unsigned(tdoff)) when load = '1' else
						q.deta;			
process(clock, reset)
begin
	if(reset = '0') then
		q.prb		<=	(others	=>	'0');
		q.fwd		<=	(others	=>	'0');
		q.cfqe	<=	(others	=>	'0');
		q.deta	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		q			<=	d;
	end if;
end process;	
dtnerr	<=	q.deta;
cfqea		<=	q.cfqe;
detune	<=	q.deta;

end architecture behavior;			