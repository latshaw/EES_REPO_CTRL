library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use work.all;

entity noniq_adc is
port(clock		:	in std_logic;
		reset		:	in std_logic;
		
		pll_lock	:	in std_logic;
		prb_in	:	in std_logic_vector(15 downto 0);
		fwd_in	:	in std_logic_vector(15 downto 0);
		ref_in	:	in std_logic_vector(15 downto 0);
		
		prb_i		:	out std_logic_vector(15 downto 0);
		prb_q		:	out std_logic_vector(15 downto 0);
		fwd_i		:	out std_logic_vector(15 downto 0);
		fwd_q		:	out std_logic_vector(15 downto 0);
		ref_i		:	out std_logic_vector(15 downto 0);
		ref_q		:	out std_logic_vector(15 downto 0);
		refi_flt	:	out std_logic_vector(15 downto 0);
		refq_flt	:	out std_logic_vector(15 downto 0)
		);
end entity noniq_adc;
architecture behavior of noniq_adc is

--signal prbyn_d				:	std_logic_vector(15 downto 0);
--signal prbyn_q				:	std_logic_vector(15 downto 0);
--signal prbynp1_d			:	std_logic_vector(15 downto 0);
--signal prbynp1_q			:	std_logic_vector(15 downto 0);


------y(n) and y(n+1) are two successive samples
------I = sin(n+1) y(n) - sin(n) y(n+1)
------Q = cos(n) y(n+1) - cos(n+1) y(n)

type reg17_4 is array(3 downto 0) of std_logic_vector(16 downto 0);

signal pll_lock_d				:	std_logic;
signal pll_lock_q				:	std_logic;
signal count_d					:	std_logic_vector(2 downto 0);
signal count_q					:	std_logic_vector(2 downto 0);
signal prbiq_in_d				:	std_logic_vector(15 downto 0);
signal prbiq_in_q				:	std_logic_vector(15 downto 0);
signal prb_ext					:	std_logic_vector(16 downto 0);
signal prb_ext_2c				:	std_logic_vector(16 downto 0);
signal prb_sel					:	std_logic_vector(16 downto 0);
signal en_prbi					:	std_logic_vector(3 downto 0);
signal en_prbq					:	std_logic_vector(3 downto 0);
signal prbi_reg_d				:	reg17_4;
signal prbi_reg_q				:	reg17_4;
signal prbq_reg_d				:	reg17_4;
signal prbq_reg_q				:	reg17_4;

signal fwdiq_in_d				:	std_logic_vector(15 downto 0);
signal fwdiq_in_q				:	std_logic_vector(15 downto 0);
signal fwd_ext					:	std_logic_vector(16 downto 0);
signal fwd_ext_2c				:	std_logic_vector(16 downto 0);
signal fwd_sel					:	std_logic_vector(16 downto 0);
signal en_fwdi					:	std_logic_vector(3 downto 0);
signal en_fwdq					:	std_logic_vector(3 downto 0);
signal fwdi_reg_d				:	reg17_4;
signal fwdi_reg_q				:	reg17_4;
signal fwdq_reg_d				:	reg17_4;
signal fwdq_reg_q				:	reg17_4;

signal refiq_in_d				:	std_logic_vector(15 downto 0);
signal refiq_in_q				:	std_logic_vector(15 downto 0);
signal ref_ext					:	std_logic_vector(16 downto 0);
signal ref_ext_2c				:	std_logic_vector(16 downto 0);
signal ref_sel					:	std_logic_vector(16 downto 0);
signal en_refi					:	std_logic_vector(3 downto 0);
signal en_refq					:	std_logic_vector(3 downto 0);
signal refi_reg_d				:	reg17_4;
signal refi_reg_q				:	reg17_4;
signal refq_reg_d				:	reg17_4;
signal refq_reg_q				:	reg17_4;

signal load_iir				:	std_logic;

component IIR7_SIMPLE IS
PORT(CLOCK 	: IN STD_LOGIC;
	  RESET 	: IN STD_LOGIC;
	  LOAD	: IN STD_LOGIC;
	  I		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
	  O		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	  );
end component;	  

begin

