-------------------------------------------------------------------------------
--
-- Title       : noniq_adc
-- Design      : shift_by_m
-- Author      : bachimanchi
-- Company     : Jefferson Lab
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\Separator\shift_by_m\src\noniq_adc.vhd
-- Generated   : Tue Jul 17 14:10:38 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {noniq_adc} architecture {behavior}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

entity noniq_adc_lut is
	 port(
		 clock : in std_logic;
		 reset : in std_logic;
		 d_in : in std_logic_vector(15 downto 0);
		 sin_lut	:	in std_logic_vector(17 downto 0);
		 cos_lut	:	in std_logic_vector(17 downto 0);
		 i_out : out std_logic_vector(17 downto 0);
		 q_out : out std_logic_vector(17 downto 0)
	     );
end noniq_adc_lut;

--}} End of automatically maintained section

architecture behavior of noniq_adc_lut is
---------------this is look up table for sampling 70 MHz with 93 MHz-------------------	
--type reg_data is array (0 to 92) of std_logic_vector(19 downto 0);
--constant sine_lut	: reg_data := (x"0000",	x"C002",	x"FDD7",	x"3FEB",	x"0452",	x"C03A",	x"F986",	x"3F8E",	x"089F",	x"C0BD",	x"F53E",	x"3EE6",	x"0CE2",	x"C189",	x"F102",	x"3DF5",	x"1116",	x"C29F",	x"ECD7",	x"3CBC",	x"1536",	x"C3FC",	x"E8C3",	x"3B3B",	x"193D",	x"C59F",	x"E4CA",	x"3976",	x"1D27",	x"C786",	x"E0F1",	x"376D",	x"20EE",	x"C9B0",	x"DD3C",	x"3524",	x"2490",	x"CC19",	x"D9B0",	x"329C",	x"2806",	x"CEBE",	x"D650",	x"2FD9",	x"2B4E",	x"D19D",	x"D321",	x"2CDF",	x"2E63",	x"D4B2",	x"D027",	x"29B0",	x"3142",	x"D7FA",	x"CD64",	x"2650",	x"33E7",	x"DB70",	x"CADC",	x"22C4",	x"3650",	x"DF12",	x"C893",	x"1F0F",	x"387A",	x"E2D9",	x"C68A",	x"1B36",	x"3A61",	x"E6C3",	x"C4C5",	x"173D",	x"3C04",	x"EACA",	x"C344",	x"1329",	x"3D61",	x"EEEA",	x"C20B",	x"0EFE",	x"3E77",	x"F31E",	x"C11A",	x"0AC2",	x"3F43",	x"F761",	x"C072",	x"067A",	x"3FC6",	x"FBAE",	x"C015",	x"0229",	x"3FFE");
--constant cosine_lut	: reg_data := (x"4000",	x"0115",	x"C009",	x"FCC2",	x"3FDB",	x"0566",	x"C054",	x"F873",	x"3F6B",	x"09B1",	x"C0E9",	x"F42D",	x"3EB1",	x"0DF1",	x"C1C8",	x"EFF5",	x"3DAD",	x"1220",	x"C2EF",	x"EBD0",	x"3C62",	x"163A",	x"C45E",	x"E7C2",	x"3AD0",	x"1A3A",	x"C613",	x"E3D1",	x"38FA",	x"1E1C",	x"C80B",	x"E000",	x"36E1",	x"21DB",	x"CA44",	x"DC55",	x"3487",	x"2571",	x"CCBC",	x"D8D3",	x"31F1",	x"28DD",	x"CF71",	x"D57F",	x"2F20",	x"2C18",	x"D25D",	x"D25D",	x"2C18",	x"2F20",	x"D57F",	x"CF71",	x"28DD",	x"31F1",	x"D8D3",	x"CCBC",	x"2571",	x"3487",	x"DC55",	x"CA44",	x"21DB",	x"36E1",	x"E000",	x"C80B",	x"1E1C",	x"38FA",	x"E3D1",	x"C613",	x"1A3A",	x"3AD0",	x"E7C2",	x"C45E",	x"163A",	x"3C62",	x"EBD0",	x"C2EF",	x"1220",	x"3DAD",	x"EFF5",	x"C1C8",	x"0DF1",	x"3EB1",	x"F42D",	x"C0E9",	x"09B1",	x"3F6B",	x"F873",	x"C054",	x"0566",	x"3FDB",	x"FCC2",	x"C009",	x"0115");
---------------end of look up table for 70/93------------------------------------------	
--	type reg_data is array (0 to 92) of integer;
--constant sine_lut	: reg_data := (0,	-131053,	-4427,	130904,	8849,	-130605,	-13260,	130157,	17657,	-129561,	-22033,	128816,	26385,	-127925,	-30706,	126888,	34992,	-125706,	-39238,	124380,	43440,	-122913,	-47591,	121305,	51689,	-119559,	-55728,	117677,	59703,	-115660,	-63609,	113512,	67444,	-111234,	-71201,	108828,	74877,	-106299,	-78468,	103649,	81969,	-100880,	-85377,	97996,	88687,	-95000,	-91896,	91896,	95000,	-88687,	-97996,	85377,	100880,	-81969,	-103649,	78468,	106299,	-74877,	-108828,	71201,	111234,	-67444,	-113512,	63609,	115660,	-59703,	-117677,	55728,	119559,	-51689,	-121305,	47591,	122913,	-43440,	-124380,	39238,	125706,	-34992,	-126888,	30706,	127925,	-26385,	-128816,	22033,	129561,	-17657,	-130157,	13260,	130605,	-8849,	-130904,	4427,	131053);
--constant cosine_lut	: reg_data := (131072,	2214,	-130997,	-6639,	130773,	11056,	-130400,	-15461,	129877,	19848,	-129207,	-24212,	128389,	28549,	-127425,	-32854,	126315,	37120,	-125061,	-41345,	123664,	45522,	-122127,	-49647,	120450,	53716,	-118635,	-57723,	116685,	61665,	-114602,	-65536,	112389,	69332,	-110047,	-73050,	107579,	76684,	-104989,	-80230,	102279,	83685,	-99452,	-87044,	96512,	90304,	-93461,	-93461,	90304,	96512,	-87044,	-99452,	83685,	102279,	-80230,	-104989,	76684,	107579,	-73050,	-110047,	69332,	112389,	-65536,	-114602,	61665,	116685,	-57723,	-118635,	53716,	120450,	-49647,	-122127,	45522,	123664,	-41345,	-125061,	37120,	126315,	-32854,	-127425,	28549,	128389,	-24212,	-129207,	19848,	129877,	-15461,	-130400,	11056,	130773,	-6639,	-130997,	2214);
	
