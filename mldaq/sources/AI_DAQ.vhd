-- remote fimrware download notes
-- bin files are exactly what needs to be on the qSPI flash
-- We can leverage intelHex commands (not sure if we need to do the byte reversal)
--  ICAPE2 might be able to be used to reconfigure the device
--  STARTUPE2 might be needed to access the qSPI chips clock
-- not clear if there is a qSPI interface or if I will need to write my own.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;
--for xilinx
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY AI_DAQ IS 
	generic (testBench : STD_LOGIC := '0');-- 1 to use as test bench, 0 otherwise
	PORT
	(
		--CLOCK_IN  : in  STD_LOGIC; -- 100 MHz PIN_AC13
		SYSCLK_P  : in STD_LOGIC;
		reset     : in  STD_LOGIC; -- switch 1, c10 reset
--		m10_reset : in std_logic;  -- Let's us know if Max10 was reset
		
        -- RGMII signals RX
        RGMII_TXD     : OUT STD_LOGIC_VECTOR(3 downto 0);
        RGMII_TX_CTRL : OUT STD_LOGIC;
        RGMII_TX_CLK  : OUT STD_LOGIC;
        -- RGMII signals TX
        RGMII_RXD     : IN STD_LOGIC_VECTOR(3 downto 0);
        RGMII_RX_CTRL : IN STD_LOGIC;
        RGMII_RX_CLK  : IN STD_LOGIC;
        -- RGMII signals, PHY Reset
        PHY_RSTN      : OUT STD_LOGIC;
    
    --		-- ADC Signals ADC 1-8
		ADC1_SDO_A : in std_logic;
		ADC1_SDO_B : in std_logic;
		ADC1_BUSY  : in std_logic;
		ADC1_nCS   : out std_logic;
		ADC1_SCLK  : out std_logic;
		ADC1_RST   : out std_logic;
		ADC1_nCNVST : out std_logic;
		
--		-- ADC Signals ADC 9-16
		ADC2_SDO_A : in std_logic;
		ADC2_SDO_B : in std_logic;
		ADC2_BUSY  : in std_logic;
		ADC2_nCS   : out std_logic;
		ADC2_SCLK  : out std_logic;
		ADC2_RST   : out std_logic;
		ADC2_nCNVST : out std_logic;
		
--		-- ADC Signals ADC 17-24
		ADC3_SDO_A : in std_logic;
		ADC3_SDO_B : in std_logic;
		ADC3_BUSY  : in std_logic;
		ADC3_nCS   : out std_logic;
		ADC3_SCLK  : out std_logic;
		ADC3_RST   : out std_logic;
		ADC3_nCNVST : out std_logic;
		
--		-- ADC Signals ADC 25-32
		ADC4_SDO_A : in std_logic;
		ADC4_SDO_B : in std_logic;
		ADC4_BUSY  : in std_logic;
		ADC4_nCS   : out std_logic;
		ADC4_SCLK  : out std_logic;
		ADC4_RST   : out std_logic;
		ADC4_nCNVST : out std_logic;
		
--		-- GPIO Spares (used for trigger board)
		SPARE_1 : in std_logic; -- XCVR1
		SPARE_2 : in std_logic; -- XCVR2
		SPARE_3 : in std_logic; -- XCVR3 (from expansion board)
		SPARE_4 : in std_logic; -- XCVR4 (from expansion board)
		SPARE_5 : in std_logic;
		SPARE_6 : in std_logic;
		SPARE_7 : in std_logic;
		SPARE_8 : in std_logic;
		SPARE_9 : in std_logic;		
		
--		--LED Interface (front panel)
		LED_SDA : inout std_logic; 
		LED_SCL : out std_logic;
		
--		-- EEPROM i2c memory access
--		FMC_SDA : inout std_logic;
--		FMC_SCL : out std_logic;
		
		-- LED on FPGA board
		led : OUT STD_LOGIC_VECTOR(7 downto 0);
		
		
        --board switches
        sw : IN STD_LOGIC_VECTOR(7 downto 0);
		
		--Nexys specific, keep HI, to turn FMC power on.
		set_vadj : OUT STD_LOGIC_VECTOR(1 downto 0);
		vadj_en : OUT STD_LOGIC;
		
		--Q SPI flash chip pins
		qspi_cs : OUT std_logic;
		qspi_dq : INOUT std_logic_vector(3 downto 0);
		
		-- PMOD JA, MAC Select
		ja : IN STD_LOGIC_VECTOR(7 downto 0)
		
		--fmc_la00_cc_n : OUT STD_LOGIC
	);
END AI_DAQ;


ARCHITECTURE ai_daq OF AI_DAQ IS 

-- IP Generates  --------------------------------------------------------- GENERATES
constant DAQ_C20 : boolean := true;
constant DAQ_BPM : boolean := false;

--attribute keep : string;
attribute dont_touch : string;

--cyclone temp sensor (inside FPGA)
--component fpga_tsd_int is
--	port (
--		corectl : in  std_logic                    := 'X'; -- corectl
--		reset   : in  std_logic                    := 'X'; -- reset
--		tempout : out std_logic_vector(9 downto 0);        -- tempout
--		eoc     : out std_logic                            -- eoc
--	);
--end component fpga_tsd_int;	

--SFP Module
--component udp_com is
--port(	clock				: in std_logic;
--		reset_n			: in std_logic;
--		lb_clk			: out std_logic;
--		sfp_sda_0		: inout std_logic;
--		sfp_scl_0		: out std_logic;
--		sfp_refclk_p	: in std_logic; 
--		sfp_rx_0_p		: in std_logic;  
--		sfp_tx_0_p		: out std_logic;
--		lb_valid			: out std_logic;
--		lb_rnw			: out std_logic;
--		lb_addr			: out std_logic_vector(23 downto 0);
--		lb_wdata			: out std_logic_vector(31 downto 0);
--		lb_renable		: out std_logic;
--		lb_rdata			: in std_logic_vector(31 downto 0) -- changed to in, 3/8/21
--	);
--end component;

-- led expander
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


component spansion IS
PORT
(
    lb_clk      : in std_logic;
    c10_addr    : in std_logic_vector(31 downto 0);
    c10_data    : in std_logic_vector(31 downto 0);
    c10_cntlr   : in std_logic_vector(31 downto 0); 
    c10_status  : out std_logic_vector(31 downto 0);
    c10_datar   : out std_logic_vector(31 downto 0);
	we_cyclone_inst_c10_data  : in std_logic;
	qspi_cs     : out std_logic;
    qspi_dq     : inout std_logic_vector(3 downto 0)
);
END COMPONENT;

signal SDA_OUT : STD_LOGIC;

component tca6416APWR_i2c is
port(clock		:	in std_logic;
	reset			:	in std_logic;
	sel        : in std_logic;
	data_send			:  in std_logic_vector(15 downto 0);
	sda			:	inout std_logic;
	scl			:	out std_logic;
	tca_config_done		:	out std_logic;
	ack_out    : out std_logic
	);
