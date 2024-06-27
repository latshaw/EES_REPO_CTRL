-- LLRF 3.0
-- James Latshaw, 11/20/2020
-- Intelrocks Control Top Level

-- Initally generated from quaturs 13.1 build files (see below)
-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"
-- CREATED		"Thu Nov 19 11:12:46 2020"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;


ENTITY interlocks_control IS 
	PORT
	(
		clock_100 :  IN  STD_LOGIC; -- 100 MHz (may need to change to 80 MHz with PLL), c10_CLKUSR
		RESET :  IN  STD_LOGIC;		-- switch 1, c10 reset
		m10_reset : in std_logic;  -- Let's us know if Max10 was reset
		
		--FPGA board LEDs
		LED0 :  OUT  STD_LOGIC; -- FPGA heart beat LED
		LED1 :  OUT  STD_LOGIC; -- HEART_BEAT LED
		LED2 :  OUT  STD_LOGIC; -- Heart beat ioc
		LED3 :  OUT  STD_LOGIC;
	
		TST_SW : IN STD_LOGIC; -- test switch 3
		
		-- SFP signals
		sfp_sda_0		:	inout std_logic;	-- I2C SFP configuartion (SDA, SFP3_SDA_0 PIN_AD14)
		sfp_scl_0		:	out std_logic;		-- I2C SFP configuartion (SCL, SFP3_SCL_0 PIN_AD15)	  
		sfp_refclk_p	:	in std_logic;		-- 125 MHz clock (SFP2_REFCLK0_P PIN_U22, SFP2_REFCLK0_N PIN_U21)  
		sfp_tx_0_p		:	out std_logic;		-- SFP+3_TX0_P PIN_AC26, SFP+3_TX0_N, PI	N_AC25
		sfp_rx_0_p		:	in std_logic;		-- SFP+3_RX0_P PIN_AB24, SFP+3_RX0_N, PIN_AB23
		
		SGMII1_RX_P    : in std_logic;
		SGMII1_TX_P    : out  std_logic;
		ETH1_RESET_N   : out std_logic;
		eth_mdio       : out std_logic;
		eth_mdc        : out std_logic;
		
		fpga_ver				: in std_logic_vector(5 downto 0); -- c10 pmod 2 for REv - and later, misc connectors with some pulls ups for older versions
		jtag_mux_sel_out   :	out std_logic; -- JTAG mux select '0' - C10 and M10, '1' for M10 only
		
		-- Legacy isa info, no longer needed, keep this until we wire up the new udp module
--		ISA_RESET_FPGA :  IN  STD_LOGIC;
--		ISA_MEMW_FPGA :  IN  STD_LOGIC;
--		ISA_MEMR_FPGA :  IN  STD_LOGIC;
--		ISA_SMEMW_FPGA :  IN  STD_LOGIC;
--		ISA_SMEMR_FPGA :  IN  STD_LOGIC;
--		ISA_AEN_FPGA :  IN  STD_LOGIC;
--		ISA_SBHE_FPGA :  IN  STD_LOGIC;
--		ISA_BALE_FPGA :  IN  STD_LOGIC;
--		ISA_MEMCS16_FPGA :  OUT  STD_LOGIC;
--		ISA_SD_DIR :  OUT  STD_LOGIC;
--		ISA_SA :  IN  STD_LOGIC_VECTOR(19 DOWNTO 0);
--		ISA_SD :  INOUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		
		-- Fast Shutdown Fiber Input Signals (Rx inputs)		
		FSD_CAV1_FPGA :  IN  STD_LOGIC;
		FSD_CAV2_FPGA :  IN  STD_LOGIC;
		FSD_CAV3_FPGA :  IN  STD_LOGIC;
		FSD_CAV4_FPGA :  IN  STD_LOGIC;
		FSD_CAV5_FPGA :  IN  STD_LOGIC;
		FSD_CAV6_FPGA :  IN  STD_LOGIC;
		FSD_CAV7_FPGA :  IN  STD_LOGIC;
		FSD_CAV8_FPGA :  IN  STD_LOGIC;
		
		-- Fast Shutdown Fiber Output Signals (Tx outputs)		
		FLT_CAV1_FPGA :  OUT  STD_LOGIC;
		FLT_CAV2_FPGA :  OUT  STD_LOGIC;
		FLT_CAV3_FPGA :  OUT  STD_LOGIC;
		FLT_CAV4_FPGA :  OUT  STD_LOGIC;
		FLT_CAV5_FPGA :  OUT  STD_LOGIC;
		FLT_CAV6_FPGA :  OUT  STD_LOGIC;
		FLT_CAV7_FPGA :  OUT  STD_LOGIC;
		FLT_CAV8_FPGA :  OUT  STD_LOGIC;
		FSD_MAIN_FPGA :  OUT  STD_LOGIC;
		
		-- Vacuum Input Siganls						
		VAC_CAV1_FPGA :  IN  STD_LOGIC;
		VAC_CAV2_FPGA :  IN  STD_LOGIC;
		VAC_CAV3_FPGA :  IN  STD_LOGIC;
		VAC_CAV4_FPGA :  IN  STD_LOGIC;
		VAC_CAV5_FPGA :  IN  STD_LOGIC;
		VAC_CAV6_FPGA :  IN  STD_LOGIC;
		VAC_CAV7_FPGA :  IN  STD_LOGIC;
		VAC_CAV8_FPGA :  IN  STD_LOGIC;
		VAC_BMLN_FPGA :  IN  STD_LOGIC;
		
		-- IR ADC Signals						 NOTE RENAMED signals to reflect additional chips
		-- each of the 4 IR adc samples 4 channels, 16 total channels
		TMP_CS_n_1 : OUT  STD_LOGIC;
		TMP_SDI_1  : OUT  STD_LOGIC;
		TMP_SDO_1  : IN   STD_LOGIC;
		TMP_SCLK_1 : OUT  STD_LOGIC;
		TMP_CS_n_2 : OUT  STD_LOGIC;
		TMP_SDI_2  : OUT  STD_LOGIC;
		TMP_SDO_2  : IN   STD_LOGIC;
		TMP_SCLK_2 : OUT  STD_LOGIC;
		TMP_CS_n_3 : OUT  STD_LOGIC;
		TMP_SDI_3  : OUT  STD_LOGIC;
		TMP_SDO_3  : IN   STD_LOGIC;
		TMP_SCLK_3 : OUT  STD_LOGIC;
		TMP_CS_n_4 : OUT  STD_LOGIC;
		TMP_SDI_4  : OUT  STD_LOGIC;
		TMP_SDO_4  : IN   STD_LOGIC;
		TMP_SCLK_4 : OUT  STD_LOGIC;	
--		TMP_ADC_CS :  OUT  STD_LOGIC;
--		TMP_ADC_SDI :  OUT  STD_LOGIC;
--		TMPCLD_ADC_SDO :  IN  STD_LOGIC;
--		TMPWRM_ADC_SDO :  IN  STD_LOGIC;
--		TMP_ADC_CLK :  OUT  STD_LOGIC;
			
		-- IR Test Outputs from FPGA					
		-- Cold Side
		TMPCLDTST1_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST2_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST3_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST4_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST5_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST6_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST7_FPGA :  OUT  STD_LOGIC;
		TMPCLDTST8_FPGA :  OUT  STD_LOGIC;
		-- Warm Side
		TMPWRMTST1_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST2_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST3_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST4_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST5_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST6_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST7_FPGA :  OUT  STD_LOGIC;
		TMPWRMTST8_FPGA :  OUT  STD_LOGIC;
		
		--ARC ADC Signals						NOTE SIGNAL RENAMES
		-- each of the 4 adcs samples 2 channgles (A and B), total 8 channels
		ARC_CS_n_1	: OUT STD_LOGIC;
		ARC_SCLK_1	: OUT STD_LOGIC;
		ARC_SDO_A_1	: IN  STD_LOGIC;
		ARC_SDO_B_1	: IN  STD_LOGIC;
		ARC_SDI_1	: OUT STD_LOGIC;
		ARC_CS_n_2	: OUT STD_LOGIC;
		ARC_SCLK_2	: OUT STD_LOGIC;
		ARC_SDO_A_2	: IN  STD_LOGIC;
		ARC_SDO_B_2	: IN  STD_LOGIC;
		ARC_SDI_2	: OUT STD_LOGIC;
		ARC_CS_n_3	: OUT STD_LOGIC;
		ARC_SCLK_3	: OUT STD_LOGIC;
		ARC_SDO_A_3	: IN  STD_LOGIC;
		ARC_SDO_B_3	: IN  STD_LOGIC;
		ARC_SDI_3	: OUT STD_LOGIC;
		ARC_CS_n_4	: OUT STD_LOGIC;
		ARC_SCLK_4	: OUT STD_LOGIC;
		ARC_SDO_A_4	: IN  STD_LOGIC;
		ARC_SDO_B_4	: IN  STD_LOGIC;
		ARC_SDI_4	: OUT STD_LOGIC;	
--		ARC_ADC_BSY :  IN  STD_LOGIC;
--		ARC_ADC_CNVST :  OUT  STD_LOGIC;
--		ARC_ADC_CS :  OUT  STD_LOGIC;
--		ARC_ADC_ADDR :  OUT  STD_LOGIC;
--		ARC_ADC1_DOUTA :  IN  STD_LOGIC;
--		ARC_ADC1_DOUTB :  IN  STD_LOGIC;
--		ARC_ADC2_DOUTA :  IN  STD_LOGIC;
--		ARC_ADC2_DOUTB :  IN  STD_LOGIC;	
--		ARC_ADC_SCLK :  OUT  STD_LOGIC;
		
		-- ARC Test Outputs from FPGA				ADDED TO PINOUT :)
		ARCTST1_FPGA :  OUT  STD_LOGIC;
		ARCTST2_FPGA :  OUT  STD_LOGIC;
		ARCTST3_FPGA :  OUT  STD_LOGIC;
		ARCTST4_FPGA :  OUT  STD_LOGIC;
		ARCTST5_FPGA :  OUT  STD_LOGIC;
		ARCTST6_FPGA :  OUT  STD_LOGIC;
		ARCTST7_FPGA :  OUT  STD_LOGIC;
		ARCTST8_FPGA :  OUT  STD_LOGIC;
		
		--LED output power (LOW leaves IPT on, HI turns IPT off)
		IPT_SHDN		: OUT 	STD_LOGIC;
		
		-- I2C LED
		LED_SDA :  INOUT  STD_LOGIC;
		LED_SCL :  OUT  STD_LOGIC;
		
		PWR_EN_5V	 : OUT STD_LOGIC; 
		PWR_SYNC_5V	 : OUT STD_LOGIC;
		PWR_EN_33V	 : OUT STD_LOGIC;
		PWR_SYNC_33V : OUT STD_LOGIC
		
