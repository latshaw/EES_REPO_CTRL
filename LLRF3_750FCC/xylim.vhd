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
		xout		:	out std_logic_vector(17 downto 0);
		yout		:	out std_logic_vector(17 downto 0);
		xstat		:	out std_logic_vector(1 downto 0);--------'0' is xin < xlimlo, '1' is xin > xlimhi
		ystat		:	out std_logic_vector(1 downto 0)--------'0' is yin < ylimlo, '1' is yin > ylimhi
		);
end entity xylim;
architecture behavior of xylim is
signal xout_d			:	std_logic_vector(17 downto 0);
signal yout_d			:	std_logic_vector(17 downto 0);
signal xstat_d			:	std_logic_vector(1 downto 0);
signal ystat_d			:	std_logic_vector(1 downto 0);
begin
process(clock, reset)
begin
	if(reset =  '0') then
		xout	<=	(others	=>	'0');
		yout	<=	(others	=>	'0');
		xstat	<=	(others	=>	'0');
		ystat	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			xout	<=	xout_d;
			yout	<=	yout_d;
			xstat	<=	xstat_d;
			ystat	<=	ystat_d;
		end if;
	end if;
end process;

xout_d	<=	xlimhi when signed(xin) > signed(xlimhi) else
				xlimlo when signed(xin) < signed(xlimlo) else
				xin;
yout_d	<=	ylimhi when signed(yin) > signed(ylimhi) else
				ylimlo when signed(yin) < signed(ylimlo) else
				yin;
xstat_d(0)	<=	'1' when signed(xin) < signed(xlimlo) else '0';
xstat_d(1)	<=	'1' when signed(xin) > signed(xlimhi) else '0';
ystat_d(0)	<=	'1' when signed(yin) < signed(ylimlo) else '0';
ystat_d(1)	<=	'1' when signed(yin) > signed(ylimhi) else '0';
end architecture behavior;	
	