end component;
attribute dont_touch of tca6416APWR_i2c : component is "yes";
--
--component tca6416APWR_i2c is
--port(clock		:	in std_logic;
--	reset			:	in std_logic;
--	data_send			:  in std_logic_vector(15 downto 0);
--	sda			:	inout std_logic;
--	scl			:	out std_logic;
--	tca_config_done		:	out std_logic
--	);
--end component;
--
--
--
COMPONENT DAQ IS 
		generic(genric_clkrate : UNSIGNED(31 downto 0) := x"07735940"); -- how many clock ticks make 1 second (not used?)
				 -- sample_rate_div  : UNSIGNED(15 downto 0) := x"61A8");  -- set adc sample rate based on clock/sample_rate_div
		PORT(
		clock 	: IN  STD_LOGIC;   -- main clock
		reset_n  : IN  STD_LOGIC;   -- active low reset
		TAKE  	: IN  STD_LOGIC;   -- active high trigger to indicate an event has occured
		TAKE_4k  : IN  STD_LOGIC;   -- active high trigger to indicate that data should be saved to buffer on 4k buffer
		DONE		: OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 8k buffer
		DONE_4k  : OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 4k buffer
		ADDR		: IN  reg13_array; -- requested read address 8k buffer
		DATA		: OUT reg16_array; -- data at memeory location (to be sent over UDP module) 8k buffer
		READY		: OUT STD_LOGIC;   -- New data writtent to buffer is ready
		ADDR_4k  : IN  reg11_array; -- data at memeory location (to be sent over UDP module) 4k buffer
		DATA_4k  : OUT reg16_array; -- New data writtent to buffer is ready 4k buffer
		offset_addr : IN STD_LOGIC_VECTOR(12 downto 0);   -- offset address, how many samples after a trigger should be saved (0 means all samples are per trigger, F's-1 all samples after trigger)
		offset_addr_4k : IN STD_LOGIC_VECTOR(10 downto 0);
		ADC_EN	: IN	STD_LOGIC;
		sample_rate_div : IN UNSIGNED(30 downto 0);
		-- ADC signals
		adc_busy : IN  STD_LOGIC;
		nCONVST	: OUT STD_LOGIC;
		nCS		: OUT STD_LOGIC;
		SCLK		: OUT STD_LOGIC;
		SDO_A		: IN  STD_LOGIC;
		SDO_B		: IN  STD_LOGIC;
		sync_reg : OUT STD_LOGIC_VECTOR(15 downto 0)
	);
END COMPONENT;
--attribute dont_touch of DAQ : component is "yes"; -- 4/13/ commented out
--
--verilog component
-- used for remote flash and reconfigure
--COMPONENT CYCLONE IS
--	PORT (
--			 lb_clk 		: IN STD_LOGIC;
--			 c10_addr 	: IN STD_LOGIC_VECTOR(31 downto 0);
--			 c10_data 	: IN STD_LOGIC_VECTOR(31 downto 0);
--			 c10_cntlr 	: IN STD_LOGIC_VECTOR(31 downto 0);
--			 c10_status : OUT STD_LOGIC_VECTOR(31 downto 0);
--			 c10_datar  : OUT STD_LOGIC_VECTOR(31 downto 0);
--			 we_cyclone_inst_c10_data : IN STD_LOGIC); 
--END COMPONENT;

-- for accessing the EEPROM
--COMPONENT EEPROM_CONTROL IS
--	PORT
--	(	
--		clock      		: IN		STD_LOGIC; -- input clock (assumed 125 MHz)
--		reset_n    		: IN		STD_LOGIC; -- active low reset
--		EEPROM_RNW		: IN 		STD_LOGIC; -- Read Not Write for eeprom address
--		EEPROM_go		: IN		STD_LOGIC; -- go, or begin process
--		EEPROM_STAT	 	: OUT 	STD_LOGIC_VECTOR(2 downto 0); -- idc_ack & EEPROM_DIR & i2c_rdy
--		EEPROM_ADDR		: IN 		STD_LOGIC_VECTOR(11 downto 0); -- address of EEPROM, max is 32k bit (we read 1 byte at each address)
--		EEPROM_DATA		: IN 		STD_LOGIC_VECTOR(7 downto 0); -- Data to write to EEPROM
--		EEPROM_DATAR	: OUT 	STD_LOGIC_VECTOR(7 downto 0); -- Data read from EEPROM
--		EEPROM_SCL 		: OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
--		EEPROM_SDA 		: INOUT 	STD_LOGIC -- data line (data is bi directional), LED_SDA
--	);
--END COMPONENT;

-- trigger module
COMPONENT FSD_trigger IS 
		generic(trip_window : UNSIGNED(7 downto 0) := x"32"); -- how many clock ticks to register a fault
		PORT(
		clock 	 : IN  STD_LOGIC; -- input clock
		reset_n   : IN  STD_LOGIC; -- active low reset
		FSD_IN	 : IN  STD_LOGIC; -- fast shutdown input (assumed 5 MHz)
		FSD_MASK  : IN  STD_LOGIC; -- MASK for fault output (set HI to mask)
		FSD_CLEAR : IN  STD_LOGIC; -- clear registered fault (set HI to clear)
		FSD_FORCE : IN  STD_LOGIC; -- force fault condition, software trigger (set HI to force)
		FSD_STAT	 : OUT STD_LOGIC; -- active status (HI means FSD is currently lost)
		FSD_FAULT : OUT STD_LOGIC -- registered fault, use this to trigger buffers (HI means that a fault has occured)
	);
END COMPONENT;

-- new udp_com module for RGMII
COMPONENT rgmii_hw_test IS
PORT(
    IP              : IN STD_LOGIC_VECTOR(31 downto 0);
    MAC             : IN STD_LOGIC_VECTOR(47 downto 0);
	SYSCLK_P        : IN  STD_LOGIC; -- 100 Mhz
	RGMII_TXD       : OUT  STD_LOGIC_VECTOR(3 downto 0);
	RGMII_TX_CTRL   : OUT  STD_LOGIC;
	RGMII_TX_CLK    : OUT  STD_LOGIC;
	RGMII_RXD       : IN  STD_LOGIC_VECTOR(3 downto 0);
	RGMII_RX_CTRL   : IN  STD_LOGIC;
	RGMII_RX_CLK    : IN  STD_LOGIC;
	PHY_RSTN        : OUT  STD_LOGIC;
    lb_clk          : OUT  STD_LOGIC; -- 125 Mhz
    lb_addr         : OUT  STD_LOGIC_VECTOR(23 downto 0);
    lb_valid        : OUT  STD_LOGIC;
    lb_rnw          : OUT  STD_LOGIC;
    lb_wdata        : OUT  STD_LOGIC_VECTOR(31 downto 0);
    lb_rdata        : IN  STD_LOGIC_VECTOR(31 downto 0);
	RESET           : IN  STD_LOGIC;
	led             : OUT  STD_LOGIC_VECTOR(7 downto 0)
	);
END COMPONENT;

signal IP  : STD_LOGIC_VECTOR(31 downto 0); 
signal MAC : STD_LOGIC_VECTOR(47 downto 0);

-- LED control (front panel)
signal LED_TOP, LED_BOTTOM, DONE : STD_LOGIC_VECTOR(7 downto 0);
-- udp signals
signal lb_valid 	: STD_LOGIC;
signal lb_rnw 	: STD_LOGIC;
signal lb_addr, lb_addr_r	: STD_LOGIC_VECTOR(23 downto 0);
signal lb_wdata, lb_rdata :STD_LOGIC_VECTOR(31 downto 0);
signal udp_blink  : STD_LOGIC;


--signal c10gx_tmp : STD_LOGIC_VECTOR(9 downto 0); -- C10GX temp sensor on DIE
--
signal CLOCK, RESET_all : STD_LOGIC;
--
signal dummy_led, LED_D : STD_LOGIC_VECTOR(15 downto 0);
signal lb_buffer_dump_A, lb_buffer_dump_B, lb_buffer_dump_C, lb_buffer_dump_D, lb_buffer_dump_E, lb_buffer_dump_F, lb_buffer_dump_G, lb_buffer_dump_H  : STD_LOGIC_VECTOR(31 downto 0);
signal lb_buffer_dump_MAIN  : STD_LOGIC_VECTOR(31 downto 0);
--
-- 8k signals
signal ADDR_1, ADDR_2, ADDR_3, ADDR_4	: reg13_array;
signal DATA_1, DATA_2, DATA_3, DATA_4	: reg16_array;
--
-- 4k signals
signal ADDR_wf_1, ADDR_wf_2, ADDR_wf_3, ADDR_wf_4 : reg11_array;
signal DATA_wf_1, DATA_wf_2, DATA_wf_3, DATA_wf_4 : reg16_array;

signal c10_datar, c10_status : STD_LOGIC_VECTOR(31 downto 0);

signal TAKE, TAKE_WF : STD_LOGIC;
signal TAKE_buf, TAKE_WF_buf, trigger_state : STD_LOGIC;


signal XCVR_FSD_IN, FSD_MASK, FSD_CLEAR, FSD_FORCE, FSD_STAT, FSD_FAULT : STD_LOGIC;
--
signal hb_fpga, gpio_led_1, gpio_led_2, gpio_led_3 : STD_LOGIC;
--
signal led_buffer : STD_LOGIC_VECTOR(7 downto 0);

signal sync_reg : STD_LOGIC_VECTOR(15 downto 0);

-- ====================================================================================================
-- REGISTER MAP Signals GENERATE 
-- This section is meant to be copy/pasted in whatever module you wish to use the below signal names. 
-- ====================================================================================================
--attribute noprune: boolean;
SIGNAL control_1 : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_control_1 : STD_LOGIC; -- RW
--attribute noprune of control_1 : signal is true;
SIGNAL c_addr : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_c_addr : STD_LOGIC; -- RW
--attribute noprune of c_addr : signal is true;
SIGNAL c_cntlr : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_c_cntlr : STD_LOGIC; -- RW
--attribute noprune of c_cntlr : signal is true;
SIGNAL c_data : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_c_data : STD_LOGIC; -- RW
--attribute noprune of c_data : signal is true;
SIGNAL adc_rate : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_adc_rate : STD_LOGIC; -- RW
--attribute noprune of adc_rate : signal is true;
SIGNAL offset_1 : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_offset_1 : STD_LOGIC; -- RW
--attribute noprune of offset_1 : signal is true;
SIGNAL offset_2 : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_offset_2 : STD_LOGIC; -- RW
--attribute noprune of offset_2 : signal is true;
SIGNAL mem_con : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_mem_con : STD_LOGIC; -- RW
--attribute noprune of mem_con : signal is true;
SIGNAL mem_addr : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_mem_addr : STD_LOGIC; -- RW
--attribute noprune of mem_addr : signal is true;
SIGNAL mem_data : STD_LOGIC_VECTOR(31 downto 0); SIGNAL en_mem_data : STD_LOGIC; -- RW
--attribute noprune of mem_data : signal is true;

SIGNAL status_1 : STD_LOGIC_VECTOR(31 downto 0); -- RO
--attribute noprune of status_1 : signal is true;
SIGNAL c10gx_tmp : STD_LOGIC_VECTOR(9 downto 0); -- RO
--attribute noprune of c10gx_tmp : signal is true;
SIGNAL c_status, c_status2 : STD_LOGIC_VECTOR(31 downto 0); -- RO
--attribute noprune of c_status : signal is true;
SIGNAL c_datar, c_datar2 : STD_LOGIC_VECTOR(31 downto 0); -- RO
--attribute noprune of c_datar : signal is true;
SIGNAL fw_ID : STD_LOGIC_VECTOR(31 downto 0); -- RO
--attribute noprune of fw_ID : signal is true;
SIGNAL mem_stat : STD_LOGIC_VECTOR(31 downto 0); -- RO
--attribute noprune of mem_stat : signal is true;
SIGNAL mem_datar : STD_LOGIC_VECTOR(31 downto 0); -- RO
--attribute noprune of mem_datar : signal is true; 
-- ====================================================================================================
-- END OF REGISTER Package 
-- ====================================================================================================


--
--attribute noprune of LED_TOP    : signal is true; 
--attribute noprune of LED_BOTTOM : signal is true; 
--attribute noprune of ADDR_1     : signal is true; 
--attribute noprune of ADDR_2     : signal is true; 
--attribute noprune of ADDR_3     : signal is true; 
--attribute noprune of ADDR_4     : signal is true;
--attribute noprune of DATA_1     : signal is true; 
--attribute noprune of DATA_2     : signal is true;
--attribute noprune of DATA_3     : signal is true; 
--attribute noprune of DATA_4     : signal is true;  
--attribute noprune of lb_wdata   : signal is true; 
--attribute noprune of lb_addr    : signal is true; 

--attribute PULLUP: string;
 
--attribute PULLUP of ADC4_nCS: signal is "true";
--attribute PULLUP of ADC4_RST: signal is "true";
--attribute PULLUP of ADC4_nCNVST: signal is "true";

signal DAQ_RESET_n : STD_LOGIC;


signal ADC1_nCS_buff, ADC1_RST_buff, ADC1_nCNVST_buff : std_logic;
signal ADC2_nCS_buff, ADC2_RST_buff, ADC2_nCNVST_buff : std_logic;
signal ADC3_nCS_buff, ADC3_RST_buff, ADC3_nCNVST_buff : std_logic;
signal ADC4_nCS_buff, ADC4_RST_buff, ADC4_nCNVST_buff : std_logic;

signal ADC4_nCS_buffex, ADC4_RST_buffex, ADC4_nCNVST_buffex : std_logic;

attribute dont_touch of ADC1_nCS_buff, ADC1_RST_buff, ADC1_nCNVST_buff  : signal is "true";
attribute dont_touch of ADC2_nCS_buff, ADC2_RST_buff, ADC2_nCNVST_buff  : signal is "true";
attribute dont_touch of ADC3_nCS_buff, ADC3_RST_buff, ADC3_nCNVST_buff  : signal is "true";
attribute dont_touch of ADC4_nCS_buff, ADC4_RST_buff, ADC4_nCNVST_buff  : signal is "true";
attribute dont_touch of ADC4_nCS_buffex, ADC4_RST_buffex, ADC4_nCNVST_buffex  : signal is "true";

--ADC1_SDO_A : in std_logic;
--ADC1_SDO_B : in std_logic;
--ADC1_BUSY  : in std_logic;

--ADC1_nCS    : out std_logic;
--ADC1_SCLK   : out std_logic;
--ADC1_RST    : out std_logic;
--ADC1_nCNVST : out std_logic;

signal lb_valid_s : STD_LOGIC; -- make lb_valid human visible
signal ack_out : STD_LOGIC;
--attribute preserve: boolean;
--attribute preserve of c10_status : signal is true;  
--attribute preserve of c10_datar  : signal is true;

signal ADC_BUSY_BUFFER : STD_LOGIC_VECTOR(3 downto 0);

attribute dont_touch of LED_TOP, LED_BOTTOM, DONE, lb_valid, lb_rnw, lb_addr, lb_addr_r, lb_wdata, lb_rdata, udp_blink, lb_buffer_dump_E, lb_buffer_dump_F, lb_buffer_dump_G, lb_buffer_dump_H  : signal is "true";
attribute dont_touch of RESET_all, lb_buffer_dump_A, lb_buffer_dump_MAIN, ADDR_1, ADDR_2, ADDR_3, ADDR_4    : signal is "true";
attribute dont_touch of DATA_wf_1, DATA_wf_2, DATA_wf_3, DATA_wf_4    : signal is "true";
attribute dont_touch of c10_datar, c10_status, XCVR_FSD_IN, FSD_MASK, FSD_CLEAR, FSD_FORCE, FSD_STAT, FSD_FAULT, hb_fpga, gpio_led_1, gpio_led_2, gpio_led_3, led_buffer   : signal is "true";
attribute dont_touch of control_1, c_addr, c_cntlr, c_data, adc_rate, offset_1, offset_2, mem_con, mem_addr, mem_data, status_1, c10gx_tmp, c_status, c_datar, fw_ID, mem_stat, mem_datar : signal is "true";
attribute dont_touch of lb_valid_s, ack_out : signal is "true";

signal ipsel, ipsel_mux : STD_LOGIC_VECTOR(7 downto 0);

---- JAL, check phy reset
--signal PHY_RSTN_buffer : STD_LOGIC;
----Essentially, this is the new udp_com.v module
--signal lb_clk, lb_valid, lb_rnw : STD_LOGIC;
--signal lb_addr : STD_LOGIC_VECTOR(23 downto 0);
--signal lb_wdata, lb_rdata : STD_LOGIC_VECTOR(31 downto 0);

--
BEGIN 
--// JAL, check phy reset
--assign PHY_RSTN = PHY_RSTN_buffer;
--assign led[4] = PHY_RSTN_buffer;
--assign led[5] = clk_locked;
--reg [26:0] tx_clk_heartbeat=0, tx_clk90_heartbeat=0;
--always @(posedge tx_clk) tx_clk_heartbeat <= tx_clk_heartbeat+1;
--always @(posedge tx_clk90) tx_clk90_heartbeat <= tx_clk90_heartbeat+1;
--assign led[6] = tx_clk_heartbeat[24];
--assign led[7] = tx_clk90_heartbeat[24];


--

--===================================================
-- LED Interface (for dev)
--===================================================
--
	--
	--
	-- Just for dev to make sure the leds are working
	-- this should make a one hot led pulse through all leds
	--			on the fpga, these will pulse 1/4 the speed
	--			on the external led boards these should pulse starting at the right most led on the bottom and moving
	--			to the left, then the top led starting at the right and moving to the left.
	--
	process (CLOCK, RESET_all)
			variable counter1   :  UNSIGNED(31 downto 0)  := x"00000000";
			variable counter2   :  UNSIGNED(15 downto 0)  := x"0000";
			variable counter3   :  UNSIGNED( 3 downto 0)  := x"F";
		begin
			if (RESET_all = '0') then
				counter1  := x"00000000";
				counter2  := x"0000";
				counter3  := x"0";
			else
				if CLOCK'event and CLOCK = '1' then
					IF    counter1 >= x"017D7840" THEN	
						counter1 := x"00000000";
						if counter3 >= x"F" THEN
							counter2  := x"0001";
							counter3 := x"0";
						ELSE
							counter2 := counter2(14 downto 0) & '0';
							counter3 := counter3 + 1;
						END IF;
					ELSE
						counter1 := counter1 + 1;
						counter2 := counter2;
						counter3 := counter3;
					END IF;
					
					dummy_led <= std_logic_vector(counter2);
					
				end if; -- end rising edge
			end if; -- end reset catch
	end process;
	--
	-- LED assignments
	--
	-- leds on fpga board
	hb_fpga 	<= dummy_led(0) and ack_out;  -- ack_out is tied to led to keep from synth away. should always be low if i2c ack are valid
	gpio_led_1	<= dummy_led(4);
	gpio_led_2  <= dummy_led(8);
	gpio_led_3	<= dummy_led(12);
	--
	
	-- have to tie to LED to make sure this are kept
	LED(7) <= LED_D(15) AND LED_D(14) AND LED_D(13) AND LED_D(12) AND LED_D(11) AND LED_D(10) AND LED_D(9) AND LED_D(8) AND LED_D(7) AND LED_D(6) AND LED_D(5) AND LED_D(4) AND LED_D(3) AND LED_D(2) AND LED_D(1) AND LED_D(0)  when SW(0)='1' else
	          ipsel(7);
	
	-- output led to Nexys video board
	--   4 PHY leds + 4 fpga hb status leds.
	
	LED(6 downto 0) <= led_buffer(2 downto 0) & gpio_led_3 & gpio_led_2 & gpio_led_1 & hb_fpga when SW(0)='1' else
	                   ipsel(6 downto 0);
	--
	-- front panel leds
--	LED_TOP 		<= dummy_led(15 downto 8);
--	LED_BOTTOM 	<= dummy_led( 7 downto 0);
--	LED_TOP 		<= dummy_led(15 downto 10) & c_status(0) & lb_wdata(0);
--	LED_BOTTOM 	<= dummy_led( 7 downto 2) & c_datar(0) & lb_rdata(0);
	
	
	
--	LED_BOTTOM <= DATA_1(0)(0) & DATA_1(1)(0) & DATA_1(2)(0) & DATA_1(3)(0) & DATA_1(4)(0) & DATA_1(5)(0) & DATA_1(6)(0) & DATA_1(7)(0);
	--
	--
	--===================================================
	-- 16 LED expansion (I2C)
	--===================================================
--	 led_cont_i2c : LED_CONTROL
--	 generic map (testBench=>testBench)
--	 PORT MAP	(	
--		clock      => clock,
--		reset_n    => RESET_all,
--		LED_TOP	  => LED_TOP,
--		LED_BOTTOM => LED_BOTTOM,
--		SCL 	     => LED_SCL,
--		SDA 	     => LED_SDA
--	);
	
	
	-- technically, this is an output only pin, we do not need to worry about tri state.
	--LED_SDA <= SDA_OUT;
	
--	inst_led_ctrl : tca6416APWR_i2c
--	port map (	clock		 => clock,
--					reset		 => RESET_all,
--					data_send => x"a5a5",
--					sda		 => LED_SDA,
--					scl		 => LED_SCL,
--					tca_config_done => open);

	
--	--===================================================
--	-- 32k bit EEPROM module
--	--==================================================
--		EEPROM_inst : EEPROM_CONTROL
--		PORT MAP (	
--		clock        => clock,
--		reset_n    	 => RESET_all,
--		EEPROM_RNW	 => mem_con(1),
--		EEPROM_go	 => mem_con(0),
--		EEPROM_STAT	 => mem_stat(2 downto 0),
--		EEPROM_ADDR	 => mem_addr(11 downto 0),
--		EEPROM_DATA	 => mem_data(7 downto 0),
--		EEPROM_DATAR => mem_datar(7 downto 0),
--		EEPROM_SCL 	 => FMC_SCL,
--		EEPROM_SDA 	 => FMC_SDA
--	);
	
	
--===================================================
-- UDP Module
--===================================================
--

 rgmii_hw_test_inst : rgmii_hw_test
PORT MAP(
    IP => IP,
    MAC => MAC,
	SYSCLK_P      =>   SYSCLK_P,                         --: IN  STD_LOGIC; -- 100 Mhz
	RGMII_TXD     =>   RGMII_TXD,                         --: OUT  STD_LOGIC_VECTOR(3 downto 0);
	RGMII_TX_CTRL =>   RGMII_TX_CTRL,                         --: OUT  STD_LOGIC;
	RGMII_TX_CLK  =>   RGMII_TX_CLK,                         --: OUT  STD_LOGIC;
	RGMII_RXD     =>   RGMII_RXD,                         --: IN  STD_LOGIC_VECTOR(3 downto 0);
	RGMII_RX_CTRL =>   RGMII_RX_CTRL,                         --: IN  STD_LOGIC;
	RGMII_RX_CLK  =>   RGMII_RX_CLK,                         --: IN  STD_LOGIC;
	PHY_RSTN      =>   PHY_RSTN,                         --: OUT  STD_LOGIC;
    lb_clk        =>   CLOCK,                         --: OUT  STD_LOGIC; -- 125 Mhz
    lb_addr       =>   lb_addr,                         --: OUT  STD_LOGIC_VECTOR(23 downto 0);
    lb_valid      =>   lb_valid,                         --: OUT  STD_LOGIC;
    lb_rnw        =>   lb_rnw,                         --: OUT  STD_LOGIC;
    lb_wdata      =>   lb_wdata,                         --: OUT  STD_LOGIC_VECTOR(31 downto 0);
    lb_rdata      =>   lb_rdata,                         --: IN  STD_LOGIC_VECTOR(31 downto 0);
	RESET         =>   RESET_all,                         --: IN  STD_LOGIC;
	led           =>   led_buffer                          --: OUT  STD_LOGIC_VECTOR(7 downto 0)
	);

--	genUDP : if testBench = '0' generate
--		--
--		inst_comms_top: udp_com
--		port map(clock				=>	sfp_refclk_p,  -- 125 Mhz clock
--					reset_n			=>	RESET_all,	   -- active low reset
--					lb_clk			=> CLOCK,			-- lb_clk 125 Mhz, from gtx0_tx_usr_clk/tx phy wrapper
--					sfp_sda_0		=>	sfp_sda_0,
--					sfp_scl_0		=>	sfp_scl_0,
--					sfp_refclk_p	=>	sfp_refclk_p,
--					sfp_rx_0_p		=>	sfp_rx_0_p,
--					sfp_tx_0_p		=>	sfp_tx_0_p,
--					lb_valid			=> lb_valid, -- 3/8/21, assume this goes HI whenever local bus data is stable
--					lb_rnw			=> lb_rnw,   -- invert and connect to input load in regs
--					lb_addr			=> lb_addr,  -- connect to input addr in regs (not all bits used)
--					lb_wdata			=> lb_wdata, -- connect to input din in regs
--					lb_renable		=> open,
--					lb_rdata			=> lb_rdata  -- connect to output dout in regs
--					);
--	--			
--	--
--	end generate genUDP;
	--
	-- simple process to make lb_valid human readable by stretching the pulse out to 200 ms.
	process(clock, RESET_all, lb_valid)
		variable stretch : UNSIGNED(31 downto 0);
	begin
		if (RESET_all = '0') or (lb_valid='1') then
			stretch := (others=>'0'); 
			lb_valid_s <= '1';
		elsif clock = '1' and clock'event then
			if stretch <= x"017D7840" then
				lb_valid_s <= '1';
				stretch := stretch + 1;
			else
				lb_valid_s <= '0';
				stretch := x"0FFFFFFF";
			end if;
		end if;
	end process;
	
	
	-- loop back adc buys status
	ADC_BUSY_BUFFER <= ADC4_BUSY & ADC3_BUSY & ADC2_BUSY & ADC1_BUSY;
	--===================================================
	-- DAQ
	--===================================================
	-- Notes for sample_rate_div:
	-- 0x61A8 for  5 kHz sample rate
	-- 0x1868 for 20 kHz sample rate
	--
	-- 1/6/22, daq modules now directly have the lb_addr fed into them. see notes on lb_buffer_dump mux
	--
	DAQ_inst_1 : DAQ
	 --generic map (sample_rate_div => x"1868")
	 PORT MAP	(	
		clock    => clock,
		reset_n  => DAQ_RESET_n,
		TAKE     => TAKE,
		TAKE_4k	 => TAKE_WF, -- use same trigger for now
		DONE	 => DONE(0),
		DONE_4k  => DONE(4),
		ADDR 	 => ADDR_1,
		DATA	 => DATA_1,
		ADDR_4k  => ADDR_wf_1,
		DATA_4k	 => DATA_wf_1,
		ADC_EN	 => '1',
		sample_rate_div => UNSIGNED(adc_rate(30 downto 0)),
		offset_addr => offset_1(12 downto 0),
		offset_addr_4k => offset_2(10 downto 0),
		adc_busy => ADC1_BUSY,
		nCONVST	=> ADC1_nCNVST_buff,
		nCS		=> ADC1_nCS_buff,
		SCLK	=> ADC1_SCLK,
		SDO_A   => ADC1_SDO_A,
		SDO_B	=> ADC1_SDO_B,
		sync_reg => sync_reg
	);	
		
		-- from autogenerate regmap info
		-- 8k buffers
		ADDR_1(0) <= lb_addr_r(12 downto 0);
		ADDR_1(1) <= lb_addr_r(12 downto 0);
		ADDR_1(2) <= lb_addr_r(12 downto 0);
		ADDR_1(3) <= lb_addr_r(12 downto 0);
		ADDR_1(4) <= lb_addr_r(12 downto 0);
		ADDR_1(5) <= lb_addr_r(12 downto 0);
		ADDR_1(6) <= lb_addr_r(12 downto 0);
		ADDR_1(7) <= lb_addr_r(12 downto 0);
		
		-- 4k buffers
		ADDR_wf_1(0) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(1) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(2) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(3) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(4) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(5) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(6) <= lb_addr_r(10 downto 0);
		ADDR_wf_1(7) <= lb_addr_r(10 downto 0);
	
	DAQ_inst_2 : DAQ
	 --generic map (sample_rate_div => x"1868")
	 PORT MAP	(	
		clock    => clock,
		reset_n  => DAQ_RESET_n,
		TAKE 	 => TAKE,
		TAKE_4k	 => TAKE_WF, -- use same trigger for now
		DONE	 => DONE(1),
		DONE_4k  => DONE(5),
		ADDR 	 => ADDR_2,
		DATA	 => DATA_2,
		ADDR_4k  => ADDR_wf_2,
		DATA_4k	 => DATA_wf_2,
		offset_addr => offset_1(12 downto 0),
		offset_addr_4k => offset_2(10 downto 0),
		ADC_EN	=> '1',
		sample_rate_div => UNSIGNED(adc_rate(30 downto 0)),
		adc_busy => ADC2_BUSY,
		nCONVST	 => ADC2_nCNVST_buff,
		nCS		 => ADC2_nCS_buff,
		SCLK	 => ADC2_SCLK,
		SDO_A    => ADC2_SDO_A,
		SDO_B	 => ADC2_SDO_B,
		sync_reg => open
	);	
		-- from autogenerate regmap info
		ADDR_2(0) <= lb_addr_r(12 downto 0);
		ADDR_2(1) <= lb_addr_r(12 downto 0);
		ADDR_2(2) <= lb_addr_r(12 downto 0);
		ADDR_2(3) <= lb_addr_r(12 downto 0);
		ADDR_2(4) <= lb_addr_r(12 downto 0);
		ADDR_2(5) <= lb_addr_r(12 downto 0);
		ADDR_2(6) <= lb_addr_r(12 downto 0);
		ADDR_2(7) <= lb_addr_r(12 downto 0);
		
		-- 4k buffers
		ADDR_wf_2(0) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(1) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(2) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(3) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(4) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(5) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(6) <= lb_addr_r(10 downto 0);
		ADDR_wf_2(7) <= lb_addr_r(10 downto 0);
		
	DAQ_inst_3 : DAQ
	-- generic map (sample_rate_div => x"1868")
	 PORT MAP	(	
		clock    => clock,
		reset_n  => DAQ_RESET_n,
		TAKE 	 => TAKE,
		TAKE_4k	 => TAKE_WF, -- use same trigger for now
		DONE	 => DONE(2),
		DONE_4k  => DONE(6),
		ADDR 	 => ADDR_3,
		DATA	 => DATA_3,
		ADDR_4k  => ADDR_wf_3, -- ADDR_wf_3
		DATA_4k	 => DATA_wf_3, -- DATA_wf_3
		offset_addr => offset_1(12 downto 0),
		offset_addr_4k => offset_2(10 downto 0),
		ADC_EN	=> '1',
		sample_rate_div => UNSIGNED(adc_rate(30 downto 0)),
		adc_busy => ADC3_BUSY,
		nCONVST	 => ADC3_nCNVST_buff,
		nCS		 => ADC3_nCS_buff,
		SCLK	 =>	ADC3_SCLK,
		SDO_A    => ADC3_SDO_A,
		SDO_B	 => ADC3_SDO_B,
		sync_reg => open
	);	
		-- from autogenerate regmap info
		ADDR_3(0) <= lb_addr_r(12 downto 0);
		ADDR_3(1) <= lb_addr_r(12 downto 0);
		ADDR_3(2) <= lb_addr_r(12 downto 0);
		ADDR_3(3) <= lb_addr_r(12 downto 0);
		ADDR_3(4) <= lb_addr_r(12 downto 0);
		ADDR_3(5) <= lb_addr_r(12 downto 0);
		ADDR_3(6) <= lb_addr_r(12 downto 0);
		ADDR_3(7) <= lb_addr_r(12 downto 0);
		
		-- 4k buffers
		ADDR_wf_3(0) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(1) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(2) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(3) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(4) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(5) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(6) <= lb_addr_r(10 downto 0);
		ADDR_wf_3(7) <= lb_addr_r(10 downto 0);
	
	DAQ_inst_4 : DAQ
	-- generic map (sample_rate_div => x"1868")
	 PORT MAP	(	
		clock    => clock,
		reset_n  => DAQ_RESET_n,
		TAKE 	 => TAKE,
		TAKE_4k	 => TAKE_WF, -- use same trigger for now
		DONE	 => DONE(3),
		DONE_4k  => DONE(7),
		ADDR 	 => ADDR_4,
		DATA	 => DATA_4,
		ADDR_4k  => ADDR_wf_4, -- ADDR_wf_4
		DATA_4k	 => DATA_wf_4, -- DATA_wf_4
		offset_addr => offset_1(12 downto 0),
		offset_addr_4k => offset_2(10 downto 0),
		ADC_EN	=> '1',
		sample_rate_div => UNSIGNED(adc_rate(30 downto 0)),
		adc_busy => ADC4_BUSY,
		nCONVST	 => ADC4_nCNVST_buff,
		nCS		 => ADC4_nCS_buff,
		SCLK     => ADC4_SCLK,
		SDO_A    => ADC4_SDO_A,
		SDO_B	 => ADC4_SDO_B,
		sync_reg => open
	);	
		-- from autogenerate regmap info
		ADDR_4(0) <= lb_addr_r(12 downto 0);
		ADDR_4(1) <= lb_addr_r(12 downto 0);
		ADDR_4(2) <= lb_addr_r(12 downto 0);
		ADDR_4(3) <= lb_addr_r(12 downto 0);
		ADDR_4(4) <= lb_addr_r(12 downto 0);
		ADDR_4(5) <= lb_addr_r(12 downto 0);
		ADDR_4(6) <= lb_addr_r(12 downto 0);
		ADDR_4(7) <= lb_addr_r(12 downto 0);
		
		-- 4k buffers
		ADDR_wf_4(0) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(1) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(2) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(3) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(4) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(5) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(6) <= lb_addr_r(10 downto 0);
		ADDR_wf_4(7) <= lb_addr_r(10 downto 0);
		
		-- =======
		-- lb_buffer_dump mux
		-- =======
		-- the goal of this mux is to assign the lb_buffer_dump to the appropriate buffer.
	   --	We look at the upper 8 bits of lb_addr and make our selection from there.
		-- there are (currently) 31 8k buffers and 31 2k buffers.
		-- they are ordered in pairs that match their channel (see comments below)
		--
		-- the lower 13 bits of lb_addr are used to select the buffer address.
		-- for the 8k buffer, all bits are needed, for the 2k buffer only 11 bits are needed.
		-- this allows us to replaced the 2k buffer with an 8k buffer without changing this mux.
		-- address values will 'roll over' for the 2k buffer if more than 11 bits are provided.
		--
		-- default value of lb_buffer_dump is 0x0000
    process (clock, lb_valid)               
	begin                                                
		if clock'event and clock = '1' then
		  if lb_valid = '1' then
		      lb_addr_r <= lb_addr;
		  end if;
		end if;	
	end process;
		
	process (clock, lb_valid)               
	begin                                                
		if clock'event and clock = '1' then
		    -- multi plexing
            if lb_valid = '1' then
                --
                -- main register mux
                -- lb_addr(18 downto 15) = 0000
                 case lb_addr(7 downto 0) is 
                    when x"50"   => lb_buffer_dump_MAIN(31 downto 0) <= control_1(31 downto 0); 
                    when x"51"   => lb_buffer_dump_MAIN(31 downto 0) <= status_1(31 downto 0); 
                    when x"52"   => lb_buffer_dump_MAIN(31 downto 0) <= c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9 downto 0); 
                    when x"53"   => lb_buffer_dump_MAIN(31 downto 0) <= c_addr(31 downto 0);
                    when x"54"   => lb_buffer_dump_MAIN(31 downto 0) <= c_cntlr(31 downto 0); 
                    when x"55"   => lb_buffer_dump_MAIN(31 downto 0) <= c_status(31 downto 0); 
                    when x"56"   => lb_buffer_dump_MAIN(31 downto 0) <= c_datar(31 downto 0); 
                    when x"57"   => lb_buffer_dump_MAIN(31 downto 0) <= c_data(31 downto 0); 
                    when x"98"   => lb_buffer_dump_MAIN(31 downto 0) <= fw_ID(31 downto 0); 
                    when x"99"   => lb_buffer_dump_MAIN(31 downto 0) <= adc_rate(31 downto 0); 
                    when x"9a"   => lb_buffer_dump_MAIN(31 downto 0) <= offset_1(31 downto 0); 
                    when x"9b"   => lb_buffer_dump_MAIN(31 downto 0) <= offset_2(31 downto 0); 
                    when x"9c"   => lb_buffer_dump_MAIN(31 downto 0) <= mem_con(31 downto 0); 
                    when x"9d"   => lb_buffer_dump_MAIN(31 downto 0) <= mem_stat(31 downto 0); 
                    when x"9e"   => lb_buffer_dump_MAIN(31 downto 0) <= mem_addr(31 downto 0); 
                    when x"9f"   => lb_buffer_dump_MAIN(31 downto 0) <= mem_data(31 downto 0); 
                    when x"a0"   => lb_buffer_dump_MAIN(31 downto 0) <= mem_datar(31 downto 0);
                    when x"a1"   => lb_buffer_dump_MAIN(31 downto 0) <= c_status2(31 downto 0); 
                    when x"a2"   => lb_buffer_dump_MAIN(31 downto 0) <= c_datar2(31 downto 0);  
                    when others  => lb_buffer_dump_MAIN(31 downto 0) <= x"faceface"; -- default
                    --lb_buffer_dump_MAIN(31 downto 0) <= lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15 downto 0); 
                end case;
               -- 2k waveform values
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_A(15 downto 0) <=DATA_wf_1(0);  lb_buffer_dump_A(31 downto 16) <= (others  => DATA_wf_1(0)(15));
                     when  "01"  => lb_buffer_dump_A(15 downto 0) <=DATA_wf_1(1);  lb_buffer_dump_A(31 downto 16) <= (others  => DATA_wf_1(1)(15));
                     when  "10"  => lb_buffer_dump_A(15 downto 0) <=DATA_wf_1(2);  lb_buffer_dump_A(31 downto 16) <= (others  => DATA_wf_1(2)(15));
                     when  "11"  => lb_buffer_dump_A(15 downto 0) <=DATA_wf_1(3);  lb_buffer_dump_A(31 downto 16) <= (others  => DATA_wf_1(3)(15));
                     when others    => lb_buffer_dump_A(31 downto 0) <= x"faceface"; -- default
                end case;
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_B(15 downto 0) <=DATA_wf_1(4);  lb_buffer_dump_B(31 downto 16) <= (others  => DATA_wf_1(4)(15));
                     when  "01"  => lb_buffer_dump_B(15 downto 0) <=DATA_wf_1(5);  lb_buffer_dump_B(31 downto 16) <= (others  => DATA_wf_1(5)(15));
                     when  "10"  => lb_buffer_dump_B(15 downto 0) <=DATA_wf_1(6);  lb_buffer_dump_B(31 downto 16) <= (others  => DATA_wf_1(6)(15));
                     when  "11"  => lb_buffer_dump_B(15 downto 0) <=DATA_wf_1(7);  lb_buffer_dump_B(31 downto 16) <= (others  => DATA_wf_1(7)(15));
                     when others    => lb_buffer_dump_B(31 downto 0) <= x"faceface"; -- default
                 end case;
                 case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_C(15 downto 0) <=DATA_wf_2(0);  lb_buffer_dump_C(31 downto 16) <= (others  => DATA_wf_2(0)(15));
                     when  "01"  => lb_buffer_dump_C(15 downto 0) <=DATA_wf_2(1);  lb_buffer_dump_C(31 downto 16) <= (others  => DATA_wf_2(1)(15));
                     when  "10"  => lb_buffer_dump_C(15 downto 0) <=DATA_wf_2(2);  lb_buffer_dump_C(31 downto 16) <= (others  => DATA_wf_2(2)(15));
                     when  "11"  => lb_buffer_dump_C(15 downto 0) <=DATA_wf_2(3);  lb_buffer_dump_C(31 downto 16) <= (others  => DATA_wf_2(3)(15));
                     when others    => lb_buffer_dump_C(31 downto 0) <= x"faceface"; -- default
                end case;
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_D(15 downto 0) <=DATA_wf_2(4);  lb_buffer_dump_D(31 downto 16) <= (others  => DATA_wf_2(4)(15));
                     when  "01"  => lb_buffer_dump_D(15 downto 0) <=DATA_wf_2(5);  lb_buffer_dump_D(31 downto 16) <= (others  => DATA_wf_2(5)(15));
                     when  "10"  => lb_buffer_dump_D(15 downto 0) <=DATA_wf_2(6);  lb_buffer_dump_D(31 downto 16) <= (others  => DATA_wf_2(6)(15));
                     when  "11"  => lb_buffer_dump_D(15 downto 0) <=DATA_wf_2(7);  lb_buffer_dump_D(31 downto 16) <= (others  => DATA_wf_2(7)(15));
                     when others    => lb_buffer_dump_D(31 downto 0) <= x"faceface"; -- default
                end case;
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_E(15 downto 0) <=DATA_wf_3(0);  lb_buffer_dump_E(31 downto 16) <= (others  => DATA_wf_3(0)(15));
                     when  "01"  => lb_buffer_dump_E(15 downto 0) <=DATA_wf_3(1);  lb_buffer_dump_E(31 downto 16) <= (others  => DATA_wf_3(1)(15));
                     when  "10"  => lb_buffer_dump_E(15 downto 0) <=DATA_wf_3(2);  lb_buffer_dump_E(31 downto 16) <= (others  => DATA_wf_3(2)(15));
                     when  "11"  => lb_buffer_dump_E(15 downto 0) <=DATA_wf_3(3);  lb_buffer_dump_E(31 downto 16) <= (others  => DATA_wf_3(3)(15));
                     when others    => lb_buffer_dump_E(31 downto 0) <= x"faceface"; -- default
                 end case;
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_F(15 downto 0) <=DATA_wf_3(4);  lb_buffer_dump_F(31 downto 16) <= (others  => DATA_wf_3(4)(15));
                     when  "01"  => lb_buffer_dump_F(15 downto 0) <=DATA_wf_3(5);  lb_buffer_dump_F(31 downto 16) <= (others  => DATA_wf_3(5)(15));
                     when  "10"  => lb_buffer_dump_F(15 downto 0) <=DATA_wf_3(6);  lb_buffer_dump_F(31 downto 16) <= (others  => DATA_wf_3(6)(15));
                     when  "11"  => lb_buffer_dump_F(15 downto 0) <=DATA_wf_3(7);  lb_buffer_dump_F(31 downto 16) <= (others  => DATA_wf_3(7)(15));
                     when others    => lb_buffer_dump_F(31 downto 0) <= x"faceface"; -- default
                  end case;
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_G(15 downto 0) <=DATA_wf_4(0);  lb_buffer_dump_G(31 downto 16) <= (others  => DATA_wf_4(0)(15));
                     when  "01"  => lb_buffer_dump_G(15 downto 0) <=DATA_wf_4(1);  lb_buffer_dump_G(31 downto 16) <= (others  => DATA_wf_4(1)(15));
                     when  "10"  => lb_buffer_dump_G(15 downto 0) <=DATA_wf_4(2);  lb_buffer_dump_G(31 downto 16) <= (others  => DATA_wf_4(2)(15));
                     when  "11"  => lb_buffer_dump_G(15 downto 0) <=DATA_wf_4(3);  lb_buffer_dump_G(31 downto 16) <= (others  => DATA_wf_4(3)(15));
                     when others    => lb_buffer_dump_G(31 downto 0) <= x"faceface"; -- default
                  end case;
                case lb_addr(12 downto 11) is 
                     when  "00"  => lb_buffer_dump_H(15 downto 0) <=DATA_wf_4(4);  lb_buffer_dump_H(31 downto 16) <= (others  => DATA_wf_4(4)(15));
                     when  "01"  => lb_buffer_dump_H(15 downto 0) <=DATA_wf_4(5);  lb_buffer_dump_H(31 downto 16) <= (others  => DATA_wf_4(5)(15));
                     when  "10"  => lb_buffer_dump_H(15 downto 0) <=DATA_wf_4(6);  lb_buffer_dump_H(31 downto 16) <= (others  => DATA_wf_4(6)(15));
                     when  "11"  => lb_buffer_dump_H(15 downto 0) <=DATA_wf_4(7);  lb_buffer_dump_H(31 downto 16) <= (others  => DATA_wf_4(7)(15));
                     when others    => lb_buffer_dump_H(31 downto 0) <= x"faceface"; -- default
                    --lb_buffer_dump_MAIN(31 downto 0) <= lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15 downto 0); 
                end case;
                
            end if; -- end lb strobe detection
            --
            -- case for all registers, use lb_addr_r
            -- REGISTER READBACK SELECT
                case lb_addr_r(19 downto 13) is    
                     when  "0000001"  => lb_rdata(15 downto 0) <= DATA_1(0);  lb_rdata(31 downto 16) <= (others => DATA_1(0)(15));
                     when  "0000010"  => lb_rdata(15 downto 0) <= DATA_1(1);  lb_rdata(31 downto 16) <= (others => DATA_1(1)(15));
                     when  "0000011"  => lb_rdata(15 downto 0) <= DATA_1(2);  lb_rdata(31 downto 16) <= (others => DATA_1(2)(15)); 
                     when  "0000100"  => lb_rdata(15 downto 0) <= DATA_1(3);  lb_rdata(31 downto 16) <= (others => DATA_1(3)(15));
                     when  "0000101"  => lb_rdata(15 downto 0) <= DATA_1(4);  lb_rdata(31 downto 16) <= (others => DATA_1(4)(15));
                     when  "0000110"  => lb_rdata(15 downto 0) <= DATA_1(5);  lb_rdata(31 downto 16) <= (others => DATA_1(5)(15));
                     when  "0000111"  => lb_rdata(15 downto 0) <= DATA_1(6);  lb_rdata(31 downto 16) <= (others => DATA_1(6)(15));
                     when  "0001000"  => lb_rdata(15 downto 0) <= DATA_1(7);  lb_rdata(31 downto 16) <= (others => DATA_1(7)(15));
                     when  "0001001"  => lb_rdata(15 downto 0) <= DATA_2(0);  lb_rdata(31 downto 16) <= (others => DATA_2(0)(15));
                     when  "0001010"  => lb_rdata(15 downto 0) <= DATA_2(1);  lb_rdata(31 downto 16) <= (others => DATA_2(1)(15));
                     when  "0001011"  => lb_rdata(15 downto 0) <= DATA_2(2);  lb_rdata(31 downto 16) <= (others => DATA_2(2)(15)); 
                     when  "0001100"  => lb_rdata(15 downto 0) <= DATA_2(3);  lb_rdata(31 downto 16) <= (others => DATA_2(3)(15));
                     when  "0001101"  => lb_rdata(15 downto 0) <= DATA_2(4);  lb_rdata(31 downto 16) <= (others => DATA_2(4)(15));
                     when  "0001110"  => lb_rdata(15 downto 0) <= DATA_2(5);  lb_rdata(31 downto 16) <= (others => DATA_2(5)(15));
                     when  "0001111"  => lb_rdata(15 downto 0) <= DATA_2(6);  lb_rdata(31 downto 16) <= (others => DATA_2(6)(15));
                     when  "0010000"  => lb_rdata(15 downto 0) <= DATA_2(7);  lb_rdata(31 downto 16) <= (others => DATA_2(7)(15));
                     when  "0010001"  => lb_rdata(15 downto 0) <= DATA_3(0);  lb_rdata(31 downto 16) <= (others => DATA_3(0)(15));
                     when  "0010010"  => lb_rdata(15 downto 0) <= DATA_3(1);  lb_rdata(31 downto 16) <= (others => DATA_3(1)(15));
                     when  "0010011"  => lb_rdata(15 downto 0) <= DATA_3(2);  lb_rdata(31 downto 16) <= (others => DATA_3(2)(15)); 
                     when  "0010100"  => lb_rdata(15 downto 0) <= DATA_3(3);  lb_rdata(31 downto 16) <= (others => DATA_3(3)(15));
                     when  "0010101"  => lb_rdata(15 downto 0) <= DATA_3(4);  lb_rdata(31 downto 16) <= (others => DATA_3(4)(15));
                     when  "0010110"  => lb_rdata(15 downto 0) <= DATA_3(5);  lb_rdata(31 downto 16) <= (others => DATA_3(5)(15));
                     when  "0010111"  => lb_rdata(15 downto 0) <= DATA_3(6);  lb_rdata(31 downto 16) <= (others => DATA_3(6)(15));
                     when  "0011000"  => lb_rdata(15 downto 0) <= DATA_3(7);  lb_rdata(31 downto 16) <= (others => DATA_3(7)(15));
                     when  "0011001"  => lb_rdata(15 downto 0) <= DATA_4(0);  lb_rdata(31 downto 16) <= (others => DATA_4(0)(15));
                     when  "0011010"  => lb_rdata(15 downto 0) <= DATA_4(1);  lb_rdata(31 downto 16) <= (others => DATA_4(1)(15));
                     when  "0011011"  => lb_rdata(15 downto 0) <= DATA_4(2);  lb_rdata(31 downto 16) <= (others => DATA_4(2)(15)); 
                     when  "0011100"  => lb_rdata(15 downto 0) <= DATA_4(3);  lb_rdata(31 downto 16) <= (others => DATA_4(3)(15));
                     when  "0011101"  => lb_rdata(15 downto 0) <= DATA_4(4);  lb_rdata(31 downto 16) <= (others => DATA_4(4)(15));
                     when  "0011110"  => lb_rdata(15 downto 0) <= DATA_4(5);  lb_rdata(31 downto 16) <= (others => DATA_4(5)(15));
                     when  "0011111"  => lb_rdata(15 downto 0) <= DATA_4(6);  lb_rdata(31 downto 16) <= (others => DATA_4(6)(15));
                     when  "0100000"  => lb_rdata(15 downto 0) <= DATA_4(7);  lb_rdata(31 downto 16) <= (others => DATA_4(7)(15));
                     when  "0110000"  => lb_rdata(31 downto 0) <= lb_buffer_dump_A;
                     when  "0110001"  => lb_rdata(31 downto 0) <= lb_buffer_dump_B;
                     when  "0110010"  => lb_rdata(31 downto 0) <= lb_buffer_dump_C;
                     when  "0110011"  => lb_rdata(31 downto 0) <= lb_buffer_dump_D;
                     when  "0110100"  => lb_rdata(31 downto 0) <= lb_buffer_dump_E;
                     when  "0110101"  => lb_rdata(31 downto 0) <= lb_buffer_dump_F;
                     when  "0110110"  => lb_rdata(31 downto 0) <= lb_buffer_dump_G;
                     when  "0110111"  => lb_rdata(31 downto 0) <= lb_buffer_dump_H;
                     when  others     => lb_rdata(31 downto 0) <= lb_buffer_dump_MAIN;
            end case;
            
        end if;
	end process;
	
	-- reset ADC once first turning on
	-- must be min of 3k ns, this resets for 8k ns (when 1F40)
	--
	-- DAQ_RESET_n will reset the DAQ modules. this block will 
	-- hold the DAQ modules in reset until he ADC has been fully reset. 
	-- the individual ADC modules will haave a wakeup time
	-- after comingout of reset (in AD7606B module, the module will wake up for 253 u sec)
	--
	-- JAL 4/26/22, 2 stage reset. Reset ADC and DAQ module, then pull ADC out of 
	-- reset but keep module in reset, then pull let both be out of reset.
	-- this allows the ADC's to wake up before we begin to request conversions.
	
	-- set resistor networkfor 3.3v
	-- then enable voltage over FMC
	process (clock, RESET_all)
		variable v_count : UNSIGNED(7 downto 0);
		begin
			if RESET_all='0' then
				v_count := (others => '0');
				vadj_en  <= '0';   -- don't enable external voltage on reset
				set_vadj <= "11";  -- default wakeup is 1.2 but we want 3.3
			elsif clock'event and clock = '1' then	
                if v_count >= x"0F" then
                    set_vadj <= "11";    -- keep set to 3.3v (options 1.2, 1.8, 2.5, 3.3)
                    vadj_en  <= '1';	 -- enable external voltage
                    v_count := x"7F";
                else
                    set_vadj <= "11";  -- set to 3.3v (options 1.2, 1.8, 2.5, 3.3)
                    vadj_en  <= '0';   -- don't enable external voltage
                    v_count := v_count + 1;
                end if;
			 end if;
	end process;
	
	
	-- r
