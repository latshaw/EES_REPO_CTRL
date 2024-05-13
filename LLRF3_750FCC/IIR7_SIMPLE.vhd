LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY IIR7_SIMPLE IS

PORT(CLOCK 	: IN STD_LOGIC;
	  RESET 	: IN STD_LOGIC;
	  LOAD	: IN STD_LOGIC;
	  I		: IN STD_LOGIC_VECTOR(17 DOWNTO 0);
	  O		: OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
	  );
	  
END ENTITY IIR7_SIMPLE;

ARCHITECTURE BEHAVIOR OF IIR7_SIMPLE IS

SIGNAL I_EXT		: STD_LOGIC_VECTOR(33 DOWNTO 0);
SIGNAL REG_SHIFT	: STD_LOGIC_VECTOR(33 DOWNTO 0);
SIGNAL REG			: STD_LOGIC_VECTOR(33 DOWNTO 0);

SIGNAL reg_out_d		: STD_LOGIC_VECTOR(33 DOWNTO 0);
SIGNAL reg_out_q		: STD_LOGIC_VECTOR(33 DOWNTO 0);

signal o_int_in		:	std_logic_vector(17 downto 0);
signal o_int_d		:	std_logic_vector(17 downto 0);
signal o_int_q		:	std_logic_vector(17 downto 0);



BEGIN





-- extend the input to 30 bits
I_EXT(33 DOWNTO 18) <= (OTHERS => I(17));
I_EXT(17 DOWNTO 0)  <= I;					
reg_out_d	<=	reg_out_q - reg_shift + i_ext when load = '1' else
					reg_out_q;
REG_SHIFT(33 DOWNTO 27) <= (OTHERS => reg_out_q(33));
REG_SHIFT(26 DOWNTO 0)  <= reg_out_q(33 DOWNTO 7);			
o_int_in <=	"01"&X"FFFF" WHEN reg_out_q(33) = '0' AND reg_out_q(32 DOWNTO 24) /= '0'&x"00" ELSE
				"10"&X"0000" WHEN reg_out_q(33) = '1' AND reg_out_q(32 DOWNTO 24) /= '1'&x"ff" ELSE
				reg_out_q(24 DOWNTO 7);
o_int_d	<=	o_int_in when load = '1' else
				o_int_q;
o	<=	o_int_q;		
process(clock, reset)
begin
	if(reset = '0') then
		reg_out_q	<=	(others => '0');
		O_int_q		<=	(others => '0');		
	elsif(rising_edge(clock)) then
		reg_out_q	<=	reg_out_d;
		o_int_q		<=	o_int_d;
	end if;
end process;
				  
END ARCHITECTURE BEHAVIOR;