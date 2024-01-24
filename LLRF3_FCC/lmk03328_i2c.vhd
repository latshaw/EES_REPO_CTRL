--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity lmk03328_i2c is
--port(clock		:	in std_logic;
--	reset			:	in std_logic;
--	init_config	:	in std_logic;	
--	sda			:	inout std_logic;
--	scl			:	out std_logic;
--	clk_done		:	out std_logic
--	);
--end entity lmk03328_i2c;
--architecture behavior of lmk03328_i2c is
--
--signal scl_cnt_d			:	std_logic_vector(10 downto 0);
--signal scl_cnt_q			:	std_logic_vector(10 downto 0);
--signal clk_reg_data_d	:	std_logic_vector(15 downto 0);
--signal clk_reg_data_q	:	std_logic_vector(15 downto 0);
--signal wait_cnt_d			:	std_logic_vector(7 downto 0);
--signal wait_cnt_q			:	std_logic_vector(7 downto 0);
--signal en_wait_cnt		:	std_logic;
--signal reg_cnt_d			:	std_logic_vector(7 downto 0);
--signal reg_cnt_q			:	std_logic_vector(7 downto 0);
--signal en_reg_cnt			:	std_logic;
--signal clr_reg_cnt		:	std_logic;
--signal data_reg_index	:	integer range 0 to 150;
--signal bit_cnt_d			:	std_logic_vector(4 downto 0);
--signal bit_cnt_q			:	std_logic_vector(4 downto 0);
--signal en_bit_cnt			:	std_logic;
--signal clr_bit_cnt		:	std_logic;
--signal data_reg_in		:	std_logic_vector(27 downto 0);
--signal data_reg_d			:	std_logic_vector(27 downto 0);
--signal data_reg_q			:	std_logic_vector(27 downto 0);
--signal ld_data_reg		:	std_logic;
--signal sh_data_reg		:	std_logic;
--signal clk_done_d			:	std_logic;
--signal clk_done_q			:	std_logic;
--signal i2c_clock			:	std_logic;
--signal pgm_cnt_q, pgm_cnt_d	:	std_logic_vector(3 downto 0);
--signal en_pgm_cnt			:	std_logic;
--signal scl_d				:	std_logic;
--signal scl_q				:	std_logic;
--signal sda_d				:	std_logic;
--signal sda_q				:	std_logic;
--
--type reg_data is array(150 downto 0) of std_logic_vector(15 downto 0);
----constant clk_reg_data	:	reg_data:= (x"0010" ,x"010B" ,x"0232" ,x"0301" ,x"0401" ,x"0500" ,x"0600" ,x"0700" ,x"0883" ,x"0900" ,x"0AA8" ,x"0B00" ,x"0CDF" ,x"0D00" ,x"0E00" ,x"0F00" ,x"1000" ,x"1100" ,x"1200" ,x"1300" ,x"14FF" ,x"15FF" ,x"16FF" ,x"1703" ,x"1800" ,x"19F5" ,x"1A00" ,x"1B08" ,x"1C28" ,x"1D02" ,x"1E38" ,x"1FB0" ,x"2030" ,x"2115" ,x"2220" ,x"2320" ,x"2416" ,x"2550" ,x"2615" ,x"273E" ,x"2818" ,x"293E" ,x"2A18" ,x"2B3E" ,x"2C18" ,x"2D0A" ,x"2E00" ,x"2F00" ,x"30FF" ,x"3100" ,x"32D5" ,x"3383" ,x"3400" ,x"3501" ,x"3600" ,x"3701" ,x"3806" ,x"3914" ,x"3A00" ,x"3B44" ,x"3C00" ,x"3D00" ,x"3E2F" ,x"3F00" ,x"4000" ,x"4146" ,x"420F" ,x"4300" ,x"4400" ,x"4501" ,x"4600" ,x"4702" ,x"4814" ,x"4900" ,x"4A46" ,x"4B00" ,x"4C00" ,x"4D02" ,x"4E00" ,x"4F00" ,x"5005" ,x"510F" ,x"5200" ,x"5300" ,x"5401" ,x"5500" ,x"5600" ,x"5700" ,x"5800" ,x"59DE" ,x"5A00" ,x"5B00" ,x"5C00" ,x"5D00" ,x"5E01" ,x"5F86" ,x"6000" ,x"6100" ,x"6200" ,x"6300" ,x"6400" ,x"6500" ,x"6600" ,x"6700" ,x"6800" ,x"6900" ,x"6A05" ,x"6B00" ,x"6C08" ,x"6D0F" ,x"6E1F" ,x"6F00" ,x"7000" ,x"7100" ,x"7200" ,x"730D" ,x"7419" ,x"7500" ,x"7607" ,x"7705" ,x"7800" ,x"7900" ,x"7A08" ,x"7B0F" ,x"7C1F" ,x"7D00" ,x"7E00" ,x"7F00" ,x"8000" ,x"810D" ,x"8219" ,x"8300" ,x"8407" ,x"850D" ,x"8600" ,x"87AF" ,x"8801" ,x"8910" ,x"8AAF" ,x"8B00" ,x"8C00" ,x"8DA8" ,x"8EFF" ,x"8F00" ,x"9000" ,x"9100" ,x"A940" ,x"AC24" ,x"AD00" ,x"0C5F" ,x"0CDF");
--constant clk_reg_data	:	reg_data:= (x"0010",	x"010B",	x"0232",	x"0301",	x"0401",	x"0500",	x"0600",	x"0700",	x"0883",	x"0900",	x"0AA8",	x"0B00",	x"0CDF",	x"0D00",	x"0E00",	x"0F00",	x"1000",	x"1100",	x"1200",	x"1300",	x"14FF",	x"15FF",	x"16FF",	x"1703",	x"1800",	x"19F5",	x"1A00",	x"1B08",	x"1C28",	x"1D02",	x"1E2C",	x"1F30",	x"2000",	x"210C",	x"2230",	x"2300",	x"2419",	x"2510",	x"2619",	x"273E",	x"2818",	x"2918",	x"2A19",	x"2B18",	x"2C0C",	x"2D0A",	x"2E00",	x"2F00",	x"30FF",	x"3100",	x"32D5",	x"3383",	x"3400",	x"3501",	x"3600",	x"3701",	x"3806",	x"3914",	x"3A00",	x"3B45",	x"3C00",	x"3D00",	x"3E03",	x"3F00",	x"4000",	x"4123",	x"420F",	x"4300",	x"4400",	x"4501",	x"4600",	x"4703",	x"4804",	x"4900",	x"4A46",	x"4B00",	x"4C00",	x"4D02",	x"4E00",	x"4F00",	x"5005",	x"510F",	x"5200",	x"5300",	x"5401",	x"5500",	x"5600",	x"5700",	x"5800",	x"59DE",	x"5A00",	x"5B00",	x"5C00",	x"5D00",	x"5E01",	x"5F86",	x"6000",	x"6100",	x"6200",	x"6300",	x"6400",	x"6500",	x"6600",	x"6700",	x"6800",	x"6900",	x"6A05",	x"6B00",	x"6C08",	x"6D0F",	x"6E1F",	x"6F00",	x"7000",	x"7100",	x"7200",	x"730D",	x"7419",	x"7500",	x"7607",	x"7705",	x"7800",	x"7900",	x"7A08",	x"7B0F",	x"7C1F",	x"7D00",	x"7E00",	x"7F00",	x"8000",	x"810D",	x"8219",	x"8300",	x"8407",	x"850D",	x"8600",	x"87AF",	x"8801",	x"8910",	x"8AAF",	x"8B00",	x"8C00",	x"8DA8",	x"8EFF",	x"8F00",	x"9000",	x"9100",	x"A940",	x"AC24",	x"AD00", x"0C5F", x"0CDF");
--
--
--type state_type is (init, data_load, scl_high, scl_low, bit_check, reg_check, stop_reg, config_done, stat_done);
--signal state				:	state_type;
--
--------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
--begin
--
--clk_reg_data_d	<=	clk_reg_data(data_reg_index);
--
--data_reg_index	<= 150 - to_integer(unsigned(reg_cnt_q));
--data_reg_in		<=	'0' & "1010100" & '0' & '1' & clk_reg_data_q(15 downto 8) & '1' & clk_reg_data_q(7 downto 0) & '1';
--scl_cnt_d		<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
--i2c_clock		<=	scl_cnt_q(10);
--wait_cnt_d		<=	std_logic_vector(unsigned(wait_cnt_q) + 1);
--bit_cnt_d		<=	(others => '0') when clr_bit_cnt = '0' else
--						std_logic_vector(unsigned(bit_cnt_q) + 1) when en_bit_cnt = '1' else
--						bit_cnt_q;
--reg_cnt_d		<=	(others => '0') when clr_reg_cnt = '0' else
--						std_logic_vector(unsigned(reg_cnt_q) + 1) when en_reg_cnt = '1' else
--						reg_cnt_q;
--data_reg_d		<=	data_reg_in when ld_data_reg = '1' else
--						data_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
--						data_reg_q;
--clk_done			<=	clk_done_q;
--pgm_cnt_d		<=	std_logic_vector(unsigned(pgm_cnt_q) + 1) when en_pgm_cnt = '1' else pgm_cnt_q;
--process(clock,reset)
--begin
--	if(reset = '0') then
--		scl_cnt_q	<=	(others => '0');
--	elsif(rising_edge(clock)) then
--		scl_cnt_q	<=	scl_cnt_d;
--	end if;
--end process;
--process(i2c_clock,reset)
--begin
--	if(reset = '0') then
--		clk_reg_data_q	<=	(others	=>	'0');
--		wait_cnt_q	<=	(others => '0');
--		bit_cnt_q	<=	(others => '0');
--		reg_cnt_q	<=	(others => '0');
--		data_reg_q	<=	(others => '0');
--		pgm_cnt_q	<=	(others	=>	'0');
--		clk_done_q	<=	'0';
--		scl_q			<=	'0';
--		sda_q			<=	'0';
--	elsif(rising_edge(i2c_clock)) then
--		clk_reg_data_q	<=	clk_reg_data_d;
--		wait_cnt_q	<=	wait_cnt_d;
--		bit_cnt_q	<=	bit_cnt_d;
--		reg_cnt_q	<=	reg_cnt_d;
--		data_reg_q	<=	data_reg_d;
--		pgm_cnt_q	<=	pgm_cnt_d;
--		clk_done_q	<=	clk_done_d;
--		scl_q			<=	scl_d;
--		sda_q			<=	sda_d;
--	end if;
--end process;	
--process(i2c_clock, reset)
--begin
--	if(reset = '0') then
--		state	<=	init;
--	elsif(rising_edge(i2c_clock)) then
--		case state is
--			when init			=>	if init_config = '1' then state <= data_load;
--										else state <= init;
--										end if;	
--			when data_load		=>	state <= scl_high;			
--			when scl_high		=>	state <= scl_low;
--			when scl_low		=>	state <= bit_check;
--			when bit_check		=>	if bit_cnt_q = "11011" then state <= reg_check;
--										else state <= scl_high;
--										end if;
--			when reg_check		=>	if reg_cnt_q = x"96" then state <= config_done;
--										else state <= stop_reg;
--										end if;
--			when stop_reg		=>	if wait_cnt_q = x"ff" then state <= data_load;
--										else state <= stop_reg;
--										end if;
--			when config_done	=>	if pgm_cnt_q =  "1111" then state	<=	stat_done;							
--										else state	<=	init;
--										end if;
--			when stat_done		=>	state	<=	stat_done;							
----			when config_done	=>	if init_config = '1' then state <= data_load;
----										else state <= config_done;
----										end if;			
--			when others			=>	state <= init;
--		end case;
--	end if;
--end process;
--en_wait_cnt			<=	'1' when state = stop_reg  else '0';
--clr_bit_cnt			<=	'0' when state = reg_check else '1';
--en_bit_cnt			<=	'1' when state = bit_check else '0';
--en_reg_cnt			<=	'1' when state = reg_check and reg_cnt_q /= x"96" else '0';
--clr_reg_cnt			<=	'0' when state = reg_check and reg_cnt_q = x"96" else '1';
--ld_data_reg			<=	'1' when state = data_load else '0';
--sh_data_reg			<=	'1' when state = scl_low else '0';
--scl_d					<=	'0' when state = scl_low or state = bit_check else '1';
--sda_d					<=	'1' when state = init or state = data_load or state = stop_reg or state = config_done else
--							'0' when state = reg_check else
--							data_reg_q(27);
--scl					<=	'0' when scl_q = '0' else 'Z';							
--sda					<=	'0' when sda_q = '0' else 'Z';
--clk_done_d			<=	'1' when state = stat_done else '0';
--en_pgm_cnt			<=	'1' when state = config_done and pgm_cnt_q /= "1111" else '0';	
--end architecture behavior;	
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity lmk03328_i2c is
--port(clock		:	in std_logic;
--	reset			:	in std_logic;
--	init_config	:	in std_logic;	
--	sda			:	inout std_logic;
--	scl			:	out std_logic;
--	clk_done		:	out std_logic;
--	pll_lock	:	out std_logic;
--	pll_ref		:	out std_logic
----	pll_rd_valid : out std_logic
--	);
--end entity lmk03328_i2c;
--architecture behavior of lmk03328_i2c is
--
--type state_type is (init, data_load, scl_high, scl_low, bit_check, reg_check, stop_reg, config_done, rd_state, rd_wait);
--
--
--type reg_record is record
--rd_sda			:	std_logic_vector(97 downto 0);	
--rd_scl			:	std_logic_vector(97 downto 0);
--data_reg_in		:	std_logic_vector(27 downto 0);
--init_config		:	std_logic;
--wait_cnt			:	unsigned(7 downto 0);
--reg_cnt			:	unsigned(7 downto 0);
--bit_cnt			:	unsigned(4 downto 0);
--rd_cnt			:	integer range 0 to 127;
--data_reg			:	std_logic_vector(27 downto 0);
--clk_reg_data	:	std_logic_vector(15 downto 0);
--clk_done			:	std_logic;
--pgm_cnt			:	unsigned(3 downto 0);
--sda				:	std_logic;
--scl				:	std_logic;
--state			:	state_type;
--sda_in			:	std_logic;
--rd_reg			:	std_logic_vector(7 downto 0);
--lock			:	std_logic;
--ref				:	std_logic;
--end record reg_record;
--
--
--type reg_data is array(150 downto 0) of std_logic_vector(15 downto 0);
--constant clk_reg_data	:	reg_data:= (x"0010",	x"010B",	x"0232",	x"0301",	x"0401",	x"0500",	x"0600",	x"0700",	x"0883",	x"0900",	x"0AA8",	x"0B00",	x"0CDF",	x"0D00",	x"0E00",	x"0F00",	x"1000",	x"1100",	x"1200",	x"1300",	x"14FF",	x"15FF",	x"16FF",	x"1703",	x"1800",	x"19F5",	x"1A00",	x"1B08",	x"1C28",	x"1D02",	x"1E2C",	x"1F30",	x"2000",	x"210C",	x"2230",	x"2300",	x"2419",	x"2510",	x"2619",	x"273E",	x"2818",	x"2918",	x"2A19",	x"2B18",	x"2C0C",	x"2D0A",	x"2E00",	x"2F00",	x"30FF",	x"3100",	x"32D5",	x"3383",	x"3400",	x"3501",	x"3600",	x"3701",	x"3806",	x"3914",	x"3A00",	x"3B45",	x"3C00",	x"3D00",	x"3E03",	x"3F00",	x"4000",	x"4123",	x"420F",	x"4300",	x"4400",	x"4501",	x"4600",	x"4703",	x"4804",	x"4900",	x"4A46",	x"4B00",	x"4C00",	x"4D02",	x"4E00",	x"4F00",	x"5005",	x"510F",	x"5200",	x"5300",	x"5401",	x"5500",	x"5600",	x"5700",	x"5800",	x"59DE",	x"5A00",	x"5B00",	x"5C00",	x"5D00",	x"5E01",	x"5F86",	x"6000",	x"6100",	x"6200",	x"6300",	x"6400",	x"6500",	x"6600",	x"6700",	x"6800",	x"6900",	x"6A05",	x"6B00",	x"6C08",	x"6D0F",	x"6E1F",	x"6F00",	x"7000",	x"7100",	x"7200",	x"730D",	x"7419",	x"7500",	x"7607",	x"7705",	x"7800",	x"7900",	x"7A08",	x"7B0F",	x"7C1F",	x"7D00",	x"7E00",	x"7F00",	x"8000",	x"810D",	x"8219",	x"8300",	x"8407",	x"850D",	x"8600",	x"87AF",	x"8801",	x"8910",	x"8AAF",	x"8B00",	x"8C00",	x"8DA8",	x"8EFF",	x"8F00",	x"9000",	x"9100",	x"A940",	x"AC24",	x"AD00", x"0C5F", x"0CDF");
--
--
--signal scl_cnt_d,scl_cnt_q			:	std_logic_vector(10 downto 0);
--signal data_reg_index	:	integer range 0 to 150;
--signal i2c_clock			:	std_logic;
--signal d,q				:	reg_record;
--
--
--
--
--------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
--begin
--
--data_reg_index	<= 150 - to_integer(unsigned(q.reg_cnt));
--d.clk_reg_data		<=	clk_reg_data(data_reg_index);
--d.data_reg_in		<=	'0' & "1010100" & '0' & '1' & q.clk_reg_data(15 downto 8) & '1' & q.clk_reg_data(7 downto 0) & '1';
--scl_cnt_d		<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
--i2c_clock		<=	scl_cnt_q(10);
----d.wait_cnt		<=	q.wait_cnt + 1;
--d.init_config	<=	init_config;
----rd_sda	<=	"101100110011000100ZZ0000000011110011ZZ101100110011000111ZZZZZZZZZZZZZZZZZZZZ01"; 
----rd_scl	<=	"110101010101010101010101010101010101011101010101010101010101010101010101010111";
--d.sda_in	<=	sda;
--
--process(clock,reset)
--begin
--	if(reset = '0') then
--		scl_cnt_q	<=	(others	=>	'0');
--	elsif(rising_edge(clock)) then
--		scl_cnt_q	<=	scl_cnt_d;
--	end if;
--end process;
--process(i2c_clock,reset)
--begin
--	if(reset = '0') then
--		q.data_reg_in	<=	(others	=>	'0');
--		q.wait_cnt	<=	(others => '0');
--		q.bit_cnt	<=	(others => '0');
--		q.reg_cnt	<=	(others => '0');
--		q.data_reg	<=	(others => '0');
--		q.clk_reg_data	<=	(others	=>	'0');
--		q.pgm_cnt	<=	(others	=>	'0');
--		q.clk_done	<=	'0';
--		q.state		<=	init;
--		q.sda		<=	'1';
--		q.scl		<=	'1';
--		q.init_config	<=	'0';
--		q.rd_scl	<=	(others	=>	'0');
--		q.rd_sda	<=	(others	=>	'0');
--		q.rd_cnt	<=	0;
--		q.sda_in	<=	'0';
--		q.rd_reg	<=	(others	=>	'1');
--		q.lock		<=	'0';
--		q.ref		<=	'0';
--	elsif(rising_edge(i2c_clock)) then
--		q			<=	d;
--	end if;
--end process;	
--process(q)
--begin
--	d.wait_cnt	<=	q.wait_cnt;
--	d.bit_cnt	<=	q.bit_cnt;
--	d.reg_cnt	<=	q.reg_cnt;
--	d.data_reg	<=	q.data_reg;
--	d.pgm_cnt	<=	q.pgm_cnt;
--	d.clk_done	<=	q.clk_done;
--	d.state		<=	q.state;
--	d.sda		<=	q.sda;
--	d.scl		<=	q.scl;
--	d.rd_sda	<=	q.rd_sda;
--	d.rd_scl	<=	q.rd_scl;
--	d.rd_cnt	<=	q.rd_cnt;	
--	case q.state is
--		when init	=>
--			if q.init_config = '1' then
--				d.data_reg	<=	q.data_reg_in;
--				d.state <= data_load;
--			end if;	
--		when data_load	=>			
--			d.state 	<= scl_high;
--			d.sda	<=	q.data_reg(27);
--		when scl_high	=>
--			d.scl		<=	'0';
--			d.data_reg	<=	q.data_reg(26 downto 0) & '0';
--			d.state <= scl_low;			
--		when scl_low		=>		
--			d.sda	<=	q.data_reg(27);
--			d.state <= bit_check;
--		when bit_check	=>
--			d.bit_cnt	<=	q.bit_cnt + 1;			
--			if q.bit_cnt = "11011" then
--				d.bit_cnt	<=	(others	=>	'0');
--				d.state 	<= reg_check;
--			else				
--				d.scl	<=	'1';
--				d.state <= scl_high;
--			end if;
--		when reg_check		=>
--			d.sda		<=	'0';
--			d.scl		<=	'1';
--			d.reg_cnt	<=	q.reg_cnt + 1;
--			if q.reg_cnt = x"96" then
--				d.reg_cnt	<=	(others	=>	'0');
--				d.state <= config_done;
--			else
--				d.state <= stop_reg;
--			end if;
--		when stop_reg	=>
--			d.wait_cnt	<=	q.wait_cnt + 1;
--			d.sda		<=	'1';
--			if q.wait_cnt = x"ff" then
--				d.data_reg	<=	q.data_reg_in;
--				d.state <= data_load;
--			else
--				d.state <= stop_reg;
--			end if;
--		when config_done	=>			
--			if q.pgm_cnt =  "1111" then
--				d.rd_sda	<=	"11110011001100110000001111000000001111001111111111001100110011000011111111111111111111111111000011";
--				d.rd_scl	<=	"11111101010101010101010100010101010101010101000011110101010101010101010001010101010101010100001111";
--				d.clk_done	<=	'1';
--				d.state	<=	rd_state;							
--			else 
--				d.pgm_cnt	<=	q.pgm_cnt + 1;
--				d.state		<=	init;
--			end if;
--		when rd_state	=>
--			d.rd_cnt	<=	q.rd_cnt + 1;
--			d.sda	<=	q.rd_sda(97);
--			d.scl	<=	q.rd_scl(97);			
--			d.rd_sda	<=	q.rd_sda(96 downto 0)&'0';	
--			d.rd_scl	<=	q.rd_scl(96 downto 0)&'0';			
--			if(q.rd_cnt = 96) then				
--				d.rd_cnt	<=	0;
--				d.rd_sda	<=	"11110011001100110000001111000000001111001111111111001100110011000011111111111111111111111111000011";
--				d.rd_scl	<=	"11111101010101010101010100010101010101010101000011110101010101010101010001010101010101010100001111";
--				d.state	<=	rd_wait;		
--			end if;
--		when rd_wait	=>		
--			d.wait_cnt	<=	q.wait_cnt + 1;
--			if q.wait_cnt = x"ff" then
--				d.state	<=	rd_state;
--			end if;
--		when others			=>	d.state <= init;
--		end case;
--end process;
--
--
--d.rd_reg	<=	q.rd_reg(6 downto 0)&sda when (q.scl = '1' and q.rd_cnt > 72 and q.rd_cnt < 89) else q.rd_reg;
--d.lock	<=	q.rd_reg(7) when q.rd_cnt = 96 else q.lock;
--d.ref		<=	q.rd_reg(6) when q.rd_cnt = 96 else q.ref;
--			
--clk_done	<=	q.clk_done;
--scl			<=	'0' when q.scl = '0' else 'Z';
--sda			<=	'0' when q.sda = '0' else 'Z';
--pll_lock		<=	q.lock;
--pll_ref		<=	q.ref;
----pll_rd_valid	<=	'1' when q.rd_reg = x"12" else '0';
--end architecture behavior;
--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity lmk03328_i2c is
--port(clock		:	in std_logic;
--	reset			:	in std_logic;
--	init_config	:	in std_logic;	
--	sda			:	inout std_logic;
--	scl			:	out std_logic;
--	clk_done		:	out std_logic
--	);
--end entity lmk03328_i2c;
--architecture behavior of lmk03328_i2c is
--
--signal scl_cnt_d			:	std_logic_vector(10 downto 0);
--signal scl_cnt_q			:	std_logic_vector(10 downto 0);
--signal wait_cnt_d			:	std_logic_vector(7 downto 0);
--signal wait_cnt_q			:	std_logic_vector(7 downto 0);
--signal en_wait_cnt		:	std_logic;
--signal reg_cnt_d			:	std_logic_vector(7 downto 0);
--signal reg_cnt_q			:	std_logic_vector(7 downto 0);
--signal en_reg_cnt			:	std_logic;
--signal clr_reg_cnt		:	std_logic;
--signal data_reg_index	:	integer range 0 to 152;
--signal bit_cnt_d			:	std_logic_vector(4 downto 0);
--signal bit_cnt_q			:	std_logic_vector(4 downto 0);
--signal en_bit_cnt			:	std_logic;
--signal clr_bit_cnt		:	std_logic;
--signal data_reg_in		:	std_logic_vector(27 downto 0);
--signal data_reg_d			:	std_logic_vector(27 downto 0);
--signal data_reg_q			:	std_logic_vector(27 downto 0);
--signal ld_data_reg		:	std_logic;
--signal sh_data_reg		:	std_logic;
--signal clk_done_d			:	std_logic;
--signal clk_done_q			:	std_logic;
--signal i2c_clock			:	std_logic;
--signal pgm_cnt_q, pgm_cnt_d	:	std_logic_vector(3 downto 0);
--signal en_pgm_cnt			:	std_logic;
--signal scl_d, scl_q		:	std_logic;
--signal sda_d, sda_q		:	std_logic;
--signal init_config_q		:	std_logic;
--signal init_wait_cnt_d	:	std_logic_vector(19 downto 0);
--signal init_wait_cnt_q	:	std_logic_vector(19 downto 0);
--
--type reg_data is array(152 downto 0) of std_logic_vector(15 downto 0);
----constant clk_reg_data	:	reg_data:= (x"0010" ,x"010B" ,x"0232" ,x"0301" ,x"0401" ,x"0500" ,x"0600" ,x"0700" ,x"0883" ,x"0900" ,x"0AA8" ,x"0B00" ,x"0CDF" ,x"0D00" ,x"0E00" ,x"0F00" ,x"1000" ,x"1100" ,x"1200" ,x"1300" ,x"14FF" ,x"15FF" ,x"16FF" ,x"1703" ,x"1800" ,x"19F5" ,x"1A00" ,x"1B08" ,x"1C28" ,x"1D02" ,x"1E38" ,x"1FB0" ,x"2030" ,x"2115" ,x"2220" ,x"2320" ,x"2416" ,x"2550" ,x"2615" ,x"273E" ,x"2818" ,x"293E" ,x"2A18" ,x"2B3E" ,x"2C18" ,x"2D0A" ,x"2E00" ,x"2F00" ,x"30FF" ,x"3100" ,x"32D5" ,x"3383" ,x"3400" ,x"3501" ,x"3600" ,x"3701" ,x"3806" ,x"3914" ,x"3A00" ,x"3B44" ,x"3C00" ,x"3D00" ,x"3E2F" ,x"3F00" ,x"4000" ,x"4146" ,x"420F" ,x"4300" ,x"4400" ,x"4501" ,x"4600" ,x"4702" ,x"4814" ,x"4900" ,x"4A46" ,x"4B00" ,x"4C00" ,x"4D02" ,x"4E00" ,x"4F00" ,x"5005" ,x"510F" ,x"5200" ,x"5300" ,x"5401" ,x"5500" ,x"5600" ,x"5700" ,x"5800" ,x"59DE" ,x"5A00" ,x"5B00" ,x"5C00" ,x"5D00" ,x"5E01" ,x"5F86" ,x"6000" ,x"6100" ,x"6200" ,x"6300" ,x"6400" ,x"6500" ,x"6600" ,x"6700" ,x"6800" ,x"6900" ,x"6A05" ,x"6B00" ,x"6C08" ,x"6D0F" ,x"6E1F" ,x"6F00" ,x"7000" ,x"7100" ,x"7200" ,x"730D" ,x"7419" ,x"7500" ,x"7607" ,x"7705" ,x"7800" ,x"7900" ,x"7A08" ,x"7B0F" ,x"7C1F" ,x"7D00" ,x"7E00" ,x"7F00" ,x"8000" ,x"810D" ,x"8219" ,x"8300" ,x"8407" ,x"850D" ,x"8600" ,x"87AF" ,x"8801" ,x"8910" ,x"8AAF" ,x"8B00" ,x"8C00" ,x"8DA8" ,x"8EFF" ,x"8F00" ,x"9000" ,x"9100" ,x"A940" ,x"AC24" ,x"AD00" ,x"0C5F" ,x"0CDF");
--constant clk_reg_data	:	reg_data:= (x"0010", x"0010" , x"0010",	x"010B",	x"0232",	x"0301",	x"0401",	x"0500",	x"0600",	x"0700",	x"0883",	x"0900",	x"0AA8",	x"0B00",	x"0CDF",	x"0D00",	x"0E00",	x"0F00",	x"1000",	x"1100",	x"1200",	x"1300",	x"14FF",	x"15FF",	x"16FF",	x"1703",	x"1800",	x"19F5",	x"1A00",	x"1B08",	x"1C28",	x"1D02",	x"1E2C",	x"1F30",	x"2000",	x"210C",	x"2230",	x"2300",	x"2419",	x"2510",	x"2619",	x"273E",	x"2818",	x"2918",	x"2A19",	x"2B18",	x"2C0C",	x"2D0A",	x"2E00",	x"2F00",	x"30FF",	x"3100",	x"32D5",	x"3383",	x"3400",	x"3501",	x"3600",	x"3701",	x"3806",	x"3914",	x"3A00",	x"3B45",	x"3C00",	x"3D00",	x"3E03",	x"3F00",	x"4000",	x"4123",	x"420F",	x"4300",	x"4400",	x"4501",	x"4600",	x"4703",	x"4804",	x"4900",	x"4A46",	x"4B00",	x"4C00",	x"4D02",	x"4E00",	x"4F00",	x"5005",	x"510F",	x"5200",	x"5300",	x"5401",	x"5500",	x"5600",	x"5700",	x"5800",	x"59DE",	x"5A00",	x"5B00",	x"5C00",	x"5D00",	x"5E01",	x"5F86",	x"6000",	x"6100",	x"6200",	x"6300",	x"6400",	x"6500",	x"6600",	x"6700",	x"6800",	x"6900",	x"6A05",	x"6B00",	x"6C08",	x"6D0F",	x"6E1F",	x"6F00",	x"7000",	x"7100",	x"7200",	x"730D",	x"7419",	x"7500",	x"7607",	x"7705",	x"7800",	x"7900",	x"7A08",	x"7B0F",	x"7C1F",	x"7D00",	x"7E00",	x"7F00",	x"8000",	x"810D",	x"8219",	x"8300",	x"8407",	x"850D",	x"8600",	x"87AF",	x"8801",	x"8910",	x"8AAF",	x"8B00",	x"8C00",	x"8DA8",	x"8EFF",	x"8F00",	x"9000",	x"9100",	x"A940",	x"AC24",	x"AD00", x"0C5F", x"0CDF");
--
--
--type state_type is (init, data_load, scl_high, scl_low, bit_check, reg_check, stop_reg, config_done, stat_done);
--signal state				:	state_type;
--
--------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
--begin
--
--data_reg_index	<= 152 - to_integer(unsigned(reg_cnt_q));
--data_reg_in		<=	'0' & "1010100" & '0' & '1' & clk_reg_data(data_reg_index)(15 downto 8) & '1' & clk_reg_data(data_reg_index)(7 downto 0) & '1';
--scl_cnt_d		<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
--i2c_clock		<=	scl_cnt_q(10);
--wait_cnt_d		<=	std_logic_vector(unsigned(wait_cnt_q) + 1);
--bit_cnt_d		<=	(others => '0') when clr_bit_cnt = '0' else
--						std_logic_vector(unsigned(bit_cnt_q) + 1) when en_bit_cnt = '1' else
--						bit_cnt_q;
--reg_cnt_d		<=	(others => '0') when clr_reg_cnt = '0' else
--						std_logic_vector(unsigned(reg_cnt_q) + 1) when en_reg_cnt = '1' else
--						reg_cnt_q;
--data_reg_d		<=	data_reg_in when ld_data_reg = '1' else
--						data_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
--						data_reg_q;
--clk_done			<=	clk_done_q;
--pgm_cnt_d		<=	std_logic_vector(unsigned(pgm_cnt_q) + 1) when en_pgm_cnt = '1' else pgm_cnt_q;
--init_wait_cnt_d	<=	std_logic_vector(unsigned(init_wait_cnt_q) + 1) when init_wait_cnt_q /= x"fffff" else
--							init_wait_cnt_q;
--process(clock,reset)
--begin
--	if(reset = '0') then
--		scl_cnt_q	<=	(others => '0');
--	elsif(rising_edge(clock)) then
--		scl_cnt_q	<=	scl_cnt_d;
--	end if;
--end process;
--process(i2c_clock,reset)
--begin
--	if(reset = '0') then
--		wait_cnt_q	<=	(others => '0');
--		bit_cnt_q	<=	(others => '0');
--		reg_cnt_q	<=	(others => '0');
--		data_reg_q	<=	(others => '0');
--		pgm_cnt_q	<=	(others	=>	'0');		
--		clk_done_q	<=	'0';
--		scl_q			<=	'1';
--		sda_q			<=	'1';
--		init_config_q	<=	'0';
--		init_wait_cnt_q	<=	(others	=>	'0');
--	elsif(rising_edge(i2c_clock)) then
--		wait_cnt_q	<=	wait_cnt_d;
--		bit_cnt_q	<=	bit_cnt_d;
--		reg_cnt_q	<=	reg_cnt_d;
--		data_reg_q	<=	data_reg_d;
--		pgm_cnt_q	<=	pgm_cnt_d;
--		clk_done_q	<=	clk_done_d;
--		scl_q			<=	scl_d;
--		sda_q			<=	sda_d;
--		init_config_q	<=	init_config;
--		init_wait_cnt_q	<=	init_wait_cnt_d;
--	end if;
--end process;	
--process(i2c_clock, reset)
--begin
--	if(reset = '0') then
--		state	<=	init;
--	elsif(rising_edge(i2c_clock)) then
--		case state is
----			when init			=>	if init_config_q = '1' then state <= data_load;
----										else state <= init;
----										end if;	
--			when init			=>	if init_wait_cnt_q = x"fffff" then state	<=	data_load;
--										else state	<=	init;
--										end if;
--			when data_load		=>	state <= scl_high;			
--			when scl_high		=>	state <= scl_low;
--			when scl_low		=>	state <= bit_check;
--			when bit_check		=>	if bit_cnt_q = "11011" then state <= reg_check;
--										else state <= scl_high;
--										end if;
--			when reg_check		=>	if reg_cnt_q = x"98" then state <= config_done;
--										else state <= stop_reg;
--										end if;
--			when stop_reg		=>	if wait_cnt_q = x"ff" then state <= data_load;
--										else state <= stop_reg;
--										end if;
--			when config_done	=>	if pgm_cnt_q =  "1111" then state	<=	stat_done;							
--										else state	<=	data_load;
--										end if;
--			when stat_done		=>	state	<=	stat_done;							
----			when config_done	=>	if init_config = '1' then state <= data_load;
----										else state <= config_done;
----										end if;			
--			when others			=>	state <= init;
--		end case;
--	end if;
--end process;
--en_wait_cnt			<=	'1' when state = stop_reg  else '0';
--clr_bit_cnt			<=	'0' when state = reg_check else '1';
--en_bit_cnt			<=	'1' when state = bit_check and bit_cnt_q /= "11011" else '0';
--en_reg_cnt			<=	'1' when state = reg_check and reg_cnt_q /= x"98" else '0';
--clr_reg_cnt			<=	'0' when state = reg_check and reg_cnt_q = x"98" else '1';
--ld_data_reg			<=	'1' when state = data_load else '0';
--sh_data_reg			<=	'1' when state = scl_low else '0';
--scl					<=	'0' when state = scl_low or state = bit_check else '1';
--sda_d					<=	'1' when state = init or state = data_load or state = stop_reg or state = config_done else
--							'0' when state = reg_check else
--							data_reg_q(27);
----scl					<=	'0' when scl_q = '0' else 'Z';
--sda					<=	'0' when sda_d = '0' else 'Z';							
--clk_done_d			<=	'1' when state = stat_done else '0';
--en_pgm_cnt			<=	'1' when state = config_done and pgm_cnt_q /= "1111" else '0';	
--end architecture behavior;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lmk03328_i2c is
port(clock		:	in std_logic;
	reset			:	in std_logic;
	init_config	:	in std_logic;	
	sda			:	inout std_logic;
	scl			:	out std_logic;
	clk_done		:	out std_logic
	);
