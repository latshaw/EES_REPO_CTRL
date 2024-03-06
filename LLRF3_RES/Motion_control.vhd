-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"
-- CREATED		"Mon Jul 13 14:00:17 2020"

--Latshaw, used quartus tools to convert BDF to vhdl file (very messy and verbose).
--I had to go through and hand wire the below. Note this is intended to be a TOP module.


-- LEAVING OFF FOR LLRF 3.0
--		next step, will need to work with FCC to send 'real' disc and detune angles to ensure that the values are recieved
--		at the stepper. (could verify with signal tap, though i would prefer to see steppers move)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;

ENTITY Motion_control IS 
	generic (testBench : STD_LOGIC := '0');-- 1 to use as test bench, 0 otherwise
	PORT
	(
		--CLOCK_IN  : in  STD_LOGIC; -- 100 MHz (may need to change to 80 MHz with PLL), c10_CLKUSR, PIN_AC13
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
		
		-- use only for testing with test bench (testBench = 1)
		addr_tb	: in  STD_LOGIC_VECTOR(23 downto 0);
		rnw_tb	: in  STD_LOGIC;
		din_tb 	: in  STD_LOGIC_VECTOR(31 downto 0);
		dout_tb 	: out STD_LOGIC_VECTOR(31 downto 0);
		
		-- ADC Signals
		ADC_DOUT : out std_logic;
		ADC_DIN  : in std_logic;
		ADC_CS   : out std_logic;
		ADC_SCLK : out std_logic;
		
		--LED Interface (front panel)
		LED_SDA : inout std_logic;
		LED_SCL : out std_logic;
		
		--Temp Sensor Interface
		OE_CONT1    : out std_logic;
		OE_CONT1_1  : out std_logic;
		SDA_M1      : inout std_logic;
		SDA_M1_1    : inout std_logic;
		DIR_CONT1   : out std_logic;
		DIR_CONT1_1 : out std_logic;
		-- For older temperature sensor
		--TEMP_SI :  IN  STD_LOGIC; --input to TEMP Sensor
		--TEMP_SC :  OUT  STD_LOGIC; -- output from TEMP Sensor,    ***** replace with new I2C temp sensor info
		--TEMP_CS :  OUT  STD_LOGIC; -- output from TEMP Sensor
		
		-- EEPROM interface
		GA1      : out std_logic;
		GA0      : out std_logic;
		FMC2_SDA : inout std_logic;
		FMC2_SCL : out std_logic;
		SCLM1    : inout std_logic;
		SCLM1_1  : inout std_logic;
		
		-- FCC fiber interface
		--		DETUNE_ANGLE :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0); -- Fibers
		FIBER_1 : in std_logic;
		FIBER_2 : in std_logic;
		FIBER_3 : in std_logic;
		FIBER_4 : in std_logic;
		FIBER_5 : in std_logic;
		FIBER_6 : in std_logic;
		FIBER_7 : in std_logic;
		FIBER_8 : in std_logic;
		
		-- Physical Limit Switch interface (HI is limit hit)
		HFLF1   :  in  STD_LOGIC;
		HFLF2   :  in  STD_LOGIC;
		HFLF3   :  in  STD_LOGIC;
		HFLF4   :  in  STD_LOGIC;
		HFLF1_1 :  in  STD_LOGIC;
		HFLF2_1 :  in  STD_LOGIC;
		HFLF3_1 :  in  STD_LOGIC;
		HFLF4_1 :  in  STD_LOGIC;
		LFLF1   :  in  STD_LOGIC;
		LFLF2   :  in  STD_LOGIC;
		LFLF3   :  in  STD_LOGIC;
		LFLF4   :  in  STD_LOGIC;
		LFLF1_1 :  in  STD_LOGIC;
		LFLF2_1 :  in  STD_LOGIC;
		LFLF3_1 :  in  STD_LOGIC;
		LFLF4_1 :  in  STD_LOGIC;

		-- Direciton and Step settings
		--		DIR = HI  -> CW rotation  (toward high limit)
		--		DIR = LOW -> CCW rotation (toward low limit)
		DIR1    :  out  STD_LOGIC;
		STEP1   :  out  STD_LOGIC;
		DIR2    :  out  STD_LOGIC;
		STEP2   :  out  STD_LOGIC;
		DIR3    :  out  STD_LOGIC;
		STEP3   :  out  STD_LOGIC;
		DIR4    :  out  STD_LOGIC;
		STEP4   :  out  STD_LOGIC;
		DIR1_1  :  out  STD_LOGIC;
		STEP1_1 :  out  STD_LOGIC;
		DIR2_1  :  out  STD_LOGIC;
		STEP2_1 :  out  STD_LOGIC;
		DIR3_1  :  out  STD_LOGIC;
		STEP3_1 :  out  STD_LOGIC;
		DIR4_1  :  out  STD_LOGIC;
		STEP4_1 :  out  STD_LOGIC;
		
		-- Stepper SPI dataout (not used, keep for future use)
		SDO1   : in std_logic;
		SDO2   : in std_logic;
		SDO3   : in std_logic;
		SDO4   : in std_logic;
		SDO1_1 : in std_logic;
		SDO2_1 : in std_logic;
		SDO3_1 : in std_logic;
		SDO4_1 : in std_logic;
		
		-- Stepper Chip Select (allows SPI communication)
		CSN1   : out std_logic;
		CSN2   : out std_logic;
		CSN3   : out std_logic;
		CSN4   : out std_logic;
		CSN1_1 : out std_logic;
		CSN2_1 : out std_logic;
		CSN3_1 : out std_logic;
		CSN4_1 : out std_logic;
		
		-- Input SPI data to stepper
		SDI1   : out std_logic;
		SDI2   : out std_logic;
		SDI3   : out std_logic;
		SDI4   : out std_logic;
		SDI1_1 : out std_logic;
		SDI2_1 : out std_logic;
		SDI3_1 : out std_logic;
		SDI4_1 : out std_logic;
		
		-- Slow SCLK for stepper SPI
		SCLK1   : out std_logic;
		SCLK2   : out std_logic;
		SCLK3   : out std_logic;
		SCLK4   : out std_logic;
		SCLK1_1 : out std_logic;
		SCLK2_1 : out std_logic;
		SCLK3_1 : out std_logic;
		SCLK4_1 : out std_logic;
		
		-- Allows stepper motor to free wheel when HI
		EN1   : out std_logic;
		EN2   : out std_logic;
		EN3   : out std_logic;
		EN4   : out std_logic;
		EN1_1 : out std_logic;
		EN2_1 : out std_logic;
		EN3_1 : out std_logic;
		EN4_1 : out std_logic;
		
		hb_fpga    :  out  STD_LOGIC; -- FPGA heart beat LED
		gpio_led_1 :  out  STD_LOGIC; -- HEART_BEAT LED
		gpio_led_2 :  out std_logic;  -- heart beat ioc
		gpio_led_3 :  out std_logic	
	);
END Motion_control;

ARCHITECTURE bdf_type OF Motion_control IS 

-- temp sensor on cyclone 10
component fpga_tsd_int is
	port (
		corectl : in  std_logic                    := 'X'; -- corectl
		reset   : in  std_logic                    := 'X'; -- reset
		tempout : out std_logic_vector(9 downto 0);        -- tempout
		eoc     : out std_logic                            -- eoc
	);
end component fpga_tsd_int;	

COMPONENT resets
	PORT(clock    : IN STD_LOGIC;
		 brd_reset : IN STD_LOGIC; -- reset, from top module (hard interface)
		 isa_reset : IN STD_LOGIC; -- ISA_RESET, from top module (hard interface)
		 reg_reset : IN STD_LOGIC; -- from register block (EPICS reset)
		 reset     : OUT STD_LOGIC -- RESET_all, to all resetable components
	);
