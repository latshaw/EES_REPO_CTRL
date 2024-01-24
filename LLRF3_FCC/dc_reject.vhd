library ieee;
use ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.ALL;


entity dc_reject is
port(clock 	: in std_logic;
	  reset 	: in std_logic;
	  ld_data	:	in std_logic;
	  d_in	: 	in std_logic_vector(15 downto 0);
	  d_out	:	out std_logic_vector(15 downto 0)
	  );	  
end entity dc_reject;

architecture behavior of dc_reject is

signal i_ext			: 	std_logic_vector(34 downto 0);
signal reg_shift		: 	std_logic_vector(34 downto 0);
signal reg_in			: 	std_logic_vector(34 downto 0);
signal reg_out			: 	std_logic_vector(34 downto 0);
signal O_int_d			: 	std_logic_vector(15 downto 0);
signal O_int_q			: 	std_logic_vector(15 downto 0);
signal dc_reject_d	:	std_logic_vector(17 downto 0);
signal dc_reject_q	:	std_logic_vector(17 downto 0);
signal d_in_d			:	std_logic_vector(15 downto 0);
signal d_in_q			:	std_logic_vector(15 downto 0);
signal d_out_d			:	std_logic_vector(15 downto 0);
signal d_out_q			:	std_logic_vector(15 downto 0);

begin
d_in_d						<=	d_in;
-- extend the input to 33 bits
i_ext(34 downto 16) 		<= (others => d_in_q(15));
i_ext(15 downto 0)  		<= d_in_q;
reg_in 						<= reg_out - reg_shift + i_ext;
reg_shift(34 downto 17) <= (others => reg_out(34));
reg_shift(16 downto 0)  <= reg_out(34 downto 18);
o_int_d 						<= X"7fff" when reg_out(34) = '0' AND reg_out(33) /= '0' else
									X"8000" when reg_out(34) = '1' AND reg_out(33) /= '1' else
									reg_out(33 downto 18);
									
dc_reject_d					<=	(d_in_q(15) & d_in_q(15) & d_in_q) - (o_int_q(15) &	o_int_q(15) & o_int_q);								
d_out_d						<=	x"7fff" when dc_reject_q(17) = '0' and dc_reject_q(16 downto 15) /= "00" else
									x"8000" when dc_reject_q(17) = '1' and dc_reject_q(16 downto 15) /= "11" else	
									dc_reject_q(15 downto 0);
d_out							<=	d_out_q;									
process(clock, reset)
begin
	if(reset	= '0') then
		reg_out		<=	(others	=>	'0');
		d_in_q		<=	(others	=>	'0');
		d_out_q		<=	(others	=>	'0');
		o_int_q		<=	(others	=>	'0');
		dc_reject_q	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		if(ld_data = '1') then
			reg_out		<=	reg_in;
			d_in_q		<=	d_in_d;
			d_out_q		<=	d_out_d;
			o_int_q		<=	o_int_d;
			dc_reject_q	<=	dc_reject_d;
		end if;	
	end if;
end process;	
				  
end architecture behavior;