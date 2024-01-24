library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity harv_trig_delay is
	port(clock	:	in std_logic;
			reset	:	in std_logic;
			strobe	:	in std_logic;
			takei	:	in std_logic;
			trgd	:	in	std_logic_vector(15 downto 0);
			takeo	:	out std_logic
			);
end entity harv_trig_delay;
architecture behavior of harv_trig_delay is

type reg_record is record
takei		:	std_logic_vector(1 downto 0);
trgd		:	integer range 0 to 2**28-1;
trgd_cnt	:	integer range 0 to 2**28-1;
takeo		:	std_logic;
end record reg_record;
signal d,q			:	reg_record;
begin


d.takei(0)	<=	takei;
d.takei(1)	<=	q.takei(0);

d.trgd			<=	to_integer(unsigned(trgd&x"000"));
d.trgd_cnt		<=	0 when q.trgd_cnt = q.trgd - 1 and q.trgd /= 0 else
						q.trgd_cnt + 1 when q.takei(0) = '0' and q.takei(1) = '1' and q.trgd_cnt = 0 else
						q.trgd_cnt + 1 when q.trgd_cnt /= 0 and q.trgd_cnt < q.trgd else
						q.trgd_cnt;
						
--d.takeo			<=	'1' when q.takei(1) = '1' or (q.takei(1) = '0' and q.trgd_cnt /= 0) else '0';
d.takeo			<=	'1' when q.takei(1) = '1' or (q.takei(1) = '0' and q.trgd_cnt /= 0) else '0';
takeo				<=	q.takeo;

process(clock, reset)
begin
	if(reset = '0') then
		q.takei		<=	"00";
		q.trgd		<=	0;
		q.trgd_cnt	<=	0;
		q.takeo		<=	'0';
	elsif(rising_edge(clock)) then
		if(strobe = '1') then
			q			<=	d;
		end if;
	end if;
end process;

end architecture behavior;			