END COMPONENT;

COMPONENT heartbeat_isa
	PORT(clock : IN STD_LOGIC;
		 reset  : IN STD_LOGIC;
		 LED    : OUT STD_LOGIC -- goes to heartbeat_sig on regs
	);
END COMPONENT;

COMPONENT heartbeat
	PORT(clock : IN STD_LOGIC;
		 reset  : IN STD_LOGIC;
		 LED    : OUT STD_LOGIC -- goes to output gpio_led_1
	);
END COMPONENT;

COMPONENT heartbeat_fp
	PORT(clock : IN STD_LOGIC;
		 reset  : IN STD_LOGIC;
		 isa_oe : IN STD_LOGIC;  -- ISA_SD_DIR_sig, from ISA_BUS_MODULE
 		 hb_dig : OUT STD_LOGIC; -- goes to output hb_fpga (LED)
		 hb_ioc : OUT STD_LOGIC  -- goes to output gpio_led_2  (LED)
	);
END COMPONENT;

COMPONENT data_select
	PORT(DIR      : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR
		 DIR_FIB   : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR_FIB
		 DONE      : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE
		 DONE_FIB  : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE_FIB
		 FIB_MODE  : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- FIB_MODE
		 MOVE      : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- MOVE
		 MOVE_FIB  : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- MOVE_FIB
		 STEPS     : IN reg32_array; -- STEPS, from regs
		 STEPS_FIB : IN reg32_array; -- STEPS_FIB, from fcc_data_acq_fiber_control
		 DIR_OUT   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR_OUT, to stepper_driver
		 DONE_OUT  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE_OUT, to stepper_driver
		 MOVE_OUT  : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- MOVE_OUT, to stepper_driver
		 STEPS_OUT : OUT reg32_array --STEPS_OUT, to stepper_driver
	);
END COMPONENT;

COMPONENT fcc_data_acq_fiber_control
	PORT(CLOCK       : IN STD_LOGIC;
		 RESET        : IN STD_LOGIC; -- RESET_ALL
		 deta_disc_regs : OUT reg2_array; -- added 3/31/21, will go to motor_status in regs
		 step_en        : OUT STD_LOGIC_VECTOR(7 downto 0); -- added 3/31/21, will go to motor_status in regs
		 DETA_HI      : IN reg16_array; -- DETA_HI, from regs
		 DETA_LO      : IN reg16_array; -- DETA_LO, from regs
		 DISC_HI      : IN reg16_array; -- DISC_HI, from regs
		 DISC_LO      : IN reg16_array; -- DISC_LO, from regs
		 DONE_MOVE    : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE_MOVE, from steppers
		 FIB_MODE     : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- FIB_MODE_IN, from regs
		 FIBER_IN     : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --DETUNE_ANGLE, input form top module (pins connect to fiber board)
		 PZT_HI       : IN reg16_array; -- PZT_HI, from regs
		 PZT_LO       : IN reg16_array; -- PZT_LO, from regs
		 STEP_HZ      : IN reg32_array; -- STEP_HZ, from regs
		 STOP         : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- STOP, from regs
		 DETA         : OUT reg16_array; -- DETA, to regs
		 DIRECTION    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR_FIB, to DATA_SELECT
		 DISC         : OUT reg28_array; -- DISC, to regs
		 DONE_ISA     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE_FIB, to DATA_SELECT
		 FIB_MODE_OUT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); --FIB_MODE, to DATA_SELECT
		 MOVE         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- MOVE_FIB, to DATA_SELECT
		 PZ           : OUT reg16_array; -- PZ, to regs
		 SLOW_MODE    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- SLOW_MODE, to regs
		 STEPS        : OUT reg32_array -- STEPS_FIB, to DATA_SELECT
	);
END COMPONENT;

COMPONENT regs
	PORT(heartbeat    : IN STD_LOGIC;   -- heartbeat_sig, form heartbeat_isa
		 clock         : IN STD_LOGIC;
		 reset         : IN STD_LOGIC;
		 load          : IN STD_LOGIC;   -- REGS_LD, from ISA_BUS Module OR not(lb_rnw) from udp module
		 epcs_bsy      : IN STD_LOGIC;   -- <NO CONNCECT>
		 abs_steps     : IN reg32_array; -- abs_steps from steppers
		 addr          : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ADDR_OUT (only use lower 9 bits), from ISA_BUS OR lb_addr of udp module (note, lb_addr is 24 bits)
		 brd_tmp       : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- TEMP_DATA (from temp sensor)
		 deta_disc     : IN reg2_array;                    -- 3/31/21, connected (controlled by motor_status register)
		 din           : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- ISA_SD, to ISA_BUS Module & top module (inout) OR lb_wdata of udp module
		 disc_fib      : IN reg28_array;                   -- DISC, from fcc_data_acq_fiber_control
		 done_move     : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- DONE_MOVE, from steppers and FCC_data_acq_fiber_control
		 dtan_fib      : IN reg16_array;                   -- DETA, from fcc_data_acq_fiber_control
		 epcsr         : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- <NO CONNCECT>
		 high_limit_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- high_limit_in, from module inputs (limit switches)
		 laccel        : IN reg32_array;                   -- laccel, from steppers
		 ldir          : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- ldir, from steppers
		 low_limit_in  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- low_limit_in, from module inputs (limit switches)
		 lsteps        : IN reg32_array;                   -- lsteps, from steppers
		 lvlcty        : IN reg32_array;                   -- lvlcty, from steppers
		 motion        : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- motion, from steppers
		 pzt_val       : IN reg16_array;                   -- PZ, from fcc_data_acq_fiber_control
		 sgn_steps     : IN reg32_array;                   -- sgn_steps, from steppers
		 slow_gdr      : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- SLOW_MODE, from fcc_data_acq_fiber_control
		 step_count    : IN reg32_array;                   -- step_count, from steppers
		 step_en       : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- 3/31/21, connected (controlled by motor_status register)
		 clear         : OUT STD_LOGIC;                    -- reg_res, to resets
		 reconfig      : OUT STD_LOGIC;                    -- <NO CONNCECT>
		 abs_stp_sub   : OUT reg16_array;                  -- abs_stp_sub, to steppers
		 accel         : OUT reg32_array;                  -- accel, to steppers
		 clr_abs_stp   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- clr_abs_stp, to steppers
		 clr_sgn_stp   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- clr_sgn_stp, to steppers
		 deta_hi       : OUT reg16_array;                  -- DETA_HI, to fcc_data_acq_fiber_control
		 deta_lo       : OUT reg16_array;                  -- DETA_LO, to fcc_data_acq_fiber_control
		 dir           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR, to DATA_SELECT
		 dir_flip      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 disc_hi       : OUT reg16_array;                  -- DISC_HI, to fcc_data_acq_fiber_control 
		 disc_lo       : OUT reg16_array;                  -- DISC_LO to fcc_data_acq_fiber_control
		 done_out      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE, to DATA_SELECT
		 dout          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);-- to REGS_D of ISA_BUS Module OR lb_rdata of udp module
		 en_sub_abs    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- en_sub_abs to steppers 
		 en_sub_sgn    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- en_sub_sgn to steppers
		 epcsa         : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);-- <NO CONNCECT>
		 epcsc         : OUT STD_LOGIC_VECTOR(3 DOWNTO 0); -- <NO CONNCECT>
		 epcsd         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- <NO CONNCECT>
		 fib_mode      : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- FIB_MODE_IN, to fcc_data_acq_fiber_control
		 inhibit       : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- inhibit, enable pins (for steppers)
		 limit         : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- limit, to LEDS (for limit switches)
		 low_current   : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- low_current, low current pins (for steppers)
		 move          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- MOVE, to DATA_SELECT
		 pzt_hi_lmt    : OUT reg16_array;                  -- PZT_HI, to fcc_data_acq_fiber_control
		 pzt_lo_lmt    : OUT reg16_array;                  -- PZT_LO, to fcc_data_acq_fiber_control
		 motorCurr_OUT : out reg16_array;                  -- TMC Current Sense (only lower 5 bits are used)
		 CHOPCONF_OUT  : out reg16_array;						-- chooper configuration, added 10/28/22
		 MRES_OUT		: out reg16_array;					   -- microstep resolution, added 10/18/22
		 step_hz       : OUT reg32_array;                  -- STEP_HZ, to fcc_data_acq_fiber_control
		 steps         : OUT reg32_array;                  -- STEPS, to DATA_SELECT
		 stop          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- STOP, to fcc_data_acq_fiber_control and steppers
		 vlcty         : OUT reg32_array;                  -- vlcty, to steppers
		 c10gx_tmp		: IN 	STD_LOGIC_VECTOR(9 downto 0);  -- internal fpga temp, goes to regs module
		 out_EEPROM_ctrl   : OUT STD_LOGIC_VECTOR(7 downto 0);  -- bit1 = RNW, bit0 = go
		 out_EEPROM_addr   : OUT STD_LOGIC_VECTOR(11 downto 0); -- 12 bit read address
		 out_EEPROM_data   : OUT STD_LOGIC_VECTOR(7 downto 0);  -- data to write to byte
		 EEPROM_datar  : IN  STD_LOGIC_VECTOR(7 downto 0);    -- data read from byte
		 out_sfp_dataw		 : OUT STD_LOGIC_VECTOR(31 downto 0); -- output from REGS to i2c module
		 sfp_datar		    : IN STD_LOGIC_VECTOR(31 downto 0);  --input from i2c module
		 out_sfp_ctrl   	 : OUT STD_LOGIC_VECTOR(31 downto 0); -- output from REGS to i2c module
		 lb_valid		    : IN STD_LOGIC;
		 rate_reg          : reg32_array