end entity lmk03328_i2c;
architecture behavior of lmk03328_i2c is

signal scl_cnt_d			:	std_logic_vector(10 downto 0);
signal scl_cnt_q			:	std_logic_vector(10 downto 0);
signal wait_cnt_d			:	std_logic_vector(7 downto 0);
signal wait_cnt_q			:	std_logic_vector(7 downto 0);
signal en_wait_cnt		:	std_logic;
signal reg_cnt_d			:	integer range 0 to 511;
signal reg_cnt_q			:	integer range 0 to 511;
signal en_reg_cnt			:	std_logic;
signal clr_reg_cnt		:	std_logic;
signal data_reg_index	:	integer range 0 to 511;
signal bit_cnt_d			:	std_logic_vector(4 downto 0);
signal bit_cnt_q			:	std_logic_vector(4 downto 0);
signal en_bit_cnt			:	std_logic;
signal clr_bit_cnt		:	std_logic;
signal data_reg_in		:	std_logic_vector(27 downto 0);
signal data_reg_d			:	std_logic_vector(27 downto 0);
signal data_reg_q			:	std_logic_vector(27 downto 0);
signal ld_data_reg		:	std_logic;
signal sh_data_reg		:	std_logic;
signal clk_done_d			:	std_logic;
signal clk_done_q			:	std_logic;
signal i2c_clock			:	std_logic;
signal pgm_cnt_q, pgm_cnt_d	:	std_logic_vector(3 downto 0);
signal en_pgm_cnt			:	std_logic;
signal scl_d, scl_q		:	std_logic;
signal sda_d, sda_q		:	std_logic;
signal init_config_q		:	std_logic;
signal init_wait_cnt_d	:	std_logic_vector(19 downto 0);
signal init_wait_cnt_q	:	std_logic_vector(19 downto 0);
signal ack					:	std_logic_vector(1 downto 0);
signal clk_reg_data_d	:	std_logic_vector(15 downto 0); 
signal clk_reg_data_q	:	std_logic_vector(15 downto 0);

