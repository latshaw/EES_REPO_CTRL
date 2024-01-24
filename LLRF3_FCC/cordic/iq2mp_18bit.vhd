library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity iq2mp_18bit is
port(clock 	: in std_logic;
	  reset 	: in std_logic;
	  load	: in std_logic;
	  i 		: in std_logic_vector(17 downto 0);
	  q	 	: in std_logic_vector(17 downto 0);
	  mag_c	:	out std_logic_vector(17 downto 0);	  
	  mag 	: out std_logic_vector(17 downto 0);
	  phs 	: out std_logic_vector(17 downto 0)
	  );	  
end entity iq2mp_18bit;

architecture behavior of iq2mp_18bit is
type reg18_5 is array(17 downto 0) of integer range 0 to 31;
constant a		: reg18_5 	:= ( 17, 16, 15, 14, 13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1, 0);									  
constant b		: reg18_26 	:= ("00"&x"000051",	"00"&x"0000A3",	"00"&x"000146",	"00"&x"00028c",	"00"&x"000518",	"00"&x"000A30",	"00"&x"00145F",	"00"&x"0028BE",	"00"&x"00517D",
								"00"&x"00A2F9", "00"&x"0145F1", "00"&x"028BD8",	"00"&x"05175F",	"00"&x"0A2C35",	"00"&x"144447",	"00"&x"27ECE1",	"00"&x"4B9014",	"00"&x"800000");

signal iin_int					: reg18_26;
signal qin_int					: reg18_26;
signal ain_int					: reg18_26;
signal iout_int					: reg18_26;
signal qout_int					: reg18_26;
signal aout_int					: reg18_26;

signal iout_shift				: reg18_26;
signal qout_shift				: reg18_26;

signal iinit					: std_logic_vector(25 downto 0);
signal qinit					: std_logic_vector(25 downto 0);
signal ainit					: std_logic_vector(25 downto 0);

signal phs_int					: std_logic_vector(25 downto 0);
signal phs_out_int			: std_logic_vector(25 downto 0);
signal mag_int					: std_logic_vector(25 downto 0);

signal sign						: std_logic_vector(17 downto 0);
signal sign_int				: std_logic;
constant cordic_gain			:	std_logic_vector(15 downto 0) := x"4dba";
signal mag_mul_d, mag_mul_q		:	std_logic_vector(41 downto 0);
signal mag_out_d, mag_out_q		:	std_logic_vector(17 downto 0);
--component iq2mp_init18 is
--port(clock 	: in std_logic;
--	  reset 	: in std_logic;
--	  load	: in std_logic;
--	  i	 	: in std_logic_vector(17 downto 0);
--	  q	 	: in std_logic_vector(17 downto 0);
--	  
--	  magi 	: out std_logic_vector(25 downto 0);
--	  magq 	: out std_logic_vector(25 downto 0);
--	  a	 	: out std_logic_vector(25 downto 0);
--	  sign	: out std_logic
--	  );	  
--end component iq2mp_init18;
--component iq2mp_reg26 is
--port(clock		: in std_logic;
--	  reset		: in std_logic;
--	  load		: in std_logic;
--	  i			: in std_logic_vector(25 downto 0);
--	  q			: in std_logic_vector(25 downto 0);
--	  a			: in std_logic_vector(25 downto 0);
----	  A_IN		: in std_logic_vector(17 downto 0);
----	  M			: in integer range 0 to 31;
--	  
--	  i_out		: out std_logic_vector(25 downto 0);
--	  q_out		: out std_logic_vector(25 downto 0);
--	  a_out		: out std_logic_vector(25 downto 0);
--	  sign		: out std_logic
--	  );	  
--end component iq2mp_reg26;
--component cordic_shift18 is
--port(data_in 	: in reg18_26;
--	 data_out	: out reg18_26
--	 );
--end component cordic_shift18;
begin

iq2mp_reg_gen: entity work.iq2mp_init18
port map(clock => clock,
			reset => reset,
			load	=> load,
			i	 	=> i,
			q 		=> q,	  
			magi 	=> iinit,
			magq	=> qinit,
			a	 	=> ainit,
			sign	=> sign_int
			);
iq2mp_reg_gen_i: for i in 0 to 17 generate
iq2mp_single_reg_i: entity work.iq2mp_reg26
port map(clock	=> clock,
			reset	=> reset,
			load	=> load,
			i		=> iin_int(i),
			q		=> qin_int(i),
			a		=> ain_int(i),
--			A_IN	=> B(i),
--			M		=> a(i),	  
			i_out	=> iout_int(i),
			q_out	=> qout_int(i),
			a_out	=> aout_int(i),
			sign	=> sign(i)
			);		  
end generate;
cordic_shift_i: entity work.cordic_shift18 
port map(data_in 	=> iout_int,
	 	 data_out	=> iout_shift
	 	 );		  
cordic_shift_q: entity work.cordic_shift18 
port map(data_in 	=> qout_int,
	 	 data_out	=> qout_shift
	 	 );		  
iin_int(0)		<= std_logic_vector(signed(iinit) - signed(qinit)) when sign_int = '1' else std_logic_vector(signed(iinit) + signed(qinit));
qin_int(0)		<= std_logic_vector(signed(qinit) - signed(iinit)) when sign_int = '0' else std_logic_vector(signed(qinit) + signed(iinit));
ain_int(0)		<= std_logic_vector(signed(ainit) - signed(b(0))) when sign_int = '0' else std_logic_vector(signed(ainit) + signed(b(0)));
signal_gen_I: for i in 1 to 17 generate
	iin_int(i) <= std_logic_vector(signed(iout_int(i-1)) - signed(qout_shift(i-1))) when sign(i-1) = '1' else std_logic_vector(signed(iout_int(i-1)) + signed(qout_shift(i-1)));
	qin_int(i) <= std_logic_vector(signed(qout_int(i-1)) - signed(iout_shift(i-1))) when sign(i-1) = '0' else std_logic_vector(signed(qout_int(i-1)) + signed(iout_shift(i-1)));
	ain_int(i) <= std_logic_vector(signed(aout_int(i-1)) - signed(b(i))) when sign(i-1) = '0' else std_logic_vector(signed(aout_int(i-1)) + signed(b(i))) ;
end generate;
phs_int		<= std_logic_vector(signed(not aout_int(17)) + 1);
mag_mul_d	<=	std_logic_vector(signed(iout_int(17))*signed(cordic_gain));
mag_out_d	<=	"01"&x"ffff" when mag_mul_q(41) = '0' and mag_mul_q(40 downto 38) /= "000" else
				"10"&x"0000" when mag_mul_q(41) = '1' and mag_mul_q(40 downto 38) /= "111" else
				mag_mul_q(38 downto 21);
process(clock, reset)
begin
	if(reset	=	'0') then
		phs_out_int	<=	(others	=>	'0');
		mag			<=	(others	=>	'0');
		phs			<=	(others	=>	'0');
		mag_out_q	<=	(others	=>	'0');
		mag_mul_q	<=	(others	=>	'0');
		mag_c			<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			phs_out_int	<=	phs_int;
			mag			<=	mag_out_q;
			phs			<=	phs_out_int(25 downto 8);
			mag_out_q	<=	mag_out_d;
			mag_mul_q	<=	mag_mul_d;
			mag_c			<=	iout_int(17)(23 downto 6);
		end if;	
	end if;
end process;	
end architecture behavior;