--		 out_c_addr		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_cntlr	    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_status        : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_data		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_datar	       : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_en_c_data	    : OUT std_logic
		 );
END COMPONENT;

COMPONENT stepper_driver
	generic (testBench : STD_LOGIC := '0');
	PORT(reset         : IN STD_LOGIC;
		 clock          : IN STD_LOGIC;
		 direction      : IN STD_LOGIC; -- DIR_OUT, from data_select
		 dir_flip		 : IN STD_LOGIC; -- flips direction input
		 move           : IN STD_LOGIC; -- MOVE_OUT, from data_select
		 done_isa       : IN STD_LOGIC; -- DONE_OUT, from data_select
		 stop           : IN STD_LOGIC; -- STOP, from regs
		 clr_sgn_step   : IN STD_LOGIC; -- clr_sgn_stp, from regs
		 clr_abs_step   : IN STD_LOGIC; -- clr_abs_stp, from regs
		 en_sub_abs     : IN STD_LOGIC; -- en_sub_abs, from regs
		 en_sub_sgn     : IN STD_LOGIC; -- en_sub_sgn, from regs
		 accel_in       : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- accel, from regs
		 period         : IN STD_LOGIC_VECTOR(26 DOWNTO 0); -- quotient(I), from step_gen generate
		 steps_in       : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- STEPS_OUT, from data_select
		 sub_stp        : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- abs_stp_sub, from regs
		 vlcty_in       : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- vlcty, from regs
		 spi_hs_in      : IN STD_LOGIC; -- SPI updated handshake in
	    spi_hs_out     : OUT STD_LOGIC; -- SPI updated handshake out
		 step           : OUT STD_LOGIC; -- step_buffer (to board outputs)
		 dir            : OUT STD_LOGIC; -- ldir (to board output and regs)
		 motion_led     : OUT STD_LOGIC; -- motion (to board output and regs
		 done_move      : OUT STD_LOGIC; -- DONE_MOVE to regs and fcc_data_acq_fiber_control
		 abs_step       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- abs_steps, to regs
		 accum_NA       : OUT STD_LOGIC_VECTOR(12 DOWNTO 0); -- denom(I), to step_gen generate
		 clkrate_NA     : OUT STD_LOGIC_VECTOR(26 DOWNTO 0); -- numer(I), to step_gen generate
		 laccel         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- laccel, to regs
		 lsteps         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- lsteps, to regs
		 lvlcty         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- lvlcty, to regs
		 sgn_step       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- sgn_steps, to regs
		 step_count_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- step_count, to regs
		 rate_reg       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;
--
-- NOTE: DIR = 0 -> CCW (low end, low limit), DIR = 1 -> CW rotation (high end, high limit)
--
--			INHIBIT is HI  = motor in free-wheel (no output current, inhibited)
--			INHIBIT is LOW	= motor energized
--
COMPONENT TMC2660 IS -- use to configure SPI of each stepper
	PORT(CLOCK       : IN STD_LOGIC;
		 RESET        : IN STD_LOGIC;
		 CHOPCONF_IN  : IN STD_LOGIC_VECTOR(15 downto 0); -- Chopper configuration data
		 MRES         : IN STD_LOGIC_VECTOR(3 downto 0); -- specify microstep resolution
		 DRVI         : IN STD_LOGIC_VECTOR(4 DOWNTO 0); -- specify current scale (see motorCurr_OUT from regs)
		 DRVI_CONFIG  : IN STD_LOGIC;  -- 1 = use DRVI as specified current scale, 0 = set current scale to lowest (0000)
		 START_CONFIG : IN STD_LOGIC;  -- set HI to start state machine
		 SDO          : IN STD_LOGIC;	 -- SDO is (not used)
		 INHIBIT      : IN STD_LOGIC;  -- Hi to free-wheel motor, LOW to energize
		 CSN          : OUT STD_LOGIC; -- spi chip select
		 SCK          : OUT STD_LOGIC; -- spi sclk
		 SDI          : OUT STD_LOGIC; -- spi data in
		 SEN          : OUT STD_LOGIC; -- loops back INHIBIT, active low
		 CONFIG_DONE  : OUT STD_LOGIC
		 );
END COMPONENT;

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

component RAM_2_PORT is
		port (
			data_a    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- datain_a
			q_a       : out std_logic_vector(31 downto 0);                    -- dataout_a
			data_b    : in  std_logic_vector(31 downto 0) := (others => 'X'); -- datain_b
			q_b       : out std_logic_vector(31 downto 0);                    -- dataout_b
			address_a : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- address_a
			address_b : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- address_b
			wren_a    : in  std_logic                     := 'X';             -- wren_a
			wren_b    : in  std_logic                     := 'X';             -- wren_b
			clock     : in  std_logic                     := 'X'              -- clk
		);
	end component RAM_2_PORT;

-- fifo for udp_com module
-- needed because we are crossing clock domains (125 MHz to 100 MHz)
--component FIFO is
--		port (
--			data    : in  std_logic_vector(56 downto 0) := (others => 'X'); -- datain
--			wrreq   : in  std_logic                     := 'X';             -- wrreq
--			rdreq   : in  std_logic                     := 'X';             -- rdreq
--			wrclk   : in  std_logic                     := 'X';             -- wrclk
--			rdclk   : in  std_logic                     := 'X';             -- rdclk
--			q       : out std_logic_vector(56 downto 0);                    -- dataout
--			rdempty : out std_logic;                                        -- rdempty
--			wrfull  : out std_logic                                         -- wrfull
--		);
--	end component FIFO;

---- I2C module for LEDs
--component gen_i2c IS
--	generic (testBench : STD_LOGIC := '0');
--	PORT
--	(	
--		clock     : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
--		reset_n   : IN  	STD_LOGIC; -- active low reset
--		EN			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
--		ADDR 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address
--		RW			 : IN  	STD_LOGIC; -- read/write, read = HI, writes = LOW
--		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); -- input data, lsByte sent first
--		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0); -- read data (leave OPEN if not used)
--		P_width 	 : IN  	STD_LOGIC_VECTOR(1 downto 0); --Choose how many bytes to transmit
--		S_ACK		 : OUT 	STD_LOGIC; -- Status for ack, HI= ack recieved, LO = no ack
--		SCL 		 : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz)
--		SDA 		 : INOUT STD_LOGIC  -- data line (data is bi directional)
--	);
--END component;

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

