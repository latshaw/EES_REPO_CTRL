LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;
use work.all;

ENTITY C10GXFACTORY IS 
	PORT
	(
		reset     : in  STD_LOGIC; -- switch 1, c10 reset
		m10_reset : in std_logic;  -- Let's us know if Max10 was reset
		
		-- SFP signals
		sfp_sda_0		:	inout std_logic;	-- I2C SFP configuartion (SDA, SFP3_SDA_0 PIN_AD14)
		sfp_scl_0		:	out std_logic;		-- I2C SFP configuartion (SCL, SFP3_SCL_0 PIN_AD15)	  
		sfp_refclk_p	:	in std_logic;		-- 125 MHz clock (SFP2_REFCLK0_P PIN_U22, SFP2_REFCLK0_N PIN_U21)  
		sfp_tx_0_p		:	out std_logic;		-- SFP+3_TX0_P PIN_AC26, SFP+3_TX0_N, PI	N_AC25
		sfp_rx_0_p		:	in std_logic;		-- SFP+3_RX0_P PIN_AB24, SFP+3_RX0_N, PIN_AB23
		
		SGMII1_TX_P		:	out std_logic;		-- SGMII TX, to marvel chip
		SGMII1_RX_P		:	in std_logic;		-- SGMII RX, to marvel chip
		ETH1_RESET_N   :  out std_logic;    -- SGMII active low reset
		eth_mdio       : out std_logic;
		eth_mdc        : out std_logic;
		
		--LED Interface (front panel)
		LED_SDA : inout std_logic;
		LED_SCL : out std_logic;
		
		
		hb_fpga    :  out  STD_LOGIC; -- FPGA heart beat LED
		gpio_led_1 :  out  STD_LOGIC; -- HEART_BEAT LED
		gpio_led_2 :  out std_logic;  -- heart beat ioc
		gpio_led_3 :  out std_logic	
	);
END C10GXFACTORY;

ARCHITECTURE bdf_type OF C10GXFACTORY IS 

--SFP Module
component udp_com is
port(	clock				: in std_logic;
		reset_n			: in std_logic;
		lb_clk			: out std_logic;
		sfp_sda_0		: inout std_logic;
		sfp_scl_0		: out std_logic;
		sfp_refclk_p	: in std_logic; 
		sfp_rx_0_p		: in std_logic;  
		sfp_tx_0_p		: out std_logic;
		lb_valid			: out std_logic;
		lb_rnw			: out std_logic;
		lb_addr			: out std_logic_vector(23 downto 0);
		lb_wdata			: out std_logic_vector(31 downto 0);
		lb_renable		: out std_logic;
		lb_rdata			: in std_logic_vector(31 downto 0); -- changed to in, 3/8/21
	   sfp_dataw		: in STD_LOGIC_VECTOR(31 downto 0);
		sfp_datar		: out STD_LOGIC_VECTOR(31 downto 0);
		sfp_ctrl   	   : in STD_LOGIC_VECTOR(31 downto 0);
		sfp_config_done0 : out std_logic
	);
end component;

-- 3/6/2024 , added for new marvel PHY
COMPONENT marvell_phy_config IS
	PORT (
			clock	      :	in std_logic;
			reset	      :	in std_logic;
			phy_resetn	:	out std_logic;
			mdio	      :	out std_logic;
			mdc		   :	out std_logic;
			config_done	:	out std_logic);
END COMPONENT;

--Cyclone, remote firmward download module (RFWD)
COMPONENT CYCLONE IS
	PORT (
			 lb_clk 		: IN STD_LOGIC;
			 reset_n    : IN STD_LOGIC;
			 c10_addr 	: IN STD_LOGIC_VECTOR(31 downto 0);
			 c10_data 	: IN STD_LOGIC_VECTOR(31 downto 0);
			 c10_cntlr 	: IN STD_LOGIC_VECTOR(31 downto 0);
			 c10_status : OUT STD_LOGIC_VECTOR(31 downto 0);
			 c10_datar  : OUT STD_LOGIC_VECTOR(31 downto 0);
			 ru_param   : IN STD_LOGIC_VECTOR(2 downto 0);
			 ru_data_in : IN STD_LOGIC_VECTOR(31 downto 0);
			 ru_ctrl    : IN STD_LOGIC_VECTOR(2 downto 0);
			 ru_data_out: OUT STD_LOGIC_VECTOR(31 downto 0);
			 we_cyclone_inst_c10_data : IN STD_LOGIC); 
