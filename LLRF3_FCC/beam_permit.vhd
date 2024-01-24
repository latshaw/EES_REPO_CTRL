--------------beam permit signal--------------------------------------
--------------beam should only be permitted in SELAP(maglp = "10" and phslp = "10" when amplitude and phase are stable------
--------------limits are defined as 1000 counts for amlitude and 0.5 degree for phase---------
--------------if amplitude and phase are outside these limits, beam permit will be '0'--------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity beam_permit is
	port(clock		:	in	std_logic;
			reset		:	in	std_logic;
			strobe	:	in	std_logic;
			
			xystat	:	in	std_logic_vector(3 downto 0);
			maglp		:	in	std_logic_vector(1 downto 0);
			phslp		:	in	std_logic_vector(1 downto 0);
			clmptm		:	in	std_logic_vector(17 downto 0);
			flt_clr		:	in	std_logic;
			
			beam_fsd	:	out std_logic_vector(1 downto 0)-------[1]latched,[0]present
			);
end entity beam_permit;
architecture behavior of beam_permit is
type reg_record is record
xystat			:	std_logic_vector(3 downto 0);
maglp			:	std_logic_vector(1 downto 0);
phslp			:	std_logic_vector(1 downto 0);
flt_clr			:	std_logic;
beam_fsd		:	std_logic_vector(1 downto 0);
clmptm			:	integer range 0 to 2**26-1;
fsd_cnt			:	integer range 0 to 2**26-1;
end record reg_record;
signal d,q		:	reg_record;
begin
	

d.maglp		<=	maglp;
d.phslp		<=	phslp;
d.flt_clr	<=	flt_clr;
d.xystat	<=	xystat;

d.clmptm	<=	to_integer(unsigned(clmptm(15 downto 0)&x"00"&"00"));	
	
d.beam_fsd(0)	<=	q.xystat(0) or q.xystat(1) or q.xystat(2) or q.xystat(3);
d.fsd_cnt		<=	0 when q.beam_fsd(0) = '0' else
					q.fsd_cnt + 1 when q.beam_fsd(0) = '1' and q.fsd_cnt /= q.clmptm else
					q.fsd_cnt;
	
					
d.beam_fsd(1)	<=	'0' when (q.fsd_cnt = q.clmptm) or (q.maglp /= "10") or (q.phslp /= "10") else
						'1' when q.flt_clr = '1' else					
						q.beam_fsd(1);
					
beam_fsd		<=	q.beam_fsd;
process(clock, reset)
begin
	if(reset = '0') then		
		q.maglp			<=	(others	=>	'0');
		q.phslp			<=	(others	=>	'0');
		q.flt_clr		<=	'0';
		q.xystat		<=	(others	=>	'1');
		q.beam_fsd		<=	"00";
		q.fsd_cnt		<=	0;
		q.clmptm		<=	0;
	elsif(rising_edge(clock)) then
		if(strobe = '1') then
			q			<=	d;
		end if;
	end if;
end process;
end architecture behavior;			