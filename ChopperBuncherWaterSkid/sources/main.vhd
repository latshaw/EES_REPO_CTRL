-- 1/29/2025, new project for Chopper Buncher Water Skid in injector (CBH20)
-- James Latshaw
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;
library work;
--for xilinx
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY MAIN IS 
	generic (testBench : STD_LOGIC := '0');-- 1 to use as test bench, 0 otherwise
	PORT
	(
    SYSCLK_P  : in STD_LOGIC;
    reset     : in  STD_LOGIC; -- switch 1, c10 reset
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
    
    -- SLOT 1
    SLOT1_CSn  : out std_logic_vector(3 downto 0);
    SLOT1_SCLK : out std_logic;
    SLOT1_MOSI : out std_logic;
    SLOT1_MISO : in std_logic;	
    
    -- SLOT 2
    SLOT2_CSn  : out std_logic_vector(3 downto 0);
    SLOT2_SCLK : out std_logic;
    SLOT2_MOSI : out std_logic;
    SLOT2_MISO : in std_logic;	
    
    -- SLOT 3
    SLOT3_CSn  : out std_logic_vector(3 downto 0);
    SLOT3_SCLK : out std_logic;
    SLOT3_MOSI : out std_logic;
    SLOT3_MISO : in std_logic;	
    
    -- SLOT 4
    SLOT4_CSn  : out std_logic_vector(3 downto 0);
    SLOT4_SCLK : out std_logic;
    SLOT4_MOSI : out std_logic;
    SLOT4_MISO : in std_logic;	
    
    -- SLOT 5
    SENSE24    : in std_logic; -- J10, 24V sense
    DRIVE24    : out std_logic_vector(3 downto 0); -- 24V drives: Solenoid (J18), Permit, aux1, aux 2(J13) header pins 1 through 5 respectfully
    
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
    END MAIN;

ARCHITECTURE cbh20_arch OF MAIN IS 
--attribute keep : string;
--attribute dont_touch : string;

signal IP, driveOut1, driveOut2, counterSPI1, counterSPI2  : STD_LOGIC_VECTOR(31 downto 0); 
signal MAC : STD_LOGIC_VECTOR(47 downto 0);

-- LED control (front panel)
signal LED_TOP, LED_BOTTOM, DONE : STD_LOGIC_VECTOR(7 downto 0);
-- udp signals
signal lb_valid : STD_LOGIC;
signal lb_rnw 	: STD_LOGIC;
signal lb_addr, lb_addr_r	: STD_LOGIC_VECTOR(23 downto 0);
signal lb_wdata, lb_rdata, lb_rdata_buffer :STD_LOGIC_VECTOR(31 downto 0);
signal udp_blink  : STD_LOGIC;
signal lb_valid_bus : std_logic_vector(3 downto 0);
--signal c10gx_tmp : STD_LOGIC_VECTOR(9 downto 0); -- C10GX temp sensor on DIE
signal CLOCK, RESET_all, lb_vald : STD_LOGIC;
--signal dummy_led, LED_D : STD_LOGIC_VECTOR(15 downto 0);
signal lb_buffer_dump_A, lb_buffer_dump_B, lb_buffer_dump_C, lb_buffer_dump_D, lb_buffer_dump_E, lb_buffer_dump_F, lb_buffer_dump_G, lb_buffer_dump_H  : STD_LOGIC_VECTOR(31 downto 0);
signal lb_buffer_dump_SLOT0,lb_buffer_dump_SLOT1, lb_buffer_dump_SLOT2, lb_buffer_dump_SLOT3, lb_buffer_dump_SLOT4, lb_buffer_control_SLOT : STD_LOGIC_VECTOR(31 downto 0);
-- CBH20
signal RTD1, RTD2 : reg24_array;
signal RTD_RDY : std_logic_vector(1 downto 0);
----
signal led_buffer : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL fw_ID : STD_LOGIC_VECTOR(31 downto 0); -- RO
signal SELECT_IT, SELECT_IT_last, SELECT_IT_pulse, MOSI, MISO, SCLK, CSn : std_logic_vector(3 downto 0);
signal RTD_CTRL : std_logic_vector(7 downto 0);
signal IOEXO_CTRL : std_logic_vector(1 downto 0);
signal maskFault_en, set1_en, set2_en, deadband1_en, deadband2_en, adc_en, drive8_en_1, clearClose_en, saveRestore_en :std_logic;
signal lb_valid_s : STD_LOGIC; -- make lb_valid human visible
signal state_out1 : std_logic_vector(15 downto 0);
signal adc_1, adc_2, adc_3, adc_4 : std_logic_vector(11 downto 0);
--
--
signal config04_1, config0b_1, config0c_1, config0e_1, config0f_1, sense8_1, drive8_rb_1 : std_logic_vector(15 downto 0);
signal drive8_1 : std_logic_vector(7 downto 0);
signal addr1, addr2, addr3, addr4, addr5 : std_logic_vector(15 downto 0);
signal rtdS1_1, rtdS1_2, rtdS2_1, rtdS2_2, rtdS3_1, rtdS3_2, rtdS4_1, rtdS4_2 : std_logic_vector(23 downto 0);
signal heatGo1, heatGo2, DRIVE24OK, DRIVE24OK_d : std_logic;
signal J8_SSR : std_logic_vector(1 downto 0);
signal stat32, latch32, set1, set2, deadband1, deadband2, clearClose, saveRestore, maskFault, faults, faults_d : std_logic_vector(31 downto 0);
signal fault_counter1, fault_counter2, fault_counter3, fault_counter4, fault_counter5, fault_counter1_d, fault_counter2_d, fault_counter3_d, fault_counter4_d, fault_counter5_d : unsigned(31 downto 0);

signal opto_1_iso_out, opto_1_iso_out_buf, opto_3_iso_out : std_logic_vector(15 downto 0);
signal psi_4_1, psi_4_2, psi_4_3, psi_4_4 : std_logic_vector(11 downto 0);
signal zeros : std_logic_vector(31 downto 0);
signal clearCloseP0, clearCloseP1, clearCloseP2, clearCloseP3, clearCloseR0, clearCloseR1, clearCloseR2, clearCloseR3 : std_logic;
signal led_com, flow_fault_d, flow_fault, flow_alarm, clearCloseLast, spillFault, spillFault_d, openSwitch, overTemp1, overTemp1_d, overTemp2, overTemp2_d, main24, main24_d, fault_24V_d, fault_24V : STD_LOGIC;
signal flow_fault_timed, flow_fault_timed_d : std_logic;
signal flow_fault_count,flow_fault_count_d : UNSIGNED(31 downto 0);
signal fault_SM : std_logic_vector(3 downto 0);
signal fault_SM_counter, fault_SM_counter_d : UNSIGNED(31 downto 0);
signal overTempU1, overTempU2, error1, error2, rb1, rb2, SENSE24_counter : UNSIGNED(31 downto 0);
-- tier 1 faults are ones that prevent the realyes from closing no matter what
-- tier2 are faults which may clear after the relay is closed (like flow)
signal sense24_reg, sense24_d, faultTier1, faultTier2, faultTier1_d, faultTier2_d, resetFaults_n, resetFaults_n_d  : std_logic;
signal faultTier1_counter, faultTier2_counter, faultTier1_counter_d, faultTier2_counter_d : UNSIGNED(31 downto 0);
signal rnw_valid, hb_fpga, hb_fpga_d, cool_pulse : std_logic; 
signal LED_D : STD_LOGIC_VECTOR(15 downto 0);
signal cool, cool_d  : STD_LOGIC_VECTOR(7 downto 0);
signal timer, timer_d : UNSIGNED(31 downto 0);

signal softReset, softReset_d : std_logic;
signal PIsoftReset, PIsoftReset_d : std_logic;

signal pgain1, igain1, onMin1, maxPeriod1, timebase1, onPeriod1 : STD_LOGIC_VECTOR(31 downto 0);
signal pgain1_en, igain1_en, onMin1_en, maxPeriod1_en, timebase1_en, onPeriod1_en :std_logic;
signal pgain2, igain2, onMin2, maxPeriod2, timebase2, onPeriod2 : STD_LOGIC_VECTOR(31 downto 0);
signal pgain2_en, igain2_en, onMin2_en, maxPeriod2_en, timebase2_en, onPeriod2_en :std_logic;

BEGIN 

--===================================================
-- LED Interface
--===================================================
RESET_all <= '1'; -- not a good reset...
-- on board
LED(0)          <= reset;
LED(3 downto 1) <= "0" & heatGo2 & heatGo1;--SELECT_IT;
LED(4)          <= led_com;
LED(7 downto 5) <= SW(7 downto 5);

-- front panel
    LED_D(15 downto 8)  <= "1" & hb_fpga & led_com & heatGo1 & heatGo2 & faults(5) & "00"; --TOP LEDS
    LED_D(7 downto 0)   <= cool when DRIVE24OK='1' else x"00"; -- bottom LEDS
 
 tca6416APWR_i2c_inst : entity work.tca6416APWR_i2c
    port map ( clock => clock,
                reset => RESET_all,
                sel => clearClose(3),
                data_send => LED_D,
                sda	=> LED_SDA,
                scl	=> LED_SCL,
                ack_out => open
        );

    -- cool led patterns and front panel io
	process(clock, RESET_all, clearClose)
	begin
		if (RESET_all = '0') or (clearClose(3)='1') then
			hb_fpga    <= '0';
			cool       <= x"81";
			timer      <= (others=>'0');
		elsif clock = '1' and clock'event then
			--
			hb_fpga <= hb_fpga_d;
            cool    <= cool_d;
            timer   <= timer_d;
			--
		end if;
	end process;
--
timer_d <= timer + 1  when timer <=x"017D7840" else (others=>'0');
hb_fpga_d <= NOT(hb_fpga) when timer = x"017D7840" else hb_fpga;
cool_d(7 downto 4) <= cool(4) & cool(7 downto 5) when timer = x"017D7840" else cool(7 downto 4); -- cool(6 downto 0) & cool(7)
cool_d(3 downto 0) <= cool(2 downto 0) & cool(3) when timer = x"017D7840" else cool(3 downto 0);
--cool_d(7 downto 4) <= cool(6 downto 4) & cool(7) when timer = x"017D7840" else cool(7 downto 4); -- cool(6 downto 0) & cool(7)
--cool_d(3 downto 0) <= cool(0) & cool(3 downto 1) when timer = x"017D7840" else cool(3 downto 0);
--
--===================================================
-- UDP Module
--===================================================
--
IP    <= x"C0A83278"; -- 192.168.50.120
MAC   <= x"125555000207";
fw_ID <= x"CB000001"; -- version control
--
 rgmii_hw_test_inst : entity work.rgmii_hw_test
PORT MAP(
    IP            =>   IP,
    MAC           =>   MAC,
	SYSCLK_P      =>   SYSCLK_P,      --: IN  STD_LOGIC; -- 100 Mhz
	RGMII_TXD     =>   RGMII_TXD,     --: OUT  STD_LOGIC_VECTOR(3 downto 0);
	RGMII_TX_CTRL =>   RGMII_TX_CTRL, --: OUT  STD_LOGIC;
	RGMII_TX_CLK  =>   RGMII_TX_CLK,  --: OUT  STD_LOGIC;
	RGMII_RXD     =>   RGMII_RXD,     --: IN  STD_LOGIC_VECTOR(3 downto 0);
	RGMII_RX_CTRL =>   RGMII_RX_CTRL, --: IN  STD_LOGIC;
	RGMII_RX_CLK  =>   RGMII_RX_CLK,  --: IN  STD_LOGIC;
	PHY_RSTN      =>   PHY_RSTN,      --: OUT  STD_LOGIC;
    lb_clk        =>   CLOCK,         --: OUT  STD_LOGIC; -- 125 Mhz
    lb_addr       =>   lb_addr,       --: OUT  STD_LOGIC_VECTOR(23 downto 0);
    lb_valid      =>   lb_valid,      --: OUT  STD_LOGIC;
    lb_rnw        =>   lb_rnw,        --: OUT  STD_LOGIC;
    lb_wdata      =>   lb_wdata,      --: OUT  STD_LOGIC_VECTOR(31 downto 0);
    lb_rdata      =>   lb_rdata,      --: IN  STD_LOGIC_VECTOR(31 downto 0);
	RESET         =>   RESET_all,     --: IN  STD_LOGIC;
	led           =>   led_buffer     --: OUT  STD_LOGIC_VECTOR(7 downto 0)
	);
	--
	-- simple process to make lb_valid human readable by stretching the pulse out to 200 ms.
	process(clock, RESET_all, lb_valid)
		variable stretch : UNSIGNED(31 downto 0);
	begin
		if (RESET_all = '0') or (lb_valid='1') then
			stretch := (others=>'0'); 
			lb_valid_s <= '1';
			led_com    <= '0';
		elsif clock = '1' and clock'event then
			if stretch <= x"02FAF000" then
				lb_valid_s <= '1';
				stretch := stretch + 1;
			else
				lb_valid_s <= '0';
				stretch := x"0FFFFFFF";
			end if;
			--
			led_com    <= lb_valid_s;
			--
		end if;
	end process;
	--
    --===================================================
    -- Instantiate Slots
    --===================================================
    --
    -- address prefix of 0000 will be the base HRT, this is what EPICS will see
    -- note, the below will be available over python scripts but SW will be blind to these
    
    addr1 <= x"0001";
    addr2 <= x"0002";
    addr3 <= x"0003";
    addr4 <= x"0004";
    addr5 <= x"0005";
    
    slot1 : entity work.slot_wrapper
    PORT MAP(
    clock        => clock,
    reset_n      => softReset, --RESET_ALL,
    csn          => SLOT1_CSn,
    sclk         => SLOT1_SCLK,
    sdi          => SLOT1_MISO,
    sdo          => SLOT1_MOSI,
    rtd1_out     => rtdS1_1,        -- heater 1 outlet water temp (J1)
    rtd2_out     => rtdS1_2,        -- heater 1 cavity temp       (J2)
    SSR          => zeros( 1 downto 0),
    sense8_out   => opto_1_iso_out_buf, -- opto iso flow switch (J9) 5 bits
    adc_1_out    => open ,          --zeros(11 downto 0)
    adc_2_out    => open ,          --zeros(11 downto 0)
    adc_3_out    => open ,          --zeros(11 downto 0)
    adc_4_out    => open ,          --zeros(11 downto 0)
    lb_valid     => lb_valid,
    lb_rnw       => lb_rnw,
    lb_addr      => lb_addr,
    lb_wdata     => lb_wdata,
    lb_rdata_mux => lb_buffer_dump_SLOT1,
    ADDR_UPPER   => addr1);
    
    -- 10/31/25 update, one of the flow switches was removed (so later note) so it is set to always
    -- be low (no fault) effectively masking it out. note, it will show up as green on the screens
    opto_1_iso_out(4 downto 0)  <= '0' & opto_1_iso_out_buf(3 downto 0);

    slot2 : entity work.slot_wrapper
    PORT MAP(
    clock        => clock,
    reset_n      => softReset, --RESET_ALL,
    csn          => SLOT2_CSn,
    sclk         => SLOT2_SCLK,
    sdi          => SLOT2_MISO,
    sdo          => SLOT2_MOSI,
    rtd1_out     => rtdS2_1, -- heater 2 outlet water temp (J3)
    rtd2_out     => rtdS2_2, -- heater 2 cavity temp       (J4)
    SSR          => zeros(1 downto 0),
    sense8_out   => open,    --zeros(15 downto 0),
    adc_1_out    => psi_4_1, -- Diagnostic PSI (J7)  MOVE TO SLOT 2
    adc_2_out    => psi_4_2,
    adc_3_out    => psi_4_3,
    adc_4_out    => psi_4_4,
    lb_valid     => lb_valid,
    lb_rnw       => lb_rnw,
    lb_addr      => lb_addr,
    lb_wdata     => lb_wdata,
    lb_rdata_mux => lb_buffer_dump_SLOT2,
    ADDR_UPPER   => addr2);

    slot3 : entity work.slot_wrapper
    PORT MAP(
    clock        => clock,
    reset_n      => softReset, --RESET_ALL,
    csn          => SLOT3_CSn,
    sclk         => SLOT3_SCLK,
    sdi          => SLOT3_MISO,
    sdo          => SLOT3_MOSI,
    rtd1_out     => rtdS3_1,        -- heater 1 overtemp (J5)
    rtd2_out     => rtdS3_2,        -- heater 2 overtemp (J6)
    SSR          => zeros(1 downto 0),
    sense8_out   => opto_3_iso_out, -- opto iso spill sensor (J12) 1 bit needed
    adc_1_out    => open,           --zeros(11 downto 0),
    adc_2_out    => open,           --zeros(11 downto 0),
    adc_3_out    => open,           --zeros(11 downto 0),
    adc_4_out    => open,           --zeros(11 downto 0),
    lb_valid     => lb_valid,
    lb_rnw       => lb_rnw,
    lb_addr      => lb_addr,
    lb_wdata     => lb_wdata,
    lb_rdata_mux => lb_buffer_dump_SLOT3,
    ADDR_UPPER   => addr3);

    slot4 : entity work.slot_wrapper
    PORT MAP(
    clock        => clock,
    reset_n      => softReset, --RESET_ALL,
    csn          => SLOT4_CSn,
    sclk         => SLOT4_SCLK,
    sdi          => SLOT4_MISO,
    sdo          => SLOT4_MOSI,
    rtd1_out     => rtdS4_1,
    rtd2_out     => rtdS4_2,
    SSR          => J8_SSR,  -- SSR Drive (J8)
    sense8_out   => open,    -- zeros(15 downto 0),
    adc_1_out    => open,    --zeros(11 downto 0),
    adc_2_out    => open,    --zeros(11 downto 0),
    adc_3_out    => open,    --zeros(11 downto 0),
    adc_4_out    => open,    --zeros(11 downto 0),
    lb_valid     => lb_valid,
    lb_rnw       => lb_rnw,
    lb_addr      => lb_addr,
    lb_wdata     => lb_wdata,
    lb_rdata_mux => lb_buffer_dump_SLOT4,
    ADDR_UPPER   => addr4);
    
    
    -- slot 5 interface
    -- This takes in 24VDC, power solenoid and Main/Aux1/Aux2 connectors
    --
    
--===================================================
-- Heater Control
--===================================================
-- heaters are controlled with Solid State Relays (SSR)
-- RTD key
-- rtdS1_1 heater 1 outlet water temp (J1)
-- rtdS1_2 heater 1 cavity temp       (J2)
-- rtdS2_1 heater 2 outlet water temp (J3)
-- rtdS2_2 heater 2 cavity temp       (J4) 
-- rtdS3_1 heater 1 overtemp          (J5)
-- rtdS3_2 heater 2 overtemp          (J6)
    
--    control_slot_1 : entity work.heaterCtrl
--    PORT MAP(
--    clock        => clock,
--    reset_n      => softReset, --RESET_ALL,
--    rtd1         => rtdS1_2, -- regulate on cavity temp
--    heatGo1      => heatGo1,
--    set          => set1,
--    deadband     => deadband1);
--  control_slot_2 : entity work.heaterCtrl
--    PORT MAP(
--    clock        => clock,
--    reset_n      => softReset, --RESET_ALL,
--    rtd1         => rtdS2_2, -- regulate on cavity temp
--    heatGo1      => heatGo2,
--    set          => set2,
--    deadband     => deadband2);

 control_slot_1 : entity work.PICtrl
    PORT MAP(
    clock        => clock,
    reset_n      => PIsoftReset, --RESET_ALL,
    rtd1         => rtdS1_2,   -- regulate on cavity temp
    heatGo1      => heatGo1,
    set          => set1,
    pgain        => pgain1(22 downto 0),
    igain       =>  igain1(22 downto 0),
    onMin        => onMin1,
    maxPeriod    => maxPeriod1,
    timebase     => timebase1,
    driveOut     => driveOut1,
    counter      => counterSPI1,
    onPeriod     => onPeriod1);
    
 control_slot_2 : entity work.PICtrl
    PORT MAP(
    clock        => clock,
    reset_n      => PIsoftReset, --RESET_ALL,
    rtd1         => rtdS2_2,   -- regulate on cavity temp
    heatGo1      => heatGo2,
    set          => set2,
    pgain        => pgain2(22 downto 0),
    igain       =>  igain2(22 downto 0),
    onMin        => onMin2,
    maxPeriod    => maxPeriod2,
    timebase     => timebase2,
    driveOut     => driveOut2,
    counter      => counterSPI2, 
    onPeriod     => onPeriod2);
    
    --11/19/25, swapped order b/c 'Relay Power Chassis' has AB going to MH2 and CD going to MH1
    J8_SSR <= heatGo2 & heatGo1; -- when high, the respective SSR will be driven on
    
    rb1(23 downto 0) <= UNSIGNED(rtdS1_2);
    rb1(31 downto 24) <= (others=>'0');
    rb2(23 downto 0) <= UNSIGNED(rtdS2_2);
    rb2(31 downto 24) <= (others=>'0');
    
    -- will report our regulation error
    error1 <= UNSIGNED(set1) - rb1;
    error2 <= UNSIGNED(set2) - rb2;
  -- 
  --
  --
    --===================================================
    -- Fault Logic
    --===================================================
    -- SENSE24 : J18, 24V sense. This is the 24V that is needed to drive the heater relays. It originates external to this chassis.
    -- DRIVE24 : 24V drives: Solenoid (J18), Permit, aux1, aux 2(J13) header pins 1 through 5 respectfully
    sense24_d    <= '1' when SENSE24='1' and maskFault(4)='0' else '0';     -- 24 Volt fault logic: high means fault, low means no fault
    spillFault_d <= '0'; --spill sensor: high means fault, low means no fault,  b/c sensor is removed this is set to be low (i.e. never faults). was <= '0' when opto_3_iso_out(0)='0' else '1';
    flow_alarm   <= '0' when opto_1_iso_out(4 downto 0)="00000" else '1';     -- flow switches: high when faulted and pulled low when good. Pumps must be on to measure flow.
    flow_fault_d <= '0' when (opto_1_iso_out(0)='1' and opto_1_iso_out(1)='0' and opto_1_iso_out(2)='0' and opto_1_iso_out(3)='0' and opto_1_iso_out(4)='0') or maskFault(3)='1' else
                    '0' when (opto_1_iso_out(1)='1' and opto_1_iso_out(0)='0' and opto_1_iso_out(2)='0' and opto_1_iso_out(3)='0' and opto_1_iso_out(4)='0') or maskFault(3)='1' else
                    '0' when (opto_1_iso_out(2)='1' and opto_1_iso_out(0)='0' and opto_1_iso_out(1)='0' and opto_1_iso_out(3)='0' and opto_1_iso_out(4)='0') or maskFault(3)='1' else
                    '0' when (opto_1_iso_out(3)='1' and opto_1_iso_out(0)='0' and opto_1_iso_out(1)='0' and opto_1_iso_out(2)='0' and opto_1_iso_out(4)='0') or maskFault(3)='1' else
                    '0' when (opto_1_iso_out(4)='1' and opto_1_iso_out(0)='0' and opto_1_iso_out(1)='0' and opto_1_iso_out(2)='0' and opto_1_iso_out(3)='0') or maskFault(3)='1' else
                    '0' when opto_1_iso_out(4 downto 0)="00000" or maskFault(3)='1' else
                    '1';     -- loss of two or more is a fault.
    overTempU1(23 downto 0)  <= UNSIGNED(rtdS3_1);  -- Pump Temperature Sensors: high when faulted low when good
    overTempU1(31 downto 24) <= (others=>'0');      -- these are RTDs on the pumps to ensure that they do not overheat
    overTempU2(23 downto 0)  <= UNSIGNED(rtdS3_2);  -- over temperature alarms will fault if above 75C which is about a83000 in counts for PT1000
    overTempU2(31 downto 24) <= (others=>'0');      -- and 0010D873 for PT100 which is what is installed in the machine
    overTemp1_d <= '1' when ((overTempU1 >= x"0010D873") or (overTempU1 = x"00000000")) and maskFault(1)='0' else '0'; -- faulted when at 75C or higher, or when 0 (rtd unplugged)
    overTemp2_d <= '1' when ((overTempU2 >= x"0010D873") or (overTempU2 = x"00000000")) and maskFault(2)='0' else '0'; -- same for pump2
    --
    -- fault state machine: if no tier 1 faults, allow power to turn on for 10 seconds, check tier 2 and if all good stay on until a fault occurs or we turn off
    --fault_SM_counter_d <= fault_SM_counter + 1 when fault_SM =x"5" else (others => '0');
    --resetFaults_n_d    <= '0' when fault_SM=x"1" or fault_SM=x"2" or fault_SM=x"3" or clearClose(3)='1' else '1';
    fault_counter1_d <= fault_counter1 + 1 when spillFault  = '1' else (others => '0');
    fault_counter2_d <= fault_counter2 + 1 when overTemp1   = '1' else (others => '0');
    fault_counter3_d <= fault_counter3 + 1 when overTemp2   = '1' else (others => '0');
    fault_counter4_d <= fault_counter4 + 1 when flow_fault  = '1' else (others => '0');
    fault_counter5_d <= fault_counter5 + 1 when sense24_reg = '1' else (others => '0');
    -- these become latched faults for display only
    faults_d(0) <= '1' when fault_counter1 >= x"4A817C80" else faults(0);
    faults_d(1) <= '1' when fault_counter2 >= x"4A817C80" else faults(1);
    faults_d(2) <= '1' when fault_counter3 >= x"4A817C80" else faults(2);
    faults_d(3) <= '1' when fault_counter4 >= x"4A817C80" else faults(3);
    faults_d(4) <= '1' when fault_counter5 >= x"4A817C80" else faults(4); 
    -- power chassis enable
    DRIVE24OK_d <= '1' when fault_SM =x"4" else '0';
    -- all module reset
    softReset_d   <= '0' when fault_SM =x"1" else '1';
    PIsoftReset_d <= '0' when clearClose(3) = '1' else '1'; -- 12/1/2025
    ------------------------------------------------- 
    --
    PROCESS(CLOCK) begin 
      IF (CLOCK'event AND CLOCK='1') THEN 
         IF    fault_SM = x"0" THEN 
            IF (clearClose(0) = '1' and clearCloseLast = '0') or clearClose(3) = '1' THEN
                fault_SM <= x"1";
            ELSE
                fault_SM <= x"0";
            END IF;
            faults(4 downto 0) <= faults_d(4 downto 0);
            fault_counter1     <= fault_counter1_d;
            fault_counter2     <= fault_counter2_d;
            fault_counter3     <= fault_counter3_d;
            fault_counter4     <= fault_counter4_d;
            fault_counter5     <= fault_counter5_d;
         ELSIF fault_SM = x"1" THEN
            IF clearCloseLast = '1' THEN
                fault_SM <= x"2";
            ELSE
                fault_SM <= x"0";
            END IF;
            faults(4 downto 0) <= (others => '0');
            fault_counter1     <= (others => '0');
            fault_counter2     <= (others => '0');
            fault_counter3     <= (others => '0');
            fault_counter4     <= (others => '0');
            fault_counter5     <= (others => '0');
         ELSIF fault_SM = x"2" THEN
            fault_SM <= x"3";
            faults(4 downto 0) <= (others => '0');
            fault_counter1     <= (others => '0');
            fault_counter2     <= (others => '0');
            fault_counter3     <= (others => '0');
            fault_counter4     <= (others => '0');
            fault_counter5     <= (others => '0');
         ELSIF fault_SM = x"3" THEN
            fault_SM <= x"4";
            faults(4 downto 0) <= (others => '0');
            fault_counter1     <= (others => '0');
            fault_counter2     <= (others => '0');
            fault_counter3     <= (others => '0');
            fault_counter4     <= (others => '0');
            fault_counter5     <= (others => '0');
         ELSE
            IF clearCloseLast = '1' and faults(5 downto 0)="000000" THEN
                fault_SM <= x"4";
            ELSE
                fault_SM <= x"0";
            END IF;
            faults(4 downto 0) <= faults_d(4 downto 0);
            fault_counter1     <= fault_counter1_d;
            fault_counter2     <= fault_counter2_d;
            fault_counter3     <= fault_counter3_d;
            fault_counter4     <= fault_counter4_d;
            fault_counter5     <= fault_counter5_d;
         END IF;
         -- 
         softReset          <= softReset_d;    
         PIsoftReset        <= PIsoftReset_d;  
         clearCloseLast     <= clearClose(0);
         --
         sense24_reg        <= sense24_d;
         spillFault         <= spillFault_d; 
         overTemp1          <= overTemp1_d;
         overTemp2          <= overTemp2_d;
         flow_fault         <= flow_fault_d;
         --
         --fault_SM_counter <= fault_SM_counter_d;
         --resetFaults_n    <= resetFaults_n_d;
         faults(5)        <= NOT(saveRestore(0)) or faults(0) or faults(1) or faults(2) or faults(3) or faults(4);
         faults(6)        <= NOT(DRIVE24OK); -- main power readback. faults are low when good so we need to invert DRIVE24OK 
         faults(31 downto 7) <= (others=>'0');
         --
         DRIVE24OK <= DRIVE24OK_d;
         --
      END IF; 
    END PROCESS; 
    --
    -- high means turn on
    -- low means turn off
    DRIVE24(0) <= DRIVE24OK; -- main power enable
    DRIVE24(1) <= DRIVE24OK; -- solenoid on (same turn on conditions as main power)
    DRIVE24(2) <= '1' when clearClose(1)='1' else '0'; -- Aux 1 power enable
    DRIVE24(3) <= '1' when clearClose(2)='1' else '0'; -- Aux 2 power enable
    --      
    --
    --   
    --===================================================  
    -- Status bits
    --=================================================== 
    stat32(0)  <= heatGo1;
    stat32(1)  <= heatGo2;
    stat32(7 downto 2)  <= opto_3_iso_out(0) & opto_1_iso_out(4 downto 0);
    stat32(8)  <= flow_alarm;
    stat32(9)  <= '0'; 
    stat32(10) <= spillFault;   -- spillFault_d;
    stat32(11) <= overTemp1;   -- overTemp1_d; 
    stat32(12) <= overTemp2;   -- overTemp2_d; 
    stat32(13) <= flow_fault;  -- flow_fault_d;
    stat32(14) <= sense24_reg; -- main24;
    -- bit 15, command summary, tells you if you were successful in turning on the main heater. does not look at aux heaters.
    stat32(15) <= clearClose(0); -- commandstat read back
--    stat32(16) <= spillFault;
--    stat32(17) <= overTemp1;
--    stat32(18) <= overTemp2;
--    stat32(19) <= flow_fault;
--    stat32(20) <= main24;   
    --stat32(26 downto 16) <= STD_LOGIC_VECTOR(fault_SM_counter(31 downto 21));--(others=>'0');
    --stat32(27) <= resetFaults_n;
    stat32(21 downto 16) <= faults(5 downto 0);
    stat32(27 downto 22) <= (others=>'0');    
    stat32(31 downto 28) <= fault_SM;
    --
    --
    --
	--===================================================
	-- Hardware Register Table to EPICS
	--===================================================
    -- A little different than the standard approach. Here, we have a large number of registers
    -- but not all will be shared with software. The main registers shared with SW/what will be
    -- on EPICS are known as the base HRT. The Full Memory Map is mostly for debug and may only
    -- be accessed via python scripts. The Base HRT is a selected mirror of the registers in the
    -- Full Memory Map
    --
	--== BASE HRT  
    process (clock, lb_valid)               
	begin                                                
		if clock'event and clock = '1' then
		  if lb_valid = '1' then
		      case lb_addr(7 downto 0) is
                  when "00000000" => lb_buffer_dump_SLOT0 <= stat32;
                  when "00000001" => lb_buffer_dump_SLOT0 <= x"00000" & psi_4_1;
                  when "00000010" => lb_buffer_dump_SLOT0 <= x"00000" & psi_4_2;
                  when "00000011" => lb_buffer_dump_SLOT0 <= x"00000" & psi_4_3;
                  when "00000100" => lb_buffer_dump_SLOT0 <= x"00000" & psi_4_4;
                  when "00000101" => lb_buffer_dump_SLOT0 <= x"00" & rtdS1_1; -- heater 1 outlet water temp (J1)
                  when "00000110" => lb_buffer_dump_SLOT0 <= x"00" & rtdS1_2; -- heater 1 cavity temp       (J2)
                  when "00000111" => lb_buffer_dump_SLOT0 <= x"00" & rtdS2_1; -- heater 2 outlet water temp (J3)
                  when "00001000" => lb_buffer_dump_SLOT0 <= x"00" & rtdS2_2; -- heater 2 cavity temp       (J4)
                  when "00001001" => lb_buffer_dump_SLOT0 <= set1;
                  when "00001010" => lb_buffer_dump_SLOT0 <= deadband1;
                  when "00001011" => lb_buffer_dump_SLOT0 <= set2;
                  when "00001100" => lb_buffer_dump_SLOT0 <= deadband2;
                  when "00001101" => lb_buffer_dump_SLOT0 <= x"00" & rtdS3_1; -- heater 1 overtemp (J5)
                  when "00001110" => lb_buffer_dump_SLOT0 <= x"00" & rtdS3_2; -- heater 2 overtemp (J6)
                  when "00001111" => lb_buffer_dump_SLOT0 <= clearClose; -- switch control
                  when "00010000" => lb_buffer_dump_SLOT0 <= saveRestore;
                  when "00010001" => lb_buffer_dump_SLOT0 <= maskFault;
                  when "00010010" => lb_buffer_dump_SLOT0 <= faults; -- bit5 is summary fault
                  when "00010011" => lb_buffer_dump_SLOT0 <= STD_LOGIC_VECTOR(error1);
                  when "00010100" => lb_buffer_dump_SLOT0 <= STD_LOGIC_VECTOR(error2);
                  when "00010101" => lb_buffer_dump_SLOT0 <= fw_ID; -- firmware ID
                  when "00010110" => lb_buffer_dump_SLOT0 <= pgain1; -- heater 1 proportional gain Q8.24
                  when "00010111" => lb_buffer_dump_SLOT0 <= igain1; -- heater 1 integral gain Q8.24
                  when "00011000" => lb_buffer_dump_SLOT0 <= onMin1; -- minimum on time (short cycle)
                  when "00011001" => lb_buffer_dump_SLOT0 <= maxPeriod1; -- maxPeriod that can be on
                  when "00011010" => lb_buffer_dump_SLOT0 <= timebase1; -- control loop timebase
                  when "00011011" => lb_buffer_dump_SLOT0 <= onPeriod1; -- readback, command pulse duration
                  when "00011100" => lb_buffer_dump_SLOT0 <= pgain2; -- heater 2 proportional gain Q8.24
                  when "00011101" => lb_buffer_dump_SLOT0 <= igain2; -- heater 2 integral gain Q8.24
                  when "00011110" => lb_buffer_dump_SLOT0 <= onMin2; -- minimum on time (short cycle)
                  when "00011111" => lb_buffer_dump_SLOT0 <= maxPeriod2; -- maxPeriod that can be on
                  when "00100000" => lb_buffer_dump_SLOT0 <= timebase2; -- control loop timebase
                  when "00100001" => lb_buffer_dump_SLOT0 <= onPeriod2; -- readback, command pulse duration
                  when "00100010" => lb_buffer_dump_SLOT0 <= driveOut1; -- tap into PICTRL.v to see drive vector for heater 1(32 bit)
                  when "00100011" => lb_buffer_dump_SLOT0 <= driveOut2; -- drive for heater 2
                  when "00100100" => lb_buffer_dump_SLOT0 <=counterSPI1; -- spi counter for heater 1
                  when "00100101" => lb_buffer_dump_SLOT0 <=counterSPI2; -- spi counter for heater 2
                  when others     => lb_buffer_dump_SLOT0 <= x"00000000";
		      end case;
		  end if;
		end if;	
	end process;
    --
	--== Full Memory Map
    process (clock, lb_valid)               
	begin                                                
		if clock'event and clock = '1' then
		  --if lb_valid = '1' then
		  lb_valid_bus <= lb_valid_bus(2 downto 0) & lb_rnw;
		  --
		  if lb_valid = '1' then
		      lb_addr_r <= lb_addr;
		  end if;
		end if;	
	end process;
    --
	process (clock)               
	begin                                                
		if clock'event and clock = '1' then
            case lb_addr_r(23 downto 8) is   
                 when  "0000000000000000"  => lb_rdata(31 downto 0) <= lb_buffer_dump_SLOT0;
                 when  "0000000000000001"  => lb_rdata(31 downto 0) <= lb_buffer_dump_SLOT1;
                 when  "0000000000000010"  => lb_rdata(31 downto 0) <= lb_buffer_dump_SLOT2;
                 when  "0000000000000011"  => lb_rdata(31 downto 0) <= lb_buffer_dump_SLOT3;
                 when  "0000000000000100"  => lb_rdata(31 downto 0) <= lb_buffer_dump_SLOT4;
                 when  "0000000000000101"  => lb_rdata(31 downto 0) <= lb_buffer_control_SLOT;
                 when  others              => lb_rdata(31 downto 0) <= x"facefeed";
            end case;
        end if;
	end process;
	
    -- ====================================================================================================
    -- BEGIN REGISTER MAP - write enables for R/W regs
    -- ====================================================================================================
    -- only the read/write registers need to be called out below.
    -- pay careful atention to the FULL address
    --
    -- 10/20/2025, for writes, we must also wait for the lb_valid to be HIGH before
    -- updating the internal HRT. Note, we don't do this for C10GX, maybe we should?
    rnw_valid <= '1' when lb_rnw = '0' and lb_valid = '1' else '0';
    --
    --set1_en <= '1' when lb_rnw = '0' and lb_addr(19 downto 0) = x"00009" else '0';
    set1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00009" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         set1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND set1_en='1') THEN 
         set1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS; 
    --
    deadband1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0000a" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         deadband1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND deadband1_en='1') THEN 
         deadband1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    set2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0000b" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         set2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND set2_en='1') THEN 
         set2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;  
    --
    deadband2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0000c" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         deadband2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND deadband2_en='1') THEN 
         deadband2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    clearClose_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0000f" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         clearClose<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND clearClose_en='1') THEN 
         clearClose(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    saveRestore_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00010" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         saveRestore<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND saveRestore_en='1') THEN 
         saveRestore(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    maskFault_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00011" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         maskFault<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND maskFault_en='1') THEN 
         maskFault(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    pgain1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00016" else '0';----------------heater 1
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         pgain1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND pgain1_en='1') THEN 
         pgain1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    igain1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00017" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         igain1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND igain1_en='1') THEN 
         igain1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    onMin1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00018" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         onMin1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND onMin1_en='1') THEN 
         onMin1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    maxPeriod1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00019" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         maxPeriod1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND maxPeriod1_en='1') THEN 
         maxPeriod1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    timebase1_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0001a" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         timebase1<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND timebase1_en='1') THEN 
         timebase1(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    pgain2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0001c" else '0';----------------heater 2
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         pgain2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND pgain2_en='1') THEN 
         pgain2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    igain2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0001d" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         igain2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND igain2_en='1') THEN 
         igain2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    onMin2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0001e" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         onMin2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND onMin2_en='1') THEN 
         onMin2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    maxPeriod2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"0001f" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         maxPeriod2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND maxPeriod2_en='1') THEN 
         maxPeriod2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    timebase2_en <= '1' when rnw_valid = '1' and lb_addr(19 downto 0) = x"00020" else '0';
    PROCESS(CLOCK,RESET_ALL) begin 
      IF(RESET_ALL='0') THEN 
         timebase2<=(others => '0'); 
      ELSIF (CLOCK'event AND CLOCK='1' AND timebase2_en='1') THEN 
         timebase2(31 downto 0) <=lb_wdata(31 downto 0); 
      END IF; 
    END PROCESS;
    --
    -- ====================================================================================================
    -- END OF REGISTER MAP 
    -- ====================================================================================================
    
    --===================================================
    -- FMC Bus Voltage Init
    --===================================================
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
    
    -- set resistor network for 3.3v
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
--
--
--
END cbh20_arch;