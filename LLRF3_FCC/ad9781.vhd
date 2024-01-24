library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ad9781 is
port(clock		:	in std_logic;
		reset		:	in std_logic;
		
		spi_init	:	in	std_logic;
		sdo		:	in	std_logic;
		nCS		:	out std_logic;
		sclk		:	out std_logic;		
		sdio		:	out std_logic;		
		spi_done	:	out std_logic
		);
end entity ad9781;
architecture behavior of ad9781 is

type reg16_21 is array(20 downto 0) of std_logic_vector(15 downto 0);
signal dac_spi_data		:	reg16_21;
signal reg_count_d		:	std_logic_vector(4 downto 0);	
signal reg_count_q		:	std_logic_vector(4 downto 0);	
signal en_reg_count		:	std_logic;

signal bit_count_d		:	std_logic_vector(3 downto 0);
signal bit_count_q		:	std_logic_vector(3 downto 0);
signal clr_bit_count		:	std_logic;
signal en_bit_count		:	std_logic;

signal spi_data_reg_d	:	std_logic_vector(15 downto 0);
signal spi_data_reg_q	:	std_logic_vector(15 downto 0);
signal ld_spi_data_reg	:	std_logic;
signal sh_spi_data_reg	:	std_logic;

signal wait_count_q		:	std_logic_vector(8 downto 0);
signal wait_count_d		:	std_logic_vector(8 downto 0);
signal en_wait_count	:	std_logic;

signal sclk_d			:	std_logic;
signal sclk_q			:	std_logic;
signal cs_d				:	std_logic;
signal cs_q				:	std_logic;

signal sdio_d			:	std_logic;
signal sdio_q			:	std_logic;

signal spi_init_d		:	std_logic_vector(1 downto 0);
signal spi_init_q		:	std_logic_vector(1 downto 0);
signal spi_init_go_d	:	std_logic;
signal spi_init_go_q	:	std_logic;

signal spi_done_d		:	std_logic;
signal spi_done_q		:	std_logic;

signal spi_data_in_d	:	std_logic_vector(15 downto 0); 
signal spi_data_in_q	:	std_logic_vector(15 downto 0);
type state_type is (init, cs_high, load_data, cs_low, sclk_high, sclk_low, check_bit, check_reg, config_done);
signal state			:	state_type;
begin
	
reg_count_d		<=	std_logic_vector(unsigned(reg_count_q) + 1) when en_reg_count = '1' else
						reg_count_q;
bit_count_d		<=	std_logic_vector(unsigned(bit_count_q) + 1) when en_bit_count = '1' else	
						bit_count_q;
wait_count_d	<=	std_logic_vector(unsigned(wait_count_q) + 1) when en_wait_count = '1' else
						wait_count_q;					
spi_data_reg_d	<=	spi_data_in_d when ld_spi_data_reg = '1' else
						spi_data_reg_q(14 downto 0) & '0' when sh_spi_data_reg = '1' else
						spi_data_reg_q;
spi_data_in_d	<=	dac_spi_data(to_integer(unsigned(reg_count_q)));

spi_init_d(0)	<=	spi_init;
spi_init_d(1)	<=	spi_init_q(0);

spi_init_go_d		<=	not spi_init_q(1) and spi_init_q(0);
sdio_d				<=	spi_data_reg_q(15);


nCS					<=	cs_q;
sclk					<=	sclk_q;
sdio					<=	sdio_q;
spi_done				<=	spi_done_q;

