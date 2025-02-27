library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xylim is
	port(clock	:	in std_logic;
		reset		:	in std_logic;
		load		:	in std_logic;
		xin		:	in std_logic_vector(17 downto 0);
		yin		:	in std_logic_vector(17 downto 0);
		xlimhi	:	in std_logic_vector(17 downto 0);
		xlimlo	:	in std_logic_vector(17 downto 0);
		ylimhi	:	in std_logic_vector(17 downto 0);
		ylimlo	:	in std_logic_vector(17 downto 0);
		beam_fsd	:	in std_logic;
		xout		:	out std_logic_vector(17 downto 0);
		yout		:	out std_logic_vector(17 downto 0);
		xstat		:	out std_logic_vector(1 downto 0);--------'0' is xin < xlimlo, '1' is xin > xlimhi
		ystat		:	out std_logic_vector(1 downto 0)--------'0' is yin < ylimlo, '1' is yin > ylimhi
		);
end entity xylim;
architecture behavior of xylim is
signal xout_d							:	std_logic_vector(17 downto 0);
signal yout_d							:	std_logic_vector(17 downto 0);
signal xstat_d							:	std_logic_vector(1 downto 0);
signal ystat_d							:	std_logic_vector(1 downto 0);
signal xlimhi_d, xlimhi_q			:	std_logic_vector(17 downto 0);


signal xstat_buf		:	std_logic_vector(1 downto 0);
signal beam_fsd_q		:	std_logic;
begin
process(clock, reset)
begin
	if(reset =  '0') then
		xout				<=	(others	=>	'0');
		yout				<=	(others	=>	'0');
		xstat				<=	(others	=>	'0');
		xstat_buf		<=	(others	=>	'0');
		ystat				<=	(others	=>	'0');
		xlimhi_q			<=	(others	=>	'0');
		beam_fsd_q		<=	'1';
	elsif(rising_edge(clock)) then
		if(load = '1') then
			xout			<=	xout_d;
			yout			<=	yout_d;
			xstat			<=	xstat_d;
			xstat_buf	<=	xstat_d;
			ystat			<=	ystat_d;
			xlimhi_q		<=	xlimhi_d;
			beam_fsd_q	<=	beam_fsd;
		end if;
	end if;
end process;

xlimhi_d	<=	xlimlo when beam_fsd_q = '0' else xlimhi;

xout_d	<=	xlimhi_q when signed(xin) > signed(xlimhi) else
				(others	=>	'0') when signed(xin) < "00"&x"0000" else
				xin;
yout_d	<=	ylimhi when signed(yin) > signed(ylimhi) else
				ylimlo when signed(yin) < signed(ylimlo) else
				yin;
xstat_d(0)	<=	'1' when signed(xin) < signed(xlimlo) else '0';
xstat_d(1)	<=	'1' when signed(xin) > signed(xlimhi) else '0';
ystat_d(0)	<=	'1' when signed(yin) < signed(ylimlo) else '0';
ystat_d(1)	<=	'1' when signed(yin) > signed(ylimhi) else '0';
end architecture behavior;	
	