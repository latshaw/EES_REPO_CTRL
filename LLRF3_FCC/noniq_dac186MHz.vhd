--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;
--
--entity noniq_dac186MHz is
--port(clock	: in std_logic;
--	 reset	: in std_logic;
--
--	 i_in	: in std_logic_vector(15 downto 0);
--	 q_in	: in std_logic_vector(15 downto 0);
--	 tx_en	: in std_logic;
--	 
--	 d_out	: out std_logic_vector(15 downto 0)
--	 
--	 );
--end entity noniq_dac186MHz;
--
--architecture behavior of noniq_dac186MHz is 
--
--signal iq_count_d	: 	std_logic_vector(7 downto 0);
--signal iq_count_q	: 	std_logic_vector(7 downto 0);
--signal en_iq_count	:	std_logic;
--signal clr_iq_count	:	std_logic;
--
--signal i_mul		: 	std_logic_vector(15 downto 0);
--signal q_mul		: 	std_logic_vector(15 downto 0);
--
--signal i_in_d		: 	std_logic_vector(15 downto 0);
--signal i_in_q		: 	std_logic_vector(15 downto 0);
--signal q_in_d		: 	std_logic_vector(15 downto 0);
--signal q_in_q		: 	std_logic_vector(15 downto 0);
--
--signal i_mul_d		: 	std_logic_vector(31 downto 0);
--signal i_mul_q		: 	std_logic_vector(31 downto 0);
--signal q_mul_d		: 	std_logic_vector(31 downto 0);
--signal q_mul_q		: 	std_logic_vector(31 downto 0);
--signal i_out_d		:	std_logic_vector(15 downto 0);
--signal i_out_q		:	std_logic_vector(15 downto 0);
--signal q_out_d		:	std_logic_vector(15 downto 0);
--signal q_out_q		:	std_logic_vector(15 downto 0);
--
--signal d_out_d		: std_logic_vector(15 downto 0);
--signal d_out_q		: std_logic_vector(15 downto 0);
--
--signal d_tx_d		: std_logic_vector(15 downto 0);
--signal d_tx_q		: std_logic_vector(15 downto 0);
--
--signal iq_add_d		: std_logic_vector(16 downto 0);
--signal iq_add_q		: std_logic_vector(16 downto 0);
--
--type reg_data is array (185 downto 0) of std_logic_vector(15 downto 0);
--constant sin_lut	: reg_data := (x"0000", x"2CDF", x"C002", x"2E63", x"FDD7", x"D4B2", x"3FEB", x"D027", x"0452", x"29B0", x"C03A", x"3142", x"F986", x"D7FA", x"3F8E", x"CD64", x"089F", x"2650", x"C0BD", x"33E7", x"F53E", x"DB70", x"3EE6", x"CADC", x"0CE2", x"22C4", x"C189", x"3650", x"F102", x"DF12", x"3DF5", x"C893", x"1116", x"1F0F", x"C29F", x"387A", x"ECD7", x"E2D9", x"3CBC", x"C68A", x"1536", x"1B36", x"C3FC", x"3A61", x"E8C3", x"E6C3", x"3B3B", x"C4C5", x"193D", x"173D", x"C59F", x"3C04", x"E4CA", x"EACA", x"3976", x"C344", x"1D27", x"1329", x"C786", x"3D61", x"E0F1", x"EEEA", x"376D", x"C20B", x"20EE", x"0EFE", x"C9B0", x"3E77", x"DD3C", x"F31E", x"3524", x"C11A", x"2490", x"0AC2", x"CC19", x"3F43", x"D9B0", x"F761", x"329C", x"C072", x"2806", x"067A", x"CEBE", x"3FC6", x"D650", x"FBAE", x"2FD9", x"C015", x"2B4E", x"0229", x"D19D", x"3FFE", x"D321", x"0000", x"2CDF", x"C002", x"2E63", x"FDD7", x"D4B2", x"3FEB", x"D027", x"0452", x"29B0", x"C03A", x"3142", x"F986", x"D7FA", x"3F8E", x"CD64", x"089F", x"2650", x"C0BD", x"33E7", x"F53E", x"DB70", x"3EE6", x"CADC", x"0CE2", x"22C4", x"C189", x"3650", x"F102", x"DF12", x"3DF5", x"C893", x"1116", x"1F0F", x"C29F", x"387A", x"ECD7", x"E2D9", x"3CBC", x"C68A", x"1536", x"1B36", x"C3FC", x"3A61", x"E8C3", x"E6C3", x"3B3B", x"C4C5", x"193D", x"173D", x"C59F", x"3C04", x"E4CA", x"EACA", x"3976", x"C344", x"1D27", x"1329", x"C786", x"3D61", x"E0F1", x"EEEA", x"376D", x"C20B", x"20EE", x"0EFE", x"C9B0", x"3E77", x"DD3C", x"F31E", x"3524", x"C11A", x"2490", x"0AC2", x"CC19", x"3F43", x"D9B0", x"F761", x"329C", x"C072", x"2806", x"067A", x"CEBE", x"3FC6", x"D650", x"FBAE", x"2FD9", x"C015", x"2B4E", x"0229", x"D19D", x"3FFE", x"D321");
--constant cos_lut	: reg_data := (x"4000", x"D25D", x"0115", x"2C18", x"C009", x"2F20", x"FCC2", x"D57F", x"3FDB", x"CF71", x"0566", x"28DD", x"C054", x"31F1", x"F873", x"D8D3", x"3F6B", x"CCBC", x"09B1", x"2571", x"C0E9", x"3487", x"F42D", x"DC55", x"3EB1", x"CA44", x"0DF1", x"21DB", x"C1C8", x"36E1", x"EFF5", x"E000", x"3DAD", x"C80B", x"1220", x"1E1C", x"C2EF", x"38FA", x"EBD0", x"E3D1", x"3C62", x"C613", x"163A", x"1A3A", x"C45E", x"3AD0", x"E7C2", x"E7C2", x"3AD0", x"C45E", x"1A3A", x"163A", x"C613", x"3C62", x"E3D1", x"EBD0", x"38FA", x"C2EF", x"1E1C", x"1220", x"C80B", x"3DAD", x"E000", x"EFF5", x"36E1", x"C1C8", x"21DB", x"0DF1", x"CA44", x"3EB1", x"DC55", x"F42D", x"3487", x"C0E9", x"2571", x"09B1", x"CCBC", x"3F6B", x"D8D3", x"F873", x"31F1", x"C054", x"28DD", x"0566", x"CF71", x"3FDB", x"D57F", x"FCC2", x"2F20", x"C009", x"2C18", x"0115", x"D25D", x"4000", x"D25D", x"0115", x"2C18", x"C009", x"2F20", x"FCC2", x"D57F", x"3FDB", x"CF71", x"0566", x"28DD", x"C054", x"31F1", x"F873", x"D8D3", x"3F6B", x"CCBC", x"09B1", x"2571", x"C0E9", x"3487", x"F42D", x"DC55", x"3EB1", x"CA44", x"0DF1", x"21DB", x"C1C8", x"36E1", x"EFF5", x"E000", x"3DAD", x"C80B", x"1220", x"1E1C", x"C2EF", x"38FA", x"EBD0", x"E3D1", x"3C62", x"C613", x"163A", x"1A3A", x"C45E", x"3AD0", x"E7C2", x"E7C2", x"3AD0", x"C45E", x"1A3A", x"163A", x"C613", x"3C62", x"E3D1", x"EBD0", x"38FA", x"C2EF", x"1E1C", x"1220", x"C80B", x"3DAD", x"E000", x"EFF5", x"36E1", x"C1C8", x"21DB", x"0DF1", x"CA44", x"3EB1", x"DC55", x"F42D", x"3487", x"C0E9", x"2571", x"09B1", x"CCBC", x"3F6B", x"D8D3", x"F873", x"31F1", x"C054", x"28DD", x"0566", x"CF71", x"3FDB", x"D57F", x"FCC2", x"2F20", x"C009", x"2C18", x"0115", x"D25D");
--signal lut_index	: integer range 0 to 185;
--
--begin
--
--i_in_d	<=	i_in;
--q_in_d	<= 	q_in;
--lut_index	<= to_integer(unsigned (x"b9" - iq_count_q));
--
--i_mul	<= cos_lut(lut_index);
--q_mul	<= sin_lut(lut_index);			
--			
--			
--			
--i_mul_d		<= std_logic_vector(signed(i_in_q) * signed(i_mul));
--q_mul_d		<= std_logic_vector(signed(q_in_q) * signed(q_mul));
--
--i_out_d		<=	x"7fff" when i_mul_q(31) = '0' and i_mul_q(30 downto 29) /= "00" else
--				x"8000" when i_mul_q(31) = '1' and i_mul_q(30 downto 29) /= "11" else
--				i_mul_q(29 downto 14);-------dividing by 16384
--q_out_d		<=	x"7fff" when q_mul_q(31) = '0' and q_mul_q(30 downto 29) /= "00" else
--				x"8000" when q_mul_q(31) = '1' and q_mul_q(30 downto 29) /= "11" else
--				q_mul_q(29 downto 14);-------dividing by 16384				
--iq_add_d	<= (i_out_q(15) & i_out_q) + (q_out_q(15) & q_out_q);
--d_out_d		<= 	x"7fff" when iq_add_q(16) = '0' and iq_add_q(15) = '1' else
--				x"8000" when iq_add_q(16) = '1' and iq_add_q(15) = '0' else
--				iq_add_q(15 downto 0);
--d_tx_d		<= (x"8000") when tx_en = '0' else (d_out_q);------2's complement to straight binary
--d_out			<= d_tx_q;
--iq_count_d	<= 	x"00" when clr_iq_count = '0' else
--				iq_count_q + '1' when en_iq_count = '1' else
--				iq_count_q;
--en_iq_count		<=	'1' when iq_count_q /= x"b9" else '0';
--clr_iq_count	<=	'0' when iq_count_q = x"b9" else '1';
--process(clock,reset)
--begin
--	if (reset = '0') then
--		iq_count_q	<= 	(others => 	'0');
--		i_in_q		<=	(others => 	'0');
--		q_in_q		<=	(others	=> 	'0');
--		i_mul_q		<= 	(others	=> 	'0');
--		q_mul_q		<= 	(others => 	'0');
--		i_out_q		<=	(others => 	'0');
--		q_out_q		<=	(others	=> 	'0');
--		iq_add_q	<= 	(others =>	'0');
--		d_out_q		<=	(others	=>	'0');
--		d_tx_q		<= (others	=> '0');
--	elsif rising_edge(clock) then
--		iq_count_q	<=	iq_count_d;
--		i_in_q		<=	i_in_d;
--		q_in_q		<=	q_in_d;
--		i_mul_q		<=	i_mul_d;
--		q_mul_q		<=	q_mul_d;
--		i_out_q		<= 	i_out_d;
--		q_out_q		<=	q_out_d;
--		iq_add_q	<=	iq_add_d;
--		d_out_q		<= d_out_d;
--		d_tx_q		<= d_tx_d;
--	end if;
--end process;	
--	
--end architecture behavior;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity noniq_dac186MHz is
port(clock	: 	in std_logic;
	 reset	: 	in std_logic;
	 tx_en	: 	in std_logic;
	 i_in		: 	in std_logic_vector(15 downto 0);
	 q_in		: 	in std_logic_vector(15 downto 0);
	 sin_lut	:	in std_logic_vector(17 downto 0);
	 cos_lut	:	in std_logic_vector(17 downto 0);
	 
	 d_out	: 	out std_logic_vector(15 downto 0)
	 
	 );
