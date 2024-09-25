library ieee;
use ieee.std_logic_1164.all;

entity jtag_sel is
	port(clock	:	in std_logic;
			reset	:	in std_logic;
			
			jtag_sel_in	:	in std_logic_vector(1 downto 0);---------(0) max10-> c10 clock, (1) max10 -> c10 data
			jtag_sel_out	:	out std_logic--------'1'----max10 only, '0' both max10 and cyclone 10
			);
end entity jtag_sel;

architecture behavior of jtag_sel is

signal jtag_out_q, jtag_out_d		:	std_logic;
signal jtag_sel_in_q					:	std_logic_vector(5 downto 0);






begin


jtag_out_d		<=	--'1'when jtag_sel_in_q(2 downto 1) = "10" else
						--'0' when jtag_sel_in_q(2 downto 1) = "01" else
						'0' when jtag_sel_in_q(2 downto 1) = "01" and jtag_sel_in_q(5 downto 4) = "10" else
						'1' when jtag_sel_in_q(2 downto 1) = "10" and jtag_sel_in_q(5 downto 4) = "01" else
						jtag_out_q;
						
						
						

						
						
--jtag_sel_out	<=	not jtag_out_q;						


process(clock)
begin
	if(rising_edge(clock)) then
	
		if(reset = '0') then
			jtag_out_q	<=	'1';
			jtag_sel_in_q	<=	(others	=>	'0');
			jtag_sel_out	<=	'0';			
		else
			jtag_out_q						<=	jtag_out_d;
			jtag_sel_in_q(2 downto 0)	<=	jtag_sel_in_q(1 downto 0)&jtag_sel_in(0);
			jtag_sel_in_q(5 downto 3)	<=	jtag_sel_in_q(4 downto 3)&jtag_sel_in(1);
			jtag_sel_out					<=	not jtag_out_q;
		end if;
	end if;	
end process;
	
		






end architecture behavior;			
