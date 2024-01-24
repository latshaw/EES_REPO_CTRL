library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mp2iq_init_new is
generic(n : integer := 18);	
port(clock 	: in std_logic;
	  reset 	: in std_logic;
	  load	: in std_logic;
	  mag 	: in std_logic_vector(n-1 downto 0);
	  phs_h 	: in std_logic_vector(n-1 downto 0);
	  phs_l	:	in std_logic_vector(7 downto 0);----this is needed to get the resolution needed for nco, would be better to increase it to 12 bits to make the precision better		
	  i 		: out std_logic_vector(n+7 downto 0);
	  q 		: out std_logic_vector(n+7 downto 0);
	  p		: out std_logic_vector(n+7 downto 0);
	  a	 	: out std_logic_vector(n+7 downto 0)
	  );	  
end entity mp2iq_init_new;
architecture behavior of mp2iq_init_new is
signal mag_int	: std_logic_vector(n+7 downto 0);
signal i_int	: std_logic_vector(n+7 downto 0);
signal q_int	: std_logic_vector(n+7 downto 0);
signal ang_int	: std_logic_vector(n+7 downto 0);
signal phs_int	: std_logic_vector(n+7 downto 0);
begin
mag_int(n+7 downto n+6) 	<= (others => mag(n-1));
mag_int(n+5 downto 6)		<= mag;
mag_int(5 downto 0)			<=	(others	=>	'0');
phs_int(n+7 downto 8)	<= phs_h ;
phs_int(7 downto 0)		<= phs_l;
i_int <= (others => '0');
q_int <= mag_int when phs_h(n-1) = '0' else std_logic_vector((signed(not mag_int) + 1)) ;
ang_int <= ("01" & x"000000") when phs_h(n-1) = '0' else ("11" & x"000000");--16384 pos 90 deg, 245760 neg 90 deg	
process(clock, reset)
begin
	if(reset = '0') then
		i	<=	(others	=>	'0');
		q	<=	(others	=>	'0');
		a	<=	(others	=>	'0');
		p	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			i	<=	i_int;
			q	<=	q_int;
			a	<=	ang_int;
			p	<=	phs_int;
		end if;
	end if;	
end process;
end architecture behavior; 