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
 
--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {marvell_phy_config} architecture {behavior}}
 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity marvell_phy_config is
port(clock	:	in std_logic;
	reset	:	in std_logic;
	en_mdc : in std_logic; -- during power on, set HI to enable mdc/mdio register config. Marvel reset happens in any case.
	phy_resetn	:	out std_logic;
	mdio	:	out std_logic;
	mdc		:	out std_logic;
	config_done	:	out std_logic
	);
end marvell_phy_config;
 
--}} End of automatically maintained section
 
architecture behavior of marvell_phy_config is
 
signal clk_div_q			: unsigned(7 downto 0);
signal clk_div_d			: unsigned(7 downto 0);
signal sclk					: std_logic;
signal en_reset_count		: std_logic;
signal reset_count_d		: unsigned(11 downto 0);
signal reset_count_q		: unsigned(11 downto 0);
signal clr_bit_count		: std_logic;
signal en_bit_count			: std_logic;
signal bit_count_q			: unsigned(6 downto 0);
signal bit_count_d			: unsigned(6 downto 0);
signal clr_addr_count		: std_logic;
signal en_addr_count		: std_logic;
signal addr_count_q			: unsigned(4 downto 0);
signal addr_count_d			: unsigned(4 downto 0);
signal data_in_phy_q		: std_logic_vector(64 downto 0);
signal data_in_phy_d		: std_logic_vector(64 downto 0);
signal data_in_phy_w		: std_logic_vector(64 downto 0);
signal ld_data_in_phy		: std_logic;
signal en_data_in_phy		: std_logic;
signal data_in_phy			: std_logic_vector(64 downto 0);
signal en_data_out_phy		: std_logic;
signal data_out_phy_q		: std_logic_vector(63 downto 0);
signal data_out_phy_d		: std_logic_vector(63 downto 0);
 
signal mdc_d					:	std_logic;
signal mdio_d, mdio_q		:	std_logic;
signal phy_resetn_d			:	std_logic;
 
 
type state_type is (init, load_data, enable_check, sclk_low, sclk_high, addr_check, phy_config_done);
signal state			: state_type;
 

signal mdioCatchCnt_q, mdioCatchCnt_d    : unsigned(11 downto 0);
signal en_mdioCatchCnt, en_mdc_q : std_logic;
 
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
--		mdc				<=	'0';
--		mdio_q			<=	'1';
		phy_resetn		<=	'0';	
		en_mdc_q       <= '0';
	elsif(rising_edge(sclk)) then
		bit_count_q		<= bit_count_d;
		addr_count_q	<= addr_count_d;
		reset_count_q	<= reset_count_d;
		data_in_phy_q	<= data_in_phy_d;
		data_out_phy_q	<= data_out_phy_d;		
--		mdc				<=	mdc_d;
--		mdio_q			<=	mdio_d;
		phy_resetn		<=	phy_resetn_d;
		mdioCatchCnt_q <= mdioCatchCnt_d;
		en_mdc_q       <= en_mdc;
	end if;
end process;	
 

-- during power up, different versions of the fpga have different pull up which may expereince brief transients
-- this coutner helps smooth out those transients. If coutner is on half the time, then pull up is likely present
mdioCatchCnt_d <= mdioCatchCnt_q + 1 when ((en_mdc_q = '1') and (state = init) and (mdioCatchCnt_q /= x"989")) else mdioCatchCnt_q;
 
addr_count_d	<= 	(others => '0') when clr_addr_count = '0' else
					addr_count_q + 1 when en_addr_count = '1' else
					addr_count_q;
bit_count_d		<= 	(others => '0') when clr_bit_count = '0' else
					bit_count_q + 1 when en_bit_count = '1' else
					bit_count_q;
reset_count_d	<=	reset_count_q + 1 when en_reset_count = '1' else
					reset_count_q;
--data_in_phy		<= 	"111111111111111111111111111111111" & "01" & "10" & "00000" & addr_count_q & "00" & "0000000000000000" when rw_q = '0' else
--					data_in_phy_w;
 
--reg22_w			<= x"0201";----page 18 register 20, set mode[2:0] to "001" ----SGMII to copper
--reg22_w			<=	x"8201";---reset the phy

