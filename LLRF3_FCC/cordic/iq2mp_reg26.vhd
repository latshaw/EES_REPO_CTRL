library ieee;
use ieee.std_logic_1164.all;

entity iq2mp_reg26 is
port(clock		: in std_logic;
	  reset		: in std_logic;
	  load		: in std_logic;
	  i			: in std_logic_vector(25 downto 0);
	  q			: in std_logic_vector(25 downto 0);
	  a			: in std_logic_vector(25 downto 0);
--	  A_IN		: in std_logic_vector(17 downto 0);
--	  M			: in integer range 0 to 31;
	  
	  i_out		: out std_logic_vector(25 downto 0);
	  q_out		: out std_logic_vector(25 downto 0);
	  a_out		: out std_logic_vector(25 downto 0);
	  sign		: out std_logic
	  );	  
end entity iq2mp_reg26;

architecture behavior of iq2mp_reg26 is

signal sign_int		: std_logic;
signal i_int		: std_logic_vector(25 downto 0);
signal q_int		: std_logic_vector(25 downto 0);
signal ang_int		: std_logic_vector(25 downto 0);
signal q_out_int	: std_logic_vector(25 downto 0);
signal i_div		: std_logic_vector(25 downto 0);
signal q_div		: std_logic_vector(25 downto 0);

begin
sign_int		<= q_out_int(25);
sign			<= sign_int;
q_out 		<= q_out_int;
process(clock, reset)
begin
	if(reset	=	'0') then
		i_out				<=	(others	=>	'0');
		q_out_int		<=	(others	=>	'0');
		a_out				<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			i_out				<=	i;
			q_out_int		<=	q;
			a_out				<=	a;
		end if;
	end if;
end process;

end architecture behavior;