process (clock, RESET_all, control_1)
        variable r_d : UNSIGNED(31 downto 0);
        variable ctrl_last : STD_LOGIC;
    begin
    -- 
        if (RESET_all='0') then
            r_d := (others => '0');
            DAQ_RESET_n   <= '0';  -- hold module in reset
            ADC1_RST_buff <= '1';  -- reset ADC chips
            ADC2_RST_buff <= '1';
            ADC3_RST_buff <= '1';
            ADC4_RST_buff <= '1';
        elsif clock'event and clock = '1' then	
           if r_d >= x"09502F90" then
                if ((ctrl_last='0') and (control_1(8)='1')) then
                    r_d := (others => '0');
                else
                    r_d := x"09502F90";
                end if;
                DAQ_RESET_n   <= '1'; -- release module from reset
                ADC1_RST_buff <= '0';  -- adc's already released from reset for ADC chips
                ADC2_RST_buff <= '0';
                ADC3_RST_buff <= '0';
                ADC4_RST_buff <= '0';
           else
                DAQ_RESET_n   <= '0';  -- hold module in reset
                if r_d >= x"07735940" then
                    ADC1_RST_buff <= '0';  -- release ADCs from reset while keeping firmware module in reset
                    ADC2_RST_buff <= '0';
                    ADC3_RST_buff <= '0';
                    ADC4_RST_buff <= '0';
                else
                    ADC1_RST_buff <= '1';  -- hold ADC's in reset
                    ADC2_RST_buff <= '1';
                    ADC3_RST_buff <= '1';
                    ADC4_RST_buff <= '1';
                end if;
                r_d := r_d + 1;
           end if;
           -- Always update last value of reset control bit
            ctrl_last := control_1(8);
        end if;