-- for temp sensor
component ADT_CONTROL IS
	generic (testBench : STD_LOGIC := '0'); 
	PORT
	(	
		clock      : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n    : IN  	STD_LOGIC; -- active low reset
		TEMP_DATA  : OUT  STD_LOGIC_VECTOR(15 downto 0); -- upper LED on front panel
		OE_CONT1   : OUT  STD_LOGIC;
		DIR_CONT1  : OUT  STD_LOGIC;
		SCL 		  : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
		SDA 		  : INOUT STD_LOGIC -- data line (data is bi directional), LED_SDA
	);
END component;

-- PLL
component PLL_main is
	port (
		rst      : in  std_logic := 'X'; -- reset
		refclk   : in  std_logic := 'X'; -- clk, input 100 MHZ
		outclk_0 : out std_logic;        -- clk, 100 MHZ
		outclk_1 : out std_logic         -- clk, 50 MHZ
	);
end component PLL_main;
--
component PLL_125_to_50 is
	port (
		rst      : in  std_logic := 'X'; -- reset
		refclk   : in  std_logic := 'X'; -- clk
		locked   : out std_logic;        -- export
		outclk_0 : out std_logic         -- clk
	);
end component PLL_125_to_50;
--
-- for accessing the EEPROM
COMPONENT EEPROM_CONTROL IS
	PORT
	(	
		clock      		: IN		STD_LOGIC; -- input clock (assumed 125 MHz)
		reset_n    		: IN		STD_LOGIC; -- active low reset
		EEPROM_RNW		: IN 		STD_LOGIC; -- Read Not Write for eeprom address
		EEPROM_go		: IN		STD_LOGIC; -- go, or begin process
		EEPROM_STAT	 	: OUT 	STD_LOGIC_VECTOR(2 downto 0); -- idc_ack & EEPROM_DIR & i2c_rdy
		EEPROM_ADDR		: IN 		STD_LOGIC_VECTOR(11 downto 0); -- address of EEPROM, max is 32k bit (we read 1 byte at each address)
		EEPROM_DATA		: IN 		STD_LOGIC_VECTOR(7 downto 0); -- Data to write to EEPROM
		EEPROM_DATAR	: OUT 	STD_LOGIC_VECTOR(7 downto 0); -- Data read from EEPROM
		EEPROM_SCL 		: OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
		EEPROM_SDA 		: INOUT 	STD_LOGIC -- data line (data is bi directional), LED_SDA
	);
END COMPONENT;
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
--


--declare signals
signal c10gx_tmp, c10gx_tmp_buffer	, tempb1, tempb2	:	std_logic_vector(9 downto 0);
signal temp_eoc1, temp_eoc2, temp_eoc3 : STD_LOGIC;
--
-- i2c expander setup done (for configuring the SFP module)
signal sfp_config_done0 : STD_LOGIC;
--
signal reg_res, RESET_all, heartbeat_sig, REGS_LD, ISA_SD_DIR_sig, ISA_RESET, ISA_SD_DIR  : STD_LOGIC;
--
signal dir_flip, DIR, DIR_FIB, DONE, DONE_FIB, DIR_OUT, DONE_OUT, MOVE, MOVE_OUT, DONE_MOVE, FIB_MODE, FIB_MODE_IN, STOP, high_limit_in,
       ldir, motion, clr_abs_stp, clr_sgn_stp, en_sub_abs, en_sub_sgn, inhibit, limit, low_current, step_buffer, MOVE_FIB,
		 SLOW_MODE, low_limit_in, SPI_CONFIG, SDO_IN, crash, CSN, SDI, SCK, SEN, CONFIG_DONE, DETUNE_ANGLE, SPI_HS_IN, SPI_HS_OUT : STD_LOGIC_VECTOR(7 downto 0);
--
-- LED control (front panel)
signal LED_TOP, LED_BOTTOM : STD_LOGIC_VECTOR(7 downto 0) := x"00";
-- LED signals for I2C module
signal ADDR_LED : STD_LOGIC_VECTOR(6 downto 0);
signal DATA_LED : STD_LOGIC_VECTOR(23 downto 0);
signal EN_LED   : STD_LOGIC;
--
signal TEMP_DATA, TEMP_DATA_buff1, TEMP_DATA_buff2, REGS_D, ISA_SD :STD_LOGIC_VECTOR(15 downto 0);
--
signal dout : STD_LOGIC_VECTOR(31 downto 0);
--
signal ADDR_OUT : STD_LOGIC_VECTOR(19 downto 0); -- only lower 10 bits are used (9 downto 0)
--
signal denom : reg13_array; --for stepper generate statement
--
signal DETA_HI, DETA_LO, DISC_HI, DISC_LO, PZT_HI, PZT_LO, MOTOR_CURR, DETA, PZ, abs_stp_sub, MRES, CHOPCONF : reg16_array;
--
signal numer, quotient : reg27_array; -- for stepper generate statement
--
signal DISC : reg28_array;
--
 -- added 3/31/21, will go to motor_status in regs
signal deta_disc_regs :  reg2_array;
signal step_en        :  STD_LOGIC_VECTOR(7 downto 0);
--
signal STEPS, STEPS_FIB, STEPS_OUT, STEP_HZ, abs_steps, laccel, lsteps, lvlcty, sgn_steps, step_count, accel, vlcty, rate_reg : reg32_array;
--
-- udp signals
-- 125 Mhz signals
signal lb_rnw_fast, lb_valid 	: STD_LOGIC; -- lb_valid_fast
signal lb_addr_fast	: STD_LOGIC_VECTOR(23 downto 0);
signal lb_wdata_fast, lb_rdata_fast :STD_LOGIC_VECTOR(31 downto 0);
-- 100 Mhz signals
signal lb_rnw 	: STD_LOGIC;
signal lb_addr	: STD_LOGIC_VECTOR(23 downto 0);
signal lb_wdata, lb_rdata :STD_LOGIC_VECTOR(31 downto 0);
signal udp_blink  : STD_LOGIC; -- fast indicator when a new address is read

-- lb_rdata syn signal
signal ram_fast_q_2, lb_rdata_SYN :STD_LOGIC_VECTOR(31 downto 0);

--muxed fast signals
signal lb_rnw_100, lb_rnw_100_D, lb_rnw_100_Q, lb_rnw_125, lb_rnw_reg	 : STD_LOGIC;
signal lb_addr_SM, lb_addr_SM_D, lb_addr_SM_Q, lb_addr_reg 	 : STD_LOGIC_VECTOR(23 downto 0);
signal lb_wdata_D, lb_wdata_Q, lb_wdata_reg, lb_rdata_reg :STD_LOGIC_VECTOR(31 downto 0);

-- mux control for sync
signal rnw_syn_mux, addr_syn_mux, wdata_syn_mux : STD_LOGIC;

