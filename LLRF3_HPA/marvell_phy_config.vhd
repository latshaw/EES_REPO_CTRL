-------------------------------------------------------------------------------
--
-- Title       : marvell_phy_config
-- Design      : shift_by_m
-- Author      : bachimanchi
-- Company     : Jlab
--
-------------------------------------------------------------------------------
--
-- File        : F:\Bachiman_FDrive\My_Designs\Separator_backup\shift_by_m\src\marvell_phy_config.vhd
-- Generated   : Mon Mar  4 09:40:02 2024
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------
 -- 4/2/2025 added functionality to read back the ID register to determine the model number. 
 -- PHY chip 88E1512, model number 011101, DOES NOT COME UP IN GIGABIT, NEED TO CONFIGURE
 -- PHY chip 88E1111, model number 001100, automatically comes up in GIGABIT (NO NEED TO CONFIGURE)
 
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity marvell_phy_config is
port(clock	:	in std_logic;
	reset	:	in std_logic;
	en_mdc : in std_logic; -- during power on, set HI to enable mdc/mdio register config. Marvel reset happens in any case.
	phy_resetn	:	out std_logic;
	mdio	:	inout std_logic;
	mdc		:	out std_logic;
	config_done	:	out std_logic
	);
end marvell_phy_config;

 
architecture behavior of marvell_phy_config is
 
signal clk_div_q			: unsigned(7 downto 0);
signal clk_div_d			: unsigned(7 downto 0);
signal sclk					: std_logic;
signal en_reset_count		: std_logic;
signal reset_count_d		: unsigned(15 downto 0);
signal reset_count_q		: unsigned(15 downto 0);
signal clr_bit_count		: std_logic;
signal en_bit_count			: std_logic;
signal bit_count_q			: unsigned(6 downto 0);
signal bit_count_d			: unsigned(6 downto 0);
signal clr_addr_count		: std_logic;
signal en_addr_count		: std_logic;
signal addr_count_q			: unsigned(4 downto 0);
signal addr_count_d			 : unsigned(4 downto 0);
signal data_in_phy_q		        : std_logic_vector(72 downto 0);
signal data_in_phy_d		   	  : std_logic_vector(72 downto 0);
signal data_hi_z                : std_logic_vector(72 downto 0);
signal data_hi_z_d, data_hi_z_q : std_logic_vector(72 downto 0);
signal data_in_phy_read_q		  : std_logic_vector(72 downto 0);
signal data_in_phy_read_d		  : std_logic_vector(72 downto 0);
signal data_in_phy_w		        : std_logic_vector(72 downto 0);
signal ld_data_in_phy		: std_logic;
signal en_data_in_phy		: std_logic;
signal data_in_phy			: std_logic_vector(72 downto 0);
signal en_data_out_phy		: std_logic;
signal data_out_phy_q		: std_logic_vector(71 downto 0);
signal data_out_phy_d		: std_logic_vector(71 downto 0);
 
signal mdc_d					:	std_logic;
signal mdio_d, mdio_q		:	std_logic;
signal phy_resetn_d			:	std_logic;

signal Data_read_d, Data_read_q : std_logic_vector(15 downto 0);
signal device_id_d, device_id_q : std_logic_vector(15 downto 0);
 
type state_type is (init, load_data, enable_check, sclk_low, sclk_high, addr_check, phy_config_done);
signal state			: state_type;
 

signal mdioCatchCnt_q, mdioCatchCnt_d    : unsigned(11 downto 0);
signal en_mdioCatchCnt, en_mdc_q : std_logic;
 
 
 
attribute noprune: boolean;
attribute noprune of data_in_phy_read_q : signal is true;
attribute noprune of device_id_q : signal is true;
attribute keep: boolean;
attribute keep of data_hi_z_q : signal is true;
attribute keep of data_in_phy_q : signal is true;

begin

clk_div_d	<= clk_div_q + 1;	
sclk		<= clk_div_q(7);-------only for testing change it to (7) for actual implementation
 
process(reset,clock)
begin
	if (reset = '0') then
		clk_div_q	<= (others => '0');
	elsif(rising_edge(clock)) then
		clk_div_q	<= clk_div_d;
	end if;
end process;
process(reset,sclk)
begin
	if(reset = '0') then
		bit_count_q		<= (others => '0');
		addr_count_q	<= (others => '0');
		reset_count_q	<= (others => '0');
		data_in_phy_q	<= (others => '0');
		data_out_phy_q	<= (others => '0');
		mdioCatchCnt_q <= (others => '0');
		data_hi_z_q    <= (others => '0');
		phy_resetn		<=	'0';	
		en_mdc_q       <= '0';
		Data_read_q    <= (others => '0');
		data_in_phy_read_q <= (others => '0');
		device_id_q  <= (others => '0');
	elsif(rising_edge(sclk)) then
		bit_count_q		<= bit_count_d;
		addr_count_q	<= addr_count_d;
		reset_count_q	<= reset_count_d;
		data_in_phy_q	<= data_in_phy_d;
		data_out_phy_q	<= data_out_phy_d;		
		data_hi_z_q    <= data_hi_z_d;
		phy_resetn		<=	phy_resetn_d;
		mdioCatchCnt_q <= mdioCatchCnt_d;
		en_mdc_q       <= en_mdc;
		data_in_phy_read_q <= data_in_phy_read_d;
		Data_read_q    <= Data_read_d;
		device_id_q    <= device_id_d;
	end if;
end process;	
 
 
--reg22_w			<= x"0201";----page 18 register 20, set mode[2:0] to "001" ----SGMII to copper
--reg22_w			<=	x"8201";---reset the phy