end entity noniq_dac186MHz;

architecture behavior of noniq_dac186MHz is 

--signal iq_count_d		: 	std_logic_vector(7 downto 0);
--signal iq_count_q		: 	std_logic_vector(7 downto 0);
--signal en_iq_count	:	std_logic;
--signal clr_iq_count	:	std_logic;

signal i_mul			: 	std_logic_vector(17 downto 0);
signal q_mul			: 	std_logic_vector(17 downto 0);

signal i_in_d			: 	std_logic_vector(15 downto 0);
signal i_in_q			: 	std_logic_vector(15 downto 0);
signal q_in_d			: 	std_logic_vector(15 downto 0);
signal q_in_q			: 	std_logic_vector(15 downto 0);

signal i_mul_d			: 	std_logic_vector(33 downto 0);
signal i_mul_q			: 	std_logic_vector(33 downto 0);
signal q_mul_d			: 	std_logic_vector(33 downto 0);
signal q_mul_q			: 	std_logic_vector(33 downto 0);
signal i_out_d			:	std_logic_vector(15 downto 0);
signal i_out_q			:	std_logic_vector(15 downto 0);
signal q_out_d			:	std_logic_vector(15 downto 0);
signal q_out_q			:	std_logic_vector(15 downto 0);

signal d_out_d			: std_logic_vector(15 downto 0);
signal d_out_q			: std_logic_vector(15 downto 0);

