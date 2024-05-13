--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--use work.components.all;
--
--entity freq_disc is
--	port(clock		:	in std_logic;
--		reset		:	in std_logic;
--		load		:	in std_logic;
--		phs_in		:	in std_logic_vector(17 downto 0);
--		disc_out	:	out reg18_4;
--		disc_stp	:	out std_logic_vector(27 downto 0)
--		);
--end entity freq_disc;
--architecture behavior of freq_disc is
--signal phs_sml_reg_d, phs_sml_reg_q			:	reg18_9;
--signal phs_med_reg_d, phs_med_reg_q			:	reg18_9;
--signal phs_lrg_reg_d, phs_lrg_reg_q			:	reg18_9;
--signal phs_xlrg_reg_d, phs_xlrg_reg_q		:	reg18_9;
--signal phs_diff_sml_d, phs_diff_sml_q		:	std_logic_vector(18 downto 0);
--signal phs_diff_med_d, phs_diff_med_q		:	std_logic_vector(18 downto 0);
--signal phs_diff_lrg_d, phs_diff_lrg_q		:	std_logic_vector(18 downto 0);
--signal phs_diff_xlrg_d, phs_diff_xlrg_q	:	std_logic_vector(18 downto 0);
--signal freq_count_d, freq_count_q			:	std_logic_vector(13 downto 0);
--signal en_phs_sml_reg							:	std_logic;
--signal en_phs_med_reg							:	std_logic;
--signal en_phs_lrg_reg							:	std_logic;
--signal en_phs_xlrg_reg							:	std_logic;
--
--signal disc_sml_stp_d, disc_sml_stp_q		:	std_logic_vector(27 downto 0);
--signal disc_med_stp_d, disc_med_stp_q		:	std_logic_vector(27 downto 0);
--signal disc_lrg_stp_d, disc_lrg_stp_q		:	std_logic_vector(27 downto 0);
--signal disc_xlrg_stp_d, disc_xlrg_stp_q	:	std_logic_vector(27 downto 0);
--signal disc_stp_d, disc_stp_q					:	std_logic_vector(27 downto 0);
--
--signal sel_d, sel_q								: integer range 0 to 3;
--
--signal disc_int									:	reg18_4;
--
--begin
--freq_count_d		<=	std_logic_vector(unsigned(freq_count_q) + 1);
--
--en_phs_sml_reg		<=	'1' when freq_count_q(13 downto 0) = "00"&x"000" else '0';
--en_phs_med_reg		<=	'1' when freq_count_q(9 downto 0) = "00"&x"00" else '0';	
--en_phs_lrg_reg		<=	'1' when freq_count_q(5 downto 0) = "00"&x"0" else '0';
--en_phs_xlrg_reg		<=	'1' when freq_count_q(2 downto 0) = "000" else '0';
--
--phs_sml_reg_d(0)	<=	phs_in when en_phs_sml_reg = '1' else phs_sml_reg_q(0);
--phs_med_reg_d(0)	<=	phs_in when en_phs_med_reg = '1' else phs_med_reg_q(0);
--phs_lrg_reg_d(0)	<=	phs_in when en_phs_lrg_reg = '1' else phs_lrg_reg_q(0);
--phs_xlrg_reg_d(0)	<=	phs_in when en_phs_xlrg_reg = '1' else phs_xlrg_reg_q(0);
--	
--phs_reg_gen_i: for i in 1 to 8 generate
--	phs_sml_reg_d(i)	<=	phs_sml_reg_q(i-1) when en_phs_sml_reg = '1' else phs_sml_reg_q(i);
--	phs_med_reg_d(i)	<=	phs_med_reg_q(i-1) when en_phs_med_reg = '1' else phs_med_reg_q(i);	
--	phs_lrg_reg_d(i)	<=	phs_lrg_reg_q(i-1) when en_phs_lrg_reg = '1' else phs_lrg_reg_q(i);	
--	phs_xlrg_reg_d(i)	<=	phs_xlrg_reg_q(i-1) when en_phs_xlrg_reg = '1' else phs_xlrg_reg_q(i);
--end generate;
--
--phs_diff_sml_d			<=	std_logic_vector(signed(phs_sml_reg_q(8)(17)&phs_sml_reg_q(8)) - signed(phs_sml_reg_q(0)(17)&phs_sml_reg_q(0)));
--phs_diff_med_d			<=	std_logic_vector(signed(phs_med_reg_q(8)(17)&phs_med_reg_q(8)) - signed(phs_med_reg_q(0)(17)&phs_med_reg_q(0)));
--phs_diff_lrg_d			<=	std_logic_vector(signed(phs_lrg_reg_q(8)(17)&phs_lrg_reg_q(8)) - signed(phs_lrg_reg_q(0)(17)&phs_lrg_reg_q(0)));
--phs_diff_xlrg_d		<=	std_logic_vector(signed(phs_xlrg_reg_q(8)(17)&phs_xlrg_reg_q(8)) - signed(phs_xlrg_reg_q(4)(17)&phs_xlrg_reg_q(4)));
--
--process(clock, reset)
--begin
--	if(reset = '0') then
--		freq_count_q		<=	(others	=>	'0');
--		phs_sml_reg_q		<=	(others	=>	(others	=>	'0'));
--		phs_med_reg_q		<=	(others	=>	(others	=>	'0'));
--		phs_lrg_reg_q		<=	(others	=>	(others	=>	'0'));
--		phs_xlrg_reg_q		<=	(others	=>	(others	=>	'0'));
--		phs_diff_sml_q		<=	(others	=>	'0');
--		phs_diff_med_q		<=	(others	=>	'0');
--		phs_diff_lrg_q		<=	(others	=>	'0');
--		phs_diff_xlrg_q	<=	(others	=>	'0');
--		disc_sml_stp_q		<=	(others	=>	'0');
--		disc_med_stp_q		<=	(others	=>	'0');
--		disc_lrg_stp_q		<=	(others	=>	'0');
--		disc_xlrg_stp_q	<=	(others	=>	'0');
--		sel_q					<=	0;
--		disc_stp_q			<=	(others	=>	'0');
--	elsif(rising_edge(clock)) then
--		if(load = '1') then
--			freq_count_q		<=	freq_count_d;
--			phs_sml_reg_q		<=	phs_sml_reg_d;
--			phs_med_reg_q		<=	phs_med_reg_d;
--			phs_lrg_reg_q		<=	phs_lrg_reg_d;
--			phs_xlrg_reg_q		<=	phs_xlrg_reg_d;
--			phs_diff_sml_q		<=	phs_diff_sml_d;
--			phs_diff_med_q		<=	phs_diff_med_d;
--			phs_diff_lrg_q		<=	phs_diff_lrg_d;
--			phs_diff_xlrg_q	<=	phs_diff_xlrg_d;
--			disc_sml_stp_q		<=	disc_sml_stp_d;
--			disc_med_stp_q		<=	disc_med_stp_d;
--			disc_lrg_stp_q		<=	disc_lrg_stp_d;
--			disc_xlrg_stp_q	<=	disc_xlrg_stp_d;
--			sel_q					<=	sel_d;
--			disc_stp_q			<=	disc_stp_d;
--		end if;
--	end if;
--end process;
--disc_int(0)		<=	phs_diff_sml_q(17 downto 0);
--disc_int(1)		<=	phs_diff_med_q(17 downto 0);
--disc_int(2)		<=	phs_diff_lrg_q(17 downto 0);
--disc_int(3)		<=	phs_diff_xlrg_q(17 downto 0);
--
--disc_out		<=	disc_int;
--disc_stp		<=	disc_stp_q;	
--
---------------------------------28 bit discriminator for stepper control------------------------------
--disc_sml_stp_d(27 downto 16)		<=	(others	=>	phs_diff_sml_q(17));
--disc_sml_stp_d(15 downto 0)		<=	phs_diff_sml_q(17 downto 2);
--
--disc_med_stp_d(27 downto 20)		<=	(others	=>	phs_diff_med_q(17));
--disc_med_stp_d(19 downto 4)		<=	phs_diff_med_q(17 downto 2);
--disc_med_stp_d(3 downto 0)			<=	x"0";
--
--disc_lrg_stp_d(27 downto 24)		<=	(others	=>	phs_diff_lrg_q(17));
--disc_lrg_stp_d(23 downto 8)		<=	phs_diff_lrg_q(17 downto 2);
--disc_lrg_stp_d(7 downto 0)			<=	x"00";
--
--disc_xlrg_stp_d(27 downto 12)		<=	phs_diff_xlrg_q(17 downto 2);
--disc_xlrg_stp_d(11 downto 0)		<=	x"000";
--
--sel_d			<=	3 when (disc_int(3) < x"0007" or disc_int(3) > x"fff8") and (disc_int(2) < x"006c" or disc_int(2) > x"ff93") and (disc_int(1) < x"06be" or disc_int(1) > x"f941") else
--					2 when (disc_int(3) < x"006c" or disc_int(3) > x"ff93") and (disc_int(2) < x"06be" or disc_int(2) > x"f941") else
--					1 when (disc_int(3) < x"06be" or disc_int(3) > x"f941") else
--					0;
--					
--with sel_q select
--	disc_stp_d		<=	disc_sml_stp_q when 3,
--							disc_med_stp_q when 2,
--							disc_lrg_stp_q when 1,
--							disc_xlrg_stp_q when others;
--
--end architecture behavior;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity freq_disc is
	port(clock		:	in std_logic;
		reset		:	in std_logic;
		load		:	in std_logic;
		phs_sml_in		:	in std_logic_vector(17 downto 0);
		phs_med_in		:	in std_logic_vector(17 downto 0);
		phs_lrg_in		:	in std_logic_vector(17 downto 0);
		phs_xlrg_in		:	in std_logic_vector(17 downto 0);
		disc_out	:	out reg18_4;
		disc_stp	:	out std_logic_vector(27 downto 0)
		);
