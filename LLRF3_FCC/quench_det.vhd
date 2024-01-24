library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity quench_det is
port(clock		:	in std_logic;
		reset		:	in std_logic;
		strobe	:	in std_logic;
		prbm		:	in std_logic_vector(17 downto 0);
		qmsk		:	in std_logic;
		flt_clr	:	in std_logic;
		qslope	:	in std_logic_vector(17 downto 0);
		qrate		:	in std_logic_vector(17 downto 0);
		qdiff		:	out std_logic_vector(17 downto 0);
		qstat		:	out std_logic_vector---------[0] present, [1] latched
		);
end entity quench_det;
architecture behavior of quench_det is
signal qslope_buf		:	std_logic_vector(17 downto 0);
signal prbm_buf		:	std_logic_vector(17 downto 0);
signal tmr_d,tmr		:	std_logic_vector(17 downto 0);
signal tmr_valid		:	std_logic;
signal qrate_buf		:	std_logic_vector(17 downto 0);
signal qvalid			:	std_logic;
signal qflt_d,qflt	:	std_logic;	
type reg3_18 is array(2 downto 0) of std_logic_vector(18 downto 0);
signal diff_d, diff_q	:	reg3_18;
signal diff_out			:	std_logic_vector(17 downto 0);
signal diff_out_d, diff_out_q	:	std_logic_vector(17 downto 0);
signal flt_clr_q		:	std_logic;
begin

tmr_valid	<=	'1' when qrate_buf /= "00" & x"0000" and tmr = qrate_buf else '0';

tmr_d		<=	(others	=>	'0') when tmr_valid = '1' else
				std_logic_vector(unsigned(tmr) + 1) when qrate_buf /= "00" & x"0000" else
				tmr;
diff_d(0)				<=	'0'&prbm_buf when tmr_valid = '1' else diff_q(0);
diff_d(1)	<=	diff_q(0) when tmr_valid = '1' else diff_q(1);
diff_d(2)				<=	std_logic_vector(signed(diff_q(1)) - signed(diff_q(0)));--------subtract present from old

diff_out				<=	"01"&x"ffff" when diff_q(2)(18 downto 17) = "01" else
								"10"&x"0000" when diff_q(2)(18 downto 17) = "10" else
								diff_q(2)(17 downto 0);
								
diff_out_d				<=	diff_out when tmr_valid = '1' else diff_out_q;								
								
qdiff						<=	diff_out_q;								
qvalid					<=	'1' when tmr_valid = '1' and diff_out_q(17) = qslope_buf(17) and diff_out_q > qslope_buf and qmsk = '0' else '0';
qstat(0)						<=	qvalid;
qstat(1)					<=	qflt;					
				
qflt_d					<=	'0' when flt_clr_q = '1' else
								'1' when qvalid = '1' else
								qflt;
								
process(clock, reset)
begin
	if(reset = '0') then
		qslope_buf	<=	(others	=>	'0');
		qrate_buf	<=	(others	=>	'0');
		prbm_buf	<=	(others	=>	'0');	
		tmr			<=	(others	=>	'0');
		diff_q		<=	(others	=>	(others	=>	'0'));
		diff_out_q	<=	(others	=>	'0');
		qflt			<=	'0';
		flt_clr_q	<=	'0';
	elsif(rising_edge(clock)) then
		flt_clr_q	<=	flt_clr;	
		if(strobe = '1') then
			qrate_buf	<=	qrate;
			qslope_buf	<=	qslope;
			prbm_buf	<=	prbm;
			tmr			<=	tmr_d;
			diff_q		<=	diff_d;
			diff_out_q	<=	diff_out_d;
			qflt			<=	qflt_d;
		end if;
	end if;
end process;	


end architecture behavior;		