signal data_in_d, data_in_q	:	std_logic_vector(26 downto 0);

--type reg_data is array(83 downto 0) of std_logic_vector(15 downto 0);
--constant clk_reg_data	:	reg_data:= (x"0010" ,x"010B" ,x"0232" ,x"0301" ,x"0401" ,x"0500" ,x"0600" ,x"0700" ,x"0883" ,x"0900" ,x"0AA8" ,x"0B00" ,x"0CDF" ,x"0D00" ,x"0E00" ,x"0F00" ,x"1000" ,x"1100" ,x"1200" ,x"1300" ,x"14FF" ,x"15FF" ,x"16FF" ,x"1703" ,x"1800" ,x"19F5" ,x"1A00" ,x"1B08" ,x"1C28" ,x"1D02" ,x"1E38" ,x"1FB0" ,x"2030" ,x"2115" ,x"2220" ,x"2320" ,x"2416" ,x"2550" ,x"2615" ,x"273E" ,x"2818" ,x"293E" ,x"2A18" ,x"2B3E" ,x"2C18" ,x"2D0A" ,x"2E00" ,x"2F00" ,x"30FF" ,x"3100" ,x"32D5" ,x"3383" ,x"3400" ,x"3501" ,x"3600" ,x"3701" ,x"3806" ,x"3914" ,x"3A00" ,x"3B44" ,x"3C00" ,x"3D00" ,x"3E2F" ,x"3F00" ,x"4000" ,x"4146" ,x"420F" ,x"4300" ,x"4400" ,x"4501" ,x"4600" ,x"4702" ,x"4814" ,x"4900" ,x"4A46" ,x"4B00" ,x"4C00" ,x"4D02" ,x"4E00" ,x"4F00" ,x"5005" ,x"510F" ,x"5200" ,x"5300" ,x"5401" ,x"5500" ,x"5600" ,x"5700" ,x"5800" ,x"59DE" ,x"5A00" ,x"5B00" ,x"5C00" ,x"5D00" ,x"5E01" ,x"5F86" ,x"6000" ,x"6100" ,x"6200" ,x"6300" ,x"6400" ,x"6500" ,x"6600" ,x"6700" ,x"6800" ,x"6900" ,x"6A05" ,x"6B00" ,x"6C08" ,x"6D0F" ,x"6E1F" ,x"6F00" ,x"7000" ,x"7100" ,x"7200" ,x"730D" ,x"7419" ,x"7500" ,x"7607" ,x"7705" ,x"7800" ,x"7900" ,x"7A08" ,x"7B0F" ,x"7C1F" ,x"7D00" ,x"7E00" ,x"7F00" ,x"8000" ,x"810D" ,x"8219" ,x"8300" ,x"8407" ,x"850D" ,x"8600" ,x"87AF" ,x"8801" ,x"8910" ,x"8AAF" ,x"8B00" ,x"8C00" ,x"8DA8" ,x"8EFF" ,x"8F00" ,x"9000" ,x"9100" ,x"A940" ,x"AC24" ,x"AD00" ,x"0C5F" ,x"0CDF");
--signal clk_reg_data	:	reg_data:= (x"0010", x"0010", x"0010",	x"010B",	x"0232",	x"0301",	x"0401",	x"0500",	x"0600",	x"0700",	x"0883",	x"0900",	x"0AA8",	x"0B00",	x"0CDF",	x"0D00",	x"0E00",	x"0F00",	x"1000",	x"1100",	x"1200",	x"1300",	x"14FF",	x"15FF",	x"16FF",	x"1703",	x"1800",	x"19F5",	x"1A00",	x"1B08",	x"1C28",	x"1D02",	x"1E2C",	x"1F30",	x"2000",	x"210C",	x"2230",	x"2300",	x"2419",	x"2510",	x"2619",	x"273E",	x"2818",	x"2918",	x"2A19",	x"2B18",	x"2C0C",	x"2D0A",	x"2E00",	x"2F00",	x"30FF",	x"3100",	x"32D5",	x"3383",	x"3400",	x"3501",	x"3600",	x"3701",	x"3806",	x"3914",	x"3A00",	x"3B45",	x"3C00",	x"3D00",	x"3E03",	x"3F00",	x"4000",	x"4123",	x"420F",	x"4300",	x"4400",	x"4501",	x"4600",	x"4703",	x"4804",	x"4900",	x"4A46",	x"4B00",	x"4C00",	x"4D02",	x"4E00",	x"4F00",	x"5005",	x"510F",	x"5200",	x"5300",	x"5401",	x"5500",	x"5600",	x"5700",	x"5800",	x"59DE",	x"5A00",	x"5B00",	x"5C00",	x"5D00",	x"5E01",	x"5F86",	x"6000",	x"6100",	x"6200",	x"6300",	x"6400",	x"6500",	x"6600",	x"6700",	x"6800",	x"6900",	x"6A05",	x"6B00",	x"6C08",	x"6D0F",	x"6E1F",	x"6F00",	x"7000",	x"7100",	x"7200",	x"730D",	x"7419",	x"7500",	x"7607",	x"7705",	x"7800",	x"7900",	x"7A08",	x"7B0F",	x"7C1F",	x"7D00",	x"7E00",	x"7F00",	x"8000",	x"810D",	x"8219",	x"8300",	x"8407",	x"850D",	x"8600",	x"87AF",	x"8801",	x"8910",	x"8AAF",	x"8B00",	x"8C00",	x"8DA8",	x"8EFF",	x"8F00",	x"9000",	x"9100",	x"A940",	x"AC24",	x"AD00", x"0C5F", x"0CDF");
--signal clk_reg_data	:	reg_data:= (x"0CDF",	x"0E00",	x"0F00",	x"1100",	x"1300",	x"14FF",	x"15FF",	x"16FF",	x"1703",	x"1800",	x"19F5",	x"1B08",	x"1C28",	x"1D02",	x"1E0C",	x"1F30",	x"2000",	x"210C",	x"2230",	x"2300",	x"2419",	x"2510",	x"2619",	x"273E",	x"2818",	x"2918",	x"2A19",	x"2B18",	x"2C0C",	x"2D0A",	x"2E00",	x"2F00",	x"3100",	x"32D5",	x"3383",	x"3400",	x"3501",	x"3600",	x"3701",	x"3806",	x"3914",	x"3A00",	x"3B45",	x"3C00",	x"3D00",	x"3E03",	x"3F00",	x"4000",	x"4123",	x"420F",	x"4300",	x"4400",	x"4501",	x"4600",	x"4703",	x"5600",	x"5800",	x"59DE",	x"5A00",	x"5B00",	x"5C00",	x"5D00",	x"5E01",	x"5F86",	x"6000",	x"6100",	x"6200",	x"6300",	x"6400",	x"6500",	x"6600",	x"6700",	x"6800",	x"6900",	x"7500",	x"7607",	x"7705",	x"7800",	x"8910",	x"8B00",	x"8C00",	x"8EFF",	x"0C5F", x"0CDF");