signal d_tx_d			: std_logic_vector(15 downto 0);
signal d_tx_q			: std_logic_vector(15 downto 0);

signal iq_add_d		: std_logic_vector(16 downto 0);
signal iq_add_q		: std_logic_vector(16 downto 0);

--type reg_data is array (0 to 185) of std_logic_vector(15 downto 0);
--constant sin_lut	: reg_data := (x"0000", x"2CDF", x"C002", x"2E63", x"FDD7", x"D4B2", x"3FEB", x"D027", x"0452", x"29B0", x"C03A", x"3142", x"F986", x"D7FA", x"3F8E", x"CD64", x"089F", x"2650", x"C0BD", x"33E7", x"F53E", x"DB70", x"3EE6", x"CADC", x"0CE2", x"22C4", x"C189", x"3650", x"F102", x"DF12", x"3DF5", x"C893", x"1116", x"1F0F", x"C29F", x"387A", x"ECD7", x"E2D9", x"3CBC", x"C68A", x"1536", x"1B36", x"C3FC", x"3A61", x"E8C3", x"E6C3", x"3B3B", x"C4C5", x"193D", x"173D", x"C59F", x"3C04", x"E4CA", x"EACA", x"3976", x"C344", x"1D27", x"1329", x"C786", x"3D61", x"E0F1", x"EEEA", x"376D", x"C20B", x"20EE", x"0EFE", x"C9B0", x"3E77", x"DD3C", x"F31E", x"3524", x"C11A", x"2490", x"0AC2", x"CC19", x"3F43", x"D9B0", x"F761", x"329C", x"C072", x"2806", x"067A", x"CEBE", x"3FC6", x"D650", x"FBAE", x"2FD9", x"C015", x"2B4E", x"0229", x"D19D", x"3FFE", x"D321", x"0000", x"2CDF", x"C002", x"2E63", x"FDD7", x"D4B2", x"3FEB", x"D027", x"0452", x"29B0", x"C03A", x"3142", x"F986", x"D7FA", x"3F8E", x"CD64", x"089F", x"2650", x"C0BD", x"33E7", x"F53E", x"DB70", x"3EE6", x"CADC", x"0CE2", x"22C4", x"C189", x"3650", x"F102", x"DF12", x"3DF5", x"C893", x"1116", x"1F0F", x"C29F", x"387A", x"ECD7", x"E2D9", x"3CBC", x"C68A", x"1536", x"1B36", x"C3FC", x"3A61", x"E8C3", x"E6C3", x"3B3B", x"C4C5", x"193D", x"173D", x"C59F", x"3C04", x"E4CA", x"EACA", x"3976", x"C344", x"1D27", x"1329", x"C786", x"3D61", x"E0F1", x"EEEA", x"376D", x"C20B", x"20EE", x"0EFE", x"C9B0", x"3E77", x"DD3C", x"F31E", x"3524", x"C11A", x"2490", x"0AC2", x"CC19", x"3F43", x"D9B0", x"F761", x"329C", x"C072", x"2806", x"067A", x"CEBE", x"3FC6", x"D650", x"FBAE", x"2FD9", x"C015", x"2B4E", x"0229", x"D19D", x"3FFE", x"D321");
--constant cos_lut	: reg_data := (x"4000", x"D25D", x"0115", x"2C18", x"C009", x"2F20", x"FCC2", x"D57F", x"3FDB", x"CF71", x"0566", x"28DD", x"C054", x"31F1", x"F873", x"D8D3", x"3F6B", x"CCBC", x"09B1", x"2571", x"C0E9", x"3487", x"F42D", x"DC55", x"3EB1", x"CA44", x"0DF1", x"21DB", x"C1C8", x"36E1", x"EFF5", x"E000", x"3DAD", x"C80B", x"1220", x"1E1C", x"C2EF", x"38FA", x"EBD0", x"E3D1", x"3C62", x"C613", x"163A", x"1A3A", x"C45E", x"3AD0", x"E7C2", x"E7C2", x"3AD0", x"C45E", x"1A3A", x"163A", x"C613", x"3C62", x"E3D1", x"EBD0", x"38FA", x"C2EF", x"1E1C", x"1220", x"C80B", x"3DAD", x"E000", x"EFF5", x"36E1", x"C1C8", x"21DB", x"0DF1", x"CA44", x"3EB1", x"DC55", x"F42D", x"3487", x"C0E9", x"2571", x"09B1", x"CCBC", x"3F6B", x"D8D3", x"F873", x"31F1", x"C054", x"28DD", x"0566", x"CF71", x"3FDB", x"D57F", x"FCC2", x"2F20", x"C009", x"2C18", x"0115", x"D25D", x"4000", x"D25D", x"0115", x"2C18", x"C009", x"2F20", x"FCC2", x"D57F", x"3FDB", x"CF71", x"0566", x"28DD", x"C054", x"31F1", x"F873", x"D8D3", x"3F6B", x"CCBC", x"09B1", x"2571", x"C0E9", x"3487", x"F42D", x"DC55", x"3EB1", x"CA44", x"0DF1", x"21DB", x"C1C8", x"36E1", x"EFF5", x"E000", x"3DAD", x"C80B", x"1220", x"1E1C", x"C2EF", x"38FA", x"EBD0", x"E3D1", x"3C62", x"C613", x"163A", x"1A3A", x"C45E", x"3AD0", x"E7C2", x"E7C2", x"3AD0", x"C45E", x"1A3A", x"163A", x"C613", x"3C62", x"E3D1", x"EBD0", x"38FA", x"C2EF", x"1E1C", x"1220", x"C80B", x"3DAD", x"E000", x"EFF5", x"36E1", x"C1C8", x"21DB", x"0DF1", x"CA44", x"3EB1", x"DC55", x"F42D", x"3487", x"C0E9", x"2571", x"09B1", x"CCBC", x"3F6B", x"D8D3", x"F873", x"31F1", x"C054", x"28DD", x"0566", x"CF71", x"3FDB", x"D57F", x"FCC2", x"2F20", x"C009", x"2C18", x"0115", x"D25D");
--constant sin_lut	: reg_data := (x"0000",	x"2CDE",	x"C003",	x"2E62",	x"FDD7",	x"D4B3",	x"3FEA",	x"D027",	x"0452",	x"29AF",	x"C03B",	x"3141",	x"F987",	x"D7FA",	x"3F8D",	x"CD65",	x"089F",	x"2650",	x"C0BE",	x"33E7",	x"F53E",	x"DB71",	x"3EE5",	x"CADD",	x"0CE2",	x"22C4",	x"C18A",	x"364F",	x"F102",	x"DF12",	x"3DF4",	x"C894",	x"1116",	x"1F0F",	x"C2A0",	x"3879",	x"ECD8",	x"E2DA",	x"3CBB",	x"C68B",	x"1536",	x"1B36",	x"C3FD",	x"3A60",	x"E8C3",	x"E6C3",	x"3B3A",	x"C4C6",	x"193D",	x"173D",	x"C5A0",	x"3C03",	x"E4CA",	x"EACA",	x"3975",	x"C345",	x"1D26",	x"1328",	x"C787",	x"3D60",	x"E0F1",	x"EEEA",	x"376C",	x"C20C",	x"20EE",	x"0EFE",	x"C9B1",	x"3E76",	x"DD3C",	x"F31E",	x"3523",	x"C11B",	x"248F",	x"0AC2",	x"CC19",	x"3F42",	x"D9B0",	x"F761",	x"329B",	x"C073",	x"2806",	x"0679",	x"CEBF",	x"3FC5",	x"D651",	x"FBAE",	x"2FD9",	x"C016",	x"2B4D",	x"0229",	x"D19E",	x"3FFD",	x"D322",	x"0000",	x"2CDE",	x"C003",	x"2E62",	x"FDD7",	x"D4B3",	x"3FEA",	x"D027",	x"0452",	x"29AF",	x"C03B",	x"3141",	x"F987",	x"D7FA",	x"3F8D",	x"CD65",	x"089F",	x"2650",	x"C0BE",	x"33E7",	x"F53E",	x"DB71",	x"3EE5",	x"CADD",	x"0CE2",	x"22C4",	x"C18A",	x"364F",	x"F102",	x"DF12",	x"3DF4",	x"C894",	x"1116",	x"1F0F",	x"C2A0",	x"3879",	x"ECD8",	x"E2DA",	x"3CBB",	x"C68B",	x"1536",	x"1B36",	x"C3FD",	x"3A60",	x"E8C3",	x"E6C3",	x"3B3A",	x"C4C6",	x"193D",	x"173D",	x"C5A0",	x"3C03",	x"E4CA",	x"EACA",	x"3975",	x"C345",	x"1D26",	x"1328",	x"C787",	x"3D60",	x"E0F1",	x"EEEA",	x"376C",	x"C20C",	x"20EE",	x"0EFE",	x"C9B1",	x"3E76",	x"DD3C",	x"F31E",	x"3523",	x"C11B",	x"248F",	x"0AC2",	x"CC19",	x"3F42",	x"D9B0",	x"F761",	x"329B",	x"C073",	x"2806",	x"0679",	x"CEBF",	x"3FC5",	x"D651",	x"FBAE",	x"2FD9",	x"C016",	x"2B4D",	x"0229",	x"D19E",	x"3FFD",	x"D322");
--constant cos_lut	: reg_data := (x"3FFF",	x"D25E",	x"0115",	x"2C17",	x"C00A",	x"2F1F",	x"FCC2",	x"D580",	x"3FDA",	x"CF71",	x"0566",	x"28DC",	x"C055",	x"31F0",	x"F874",	x"D8D4",	x"3F6A",	x"CCBD",	x"09B1",	x"2571",	x"C0EA",	x"3487",	x"F42E",	x"DC55",	x"3EB0",	x"CA45",	x"0DF0",	x"21DA",	x"C1C9",	x"36E0",	x"EFF6",	x"E000",	x"3DAC",	x"C80C",	x"1220",	x"1E1C",	x"C2F0",	x"38F9",	x"EBD0",	x"E3D1",	x"3C61",	x"C614",	x"163A",	x"1A3A",	x"C45F",	x"3ACF",	x"E7C2",	x"E7C2",	x"3ACF",	x"C45F",	x"1A3A",	x"163A",	x"C614",	x"3C61",	x"E3D1",	x"EBD0",	x"38F9",	x"C2F0",	x"1E1C",	x"1220",	x"C80C",	x"3DAC",	x"E001",	x"EFF6",	x"36E0",	x"C1C9",	x"21DA",	x"0DF0",	x"CA45",	x"3EB0",	x"DC55",	x"F42E",	x"3487",	x"C0EA",	x"2571",	x"09B1",	x"CCBD",	x"3F6A",	x"D8D4",	x"F874",	x"31F0",	x"C055",	x"28DC",	x"0566",	x"CF71",	x"3FDA",	x"D580",	x"FCC2",	x"2F1F",	x"C00A",	x"2C17",	x"0115",	x"D25E",	x"3FFF",	x"D25E",	x"0115",	x"2C17",	x"C00A",	x"2F1F",	x"FCC2",	x"D580",	x"3FDA",	x"CF71",	x"0566",	x"28DC",	x"C055",	x"31F0",	x"F874",	x"D8D4",	x"3F6A",	x"CCBD",	x"09B1",	x"2571",	x"C0EA",	x"3487",	x"F42E",	x"DC55",	x"3EB0",	x"CA45",	x"0DF0",	x"21DA",	x"C1C9",	x"36E0",	x"EFF6",	x"E000",	x"3DAC",	x"C80C",	x"1220",	x"1E1C",	x"C2F0",	x"38F9",	x"EBD0",	x"E3D1",	x"3C61",	x"C614",	x"163A",	x"1A3A",	x"C45F",	x"3ACF",	x"E7C2",	x"E7C2",	x"3ACF",	x"C45F",	x"1A3A",	x"163A",	x"C614",	x"3C61",	x"E3D1",	x"EBD0",	x"38F9",	x"C2F0",	x"1E1C",	x"1220",	x"C80C",	x"3DAC",	x"E000",	x"EFF6",	x"36E0",	x"C1C9",	x"21DA",	x"0DF0",	x"CA45",	x"3EB0",	x"DC55",	x"F42E",	x"3487",	x"C0EA",	x"2571",	x"09B1",	x"CCBD",	x"3F6A",	x"D8D4",	x"F874",	x"31F0",	x"C055",	x"28DC",	x"0566",	x"CF71",	x"3FDA",	x"D580",	x"FCC2",	x"2F1F",	x"C00A",	x"2C17",	x"0115",	x"D25E");


