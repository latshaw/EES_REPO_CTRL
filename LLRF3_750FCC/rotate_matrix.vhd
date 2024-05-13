library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rotate_matrix is
	port(clock	:	in std_logic;
		reset		:	in std_logic;
		load		:	in std_logic;		
		xin		:	in std_logic_vector(17 downto 0);
		yin		:	in std_logic_vector(17 downto 0);
		cos		:	in std_logic_vector(17 downto 0);
		sin		:	in std_logic_vector(17 downto 0);
		xout		:	out std_logic_vector(17 downto 0);
		yout		:	out std_logic_vector(17 downto 0)
		);
end entity rotate_matrix;
architecture behavior of rotate_matrix is
signal xincos_d, xincos_q			:	std_logic_vector(35 downto 0);
signal xinsin_d, xinsin_q			:	std_logic_vector(35 downto 0);
signal yincos_d, yincos_q			:	std_logic_vector(35 downto 0);
signal yinsin_d, yinsin_q			:	std_logic_vector(35 downto 0);
signal xoutint_d, xoutint_q		:	std_logic_vector(36 downto 0);
signal youtint_d, youtint_q		:	std_logic_vector(36 downto 0);
signal xout_d, xout_q				:	std_logic_vector(17 downto 0);
signal yout_d, yout_q				:	std_logic_vector(17 downto 0);
begin	
xincos_d		<=	std_logic_vector(signed(xin)*signed(cos));
xinsin_d		<=	std_logic_vector(signed(xin)*signed(sin));
yincos_d		<=	std_logic_vector(signed(yin)*signed(cos));
yinsin_d		<=	std_logic_vector(signed(yin)*signed(sin));
xoutint_d	<=	std_logic_vector(signed(xincos_q(35) & xincos_q) - signed(yinsin_q(35) & yinsin_q));
youtint_d	<=	std_logic_vector(signed(xinsin_q(35) & xinsin_q) + signed(yincos_q(35) & yincos_q));
xout_d		<=	"01"&x"ffff" when xoutint_q(36) = '0' and xoutint_q(35 downto 34) = "11" else
					"10"&x"0000" when xoutint_q(36) = '1' and xoutint_q(35 downto 34) = "00" else
					xoutint_q(34 downto 17);
yout_d		<=	"01"&x"ffff" when youtint_q(36) = '0' and youtint_q(35 downto 34) = "11" else
					"10"&x"0000" when youtint_q(36) = '1' and youtint_q(35 downto 34) = "00" else
					youtint_q(34 downto 17);				
xout			<=	xout_q;
yout			<=	yout_q;
process(clock, reset)
begin
	if(reset = '0') then
		xincos_q	<=	(others	=>	'0');	
		xinsin_q	<=	(others	=>	'0');	
		yincos_q	<=	(others	=>	'0');	
		yinsin_q	<=	(others	=>	'0');
		xoutint_q	<=	(others	=>	'0');
		youtint_q	<=	(others	=>	'0');
		xout_q		<=	(others	=>	'0');
		yout_q		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(load = '1') then
			xincos_q	<=	xincos_d;	
			xinsin_q	<=	xinsin_d;	
			yincos_q	<=	yincos_d;	
			yinsin_q	<=	yinsin_d;
			xoutint_q	<=	xoutint_d;
			youtint_q	<=	youtint_d;
			xout_q		<=	xout_d;
			yout_q		<=	yout_d;
		end if;	
	end if;
end process;	
		
	
	
end architecture behavior;