end entity freq_disc;
architecture behavior of freq_disc is
signal phs_sml_reg_d, phs_sml_reg_q			:	reg18_9;
signal phs_med_reg_d, phs_med_reg_q			:	reg18_9;
signal phs_lrg_reg_d, phs_lrg_reg_q			:	reg18_9;
signal phs_xlrg_reg_d, phs_xlrg_reg_q		:	reg18_9;
signal phs_diff_sml_d, phs_diff_sml_q		:	std_logic_vector(18 downto 0);
signal phs_diff_med_d, phs_diff_med_q		:	std_logic_vector(18 downto 0);
signal phs_diff_lrg_d, phs_diff_lrg_q		:	std_logic_vector(18 downto 0);
signal phs_diff_xlrg_d, phs_diff_xlrg_q	:	std_logic_vector(18 downto 0);
signal freq_count_d, freq_count_q			:	std_logic_vector(13 downto 0);
signal en_phs_sml_reg							:	std_logic;
signal en_phs_med_reg							:	std_logic;
signal en_phs_lrg_reg							:	std_logic;
signal en_phs_xlrg_reg							:	std_logic;

signal disc_sml_stp_d, disc_sml_stp_q		:	std_logic_vector(27 downto 0);
signal disc_med_stp_d, disc_med_stp_q		:	std_logic_vector(27 downto 0);
signal disc_lrg_stp_d, disc_lrg_stp_q		:	std_logic_vector(27 downto 0);
signal disc_xlrg_stp_d, disc_xlrg_stp_q	:	std_logic_vector(27 downto 0);
signal disc_stp_d, disc_stp_q					:	std_logic_vector(27 downto 0);

