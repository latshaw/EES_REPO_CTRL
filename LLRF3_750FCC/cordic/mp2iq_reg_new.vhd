library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mp2iq_reg_new is
generic(n : integer := 26);	
port(clock	: in std_logic;
	  reset	: in std_logic;
	  load	: in std_logic;
	  i		: in std_logic_vector(n-1 downto 0);
	  q		: in std_logic_vector(n-1 downto 0);
	  p		: in std_logic_vector(n-1 downto 0);
	  a		: in std_logic_vector(n-1 downto 0);
	  a_in	: in std_logic_vector(n-1 downto 0);
	  m		: in integer range 0 to 31;	  
	  i_out	: out std_logic_vector(n-1 downto 0);
	  q_out	: out std_logic_vector(n-1 downto 0);
	  p_out	: out std_logic_vector(n-1 downto 0);
	  a_out	: out std_logic_vector(n-1 downto 0)
	  );	  
end entity mp2iq_reg_new;
architecture behavior of mp2iq_reg_new is
signal i_div		: std_logic_vector(n-1 downto 0);
signal q_div		: std_logic_vector(n-1 downto 0);
signal i_int		: std_logic_vector(n-1 downto 0);
signal q_int		: std_logic_vector(n-1 downto 0);
signal ang_int		: std_logic_vector(n-1 downto 0);
signal sign			: std_logic;
signal sign_int		: std_logic_vector(n-1 downto 0);
begin
sign_int 	<= std_logic_vector(signed(p) - signed(a));
sign 		<= sign_int(n-1);
i_shift: entity work.shift_by_m ----division by 2^m
	generic map(n => 26)			
	port map(d_in	=>	i,
				m		=> m,
				d_out	=> i_div
				);				
q_shift: entity work.shift_by_m ----division by 2^m
	generic map(n => 26)			 
	port map(d_in	=>	q,
				m		=> m,
				d_out	=> q_div
				);
i_int <= std_logic_vector(signed(i) - signed(q_div)) when sign = '0' else std_logic_vector(signed(i) + signed(q_div));
q_int <= std_logic_vector(signed(q) - signed(i_div)) when sign = '1' else std_logic_vector(signed(q) + signed(i_div));
ang_int <= std_logic_vector(signed(a) - signed(a_in)) when sign = '1' else std_logic_vector(signed(a) + signed(a_in));
process(clock, reset)
begin
	if(reset = '0') then
		i_out	<=	(others	=>	'0');
		q_out	<=	(others	=>	'0');
		a_out	<=	(others	=>	'0');
		p_out	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			i_out	<=	i_int;
			q_out	<=	q_int;
			a_out	<=	ang_int;
			p_out	<=	p;
		end if;
	end if;	
end process;
end architecture behavior; 