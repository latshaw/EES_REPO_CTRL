library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iq2mp_18bit_small is
port(clock		: in std_logic;
	  reset		: in std_logic;
	  i			: in std_logic_vector(17 downto 0);
	  q 		: in std_logic_vector(17 downto 0);	  
	  load		: out std_logic;
	  m			: out std_logic_vector(17 downto 0);-----this has gain of 1.646 as cal tables at the epics level have cordic gain
	  p			: out std_logic_vector(17 downto 0)
	  );	  
end entity iq2mp_18bit_small;

architecture behavior of iq2mp_18bit_small is
--component shift_by_m is
--	generic(n : integer := 18);
--	port(d_in	: in std_logic_vector(n-1 downto 0);
--		 m 		: in	 integer ;
--		 d_out	: out std_logic_vector(n-1 downto 0)
--		  );
--end component shift_by_m;
signal i_extend					: std_logic_vector(25 downto 0);
signal q_extend					: std_logic_vector(25 downto 0);

signal i_init						: std_logic_vector(25 downto 0);
signal i_init1						: std_logic_vector(25 downto 0);
signal i_int						: std_logic_vector(25 downto 0);
signal i_in							: std_logic_vector(25 downto 0);
signal i_out						: std_logic_vector(25 downto 0);

signal q_init						: std_logic_vector(25 downto 0);
signal q_init1						: std_logic_vector(25 downto 0);
signal q_int						: std_logic_vector(25 downto 0);
signal q_in							: std_logic_vector(25 downto 0);
signal q_out						: std_logic_vector(25 downto 0);

signal a_init						: std_logic_vector(25 downto 0);
signal a_init1						: std_logic_vector(25 downto 0);
signal a_int						: std_logic_vector(25 downto 0);
signal a_in							: std_logic_vector(25 downto 0);
signal a_out						: std_logic_vector(25 downto 0);

signal i_div						: std_logic_vector(25 downto 0);
signal q_div						: std_logic_vector(25 downto 0);

signal mag_in						: std_logic_vector(25 downto 0);
signal phs_in						: std_logic_vector(25 downto 0);
signal mag_d, mag_q				:	std_logic_vector(25 downto 0);
signal phs_d, phs_q				:	std_logic_vector(25 downto 0);
constant cordic_gain				:	std_logic_vector(15 downto 0) := x"4dba";
signal mag_mul_d, mag_mul_q	:	std_logic_vector(41 downto 0);
signal mag_out_d, mag_out_q	:	std_logic_vector(17 downto 0);
signal load_d						:	std_logic;

signal en_loop_count				: std_logic;
signal loop_count_d				:	std_logic_vector(4 downto 0);
signal loop_count_q				: std_logic_vector(4 downto 0);
signal y								: integer range 0 to 31; 
type reg18_26 is array(17 downto 0) of std_logic_vector(25 downto 0);
constant b							: reg18_26 	:=	("00"&x"000051",	"00"&x"0000A3",	"00"&x"000146",	"00"&x"00028c",	"00"&x"000518",	"00"&x"000A30",	"00"&x"00145F",	"00"&x"0028BE",	"00"&x"00517D",
															"00"&x"00A2F9", "00"&x"0145F1", "00"&x"028BD8",	"00"&x"05175F",	"00"&x"0A2C35",	"00"&x"144447",	"00"&x"27ECE1",	"00"&x"4B9014",	"00"&x"800000");
begin
	
