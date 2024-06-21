--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity reset_all is
--	port(clock	:	in	std_logic;
--			brd	:	in	std_logic;------board reset pin
--			reg	:	in	std_logic;------register reset from epics
--			pll	:	in	std_logic;------reset until pll config is done
--			
--			pllrst	:	out std_logic;------reset for the cdcm7005 block
--			fwrst		:	out std_logic-------reset for the whole firmware
--			);
--end entity reset_all;
--architecture behavior of reset_all is
--type reg_record is record
--rst_cnt	:	integer range 0 to 4095;
--fwrst		:	std_logic;
--end record;
--signal d,q		:	reg_record;
--signal reset	:	std_logic;
--begin
--
--d.rst_cnt	<=	q.rst_cnt + 1 when q.rst_cnt /= 4095 else
--					q.rst_cnt;
--
--d.fwrst		<=	'1' when q.rst_cnt = 4095 else '0';
--
--
--reset			<=	brd and reg and pll;
--pllrst		<=	brd and reg;
--
--process(clock, reset)
--begin
--	if(reset = '0') then
--		q.rst_cnt	<=	0;
--		q.fwrst		<=	'0';
--	elsif(rising_edge(clock)) then
--		q				<=	d;
--	end if;
--end process;
--
--
--fwrst		<=	q.fwrst;	
--
--
--end architecture behavior;			
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reset_all is
	port(clock	:	in	std_logic;
			brd	:	in	std_logic;------board reset pin
			reg	:	in	std_logic;------register reset from epics
			pll	:	in	std_logic;------reset until pll config is done
			
			pllrst	:	out std_logic;------reset for the cdcm7005 block
			fwrst		:	out std_logic-------reset for the whole firmware
			);
end entity reset_all;
architecture behavior of reset_all is

signal rst_cnt_d, rst_cnt_q	:	unsigned(11 downto 0);
signal pllrst_d, pllrst_q		:	std_logic;
signal fwrst_d, fwrst_q			:	std_logic;


begin

rst_cnt_d	<=	rst_cnt_q + 1 when rst_cnt_q /= x"fff" else
					rst_cnt_q;
					
					
process(clock, brd)
begin
	if(brd = '0') then
		rst_cnt_q	<=	(others	=>	'0');		
		fwrst_q		<=	'0';
		pllrst_q		<=	'0';
	elsif(rising_edge(clock)) then
		rst_cnt_q	<=	rst_cnt_d;
		fwrst_q		<=	fwrst_d;
		pllrst_q		<=	pllrst_d;
		
	end if;
end process;					
					
					

fwrst_d		<=	'0' when rst_cnt_q < x"fff" or reg = '0' or pllrst = '0' else '1';
pllrst_d		<=	'0' when reg = '0' else '1';



pllrst	<=	pllrst_q;
fwrst		<=	fwrst_q;	


end architecture behavior;			
			
			