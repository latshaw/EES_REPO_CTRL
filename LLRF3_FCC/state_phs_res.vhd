---------------VHDL version of Larry Doolittle's verilog code-----------------------------
--------------rewritten to be used in the simulink model too------------------------------
----state linear 00, pos clip 10, neg clip 11

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_phs_res is
	generic(w : integer := 18);
	port(clock	:	in std_logic;
		reset	:	in std_logic;
		load	:	in std_logic;
		ang_in	:	in std_logic_vector(w-1 downto 0);
		ang_out	:	out std_logic_vector(w-1 downto 0)		
		);
end entity state_phs_res;
architecture behavior of state_phs_res is
--signal pn_np_ignore		:	std_logic;
signal pn, np				:	std_logic;
signal ang_q				:	std_logic_vector(w-1 downto 0);
signal clip					:	std_logic_vector(w-1 downto 0);
signal state_d, state_q		:	std_logic_vector(1 downto 0);
signal ang_out_d			:	std_logic_vector(w-1 downto 0);
begin
--pn_np_ignore	<=	'1' when signed(ang_in) > "01"&x"FA4F" and signed(ang_q) < "10"&x"05b1" or
--									signed(ang_in) < "10"&x"05b1" and signed(ang_in) > "01"&x"FA4F" else
--									'0';
pn			<=	not ang_q(w-1) and ang_q(w-2) and ang_in(w-1) and not ang_in(w-2);
np			<=	ang_q(w-1) and not ang_q(w-2) and not ang_in(w-1) and ang_in(w-2);
clip(w-1)	<=	state_q(0);
clip(w-2 downto 0)	<=	(others	=>	not state_q(0));
ang_out_d	<=	clip when state_q(1) = '1' else ang_q;
state_d(0)	<=	(not pn and np and not state_q(0) and not state_q(1)) or
				(not pn and np and state_q(0) and state_q(1)) or
				(state_q(0) and state_q(1) and (not pn) and (not np));

state_d(1)	<=	(not state_q(0) and not state_q(1) and (np xor pn)) or
				(not state_q(0) and state_q(1) and (not np)) or
				(state_q(0) and state_q(1) and not pn);

process(clock, reset)
begin
	if(reset = '0') then
		ang_q		<=	(others		=>	'0');
		state_q		<=	(others		=>	'0');		
		ang_out		<=	(others		=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			ang_q		<=	ang_in;
			state_q		<=	state_d;
			ang_out		<=	ang_out_d;
		end if;	
	end if;
end process;	
end architecture behavior;		
		
		