--signal din_cnt_q		: 	std_logic_vector(7 downto 0);
--signal din_cnt_d		: 	std_logic_vector(7 downto 0);
--signal clr_din_cnt		: 	std_logic;
--signal en_din_cnt		: 	std_logic;
--signal din_cnt_plus1	: 	std_logic_vector(7 downto 0);

signal din_reg0_q		: 	std_logic_vector(15 downto 0);
signal din_reg0_d		: 	std_logic_vector(15 downto 0);
signal din_reg1_q		: 	std_logic_vector(15 downto 0);
signal din_reg1_d		: 	std_logic_vector(15 downto 0);
signal din_reg2_q		: 	std_logic_vector(15 downto 0);
signal din_reg2_d		: 	std_logic_vector(15 downto 0);

signal i_mul_o1_d		:	std_logic_vector(33 downto 0);
signal i_mul_o1_q		:	std_logic_vector(33 downto 0);
signal i_mul_o2_d		:	std_logic_vector(33 downto 0);
signal i_mul_o2_q		:	std_logic_vector(33 downto 0);
signal q_mul_o1_d		:	std_logic_vector(33 downto 0);
signal q_mul_o1_q		:	std_logic_vector(33 downto 0);
signal q_mul_o2_d		:	std_logic_vector(33 downto 0);
signal q_mul_o2_q		:	std_logic_vector(33 downto 0);