--		--temperature sensor info (new board does not have a temperature sensor)
--		TMPBRD_SI :  IN  STD_LOGIC;
--		TMPBRD_SCK :  OUT  STD_LOGIC;
--		TMPBRD_CS :  OUT  STD_LOGIC;
--		
--		-- Uart signals, not needed
--		RS232_RX :  IN  STD_LOGIC;
--		RS232_TX :  OUT  STD_LOGIC;
--		JMPR :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
--		LED :  OUT  STD_LOGIC; -- extra, not needed?
--		
--		-- dac signals, no longer needed. just the IPT shutdown signal
--		ARC_DAC_SYNC :  OUT  STD_LOGIC;
--		ARC_DAC_SCLK :  OUT  STD_LOGIC;
--		ARC_DAC_DIN :  OUT  STD_LOGIC
	);
END interlocks_control;

ARCHITECTURE bdf_type OF interlocks_control IS 

--SFP Module, updated 3/31/2021 to include local bus clock
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
		sfp_config_done0 : out STD_LOGIC
	);
end component;

-- removed
--COMPONENT lm74 
--	PORT(CLOCK : IN STD_LOGIC;
--		 RESET : IN STD_LOGIC;
--		 GO : IN STD_LOGIC;
--		 SI : IN STD_LOGIC;
--		 CS : OUT STD_LOGIC;
--		 SC : OUT STD_LOGIC;
--		 DATA_OUT : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
--	);
--END COMPONENT;

COMPONENT ad7367_control
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 ARC_ADC_BSY : IN STD_LOGIC;
		 ARC_ADC1_DOUTA : IN STD_LOGIC;
		 ARC_ADC1_DOUTB : IN STD_LOGIC;
		 ARC_ADC2_DOUTA : IN STD_LOGIC;
		 ARC_ADC2_DOUTB : IN STD_LOGIC;
		 ARC_BUF_ADDR_IN : IN STD_LOGIC_VECTOR(15 DOWNTO 1);
		 ARC_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_STOP : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_TRIG_DELAY : IN REG16_ARRAY;
		 ARC_ADC_CNVST : OUT STD_LOGIC;
		 ARC_ADC_CS : OUT STD_LOGIC;
		 ARC_ADC_SCLK : OUT STD_LOGIC;
		 ARC_ADC_ADDR : OUT STD_LOGIC;
		 ARC_BUF_ADDR : OUT REG11_ARRAY;
		 ARC_BUF_EN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_BUFF_READY : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_DATA : OUT REG16_ARRAY
	);
END COMPONENT;

COMPONENT heartbeat_fp
	PORT(clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 isa_oe : IN STD_LOGIC;
		 hb_dig : OUT STD_LOGIC;
		 hb_ioc : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT heartbeat_isa
	PORT(clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 LED : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT vac_fault_status
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 VAC_BMLN_FPGA : IN STD_LOGIC;
		 MASK_VAC_FAULT : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 VAC_FAULT_CLEAR : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 VAC_WAVGD_FPGA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 VAC_FAULT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 VAC_STATUS : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)
	);
END COMPONENT;

COMPONENT lpm_counter0
	PORT(clock : IN STD_LOGIC;
		 q : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END COMPONENT;

COMPONENT regs
	PORT(HB_ISA : IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 ADDR : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 ARC_BUFF_DATA : REG16_ARRAY;
		 --ARC_BUFF_READY : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_DATA : IN REG16_ARRAY;
		 ARC_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DIG_TEMP : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		 DIN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 FC_FSD_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 FIRST_CAVITY_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 MAIN_FSD_FAULT_STATUS : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 TMPCLD_DATA : IN REG16_ARRAY;
		 TMPCLD_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 TMPWRM_DATA : IN REG16_ARRAY;
		 TMPWRM_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 VAC_FAULT_STATUS : IN STD_LOGIC_VECTOR(17 DOWNTO 0);
		 REG_RESET : OUT STD_LOGIC;
		 ARC_FLT_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_LIMIT : OUT REG16_ARRAY;
		 ARC_PWR : OUT REG16_ARRAY;
		 ARC_STOP : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_TIMER : OUT REG16_ARRAY;
		 ARC_TRIG_DELAY : OUT REG16_ARRAY;
		 ARC_TST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_TST_FLT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 CAV_FLT_FPGA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 DOUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 FC_FSD_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 FC_FSD_MASK : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_CLR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 INTEN_MASK : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 MASK_ARC_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 MASK_TMP_FAULT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 MASK_VAC_FAULT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 TMPCLD_FLT_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_LIMIT : OUT REG16_ARRAY;
		 TMPCLD_TST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_FLT_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_LIMIT : OUT REG16_ARRAY;
		 TMPWRM_TST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 VAC_FLT_CLR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 ready_arc	 : IN STD_LOGIC_VECTOR(7 downto 0);
		 arc_adc_busy : IN STD_LOGIC_VECTOR(7 downto 0);
		 HELIUM_INTERLOCK_LED : OUT STD_LOGIC;
		 lb_valid		: IN STD_LOGIC
--		 out_c_addr		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_cntlr	    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_status        : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_data		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_datar	       : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_en_c_data	    : OUT std_logic
	);
END COMPONENT;



COMPONENT ARC_COMPARE IS
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 ARC_DATA : IN REG16_ARRAY; -- arc input data (channel specific)
		 ARC_LIMIT : IN REG16_ARRAY; -- specify arc limit (fault if over this limit, channel specific)
		 ARC_TIMER : IN REG16_ARRAY; -- number of continous ticks before issuing an arc fault (channel specific)
		 MASK_ARC_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- not used
		 ARC_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- set hi to clear that channels fault (channel specific)
		 ARC_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- latch an arc fault has existed for the specified interval (channel specific)
		 ARC_STATUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) -- unfiltered value of fault check (channel specific)
		 );
END COMPONENT;

--COMPONENT interlock_lcd
--	PORT(clk_0 : IN STD_LOGIC;
--		 reset_n : IN STD_LOGIC;
--		 rxd_to_the_uart_0 : IN STD_LOGIC;
--		 in_port_to_the_ARC_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 in_port_to_the_COLD_WINDOW_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 in_port_to_the_FC_FSD : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 in_port_to_the_INTERLOCK_ENABLE : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 in_port_to_the_WARM_WINDOW_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 in_port_to_the_WAVEGUIDE_VAC_FAULT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
--		 txd_from_the_uart_0 : OUT STD_LOGIC
--	);
--END COMPONENT;

COMPONENT ad7328_control
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 TMPCLD_ADC_SDO : IN STD_LOGIC;
		 TMPWRM_ADC_SDO : IN STD_LOGIC;
		 TMP_ADC_SDI : OUT STD_LOGIC;
		 TMP_ADC_CLK : OUT STD_LOGIC;
		 TMP_ADC_CS : OUT STD_LOGIC;
		 TMPCLD_DATA : OUT REG16_ARRAY;
		 TMPCLD_FLTR_EN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_DATA : OUT REG16_ARRAY;
		 TMPWRM_FLTR_EN : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

--COMPONENT isa_bus
--	PORT(RESET : IN STD_LOGIC;
--		 CLOCK : IN STD_LOGIC;
--		 ISA_BALE : IN STD_LOGIC;
--		 ISA_AEN : IN STD_LOGIC;
--		 ISA_MEMR : IN STD_LOGIC;
--		 ISA_MEMW : IN STD_LOGIC;
--		 ISA_SMEMR : IN STD_LOGIC;
--		 ISA_SMEMW : IN STD_LOGIC;
--		 ISA_SBHE : IN STD_LOGIC;
--		 ISA_SA : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
--		 ISA_SD : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
--		 REGS_D : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
--		 ISA_SD_DIR : OUT STD_LOGIC;
--		 ISA_CS16 : OUT STD_LOGIC;
--		 REGS_LD : OUT STD_LOGIC;
--		 ADDR_OUT : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
--	);
--END COMPONENT;

