library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pi_control is
	port(clock		:	in std_logic;
		reset			:	in std_logic;
		load			:	in std_logic;
		rfon			:	in	std_logic;
		mploop		:	in std_logic_vector(1 downto 0);
		set			:	in std_logic_vector(17 downto 0);
		mes			:	in std_logic_vector(17 downto 0);
		pgain			:	in std_logic_vector(15 downto 0);
		igain			:	in std_logic_vector(15 downto 0);
		irate			:	in std_logic_vector(15 downto 0);
		pi_out		:	out std_logic_vector(17 downto 0)
		);
end entity pi_control;
architecture behavior of pi_control is
signal rfon_d, rfon_q			:	std_logic_vector(1 downto 0);
signal err_d, err_q				:	std_logic_vector(18 downto 0);
signal err_ext_d, err_ext_q	:	std_logic_vector(34 downto 0);
signal err_ext_int				:	std_logic_vector(34 downto 0);
signal pmul_d, pmul_q			:	std_logic_vector(34 downto 0);
signal iadd_d, iadd_q			:	std_logic_vector(18 downto 0);
signal i_load						:	std_logic;
signal i_load_d, i_load_q		:	std_logic_vector(24 downto 0);
signal iclip_d, iclip_q			:	std_logic_vector(17 downto 0);
signal imul_d, imul_q			:	std_logic_vector(33 downto 0);
signal pi_add_d, pi_add_q		:	std_logic_vector(34 downto 0);
signal pi_out_d					:	std_logic_vector(17 downto 0);
signal mploop_q					:	std_logic_vector(1 downto 0);
begin
rfon_d(0)		<=	rfon;
rfon_d(1)		<=	rfon_q(0);


err_d		<=	std_logic_vector(signed(set(17)&set) - signed(mes(17)&mes));
pmul_d		<=	std_logic_vector(signed(err_q)*signed(pgain));


i_load_d		<=	(others	=>	'0') when i_load_q(24 downto 9) = irate else
					std_logic_vector(unsigned(i_load_q) + 1) when irate /= x"0000" else
					i_load_q;


-----------------------------------------------------------------------------------------------------------------
i_load							<=	'1' when i_load_q = '0'&x"000000" and irate /= x"0000" else '0';				
iadd_d							<=	(others	=>	'0') when mploop_q /= "10" or rfon_q(1) = '0' else
										std_logic_vector(signed(iadd_q) + signed(err_q)) when i_load = '1' else
										iadd_q;
iclip_d							<=	"01"&x"ffff" when iadd_q(18) = '0' and iadd_q(17) /= '0' else
										"10"&x"0000" when iadd_q(18) = '1' and iadd_q(17) /= '1' else
										iadd_q(17 downto 0);
imul_d							<=	std_logic_vector(signed(iclip_q) * signed(igain));
-----------------------------------------------------------------------------------------------------------------
pi_add_d							<=	std_logic_vector(signed(imul_q(33)&imul_q) + signed(pmul_q));

pi_out_d	<=	"01"&x"ffff" when pi_add_q(34) = '0' and pi_add_q(33 downto 17) /= '0'&x"0000" else
				"10"&x"0000" when pi_add_q(34) = '1' and pi_add_q(33 downto 17) /= '1'&x"ffff" else
				pi_add_q(17 downto 0);										

				
process(clock, reset)
begin
	if(reset = '0') then
		err_q			<=	(others	=>	'0');
		pmul_q		<=	(others	=>	'0');		
		i_load_q		<=	(others	=>	'0');
		iadd_q		<=	(others	=>	'0');
		iclip_q		<=	(others	=>	'0');
		imul_q		<=	(others	=>	'0');
		pi_add_q		<=	(others	=>	'0');
		pi_out		<=	(others	=>	'0');
		mploop_q	<=	"00";
		rfon_q		<=	"00";
	elsif(rising_edge(clock)) then
		if(load = '1') then
			err_q			<=	err_d;
			pmul_q		<=	pmul_d;
			i_load_q		<=	i_load_d;
			iadd_q		<=	iadd_d;
			iclip_q		<=	iclip_d;
			imul_q		<=	imul_d;
			pi_add_q		<=	pi_add_d;		
			pi_out		<=	pi_out_d;
			mploop_q	<=	mploop;
			rfon_q		<=	rfon_d;
		end if;		
	end if;	
end process;	
end architecture behavior;