-------------look up table for 70 MHz sampling with 112 MHz clock (35 MHz sampling with 56 MHz clock)
----
--sin_lut(0) <= (others => '0');
--sin_lut(1) <= "10" & x"95f";
--sin_lut(2) <= "01" & x"fff";
--sin_lut(3) <= "10" & x"95f";
--sin_lut(4) <= (others => '0');
--sin_lut(5) <= "01" & x"6a1";
--sin_lut(6) <= "10" & x"000";
--sin_lut(7) <= "01" & x"6a1";
--
--cos_lut(0) <= "01" & x"fff";
--cos_lut(1) <= "10" & x"95f";
--cos_lut(2) <= (others => '0');
--cos_lut(3) <= "01" & x"6a1";
--cos_lut(4) <= "10" & x"000";
--cos_lut(5) <= "01" & x"6a1";
--cos_lut(6) <= (others => '0');
--cos_lut(7) <= "10" & x"95f";
-------------end of look up table for 70 MHz sampling with 112 MHz clock
--
----------probe registers------
--
--prbyn_d		<=	prb_in;
--prbynp1_d	<=	prbyn_q;

pll_lock_d	<=	pll_lock;
------------------------------------SAMPLING 70 MHz IF REFERENCE WITH 112 MHz--------------------------------
count_d					<= (others => '0') when pll_lock_q = '0' else
							count_q + '1';
	
prbiq_in_d				<= prb_in;

prb_ext(16) 			<= prbiq_in_q(15);
prb_ext(15 downto 0) <= prbiq_in_q;

prb_ext_2c 				<= not (prb_ext) + '1';

en_prbi(0) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_prbi(1) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_prbi(2) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_prbi(3) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';

prb_sel 				<= prb_ext when count_q(2) = '0' else prb_ext_2c;
	
	
prbi_reg_d(0)			<= prb_sel when en_prbi(0) = '1' else prbi_reg_q(0);
prbi_reg_d(1) 			<= prbi_reg_q(0) when en_prbi(1) = '1' else prbi_reg_q(1);
prbi_reg_d(2) 			<= (prbi_reg_q(0) + prbi_reg_q(1)) when en_prbi(2) = '1' else prbi_reg_q(2);
prbi_reg_d(3)			<= prbi_reg_q(2) when en_prbi(3) = '1' else prbi_reg_q(3);
prb_i					<= prbi_reg_q(3)(16 downto 1);

en_prbq(0) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_prbq(1) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_prbq(2) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_prbq(3) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';

prbq_reg_d(0)			<= prb_sel when en_prbq(0) = '1' else prbq_reg_q(0);
prbq_reg_d(1) 			<= prbq_reg_q(0) when en_prbq(1) = '1' else prbq_reg_q(1);
prbq_reg_d(2) 			<= (prbq_reg_q(0) + prbq_reg_q(1)) when en_prbq(2) = '1' else prbq_reg_q(2);
prbq_reg_d(3)			<= prbq_reg_q(2) when en_prbq(3) = '1' else prbq_reg_q(3);
prb_q					<= prbq_reg_q(3)(16 downto 1);


fwdiq_in_d				<= fwd_in;

fwd_ext(16) 			<= fwdiq_in_q(15);
fwd_ext(15 downto 0) <= fwdiq_in_q;

fwd_ext_2c 				<= not (fwd_ext) + '1';

en_fwdi(0) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_fwdi(1) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_fwdi(2) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_fwdi(3) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';

fwd_sel 				<= fwd_ext when count_q(2) = '0' else fwd_ext_2c;
	
	
fwdi_reg_d(0)			<= fwd_sel when en_fwdi(0) = '1' else fwdi_reg_q(0);
fwdi_reg_d(1) 			<= fwdi_reg_q(0) when en_fwdi(1) = '1' else fwdi_reg_q(1);
fwdi_reg_d(2) 			<= (fwdi_reg_q(0) + fwdi_reg_q(1)) when en_fwdi(2) = '1' else fwdi_reg_q(2);
fwdi_reg_d(3)			<= fwdi_reg_q(2) when en_fwdi(3) = '1' else fwdi_reg_q(3);
fwd_i					<= fwdi_reg_q(3)(16 downto 1);

en_fwdq(0) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_fwdq(1) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_fwdq(2) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_fwdq(3) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';

