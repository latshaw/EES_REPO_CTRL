library ieee;
use ieee.std_logic_1164.all;
USE WORK.COMPONENTS.ALL;

entity arc_test_gen is

port(clock : in std_logic;
	 reset : in std_logic;
	 test_signal : out std_logic
	 );
	 
end entity arc_test_gen;

architecture behavior of arc_test_gen is

signal one : std_logic;
signal en_count : std_logic;
signal count : std_logic_vector(9 downto 0);

begin




arc_test_counter: counter
		generic map(n => 10)
		port map(clock => clock,
			 reset => reset,
			 clear => one,
			 enable => one,
			 count => count
			);
			
			
			test_signal <= count(9);



end architecture behavior;