type state_type is (init, data_load, scl_high, scl_low, bit_check, reg_check, stop_reg, config_done, stat_done);
signal state				:	state_type;

------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
begin

--clk_reg_data_d	<=	clk_reg_data(data_reg_index);
-------------------------clock configuration rom------------------------
process(i2c_clock)
begin
	if(rising_edge(i2c_clock)) then
		case reg_cnt_q is
			when 0	=> clk_reg_data_d  <= 	x"0CDF";			
			when 1 	=> clk_reg_data_d  <= 	x"0E00";
			when 2 	=> clk_reg_data_d  <= 	x"0F00";
			when 3 	=> clk_reg_data_d  <= 	x"1100";
			when 4 	=> clk_reg_data_d  <= 	x"1300";
			when 5 	=> clk_reg_data_d  <= 	x"14FF";
			when 6 	=> clk_reg_data_d  <= 	x"15FF";
			when 7 	=> clk_reg_data_d  <= 	x"16FF";
			when 8 	=> clk_reg_data_d  <= 	x"1703";
			when 9 	=> clk_reg_data_d  <= 	x"1800";
			when 10 => clk_reg_data_d  <= 	x"19F5";
			when 11 => clk_reg_data_d  <= 	x"1B08";
			when 12 => clk_reg_data_d  <= 	x"1C28";
			when 13 => clk_reg_data_d  <= 	x"1D02";
			when 14 => clk_reg_data_d  <= 	x"1E0C";
			when 15 => clk_reg_data_d  <= 	x"1F30";
			when 16 => clk_reg_data_d  <= 	x"2000";
			when 17 => clk_reg_data_d  <= 	x"210C";
			when 18 => clk_reg_data_d  <= 	x"2230";
			when 19 => clk_reg_data_d  <= 	x"2300";
			when 20 => clk_reg_data_d  <= 	x"2419";
			when 21 => clk_reg_data_d  <= 	x"2510";
			when 22 => clk_reg_data_d  <= 	x"2619";
			when 23 => clk_reg_data_d  <= 	x"273E";
			when 24 => clk_reg_data_d  <= 	x"2818";
			when 25 => clk_reg_data_d  <= 	x"2918";
			when 26 => clk_reg_data_d  <= 	x"2A19";
			when 27 => clk_reg_data_d  <= 	x"2B18";
			when 28 => clk_reg_data_d  <= 	x"2C0C";
			when 29 => clk_reg_data_d  <= 	x"2D0A";
			when 30 => clk_reg_data_d  <= 	x"2E00";
			when 31 => clk_reg_data_d  <= 	x"2F00";
			when 32 => clk_reg_data_d  <= 	x"3100";
			when 33 => clk_reg_data_d  <= 	x"32D5";
			when 34 => clk_reg_data_d  <= 	x"3383";
			when 35 => clk_reg_data_d  <= 	x"3400";
			when 36 => clk_reg_data_d  <= 	x"3501";
			when 37 => clk_reg_data_d  <= 	x"3600";
			when 38 => clk_reg_data_d  <= 	x"3701";
			when 39 => clk_reg_data_d  <= 	x"3806";
			when 40 => clk_reg_data_d  <= 	x"3914";
			when 41 => clk_reg_data_d  <= 	x"3A00";
			when 42 => clk_reg_data_d  <= 	x"3B45";
			when 43 => clk_reg_data_d  <= 	x"3C00";
			when 44 => clk_reg_data_d  <= 	x"3D00";
			when 45 => clk_reg_data_d  <= 	x"3E03";
			when 46 => clk_reg_data_d  <= 	x"3F00";
			when 47 => clk_reg_data_d  <= 	x"4000";
			when 48 => clk_reg_data_d  <= 	x"4123";
			when 49 => clk_reg_data_d  <= 	x"420F";
			when 50 => clk_reg_data_d  <= 	x"4300";
			when 51	=> clk_reg_data_d  <= 	x"4400";
			when 52 => clk_reg_data_d  <= 	x"4501";
			when 53 => clk_reg_data_d  <= 	x"4600";
			when 54 => clk_reg_data_d  <= 	x"4703";
			when 55 => clk_reg_data_d  <= 	x"5600";
			when 56 => clk_reg_data_d  <= 	x"5800";
			when 57 => clk_reg_data_d  <= 	x"59DE";
			when 58 => clk_reg_data_d  <= 	x"5A00";
			when 59 => clk_reg_data_d  <= 	x"5B00";
			when 60 => clk_reg_data_d  <= 	x"5C00";
			when 61 => clk_reg_data_d  <= 	x"5D00";
			when 62 => clk_reg_data_d  <= 	x"5E01";
			when 63 => clk_reg_data_d  <= 	x"5F86";
			when 64 => clk_reg_data_d  <= 	x"6000";
			when 65 => clk_reg_data_d  <= 	x"6100";
			when 66 => clk_reg_data_d  <= 	x"6200";
			when 67 => clk_reg_data_d  <= 	x"6300";
			when 68 => clk_reg_data_d  <= 	x"6400";
			when 69 => clk_reg_data_d  <= 	x"6500";
			when 70 => clk_reg_data_d  <= 	x"6600";
			when 71 => clk_reg_data_d  <= 	x"6700";
			when 72 => clk_reg_data_d  <= 	x"6800";
			when 73 => clk_reg_data_d  <= 	x"6900";
			when 74 => clk_reg_data_d  <= 	x"7500";
			when 75 => clk_reg_data_d  <= 	x"7607";
			when 76 => clk_reg_data_d  <= 	x"7705";
			when 77 => clk_reg_data_d  <= 	x"7800";
			when 78 => clk_reg_data_d  <= 	x"8910";
			when 79 => clk_reg_data_d  <= 	x"8B00";
			when 80 => clk_reg_data_d  <= 	x"8C00";
			when 81 => clk_reg_data_d  <= 	x"8EFF";
			when 82 => clk_reg_data_d  <= 	x"0C5F";
			when 83 => clk_reg_data_d  <= 	x"0CDF";
			when others	=>	clk_reg_data_d  <= 	x"0010";
		end case;	
	end if;