-- only need to specify read registers, all others are NO HI Z
data_hi_z 		<=	"0" & x"00000000" & "00" & "00" & "00000" & "00000" & "10" & x"FFFF" & x"00"            when addr_count_q = "00001" else -- read reg 3 page 0
						"0" & x"00000000" & "00" & "00" & "00000" & "00000" & "10" & x"FFFF" & x"00"            when addr_count_q = "00010" else -- read reg 3 page 0
					   "0" & x"00000000" & "00" & "00" & "00000" & "00000" & "00" & x"0000" & x"00";  -- all other addresses (non-reads)


data_in_phy		<=	"1" & x"FFFFFFFF" & "01" & "01" & "00000" & "10110" & "Z0" & x"0000" & x"FF"            when addr_count_q = "00000" else-----reg 22, go to page 0
						"1" & x"FFFFFFFF" & "01" & "10" & "00000" & "00010" & "Z0" & "ZZZZZZZZZZZZZZZZ" & x"FF" when addr_count_q = "00001" else -- read reg 3 page 0
						"1" & x"FFFFFFFF" & "01" & "10" & "00000" & "00011" & "Z0" & "ZZZZZZZZZZZZZZZZ" & x"FF" when addr_count_q = "00010" else -- read reg 3 page 0
						"1" & x"FFFFFFFF" & "01" & "01" & "00000" & "10110" & "10" & x"0012" & x"FF"            when addr_count_q = "00011" else-----reg 22 go to page 18
					   "1" & x"FFFFFFFF" & "01" & "01" & "00000" & "10100" & "10" & x"0201" & x"FF"            when addr_count_q = "00100" else-----reg 20, write x0201
					   "1" & x"FFFFFFFF" & "01" & "01" & "00000" & "10100" & "10" & x"8201" & x"FF";                                           -----reg 20, write x8201

			
process(reset,sclk)
begin
	if(reset = '0') then
		state <= init;
	elsif (rising_edge(sclk)) then
		case state is
			when init		=> 	if reset_count_q = x"FFFF" then  -- Hold in reset for 10 ms (we overshoot so we can work for a range of clocks)
											state	<= enable_check;       
								      else 
											state <= init;
								      end if;
			when enable_check => state <= load_data;
			when load_data	=>	   state <= sclk_low;
			when sclk_low	=> 	state <= sclk_high;
			when sclk_high	=>	if bit_count_q = "1001000" then -- "1000000" then changed from 64 to 72
										state <= addr_check;
									else 
										state <= sclk_low;
									end if;
			when addr_check	=>	 if (addr_count_q = "00010") and (device_id_d(9 downto 4) /= "011101") then -- read ID register
											-- see note at top of file for which marvel PHY goes with which device ID
											-- note, we are just making sure that the PHY is NOT the 88E1512. If we are NOT 88E1512, then no
											-- need to configure the chip (just skip to done state).
											state <= phy_config_done;
										elsif addr_count_q = "00101" then 
											state <= phy_config_done;
										else 
											state <= load_data;
										end if;
			when phy_config_done	=>	state	<=	phy_config_done;

			when others		=> state <= init;
		end case;
	end if;
end process;
 
mdc		<= '0' when state = sclk_low      else '1';
mdio		<=	'Z' when data_hi_z_q(72) = '1' else data_in_phy_q(72);
					
phy_resetn_d	   <=	'0' when state = init else '1';	
clr_bit_count	   <=	'0' when state = load_data else '1';
en_bit_count	   <=	'1' when state = sclk_high else '0';
clr_addr_count	   <= '0' when state = phy_config_done else '1';
en_addr_count	   <=	'1' when state = addr_check and addr_count_q /= "00101" else '0';
en_reset_count	   <=	'1' when state = init and reset_count_q /= x"FFFF"else '0';
ld_data_in_phy	   <=	'1' when state = load_data else '0';
en_data_in_phy	   <=	'1' when state = sclk_high else '0';
en_data_out_phy	<=	'1' when state = sclk_high else '0';
config_done		   <=	'1' when state = phy_config_done else '0';	
 
 -- during power up, different versions of the fpga have different pull up which may expereince brief transients
-- this coutner helps smooth out those transients. If coutner is on half the time, then pull up is likely present
mdioCatchCnt_d <= mdioCatchCnt_q + 1 when ((en_mdc_q = '1') and (state = init) and (mdioCatchCnt_q /= x"0FF")) else mdioCatchCnt_q;
 
addr_count_d	<= 	(others => '0') when clr_addr_count = '0' else
					addr_count_q + 1      when en_addr_count = '1'  else
					addr_count_q;
bit_count_d		<= 	(others => '0') when clr_bit_count = '0' else
					bit_count_q + 1       when en_bit_count = '1'  else
					bit_count_q;
reset_count_d	<=	reset_count_q + 1 when en_reset_count = '1' else reset_count_q;
data_in_phy_d	<= 	data_in_phy                      when ld_data_in_phy = '1' else
							data_in_phy_q(71 downto 0) & '0' when en_data_in_phy = '1' else
							data_in_phy_q;
data_hi_z_d	   <= 	data_hi_z                    when ld_data_in_phy = '1' else
							data_hi_z(71 downto 0) & '0' when en_data_in_phy = '1' else
							data_hi_z;
data_in_phy_read_d <= data_in_phy_read_q(71 downto 0) & mdio when state = sclk_low else data_in_phy_read_q; -- sample on falling edge
--
Data_read_d <=	Data_read_q(14 downto 0) & mdio when (state = sclk_low) else Data_read_q;
device_id_d <= Data_read_q when (bit_count_q = x"40") and (addr_count_q = "00010") and (state = sclk_high) else device_id_q;


--
end behavior;