data_in_phy		<=	"111111111111111111111111111111111" & "01" & "01" & "00000" & "10110" & "10" & x"0012" when addr_count_q = "00000" else-----reg 22 page 18
					"111111111111111111111111111111111" & "01" & "01" & "00000" & "10100" & "10" & x"0201" when addr_count_q = "00001" else
					"111111111111111111111111111111111" & "01" & "01" & "00000" & "10100" & "10" & x"8201";
					--"111111111111111111111111111111111" & "01" & "01" & "00000" & "10110" & "10" & x"0000" when addr_count_q = "00011" else-----reg 22 page 0
					--"111111111111111111111111111111111" & "01" & "01" & "00000" & "00000" & "10" & x"0140" when addr_count_q = "00100" else-----reg 0 page 0
					--"111111111111111111111111111111111" & "01" & "01" & "00000" & "00000" & "10" & x"8140";



--					"111111111111111111111111111111111" & "01" & "01" & "00000" & "10110" & "10" & x"0002" when addr_count_q = "00011" else-----page 18
--					"111111111111111111111111111111111" & "01" & "01" & "00000" & "10101" & "10" & x"1226" when addr_count_q = "00100" else
--					"111111111111111111111111111111111" & "01" & "01" & "00000" & "10110" & "10" & x"0000" when addr_count_q = "00101" else-----page 18
--					"111111111111111111111111111111111" & "01" & "01" & "00000" & "00000" & "10" & x"1541";




data_in_phy_d	<= 	data_in_phy when ld_data_in_phy = '1' else
					data_in_phy_q(63 downto 0) & '0' when en_data_in_phy = '1' else
					data_in_phy_q;

 
	
 
 
					
process(reset,sclk)
begin
	if(reset = '0') then
		state <= init;
	elsif (rising_edge(sclk)) then
		case state is
			when init		=> 	if reset_count_q = x"989" then  -- Hold in reset for 10 ms
											state	<= enable_check;       -- x"989" after  10 ms
								      else 
											state <= init;
								      end if;
			when enable_check => if mdioCatchCnt_q >= x"4C4" then  -- Check to see if en_mdc is set.
											state <= load_data;            -- If HI, proceed with mdc/mdio register config. 
										else 
											state	<=	phy_config_done;      -- Else skip to done
										end if;
			when load_data	=>	state <= sclk_low;
			when sclk_low	=> 	state <= sclk_high;
			when sclk_high	=>	if bit_count_q = "1000000" then 
										state <= addr_check;
									else 
										state <= sclk_low;
									end if;
			when addr_check	=>	if addr_count_q = "00010" then 
											state <= phy_config_done;
										else 
											state <= load_data;
										end if;
			when phy_config_done	=>	state	<=	phy_config_done;

			when others		=> state <= init;
		end case;
	end if;
end process;
 
--enet_mdc		<= 	'1' when state = init or state = load_data or state = addr_check or state = rd_done else sclk;
mdc		<= 	'0' when state = sclk_low else '1';
 
 
	
 
--mdio		<=	'0' when data_in_phy_q(64) = '0' and (state = sclk_low or state = sclk_high) else 'Z';					
 
mdio		<=	data_in_phy_q(64);
--mdio			<=	'0' when data_in_phy_q(64) = '0' else 'Z';					
phy_resetn_d	<=	'0' when state = init else '1';	
 
clr_bit_count	<=	'0' when state = load_data else '1';
en_bit_count	<=	'1' when state = sclk_high else '0';
 
clr_addr_count	<= '0' when state = phy_config_done else '1';
en_addr_count	<=	'1' when state = addr_check and addr_count_q /= "00010" else '0';
 
	
en_reset_count	<=	'1' when state = init and reset_count_q /= x"989"else '0';
 
ld_data_in_phy	<=	'1' when state = load_data else '0';
en_data_in_phy	<=	'1' when state = sclk_high else '0';

 
	
en_data_out_phy	<=	'1' when state = sclk_high else '0';
config_done		<=	'1' when state = phy_config_done else '0';	
 
 
	 -- enter your statements here --
 
end behavior;