end process;	

--data_reg_index	<= 83 - to_integer(unsigned(reg_cnt_q));
--data_reg_index	<= to_integer(unsigned(reg_cnt_q));
data_reg_in		<=	'0' & "1010100" & '0' & '1' & clk_reg_data_q(15 downto 8) & '1' & clk_reg_data_q(7 downto 0) & '1';
scl_cnt_d		<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
i2c_clock		<=	scl_cnt_q(10);
wait_cnt_d		<=	std_logic_vector(unsigned(wait_cnt_q) + 1) when en_wait_cnt = '1' else
						wait_cnt_q;
bit_cnt_d		<=	(others => '0') when clr_bit_cnt = '0' else
						std_logic_vector(unsigned(bit_cnt_q) + 1) when en_bit_cnt = '1' else
						bit_cnt_q;
reg_cnt_d		<=	reg_cnt_q + 1 when en_reg_cnt = '1' else
						reg_cnt_q;
data_reg_d		<=	data_reg_in when ld_data_reg = '1' else
						data_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
						data_reg_q;
clk_done			<=	clk_done_q;
pgm_cnt_d		<=	std_logic_vector(unsigned(pgm_cnt_q) + 1) when en_pgm_cnt = '1' else pgm_cnt_q;
init_wait_cnt_d	<=	std_logic_vector(unsigned(init_wait_cnt_q) + 1) when init_wait_cnt_q /= x"fffff" else
							init_wait_cnt_q;
							
