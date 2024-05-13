library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cic is
port(clock			:	in std_logic;
	reset			:	in std_logic;
	strobe_integ	:	in std_logic;
--	strobe_dec		:	in std_logic;
	d_in			:	in std_logic_vector(17 downto 0);
	d_out			:	out std_logic_vector(17 downto 0);
	strobe_out		:	out std_logic
	);
end entity cic;
architecture behavior of cic is
type reg32_3 is array(2 downto 0) of signed(31 downto 0);
type reg32_6 is array(5 downto 0) of signed(31 downto 0);
type reg_record is record
integ_reg	:	reg32_3;
comb_reg	:	reg32_6;
dec_cnt		:	integer range 0 to 3;
dec_reg		:	signed(31 downto 0);
strobe		:	std_logic;
cic_div		:	signed(31 downto 0);
data_out	:	signed(17 downto 0);
end record reg_record;
signal d_in_ext		:	signed(31 downto 0);
signal d,q			:	reg_record;
signal cic_div_out	:	signed(17 downto 0);
signal strobe_dec	:	std_logic;
begin
d.dec_cnt					<=	0 when q.dec_cnt = 3 and strobe_integ = '1'
								else q.dec_cnt + 1 when strobe_integ = '1' else
								q.dec_cnt;
strobe_dec					<=	'1' when q.dec_cnt = 3 else '0';
d_in_ext(31 downto 18)		<=	(others	=>	d_in(17));
d_in_ext(17 downto 0)		<=	signed(d_in);

d.integ_reg(0)		<=	d_in_ext + q.integ_reg(0) when strobe_integ = '1' else q.integ_reg(0);
d.integ_reg(1)		<=	d_in_ext + q.integ_reg(0) + q.integ_reg(1) when strobe_integ = '1' else q.integ_reg(1);
d.integ_reg(2)		<=	d_in_ext + q.integ_reg(0) + q.integ_reg(1) + q.integ_reg(2) when strobe_integ = '1' else q.integ_reg(2);
d.dec_reg			<=	q.integ_reg(2) when strobe_dec = '1' else q.dec_reg;
	
d.comb_reg(0)		<=	q.dec_reg when strobe_dec = '1' else q.comb_reg(0);
d.comb_reg(1)		<=	q.comb_reg(0) when strobe_dec = '1' else q.comb_reg(1);	
d.comb_reg(2)		<=	q.dec_reg - q.comb_reg(1) when strobe_dec = '1' else q.comb_reg(2);
d.comb_reg(3)		<=	q.comb_reg(2) when strobe_dec = '1' else q.comb_reg(3);	
d.comb_reg(4)		<=	q.dec_reg - q.comb_reg(1) - q.comb_reg(3) when strobe_dec = '1' else q.comb_reg(4);
d.comb_reg(5)		<=	q.comb_reg(4) when strobe_dec = '1' else q.comb_reg(5);
	
d.cic_div			<=	q.dec_reg - q.comb_reg(1) - q.comb_reg(3) - q.comb_reg(5) when strobe_dec = '1' else q.cic_div;
cic_div_out			<=	"01"&x"ffff" when q.cic_div(31) = '0' and q.cic_div(30 downto 26) /= "00000" else
						"10"&x"0000" when q.cic_div(31) = '1' and q.cic_div(30 downto 26) /= "11111" else
						q.cic_div(26 downto 9);
d.data_out			<=	cic_div_out when strobe_dec = '1' else q.data_out;
d_out				<=	std_logic_vector(q.data_out);
d.strobe			<=	strobe_dec;
strobe_out			<=	q.strobe;
process(clock, reset)
begin
	if(reset = '0') then
		q.integ_reg		<=	(others	=>	(others	=>	'0'));
		q.comb_reg		<=	(others	=>	(others	=>	'0'));
		q.dec_reg		<=	(others	=>	'0');
		q.strobe		<=	'0';
		q.cic_div		<=	(others	=>	'0');
		q.data_out		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		q				<=	d;
	end if;
end process;	

end architecture behavior;