-- mux controlf for reg
signal rnw_reg_mux, addr_reg_mux, rdata_reg_mux : STD_LOGIC;

-- state machine for sync
signal state_SM : STD_LOGIC_VECTOR(3 downto 0);

--
-- fifo signals
signal data, data_q : STD_LOGIC_VECTOR(56 downto 0);
signal wrreq, rdreq, rdempty, wrfull : STD_LOGIC;

--
-- Signals to help MODELSIM compile
signal addr_buffer		: STD_LOGIC_VECTOR(31 downto 0);
signal not_rnw				: STD_LOGIC;
signal count_FULL, count_Half 	: STD_LOGIC_VECTOR(31 downto 0);
--
signal CLOCK, clk_50, clk_100, altclk_clock, PLL_reset, PLL_125_to_50_locked, PLL_125_to_50_raw, udp_ioc : STD_LOGIC;
--
-- signals for 32 kbit EEPROM
signal EEPROM_ctrl : STD_LOGIC_VECTOR(7 downto 0);
signal EEPROM_addr    : STD_LOGIC_VECTOR(11 downto 0);
signal EEPROM_data, EEPROM_datar : STD_LOGIC_VECTOR(7 downto 0);
--
-- Cylone remote configuration/update signals (from regs module to inst_cyclone)
SIGNAL c_addr		: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c_cntlr		: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c10_status : std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c_data		: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL c10_datar	: std_logic_VECTOR(31 DOWNTO 0);
SIGNAL en_c_data	: std_logic; -- note, this is intended to capture the enable strobe when the c_data signal is written by the udp_com module
--
-- SFP i2C signals
signal sfp_dataw, sfp_datar, sfp_ctrl  :  std_logic_VECTOR(31 DOWNTO 0);
--
-- internal temperature sensore end of fetching the temp. (falling edge)
SIGNAL fpga_tsd_int_EOC_n : STD_LOGIC;
--
-- for buffering across clock domains 
--	(temp senor, 1Mhz to 125 Mhz)
--TYPE mem_2k IS ARRAY(0 TO 127) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
--	SIGNAL ram_block : mem_2k; 
--	attribute ramstyle : string;
--	attribute ramstyle of ram_block : signal is "M20K";
	
	
--
BEGIN 
-- ================================================================
-- MARVEL PHY INIT
-- ================================================================
-- 3/6/2024


marvell_phy_config_inst : marvell_phy_config
	PORT MAP(
			clock	      => clock,
			reset	      => RESET_all,
			phy_resetn	=> ETH1_RESET_N,
			mdio	      => eth_mdio,
			mdc		   => eth_mdc,
			config_done	=>  open);
			
--===================================================
-- PLL and Clock
--===================================================
--
PLL_reset <= NOT(RESET_all);
-- reset SGMII/Marvel chip during FPGA reset.
-- will hold in reset for minimum of 8 clock cycles (64 ns)
--ETH1_RESET_N <= RESET_all; 

--
-- 3/12/21, switched to using 125 Mhz as global clock to see if C10GX  has a sufficient speed grade
--
--CLOCK <= sfp_refclk_p; 3/19/21, switch to lb_clk from udp_com module, also 125 Mhz but it goes through additional PLL/buffers and accounts for FIFO phase delay
--===================================================
-- Reset Control
--===================================================

reset_control : resets
PORT MAP(clock, reset, ISA_RESET, reg_res, RESET_all);
-- dummy isa_reset, eventually replace this with SFP reset
ISA_RESET <= '0'; -- note, this reset actually isn't used in the module...
--
--===================================================
-- Heartbeat(s)                                          ** Need to remove referecnes to ISA_BUS (no longer used). r these just for leds? maybe update...
--===================================================
--
-- changed from heartbeat module, periodic blinking (seems redundant)
HB_FP : heartbeat_isa
PORT MAP(clock, RESET_all, gpio_led_1);
HB_ISA : heartbeat_isa 
PORT MAP(clock, RESET_all, heartbeat_sig);
--
-- UDP communication heartbeat
HB_HB : heartbeat_fp
PORT MAP(clock, RESET_all, udp_blink, hb_fpga, udp_ioc);
--
gpio_led_2 <= udp_ioc;
-- 
-- simple process to watch for address change and strobe the udp_blink signal.
-- Goal is to catch a 'burst' of udp packets and provide a visual indicator.
--
-- this process also introduces a 'fade' in which it will keep the led blink light on.
-- if no packets are being sent, led will be off, if a burse of packets are sent, led 
-- will appear on. if just seveal packets are sent, the led will blink on but you won't notice it.
-- 3/12/21 modified to watch for lb_valid strobe
process (clock, RESET_all)
	variable counter      : UNSIGNED(3 downto 0) := x"0";
begin
	if (RESET_all = '0') then
		counter   := x"0";
		udp_blink <= '0';
	elsif clock'event and clock = '1' then
		-- watch for new udp packet
		if   (lb_valid='1') then
			-- reset counter and signal the HB_HB module to 'blink' the udp com heartbeat
			counter := x"0";
			udp_blink <= '1';
		elsif (counter < x"F") then
			-- keep the pulse hi for the duration of the counter (min 2 clock cycles)
			counter := counter + 1;
			udp_blink <= '1';
		else
			-- keep udp blink indicator off until the next packet
			counter := x"F";
			udp_blink <= '0';
		end if;
		--
	end if;
end process;
--
--===================================================
-- Ethernet Communication Module from Berkeley (with test bench option)
--===================================================
--
-- If we are not in test bench mode, incorporate udp module
-- marvel chip signals are SGMII1<>
-- SFP chip signals are sfp_<>
--
	genUDP : if testBench = '0' generate
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
					sfp_dataw	   => sfp_dataw,
					sfp_datar	   => sfp_datar,
					sfp_ctrl       => sfp_ctrl,   	
					sfp_config_done0 => sfp_config_done0 -- tca i2c expander chip is done
					);
	--
	-- 
	gpio_led_3 <= sfp_config_done0;-- when CLOCK_IN = '1' else '0';--lb_valid; -- LED should appear on if receiving data				
	--
	-- this signal is only needed for the test bench.
	-- the compiler should optimize this signal away
	dout_tb <= (others =>'Z');
	--
	end generate genUDP;
--
-- If we are in test bench mode, we will assign address, rnw and data
-- from the test bench.
	genTB : if testBench = '1' generate
		lb_addr 	<= addr_tb;  -- input from TB
		lb_rnw 	<= rnw_tb;	 -- input from TB
		lb_wdata <= din_tb;	 -- input from TB
		dout_tb	<= lb_rdata; -- output to TB
	end generate genTB;
--
--===================================================
-- DATA SELECT
--===================================================
--
b2v_inst26 : data_select
PORT MAP(DIR, DIR_FIB, DONE, DONE_FIB, FIB_MODE, MOVE, MOVE_FIB, STEPS, STEPS_FIB, DIR_OUT, DONE_OUT, MOVE_OUT, STEPS_OUT );
--
--===================================================
-- FCC DATA ACQ FIBER CONTROL
--=================================================== ******************** will need to update counter for 125 Mhz period (notes in module) ****************
--
-- Fiber data from FCC
DETUNE_ANGLE <= FIBER_8 & FIBER_7 & FIBER_6 & FIBER_5 & FIBER_4 & FIBER_3 & FIBER_2 & FIBER_1;
--
b2v_inst12 : fcc_data_acq_fiber_control
PORT MAP(CLOCK, RESET_ALL, deta_disc_regs, step_en, DETA_HI, DETA_LO, DISC_HI, DISC_LO, DONE_MOVE, FIB_MODE_IN, DETUNE_ANGLE, PZT_HI, PZT_LO, STEP_HZ,
         STOP, DETA, DIR_FIB, DISC, DONE_FIB, FIB_MODE, MOVE_FIB, PZ, SLOW_MODE, STEPS_FIB);