data_in_d		<=	data_in_q(25 downto 0)&sda when state = scl_high else
						data_in_q;
ack				<=	data_in_q(18)&data_in_q(9);						
process(clock,reset)
begin
	if(reset = '0') then
		scl_cnt_q	<=	(others => '0');
	elsif(rising_edge(clock)) then
		scl_cnt_q	<=	scl_cnt_d;
	end if;
end process;
process(i2c_clock,reset)
begin
	if(reset = '0') then
		wait_cnt_q	<=	(others => '0');
		bit_cnt_q	<=	(others => '0');
		reg_cnt_q	<=	0;
		data_reg_q	<=	(others => '0');
		pgm_cnt_q	<=	(others	=>	'0');		
		clk_done_q	<=	'0';
		scl_q			<=	'1';
		sda_q			<=	'1';
		init_config_q	<=	'0';
		init_wait_cnt_q	<=	(others	=>	'0');
		data_in_q			<=	(others	=>	'1');
		clk_reg_data_q	<=	(others	=>	'0');
	elsif(rising_edge(i2c_clock)) then
		wait_cnt_q	<=	wait_cnt_d;
		bit_cnt_q	<=	bit_cnt_d;
		reg_cnt_q	<=	reg_cnt_d;
		data_reg_q	<=	data_reg_d;
		pgm_cnt_q	<=	pgm_cnt_d;
		clk_done_q	<=	clk_done_d;
		scl_q			<=	scl_d;
		sda_q			<=	sda_d;
		init_config_q	<=	init_config;
		init_wait_cnt_q	<=	init_wait_cnt_d;
		data_in_q			<=	data_in_d;
		clk_reg_data_q	<=	clk_reg_data_d;
	end if;