COMPONENT inten_fc_fsd
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 FIVE_MHZ : IN STD_LOGIC;
		 ARC_TST_FLT : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 CAV_FLT_FPGA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 FC_FSD_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 FC_FSD_MASK : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_CLEAR : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 INTEN_FPGA : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_MASK : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 FSD_MAIN : OUT STD_LOGIC;
		 FC_FSD_FAULT_STATUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 FC_FSD_FPGA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 FIRST_CAVITY_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_FAULT_STATUS : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 MAIN_FSD_FAULT_STATUS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT dac8568_control
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 DATA : IN REG16_ARRAY;
		 SCLK : OUT STD_LOGIC;
		 DIN : OUT STD_LOGIC;
		 SYNC : OUT STD_LOGIC
	);
END COMPONENT;

COMPONENT ir_iir
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 LOAD_CLD : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 LOAD_WRM : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_DATA : IN REG16_ARRAY;
		 TMPWRM_DATA : IN REG16_ARRAY;
		 TMPCLD_FLTR : OUT REG16_ARRAY;
		 TMPWRM_FLTR : OUT REG16_ARRAY
	);
END COMPONENT;

COMPONENT tmp_compare
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 MASK_TMP_FAULT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 TMPCLD_DATA : IN REG16_ARRAY;
		 TMPCLD_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_LIMIT : IN REG16_ARRAY;
		 TMPWRM_DATA : IN REG16_ARRAY;
		 TMPWRM_FAULT_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_LIMIT : IN REG16_ARRAY;
		 TMPCLD_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_STATUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_STATUS : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;

-- added 12/3/2020
COMPONENT ADS8353
	PORT (
		clk		    : in  std_logic; -- 100 MHz CLOCK (fixed)
		reset_n	    : in  std_logic;
		ADC_CSn		 : out std_logic;
		ADC_SCK      : out std_logic;
		ADC_SDI      : out std_logic; -- 12.5 MHz (fixed)
		ADC_SDO_A    : in  std_logic;
		ADC_SDO_B    : in  std_logic;
		reg_a			 : out std_logic_vector(15 downto 0);
		reg_b			 : out std_logic_vector(15 downto 0);
		ready_a	    : out std_logic;
		ready_b		 : out std_logic -- will go hi when data is loaded into registers
		);
END COMPONENT;

COMPONENT ads8353_arc
	port(clock : in std_logic;
		 nreset : in std_logic;
	
		 sdo_a : in std_logic;
		 sdo_b : in std_logic;
		 
		 ncs : out std_logic;
		 sclk : out std_logic;
		 sdi : out std_logic;
		 
		 busy : out std_logic; -- adc is busy, JAL
		 
		 data_cha : out std_logic_vector(15 downto 0);
		 data_chb : out std_logic_vector(15 downto 0)
		 );
END COMPONENT;

-- added 12/11/2020
COMPONENT ADS8684
	PORT (
		clk		    : in  std_logic; -- 100 MHz Clock (fixed)
		reset_n	    : in  std_logic;
		ADC_CSn		 : out std_logic;
		ADC_SCK      : out std_logic;
		ADC_SDI      : out std_logic; -- 12.5 MHz (fixed), max 17 MHz
		ADC_SDO      : in  std_logic;
		reg_a			 : out std_logic_vector(15 downto 0);
		reg_b			 : out std_logic_vector(15 downto 0);
		reg_c			 : out std_logic_vector(15 downto 0);
		reg_d			 : out std_logic_vector(15 downto 0);
		ready_a	    : out std_logic;
		ready_b	    : out std_logic;
		ready_c	    : out std_logic;
		ready_d	    : out std_logic -- will go hi when data is loaded into registers.
		);
END COMPONENT;

-- PLL to convert 125 Mhz to 5Mhz, 3/31/21
component PLL_125_to_5 is
	port (
		rst      : in  std_logic := 'X'; -- reset
		refclk   : in  std_logic := 'X'; -- clk
		locked   : out std_logic;        -- export
		outclk_0 : out std_logic         -- clk
	);
end component PLL_125_to_5;

-- LED 16 bit IO expander
component LED_CONTROL IS
	generic (testBench : STD_LOGIC := '0'); 
	PORT
	(	
		clock      : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n    : IN  	STD_LOGIC; -- active low reset
		LED_TOP	  : IN  	STD_LOGIC_VECTOR(7 downto 0); -- upper LED on front panel
		LED_BOTTOM : IN  	STD_LOGIC_VECTOR(7 downto 0); -- lower LED on front panel
		SCL 		  : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
		SDA 		  : INOUT STD_LOGIC -- data line (data is bi directional), LED_SDA
	);
END component;

--epics level reset control
COMPONENT RESETS IS
	PORT(CLOCK : IN STD_LOGIC;
		 BRD_RESET : IN STD_LOGIC;
		 ISA_RESET_FPGA : IN STD_LOGIC;
		 REG_RESET : IN STD_LOGIC;
		 RESET : OUT STD_LOGIC
		);
END COMPONENT;

--cyclone temp sensor (inside FPGA)
component fpga_tsd_int is
	port (
		corectl : in  std_logic                    := 'X'; -- corectl
		reset   : in  std_logic                    := 'X'; -- reset
		tempout : out std_logic_vector(9 downto 0);        -- tempout
		eoc     : out std_logic                            -- eoc
	);
end component fpga_tsd_int;	

--verilog component
-- used for remote flash and reconfigure
COMPONENT CYCLONE IS
	PORT (
			 lb_clk 		: IN STD_LOGIC;
			 c10_addr 	: IN STD_LOGIC_VECTOR(31 downto 0);
			 c10_data 	: IN STD_LOGIC_VECTOR(31 downto 0);
			 c10_cntlr 	: IN STD_LOGIC_VECTOR(31 downto 0);
			 c10_status : OUT STD_LOGIC_VECTOR(31 downto 0);
			 c10_datar  : OUT STD_LOGIC_VECTOR(31 downto 0);
			 we_cyclone_inst_c10_data : IN STD_LOGIC); 
END COMPONENT;
--
-- 3/6/2024 , added for new marvel PHY
COMPONENT marvell_phy_config IS
	PORT (
			clock	      :	in std_logic;
			reset	      :	in std_logic;
			en_mdc      :  in std_logic;
			phy_resetn	:	out std_logic;
			mdio	      :	out std_logic;
			mdc		   :	out std_logic;
			config_done	:	out std_logic);
END COMPONENT;

--
signal c10gx_tmp, c10gx_tmp_buffer	, tempb1, tempb2	:	std_logic_vector(9 downto 0);
signal temp_eoc1, temp_eoc2, temp_eoc3 : STD_LOGIC;
-- internal temperature sensore end of fetching the temp. (falling edge)
SIGNAL fpga_tsd_int_EOC_n : STD_LOGIC;
signal en_mdc_mdio : STD_LOGIC;
signal sfp_config_done0 : STD_LOGIC;
SIGNAL	A :  STD_LOGIC_VECTOR(19 DOWNTO 0);
SIGNAL	ARC :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	at :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	CLD :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	ct :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	FC_FSD :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	flt :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	fsd :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	INTEN :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	q :  STD_LOGIC;
SIGNAL	VAC :  STD_LOGIC_VECTOR(17 DOWNTO 0);
SIGNAL	VAC_WAVGD :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	WRM :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	wt :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	ARC_FAULT_CLEAR :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	ARC_STOP :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	ARC_TRIG_DELAY :  REG16_ARRAY;
SIGNAL	udp_hb :  STD_LOGIC;
SIGNAL	MASK_VAC_FAULT :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	VAC_FAULT_CLEAR :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	HB_ISA :  STD_LOGIC;
SIGNAL	lb_rnw_n :  STD_LOGIC; -- inverted rnw
SIGNAL	ARC_BUFF_READY :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	ARC_DATA :  REG16_ARRAY;
SIGNAL	FIRST_CAVITY_FAULT :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	MAIN_FSD_FAULT_STATUS :  STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL	TMPCLD_DATA :  REG16_ARRAY;
SIGNAL	TMPWRM_DATA :  REG16_ARRAY;
SIGNAL	ARC_LIMIT :  REG16_ARRAY;
SIGNAL	ARC_TIMER :  REG16_ARRAY;
SIGNAL	ARC_STOP1 :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	CAV_FLT_FPGA :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	FC_FSD_CLEAR :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	FC_FSD_MASK :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	INTEN_CLEAR :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	INTEN_MASK :  STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL	ARC_PWR :  REG16_ARRAY;
SIGNAL	ARC_STOP8 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	ARC_STOP9 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	ARC_TRIG_DELAY0 :  REG16_ARRAY;
SIGNAL	ARC_TRIG_DELAY1 :  REG16_ARRAY;
SIGNAL	MASK_TMP_FAULT :  STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL	TMPCLD_FAULT_CLEAR :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	TMPCLD_LIMIT :  REG16_ARRAY;
SIGNAL	TMPWRM_FAULT_CLEAR :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	TMPWRM_LIMIT :  REG16_ARRAY;

SIGNAL udp_reset : STD_LOGIC; -- JAL, 5/17/22, help with SFP debug.

