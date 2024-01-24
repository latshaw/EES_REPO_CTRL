library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib_ctl is
	port(clock		:	in std_logic;
			reset		:	in std_logic;
			rfon		:	in std_logic;
			gmesflt	:	in std_logic;
			fibin		:	in std_logic_vector(1 downto 0);---[1]interlock prmt in, [0] hpa prmt in
			fibmski	:	in std_logic_vector(1 downto 0);
			fibseto	:	in std_logic_vector(1 downto 0);
			fltclr	:	in std_logic;
			rfprmt	:	out std_logic;
			fibstat	:	out std_logic_vector(3 downto 0);---[3]intlk latch,[2]hpa latch,[1]intlk inst,[0]hpa inst 
			fibout	:	out std_logic_vector(1 downto 0)---[1] fsd to interlocks, [0] hpa prmt out
			);
end entity fib_ctl;
architecture behavior of fib_ctl is
type reg_record is record
fib_cnt_hpa			:	integer range 0 to 127;
fib_cnt_int			:	integer range 0 to 127;
fib_hpa				:	std_logic_vector(2 downto 0);
fib_int				:	std_logic_vector(2 downto 0);
fib_stat				:	std_logic_vector(1 downto 0);
cnt_5MHz				:	integer range 0 to 19;
fltclr				:	std_logic_vector(1 downto 0);
rf_on					:	std_logic;
gmesflt				:	std_logic;
fib_inst				:	std_logic_vector(1 downto 0);
fibout				:	std_logic_vector(1 downto 0);
end record reg_record;
signal d,q			:	reg_record;
signal sig_5MHz	:	std_logic;
begin
d.fib_hpa(0)				<=	fibin(0);
d.fib_hpa(2 downto 1)	<=	q.fib_hpa(1 downto 0);
d.fib_int(0)				<=	fibin(1);
d.fib_int(2 downto 1)	<=	q.fib_int(1 downto 0);
rfprmt						<=	q.rf_on;
fibstat						<=	q.fib_stat&q.fib_inst;
d.fltclr						<=	q.fltclr(0)&fltclr;
d.gmesflt					<=	gmesflt;		
process(clock, reset)
begin
	if(reset = '0') then
		q.fib_cnt_hpa	<=	0;
		q.fib_cnt_int	<=	0;
		q.fib_hpa		<=	(others	=>	'0');
		q.fib_int		<=	(others	=>	'0');
		q.rf_on			<=	'0';
		q.gmesflt		<=	'1';
		q.cnt_5MHz		<=	0;
		q.fib_stat		<=	"00";
		q.fltclr			<=	"00";
		q.fib_inst		<=	"00";
		q.fibout			<=	"00";
	elsif(rising_edge(clock)) then
		q					<=	d;
	end if;
end process;
sig_5MHz				<=	'1' when q.cnt_5MHz < 10 else '0'; 
d.cnt_5MHz			<=	0 when q.cnt_5MHz = 19 else q.cnt_5MHz + 1;
d.fib_cnt_hpa		<=	0 when fibmski(0) = '1' or q.fltclr(0) = '1' or (q.fib_hpa(1) = '1' and q.fib_hpa(2) = '0') else
							q.fib_cnt_hpa + 1 when q.fib_cnt_hpa /= 99 else
							q.fib_cnt_hpa;	
d.fib_cnt_int		<=	0 when fibmski(1) = '1' or q.fltclr(0) = '1' or (q.fib_int(1) = '1' and q.fib_int(2) = '0') else
							q.fib_cnt_int + 1 when q.fib_cnt_int /= 99 else
							q.fib_cnt_int;
d.rf_on				<=	'1' when q.fib_cnt_hpa /= 99 and q.fib_cnt_int /= 99 else '0';
d.fib_inst(0)		<=	'1' when q.fib_cnt_hpa = 99 else '0';
d.fib_inst(1)		<=	'1' when q.fib_cnt_int = 99 else '0';
d.fib_stat(0)		<=	'1' when q.fib_cnt_hpa = 99 else
							'0' when q.fltclr(1) = '1' else							
							q.fib_stat(0);
d.fib_stat(1)		<=	'1' when q.fib_cnt_int = 99 else
							'0' when q.fltclr(1) = '1' else							
							q.fib_stat(1);							
d.fibout(0)			<=	not q.gmesflt and sig_5MHz;----to hpa							
--fibout(1)			<=	(rfon or fibseto(1)) and sig_5MHz and not q.xystat(0) and not q.xystat(1) and not q.xystat(2) and not q.xystat(3);----to interlocks
d.fibout(1)			<=	(rfon or fibseto(1)) and sig_5MHz;----to interlocks
fibout				<=	q.fibout;


end architecture behavior;			