end process;	
process(i2c_clock, reset)
begin
	if(reset = '0') then
		state	<=	init;
	elsif(rising_edge(i2c_clock)) then
		case state is
--			when init			=>	if init_config_q = '1' then state <= data_load;
--										else state <= init;
--										end if;	
			when init			=>	if init_wait_cnt_q = x"fffff" then state	<=	data_load;
										else state	<=	init;
										end if;
			when data_load		=>	state <= scl_high;			
			when scl_high		=>	state <= scl_low;
			when scl_low		=>	state <= bit_check;
			when bit_check		=>	if bit_cnt_q = "11011" then state <= reg_check;
										else state <= scl_high;
										end if;
			when reg_check		=>	if reg_cnt_q = 511 then state <= stat_done;
										else state <= stop_reg;
										end if;
			when stop_reg		=>	if wait_cnt_q = x"ff" then state <= data_load;
										else state <= stop_reg;
										end if;
--			when config_done	=>	if pgm_cnt_q =  "1111" then state	<=	stat_done;							
--										else state	<=	data_load;
--										end if;
			when stat_done		=>	state	<=	stat_done;							
--			when config_done	=>	if init_config = '1' then state <= data_load;
--										else state <= config_done;
--										end if;			
			when others			=>	state <= init;
		end case;
	end if;
end process;
en_wait_cnt			<=	'1' when state = stop_reg  else '0';
clr_bit_cnt			<=	'0' when state = reg_check else '1';
en_bit_cnt			<=	'1' when state = bit_check and bit_cnt_q /= "11011" else '0';
--en_reg_cnt			<=	'1' when state = reg_check and ack = "00" and reg_cnt_q /= 511 else '0';
en_reg_cnt			<=	'1' when state = reg_check and reg_cnt_q /= 511 else '0';
--clr_reg_cnt			<=	'0' when state = reg_check and reg_cnt_q = 511 else '1';
ld_data_reg			<=	'1' when state = data_load else '0';
sh_data_reg			<=	'1' when state = scl_low else '0';
scl					<=	'0' when state = scl_low or state = bit_check else '1';
sda_d					<=	'1' when state = init or state = data_load or state = stop_reg or state = config_done else
							'0' when state = reg_check else
							data_reg_q(27);
--scl					<=	'0' when scl_q = '0' else 'Z';
sda					<=	'0' when sda_d = '0' else 'Z';							
clk_done_d			<=	'1' when state = stat_done else '0';
en_pgm_cnt			<=	'1' when state = config_done and pgm_cnt_q /= "1111" else '0';	
end architecture behavior;				