--signal lut_index	: integer range 0 to 185;

begin

i_in_d	<=	i_in;
q_in_d	<= q_in;
--lut_index	<= to_integer(unsigned (iq_count_q));

--i_mul	<= cos_lut(lut_index);
--q_mul	<= sin_lut(lut_index);			
i_mul	<=	cos_lut;
q_mul	<=	sin_lut;
			
			
			
i_mul_d		<= std_logic_vector(signed(i_in_q) * signed(i_mul));
q_mul_d		<= std_logic_vector(signed(q_in_q) * signed(q_mul));

i_out_d		<=	x"7fff" when i_mul_q(33) = '0' and i_mul_q(32) /= '0' else
					x"8000" when i_mul_q(33) = '1' and i_mul_q(32) /= '1' else
					i_mul_q(32 downto 17);-------dividing by 131072
q_out_d		<=	x"7fff" when q_mul_q(33) = '0' and q_mul_q(32) /= '0' else
					x"8000" when q_mul_q(33) = '1' and q_mul_q(32) /= '1' else
					q_mul_q(32 downto 17);-------dividing by 131072				
iq_add_d		<= std_logic_vector(signed(i_out_q(15) & i_out_q) + signed(q_out_q(15) & q_out_q));
d_out_d		<=	x"7fff" when iq_add_q(16) = '0' and iq_add_q(15) = '1' else
					x"8000" when iq_add_q(16) = '1' and iq_add_q(15) = '0' else
					iq_add_q(15 downto 0);
