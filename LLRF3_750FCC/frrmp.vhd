library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity frrmp is
	port(clock			:	in std_logic;
			reset			:	in std_logic;
			load			:	in std_logic;
			prob_i			:	in std_logic_vector(17 downto 0);
			prob_q			:	in std_logic_vector(17 downto 0);
			rflc_i		:	in std_logic_vector(17 downto 0);
			rflc_q		:	in std_logic_vector(17 downto 0);
			frwd_i		:	in std_logic_vector(17 downto 0);
			frwd_q		:	in std_logic_vector(17 downto 0);
			refr_i		:	in std_logic_vector(17 downto 0);
			refr_q		:	in std_logic_vector(17 downto 0);
			fltrd			:	out reg16_18
--			frrmp			:	out reg18_8
			);
end entity frrmp;
architecture behavior of frrmp is
signal fltr_in			:	reg18_8;
signal fltrd_iq		:	reg18_8;
signal frrmp_int		:	reg18_8;
signal load_out		:	std_logic_vector(3 downto 0);
begin
fltr_in(0)	<=	prob_i;
fltr_in(1)	<=	prob_q;
fltr_in(2)	<=	rflc_i;
fltr_in(3)	<=	rflc_q;
fltr_in(4)	<=	frwd_i;
fltr_in(5)	<=	frwd_q;
fltr_in(6)	<=	refr_i;
fltr_in(7)	<=	refr_q;

fltr_iq_gen_i: for i in 0 to 3 generate
inst_iir_lpf_i: entity work.iir_lpfk7
port map(clock		=>	clock,
			reset		=>	reset,
			load		=>	load,	
			d_in		=>	fltr_in(2*i),
			d_out		=>	fltrd_iq(2*i)
			);
inst_iir_lpf_q: entity work.iir_lpfk7
port map(clock		=>	clock,
			reset		=>	reset,
			load		=>	load,	
			d_in		=>	fltr_in(2*i+1),
			d_out		=>	fltrd_iq(2*i+1)
			);
inst_iq2mp_small_i: entity work.iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	fltrd_iq(2*i),
			q 			=>	fltrd_iq(2*i+1),
			load		=>	load_out(i),
			m			=>	frrmp_int(2*i),
			p			=>	frrmp_int(2*i+1)
			);
end generate;


	



inout_sig_gen_j: for j in 0 to 3 generate
	fltrd(4*j)	<=	fltrd_iq(2*j);
	fltrd(4*j+1)	<=	fltrd_iq(2*j+1);
	fltrd(4*j+2)	<=	frrmp_int(2*j);
	fltrd(4*j+3)	<=	frrmp_int(2*j+1);
end generate;
end architecture behavior;			