end process;
	
	
--	ADC1_nCS    <= ADC1_nCS_buff;
--	ADC1_RST    <= ADC1_RST_buff;
--	ADC1_nCNVST <= ADC1_nCNVST_buff;
--	ADC2_nCS    <= ADC2_nCS_buff;
--	ADC2_RST    <= ADC2_RST_buff;
--	ADC2_nCNVST <= ADC2_nCNVST_buff;
--	ADC3_nCS    <= ADC3_nCS_buff;
--	ADC3_RST    <= ADC3_RST_buff;
--	ADC3_nCNVST <= ADC3_nCNVST_buff;
--	ADC4_nCS    <= ADC4_nCS_buff;
--	ADC4_RST    <= ADC4_RST_buff;
--	ADC4_nCNVST <= ADC4_nCNVST_buff;

	
--	process (clock, RESET_all)
--        variable r_d2 : UNSIGNED(31 downto 0);
--    begin
--    -- 
--        if (RESET_all='0') then
--                r_d2 := (others => '0');
--                ADC4_nCS_buffex    <= '1';
--                ADC4_RST_buffex    <= '1';
--                ADC4_nCNVST_buffex <= '1';
--        elsif clock'event and clock = '1' then	
--           if r_d2 >= x"03b0ACA0" then
--                ADC4_nCS_buffex    <= '1';
--                ADC4_RST_buffex    <= '1';
--                ADC4_nCNVST_buffex <= '1';
--                if  r_d2 >= x"07735940" then
--                    r_d2 := (others => '0');
--                else
--                    r_d2 := r_d2 + 1;
--                end if;
--           else
--                ADC4_nCS_buffex    <= '0';
--                ADC4_RST_buffex    <= '0';
--                ADC4_nCNVST_buffex <= '0';
--                r_d2 := r_d2 + 1;
--           end if;
--        end if;
--end process;
	
