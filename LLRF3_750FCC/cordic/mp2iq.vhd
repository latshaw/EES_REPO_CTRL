library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mp2iq is

port(clock 	: in std_logic;
	  reset : in std_logic;
	  load	: in std_logic;
	  mag 	: in std_logic_vector(17 downto 0);
	  phs_h 	: in std_logic_vector(17 downto 0);
	  phs_l	:	in std_logic_vector(7 downto 0);
	  
	  i 	: out std_logic_vector(17 downto 0);
	  q 	: out std_logic_vector(17 downto 0)
	  );
	  
end entity mp2iq;

architecture behavior of mp2iq is
type reg18_5 is array(17 downto 0) of integer range 0 to 31;
type reg18_26 is array(17 downto 0) of std_logic_vector(25 downto 0);
constant a		: reg18_5 	:= ( 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);
constant b		: reg18_26 	:= ("00"&x"000051",	"00"&x"0000A3",	"00"&x"000146",	"00"&x"00028c",	"00"&x"000518",	"00"&x"000A30",	"00"&x"00145F",	"00"&x"0028BE",	"00"&x"00517D",
								"00"&x"00A2F9", "00"&x"0145F1", "00"&x"028BD8",	"00"&x"05175F",	"00"&x"0A2C35",	"00"&x"144447",	"00"&x"27ECE1",	"00"&x"4B9014",	"00"&x"800000");

signal iin_int					: reg18_26;
signal qin_int					: reg18_26;
signal pin_int					: reg18_26;
signal ain_int					: reg18_26;
signal iout_int					: reg18_26;
signal qout_int					: reg18_26;
signal pout_int					: reg18_26;
signal aout_int					: reg18_26;
signal iinit					: std_logic_vector(25 downto 0);
signal qinit					: std_logic_vector(25 downto 0);
signal ainit					: std_logic_vector(25 downto 0);
signal pinit					: std_logic_vector(25 downto 0);
signal i_mul_d, i_mul_q			:	std_logic_vector(41 downto 0);
signal q_mul_d, q_mul_q			:	std_logic_vector(41 downto 0);
signal i_d, q_d					:	std_logic_vector(17 downto 0);
constant cordic_gain			:	std_logic_vector(15 downto 0) := x"4dba";
begin
	
mp2iq_reg_gen: entity work.mp2iq_init_new 
generic map(n => 18)
port map(clock => clock,
			reset => reset,
			load	=> load,
			mag 	=> mag,
			phs_h	=> phs_h,
			phs_l	=>	phs_l,	
			i 		=> iin_int(0),
			q 		=> qin_int(0),
			p		=> pin_int(0),
			a	 	=> ain_int(0)
			);		  
	  
mp2iq_reg_gen_i: for i in 0 to 17 generate

mp2iq_single_reg_i: entity work.mp2iq_reg_new 
generic map(n	=>	26)
port map(clock	=> clock,
	  	 reset	=> reset,
	 	 load	=> load,
	 	 i		=> iin_int(i),
	 	 q		=> qin_int(i),
	 	 p		=> pin_int(i),
	 	 a		=> ain_int(i),
	 	 a_in	=> b(i),
	 	 m		=> a(i),
	  
	 	 i_out	=> iout_int(i),
	 	 q_out	=> qout_int(i),
	 	 p_out	=> pout_int(i),
	 	 a_out	=> aout_int(i)
	 	 );
		  
end generate;

signal_gen_i: for i in 1 to 17 generate
	
	iin_int(i) <= iout_int(i-1)	;
	qin_int(i) <= qout_int(i-1)	;
	pin_int(i) <= pout_int(i-1)	;
	ain_int(i) <= aout_int(i-1)	;

end generate;

i_mul_d				<= std_logic_vector(signed(iout_int(17)) * signed(cordic_gain)); 
q_mul_d				<= std_logic_vector(signed(qout_int(17)) * signed(cordic_gain));
i_d					<=	"01"&x"ffff" when i_mul_q(41) = '0' and i_mul_q(40 downto 38) /= "000" else
						"10"&x"0000" when i_mul_q(41) = '1' and i_mul_q(40 downto 38) /= "111" else
						i_mul_q(38 downto 21);
q_d					<=	"01"&x"ffff" when q_mul_q(41) = '0' and q_mul_q(40 downto 38) /= "000" else
						"10"&x"0000" when q_mul_q(41) = '1' and q_mul_q(40 downto 38) /= "111" else
						q_mul_q(38 downto 21);

process(clock, reset)
begin
	if(reset = '0') then
		i_mul_q		<=	(others	=>	'0');
		q_mul_q		<=	(others	=>	'0');
		i			<=	(others	=>	'0');
		q			<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			i_mul_q		<=	i_mul_d;
			q_mul_q		<=	q_mul_d;
			i			<=	i_d;
			q			<=	q_d;
		end if;
	end if;
end process;		
end architecture behavior;