--ARC ADC busy indicator (2 channels per bit)
-- ADC_BUSY(0) is for ARC channels 0,1
-- ADC_BUSY(1) is for ARC channels 2,3
-- ADC_BUSY(2) is for ARC channels 4,5
-- ADC_BUSY(3) is for ARC channels 6,7
SIGNAL ADC_BUSY 	: STD_LOGIC_VECTOR(3 downto 0);
SIGNAL ADC_BUSY_8 	: STD_LOGIC_VECTOR(7 downto 0);

-- UDP Signals
SIGNAL lb_rnw	 	: STD_LOGIC;
SIGNAL lb_addr		: STD_LOGIC_VECTOR(23 downto 0);
SIGNAL lb_wdata	: STD_LOGIC_VECTOR(31 downto 0);
SIGNAL lb_rdata	: STD_LOGIC_VECTOR(31 downto 0);

-- 125 Mhz local bus clock (main system clock)
SIGNAL CLOCK : STD_LOGIC;
SIGNAL clk_5, clk_5_locked : STD_LOGIC;

-- arc adc ready signal 
SIGNAL ready_arc  : STD_LOGIC_VECTOR(7 downto 0);

-- I2C LED signals
SIGNAL LED_TOP, LED_BOTTOM : STD_LOGIC_VECTOR(7 downto 0);

-- heart beat buffer signals
signal hb_dig, hb_ioc : STD_LOGIC;
 
-- old signals, delete these 
--SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
--SIGNAL	ARC_STOP0 :  STD_LOGIC_VECTOR(7 DOWNTO 0);
--SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(12 DOWNTO 0);

signal HELIUM_INTERLOCK_LED : STD_LOGIC;
signal REG_RESET, RESET_all_n : STD_LOGIC;
--signal c10gx_tmp					:	std_logic_vector(9 downto 0); -- temp sensor
--
-- Cylone remote configuration/update signals (from regs module to inst_cyclone)
SIGNAL c_addr		: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c_cntlr		: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c10_status : std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c_data		: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c10_datar	: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL en_c_data	: std_logic; -- note, this is intended to capture the enable strobe when the c_data signal is written by the udp_com module
SIGNAL lb_valid   : STD_LOGIC;
--
BEGIN 

-- ================================================================
-- MARVEL PHY INIT
-- ================================================================
-- 3/6/2024

en_mdc_mdio <= '0' when fpga_ver(3)= '1' else '1'; -- note, a jumper connecting PMOD2 C10 pin 4 to GND (pin 5 or 11) is needed

marvell_phy_config_inst : marvell_phy_config
	PORT MAP(
			clock	      => clock_100,
			reset	      => RESET_all_n,
			en_mdc      => en_mdc_mdio,
			phy_resetn	=> ETH1_RESET_N,
			mdio	      => eth_mdio,
			mdc		   => eth_mdc,
			config_done	=>  LED3);