--
--===================================================
-- REGS (HRT block)
--===================================================
-- Transition from ISA_Bus to udp module notes
-- 	REGS_LD  	became NOT(lb_rnw)
--		ADDR_OUT 	became lb_addr (note, only using lower 10 bits)
--		ISA_SD		became lb_wdata
--		REGS_D/dout	became lb_rdata
--
-- Signals added to help MODELSIM compile
--addr_buffer <= x"00000"&lb_addr(11 downto 0);
addr_buffer <= x"00"&lb_addr; --JAL, 3/22/23. changed to accomodate waveforms
not_rnw		<= NOT(lb_rnw);-- JAL, AND this with lb_valid if we have race conditions?
--
b2v_inst23 : regs
PORT MAP(
heartbeat        => heartbeat_sig, 
clock            => CLOCK, 
reset 		     => RESET_ALL, 
load 		     => not_rnw, 
epcs_bsy 	     => '0', 
abs_steps 	     => abs_steps, 
addr 		     => addr_buffer, 
brd_tmp 	     => TEMP_DATA, 
deta_disc        => deta_disc_regs, 
din 		     => lb_wdata, 
disc_fib 	     => DISC, 
done_move 	     => DONE_MOVE, 
dtan_fib	     => DETA,
epcsr 		     => x"00", 
high_limit_in    => high_limit_in, 
laccel 		     => laccel, 
ldir 		     => ldir, 
low_limit_in     => low_limit_in, 
lsteps 		     => lsteps, 
lvlcty 		     => lvlcty, 
motion 		     => motion, 
pzt_val 	     => PZ, 
sgn_steps 	     => sgn_steps, 
slow_gdr 	     => SLOW_MODE, 
step_count 	     => step_count, 
step_en 	     => step_en,
clear 		     => reg_res, 
reconfig 	     => OPEN, 
abs_stp_sub      => abs_stp_sub, 
accel 		     => accel, 
clr_abs_stp      => clr_abs_stp, 
clr_sgn_stp      => clr_sgn_stp, 
deta_hi 	     => DETA_HI, 
deta_lo 	     => DETA_LO, 
dir			     => DIR, 
dir_flip 	     => dir_flip,
disc_hi		     => DISC_HI, 
disc_lo 	     => DISC_LO, 
done_out 	     => DONE, 
dout 		     => lb_rdata, 
en_sub_abs 	     => en_sub_abs, 
en_sub_sgn 	     => en_sub_sgn,
epcsa 		     => OPEN, 
epcsc 		     => OPEN, 
epcsd 		     => OPEN, 
fib_mode 	     => FIB_MODE_IN, 
inhibit 	     => inhibit, 
limit 		     => limit, 
low_current	     => low_current, 
move 		     => MOVE, 
pzt_hi_lmt 	     => PZT_HI, 
pzt_lo_lmt 	     => PZT_LO, 
motorCurr_OUT    => MOTOR_CURR,
CHOPCONF_OUT	  => CHOPCONF,
MRES_OUT			  => MRES, 
step_hz 		 => STEP_HZ, 
steps 			 => STEPS, 
stop 			 => STOP, 
vlcty 			 => vlcty, 
c10gx_tmp 		 => c10gx_tmp, 
out_EEPROM_ctrl  => EEPROM_ctrl, 
out_EEPROM_addr  => EEPROM_addr, 
out_EEPROM_data  => EEPROM_data, 
EEPROM_datar     => EEPROM_datar, 
out_sfp_dataw	 => sfp_dataw,
sfp_datar	 => sfp_datar,
out_sfp_ctrl     => sfp_ctrl,
lb_valid		 => lb_valid,
rate_reg   => rate_reg); 
--
-- limit switch info
-- HI means limit reached
high_limit_in <= HFLF4_1 & HFLF3_1 & HFLF2_1 & HFLF1_1 & HFLF4 & HFLF3 & HFLF2 & HFLF1;
low_limit_in  <= LFLF4_1 & LFLF3_1 & LFLF2_1 & LFLF1_1 & LFLF4 & LFLF3 & LFLF2 & LFLF1;
--
-- Front Panel LEDS
--LED_BOTTOM(7 downto 4) <= (HFLF1   NOR LFLF1)   & (HFLF2   NOR LFLF2) 	 & (HFLF3   NOR LFLF3)   & (HFLF4   NOR LFLF4);
--LED_BOTTOM(3 downto 0) <= (HFLF1_1 NOR LFLF1_1) & (HFLF2_1 NOR LFLF2_1)  & (HFLF3_1 NOR LFLF3_1) & (HFLF4_1 NOR LFLF4_1);
-- need to reverse order and change to OR, JAL 5/18/22
LED_BOTTOM(7 downto 0) <= (HFLF4_1 NOR LFLF4_1) & (HFLF3_1 NOR LFLF3_1) & (HFLF2_1 NOR LFLF2_1)  & (HFLF1_1 NOR LFLF1_1) & (HFLF4 NOR LFLF4) & (HFLF3 NOR LFLF3)  & (HFLF2 NOR LFLF2) & (HFLF1 NOR LFLF1);
--===================================================
-- STEPPERS
--===================================================
--
step_gen: for I in 0 to 7 generate
	stepper_I : stepper_driver
	generic map (testBench=>testBench)
	PORT MAP(RESET_ALL, CLOCK, DIR_OUT(I), dir_flip(I), MOVE_OUT(I), DONE_OUT(I), STOP(I), clr_sgn_stp(I), clr_abs_stp(I), en_sub_abs(I), en_sub_sgn(I),
          	accel(I), (others =>'0'), STEPS_OUT(I), abs_stp_sub(I), vlcty(I), SPI_HS_IN(I), SPI_HS_OUT(I), step_buffer(I), ldir(I), motion(I), DONE_MOVE(I), abs_steps(I),
            open, open, laccel(I), lsteps(I), lvlcty(I), sgn_steps(I), step_count(I), rate_reg(I));
	--
	-- the stepper module was modified so that we don't need the division module anymore
	--division_I : division
	--PORT MAP(denom(I), numer(I), quotient(I));
	--
end generate step_gen;
--
-- Board outputs from step_gen (commands to TMC chips to move steppers and control direction)
STEP4_1 <= step_buffer(7); DIR4_1 <= ldir(7); 
STEP3_1 <= step_buffer(6); DIR3_1 <= ldir(6); 
STEP2_1 <= step_buffer(5); DIR2_1 <= ldir(5); 
STEP1_1 <= step_buffer(4); DIR1_1 <= ldir(4); 
STEP4   <= step_buffer(3); DIR4   <= ldir(3); 
STEP3   <= step_buffer(2); DIR3   <= ldir(2); 
STEP2   <= step_buffer(1); DIR2   <= ldir(1); 
STEP1   <= step_buffer(0); DIR1   <= ldir(0); 
--
-- Front panel LEDs
LED_TOP(3 downto 0) <= (motion(0) OR motion(1)) & (motion(2) OR motion(3)) & (motion(4) OR motion(5)) & (motion(6) OR motion(7));
LED_TOP(4) <= (FIB_MODE(0) or FIB_MODE(1) or FIB_MODE(2) or FIB_MODE(3) or FIB_MODE(4) or FIB_MODE(5) or FIB_MODE(6) or FIB_MODE(7)) ;	--fiber mode selected (on at least one channel)
LED_TOP(5) <= udp_ioc;		   -- coms with ioc
LED_TOP(6) <= heartbeat_sig;  -- fpga heat beat
LED_TOP(7) <= '1'; 				-- fpga power