OBUF_ADC1_nCS_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC1_nCS,  I => ADC1_nCS_buff);

OBUF_ADC1_RST1_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC1_RST,  I => ADC1_RST_buff);

OBUF_ADC1_nCNVST_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC1_nCNVST,  I => ADC1_nCNVST_buff);

OBUF_ADC2_nCS_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC2_nCS,  I => ADC2_nCS_buff);

OBUF_ADC2_RST1_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC2_RST,  I => ADC2_RST_buff);


OBUF_ADC2_nCNVST_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC2_nCNVST,  I => ADC2_nCNVST_buff);

OBUF_ADC3_nCS_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC3_nCS,  I => ADC3_nCS_buff);

OBUF_ADC3_RST1_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC3_RST,  I => ADC3_RST_buff);

OBUF_ADC3_nCNVST_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC3_nCNVST,  I => ADC3_nCNVST_buff);


OBUF_ADC4_nCS_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC4_nCS,  I => ADC4_nCS_buff);

OBUF_ADC4_RST1_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC4_RST,  I => ADC4_RST_buff);

OBUF_ADC4_nCNVST_inst : OBUF
generic map (DRIVE => 16,
 IOSTANDARD => "DEFAULT",
 SLEW => "SLOW")
port map ( O => ADC4_nCNVST,  I => ADC4_nCNVST_buff);