signal sel_d, sel_q								: integer range 0 to 3;

signal disc_int_flt								:	reg18_4;
signal disc_int									:	reg16_4;

begin
freq_count_d		<=	std_logic_vector(unsigned(freq_count_q) + 1);

en_phs_sml_reg		<=	'1' when freq_count_q(13 downto 0) = "00"&x"000" else '0';
en_phs_med_reg		<=	'1' when freq_count_q(9 downto 0) = "00"&x"00" else '0';	
en_phs_lrg_reg		<=	'1' when freq_count_q(5 downto 0) = "00"&x"0" else '0';
en_phs_xlrg_reg		<=	'1' when freq_count_q(2 downto 0) = "000" else '0';

phs_sml_reg_d(0)	<=	phs_sml_in when en_phs_sml_reg = '1' else phs_sml_reg_q(0);
phs_med_reg_d(0)	<=	phs_med_in when en_phs_med_reg = '1' else phs_med_reg_q(0);
phs_lrg_reg_d(0)	<=	phs_lrg_in when en_phs_lrg_reg = '1' else phs_lrg_reg_q(0);
phs_xlrg_reg_d(0)	<=	phs_xlrg_in when en_phs_xlrg_reg = '1' else phs_xlrg_reg_q(0);
	
phs_reg_gen_i: for i in 1 to 8 generate
	phs_sml_reg_d(i)	<=	phs_sml_reg_q(i-1) when en_phs_sml_reg = '1' else phs_sml_reg_q(i);
	phs_med_reg_d(i)	<=	phs_med_reg_q(i-1) when en_phs_med_reg = '1' else phs_med_reg_q(i);	
	phs_lrg_reg_d(i)	<=	phs_lrg_reg_q(i-1) when en_phs_lrg_reg = '1' else phs_lrg_reg_q(i);	
	phs_xlrg_reg_d(i)	<=	phs_xlrg_reg_q(i-1) when en_phs_xlrg_reg = '1' else phs_xlrg_reg_q(i);