signal i_mul_q			: 	std_logic_vector(34 downto 0);
signal i_mul_d			: 	std_logic_vector(34 downto 0);
signal q_mul_q			: 	std_logic_vector(34 downto 0);
signal q_mul_d			: 	std_logic_vector(34 downto 0);

signal i_out_d			:	std_logic_vector(17 downto 0);
signal i_out_q			:	std_logic_vector(17 downto 0);
signal q_out_d			:	std_logic_vector(17 downto 0);
signal q_out_q			:	std_logic_vector(17 downto 0);

signal sine_lutn_d, sine_lutn		:	std_logic_vector(17 downto 0);
signal sine_lutnp1_d, sine_lutnp1		:	std_logic_vector(17 downto 0);
signal cosine_lutn_d, cosine_lutn		:	std_logic_vector(17 downto 0);
signal cosine_lutnp1_d, cosine_lutnp1	:	std_logic_vector(17 downto 0);

constant determinant	: 	std_logic_vector(9 downto 0) := "0000000001";
-------for sampling 70 with 93 MHz determinant is almost close to 1
begin
	
--din_cnt_d	<=	x"00" when clr_din_cnt = '1' else
--					std_logic_vector(unsigned(din_cnt_q) + 1) when en_din_cnt = '1' else
--					din_cnt_q;
					
--clr_din_cnt	<=	'1' when din_cnt_q = x"5c" else '0';														 													 
--en_din_cnt	<=	'1' when din_cnt_q /= x"5c" else '0';
	
din_reg0_d		<= 	d_in;
din_reg1_d		<= 	din_reg0_q;
din_reg2_d		<= 	din_reg1_q;

--din_cnt_plus1	<= 	x"00" when din_cnt_q = x"5c" else std_logic_vector(unsigned(din_cnt_q) + 1);
--sine_lutn_d			<=	std_logic_vector(to_signed(sine_lut(to_integer(unsigned(din_cnt_q))),19));
--sine_lutnp1_d		<=	std_logic_vector(to_signed(sine_lut(to_integer(unsigned(din_cnt_plus1))),19));
--cosine_lutn_d		<=	std_logic_vector(to_signed(cosine_lut(to_integer(unsigned(din_cnt_q))),19));
--cosine_lutnp1_d	<=	std_logic_vector(to_signed(cosine_lut(to_integer(unsigned(din_cnt_plus1))),19));
sine_lutn_d				<=	sin_lut;
sine_lutnp1_d			<=	sine_lutn;
cosine_lutn_d			<=	cos_lut;
cosine_lutnp1_d		<=	cosine_lutn;
	
i_mul_o1_d	<=	std_logic_vector(signed(din_reg1_q) * signed(sine_lutnp1));		
i_mul_o2_d	<=	std_logic_vector(signed(din_reg2_q) * signed(sine_lutn));
q_mul_o1_d	<=	std_logic_vector(signed(din_reg2_q) * signed(cosine_lutn));
q_mul_o2_d	<=	std_logic_vector(signed(din_reg1_q) * signed(cosine_lutnp1));


i_mul_d		<= 	std_logic_vector(signed(i_mul_o1_q(33)&i_mul_o1_q) - signed(i_mul_o2_q(33)&i_mul_o2_q));
q_mul_d		<= 	std_logic_vector(signed(q_mul_o1_q(33)&q_mul_o1_q) - signed(q_mul_o2_q(33)&q_mul_o2_q));


--sine_mul_shift		<= 	std_logic_vector(signed(sine_mul_d) * signed(determinant));
--cosine_mul_shift	<= 	std_logic_vector(signed(cosine_mul_d) * signed(determinant));

i_out_d		<=	"01"&x"ffff" when i_mul_q(34) = '0' and i_mul_q(33 downto 32) /= "00" else
					"10"&x"0000" when i_mul_q(34) = '1' and i_mul_q(33 downto 32) /= "11" else
					i_mul_q(32 downto 15);-------dividing by 32768 to gain two more bits