--PULLUP_OBUF_ADC4_nCS_inst : PULLUP
--   port map (
--      O => ADC4_nCS_buffex     -- Pullup output (connect directly to top-level port)
--   );

--   IOBUF_ADC4_nCS_inst : IOBUF
--   generic map (
--      DRIVE => 12,
--      IOSTANDARD => "DEFAULT",
--      SLEW => "SLOW")
--   port map (
--      O =>  open,          -- Buffer output (to fpga from external IC)
--      IO => ADC4_nCS,      -- Buffer inout port (connect directly to top-level port)
--      I =>  ADC4_nCS_buff, -- Buffer input (from fpga)
--      T =>  ADC4_nCS_buff  -- 3-state enable input, high=input (HI Z output, allows fpga to see external IC data), low=output (outputs data to external IC)
--   );

--PULLUP_OBUF_ADC4_RST1_inst : PULLUP
--   port map (
--      O => ADC4_RST_buffex     -- Pullup output (connect directly to top-level port)
--   );

--   IOBUF_ADC4_RST1_inst : IOBUF
--   generic map (
--      DRIVE => 12,
--      IOSTANDARD => "DEFAULT",
--      SLEW => "SLOW")
--   port map (
--      O =>  open,          -- Buffer output (to fpga from external IC)
--      IO => ADC4_RST,      -- Buffer inout port (connect directly to top-level port)
--      I =>  ADC4_RST_buff, -- Buffer input (from fpga)
--      T =>  ADC4_RST_buff  -- 3-state enable input, high=input (HI Z output, allows fpga to see external IC data), low=output (outputs data to external IC)
--   );


--PULLUP_ADC4_nCNVST_inst_inst : PULLUP
--   port map (
--      O => ADC4_nCNVST_buffex     -- Pullup output (connect directly to top-level port)
--   );

--   IOBUF_ADC4_nCNVST_inst : IOBUF
--   generic map (
--      DRIVE => 12,
--      IOSTANDARD => "DEFAULT",
--      SLEW => "SLOW")
--   port map (
--      O =>  open,          -- Buffer output (to fpga from external IC)
--      IO => ADC4_nCNVST,      -- Buffer inout port (connect directly to top-level port)
--      I =>  ADC4_nCNVST_buff, -- Buffer input (from fpga)
--      T =>  ADC4_nCNVST_buff  -- 3-state enable input, high=input (HI Z output, allows fpga to see external IC data), low=output (outputs data to external IC)
--   );