END COMPONENT;
--
--
attribute noprune: boolean;
signal CLOCK, lb_valid, RESET_all, load 	: STD_LOGIC; 
signal lb_rnw 	: STD_LOGIC;
signal lb_addr	: STD_LOGIC_VECTOR(23 downto 0);
signal lb_wdata, lb_rdata, ru_data_out, ru_data_in :STD_LOGIC_VECTOR(31 downto 0);
signal ru_param, ru_ctrl : STD_LOGIC_VECTOR(2 downto 0); -- 3 bit

signal en_ru_param, en_ru_ctrl, en_ru_data_in : STD_LOGIC;

signal udp_blink  : STD_LOGIC;
signal c10_datar, c10_status, ADDR, DOUT, DIN : STD_LOGIC_VECTOR(31 downto 0);
signal en_c_addr  : StD_LOGIC;
signal en_c_cntl  : StD_LOGIC;   
signal en_c_data  : StD_LOGIC;
signal rate_chn, detune_chn  : reg32_array;
signal lb_addr_r, regbank_0, regbank_1, regbank_2, regbank_3, regbank_4, regbank_5, regbank_6, regbank_7 : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of lb_addr_r : signal is true;
attribute noprune of regbank_0 : signal is true;
attribute noprune of regbank_1 : signal is true;
attribute noprune of regbank_2 : signal is true;
attribute noprune of regbank_3 : signal is true;
attribute noprune of regbank_4 : signal is true;
attribute noprune of regbank_5 : signal is true;
attribute noprune of regbank_6 : signal is true;
attribute noprune of regbank_7 : signal is true;
--signal wf_4k_command, wf_4k_status : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL c_addr : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of c_addr : signal is true;
SIGNAL c_cntlr : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of c_cntlr : signal is true;
SIGNAL c_data : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of c_data : signal is true;
SIGNAL c_status : STD_LOGIC_VECTOR(31 downto 0); -- RO
attribute noprune of c_status : signal is true;
SIGNAL c_datar : STD_LOGIC_VECTOR(31 downto 0); -- RO
attribute noprune of c_datar : signal is true;
signal lb_strb : STD_LOGIC;
attribute noprune of lb_strb : signal is true;
--
attribute noprune of ru_ctrl : signal is true;
attribute noprune of ru_param : signal is true;
attribute noprune of ru_data_in : signal is true;
--
BEGIN 
-- ================================================================
-- General Notes
-- ================================================================
-- This module is being designed to be a light weight, factory image
-- for LLRF 3.0 projects. This image will have limited functionality
-- restricted to updating application image firmware (remotely) only.
--
RESET_all <= '0' when reset = '0' else '1'; -- active low reset from on chip pushbutton
--
--===================================================
-- Ethernet Communication Module from Berkeley (with test bench option)
--===================================================
--
inst_comms_top: udp_com
port map(clock				=>	sfp_refclk_p,  -- 100 MHz input clock, 3/9/21 changed from clock 
			reset_n			=>	RESET_all,	   -- active low reset
			lb_clk			=> CLOCK,			-- lb_clk 125 Mhz, from gtx0_tx_usr_clk/tx phy wrapper
			sfp_sda_0		=>	sfp_sda_0,
			sfp_scl_0		=>	sfp_scl_0,
			sfp_refclk_p	=>	sfp_refclk_p,
			sfp_rx_0_p		=>	SGMII1_RX_P,  -- sfp_rx_0_p
			sfp_tx_0_p		=>	SGMII1_TX_P,  -- sfp_tx_0_p
			lb_valid			=> lb_valid, -- 3/8/21, assume this goes HI whenever local bus data is stable
			lb_rnw			=> lb_rnw,   -- invert and connect to input load in regs
			lb_addr			=> lb_addr,  -- connect to input addr in regs (not all bits used)
			lb_wdata			=> lb_wdata, -- connect to input din in regs
			lb_renable		=> open,
			lb_rdata			=> lb_rdata,  -- connect to output dout in regs
			sfp_dataw	   => open,
			--sfp_datar	   =>  ,
			sfp_ctrl       => open   	
			--sfp_config_done0 =>  -- tca i2c expander chip is done
			);
	--
	load     <= NOT(lb_rnw);
	DIN      <= lb_wdata;
	lb_rdata <= DOUT;
	ADDR     <= x"00"&lb_addr;
	--