end generate;

phs_diff_sml_d			<=	std_logic_vector(signed(phs_sml_reg_q(8)(17)&phs_sml_reg_q(8)) - signed(phs_sml_reg_q(0)(17)&phs_sml_reg_q(0)));
phs_diff_med_d			<=	std_logic_vector(signed(phs_med_reg_q(8)(17)&phs_med_reg_q(8)) - signed(phs_med_reg_q(0)(17)&phs_med_reg_q(0)));
phs_diff_lrg_d			<=	std_logic_vector(signed(phs_lrg_reg_q(8)(17)&phs_lrg_reg_q(8)) - signed(phs_lrg_reg_q(0)(17)&phs_lrg_reg_q(0)));
phs_diff_xlrg_d		<=	std_logic_vector(signed(phs_xlrg_reg_q(8)(17)&phs_xlrg_reg_q(8)) - signed(phs_xlrg_reg_q(4)(17)&phs_xlrg_reg_q(4)));

process(clock, reset)
begin
	if(reset = '0') then
		freq_count_q		<=	(others	=>	'0');
		phs_sml_reg_q		<=	(others	=>	(others	=>	'0'));
		phs_med_reg_q		<=	(others	=>	(others	=>	'0'));
		phs_lrg_reg_q		<=	(others	=>	(others	=>	'0'));
		phs_xlrg_reg_q		<=	(others	=>	(others	=>	'0'));
		phs_diff_sml_q		<=	(others	=>	'0');
		phs_diff_med_q		<=	(others	=>	'0');
		phs_diff_lrg_q		<=	(others	=>	'0');
		phs_diff_xlrg_q	<=	(others	=>	'0');
		disc_sml_stp_q		<=	(others	=>	'0');
		disc_med_stp_q		<=	(others	=>	'0');
		disc_lrg_stp_q		<=	(others	=>	'0');
		disc_xlrg_stp_q	<=	(others	=>	'0');
		sel_q					<=	0;
		disc_stp				<=	(others	=>	'0');
		disc_int				<=	(others	=>	(others	=>	'0'));
		disc_out				<=	(others	=>	(others	=>	'0'));
	elsif(rising_edge(clock)) then
		if(load = '1') then
			freq_count_q		<=	freq_count_d;
			phs_sml_reg_q		<=	phs_sml_reg_d;
			phs_med_reg_q		<=	phs_med_reg_d;
			phs_lrg_reg_q		<=	phs_lrg_reg_d;
			phs_xlrg_reg_q		<=	phs_xlrg_reg_d;
			phs_diff_sml_q		<=	phs_diff_sml_d;
			phs_diff_med_q		<=	phs_diff_med_d;
			phs_diff_lrg_q		<=	phs_diff_lrg_d;
			phs_diff_xlrg_q	<=	phs_diff_xlrg_d;
			disc_sml_stp_q		<=	disc_sml_stp_d;
			disc_med_stp_q		<=	disc_med_stp_d;
			disc_lrg_stp_q		<=	disc_lrg_stp_d;
			disc_xlrg_stp_q	<=	disc_xlrg_stp_d;
			sel_q					<=	sel_d;
			disc_stp				<=	disc_stp_d;
			disc_int(3)			<=	disc_int_flt(3)(17 downto 2);
			disc_int(2)			<=	disc_int_flt(2)(17 downto 2);
			disc_int(1)			<=	disc_int_flt(1)(17 downto 2);
			disc_int(0)			<=	disc_int_flt(0)(17 downto 2);
			disc_out				<=	disc_int_flt;
		end if;
	end if;
