library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity iq2mp_init18 is
port(clock 	: in std_logic;
	  reset 	: in std_logic;
	  load	: in std_logic;
	  i	 	: in std_logic_vector(17 downto 0);
	  q	 	: in std_logic_vector(17 downto 0);	  
	  magi 	: out std_logic_vector(25 downto 0);
	  magq 	: out std_logic_vector(25 downto 0);
	  a	 	: out std_logic_vector(25 downto 0);
	  sign	: out std_logic
	  );	  
end entity iq2mp_init18;

architecture behavior of iq2mp_init18 is
signal magi_int	: std_logic_vector(25 downto 0);
signal magq_out_int	: std_logic_vector(25 downto 0);
signal magq_int	: std_logic_vector(25 downto 0);
signal i_int	: std_logic_vector(25 downto 0);
signal q_int	: std_logic_vector(25 downto 0);
signal ang_int	: std_logic_vector(25 downto 0);
signal phs_int	: std_logic_vector(25 downto 0);
begin
i_int(25 downto 24)				<=	(others	=>	i(17));
i_int(23 downto 6)				<=	i;
i_int(5 downto 0)				<=	(others	=>	'0');
q_int(25 downto 24)				<=	(others	=>	q(17));
q_int(23 downto 6)				<=	q;
q_int(5 downto 0)				<=	(others	=>	'0');
ang_int 					<= ("01"&x"000000") when q(17) = '1' else ("11"&x"000000");--65536 POS 90 DEG, 196608 NEG 90 DEG	
magi_int					<= q_int when q(17) = '0' else std_logic_vector(signed(not q_int) + 1);
magq_int					<= i_int when q(17) = '1' else std_logic_vector(signed(not i_int) + 1);
process(clock, reset)
begin
	if(reset	=	'0') then
		magi				<=	(others	=>	'0');
		magq_out_int	<=	(others	=>	'0');
		a					<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			magi				<=	magi_int;
			magq_out_int	<=	magq_int;
			a					<=	ang_int;
		end if;	
	end if;
end process;
magq						<= magq_out_int;
sign						<= magq_out_int(25);
end architecture behavior;