-- ================================================================
-- Reset Control
-- ================================================================
reset_control: RESETS
PORT MAP(CLOCK 			=> CLOCK,			-- local bus clock (125 MHz
			BRD_RESET 		=> RESET,			-- board level reset
			ISA_RESET_FPGA => '0', 				-- N/C
			REG_RESET 		=> '0',  	      -- reset from control register / epics, REG_RESET from reg module removed. JAL 6/21/22
			RESET 			=> RESET_all_n);	-- reset to reset all modules, active low


-- ================================================================
-- Heart Beats
-- ================================================================
b2v_inst10 : heartbeat_fp
PORT MAP(clock => CLOCK,
		 reset => RESET_all_n,
		 isa_oe => udp_hb, -- allow udp hb to pulse 
		 hb_dig => hb_dig,
		 hb_ioc => hb_ioc); -- will only pulse when epics ioc read/writes a new address
		 
		 LED0 <= hb_dig;
		 LED1 <= hb_ioc;

b2v_inst17 : heartbeat_isa -- this module seems redundant
PORT MAP(clock => CLOCK,
		 reset => RESET_all_n,
		 LED => HB_ISA);
		 
b2v_inst2 : heartbeat_isa
PORT MAP(clock => CLOCK,
		 reset => RESET_all_n,
		 LED => LED2);
		 
-- loop back sfp config done bit to LED3
--LED3 <= sfp_config_done0;
		 
--HB_HB : heartbeat_fp
--PORT MAP(clock, RESET_all_n, udp_hb);

 
-- simple process to watch for address change and strobe the udp_hb signal
process (clock, RESET_all_n)
	variable counter      : UNSIGNED(31 downto 0) := x"00000000";
	variable last_address : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
begin
	if (RESET_all_n = '0') then
		counter   := x"00000000";
		udp_hb <= '0';
	elsif clock'event and clock = '1' then
		-- watch for when the address changes
		if   (last_address /= lb_addr(23 downto 0)) then
			-- reset counter and signal the HB_HB module to 'blink' the udp com heartbeat
			counter := x"00000000";
			udp_hb <= '1';
		elsif (counter < x"0000000F") then
			-- keep the pulse hi for the duration of the counter (min 2 clock cycles)
			counter := counter + 1;
			udp_hb <= '1';
		else
			-- keep udp blink indicator off until the next address change
			counter := x"0000000F";
			udp_hb <= '0';
		end if;
		-- update last address
		last_address := lb_addr(23 downto 0);
		--
	end if;
end process;
		 
-- ================================================================
-- ADC
-- ================================================================

--IR ADC
--		 b2v_inst4 : ad7328_control
--PORT MAP(CLOCK => CLOCK,
--		 RESET => RESET,
--		 TMPCLD_ADC_SDO => TMPCLD_ADC_SDO,
--		 TMPWRM_ADC_SDO => TMPWRM_ADC_SDO,
--		 TMP_ADC_SDI => TMP_ADC_SDI,
--		 TMP_ADC_CLK => TMP_ADC_CLK,
--		 TMP_ADC_CS => TMP_ADC_CS,
--		 TMPCLD_DATA => ARC_TRIG_DELAY0,
--		 TMPCLD_FLTR_EN => ARC_STOP8,
--		 TMPWRM_DATA => ARC_TRIG_DELAY1,
--		 TMPWRM_FLTR_EN => ARC_STOP9);

--		IR Data
-- 	These adc data words need to be run through IRR. use ready_x for f_sample pulse
--		TMPCLD_DATA adn TMPWRM_DATA will be oututs from the IRR, not this module...
--
-- NOTICE: for the IR channels only, the silkscreen on the board does not match
-- 			the label on the rear panel. As of 4/27/2021, below is what 
--
--				silkscreen label		rear chassis label
-- 			IR 1-2					wrm/cld 3&4
--				IR 3-4					wrm/cld 1&2
--				IR 5-6					wrm/cld 7&8
--				IR 7-8					wrm/cld 5&6
--
-- original pinout that matches silcscreen. keep for reference
-- IR_A/B_1 = TMPWRM1 IR_A/B_6 = TMPWRM4 IR_A/B_9  = TMPWRM5 IR_A/B_9  = TMPWRM5
-- IR_A/B_4 = TMPWRM3 IR_A/B_7 = TMPWRM2 IR_A/B_12 = TMPWRM7 IR_A/B_12 = TMPWRM7
-- IR_A/B_2 = TMPCLD3 IR_A/B_5 = TMPCLD2 IR_A/B_10 = TMPCLD7 IR_A/B_10 = TMPCLD7
-- IR_A/B_3 = TMPCLD1 IR_A/B_8 = TMPCLD4 IR_A/B_11 = TMPCLD5 IR_A/B_11 = TMPCLD5
-- on 4/27/21, I went through and update the output register of the adc modules
-- to be what matches the rear panel. I left the silcscreen labels. Please note
-- the above table as a reference to what the actual values should be.

		IR_ADC_1 : ADS8684 
		PORT MAP (
		clk	 	=>  CLOCK,
		reset_n	=>  RESET_all_n,
		ADC_CSn	=>  TMP_CS_n_1,
		ADC_SCK	=>  TMP_SCLK_1,
		ADC_SDI	=>  TMP_SDI_1,
		ADC_SDO	=>  TMP_SDO_1,
		reg_a		=>  TMPCLD_DATA(2), --
		reg_b		=>  TMPWRM_DATA(2), --
		reg_c		=>  TMPWRM_DATA(0), --
		reg_d		=>  TMPCLD_DATA(0), --
		ready_a	=>  open,
		ready_b	=>  open,
		ready_c	=>  open,
		ready_d	=>  open
		);
		
		
		IR_ADC_2 : ADS8684 
		PORT MAP (
		clk	 	=>  CLOCK,
		reset_n	=>  RESET_all_n,
		ADC_CSn	=>  TMP_CS_n_2,
		ADC_SCK	=>  TMP_SCLK_2,
		ADC_SDI	=>  TMP_SDI_2,
		ADC_SDO	=>  TMP_SDO_2,
		reg_a		=>  TMPCLD_DATA(1), --
		reg_b		=>  TMPWRM_DATA(1), --
		reg_c		=>  TMPWRM_DATA(3), --
		reg_d		=>  TMPCLD_DATA(3), --
		ready_a	=>  open,
		ready_b	=>  open,
		ready_c	=>  open,
		ready_d	=>  open
		);
		
		IR_ADC_3 : ADS8684 
		PORT MAP (
		clk	 	=>  CLOCK,
		reset_n	=>  RESET_all_n,
		ADC_CSn	=>  TMP_CS_n_3,
		ADC_SCK	=>  TMP_SCLK_3,
		ADC_SDI	=>  TMP_SDI_3,
		ADC_SDO	=>  TMP_SDO_3,
		reg_a		=>  TMPCLD_DATA(6), -- 
		reg_b		=>  TMPWRM_DATA(6), --
		reg_c		=>  TMPWRM_DATA(4), --
		reg_d		=>  TMPCLD_DATA(4), --
		ready_a	=>  open,
		ready_b	=>  open,
		ready_c	=>  open,
		ready_d	=>  open
		);
		
		IR_ADC_4 : ADS8684 
		PORT MAP (
		clk	 	=>  CLOCK,
		reset_n	=>  RESET_all_n,
		ADC_CSn	=>  TMP_CS_n_4,
		ADC_SCK	=>  TMP_SCLK_4,
		ADC_SDI	=>  TMP_SDI_4,
		ADC_SDO	=>  TMP_SDO_4,
		reg_a		=>  TMPCLD_DATA(5), 
		reg_b		=>  TMPWRM_DATA(5), 
		reg_c		=>  TMPWRM_DATA(7), 
		reg_d		=>  TMPCLD_DATA(7), 
		ready_a	=>  open,
		ready_b	=>  open,
		ready_c	=>  open,
		ready_d	=>  open
		);
		
		
--		 -- ARC ADC
--		 b2v_inst1 : ad7367_control
--PORT MAP(CLOCK => CLOCK,
--		 RESET => RESET,
--		 ARC_ADC_BSY => ARC_ADC_BSY,
--		 ARC_ADC1_DOUTA => ARC_ADC1_DOUTA,
--		 ARC_ADC1_DOUTB => ARC_ADC1_DOUTB,
--		 ARC_ADC2_DOUTA => ARC_ADC2_DOUTA,
--		 ARC_ADC2_DOUTB => ARC_ADC2_DOUTB,
--		 ARC_BUF_ADDR_IN => A(15 DOWNTO 1),
--		 ARC_FAULT => ARC(15 DOWNTO 8),
--		 ARC_FAULT_CLEAR => ARC_FAULT_CLEAR,
--		 ARC_STOP => ARC_STOP,
--		 ARC_TRIG_DELAY => ARC_TRIG_DELAY,
--		 ARC_ADC_CNVST => ARC_ADC_CNVST,
--		 ARC_ADC_CS => ARC_ADC_CS,
--		 ARC_ADC_SCLK => ARC_ADC_SCLK,
--		 ARC_ADC_ADDR => ARC_ADC_ADDR,
--		 ARC_BUFF_READY => ARC_BUFF_READY,
--		 ARC_DATA => ARC_DATA); -- output form adc (chanel specific)
		 
-- 	ARC DATA
-- 	need to pass ready pulse into regs to assist in saving the arc records (arc buffer data).
-- 	These ready_x signals are different then the arc buffer data ready signals
		 -- 
		 -- ARC labeling corrections: 6/24/21
		 -- schematic			PV
		 -- J4 top, ARC 1 	ARC 3
		 -- J4 top, ARC 2 	ARC 4
		 -- J4 bot, ARC 3		ARC 1
		 -- J4 bot, ARC 4		ARC 2
		 --
		 -- J5 top, ARC 5		ARC 7
		 -- J5 top, ARC 6		ARC 8
		 -- J5 bot, ARC 7		ARC 5
		 -- J5 bot, ARC 8		ARC 6
		 
		 
		 -- note: SPI signals reflect board level names.
		 -- reg_a/reg_b signasl reflect epcis PV names
		 
		 
--		ARC_ADC_1 : ADS8353
--		PORT MAP (
--		clk   =>     CLOCK,   
--		reset_n =>   RESET_all_n, 
--		ADC_CSn =>   ARC_CS_n_1,	
--		ADC_SCK =>   ARC_SCLK_1,
--		ADC_SDI =>   ARC_SDI_1,
--		ADC_SDO_A => ARC_SDO_A_1,
--		ADC_SDO_B => ARC_SDO_B_1,
--		reg_a =>     ARC_DATA(2), -- ARC_A_3 on schematic (J4-B: pin, Pos/Neg - 13/12)
--		reg_b	=>     ARC_DATA(3), -- ARC_A_4 on schematic (J4-B: pin, Pos/Neg - 21/20)
--		ready_a =>   ready_arc(2),
--		ready_b =>   ready_arc(3)); 
		
	ARC_ADC_1 : ads8353_arc
	port MAP(
		 clock    => CLOCK,
		 nreset   => RESET_all_n,
		 sdo_a 	 => ARC_SDO_A_1,
		 sdo_b 	 => ARC_SDO_B_1,
		 ncs 		 => ARC_CS_n_1,
		 sclk 	 => ARC_SCLK_1,
		 sdi 		 => ARC_SDI_1,
		 busy		 => ADC_BUSY(1),
		 data_cha => ARC_DATA(2),
		 data_chb => ARC_DATA(3)
		 );
		
--		ARC_ADC_2 : ADS8353
--		PORT MAP (
--		clk   =>     CLOCK,   
--		reset_n =>   RESET_all_n, 
--		ADC_CSn =>   ARC_CS_n_2,	
--		ADC_SCK =>   ARC_SCLK_2,
--		ADC_SDI =>   ARC_SDI_2,
--		ADC_SDO_A => ARC_SDO_A_2,
--		ADC_SDO_B => ARC_SDO_B_2,
--		reg_a =>     ARC_DATA(0),  -- ARC_A_1 on schematic (J4-A: pin, Pos/Neg - 13/12)
--		reg_b	=>     ARC_DATA(1),  -- ARC_A_2 on schematic (J4-A: pin, Pos/Neg - 21/20)
--		ready_a =>   ready_arc(0),
--		ready_b =>   ready_arc(1)); 
		
	ARC_ADC_2 : ads8353_arc
	port MAP(
		 clock    => CLOCK,
		 nreset   => RESET_all_n,
		 sdo_a 	 => ARC_SDO_A_2,
		 sdo_b 	 => ARC_SDO_B_2,
		 ncs 		 => ARC_CS_n_2,
		 sclk 	 => ARC_SCLK_2,
		 sdi 		 => ARC_SDI_2,
		 busy		 => ADC_BUSY(0),
		 data_cha => ARC_DATA(0),
		 data_chb => ARC_DATA(1)
		 );
		
--		ARC_ADC_3 : ADS8353
--		PORT MAP (
--		clk   =>     CLOCK,   
--		reset_n =>   RESET_all_n, 
--		ADC_CSn =>   ARC_CS_n_3,	
--		ADC_SCK =>   ARC_SCLK_3,
--		ADC_SDI =>   ARC_SDI_3,
--		ADC_SDO_A => ARC_SDO_A_3,
--		ADC_SDO_B => ARC_SDO_B_3,
--		reg_a =>     ARC_DATA(6), -- ARC_A_7 on schematic (J5-B: pin, Pos/Neg - 13/12)
--		reg_b	=>     ARC_DATA(7), -- ARC_A_8 on schematic (J5-B: pin, Pos/Neg - 21/20)
--		ready_a =>   ready_arc(6),
--		ready_b =>   ready_arc(7)); 
		
	ARC_ADC_3 : ads8353_arc
	port MAP(
		 clock    => CLOCK,
		 nreset   => RESET_all_n,
		 sdo_a 	 => ARC_SDO_A_3,
		 sdo_b 	 => ARC_SDO_B_3,
		 ncs 		 => ARC_CS_n_3,
		 sclk 	 => ARC_SCLK_3,
		 sdi 		 => ARC_SDI_3,
		 busy		 => ADC_BUSY(3),
		 data_cha => ARC_DATA(6),
		 data_chb => ARC_DATA(7)
		 );
--		
--		ARC_ADC_4 : ADS8353
--		PORT MAP (
--		clk   =>     CLOCK,   
--		reset_n =>   RESET_all_n, 
--		ADC_CSn =>   ARC_CS_n_4,	
--		ADC_SCK =>   ARC_SCLK_4,
--		ADC_SDI =>   ARC_SDI_4,
--		ADC_SDO_A => ARC_SDO_A_4,
--		ADC_SDO_B => ARC_SDO_B_4,
--		reg_a =>     ARC_DATA(4), -- ARC_A_5 on schematic (J5-A: pin, Pos/Neg - 13/12)
--		reg_b	=>     ARC_DATA(5), -- ARC_A_6 on schematic (J5-A: pin, Pos/Neg - 21/20)
--		ready_a =>   ready_arc(4),
--		ready_b =>   ready_arc(5)); 
		
	ARC_ADC_4 : ads8353_arc
	port MAP(
		 clock    => CLOCK,
		 nreset   => RESET_all_n,
		 sdo_a 	 => ARC_SDO_A_4,
		 sdo_b 	 => ARC_SDO_B_4,
		 ncs 		 => ARC_CS_n_4,
		 sclk 	 => ARC_SCLK_4,
		 sdi 		 => ARC_SDI_4,
		 busy		 => ADC_BUSY(2),
		 data_cha => ARC_DATA(4),
		 data_chb => ARC_DATA(5)
		 );
		
		 -- FOR ARC ADCs:
		 -- channel specific adc busy signal (note, dual port ADCs)
		 ADC_BUSY_8(0) <= ADC_BUSY(0);
		 ADC_BUSY_8(1) <= ADC_BUSY(0);
		 ADC_BUSY_8(2) <= ADC_BUSY(1);
		 ADC_BUSY_8(3) <= ADC_BUSY(1);
		 ADC_BUSY_8(4) <= ADC_BUSY(2);
		 ADC_BUSY_8(5) <= ADC_BUSY(2);
		 ADC_BUSY_8(6) <= ADC_BUSY(3);
		 ADC_BUSY_8(7) <= ADC_BUSY(3);
		 		 
-- ================================================================
-- Fast Shut Down FSD
-- ================================================================
-- 3/31/21, updated for 125 Mhz local bus clock
-- Generate a 5Mhz signal from a 125 Mhz input CLOCK
-- note: rst is active hi and RESET is active low thus we need to input NOT(RESET) into rst input.

	PLL_5MHZ : component PLL_125_to_5
		port map (
			rst      => NOT(RESET_all_n), -- PLL will reset when this input is HI.
			refclk   => CLOCK, -- 125 Mhz in phase with local bus clock
			locked   => clk_5_locked,  
			outclk_0 => clk_5 
		);
		
		-- assign 5 MHz PLL output when signal is locked (stable)
		q <= clk_5 when clk_5_locked = '1' else '0';
		
--	process(CLOCK,RESET)
--		variable count	: STD_LOGIC_VECTOR(15 downto 0);
--		variable tmp	: STD_LOGIC;
--	begin
--		-- active low reset
--		if(RESET='0') then
--			-- reset counter, the output clock is initiated as a low
--			count:=x"0000";
--			tmp:='0';
--		elsif(CLOCK'event and CLOCK='1') then
--			-- check to see if the desired number of ticks have passed
--			-- x0009 = 10 ticks which results in 100 ns low, 100 ns hi which is a 5Mhz clock
--			if (count >= x"0009") then
--				tmp := NOT tmp;--toggle clock signal
--				count := x"0000"; -- reset counter
--			else
--				count :=count+1; --increment counter
--			end if;
--		end if;
--		--assign output 5 Mhz clock
--		q <= tmp; -- this goes to teh inten_fc_fsd
--	end process;

-- interlock enable for field control chassis fast shut down
b2v_inst6 : inten_fc_fsd
PORT MAP(CLOCK => CLOCK,
		 RESET => RESET_all_n,						-- active low reset
		 FIVE_MHZ => q,						-- expects 5 Mhz
		 CAV_FLT_FPGA => CAV_FLT_FPGA,	-- fault from cavity module,HI=Fault. This is a channel specific fault which means a latched fault that was not masked occured.
		 FC_FSD_CLEAR => FC_FSD_CLEAR,	-- set HI to clear fault latch
		 FC_FSD_MASK => FC_FSD_MASK,		-- set HI to mask out that channels Field control FSD
		 INTEN_CLEAR => INTEN_CLEAR,		-- set HI to clear fault latch
		 INTEN_FPGA => fsd,					-- FSD_CAV_FPGA
		 INTEN_MASK => INTEN_MASK,			-- [8] CORRESPONDS TO FSD MAIN MASK, set HI to mask out that channel
		 FSD_MAIN => FSD_MAIN_FPGA,
		 FC_FSD_FAULT_STATUS => FC_FSD,
		 FC_FSD_FPGA => flt,					-- held LOW if a CAV_FLT_FPGA fault occurs else 5Mhz signal
		 FIRST_CAVITY_FAULT => FIRST_CAVITY_FAULT, -- records which cavity fault latched first
		 INTEN_FAULT_STATUS => INTEN,		--fault latch (15:8) & fault status (7:0) 
		 MAIN_FSD_FAULT_STATUS => MAIN_FSD_FAULT_STATUS);
		 
-- ================================================================
-- Fault Control
-- ================================================================

-- latched faults for optical isolators (J5 connector)
b2v_inst12 : vac_fault_status
PORT MAP(CLOCK => CLOCK,
		 RESET => RESET_all_n,
		 VAC_BMLN_FPGA => VAC_BMLN_FPGA,			-- fault input, HI=fault
		 MASK_VAC_FAULT => MASK_VAC_FAULT,		-- set hi to mask fault
		 VAC_FAULT_CLEAR => VAC_FAULT_CLEAR,	-- set hi to clear a latched fault
		 VAC_WAVGD_FPGA => VAC_WAVGD,				-- fault input, HI=fault
		 VAC_FAULT => VAC(17 DOWNTO 9),			-- latched fault value
		 VAC_STATUS => VAC(8 DOWNTO 0));			-- unlatched current status
		
-- ARC compare (latch onto faults if they exist)
b2v_inst18 : arc_compare
PORT MAP(CLOCK => CLOCK,
		 RESET => RESET_all_n,
		 ARC_DATA => ARC_DATA, 						-- arc input data (channel specific)
		 ARC_FAULT_CLEAR => ARC_FAULT_CLEAR,	-- set hi to clear that channels fault (channel specific)
		 ARC_LIMIT => ARC_LIMIT,					-- specify arc limit (fault if over this limit, channel specific)
		 ARC_TIMER => ARC_TIMER,					-- number of continous ticks before issuing an arc fault (channel specific)
		 MASK_ARC_FAULT => open,					-- not used
		 ARC_FAULT => ARC(15 DOWNTO 8),			-- latched arc fault has existed for the specified interval (channel specific)
		 ARC_STATUS => ARC(7 DOWNTO 0));			-- unfiltered value of fault check (channel specific)	
	
--  IR Compare (latch onto faults if they exist)
b2v_inst9 : tmp_compare
PORT MAP(CLOCK => CLOCK,
		 RESET => RESET_all_n,
		 MASK_TMP_FAULT => open,							-- Not used
		 TMPCLD_DATA => TMPCLD_DATA,						-- input channel teperature
		 TMPCLD_FAULT_CLEAR => TMPCLD_FAULT_CLEAR,	-- set hi to clear latched fault
		 TMPCLD_LIMIT => TMPCLD_LIMIT,					-- fault if above this limit
		 TMPWRM_DATA => TMPWRM_DATA,						-- input channel teperature
		 TMPWRM_FAULT_CLEAR => TMPWRM_FAULT_CLEAR,	-- set hi to clear latched fault
		 TMPWRM_LIMIT => TMPWRM_LIMIT,					-- fault if above this limit
		 TMPCLD_FAULT => CLD(15 DOWNTO 8),				-- latched fault
		 TMPCLD_STATUS => CLD(7 DOWNTO 0),				-- unlatched current fault status
		 TMPWRM_FAULT => WRM(15 DOWNTO 8),				-- latched fault
		 TMPWRM_STATUS => WRM(7 DOWNTO 0));				-- unlatched current fault status

--===================================================
-- Ethernet Communication Module from Berkeley
--===================================================
--
--
-- JAL, tie FPGA switch 3 to reconfigure udp module.
-- this is meant for debugging.
process(CLOCK, TST_SW)
begin
	if(CLOCK='1' and CLOCK'event) then
		if TST_SW = '0' then
			udp_reset <= '0';
		else
			udp_reset <= '1';
		end if;
	end if;
end process;

-- JAL 3/6/2024, moved into marvell_phy_config.vhd module
-- will reset Marvel PHY. One reset is needed to init PHY.
--ETH1_RESET_N <= RESET_all_n;
--
-- 7/26/22, updated to Marvel PHY 
inst_comms_top: udp_com
port map(clock				=>	sfp_refclk_p,  -- 3/31/21, 125 Mhz clock 
		reset_n			=>	udp_reset,	   -- active low reset
		lb_clk			=> CLOCK,			-- lb_clk 125 Mhz, from gtx0_tx_usr_clk/tx phy wrapper
		sfp_sda_0		=>	sfp_sda_0,
		sfp_scl_0		=>	sfp_scl_0,
		sfp_refclk_p	=>	sfp_refclk_p,
		sfp_rx_0_p		=>	SGMII1_RX_P,   -- sfp_rx_0_p
		sfp_tx_0_p		=>	SGMII1_TX_P,   -- sfp_tx_0_p
		lb_valid			=> lb_valid, -- 3/8/21, assume this goes HI whenever local bus data is stable
		lb_rnw			=> lb_rnw,   -- invert and connect to input load in regs
		lb_addr			=> lb_addr,  -- connect to input addr in regs (not all bits used)
		lb_wdata			=> lb_wdata, -- connect to input din in regs
		lb_renable		=> open,
		lb_rdata			=> lb_rdata,  -- connect to output dout in regs
		sfp_config_done0 => sfp_config_done0
		);
		
lb_rnw_n <= not(lb_rnw); -- for input into reg module

-- keep unused address bits as LOW
-- JAL, 3/23/21 update added to account for sign extentions
--lb_rdata(31 downto 16)  <= (others => lb_rdata_out(15));
--lb_rdata(15 downto 0)	<=	lb_rdata_out(15 downto 0);	


--ISA_SD_DIR <= udp_hb;
--SYNTHESIZED_WIRE_0 <= '1';
--b2v_inst5 : isa_bus
--PORT MAP(RESET => RESET,
--		 CLOCK => CLOCK,
--		 ISA_BALE => ISA_BALE_FPGA,--
--		 ISA_AEN => ISA_AEN_FPGA,--
--		 ISA_MEMR => ISA_MEMR_FPGA,--
--		 ISA_MEMW => ISA_MEMW_FPGA,--
--		 ISA_SMEMR => ISA_SMEMR_FPGA,--
--		 ISA_SMEMW => ISA_SMEMW_FPGA,--
--		 ISA_SBHE => ISA_SBHE_FPGA,--
--		 ISA_SA => ISA_SA,--
--		 ISA_SD => ISA_SD,-- replaced with lb_wdata
--		 REGS_D => ARC_STOP1,
--		 ISA_SD_DIR => SYNTHESIZED_WIRE_4,-- replaced with udp_hb
--		 ISA_CS16 => ISA_MEMCS16_FPGA,--
--		 REGS_LD => SYNTHESIZED_WIRE_8,-- replaced with lb_rnw_n
--		 ADDR_OUT => A); -- replaced with lb_addr
-- ================================================================
-- Register Table
-- ================================================================

b2v_inst16 : regs
PORT MAP(HB_ISA              => HB_ISA,
		 CLOCK                 => CLOCK,
		 RESET                 => RESET_all_n,
		 LOAD                  => lb_rnw_n,
		 ADDR                  => lb_addr(23 DOWNTO 0),
		 --ARC_BUFF_READY        => ARC_BUFF_READY,
		 ARC_DATA              => ARC_DATA,
		 ARC_FAULT_STATUS      => ARC,
		 DIG_TEMP              => "000" & c10gx_tmp, -- new temp sensor is 10 bits, expects 13
		 DIN                   => lb_wdata(31 downto 0), -- JAL 3/3/22, updated to 32 bits to support remote download
		 FC_FSD_FAULT_STATUS   => FC_FSD,
		 FIRST_CAVITY_FAULT    => FIRST_CAVITY_FAULT,
		 INTEN_FAULT_STATUS    => INTEN,
		 MAIN_FSD_FAULT_STATUS => MAIN_FSD_FAULT_STATUS,
		 TMPCLD_DATA           => TMPCLD_DATA,
		 TMPCLD_FAULT_STATUS   => CLD,
		 TMPWRM_DATA           => TMPWRM_DATA,
		 TMPWRM_FAULT_STATUS   => WRM,
		 VAC_FAULT_STATUS      => VAC,
		 REG_RESET				  => REG_RESET, -- added 4/23/21, so that we can fully reset over epics
		 ARC_FLT_CLR           => ARC_FAULT_CLEAR,
		 ARC_LIMIT             => ARC_LIMIT,
		 ARC_PWR               => ARC_PWR,
		 ARC_STOP              => ARC_STOP, -- not used with new adc, needed??????
		 ARC_TIMER             => ARC_TIMER,
		 ARC_TRIG_DELAY        => open, -- ARC_TRIG_DELAY is not used with new ADC, needed??????
		 ARC_TST               => at,-- 7 downto 0 correspond to arc tests 7 down to 0 (pulse exists for a fixed time, 49984 ticks)
		 CAV_FLT_FPGA          => CAV_FLT_FPGA, -- Each fault is ORed together in this signal (gate by its mask respectively). Channel specific.
		 DOUT                  => lb_rdata,
		 FC_FSD_CLR            => FC_FSD_CLEAR,
		 FC_FSD_MASK           => FC_FSD_MASK,
		 INTEN_CLR             => INTEN_CLEAR,
		 INTEN_MASK            => INTEN_MASK,
		 MASK_ARC_FAULT        => open, -- MASK_ARC_FAULT was not being used, mask occurs internal to regs, clear this fault after testing
		 MASK_TMP_FAULT        => open, -- MASK_TMP_FAULT was not being used, mask occurs internal to regs, clear this fault after testing
		 MASK_VAC_FAULT        => MASK_VAC_FAULT,
		 TMPCLD_FLT_CLR        => TMPCLD_FAULT_CLEAR,
		 TMPCLD_LIMIT          => TMPCLD_LIMIT,
		 TMPCLD_TST            => ct,
		 TMPWRM_FLT_CLR        => TMPWRM_FAULT_CLEAR,
		 TMPWRM_LIMIT          => TMPWRM_LIMIT,
		 TMPWRM_TST            => wt,
		 VAC_FLT_CLR           => VAC_FAULT_CLEAR,
		 ready_arc				  => ready_arc,
		 arc_adc_busy          => ADC_BUSY_8,
		 HELIUM_INTERLOCK_LED  => HELIUM_INTERLOCK_LED,
		 lb_valid  => lb_valid
--		 out_c_addr				  => c_addr, 	-- JAL, 3/3/22 added for cyclone remote download 
--		 out_c_cntlr			  => c_cntlr, 
--		 c10_status       	  => c10_status, 
--		 out_c_data		 	     => c_data, 
--		 c10_datar	  		     => c10_datar, 
--		 out_en_c_data			  => en_c_data
		 );


-- ================================================================
-- General Assignments (maybe move these to specific modules)
-- ================================================================

-- input from Rx Fibers order updated on 4/21/2021
-- fsd = Fast Shutdown
fsd(7) <= FSD_CAV1_FPGA;
fsd(6) <= FSD_CAV2_FPGA;
fsd(5) <= FSD_CAV3_FPGA;
fsd(4) <= FSD_CAV4_FPGA;
fsd(3) <= FSD_CAV5_FPGA;
fsd(2) <= FSD_CAV6_FPGA;
fsd(1) <= FSD_CAV7_FPGA;
fsd(0) <= FSD_CAV8_FPGA;

-- output to Tx Fibers, order updated on 4/21/2021
-- flt = FAULT
FLT_CAV1_FPGA <= flt(0);
FLT_CAV2_FPGA <= flt(1);
FLT_CAV3_FPGA <= flt(2);
FLT_CAV4_FPGA <= flt(3);
FLT_CAV5_FPGA <= flt(4);
FLT_CAV6_FPGA <= flt(5);
FLT_CAV7_FPGA <= flt(6);
FLT_CAV8_FPGA <= flt(7);

-- IR cavity test outputs (warm and cold)
-- NOTE: Rear chassis labels do not match silcscreen on PCB. Thus this
--			the mapping is differente (see not with IR ADCs)
--				silkscreen label		rear chassis label
-- 			IR 1-2					wrm/cld 3&4
--				IR 3-4					wrm/cld 1&2
--				IR 5-6					wrm/cld 7&8
--				IR 7-8					wrm/cld 5&6
-- ct = COLD TEST
-- wt = WARM TEST
-- output signal matches silcscreen values, ct/wt are from
-- hrt/epics and match the rear chassis labels.


-- JAL 9/13/21, NOTE, the below pinouts are confusing. for REV 1 pcbs, change the TST output pins to reflect the update schematic of C1775.
-- again, this is functional AS IS, but a one to one mapping would make the f/w more readable.

TMPCLDTST1_FPGA <= ct(2);
TMPCLDTST2_FPGA <= ct(3);
TMPCLDTST3_FPGA <= ct(0);
TMPCLDTST4_FPGA <= ct(1);
TMPCLDTST5_FPGA <= ct(6);
TMPCLDTST6_FPGA <= ct(7);
TMPCLDTST7_FPGA <= ct(4);
TMPCLDTST8_FPGA <= ct(5);
TMPWRMTST1_FPGA <= wt(2);
TMPWRMTST2_FPGA <= wt(3);
TMPWRMTST3_FPGA <= wt(0);
TMPWRMTST4_FPGA <= wt(1);
TMPWRMTST5_FPGA <= wt(6);
TMPWRMTST6_FPGA <= wt(7);
TMPWRMTST7_FPGA <= wt(4);
TMPWRMTST8_FPGA <= wt(5);

-- saved for reference on 4/27/21
--TMPCLDTST1_FPGA <= ct(0);
--TMPCLDTST2_FPGA <= ct(1);
--TMPCLDTST3_FPGA <= ct(2);
--TMPCLDTST4_FPGA <= ct(3);
--TMPCLDTST5_FPGA <= ct(4);
--TMPCLDTST6_FPGA <= ct(5);
--TMPCLDTST7_FPGA <= ct(6);
--TMPCLDTST8_FPGA <= ct(7);
--TMPWRMTST1_FPGA <= wt(0);
--TMPWRMTST2_FPGA <= wt(1);
--TMPWRMTST3_FPGA <= wt(2);
--TMPWRMTST4_FPGA <= wt(3);
--TMPWRMTST5_FPGA <= wt(4);
--TMPWRMTST6_FPGA <= wt(5);
--TMPWRMTST7_FPGA <= wt(6);
--TMPWRMTST8_FPGA <= wt(7);


-- ARC cavity test outputs
-- at = ARC TEST
--ARCTST1_FPGA <= at(0);
--ARCTST2_FPGA <= at(1);
--ARCTST3_FPGA <= at(2);
--ARCTST4_FPGA <= at(3);
--ARCTST5_FPGA <= at(4);
--ARCTST6_FPGA <= at(5);
--ARCTST7_FPGA <= at(6);
--ARCTST8_FPGA <= at(7);
-- updated on 6/24/21
ARCTST1_FPGA <= at(2);
ARCTST2_FPGA <= at(3);
ARCTST3_FPGA <= at(0);
ARCTST4_FPGA <= at(1);
ARCTST5_FPGA <= at(6);
ARCTST6_FPGA <= at(7);
ARCTST7_FPGA <= at(4);
ARCTST8_FPGA <= at(5);

-- Raw input from optical isolators, these are debounced in VAC_FAULT_STATUS module
VAC_WAVGD(0) <= VAC_CAV1_FPGA;
VAC_WAVGD(1) <= VAC_CAV2_FPGA;
VAC_WAVGD(2) <= VAC_CAV3_FPGA;
VAC_WAVGD(3) <= VAC_CAV4_FPGA;
VAC_WAVGD(4) <= VAC_CAV5_FPGA;
VAC_WAVGD(5) <= VAC_CAV6_FPGA;
VAC_WAVGD(6) <= VAC_CAV7_FPGA;
VAC_WAVGD(7) <= VAC_CAV8_FPGA;


	--===================================================
	--		16 LED expansion (I2C)
	--===================================================
	 led_cont_i2c : LED_CONTROL
	 generic map (testBench=>'0') -- this is only used for simulation, 0 is off, 1 is on
	 PORT MAP	(	
		clock      => clock,
		reset_n    => RESET_all_n,
		LED_TOP	  => LED_TOP,
		LED_BOTTOM => LED_BOTTOM,
		SCL 	     => LED_SCL,
		SDA 	     => LED_SDA
	);
	
	LED_TOP(7) 		<= '1';
	LED_TOP(6) 		<= hb_dig;
	LED_TOP(5) 		<= hb_ioc;
	LED_TOP(4) 		<= NOT(VAC(17)); -- VAC(17) is the BL latched fault. We invert this so that the LED stays green unless if a fault occurs.
	LED_TOP(3) 		<= VAC(9) or VAC(10) or VAC(11) or VAC(12) or VAC(13) or VAC(14) or VAC(15) or VAC(16); -- cavity vac faults (note bit 17 is BL latched fault)
	LED_TOP(2) 		<= HELIUM_INTERLOCK_LED;--WRM(8) or WRM(9) or WRM(10) or WRM(11) or WRM(12) or WRM(13) or WRM(14) or WRM(15) or CLD(8) or CLD(9) or CLD(10) or CLD(11) or CLD(12) or CLD(13) or CLD(14) or CLD(15); -- latched temperature faults
	LED_TOP(1) 		<= FC_FSD(8) or FC_FSD(9) or FC_FSD(10) or FC_FSD(11) or FC_FSD(12) or FC_FSD(13) or FC_FSD(14) or FC_FSD(15); -- latched fsd faults
	LED_TOP(0) 		<= ARC(8) or ARC(9) or ARC(10) or ARC(11) or ARC(12) or ARC(13) or ARC(15) or ARC(15); -- latched arc faults
	--
	--
	-- LED indicators for latched cavity faults. 
	-- This is different from CAV_FLT_FPGA, which is not latched.
	--
	
	LED_BOTTOM(7) 	<= CAV_FLT_FPGA(0);
	LED_BOTTOM(6) 	<= CAV_FLT_FPGA(1);
	LED_BOTTOM(5) 	<= CAV_FLT_FPGA(2);
	LED_BOTTOM(4) 	<= CAV_FLT_FPGA(3);
	LED_BOTTOM(3) 	<= CAV_FLT_FPGA(4);
	LED_BOTTOM(2) 	<= CAV_FLT_FPGA(5);
	LED_BOTTOM(1) 	<= CAV_FLT_FPGA(6);
	LED_BOTTOM(0) 	<= CAV_FLT_FPGA(7);
	
--	LED_BOTTOM(7) 	<= FC_FSD( 8) or ARC( 8) or WRM( 8) or CLD( 8) or VAC( 9);
--	LED_BOTTOM(6) 	<= FC_FSD( 9) or ARC( 9) or WRM( 9) or CLD( 9) or VAC(10);
--	LED_BOTTOM(5) 	<= FC_FSD(10) or ARC(10) or WRM(10) or CLD(10) or VAC(11);
--	LED_BOTTOM(4) 	<= FC_FSD(11) or ARC(11) or WRM(11) or CLD(11) or VAC(12);
--	LED_BOTTOM(3) 	<= FC_FSD(12) or ARC(12) or WRM(12) or CLD(12) or VAC(13);
--	LED_BOTTOM(2) 	<= FC_FSD(13) or ARC(13) or WRM(13) or CLD(13) or VAC(14);
--	LED_BOTTOM(1) 	<= FC_FSD(14) or ARC(14) or WRM(14) or CLD(14) or VAC(15);
--	LED_BOTTOM(0) 	<= FC_FSD(15) or ARC(15) or WRM(15) or CLD(15) or VAC(16);

-----------fpga internal temperature sensor--------------
	-- internal temperature sesnor inside DIE of C10GX
	--
	--signal c10gx_tmp, c10gx_tmp_buffer	, tempb1, tempb2	:	std_logic_vector(9 downto 0);
	-- signal temp_eoc1, temp_eoc2, temp_eoc3 : STD_LOGIC;
	--
	-- NOTE: module uses internal 1Mhz clock. Data is ready at falling edge of fpga_tsd_int_EOC_n
	inst_fpga_tsd: fpga_tsd_int
	port map(
			corectl =>	'1', -- leave HI to continue to sample temp (once every 1024 ms)
			reset   =>	'0',
			tempout =>	c10gx_tmp_buffer,
			eoc     =>	fpga_tsd_int_EOC_n -- at falling edge, data on c10gx_tmp_buffer is valid
		);
	
	-- watch for falling edge of EOC, and then register the new temperature
	process (clock) 	begin
		if (clock'event and clock='1') then temp_eoc1 <= fpga_tsd_int_EOC_n; end if;
	end process;
		process (clock) 	begin
		if (clock'event and clock='1') then temp_eoc2 <= temp_eoc1; end if;
	end process;
	process (clock) 	begin
		if (clock'event and clock='1') then temp_eoc3 <= temp_eoc2; end if;
	end process;
	process (clock) 	begin
		if (clock'event and clock='1') then tempb1 <= c10gx_tmp_buffer; end if;
	end process;
	process (clock) 	begin
		if (clock'event and clock='1') then tempb2 <= tempb1; end if;
	end process;
   process (clock)  begin
		if (clock'event and clock='1') then
			if (temp_eoc3='1') and (temp_eoc2 = '0') then
				c10gx_tmp <= tempb2;
			 end if;
		end if;
	end process;
	
	-----------TPS62111 power swtichers--------------
	PWR_EN_5V	 <= '1';
   PWR_SYNC_5V	 <= '1';
	PWR_EN_33V	 <= '1';
   PWR_SYNC_33V <= '1';
--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
-- No longer needed modules. delete these after done porting over everything (for now, keep as referecne)
--
--b2v_inst3 : interlock_lcd -- we don't have an lcd anymore
--PORT MAP(clk_0 => CLOCK,
--		 reset_n => RESET,
--		 rxd_to_the_uart_0 => RS232_RX,
--		 in_port_to_the_ARC_FAULT => ARC(15 DOWNTO 8),
--		 in_port_to_the_COLD_WINDOW_FAULT => CLD(15 DOWNTO 8),
--		 in_port_to_the_FC_FSD => FC_FSD(15 DOWNTO 8),
--		 in_port_to_the_INTERLOCK_ENABLE => INTEN(15 DOWNTO 8),
--		 in_port_to_the_WARM_WINDOW_FAULT => WRM(15 DOWNTO 8),
--		 in_port_to_the_WAVEGUIDE_VAC_FAULT => VAC(16 DOWNTO 9),
--		 txd_from_the_uart_0 => RS232_TX);
--
--
--
--b2v_inst7 : dac8568_control -- we don't use the dac anympore
--PORT MAP(CLOCK => CLOCK,
--		 RESET => RESET,
--		 DATA => ARC_PWR,
--		 SCLK => ARC_DAC_SCLK,
--		 DIN => ARC_DAC_DIN,
--		 SYNC => ARC_DAC_SYNC);


		 
--		 b2v_inst : lm74 -- temp sensor which we dont have anymore
--PORT MAP(CLOCK => CLOCK,
--		 RESET => RESET,
--		 GO => '1',
--		 SI => TMPBRD_SI,
--		 CS => TMPBRD_CS,
--		 SC => TMPBRD_SCK,
--		 DATA_OUT => SYNTHESIZED_WIRE_11);
--
--b2v_inst8 : ir_iir --need to have IIR
--PORT MAP(CLOCK => CLOCK,
--		 RESET => RESET,
--		 LOAD_CLD => ARC_STOP8,
--		 LOAD_WRM => ARC_STOP9,
--		 TMPCLD_DATA => ARC_TRIG_DELAY0,
--		 TMPWRM_DATA => ARC_TRIG_DELAY1,
--		 TMPCLD_FLTR => TMPCLD_DATA,
--		 TMPWRM_FLTR => TMPWRM_DATA);

-- will need to replaced this module with a genric clock divide that prodcues a 5 Mhz clcok. Feed this into FIVE_MHZ
-- of the inten_fc_fsd module																															?????
--
---- megawizard 4 bit counter, counts up
--	 b2v_inst14 : lpm_counter0
--PORT MAP(clock => CLOCK, -- assumes 80 Mhz clock will need to chang if we use 100 Mhz
--		 q => q); -- produces a 5 Mhz clock
END bdf_type;