fwdq_reg_d(0)			<= fwd_sel when en_fwdq(0) = '1' else fwdq_reg_q(0);
fwdq_reg_d(1) 			<= fwdq_reg_q(0) when en_fwdq(1) = '1' else fwdq_reg_q(1);
fwdq_reg_d(2) 			<= (fwdq_reg_q(0) + fwdq_reg_q(1)) when en_fwdq(2) = '1' else fwdq_reg_q(2);
fwdq_reg_d(3)			<= fwdq_reg_q(2) when en_fwdq(3) = '1' else fwdq_reg_q(3);
fwd_q						<= fwdq_reg_q(3)(16 downto 1);

refiq_in_d				<= ref_in;

ref_ext(16) 			<= refiq_in_q(15);
ref_ext(15 downto 0) <= refiq_in_q;

ref_ext_2c 				<= not (ref_ext) + '1';

en_refi(0) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_refi(1) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_refi(2) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "00" else '0';
en_refi(3) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';

ref_sel 				<= ref_ext when count_q(2) = '0' else ref_ext_2c;
	
	
refi_reg_d(0)			<= ref_sel when en_refi(0) = '1' else refi_reg_q(0);
refi_reg_d(1) 			<= refi_reg_q(0) when en_refi(1) = '1' else refi_reg_q(1);
refi_reg_d(2) 			<= (refi_reg_q(0) + refi_reg_q(1)) when en_refi(2) = '1' else refi_reg_q(2);
refi_reg_d(3)			<= refi_reg_q(2) when en_refi(3) = '1' else refi_reg_q(3);
ref_i					<= refi_reg_q(3)(16 downto 1);

en_refq(0) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_refq(1) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_refq(2) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';
en_refq(3) <= '1' when pll_lock_q = '1' and count_q(1 downto 0) = "10" else '0';

refq_reg_d(0)			<= ref_sel when en_refq(0) = '1' else refq_reg_q(0);
refq_reg_d(1) 			<= refq_reg_q(0) when en_refq(1) = '1' else refq_reg_q(1);
refq_reg_d(2) 			<= (refq_reg_q(0) + refq_reg_q(1)) when en_refq(2) = '1' else refq_reg_q(2);
refq_reg_d(3)			<= refq_reg_q(2) when en_refq(3) = '1' else refq_reg_q(3);
ref_q						<= refq_reg_q(3)(16 downto 1);



process(clock, reset)
begin
	if (reset = '0') then
		pll_lock_q	<=	'0';
		count_q		<=	(others => '0');
		prbi_reg_q	<=	(others => (others =>'0'));
		prbq_reg_q	<=	(others => (others =>'0'));
		prbiq_in_q	<=	(others => '0');
		fwdi_reg_q	<=	(others => (others =>'0'));
		fwdq_reg_q	<=	(others => (others =>'0'));
		fwdiq_in_q	<=	(others => '0');
		refi_reg_q	<=	(others => (others =>'0'));
		refq_reg_q	<=	(others => (others =>'0'));
		refiq_in_q	<=	(others => '0');
	elsif(rising_edge(clock)) then
		pll_lock_q	<=	pll_lock_d;
		count_q		<=	count_d;
		prbi_reg_q	<=	prbi_reg_d;
		prbq_reg_q	<=	prbq_reg_d;
		prbiq_in_q	<= prbiq_in_d;
		fwdi_reg_q	<=	fwdi_reg_d;
		fwdq_reg_q	<=	fwdq_reg_d;
		fwdiq_in_q	<= fwdiq_in_d;
		refi_reg_q	<=	refi_reg_d;
		refq_reg_q	<=	refq_reg_d;
		refiq_in_q	<= refiq_in_d;

	end if;
end process;

load_iir		<=	'1' when count_q(1 downto 0) = "10" else '0';

refi_flt_iir: IIR7_SIMPLE
port map(CLOCK 	=>	clock,
			RESET 	=>	reset,
			LOAD		=>	load_iir,
			I			=>	refi_reg_q(3)(16 downto 1),
			O			=>	refi_flt
			);
refq_flt_iir: IIR7_SIMPLE
port map(CLOCK 	=>	clock,
			RESET 	=>	reset,
			LOAD		=>	load_iir,
			I			=>	refq_reg_q(3)(16 downto 1),
			O			=>	refq_flt
			);				





--------------------------------END OF SAMPLING 70 MHz IF REFERENCE---------------------------------------------------

	


end architecture behavior;		
