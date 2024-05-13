library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity firn is
	port(clock	:	in std_logic;
		reset	:	in std_logic;
		ld_in	:	in std_logic;
		d_in	:	in std_logic_vector(17 downto 0);
		d_out	:	out std_logic_vector(17 downto 0);
		ld_out	:	out std_logic
		);
end entity firn;
architecture behavior of firn is
type reg33_18 is array(32 downto 0) of signed(17 downto 0);
type reg17_19 is array(16 downto 0) of signed(18 downto 0);
type reg17_29 is array(16 downto 0) of signed(28 downto 0);
type reg17_34 is array(16 downto 0) of signed(33 downto 0);
type reg6_34 is array(5 downto 0) of signed(33 downto 0);
type reg2_34 is array(1 downto 0) of signed(33 downto 0);
type reg_record is record
delay_reg		:	reg33_18;	
add_reg			:	reg17_19;
mul_reg			:	reg17_29;
mul_reg_ext		:	reg17_34;
mul_add_reg		:	reg6_34;
result_add_reg	:	reg2_34;
result_add		:	signed(33 downto 0);
gain_mul			:	signed(44 downto 0);
d_out			:	signed(17 downto 0);
ld_out			:	std_logic;
end record reg_record;
signal d,q		:	reg_record;
--signal delay_reg_d, delay_reg_q				:	reg33_18;
--signal add_reg_d, add_reg_q					:	reg17_19;
--signal mul_reg_d, mul_reg_q					:	reg17_29;
--signal mul_reg_ext_d, mul_reg_ext_q			:	reg17_34;
--signal mul_add_reg_d, mul_add_reg_q			:	reg6_34;
--signal result_add_reg_d, result_add_reg_q	:	reg2_34;
--signal result_add_d,result_add_q			:	std_logic_vector(33 downto 0);
--signal d_out_d								:	std_logic_vector(17 downto 0);

type reg17_10 is array(16 downto 0) of signed(9 downto 0);
constant fir_coeff	:	reg17_10	:=	("00" & X"02", "00" & X"04", "00" & X"08", "00" & X"0D", "00" & X"18", "00" & X"27", "00" & X"3A",
										"00" & X"51", "00" & X"6D", "00" & X"8B", "00" & X"AB", "00" & X"CA", "00" & X"E7", "01" & X"00",
										"01" & X"14", "01" & X"20", "01" & X"24");
constant fir_gain		:	signed(10 downto 0) := "011" & x"bd";--------taking out the gain of 1.07										
begin
d.ld_out			<=	ld_in;
ld_out				<=	q.ld_out;
d.delay_reg(0)		<=	signed(d_in) when ld_in = '1' else q.delay_reg(0);	
delay_reg_gen_i:for i in 1 to 32 generate
d.delay_reg(i)		<=	q.delay_reg(i-1) when ld_in = '1' else q.delay_reg(i);
end generate;
add_reg_gen_i: for i in 0 to 15 generate
d.add_reg(i)		<=	(q.delay_reg(i)(17) & q.delay_reg(i))+(q.delay_reg(32-i)(17) & q.delay_reg(32-i));
end generate;
d.add_reg(16)		<=	q.delay_reg(16)(17) & q.delay_reg(16);
mul_reg_gen_i: for i in 0 to 16 generate
d.mul_reg(i)		<=	fir_coeff(i)*q.add_reg(i) when ld_in = '1' else q.mul_reg(i);
d.mul_reg_ext(i)	<=	(resize(signed(q.mul_reg(i)),34));
end generate;
mul_add_reg_gen_i:for i in 0 to 4 generate
d.mul_add_reg(i)	<=	q.mul_reg_ext(3*i+0)+q.mul_reg_ext(3*i+1)+q.mul_reg_ext(3*i+2);	
end generate;
d.mul_add_reg(5)	<=	q.mul_reg_ext(15)+q.mul_reg_ext(16);
result_add_reg_gen_i: for i in 0 to 1 generate
d.result_add_reg(i)	<=	q.mul_add_reg(3*i+0)+q.mul_add_reg(3*i+1)+q.mul_add_reg(3*i+2);
end generate;
d.result_add		<=	q.result_add_reg(0)+q.result_add_reg(1) when ld_in = '1' else q.result_add;
d.gain_mul			<=	q.result_add * fir_gain;
--d.d_out				<=	"01"&x"ffff" when q.result_add(33) = '0' and q.result_add(32 downto 29) /= x"0" else
--						"10"&x"0000" when q.result_add(33) = '1' and q.result_add(32 downto 29) /= x"f" else
--						q.result_add(29 downto 12);
d.d_out				<=	"01"&x"ffff" when q.gain_mul(44) = '0' and q.gain_mul(43 downto 39) /= '0'&x"0" else
						"10"&x"0000" when q.gain_mul(44) = '1' and q.gain_mul(43 downto 39) /= '1'&x"f" else
						q.gain_mul(39 downto 22);						
process(clock, reset)
begin
	if(reset = '0') then
		q.delay_reg			<=	(others	=>(others	=>	'0'));
		q.add_reg			<=	(others	=>(others	=>	'0'));
 		q.mul_reg			<=	(others	=>(others	=>	'0'));
		q.mul_reg_ext		<=	(others	=>(others	=>	'0'));
		q.mul_add_reg		<=	(others	=>(others	=>	'0'));
		q.result_add_reg	<=	(others	=>(others	=>	'0'));
		q.result_add		<=	(others	=>	'0');
		q.d_out				<=	(others	=>	'0');
		q.ld_out				<=	'0';
		q.gain_mul			<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		q					<=	d;
	end if;
end process;
d_out			<=	std_logic_vector(q.d_out);
	
end architecture behavior;	