--
--
-- working 10/20/2020, incorporating PLL
--process (clock, reset)
--	variable counter     :  UNSIGNED(3 downto 0) := x"0";
--begin
--	if (reset = '0') then
--		counter := x"0";
--		clk_50 <= '0';
--	else
--		if clock'event and clock = '1' then
--			if (counter >= x"0") AND (counter < x"1") then
--				clk_50 <= '1';
--				counter := counter + 1;
--			else
--				clk_50 <= '0';
--				counter := x"0";
--			end if;
--		end if;
--	end if;
--end process;

-- Simple PLL to produce the 50 Mhz clock for TMC2660 SPI
--
--inst_PLL_125_to_50 : component PLL_125_to_50
--		port map (
--			rst      => NOT(reset),      			--  active hi reset, (reset signal is active low, thus we need to invert it)
--			refclk   => clock,   					--  125 Mhz clock signal
--			locked   => PLL_125_to_50_locked,   --  PLL locked output, PLL will be locked when this is HI
--			outclk_0 => PLL_125_to_50_raw  		--  raw clock, this signal should be held low until PLL locked is achieved
--		);
--
--clk_50 <= PLL_125_to_50_raw when PLL_125_to_50_locked = '1' else '0';
--
-- 3/12/21, this module is running at a slower clock then the rest of this module. However, the signal inputs are slow moving
-- and syncronized within the module. This should be sufficent to prevent metastable conditions.
--
-- 1/10/22, note, clk_50 a 50 Mhz clock was driving this module. It will also work with a 125 Mhz clock.
--
SPI_ports_gen : for I in 0 to 7 generate
	--
	TMC2660_I : TMC2660
	PORT MAP(clock, RESET_ALL, CHOPCONF(0), MRES(0)(3 downto 0), MOTOR_CURR(I)(4 downto 0), low_current(I), SPI_CONFIG(I), SDO_IN(I), inhibit(I), 
	         CSN(I), SCK(I), SDI(I), SEN(I), CONFIG_DONE(I) );
	--
	--
	PRO_I : process (CLOCK, RESET_ALL)
		-- for stepper spi configuration generate statment
		variable MOTOR_CURR_SAVE  : STD_LOGIC_VECTOR(15 downto 0);
		variable low_current_SAVE : STD_LOGIC;
		variable MRES_SAVE        : STD_LOGIC_VECTOR(15 downto 0);
		variable counter          : UNSIGNED(15 downto 0);
		--constant max_count        : UNSIGNED(15 downto 0) := x"0064"; -- how many 8ns long the pulse should be. SPI begins at rising edge
	begin
		if RESET_ALL = '0' then
			-- reset signals
			SPI_CONFIG(I)    <= '0';
			MOTOR_CURR_SAVE  := (others => '0');
			counter			  := (others => '0');
			low_current_SAVE := '0';		
		elsif (CLOCK'event and CLOCK='1') then
			-- Check to see if any of the TMC registers have changed and if so, update the TMC over SPI
			if ((MOTOR_CURR_SAVE /= MOTOR_CURR(I)) OR (low_current_SAVE /= low_current(I)) OR (MRES_SAVE /= MRES(I))) then
				-- Begin to update TMC over SPI
				SPI_CONFIG(I) <= '1'; 
				counter       := x"0000";
				-- Register these values as this is what will be on the TMC after SPI is done
				MOTOR_CURR_SAVE  := MOTOR_CURR(I);
				low_current_SAVE := low_current(I);
				MRES_SAVE        := MRES(I);
			elsif	(counter < x"0064") then -- keep SPI configuration pulse HI for mac_count number of clock ticks.
				SPI_CONFIG(I) <= '1'; 
				counter       := counter + 1; 
			else -- keep SPI configuration bit low if the last sent TMC registers are up to date
				SPI_CONFIG(I) <= '0'; 
				counter       := x"0064"; 
			end if;
		end if; -- end rising edge check and reset check
	end process PRO_I;
	--
	-- Notes on SPI handshake. The TMC2660 chip has many settings/configurations which are setup during an SPI configuration phase. Items such as
	-- motor current, micro step resolution and chopper current profile configuration can be dynamically changed. When this happens the TMC chip
	-- will need to have its programming registers reconfigured over SPI. Most registers can be changed at anytime, but some registers (such as hold current)
	-- may change when the motor goes from not moving to wanting to move. Thus, it is necessary to 'check' the SPI registers BEFORE any steps occur.
	-- The SPI Handshake In/out (SPI_HS_IN/OUT) are between this module and the stepper_driver.vhd module. Once a valid go/move command is given, the
	-- stepper_driver module will go into LOAD state and wait there until it gets a response. stepper_driver will set SPI_HS_OUT to HI when in the load state
	-- and the module will not proceed to step until stepper_driver sees the SPI_HS_IN bit go HI.
	--
	-- PRO_I will update the SPI registers if any changes occur. When stepper_driver.vhd goes  into load, the current setting may be changed which will
	-- be seen by this process.
	--
	-- PRO_HS_I will wait until it sees the SPI_HS_OUT bit go HI and then it will monitor the CONFIG_DONE bit and ensure that it is HI (meaning done)
	-- beofe allowing SPI_HS_IN to go HI, meaning that the SPI configurtion is up to date. SPI_HS_IN will stay HI until SPI_HS_OUT is pulled low by
	-- moving to a new state in stepper_driver.vhd
	--
	--
	PRO_HS_I : process(CLOCK)
		variable spi_check_count : UNSIGNED(15 downto 0);
	begin
		if (CLOCK = '1' and CLOCK'event) then
			if   ((SPI_HS_OUT(I) = '1') AND (spi_check_count < x"0064") AND (CONFIG_DONE(I) = '1')) then -- if true, then stepper driver is requesting that we check the status of CONFIG_DONE(I)
				SPI_HS_IN(I)    <= '0'; -- sent to stepper driver module, Keep Low
				spi_check_count := spi_check_count + 1;
			-- if spi configuration done bit is high for a set number of clocks, wait for stepper drivermodule
			-- to set SPI handshake out to low (meaning it has left the laod state) before this process sets spi handshake in back to low.
			elsif ((SPI_HS_OUT(I) = '1') AND (spi_check_count >= x"0064") AND (CONFIG_DONE(I) = '1')) then 
				SPI_HS_IN(I)    <= '1'; -- sent to stepper driver module, set HI
				spi_check_count := spi_check_count + 1;
			else
				SPI_HS_IN(I)     <= '0'; -- sent to stepper driver module, keep LOW
				spi_check_count  := (others => '0');	
			end if;
		end if;
	end process;
	--
	--
	--
end generate SPI_ports_gen;
--
--
--
--
-- assign to output pins for steppers
--	 chip select		 s clock				  datat to stepper  Stepper enable
	 CSN1   <= CSN(0); SCLK1   <= SCK(0); SDI1   <= SDI(0); EN1   <= SEN(0);
    CSN2   <= CSN(1); SCLK2   <= SCK(1); SDI2   <= SDI(1); EN2   <= SEN(1);
    CSN3   <= CSN(2); SCLK3   <= SCK(2); SDI3   <= SDI(2); EN3   <= SEN(2);
    CSN4   <= CSN(3); SCLK4   <= SCK(3); SDI4   <= SDI(3); EN4   <= SEN(3);
    CSN1_1 <= CSN(4); SCLK1_1 <= SCK(4); SDI1_1 <= SDI(4); EN1_1 <= SEN(4);
    CSN2_1 <= CSN(5); SCLK2_1 <= SCK(5); SDI2_1 <= SDI(5); EN2_1 <= SEN(5);
    CSN3_1 <= CSN(6); SCLK3_1 <= SCK(6); SDI3_1 <= SDI(6); EN3_1 <= SEN(6);
    CSN4_1 <= CSN(7); SCLK4_1 <= SCK(7); SDI4_1 <= SDI(7); EN4_1 <= SEN(7);
--
--------------
-- SPI Notes :
--------------
	--SPI_CONFIG:	pulse hi whenever a change is made to current sense (this is go for spi)
	--
	--crash:			motor command (2), another way to force an inhibit (seems redundant) but included anyway
	--
	--CSN:			assign to chip select output pin for stepper
	--
	--SCK:			assign SCK to output pin. This is 127 times slower than CLOCK 
	--					  (CLOCK=100M -> SCLK=787.4k)
	--
	--EN:			   enable for steppers (active low to enable)
	--
 	--CONFIG_DONE:	whenever SPI needs updated, wait until config_done pulses before executing new steps. maybe add to motor status?
	--
	--SDO_IN:		This is not used, for future use if we want read backs from the steppers (like current being used, stal info).
	--

	--===================================================
	--		16 LED expansion (I2C)
	--=================================================== 
	 led_cont_i2c : LED_CONTROL
	 generic map (testBench=>testBench)
	 PORT MAP	(	
		clock      => clock,
		reset_n    => RESET_ALL,
		LED_TOP	  => LED_TOP,
		LED_BOTTOM => LED_BOTTOM,
		SCL 	     => LED_SCL,
		SDA 	     => LED_SDA
	);
	
	--===================================================
	--		Temp Sensor (8 total sesnors on 2 I2c lines)
	--===================================================
	--
	adt_cont_i2c : ADT_CONTROL
	 generic map (testBench=>testBench)
	 PORT MAP	(	
		clock      => clock,
		reset_n    => RESET_ALL,
		TEMP_DATA  => TEMP_DATA_buff1,
		OE_CONT1   => OE_CONT1,
		DIR_CONT1  => DIR_CONT1,
		SCL 	     => SCLM1,
		SDA 	     => SDA_M1
	);
	--
	adt_cont_i2c_1 : ADT_CONTROL
	 generic map (testBench=>testBench)
	 PORT MAP	(	
		clock      => clock,
		reset_n    => RESET_ALL,
		TEMP_DATA  => TEMP_DATA_buff2,
		OE_CONT1   => OE_CONT1_1,
		DIR_CONT1  => DIR_CONT1_1,
		SCL 	     => SCLM1_1,
		SDA 	     => SDA_M1_1
	);
	--
	-- TEMP_DATA_buff1 and TEMP_DATA_buff2 are average temperatures of the left
	-- hand side and right hand side of the stepper board. This process
	-- combines the values to get the overall average.
	--
	-- Note, about temp data is registered, but if results are poor add a condition that only
	-- reports the temperatures when the DIR_CONT1/_1 signals are HI, as this is when data
	-- is being sent to the IC temp sensor and the value should be stable (rising edge).
	--
	process (clock, RESET_ALL)
		variable ADT_count : STD_LOGIC_VECTOR(1 downto 0);  -- keep track of which step we are on for averaging
		variable ADT_sum	 : STD_LOGIC_VECTOR(15 downto 0); -- 16 bit accumulator
	begin
		if (RESET_ALL='0') then
			ADT_count := (others =>'0');
		elsif (clock'event and clock='1') then
			case ADT_count is
				when "00"   => -- add 2 values together
					ADT_sum   := STD_LOGIC_VECTOR(UNSIGNED(TEMP_DATA_buff1) + UNSIGNED(TEMP_DATA_buff2));
					ADT_count := "01";
				when "01"   => -- divide by 2
					ADT_sum   := "0" & ADT_sum(15 downto 1);
					ADT_count := "10";
				when others => -- update average register TEMP_DATA to report to EPICS
					TEMP_DATA <= ADT_sum;
					ADT_count := "00";
			end case;
		end if;
	end process;
	--
	--
	--===================================================
   -- fpga internal temperature sensor
   --===================================================
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
	--
	--
	--===================================================
   -- 32k bit EEPROM
   --===================================================
	--
	-- NOT WORING AS DESIRED?, pulls ups on i2c chip might be too weak.
	-- nice to have, not needed.
--	inst_EEPROM: EEPROM_CONTROL
--		PORT MAP
--		(	
--			clock      		=> clock, 
--			reset_n    		=> RESET_ALL, 
--			EEPROM_RNW		=> EEPROM_ctrl(1), 
--			EEPROM_go		=> EEPROM_ctrl(0), 
--			EEPROM_STAT	 	=> open, 
--			EEPROM_ADDR		=> EEPROM_addr,  
--			EEPROM_DATA		=> EEPROM_data, 
--			EEPROM_DATAR	=> EEPROM_datar, 
--			EEPROM_SCL 		=> FMC2_SCL, 
--			EEPROM_SDA 		=> FMC2_SDA);
			--
			-- other control bit are unused
			EEPROM_ctrl(7 downto 2) <= "000000";
			--
			-- this sets the device address (really these should be pull ups).
			-- A2 = LOW, A1 = HI, A0 = HI
			--
			-- GA2 is tied to low on PCB
			GA1 <= '1'; -- A1, fixed, this and GA0 could be a pull ups on PCB.
			GA0 <= '1'; -- A0, fixed,
			--
			--
	--===================================================
   -- Remote Flash Update/Reconfig
   --===================================================
	-- 1/10/22
	-- This module allows us to update the firmware load saved on the EPCQ
	-- and trigger a reconfiguration of the fpga device over the network.
	-- module was desiged for C10GX but should also be compatible with Aria 10 devices.
	-- note, this is a verilog module
--	CYCLONE_inst : CYCLONE
--	PORT MAP(
--			 lb_clk 		=> CLOCK,
--			 c10_addr 	=> c_addr,
--			 c10_data 	=> c_data,
--			 c10_cntlr 	=> c_cntlr,
--			 c10_status => c10_status,
--			 c10_datar  => c10_datar,
--			 we_cyclone_inst_c10_data => en_c_data);
	--
	--
	--
	--
	-- **************************************************
	--	Still need to incorporate/edit the below
	-- **************************************************
	--
	--
	--
	--===================================================
	-- Temp Sensor                                          *** will need to update with new temp sensor info
	--===================================================
	--
	--TEMP_SENSOR : lm74 --                               <-- Will need to change (different Temp sensor)
	--PORT MAP(clock, RESET_all, TEMP_SI, TEMP_CS ,TEMP_SC, TEMP_DATA);
	 --TEMP_DATA <= x"1234"; -- dummy value for read back
	--
	--===================================================
	-- ISA BUS                                              **** no longer needed becasue of udp code
	--===================================================
	--
	--ISA_BUS_MODULE : isa_bus
	--PORT MAP(RESET_ALL, clock, ISA_BALE, ISA_MEMR, ISA_MEMW, ISA_SA, ISA_SD, REGS_D, REGS_LD, ISA_SD_DIR_sig, ISA_CS16, ADDR_OUT);
	--ISA_SD  input data to regs or output data on ISA bus.
	--REGS_LD  0 = read, 1 = write
	--ADDR_OUT 
	--REGS_D <= dout(15 downto 0);`
	-- replaced this ISA_SD_DIR_sig with a pulse detection of when the address changes
	--ISA_SD_DIR_sig <= '1';
	--ISA_SD_DIR <= ISA_SD_DIR_sig;
	--
	--
END bdf_type;