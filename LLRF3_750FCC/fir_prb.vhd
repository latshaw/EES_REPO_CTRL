library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_prb is
	port(reset	:	in std_logic;
		clock	:	in std_logic;
		load	:	in std_logic;
		d_in	:	in std_logic_vector(17 downto 0);
		d_out	:	out std_logic_vector(17 downto 0)
		);
end entity fir_prb;
architecture behavior of fir_prb is
type fir_coef is array(27 downto 0) of integer range 0 to 255;
constant fir_coef1	:	fir_coef	:=	(153, 152, 149, 146, 141, 136, 129, 122, 114, 106, 98, 89, 81, 72, 64, 56, 48, 41, 34, 28, 23, 19, 14, 11, 8, 6, 4, 4);
type fir_reg_data is array(55 downto 0) of std_logic_vector(18 downto 0);
type fir_add_data is array(27 downto 0) of std_logic_vector(18 downto 0);
type fir_mul_data is array(27 downto 0) of std_logic_vector(27 downto 0);
type fir_add_pipe_data is array(9 downto 0) of std_logic_vector(33 downto 0);
type reg_record is record
fir_reg			:	fir_reg_data;
fir_add			:	fir_add_data;
fir_mul			:	fir_mul_data;
fir_add_pipe	:	fir_add_pipe_data;	
data_out	:	std_logic_vector(17 downto 0);
end record reg_record;

signal d,q		:	reg_record;
begin
d.fir_reg(0)(18)			<=	d_in(17);
d.fir_reg(0)(17 downto 0)	<=	d_in;
d.fir_reg(55 downto 1)		<=	q.fir_reg(54 downto 0);
fir_add_gen_i: for i in 0 to 27 generate
	d.fir_add(i)	<=	std_logic_vector(signed(q.fir_reg(i)) + signed(q.fir_reg(55-i)));
end generate;
fir_mul_gen_i: for i in 0 to 27 generate
	d.fir_mul(i)	<=	std_logic_vector(signed(q.fir_add(i))*(to_signed(fir_coef1(i),9)));
end generate;

fir_add_mul_gen_i: for i in 0 to 6 generate
	d.fir_add_pipe(i)	<=	std_logic_vector(signed(resize(signed(q.fir_mul(i*4)),34)) + signed(resize(signed(q.fir_mul(i*4+1)),34)) + signed(resize(signed(q.fir_mul(i*4+2)),34)) + signed(resize(signed(q.fir_mul(i*4+3)),34))); 
end generate;
d.fir_add_pipe(7)	<=	std_logic_vector(signed(q.fir_add_pipe(0)) + signed(q.fir_add_pipe(1)) + signed(q.fir_add_pipe(2)) + signed(q.fir_add_pipe(3)));
d.fir_add_pipe(8)	<=	std_logic_vector(signed(q.fir_add_pipe(4)) + signed(q.fir_add_pipe(5)) + signed(q.fir_add_pipe(6)));
d.fir_add_pipe(9)	<=	std_logic_vector(signed(q.fir_add_pipe(7)) + signed(q.fir_add_pipe(8)));

d.data_out			<=	"01"&x"ffff" when q.fir_add_pipe(9)(33) = '0' and q.fir_add_pipe(9)(32 downto 29) /=  x"0" else
						"10"&x"0000" when q.fir_add_pipe(9)(33) = '1' and q.fir_add_pipe(9)(32 downto 29) /=  x"f" else
						q.fir_add_pipe(9)(29 downto 12);
d_out				<=	q.data_out;							
process(clock, reset)
begin
	if(reset = '0') then
		q.fir_reg	<=	(others	=>	(others	=>	'0'));
		q.fir_add	<=	(others	=>	(others	=>	'0'));
		q.fir_mul	<=	(others	=>	(others	=>	'0'));
		q.data_out	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			q	<=	d;
		end if;
	end if;
end process;	
	
	
end architecture behavior;	