end process;
----------------------------------------iir filters for discriminators----------------------------
iir_lpfk9_disc_smal: entity work.iir_lpfk11
port map(clock 	=>	clock,
			reset 	=>	reset,
			load		=>	en_phs_sml_reg,
			d_in		=>	phs_diff_sml_q(17 downto 0),
			d_out		=>	disc_int_flt(0),
			ld_out	=>	open
			);
iir_lpfk5_disc_med: entity work.iir_lpfk7
port map(clock 	=>	clock,
			reset 	=>	reset,
			load		=>	en_phs_med_reg,
			d_in		=>	phs_diff_med_q(17 downto 0),
			d_out		=>	disc_int_flt(1)
			);
iir_lpfk9_disc_lrg: entity work.iir_lpfk11
port map(clock 	=>	clock,
			reset 	=>	reset,
			load		=>	en_phs_lrg_reg,
			d_in		=>	phs_diff_lrg_q(17 downto 0),
			d_out		=>	disc_int_flt(2),
			ld_out	=>	open
			);
iir_lpfk9_disc_xlrg: entity work.iir_lpfk11
port map(clock 	=>	clock,
			reset 	=>	reset,
			load		=>	en_phs_xlrg_reg,
			d_in		=>	phs_diff_xlrg_q(17 downto 0),
			d_out		=>	disc_int_flt(3),
			ld_out	=>	open
			);

--disc_int(0)		<=	phs_diff_sml_q(17 downto 2);
--disc_int(1)		<=	phs_diff_med_q(17 downto 2);
--disc_int(2)		<=	phs_diff_lrg_q(17 downto 2);
--disc_int(3)		<=	phs_diff_xlrg_q(17 downto 2);

--disc_out		<=	disc_int;

--disc_stp			<=	disc_stp_q;	

-------------------------------28 bit discriminator for stepper control------------------------------
--disc_sml_stp_d(27 downto 16)		<=	(others	=>	phs_diff_sml_q(17));
--disc_sml_stp_d(15 downto 0)		<=	phs_diff_sml_q(17 downto 2);
--
--disc_med_stp_d(27 downto 20)		<=	(others	=>	phs_diff_med_q(17));
--disc_med_stp_d(19 downto 4)		<=	phs_diff_med_q(17 downto 2);
--disc_med_stp_d(3 downto 0)			<=	x"0";
--
--disc_lrg_stp_d(27 downto 24)		<=	(others	=>	phs_diff_lrg_q(17));
--disc_lrg_stp_d(23 downto 8)		<=	phs_diff_lrg_q(17 downto 2);
--disc_lrg_stp_d(7 downto 0)			<=	x"00";
--
--disc_xlrg_stp_d(27 downto 12)		<=	phs_diff_xlrg_q(17 downto 2);
--disc_xlrg_stp_d(11 downto 0)		<=	x"000";
disc_sml_stp_d(27 downto 16)		<=	(others	=>	disc_int_flt(0)(17));
disc_sml_stp_d(15 downto 0)		<=	disc_int_flt(0)(17 downto 2);

disc_med_stp_d(27 downto 20)		<=	(others	=>	disc_int_flt(1)(17));
disc_med_stp_d(19 downto 4)		<=	disc_int_flt(1)(17 downto 2);
disc_med_stp_d(3 downto 0)			<=	x"0";

disc_lrg_stp_d(27 downto 24)		<=	(others	=>	disc_int_flt(2)(17));
disc_lrg_stp_d(23 downto 8)		<=	disc_int_flt(2)(17 downto 2);
disc_lrg_stp_d(7 downto 0)			<=	x"00";

disc_xlrg_stp_d(27 downto 12)		<=	disc_int_flt(3)(17 downto 2);
disc_xlrg_stp_d(11 downto 0)		<=	x"000";


sel_d			<=	3 when (disc_int(3) < x"0007" or disc_int(3) > x"fff8") and (disc_int(2) < x"006c" or disc_int(2) > x"ff93") and (disc_int(1) < x"06be" or disc_int(1) > x"f941") else
					2 when (disc_int(3) < x"006c" or disc_int(3) > x"ff93") and (disc_int(2) < x"06be" or disc_int(2) > x"f941") else
					1 when (disc_int(3) < x"06be" or disc_int(3) > x"f941") else
					0;
					
with sel_q select
	disc_stp_d		<=	disc_sml_stp_q when 3,
							disc_med_stp_q when 2,
							disc_lrg_stp_q when 1,
							disc_xlrg_stp_q when others;

end architecture behavior;