library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity var_attn is
	port(clock	:	in std_logic;
		reset	:	in std_logic;
		d_in	:	in std_logic_vector(5 downto 0);
		
		sclk	:	out std_logic;
		le		:	out std_logic;
		sdata	:	out std_logic
		);
end entity var_attn;
architecture behavior of var_attn is

type reg_record is record
sclk_reg	:	std_logic_vector(19 downto 0);
le_reg		:	std_logic_vector(19 downto 0);
sdata_reg	:	std_logic_vector(19 downto 0);
din_reg		:	std_logic_vector(5 downto 0);
bit_cnt		:	integer range 0 to 20;
end record reg_record;
signal clk_count_d, clk_count_q		:	unsigned(6 downto 0);
signal d,q	:	reg_record;										 
signal attn_data	:	std_logic_vector(11 downto 0);

begin
sclk		<=	q.sclk_reg(19);
le			<=	q.le_reg(19);
sdata		<=	q.sdata_reg(19);
clk_count_d	<=	clk_count_q + 1;
	
process(clock, reset)
begin
	if(reset = '0') then
		clk_count_q	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		clk_count_q	<=	clk_count_d;
	end if;
end process;
process(clk_count_q(6), reset)
begin
	if(reset = '0') then
		q.sclk_reg	<=	(others	=>	'0');
		q.le_reg	<=	(others	=>	'0');
		q.sdata_reg	<=	(others	=>	'0');
		q.din_reg	<=	(others	=>	'0');
		q.bit_cnt	<=	0;
	elsif(rising_edge(clk_count_q(6))) then
		q			<=	d;
	end if;
end process;

attn_data	<=	q.din_reg(5)&q.din_reg(5)&q.din_reg(4)&q.din_reg(4)&q.din_reg(3)&q.din_reg(3)&q.din_reg(2)&q.din_reg(2)&q.din_reg(1)&q.din_reg(1)&q.din_reg(0)&q.din_reg(0);

d.sclk_reg	<=	"00001010101010100000" when q.bit_cnt = 1 else 
				q.sclk_reg(18 downto 0)&'0' when q.bit_cnt < 20 else
				q.sclk_reg;
d.le_reg	<=	"00000000000000001000" when q.bit_cnt = 1 else 
				q.le_reg(18 downto 0)&'0' when q.bit_cnt < 20 else
				q.le_reg;
d.sdata_reg	<=	"000"&attn_data &"00000" when q.bit_cnt = 1 else 
				q.sdata_reg(18 downto 0)&'0' when q.bit_cnt < 20 else
				q.sdata_reg;
d.din_reg	<=	d_in when q.bit_cnt = 20 else
				q.din_reg;
d.bit_cnt	<=	q.bit_cnt + 1 when q.bit_cnt /= 20 else
				0 when q.bit_cnt = 20 and q.din_reg /= d.din_reg else
				q.bit_cnt;	
end architecture behavior;