q_out_d		<=	"01"&x"ffff" when q_mul_q(34) = '0' and q_mul_q(33 downto 32) /= "00" else
					"10"&x"8000" when q_mul_q(34) = '1' and q_mul_q(33 downto 32) /= "11" else
					q_mul_q(32 downto 15);-------dividing by 32768 to gain two more bits		

i_out		<=	i_out_q;
q_out		<=	q_out_q;
				
process(reset,clock)
begin
	if(reset = '0') then
--		din_cnt_q		<=	(others => '0');
		din_reg0_q		<= 	(others => '0');	
		din_reg1_q		<= 	(others => '0');
		din_reg2_q		<= 	(others => '0');
--		din_cnt_q		<=	(others => '0');
		i_mul_o1_q		<=	(others => '0');
		i_mul_o2_q		<=	(others => '0'); 
		q_mul_o1_q		<=	(others => '0');
		q_mul_o2_q		<=	(others => '0');
		i_mul_q			<= 	(others => '0');
		q_mul_q			<= 	(others => '0');
		i_out_q			<= 	(others => '0');
		q_out_q			<=	(others => '0');
		
		sine_lutn		<=	(others	=>	'0');
		sine_lutnp1		<=	(others	=>	'0');
		cosine_lutn		<=	(others	=>	'0');
		cosine_lutnp1	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
--		din_cnt_q		<= 	din_cnt_d;
		din_reg0_q		<= 	din_reg0_d;
		din_reg1_q		<= 	din_reg1_d;
		din_reg2_q		<= 	din_reg2_d;
--		din_cnt_q		<=	din_cnt_d;
		i_mul_o1_q		<=	i_mul_o1_d;
		i_mul_o2_q		<=	i_mul_o2_d;
		q_mul_o1_q		<=	q_mul_o1_d;
		q_mul_o2_q		<=	q_mul_o2_d;
		i_mul_q			<= 	i_mul_d;
		q_mul_q			<= 	q_mul_d;
		i_out_q			<=	i_out_d;
		q_out_q			<=	q_out_d;
		
		sine_lutn		<=	sine_lutn_d;
		sine_lutnp1		<=	sine_lutnp1_d;
		cosine_lutn		<=	cosine_lutn_d;
		cosine_lutnp1	<=	cosine_lutnp1_d;
	end if;
end process;
end behavior;
--
---------------------------------------------------------------------------------
--
-- Title       : noniq_adc
-- Design      : shift_by_m
-- Author      : bachimanchi
-- Company     : Jefferson Lab
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\Separator\shift_by_m\src\noniq_adc.vhd
-- Generated   : Tue Jul 17 14:10:38 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
--
--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {noniq_adc} architecture {behavior}}

