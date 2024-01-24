library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity freq_disc_phs is
	port(reset			:	in std_logic;
			clock			:	in std_logic;
			load			:	in std_logic;
			prbi			:	in std_logic_vector(17 downto 0);
			prbq			:	in std_logic_vector(17 downto 0);
			phs_sml		:	out std_logic_vector(17 downto 0);
			phs_med		:	out std_logic_vector(17 downto 0);
			phs_lrg		:	out std_logic_vector(17 downto 0);
			phs_xlrg		:	out std_logic_vector(17 downto 0)
			);
end entity freq_disc_phs;
architecture behavior of freq_disc_phs is
signal prbi_iirk15, prbq_iirk15	:	std_logic_vector(17 downto 0);
signal prbi_iirk12, prbq_iirk12	:	std_logic_vector(17 downto 0);
signal prbi_iirk8, prbq_iirk8		:	std_logic_vector(17 downto 0);
signal prbi_iirk4, prbq_iirk4		:	std_logic_vector(17 downto 0);
begin
iirk13_prbi_inst: entity work.iir_lpfk15
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbi,
			d_out	=>	prbi_iirk15
			);
iirk13_prbq_inst: entity work.iir_lpfk15
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbq,
			d_out	=>	prbq_iirk15
			);
iirk13_prbiq2mp_inst: entity work.iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	prbi_iirk15,
			q 			=>	prbq_iirk15,
			load		=>	open,
			m			=>	open,
			p			=>	phs_sml
			);
iirk10_prbi_inst: entity work.iir_lpfk12
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbi,
			d_out	=>	prbi_iirk12
			);
iirk10_prbq_inst: entity work.iir_lpfk12
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbq,
			d_out	=>	prbq_iirk12
			);
iirk10_prbiq2mp_inst: entity work.iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	prbi_iirk12,
			q 			=>	prbq_iirk12,
			load		=>	open,
			m			=>	open,
			p			=>	phs_med
			);
iirk6_prbi_inst: entity work.iir_lpfk8
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbi,
			d_out	=>	prbi_iirk8
			);
iirk6_prbq_inst: entity work.iir_lpfk8
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbq,
			d_out	=>	prbq_iirk8
			);
iirk6_prbiq2mp_inst: entity work.iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	prbi_iirk8,
			q 			=>	prbq_iirk8,
			load		=>	open,
			m			=>	open,
			p			=>	phs_lrg
			);
iirk2_prbi_inst: entity work.iir_lpfk4
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbi,
			d_out	=>	prbi_iirk4
			);
iirk2_prbq_inst: entity work.iir_lpfk4
port map(clock	=>	clock,
			reset =>	reset,
			load	=>	load,
			d_in	=>	prbq,
			d_out	=>	prbq_iirk4
			);
iirk2_prbiq2mp_inst: entity work.iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	prbi_iirk4,
			q 			=>	prbq_iirk4,
			load		=>	open,
			m			=>	open,
			p			=>	phs_xlrg
			);	  						

end architecture behavior;			
			