--
-- 
-- reset control. When pulsed, hold system in reset
--	process (clock, reset)
--		variable r_d2 : UNSIGNED(15 downto 0);
--	begin
--		if (reset='0' OR control_1(8)='1') then
--			r_d2 := (others => '0');
--		elsif clock'event and clock = '1' then			
--				if r_d2 >= x"1F40" then
--					RESET_all <= '1';
--					r_d2 := x"FFFF";
--				else
--					RESET_all <= '0';
--					r_d2 := r_d2 + 1;
--				end if;
--		end if;
--	end process;
	--RESET_all <= '1';
	--
	
	--
	--===================================================
	--		Remote Flash Update/Reconfig
	--===================================================
	-- note, this is a verilog module
--	CYCLONE_inst : CYCLONE
--	PORT MAP(
--			 lb_clk 		=> CLOCK,
--			 c10_addr 	=> c_addr,
--			 c10_data 	=> c_data,
--			 c10_cntlr 	=> c_cntlr,
--			 c10_status => c10_status,
--			 c10_datar  => c10_datar,
--			 we_cyclone_inst_c10_data => (lb_valid AND en_c_data));
		
	--===================================================
	-- Control/EPICS Registers
	--===================================================
	-- 4/13/22, preventing race condition for data by anding status done bits together instead of just looking at one
	-- status register:
	status_1(31 downto 24) <= DONE(7) & DONE(6) & DONE(5) & DONE(4) & DONE(3) & DONE(2) & DONE(1) & DONE(0);
	status_1(23 downto 8) <= x"0000";
	status_1(7 downto 4) <= ADC_BUSY_BUFFER; -- ADC4_BUSY & ADC3_BUSY & ADC2_BUSY & ADC1_BUSY
	status_1(3) <= FSD_FAULT;
	status_1(2) <= FSD_STAT;
	status_1(1) <= '1' when (DONE(0)='1' AND DONE(1)='1' AND DONE(2)='1' AND DONE(3)='1') else '0'; -- bit1 fault data, done flag
	status_1(0) <= '1' when (DONE(4)='1' AND DONE(5)='1' AND DONE(6)='1' AND DONE(7)='1') else '0'; -- bit0 waveform/scope data, done flag
	--
	-- control register:
	-- control_1(10 downto 9) XCVR select
	--control_1(8) master reset (if hi)
		
   -- NOTE, some modules (like the LED I2C bus) may need to be reset if they hang
	RESET_all <= reset ;--when c_cntlr(8)='0' else '0'; -- no debounce for dev
    --
    -- c_cntlr(5) and c_cntlr(4) are for selecting which fiber channel to use
--    FSD_MASK  <= c_cntlr(3);               --8
--    FSD_CLEAR <= c_cntlr(2);               --4, must be manually strobed.
--    FSD_FORCE <= c_cntlr(1);               --2
   -- cntrl(0) is for calibration capture  --1
    FSD_MASK  <= c_cntlr(11);               --2048
    FSD_CLEAR <= c_cntlr(10);               --1024, must be manually strobed.
    FSD_FORCE <= c_cntlr( 9);               --512
   
    -- moving control bits to control_1. c_cntlr will be dedciated for Remote FW download 1-5-23

   -- process to watch for falling edge of take bit (meaning soft IOC/epics has finished reading the fault data)
   -- and clear the latched fault. This will automtically clear the latched fault bit. A user can manually
   -- clear the fault latch if needed. This is only necessary if the harvester/fault waveform viewer is not turned on.
--    process (clock, RESET_all,  control_1)
--        variable last_control_1 : STD_LOGIC;
--    begin
--        if (RESET_all = '0')then
--                last_control_1 := '0';
--                FSD_CLEAR <= '0'; 
--        elsif clock'event and clock = '1' then	
--                -- watching for falling edge of fault take bit (from HI to LOW)
--                if ((last_control_1='1') AND (control_1(1)='0')) then
--                    FSD_CLEAR <= '1'; -- clear latched fault (loss of FSD signal)
--                else
--                    FSD_CLEAR <= c_cntlr(2); -- else manually clear latched fault of control bit is set
--                end if;    
--                last_control_1 := control_1(1); -- update fault take bit
--        end if;
--	end process;
   
   
   
   
   
   
   --  To manually 'force' a fault signal, input to c_cntlr the valude 2, wait for fault buffer to fill, then set c_cntlr to 4 to clear.
   -- we can also input 3 to control_1 in order to load fault waveforms.
   -- If FSD is every lost, then the fault data will fill up and then we will need to set c_cntlr to 4 to clear the fault.
   --
   --
	
	-- Fault waveform take bit:
	--     Can be triggered with control register (bit 1 or bit 5) or when 5 Mhz signal is lost and unmasked (bit 7 is LOW).
	--     Buffer will fill up at time of fault
	--     Buffer will not be cleared until FSD_clear is pulsed HI AND control bit 1 and bit 5 are LOW.
	--     Technically, epics does not need to ever initiate a take bit because loss of FSD is equivalent to the take bit. Epics
	--     only needs to clear the FSD fault between captures.
	TAKE_buf      <= control_1(1) OR FSD_FAULT;
	-- scope waveform take bit
    TAKE_WF_buf   <= control_1(0);
    
    -- add register delay to help with timing.
    -- includes special debug code to validate trigger timing (lb_buffer_dump_A is data on 2k buffers for channels 0, 1, 2, or 3).
    -- NOTE, lets use a another control_2 for configuring FSD masks, FSD force and debug mode)
    --
    -- trigger_state will go hi once the input signal is greater than 0 counts (of the control bit is set)
    -- 
    --sync_reg is the current value of the adc for channel 0 (irrespecitve of the buffer)
    
    process (clock, RESET_all,  sync_reg)
    variable cake : STD_LOGIC;
    begin
        if (RESET_all = '0')then
                TAKE      <= '0';
                TAKE_WF   <= '0';
                trigger_state <= '0';
                cake := '0';
        elsif clock'event and clock = '1' then	
                -- set control bit to debug mode and wait for chn0 to begreater than about .3 volts
                -- then initiate trigger (take bit) and stay in this state until control bit is reset to LOW
                if (( sync_reg(15) = '0') and (UNSIGNED( sync_reg(15 downto 0)) >= x"038E") and (c_cntlr(14) = '1')) or (( trigger_state = '1') and (c_cntlr(14) = '1')) then
                    TAKE    <= '1';
                    TAKE_WF <= '1';
                    trigger_state <= '1';
                    
                  c_status2(15 downto 0) <= x"beef";
                  if cake = '0' then
                      c_datar2(15 downto 0)  <= sync_reg;
                      cake := '1';
	              end if;
                    
                elsif (c_cntlr(14) = '1') then
                     c_status2(15 downto 0) <= x"c001";
                     TAKE   <= '0';
                    TAKE_WF <= '0';
                    trigger_state <= '0';
                    cake := '0';
                else
                    TAKE    <= TAKE_buf;
                    TAKE_WF <= TAKE_WF_buf;
                    trigger_state <= '0';
                     c_status2(15 downto 0) <= x"0000";
                     c_datar2(15 downto 0)  <= x"0000";
                    cake := '0';
                end if;                
        end if;
	end process;


	--
	-- fimrware update registers
	--c_status <= c10_status;
	--c_datar  <= c10_datar;
	--
	-- LED loop back
	--LED_TOP 	<= dummy_led( 7 downto 3) & c_datar(0) & lb_rdata(0) & lb_valid_s;
	--LED_BOTTOM 	<= DONE(4) & DONE(5) & DONE(6) & DONE(7) & DONE(0) & DONE(1) & DONE(2) & DONE(3);
	
		
	--LED_TOP <=x"a5";
	--LED_BOTTOM <= x"5a";
	
	--LED_D(7 downto 0)  <= dummy_led( 7 downto 4) & lb_rdata(2 downto 0) & lb_valid_s;
    --LED_D(15 downto 8) <= DONE(4) & DONE(5) & DONE(6) & DONE(7) & DONE(0) & DONE(1) & DONE(2) & DONE(3);
	--LED_D(7 downto 0)  <= "1" & hb_fpga & lb_valid_s & FSD_STAT & TAKE_WF & TAKE & c_cntlr(5 downto 4); -- JAL 9/1/22 updated to match LEDs
    --LED_D(15 downto 8) <= DONE(4) & DONE(5) & DONE(6) & DONE(7) & DONE(0) & DONE(1) & DONE(2) & DONE(3); -- note sure if the buffer done is useful
    LED_D(15 downto 8)  <= "1" & hb_fpga & lb_valid_s & FSD_STAT & TAKE_WF & TAKE & c_cntlr(5 downto 4); -- JAL, 1/4/23, TOP LEDS
    LED_D(7 downto 0)   <= DONE(4) & DONE(5) & DONE(6) & DONE(7) & DONE(0) & DONE(1) & DONE(2) & DONE(3); -- bottom LEDS
	
	
 tca6416APWR_i2c_inst : tca6416APWR_i2c
    port map ( clock => clock,
                reset => RESET_all,
                sel => sw(0),
                data_send => LED_D,
                sda	=> LED_SDA,
                scl	=> LED_SCL,
                ack_out => ack_out
        );

	--dummy_led( 7 downto 2) & c_datar(0) & lb_rdata(0);
	--
	--
	--
	--===================================================
	--		fpga internal temperature sensor
	--===================================================
