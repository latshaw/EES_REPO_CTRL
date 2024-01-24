library ieee;
use ieee.std_logic_1164.all;

entity dpa_ptrn_match is
	port(clock		:	in std_logic;
		reset		:	in std_logic;
		dpa_locked	:	in std_logic;
		ptrn_in		:	in std_logic_vector(7 downto 0);
		ptrn_tgt	:	in std_logic_vector(7 downto 0);
		dpa_rst		:	out std_logic;
		dpa_hold	:	out std_logic;
		dpa_match	:	out std_logic);
end entity dpa_ptrn_match;
architecture behavior of dpa_ptrn_match is
signal dpa_locked_d		:	std_logic_vector(1 downto 0);
signal dpa_locked_q		:	std_logic_vector(1 downto 0);
signal dpa_init			:	std_logic;
signal ptrn_in_d		:	std_logic_vector(7 downto 0);
signal ptrn_in_q		:	std_logic_vector(7 downto 0);
signal ptrn_tgt_d		:	std_logic_vector(7 downto 0);
signal ptrn_tgt_q		:	std_logic_vector(7 downto 0);
signal dpa_rst_d		:	std_logic_vector(1 downto 0);
signal dpa_rst_q		:	std_logic_vector(1 downto 0);
signal dpa_rst_out_d	:	std_logic;
signal dpa_rst_out_q	:	std_logic;
signal dpa_hold_d		:	std_logic;
signal dpa_hold_q		:	std_logic;
signal dpa_match_d		:	std_logic;
signal dpa_match_q		:	std_logic;
begin
ptrn_tgt_d			<=	ptrn_tgt;
ptrn_in_d			<=	ptrn_in;
--risin edge of dpa_locked	
dpa_locked_d(0)		<=	dpa_locked;
dpa_locked_d(1)		<=	dpa_locked_q(0);
dpa_init			<=	dpa_locked_q(0) and not dpa_locked_q(1);

dpa_rst_d(0)		<=	'1' when dpa_init = '1' and ptrn_in_q /= ptrn_tgt_q else '0';
dpa_rst_d(1)		<=	dpa_rst_q(0);
dpa_rst_out_d		<=	dpa_rst_q(0) and not dpa_rst_q(1);
dpa_rst				<=	dpa_rst_out_q;

dpa_hold_d			<=	'1' when ptrn_in_q = ptrn_tgt_q and dpa_locked_q(1) = '1' else '0';
dpa_hold			<=	dpa_hold_q;

dpa_match_d			<=	'1' when ptrn_in_q = ptrn_tgt_q and dpa_locked_q(1) = '1' else '0';
dpa_match			<=	dpa_match_q;
process(clock, reset)
begin
	if(reset = '0') then
		ptrn_in_q		<=	(others	=>	'0');
		ptrn_tgt_q		<=	(others	=>	'0');
		dpa_locked_q	<=	(others	=>	'0');
		dpa_rst_q		<=	(others	=>	'0');
		dpa_rst_out_q	<=	'0';
		dpa_hold_q		<=	'0';
		dpa_match_q		<=	'0';
	elsif(rising_edge(clock)) then
		ptrn_in_q		<=	ptrn_in_d;
		ptrn_tgt_q		<=	ptrn_tgt_d;
		dpa_locked_q	<=	dpa_locked_d;
		dpa_rst_q		<=	dpa_rst_d;
		dpa_rst_out_q	<=	dpa_rst_out_d;
		dpa_hold_q		<=	dpa_hold_d;
		dpa_match_q		<=	dpa_match_d;
	end if;
end process;	

end architecture behavior;	