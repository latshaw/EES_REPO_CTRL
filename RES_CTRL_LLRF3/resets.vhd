library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.components.all;

entity resets is
	port(clock : in std_logic;
		 brd_reset : in std_logic;---reset on the board connected to FPGA
		 isa_reset : in std_logic;---isa bus reset
		 reg_reset : in std_logic;---register reset from EPICS
		 reset : out std_logic ---reset for FPGA firmware
		);
end entity resets;

architecture behavior of resets is

signal en_reset_timer	: std_logic;
signal reset_count		: std_logic_vector(2 downto 0); 
signal reset_timer		: std_logic;

signal one					: std_logic;

begin

	one	<= '1';

	reset_timer_coutner: counter
		generic map(n => 3)
		port map(clock		=> clock,
			 	 reset		=> brd_reset,
				 clear		=> one,
			 	 en			=> en_reset_timer,
			 	 count		=> reset_count
				);
	
	
	en_reset_timer	<= '1' when (reset_count /= "111") else '0';---reset for 8 clock cycles at the start up
	reset				<= '0' when (brd_reset = '0' or reg_reset = '1' or reset_count /= "111") else '1'; 

end architecture behavior;


		 