-- ================================================================
-- MARVEL PHY INIT
-- ================================================================ *********** will need to come back and fix look at PMOD for version control
-- 3/6/2024
marvell_phy_config_inst : marvell_phy_config
	PORT MAP(
			clock	      => clock,
			reset	      => RESET_all,
			phy_resetn	=> ETH1_RESET_N,
			mdio	      => eth_mdio,
			mdc		   => eth_mdc,
			config_done	=>  open);
--
-- ================================================================
-- Register Map
-- ================================================================
-- Example for xFF registers and waveforms available. 
-- I don't suppose these will be needed for the Factory/Golden image, but if you want it, it's there :)
--
	process (clock)
	begin
		if clock'event and clock = '1' then
			if lb_valid = '1' then
				lb_addr_r <= ADDR;
			end if;
		end if;
	end process;
	--
	process (clock)  -- ADDR(7 downto 6) is 00
	begin
		if clock'event and clock = '1' then
			if lb_valid = '1' then
			
				--==================================================================
				-- ADDR(7 downto 5) is 000
				--==================================================================
			
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_0 <= ru_data_out             ;--x"000"  example start address
					when "0" & x"1" => regbank_0 <= x"0000000" & "0" & ru_param                ;--x"001" 
					when "0" & x"2" => regbank_0 <= x"0000000" & "0" & ru_ctrl                 ;--x"002" 
					when "0" & x"3" => regbank_0 <= ru_data_in              ;--x"003" 
					when others =>     regbank_0 <= x"C001FACE"				  ;-- default case
				end case;
				
				--==================================================================
				-- ADDR(7 downto 5) is 001
				--==================================================================
				
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_1 <= x"00000000"             ;--x"020" next block example
					when "0" & x"A" => regbank_1 <= x"0000ABCD"             ;--x"02A"  
					when others =>     regbank_1 <= x"C001FACE"				  ;-- default case
				end case;

				--==================================================================
				-- ADDR(7 downto 5) is 010
				--==================================================================
				
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_2 <= x"00000000"            ; --x"040" ,
					when others =>     regbank_2 <= x"C001FACE" 				 ;-- default case
				end case;
				
				--==================================================================
				-- ADDR(7 downto 5) is 011
				--==================================================================
					
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_3 <= x"00000000"            ;--x"060",
					when others =>     regbank_3 <= x"C001FACE" 				 ;-- default case
				end case;

				--==================================================================
				-- ADDR(7 downto 5) is 100
				--==================================================================
  
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_4 <= x"00000000"               ;--x"080",
					when others =>      regbank_4 <= x"C001FACE" 				 ;-- default case
				end case;
					
				--==================================================================
				-- ADDR(7 downto 5) is 101
				--==================================================================

				case ADDR(4 downto 0) is					
					when "0" & x"0" => regbank_5 <= x"00000000"                ;--x"0A0"
					when others =>      regbank_5 <= x"C001FACE" 				 ;-- default case
				end case;
	
				--==================================================================
				-- ADDR(7 downto 5) is 110
				--==================================================================
				
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_6 <= x"00000000"            ;--x"0C0",
					when "1" & x"5" => regbank_6 <= c_addr					    ;--x"0D5", -- EPCQ address
					when "1" & x"6" => regbank_6 <= c_cntlr	  	          ;--x"0D6", -- control bits for read writing and configurting EPCQ
					when "1" & x"7" => regbank_6 <= c10_status				 ;--x"0D7", -- checksum and status		 
					when "1" & x"8" => regbank_6 <= c10_datar 				 ;--x"0D8", -- read data
					when "1" & x"9" => regbank_6 <= c_data					    ;--x"0D9", -- data to write
					when others =>      regbank_6 <= x"00000000" 		    ;-- default case
				end case;
			end if; -- end for strobe /lb_valid signal
			
			   --==================================================================
				-- ADDR(7 downto 5) is 111
				--==================================================================

				case ADDR(4 downto 0) is					
					when "0" & x"0" => regbank_7 <= x"00000000"                 ;--x"0E0",
					when others =>     regbank_7 <= x"C001FACE" 				      ;-- default case
				end case;
				
			--==================================================================
			-- Main MUX
			--==================================================================
			-- notice that we are using lb_addr_r which is a registered version of ADDR
			case lb_addr_r(16 downto 12) is
				-- case for wave form viewer, 11 downto 0 is the 4k address being read
				when "00001"     => dout <= x"00000000"; 
				--when "..."     => dout <= example_for_4k_waveform(II);
				--when "10000"   => dout <= example_for_4k_waveform(III);
				when others   => 
					-- others case for generic registers (not waveforms
					case lb_addr_r(7 downto 5) is
					when "000"   => dout <= regbank_0;
					when "001"   => dout <= regbank_1;
					when "010"   => dout <= regbank_2;
					when "011"   => dout <= regbank_3;
					when "100"   => dout <= regbank_4;
					when "101"   => dout <= regbank_5;
					when "110"   => dout <= regbank_6;
					when "111"   => dout <= regbank_7;
					when others  => dout <= x"00000000"; -- default if no valid options are selected.
					end case;				
			end case;
		end if; -- end for rising edge check
	end process;	
--
-- ================================================================
-- Remote Firmware Download Block
-- ================================================================
--
CYCLONE_inst : CYCLONE
	PORT MAP(
			 lb_clk 		=> CLOCK,
			 reset_n    => RESET_all,
			 c10_addr 	=> c_addr,
			 c10_data 	=> c_data,
			 c10_cntlr 	=> c_cntlr,
			 c10_status => c10_status,
			 c10_datar  => c10_datar,
			 ru_param   => ru_param, -- 3 bit
			 ru_data_in => ru_data_in, -- 32 bit
			 ru_ctrl    => ru_ctrl, -- 3 bit
			 ru_data_out=> ru_data_out,-- 32 bit
			 we_cyclone_inst_c10_data => lb_strb);
	-- fimrware update registers
	lb_strb <= lb_valid AND en_c_data;
	c_status <= c10_status;
	c_datar  <= c10_datar; 
	
	-- Enables for RWs for this firmware block ======================
	-- enables for RW registers 
	en_c_addr <= '1' when load = '1' and addr(11 downto 0) = x"0D5" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  c_addr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_addr='1') THEN 
		  c_addr<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_cntl <= '1' when load = '1' and addr(11 downto 0) = x"0D6" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  c_cntlr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_cntl='1') THEN 
		  c_cntlr<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_data <= '1' when load = '1' and addr(11 downto 0) = x"0D9" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  c_data<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_data='1') THEN 
		  c_data<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	-- remote update specific
	
	en_ru_param <= '1' when load = '1' and addr(11 downto 0) = x"001" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  ru_param<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_ru_param='1') THEN 
		  ru_param<=din(2 downto 0); -- 3 bit
	  END IF; 
	END PROCESS; 
	
	en_ru_ctrl <= '1' when load = '1' and addr(11 downto 0) = x"002" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  ru_ctrl<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_ru_ctrl='1') THEN 
		  ru_ctrl<=din(2 downto 0); -- 3 bit
	  END IF; 
	END PROCESS; 
	
	en_ru_data_in <= '1' when load = '1' and addr(11 downto 0) = x"003" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  ru_data_in<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_ru_data_in='1') THEN 
		  ru_data_in<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	
	
	
	
	
	
	
	-- END Enables for RWs for this firmware block ======================	
END bdf_type;