--		inst_fpga_tsd: fpga_tsd_int
--		port map(
--				corectl =>	'1',
--				reset   =>	NOT(RESET_all),-- active HI reset
--				tempout =>	c10gx_tmp,
--				eoc     =>	open
--			);
	--===================================================
	--		FSD trigger input
	--===================================================
	--
	-- mux for selecting trigger input. We will only trigger
	-- on one FSD.
	XCVR_FSD_IN <=      SPARE_1 when c_cntlr(13 downto 12)="00" else
						SPARE_2 when c_cntlr(13 downto 12)="01" else
						SPARE_3 when c_cntlr(13 downto 12)="10" else
						SPARE_4;
	--
	inst_fsd : FSD_trigger
		PORT MAP(
		clock 	 => clock,
		reset_n   => RESET_all,
		FSD_IN	 => XCVR_FSD_IN, 
		FSD_MASK  => FSD_MASK , 
		FSD_CLEAR => FSD_CLEAR, 
		FSD_FORCE => FSD_FORCE, 
		FSD_STAT	 => FSD_STAT, 
		FSD_FAULT => FSD_FAULT
	);
	--
	--
	--
	--===================================================
	--		IP and MAC Select
	--===================================================	
	--  NORTH LINAC
	-- rfdaqnl02 - 129.57.202.68
	-- rfdaqnl03 - 129.57.202.69     x8139CA45
	-- rfdaqnl04 - 129.57.202.70
	-- rfdaqnl05 - 129.57.202.71
	-- rfdaqnl06 - 129.57.202.72
	-- rfdaqnl07 - 129.57.202.73
	-- rfdaqnl08 - 129.57.202.74
	-- rfdaqnl09 - 129.57.202.75
	-- rfdaqnl10 - 129.57.202.76
	-- rfdaqnl11 - 129.57.202.77
	-- rfdaqnl12 - 129.57.202.78
	-- rfdaqnl13 - 129.57.202.79
	-- rfdaqnl14 - 129.57.202.80
	-- rfdaqnl15 - 129.57.202.81
	-- rfdaqnl16 - 129.57.202.82
	-- rfdaqnl17 - 129.57.202.83
	-- rfdaqnl18 - 129.57.202.84
	-- rfdaqnl19 - 129.57.202.85
	-- rfdaqnl20 - 129.57.202.86
	-- rfdaqnl21 - 129.57.202.87
	-- ==========================
	-- SOUTH LINAC
    -- rfdaqsl02 - 129.57.202.88
    -- rfdaqsl03 - 129.57.202.89
    -- rfdaqsl04 - 129.57.202.90
    -- rfdaqsl05 - 129.57.202.91
    -- rfdaqsl06 - 129.57.202.92
    -- rfdaqsl07 - 129.57.202.93
    -- rfdaqsl08 - 129.57.202.94
    -- rfdaqsl09 - 129.57.202.95
    -- rfdaqsl10 - 129.57.202.96
    -- rfdaqsl11 - 129.57.202.97
    -- rfdaqsl12 - 129.57.202.98
    -- rfdaqsl13 - 129.57.202.99
    -- rfdaqsl14 - 129.57.202.100
    -- rfdaqsl15 - 129.57.202.101
    -- rfdaqsl16 - 129.57.202.102
    -- rfdaqsl17 - 129.57.202.103
    -- rfdaqsl18 - 129.57.202.104
    -- rfdaqsl19 - 129.57.202.105
    -- rfdaqsl20 - 129.57.202.106
    -- rfdaqsl21 - 129.57.202.107
    -- ==========================
	-- IP = {8'd192, 8'd168, 8'd50, 8'd1};  -- 192.168.50.1 is for lab testing IP
	-- MAC = 48'h125555000145; -- make last to values of MAC be the same as IP address (note IP is decimal and MAC is HEX)
--	PROCESS(CLOCK, RESET_ALL) begin 
--	  -- default IP is test lab IP OR when mac select is set to x"00"/not installed
--      IF(RESET_ALL='0' or ja(7 downto 0)=x"00" or ja(7 downto 0)=x"FF") THEN 
--          IF (sw(1) = '0') THEN -- we want rfdaqnl03 - 129.57.202.69
--               IP  <= x"8139CA45"; -- custom for  rfdaqnl03 - 129.57.202.69 because this is the prototype. Use SW(1) to set this IP
--                --IP  <= x"C0A8320" & SW(4 downto 1); -- 192.168.50. SW(binary XXX0),
--          ELSE
--                IP  <= x"C0A83201"; -- 192.168.50.1, default IP address
--          END IF;
--      ELSIF (CLOCK'event AND CLOCK='1') THEN 
--            IP  <= x"8139CA" & ja(7 downto 0); -- 192.168.50.1 
--	        MAC <= x"1255550001" & ja(7 downto 0); -- last 8 bits of MAC are same as IP
--	         --MAC <= x"12555500010f"; -- last 8 bits of MAC are same as IP
--	         --IP  <= x"C0A83201";
--      END IF; 
--      END PROCESS; 
    PROCESS(CLOCK, RESET_ALL) begin 
        IF(RESET_ALL='0') THEN
            ipsel_mux <= x"00";
        ELSIF (CLOCK'event AND CLOCK='1') THEN 
             -- C1892 PCB is not one to one wiring. decoded here :)
             ipsel_mux(0) <= ja(1);
             ipsel_mux(1) <= ja(0);
             ipsel_mux(2) <= ja(5);
             ipsel_mux(3) <= ja(4);
             ipsel_mux(4) <= ja(7);
             ipsel_mux(5) <= ja(6);
             ipsel_mux(6) <= ja(3);
             ipsel_mux(7) <= ja(2);
        END IF; 
    END PROCESS;   

    ipsel <= x"01" when ipsel_mux = x"00" OR ipsel_mux = x"FF" else ipsel_mux;

-- Use generate statments to detrmine how the IP and MAC addresses are chosen.
-- The same DAQ hardware may be deployed in various locations. This 
-- generate statment helps us determine which location the DAQ is in so that we use a specific IP address to so that we
-- can communicate with the corresponding EPCIS screens.
--
-- Note: Most firmware versions use a debug IP address if you change the selection switches on the FPGA carrier.
--
    -- DAQ NL C20 IP/MAC/FW Version
    -- IP:  192.168.50.xxx
    -- MAC: 18.85.85.00.01.xxx
    -- test ip is 192.168.50.1 (when switches 1,2 are UP) 
DAQ_TYPE_GEN_C20 : if (DAQ_C20=true) generate
        IP(31 downto 0) <= x"C0A83201" when SW(2 downto 1) = "11" else x"8139CA"&ipsel;
        fw_ID <= x"DA240123";        
        MAC <= x"1255550001" & ipsel;
    end generate DAQ_TYPE_GEN_C20;    -- 
    -- BPM IP/MAC/FW version
    -- IP:  129.57.202.120 
    -- MAC: 18.85.85.00.01.120
    -- test ip is 192.168.50.1 (when switches 1,2 are UP)
    DAQ_TYPE_GEN_BPM : if (DAQ_BPM=true) generate
        IP(31 downto 0) <= x"C0A83201" when SW(2 downto 1) = "11" else x"8139CA78";
        fw_ID <= x"B0110703";        
        MAC <= x"125555000178";
    end generate DAQ_TYPE_GEN_BPM;
    
    

    
    --  Old notes about IP bits...
--            IP(31 downto 8) <= x"C0A832" when SW(2 downto 1) = "11" else -- 192.168.50.xxx
--                           x"8139CA";                                -- custom for  rfdaqnl03 - 129.57.202.xxx               
--        IP(7 downto 0)  <= x"45" when SW(2 downto 1) = "00" else -- custom for rfdaqnl03 129.57.202.69 = x"8139CA45";
--                           ipsel;                                -- xxx.xxx.xxx.ipsel for valid IPs
    --                       x"01" when ipsel = x"00" AND SW(2 downto 1) = "10" else -- invalid selection, choose xxx.xxx.xxx.1  as default
    --                       x"01" when ipsel = x"FF" AND SW(2 downto 1) = "10" else -- invalid selection, choose xxx.xxx.xxx.1  as default
    --                       ipsel when SW(2 downto 1) = "01"                   else -- xxx.xxx.xxx.ipsel for valid IPs
    --                       ipsel when SW(2 downto 1) = "10"                   else -- xxx.xxx.xxx.ipsel for valid IPs
    --                       ipsel when SW(2 downto 1) = "11";                       -- xxx.xxx.xxx.ipsel for valid IPs
    --
    --		
    --
    
    --===================================================
	--		remote firmware download for xilinx
	--===================================================	
	--
	rem_fw : spansion 
	PORT MAP(
	lb_clk     => clock,
	c10_addr   => c_addr,
	c10_data   => c_data,
	c10_cntlr  => c_cntlr,
	c10_status => c_status,
	c10_datar  => c_datar,
	we_cyclone_inst_c10_data => (lb_valid AND en_c_data),--en_c_data,
	qspi_cs => qspi_cs,
    qspi_dq    => qspi_dq
  );
	--
	--
	--
	--
	--
-------
-------
-------
-- ====================================================================================================
-- REGISTER MAP GENERATE 
-- This is a generated register list consisting of rw (read/writable) and ro (read only) registers. 
-- These files are generated from a formatted hrt.txt file with expected format as: 
-- register_name,bit_length,bits_to_sign_extend/na,rw/ro 
-- Two files will be generated, regs.vhd and inst.vhd regs_package.vhd
-- regs_package.vhd: is a package that should be included in your module which you desire to use the signals
-- regs.vhd : is intedned to be copy/pasted into whatever module you wish to reference the registers
-- 
-- Notes:
-- All registers are expected to be 'max_bit_length' in length. The user should zero extend if needed. 
-- 
-- ====================================================================================================
-- 

--control_1 rw

en_control_1 <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"00050" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     control_1<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_control_1='1') THEN 
     control_1<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--c_addr rw

en_c_addr <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"00053" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     c_addr<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_addr='1') THEN 
     c_addr<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--c_cntlr rw

en_c_cntlr <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"00054" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     c_cntlr<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_cntlr='1') THEN 
     c_cntlr<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--c_data rw

en_c_data <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"00057" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     c_data<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_data='1') THEN 
     c_data<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--adc_rate rw

en_adc_rate <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"00099" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     adc_rate<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_adc_rate='1') THEN 
     adc_rate<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--offset_1 rw

en_offset_1 <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"0009a" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     offset_1<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_offset_1='1') THEN 
     offset_1<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--offset_2 rw

en_offset_2 <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"0009b" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     offset_2<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_offset_2='1') THEN 
     offset_2<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--mem_con rw

en_mem_con <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"0009c" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     mem_con<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_mem_con='1') THEN 
     mem_con<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--mem_addr rw

en_mem_addr <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"0009e" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     mem_addr<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_mem_addr='1') THEN 
     mem_addr<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
--mem_data rw

en_mem_data <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"0009f" else '0';
PROCESS(CLOCK,RESET_ALL) begin 
  IF(RESET_ALL='0') THEN 
     mem_data<=(others => '0'); 
  ELSIF (CLOCK'event AND CLOCK='1' AND en_mem_data='1') THEN 
     mem_data<=lb_wdata(31 downto 0); 
  END IF; 
END PROCESS; 
  


---- REGISTER READBACK SELECT
--WITH lb_addr(19 downto 0) SELECT 
--lb_rdata(31 downto 0) <=
--	   x"00000000" when x"00000",	
--		x"00001234" when x"00578",
--     control_1(31 downto 0)   WHEN x"00050", 
--     status_1(31 downto 0)   WHEN x"00051", 
--     c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9) & c10gx_tmp(9 downto 0)   WHEN x"00052", 
--     c_addr(31 downto 0)   WHEN x"00053", 
--     c_cntlr(31 downto 0)   WHEN x"00054", 
--     c_status(31 downto 0)   WHEN x"00055", 
--     c_datar(31 downto 0)   WHEN x"00056", 
--     c_data(31 downto 0)   WHEN x"00057", 
--     fw_ID(31 downto 0)   WHEN x"00098", 
--     adc_rate(31 downto 0)   WHEN x"00099", 
--     offset_1(31 downto 0)   WHEN x"0009a", 
--     offset_2(31 downto 0)   WHEN x"0009b", 
--     mem_con(31 downto 0)   WHEN x"0009c", 
--     mem_stat(31 downto 0)   WHEN x"0009d", 
--     mem_addr(31 downto 0)   WHEN x"0009e", 
--     mem_data(31 downto 0)   WHEN x"0009f", 
--     mem_datar(31 downto 0)   WHEN x"000a0", 
--     lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15) & lb_buffer_dump(15 downto 0)    when others; 

-- ====================================================================================================
-- END OF REGISTER MAP 
-- ====================================================================================================

END ai_daq;