architecture cic26_2_3 of cic is---(R=26, M=2, N=3)
type reg36_3 is array(2 downto 0) of signed(35 downto 0);
type reg36_6 is array(5 downto 0) of signed(35 downto 0);
type reg_record is record
integ_reg	:	reg36_3;
comb_reg	:	reg36_6;
dec_cnt		:	integer range 0 to 31;
dec_reg		:	signed(35 downto 0);
strobe		:	std_logic;
cic_div		:	signed(35 downto 0);
cic_gain	:	signed(50 downto 0);
data_out	:	signed(17 downto 0);
end record reg_record;
signal d_in_ext		:	signed(35 downto 0);
signal d,q			:	reg_record;
signal cic_div_out	:	signed(17 downto 0);
signal strobe_dec	:	std_logic;
constant cic_gain	:	signed(14 downto 0) := "011"&x"ba9";
begin
d.dec_cnt					<=	0 when q.dec_cnt = 25 and strobe_integ = '1'
								else q.dec_cnt + 1 when strobe_integ = '1' else
								q.dec_cnt;
strobe_dec					<=	'1' when q.dec_cnt = 25 else '0';
d_in_ext					<=	resize(signed(d_in),36);	
--d_in_ext(31 downto 18)		<=	(others	=>	d_in(17));
--d_in_ext(17 downto 0)		<=	signed(d_in);

d.integ_reg(0)		<=	d_in_ext + q.integ_reg(0) when strobe_integ = '1' else q.integ_reg(0);
d.integ_reg(1)		<=	d_in_ext + q.integ_reg(0) + q.integ_reg(1) when strobe_integ = '1' else q.integ_reg(1);
d.integ_reg(2)		<=	d_in_ext + q.integ_reg(0) + q.integ_reg(1) + q.integ_reg(2) when strobe_integ = '1' else q.integ_reg(2);
d.dec_reg			<=	q.integ_reg(2) when strobe_dec = '1' else q.dec_reg;
	
d.comb_reg(0)		<=	q.dec_reg when strobe_dec = '1' else q.comb_reg(0);
d.comb_reg(1)		<=	q.comb_reg(0) when strobe_dec = '1' else q.comb_reg(1);	
d.comb_reg(2)		<=	q.dec_reg - q.comb_reg(1) when strobe_dec = '1' else q.comb_reg(2);
d.comb_reg(3)		<=	q.comb_reg(2) when strobe_dec = '1' else q.comb_reg(3);	
d.comb_reg(4)		<=	q.dec_reg - q.comb_reg(1) - q.comb_reg(3) when strobe_dec = '1' else q.comb_reg(4);
d.comb_reg(5)		<=	q.comb_reg(4) when strobe_dec = '1' else q.comb_reg(5);
	
d.cic_div			<=	q.dec_reg - q.comb_reg(1) - q.comb_reg(3) - q.comb_reg(5) when strobe_dec = '1' else q.cic_div;
d.cic_gain			<=	q.cic_div * cic_gain;	
	
cic_div_out			<=	"01"&x"ffff" when q.cic_gain(50) = '0' and q.cic_gain(49 downto 48) /= "00"else
						"10"&x"0000" when q.cic_gain(50) = '1' and q.cic_gain(49 downto 48) /= "11" else
						q.cic_gain(48 downto 31);
						
						
d.data_out			<=	cic_div_out when strobe_dec = '1' else q.data_out;
d_out				<=	std_logic_vector(q.data_out);
d.strobe			<=	strobe_dec;
strobe_out			<=	q.strobe;
process(clock, reset)
begin
	if(reset = '0') then
		q.integ_reg		<=	(others	=>	(others	=>	'0'));
		q.comb_reg		<=	(others	=>	(others	=>	'0'));
		q.dec_reg		<=	(others	=>	'0');
		q.strobe		<=	'0';
		q.cic_div		<=	(others	=>	'0');
		q.cic_gain		<=	(others	=>	'0');
		q.data_out		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		q				<=	d;
	end if;
end process;	

end architecture cic26_2_3;	
	
		
	
	