dac_spi_data(0)		<=	'0' & "00" & "00000" & x"00";--x0
dac_spi_data(1)		<=	'0' & "00" & "00010" & x"00";--x2
dac_spi_data(2)		<=	'0' & "00" & "00011" & x"00";--x3
dac_spi_data(3)		<=	'0' & "00" & "00100" & x"00";--x4
dac_spi_data(4)		<=	'0' & "00" & "00101" & x"00";--x5
dac_spi_data(5)		<=	'0' & "00" & "00110" & x"00";--x6
dac_spi_data(6)		<=	'0' & "00" & "00000" & x"00";--xa
dac_spi_data(7)		<=	'0' & "00" & "01011" & x"f9";--xb
dac_spi_data(8)		<=	'0' & "00" & "01100" & x"01";--0xc
dac_spi_data(9)		<=	'0' & "00" & "01101" & x"00";--0xd
dac_spi_data(10)		<=	'0' & "00" & "01110" & x"00";--0xe
dac_spi_data(11)		<=	'0' & "00" & "01111" & x"f9";--0xf
dac_spi_data(12)		<=	'0' & "00" & "10000" & x"01";--0x10
dac_spi_data(13)		<=	'0' & "00" & "10001" & x"00";--0x11
dac_spi_data(14)		<=	'0' & "00" & "10010" & x"00";--0x12
dac_spi_data(15)		<=	'0' & "00" & "11010" & x"00";--0x1a
dac_spi_data(16)		<=	'0' & "00" & "11011" & x"00";--0x1b
dac_spi_data(17)		<=	'0' & "00" & "11100" & x"00";--0x1c
dac_spi_data(18)		<=	'0' & "00" & "11101" & x"00";--0x1d
dac_spi_data(19)		<=	'0' & "00" & "11110" & x"00";--0x1e
dac_spi_data(20)		<=	'0' & "00" & "11111" & x"01";--0x1f

process(clock, reset)
begin
	if(reset = '0') then
		reg_count_q		<=	(others	=> '0');
		bit_count_q		<=	(others	=> '0');
		spi_data_reg_q	<=	(others	=> '0');
		spi_data_in_q	<=	(others	=> '0');
		wait_count_q	<=	(others	=> '0');
		sclk_q			<=	'0';
		cs_q			<=	'0';
		spi_init_go_q	<=	'0';
		spi_init_q		<=	(others => '0');
		sdio_q			<=	'0';
		spi_done_q		<=	'0';
	elsif(rising_edge(clock)) then
		reg_count_q		<=	reg_count_d;
		bit_count_q		<=	bit_count_d;
		spi_data_reg_q	<=	spi_data_reg_d;
		spi_data_in_q	<=	spi_data_in_d;
		wait_count_q	<=	wait_count_d;
		sclk_q			<=	sclk_d;
		cs_q			<=	cs_d;
		spi_init_go_q	<=	spi_init_go_d;
		spi_init_q		<=	spi_init_d;
		sdio_q			<=	sdio_d;
		spi_done_q		<=	spi_done_d;
	end if;
end process;

process(clock, reset)
begin
	if(reset = '0') then
		state	<=	init;
	elsif(rising_edge(clock)) then
		case state is
			when init			=>	if spi_init_go_q = '1' then state <= cs_high;
										else state <= init;
										end if;
			when cs_high		=>	if wait_count_q = "111111111" then state <= load_data;
										else state <= cs_high;
										end if;
			when load_data		=>	state <= cs_low;
			when cs_low			=>	if wait_count_q = "111111111" then state <= sclk_high;
										else state <= cs_low;
										end if;
			when sclk_high		=>	if wait_count_q = "011111111" then state <= sclk_low;
										else state <= sclk_high;
										end if;
			when sclk_low		=>	if wait_count_q = "111111111" then state <= check_bit;
										else state <= sclk_low;
										end if;
			when check_bit		=>	if bit_count_q = "1111" then state <= check_reg;
										else state <= sclk_high;
										end if;
			when check_reg		=>	if reg_count_q = "10100" then state <= config_done;
										else state <= cs_high;
										end if;
			when config_done	=>	state <= config_done;
			when others			=>	state <= init;
		end case;
	end if;
end process;	

en_wait_count			<=	'1' when state = cs_high or state = cs_low or state = sclk_high or state = sclk_low else '0';
en_bit_count			<=	'1' when state = check_bit else '0';
--clr_bit_count			<=	'0' when state = check_reg else '1';	
en_reg_count			<=	'1' when state = check_reg and reg_count_q /= "10100" else '0';
ld_spi_data_reg		<=	'1' when state = load_data else '0';
sh_spi_data_reg		<=	'1' when state = sclk_low and wait_count_q = "100000000" else '0';
sclk_d					<=	'1' when state = sclk_high else '0';
cs_d						<=	'0' when state = cs_low or state = sclk_high or state = sclk_low or state = check_bit else '1';
spi_done_d				<=	'1' when state = config_done else '0';


	
end architecture behavior;		
		