--library IEEE;
--use IEEE.STD_LOGIC_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
--
--entity noniq_adc_lut is
--	 port(
--		 clock : in STD_LOGIC;
--		 reset : in STD_LOGIC;
--		 sin_lut	:	in std_logic_vector(17 downto 0);
--		 cos_lut	:	in std_logic_vector(17 downto 0);
--		 d_in : in STD_LOGIC_VECTOR(15 downto 0);
--		 i_out : out STD_LOGIC_VECTOR(15 downto 0);
--		 q_out : out STD_LOGIC_VECTOR(15 downto 0)
--	     );
--end noniq_adc_lut;
--
----}} End of automatically maintained section
--
--architecture behavior of noniq_adc_lut is
-----------------this is look up table for sampling 70 MHz with 93 MHz-------------------	
----type reg_data is array (0 to 92) of std_logic_vector(19 downto 0);
----constant sine_lut	: reg_data := (x"0000",	x"C002",	x"FDD7",	x"3FEB",	x"0452",	x"C03A",	x"F986",	x"3F8E",	x"089F",	x"C0BD",	x"F53E",	x"3EE6",	x"0CE2",	x"C189",	x"F102",	x"3DF5",	x"1116",	x"C29F",	x"ECD7",	x"3CBC",	x"1536",	x"C3FC",	x"E8C3",	x"3B3B",	x"193D",	x"C59F",	x"E4CA",	x"3976",	x"1D27",	x"C786",	x"E0F1",	x"376D",	x"20EE",	x"C9B0",	x"DD3C",	x"3524",	x"2490",	x"CC19",	x"D9B0",	x"329C",	x"2806",	x"CEBE",	x"D650",	x"2FD9",	x"2B4E",	x"D19D",	x"D321",	x"2CDF",	x"2E63",	x"D4B2",	x"D027",	x"29B0",	x"3142",	x"D7FA",	x"CD64",	x"2650",	x"33E7",	x"DB70",	x"CADC",	x"22C4",	x"3650",	x"DF12",	x"C893",	x"1F0F",	x"387A",	x"E2D9",	x"C68A",	x"1B36",	x"3A61",	x"E6C3",	x"C4C5",	x"173D",	x"3C04",	x"EACA",	x"C344",	x"1329",	x"3D61",	x"EEEA",	x"C20B",	x"0EFE",	x"3E77",	x"F31E",	x"C11A",	x"0AC2",	x"3F43",	x"F761",	x"C072",	x"067A",	x"3FC6",	x"FBAE",	x"C015",	x"0229",	x"3FFE");
----constant cosine_lut	: reg_data := (x"4000",	x"0115",	x"C009",	x"FCC2",	x"3FDB",	x"0566",	x"C054",	x"F873",	x"3F6B",	x"09B1",	x"C0E9",	x"F42D",	x"3EB1",	x"0DF1",	x"C1C8",	x"EFF5",	x"3DAD",	x"1220",	x"C2EF",	x"EBD0",	x"3C62",	x"163A",	x"C45E",	x"E7C2",	x"3AD0",	x"1A3A",	x"C613",	x"E3D1",	x"38FA",	x"1E1C",	x"C80B",	x"E000",	x"36E1",	x"21DB",	x"CA44",	x"DC55",	x"3487",	x"2571",	x"CCBC",	x"D8D3",	x"31F1",	x"28DD",	x"CF71",	x"D57F",	x"2F20",	x"2C18",	x"D25D",	x"D25D",	x"2C18",	x"2F20",	x"D57F",	x"CF71",	x"28DD",	x"31F1",	x"D8D3",	x"CCBC",	x"2571",	x"3487",	x"DC55",	x"CA44",	x"21DB",	x"36E1",	x"E000",	x"C80B",	x"1E1C",	x"38FA",	x"E3D1",	x"C613",	x"1A3A",	x"3AD0",	x"E7C2",	x"C45E",	x"163A",	x"3C62",	x"EBD0",	x"C2EF",	x"1220",	x"3DAD",	x"EFF5",	x"C1C8",	x"0DF1",	x"3EB1",	x"F42D",	x"C0E9",	x"09B1",	x"3F6B",	x"F873",	x"C054",	x"0566",	x"3FDB",	x"FCC2",	x"C009",	x"0115");
-----------------end of look up table for 70/93------------------------------------------	
--	type reg_data is array (0 to 92) of integer;
--constant sine_lut	: reg_data := (0,	-131053,	-4427,	130904,	8849,	-130605,	-13260,	130157,	17657,	-129561,	-22033,	128816,	26385,	-127925,	-30706,	126888,	34992,	-125706,	-39238,	124380,	43440,	-122913,	-47591,	121305,	51689,	-119559,	-55728,	117677,	59703,	-115660,	-63609,	113512,	67444,	-111234,	-71201,	108828,	74877,	-106299,	-78468,	103649,	81969,	-100880,	-85377,	97996,	88687,	-95000,	-91896,	91896,	95000,	-88687,	-97996,	85377,	100880,	-81969,	-103649,	78468,	106299,	-74877,	-108828,	71201,	111234,	-67444,	-113512,	63609,	115660,	-59703,	-117677,	55728,	119559,	-51689,	-121305,	47591,	122913,	-43440,	-124380,	39238,	125706,	-34992,	-126888,	30706,	127925,	-26385,	-128816,	22033,	129561,	-17657,	-130157,	13260,	130605,	-8849,	-130904,	4427,	131053);
--constant cosine_lut	: reg_data := (131072,	2214,	-130997,	-6639,	130773,	11056,	-130400,	-15461,	129877,	19848,	-129207,	-24212,	128389,	28549,	-127425,	-32854,	126315,	37120,	-125061,	-41345,	123664,	45522,	-122127,	-49647,	120450,	53716,	-118635,	-57723,	116685,	61665,	-114602,	-65536,	112389,	69332,	-110047,	-73050,	107579,	76684,	-104989,	-80230,	102279,	83685,	-99452,	-87044,	96512,	90304,	-93461,	-93461,	90304,	96512,	-87044,	-99452,	83685,	102279,	-80230,	-104989,	76684,	107579,	-73050,	-110047,	69332,	112389,	-65536,	-114602,	61665,	116685,	-57723,	-118635,	53716,	120450,	-49647,	-122127,	45522,	123664,	-41345,	-125061,	37120,	126315,	-32854,	-127425,	28549,	128389,	-24212,	-129207,	19848,	129877,	-15461,	-130400,	11056,	130773,	-6639,	-130997,	2214);
--	
--signal din_cnt_q		: 	std_logic_vector(7 downto 0);
--signal din_cnt_d		: 	std_logic_vector(7 downto 0);
--signal clr_din_cnt		: 	std_logic;
--signal en_din_cnt		: 	std_logic;
--signal din_cnt_plus1	: 	std_logic_vector(7 downto 0);
--
--signal din_reg0_q		: 	std_logic_vector(15 downto 0);
--signal din_reg0_d		: 	std_logic_vector(15 downto 0);
--signal din_reg1_q		: 	std_logic_vector(15 downto 0);
--signal din_reg1_d		: 	std_logic_vector(15 downto 0);
--signal din_reg2_q		: 	std_logic_vector(15 downto 0);
--signal din_reg2_d		: 	std_logic_vector(15 downto 0);
--
--signal i_mul_o1_d		:	std_logic_vector(34 downto 0);
--signal i_mul_o1_q		:	std_logic_vector(34 downto 0);
--signal i_mul_o2_d		:	std_logic_vector(34 downto 0);
--signal i_mul_o2_q		:	std_logic_vector(34 downto 0);
--signal q_mul_o1_d		:	std_logic_vector(34 downto 0);
--signal q_mul_o1_q		:	std_logic_vector(34 downto 0);
--signal q_mul_o2_d		:	std_logic_vector(34 downto 0);
--signal q_mul_o2_q		:	std_logic_vector(34 downto 0);
--
--signal i_mul_q			: 	std_logic_vector(34 downto 0);
--signal i_mul_d			: 	std_logic_vector(34 downto 0);
--signal q_mul_q			: 	std_logic_vector(34 downto 0);
--signal q_mul_d			: 	std_logic_vector(34 downto 0);
--
--signal i_out_d			:	std_logic_vector(15 downto 0);
--signal i_out_q			:	std_logic_vector(15 downto 0);
--signal q_out_d			:	std_logic_vector(15 downto 0);
--signal q_out_q			:	std_logic_vector(15 downto 0);
--
--signal sine_lutn		:	std_logic_vector(18 downto 0);
--signal sine_lutnp1		:	std_logic_vector(18 downto 0);
--signal cosine_lutn		:	std_logic_vector(18 downto 0);
--signal cosine_lutnp1	:	std_logic_vector(18 downto 0);
--
--constant determinant	: 	std_logic_vector(9 downto 0) := "0000000001";
---------for sampling 70 with 93 MHz determinant is almost close to 1
--begin
--	
--din_cnt_d	<= 	x"00" when clr_din_cnt = '1' else
--				(din_cnt_q + '1') when en_din_cnt = '1' else
--				din_cnt_q;
--					
--clr_din_cnt	<=	'1' when din_cnt_q = x"5c" else '0';														 													 
--en_din_cnt	<=	'1' when din_cnt_q /= x"5c" else '0';
--	
--din_reg0_d		<= 	d_in;
--din_reg1_d		<= 	din_reg0_q;
--din_reg2_d		<= 	din_reg1_q;
--
--din_cnt_plus1	<= 	x"00" when din_cnt_q = x"5c" else din_cnt_q+'1';
--sine_lutn		<=	std_logic_vector(to_signed(sine_lut(to_integer(unsigned(din_cnt_q))),19));
--sine_lutnp1		<=	std_logic_vector(to_signed(sine_lut(to_integer(unsigned(din_cnt_plus1))),19));
--cosine_lutn		<=	std_logic_vector(to_signed(cosine_lut(to_integer(unsigned(din_cnt_q))),19));
--cosine_lutnp1	<=	std_logic_vector(to_signed(cosine_lut(to_integer(unsigned(din_cnt_plus1))),19));
--	
--i_mul_o1_d	<=	std_logic_vector(signed(din_reg1_q) * signed(sine_lutn));		
--i_mul_o2_d	<=	std_logic_vector(signed(din_reg2_q) * signed(sine_lutnp1));
--q_mul_o1_d	<=	std_logic_vector(signed(din_reg2_q) * signed(cosine_lutnp1));
--q_mul_o2_d	<=	std_logic_vector(signed(din_reg1_q) * signed(cosine_lutn));
--
--
--i_mul_d		<= 	i_mul_o1_q - i_mul_o2_q;
--q_mul_d		<= 	q_mul_o1_q - q_mul_o2_q;
--
--
----sine_mul_shift		<= 	std_logic_vector(signed(sine_mul_d) * signed(determinant));
----cosine_mul_shift	<= 	std_logic_vector(signed(cosine_mul_d) * signed(determinant));
--
--i_out_d		<=	x"7fff" when i_mul_q(34) = '0' and i_mul_q(33 downto 32) /= "00" else
--				x"8000" when i_mul_q(34) = '1' and i_mul_q(33 downto 32) /= "11" else
--				i_mul_q(32 downto 17);-------dividing by 131072
--q_out_d		<=	x"7fff" when q_mul_q(34) = '0' and q_mul_q(33 downto 32) /= "00" else
--				x"8000" when q_mul_q(34) = '1' and q_mul_q(33 downto 32) /= "11" else
--				q_mul_q(32 downto 17);-------dividing by 131072		
--
--i_out		<=	i_out_q;
--q_out		<=	q_out_q;
--				
--process(reset,clock)
--begin
--	if(reset = '0') then
--		din_cnt_q		<=	(others => '0');
--		din_reg0_q		<= 	(others => '0');	
--		din_reg1_q		<= 	(others => '0');
--		din_reg2_q		<= 	(others => '0');
--		din_cnt_q		<=	(others => '0');
--		i_mul_o1_q		<=	(others => '0');
--		i_mul_o2_q		<=	(others => '0'); 
--		q_mul_o1_q		<=	(others => '0');
--		q_mul_o2_q		<=	(others => '0');
--		i_mul_q			<= 	(others => '0');
--		q_mul_q			<= 	(others => '0');
--		i_out_q			<= 	(others => '0');
--		q_out_q			<=	(others => '0');
--	elsif(rising_edge(clock)) then
--		din_cnt_q		<= 	din_cnt_d;
--		din_reg0_q		<= 	din_reg0_d;
--		din_reg1_q		<= 	din_reg1_d;
--		din_reg2_q		<= 	din_reg2_d;
--		din_cnt_q		<=	din_cnt_d;
--		i_mul_o1_q		<=	i_mul_o1_d;
--		i_mul_o2_q		<=	i_mul_o2_d;
--		q_mul_o1_q		<=	q_mul_o1_d;
--		q_mul_o2_q		<=	q_mul_o2_d;
--		i_mul_q			<= 	i_mul_d;
--		q_mul_q			<= 	q_mul_d;
--		i_out_q			<=	i_out_d;
--		q_out_q			<=	q_out_d;
--	end if;
--end process;
--end behavior;

