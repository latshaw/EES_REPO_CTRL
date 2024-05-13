library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity stepper_data is

port (	clock 			: in std_logic;
		reset 			: in std_logic;
		
		deta_in      	: in std_logic_vector(15 downto 0);
		disc_in 		: in std_logic_vector(27 downto 0);
		pzt_in 			: in std_logic_vector(15 downto 0);
		deta_disc_pzt  	: in std_logic_vector(1  downto 0);
		slow			: in std_logic;
		track_en		: in std_logic;
      
		crc_done 		: in std_logic;		
		data_out 		: out std_logic_vector(31 downto 0)
	
	 );
		
end entity stepper_data;

architecture behavior of stepper_data is

signal disc				: std_logic_vector(31 downto 0);
signal mode_deta		: std_logic_vector(31 downto 0);
signal pzt_data			: std_logic_vector(31 downto 0);
signal data_out_q		:	std_logic_vector(31 downto 0);

signal clr_reg_count	: std_logic;
signal en_reg_count		: std_logic;
signal reg_count_d, reg_count		: std_logic_vector(1  downto 0);

signal en_data			: std_logic;
signal data_in_reg		: std_logic_vector(31 downto 0);

signal data_mux			: std_logic_vector(31 downto 0);

signal crc_buf0			: std_logic;
signal crc_buf1			: std_logic;
signal crc_buf2			: std_logic;
signal crc_buf3			: std_logic;

begin
-----------REGISTER STRUCTURE--------
----1000-----slow stepper & Detune Angle(deta(15..0) & deta_disc_select----"00"-deta, "01"-disc, "10"-pzt,"11"-invalid, track_enable)
----1001-----DISCRIMINATOR
----1010-----pzt value
--denom <= "100000111";
mode_deta 	<= x"800"  & slow & deta_in & deta_disc_pzt & track_en;
disc 		<= x"9"    & disc_in;
pzt_data 	<= x"a000" & pzt_in;

--------------rising and falling edges of crc_done signal--------------------
process(clock, reset)
begin
	if(reset = '0') then
		crc_buf0		<=	'0';
		crc_buf1		<= '0';
		crc_buf2		<=	'0';
		reg_count	<=	"00";
		data_out_q		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		crc_buf0		<=	crc_done;
		crc_buf1		<= crc_buf0;
		crc_buf2		<=	crc_buf1;
		reg_count	<=	reg_count_d;
		data_out_q		<=	data_in_reg;
	end if;
end process;	



en_reg_count 	<= '1' when (crc_buf1 = '1' and crc_buf2 = '0' and reg_count /= "10") else '0';
clr_reg_count 	<= '0' when (crc_buf1 = '1' and crc_buf2 = '0' and reg_count = "10") else '1';
en_data 		<= '1' when (crc_buf1 = '0' and crc_buf2 = '1') else '0';


reg_count_d		<=	"00" when clr_reg_count = '0' else
						std_logic_vector(unsigned(reg_count) + 1) when en_reg_count = '1' else
						reg_count;	
					
	


	data_mux 		<= 		mode_deta when reg_count = "00" else
							disc when reg_count = "01" else
							pzt_data when reg_count = "10" else
							(others => '0');
					
	data_in_reg 	<= 		data_mux when en_data = '1' else data_out_q;
	data_out			<=	data_out_q;

				

end architecture behavior;
		