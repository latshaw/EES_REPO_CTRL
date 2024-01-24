library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deta_module is
	port(clock		:	in std_logic;
			reset		:	in std_logic;
			load		:	in std_logic;
			prb_i		:	in std_logic_vector(17 downto 0);
			prb_q		:	in std_logic_vector(17 downto 0);
			fwd_i		:	in std_logic_vector(17 downto 0);
			fwd_q		:	in std_logic_vector(17 downto 0);
			tdoff		:	in std_logic_vector(17 downto 0);
			
			deta		:	out std_logic_vector(17 downto 0);
			cfqea		:	out std_logic_vector(17 downto 0);
			deta2		:	out std_logic_vector(17 downto 0);
			dtnerr	:	out std_logic_vector(17 downto 0)
			);
end entity deta_module;
architecture behavior of deta_module is
signal ld_cnt_d, ld_cnt_q		:	integer range 0 to 127;
signal deta_ld						:	std_logic;

signal prb_i_lpfk18					:	std_logic_vector(17 downto 0);
signal prb_q_lpfk18					:	std_logic_vector(17 downto 0);
signal fwd_i_lpfk18					:	std_logic_vector(17 downto 0);
signal fwd_q_lpfk18					:	std_logic_vector(17 downto 0);
signal prbp								:	std_logic_vector(17 downto 0);
signal fwdp								:	std_logic_vector(17 downto 0);
signal ld_cordic						:	std_logic;

signal prb_i_lpfk7					:	std_logic_vector(17 downto 0);
signal prb_q_lpfk7					:	std_logic_vector(17 downto 0);
signal fwd_i_lpfk7					:	std_logic_vector(17 downto 0);
signal fwd_q_lpfk7					:	std_logic_vector(17 downto 0);
signal prbp7							:	std_logic_vector(17 downto 0);
signal fwdp7							:	std_logic_vector(17 downto 0);
signal ld_cordic7						:	std_logic;
begin

deta_ld		<=	'1' when ld_cnt_q	= 127 else '0';
ld_cnt_d		<=	0 when load = '1' and ld_cnt_q = 127 else 
					ld_cnt_q + 1 when load = '1' and ld_cnt_q /= 127 else
					ld_cnt_q;			
process(clock, reset)
begin
	if(reset = '0') then
		ld_cnt_q		<=	0;
	elsif(rising_edge(clock)) then
		ld_cnt_q		<=	ld_cnt_d;
	end if;
end process;	

prbi_iir_lpfk18: entity work.iir_lpfk18
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	prb_i,
			d_out		=>	prb_i_lpfk18
			);
prbq_iir_lpfk18: entity work.iir_lpfk18
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	prb_q,
			d_out		=>	prb_q_lpfk18
			);
fwdi_iir_lpfk18: entity work.iir_lpfk18
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	fwd_i,
			d_out		=>	fwd_i_lpfk18
			);
fwdq_iir_lpfk18: entity work.iir_lpfk18
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	fwd_q,
			d_out		=>	fwd_q_lpfk18
			);
prbi_iq2mp: entity work. iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	prb_i_lpfk18,
			q 			=>	prb_q_lpfk18,
			load		=>	ld_cordic,
			m			=>	open,
			p			=>	prbp
			);
fwdi_iq2mp: entity work. iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	fwd_i_lpfk18,
			q 			=>	fwd_q_lpfk18,
			load		=>	open,
			m			=>	open,
			p			=>	fwdp
			);	  			
detune_calc_inst: entity work. detune_calc
port map(reset		=>	reset,
			clock		=>	clock,
			load		=>	ld_cordic,
			prbphs	=>	prbp,
			fwdphs	=>	fwdp,
			tdoff		=>	tdoff,
			dtnerr	=>	dtnerr,
			detune	=>	deta,
			cfqea		=>	cfqea
			);

prbi_iir_lpfk7: entity work.iir_lpfk7
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	prb_i,
			d_out		=>	prb_i_lpfk7
			);
prbq_iir_lpfk7: entity work.iir_lpfk7
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	prb_q,
			d_out		=>	prb_q_lpfk7
			);
fwdi_iir_lpfk7: entity work.iir_lpfk7
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	fwd_i,
			d_out		=>	fwd_i_lpfk7
			);
fwdq_iir_lpfk7: entity work.iir_lpfk7
port map(clock		=>	clock,
			reset 	=>	reset,
			load		=>	deta_ld,
			d_in		=>	fwd_q,
			d_out		=>	fwd_q_lpfk7
			);
prbi_iq2mp7: entity work. iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	prb_i_lpfk7,
			q 			=>	prb_q_lpfk7,
			load		=>	ld_cordic7,
			m			=>	open,
			p			=>	prbp7
			);
fwdi_iq2mp7: entity work. iq2mp_18bit_small
port map(clock		=>	clock,
			reset		=>	reset,
			i			=>	fwd_i_lpfk7,
			q 			=>	fwd_q_lpfk7,
			load		=>	open,
			m			=>	open,
			p			=>	fwdp7
			);
detune2_calc_inst: entity work. detune_calc
port map(reset		=>	reset,
			clock		=>	clock,
			load		=>	ld_cordic7,
			prbphs	=>	prbp7,
			fwdphs	=>	fwdp7,
			tdoff		=>	tdoff,
			dtnerr	=>	open,
			detune	=>	deta2,
			cfqea		=>	open
			);			

end architecture behavior;			