y	<= to_integer(unsigned (loop_count_q));
process(clock, reset)
begin
	if(reset = '0') then
		loop_count_q	<=	(others	=>	'0');
		i_out				<=	(others	=>	'0');
		q_out				<=	(others	=>	'0');
		a_out				<=	(others	=>	'0');
		mag_mul_q		<=	(others	=>	'0');
		mag_out_q		<=	(others	=>	'0');
		mag_q				<=	(others	=>	'0');
		phs_q				<=	(others	=>	'0');
		load				<=	'0';
		m					<=	(others	=>	'0');
		p					<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		loop_count_q	<=	loop_count_d;
		i_out				<=	i_in;
		q_out				<=	q_in;
		a_out				<=	a_in;
		mag_mul_q		<=	mag_mul_d;
		mag_out_q		<=	mag_out_d;
		mag_q				<=	mag_d;
		phs_q				<=	phs_d;
		load				<=	load_d;
		m					<=	mag_out_q;-----cordic gain taken out
--		m					<=	mag_q(23 downto 6);-------for cordic gain of 1.646
		p					<=	phs_q(25 downto 8);
	end if;
end process;
loop_count_d	<= "00000" when loop_count_q = "10001" else std_logic_vector(unsigned(loop_count_q) + 1);
load_d			<= '1' when loop_count_q = "00000" else '0';					

i_extend(25 downto 24)		<= (others => i(17));
i_extend(23 downto 6)		<= 	i;
i_extend(5 downto 0)		<=	(others	=>	'0');
					
q_extend(25 downto 24)		<= (others => q(17));
q_extend(23 downto 6)		<= 	q;
q_extend(5 downto 0)		<=	(others	=>	'0');

i_init1	<= q_extend when q(17) = '0' else std_logic_vector(signed(not q_extend) + 1);
i_init	<= std_logic_vector(signed(i_init1) - signed(q_init1)) when q_init1(25) = '1' else std_logic_vector(signed(i_init1) + signed(q_init1));
i_in		<= i_init when loop_count_q = "00000" else i_int;
i_int		<= std_logic_vector(signed(i_out) - signed(q_div)) when q_out(25) = '1' else std_logic_vector(signed(i_out) + signed(q_div));

q_init1	<= i_extend when q(17) = '1' else std_logic_vector(signed(not i_extend) + 1);
q_init	<= std_logic_vector(signed(q_init1) - signed(i_init1)) when q_init1(25) = '0' else std_logic_vector(signed(q_init1) + signed(i_init1));	
q_in		<= q_init when loop_count_q = "00000" else q_int;
q_int		<= std_logic_vector(signed(q_out) - signed(i_div)) when q_out(25) = '0' else std_logic_vector(signed(q_out) + signed(i_div));

a_init1	<=	("01"&x"000000") when q(17) = '1' else ("11" & x"000000");
a_init	<= 	std_logic_vector(signed(a_init1) - signed(b(0))) when q_init1(25) = '0' else std_logic_vector(signed(a_init1) + signed(b(0)));	
a_in		<= 	a_init when loop_count_q = "00000" else a_int;
a_int		<= 	std_logic_vector(signed(a_out) - signed(b(y))) when q_out(25) = '0' else std_logic_vector(signed(a_out) + signed(b(y)));

i_shift: entity work.shift_by_m ----division by 2^m
	generic map(n => 26)			
	port map(d_in	=>	i_out,
				m		=> y,
				d_out	=> i_div
				);				
q_shift: entity work.shift_by_m ----division by 2^m
	generic map(n => 26)			 
	port map(d_in	=>	q_out,
				m		=> y,
				d_out	=> q_div
				);
mag_in		<= i_out;
mag_d			<=	mag_in when loop_count_q = "00000" else mag_q;
phs_d			<=	phs_in when loop_count_q = "00000" else phs_q;					
phs_in		<= std_logic_vector(signed(not a_out) + 1);
mag_mul_d	<=	std_logic_vector(signed(mag_q)*signed(cordic_gain));
mag_out_d	<=	"01"&x"ffff" when mag_mul_q(41) = '0' and mag_mul_q(40 downto 38) /= "000" else
					"10"&x"0000" when mag_mul_q(41) = '1' and mag_mul_q(40 downto 38) /= "111" else
					mag_mul_q(38 downto 21);
end architecture behavior;