d_tx_d		<= (x"8000") when tx_en = '0' else (d_out_q);------2's complement to straight binary
d_out			<= d_tx_q;
--iq_count_d	<= x"00" when clr_iq_count = '0' else
--					std_logic_vector(unsigned(iq_count_q) + 1) when en_iq_count = '1' else
--					iq_count_q;
--en_iq_count		<=	'1' when iq_count_q /= x"b9" else '0';
--clr_iq_count	<=	'0' when iq_count_q = x"b9" else '1';
process(clock,reset)
begin
	if (reset = '0') then
--		iq_count_q	<= (others 	=>	'0');
		i_in_q		<=	(others 	=>	'0');
		q_in_q		<=	(others	=>	'0');
		i_mul_q		<= (others	=>	'0');
		q_mul_q		<= (others	=>	'0');
		i_out_q		<=	(others	=>	'0');
		q_out_q		<=	(others	=>	'0');
		iq_add_q		<= (others 	=>	'0');
		d_out_q		<=	(others	=>	'0');
		d_tx_q		<=	(others	=> '0');
	elsif rising_edge(clock) then
--		iq_count_q	<=	iq_count_d;
		i_in_q		<=	i_in_d;
		q_in_q		<=	q_in_d;
		i_mul_q		<=	i_mul_d;
		q_mul_q		<=	q_mul_d;
		i_out_q		<= i_out_d;
		q_out_q		<=	q_out_d;
		iq_add_q		<=	iq_add_d;
		d_out_q		<= d_out_d;
		d_tx_q		<=	d_tx_d;
	end if;
end process;	
	
end architecture behavior;	
	
