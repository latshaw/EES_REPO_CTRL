-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "11/05/2020 15:40:16"
                                                            
-- Vhdl Test Bench template for design  :  Motion_control
-- 
-- Simulation tool : ModelSim-Altera (VHDL)
-- 

LIBRARY ieee;                                               
USE ieee.std_logic_1164.all;                                

ENTITY Motion_control_vhd_tst IS
END Motion_control_vhd_tst;
ARCHITECTURE Motion_control_arch OF Motion_control_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL ADC_CS : STD_LOGIC;
SIGNAL ADC_DIN : STD_LOGIC;
SIGNAL ADC_DOUT : STD_LOGIC;
SIGNAL ADC_SCLK : STD_LOGIC;
SIGNAL CLOCK_IN : STD_LOGIC;
SIGNAL CSN1 : STD_LOGIC;
SIGNAL CSN1_1 : STD_LOGIC;
SIGNAL CSN2 : STD_LOGIC;
SIGNAL CSN2_1 : STD_LOGIC;
SIGNAL CSN3 : STD_LOGIC;
SIGNAL CSN3_1 : STD_LOGIC;
SIGNAL CSN4 : STD_LOGIC;
SIGNAL CSN4_1 : STD_LOGIC;
SIGNAL DIR1 : STD_LOGIC;
SIGNAL DIR1_1 : STD_LOGIC;
SIGNAL DIR2 : STD_LOGIC;
SIGNAL DIR2_1 : STD_LOGIC;
SIGNAL DIR3 : STD_LOGIC;
SIGNAL DIR3_1 : STD_LOGIC;
SIGNAL DIR4 : STD_LOGIC;
SIGNAL DIR4_1 : STD_LOGIC;
SIGNAL DIR_CONT1 : STD_LOGIC;
SIGNAL DIR_CONT1_1 : STD_LOGIC;
SIGNAL EN1 : STD_LOGIC;
SIGNAL EN1_1 : STD_LOGIC;
SIGNAL EN2 : STD_LOGIC;
SIGNAL EN2_1 : STD_LOGIC;
SIGNAL EN3 : STD_LOGIC;
SIGNAL EN3_1 : STD_LOGIC;
SIGNAL EN4 : STD_LOGIC;
SIGNAL EN4_1 : STD_LOGIC;
SIGNAL FIBER_1 : STD_LOGIC;
SIGNAL FIBER_2 : STD_LOGIC;
SIGNAL FIBER_3 : STD_LOGIC;
SIGNAL FIBER_4 : STD_LOGIC;
SIGNAL FIBER_5 : STD_LOGIC;
SIGNAL FIBER_6 : STD_LOGIC;
SIGNAL FIBER_7 : STD_LOGIC;
SIGNAL FIBER_8 : STD_LOGIC;
SIGNAL FMC2_SCL : STD_LOGIC;
SIGNAL FMC2_SDA : STD_LOGIC;
SIGNAL GA0 : STD_LOGIC;
SIGNAL GA1 : STD_LOGIC;
SIGNAL HFLF1 : STD_LOGIC;
SIGNAL HFLF1_1 : STD_LOGIC;
SIGNAL HFLF2 : STD_LOGIC;
SIGNAL HFLF2_1 : STD_LOGIC;
SIGNAL HFLF3 : STD_LOGIC;
SIGNAL HFLF3_1 : STD_LOGIC;
SIGNAL HFLF4 : STD_LOGIC;
SIGNAL HFLF4_1 : STD_LOGIC;
SIGNAL LED_SCL : STD_LOGIC;
SIGNAL LED_SDA : STD_LOGIC;
SIGNAL LFLF1 : STD_LOGIC;
SIGNAL LFLF1_1 : STD_LOGIC;
SIGNAL LFLF2 : STD_LOGIC;
SIGNAL LFLF2_1 : STD_LOGIC;
SIGNAL LFLF3 : STD_LOGIC;
SIGNAL LFLF3_1 : STD_LOGIC;
SIGNAL LFLF4 : STD_LOGIC;
SIGNAL LFLF4_1 : STD_LOGIC;
SIGNAL OE_CONT1 : STD_LOGIC;
SIGNAL OE_CONT1_1 : STD_LOGIC;
SIGNAL SCLK1 : STD_LOGIC;
SIGNAL SCLK1_1 : STD_LOGIC;
SIGNAL SCLK2 : STD_LOGIC;
SIGNAL SCLK2_1 : STD_LOGIC;
SIGNAL SCLK3 : STD_LOGIC;
SIGNAL SCLK3_1 : STD_LOGIC;
SIGNAL SCLK4 : STD_LOGIC;
SIGNAL SCLK4_1 : STD_LOGIC;
SIGNAL SCLM1 : STD_LOGIC;
SIGNAL SCLM1_1 : STD_LOGIC;
SIGNAL SDA_M1 : STD_LOGIC;
SIGNAL SDA_M1_1 : STD_LOGIC;
SIGNAL SDI1 : STD_LOGIC;
SIGNAL SDI1_1 : STD_LOGIC;
SIGNAL SDI2 : STD_LOGIC;
SIGNAL SDI2_1 : STD_LOGIC;
SIGNAL SDI3 : STD_LOGIC;
SIGNAL SDI3_1 : STD_LOGIC;
SIGNAL SDI4 : STD_LOGIC;
SIGNAL SDI4_1 : STD_LOGIC;
SIGNAL SDO1 : STD_LOGIC;
SIGNAL SDO1_1 : STD_LOGIC;
SIGNAL SDO2 : STD_LOGIC;
SIGNAL SDO2_1 : STD_LOGIC;
SIGNAL SDO3 : STD_LOGIC;
SIGNAL SDO3_1 : STD_LOGIC;
SIGNAL SDO4 : STD_LOGIC;
SIGNAL SDO4_1 : STD_LOGIC;
SIGNAL STEP1 : STD_LOGIC;
SIGNAL STEP1_1 : STD_LOGIC;
SIGNAL STEP2 : STD_LOGIC;
SIGNAL STEP2_1 : STD_LOGIC;
SIGNAL STEP3 : STD_LOGIC;
SIGNAL STEP3_1 : STD_LOGIC;
SIGNAL STEP4 : STD_LOGIC;
SIGNAL STEP4_1 : STD_LOGIC;
SIGNAL addr_tb : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL din_tb : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL dout_tb : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL gpio_led_1 : STD_LOGIC;
SIGNAL gpio_led_2 : STD_LOGIC;
SIGNAL gpio_led_3 : STD_LOGIC;
SIGNAL hb_fpga : STD_LOGIC;
SIGNAL m10_reset : STD_LOGIC;
SIGNAL reset : STD_LOGIC;
SIGNAL rnw_tb : STD_LOGIC;
SIGNAL sfp_refclk_p : STD_LOGIC;
SIGNAL sfp_rx_0_p : STD_LOGIC;
SIGNAL sfp_scl_0 : STD_LOGIC;
SIGNAL sfp_sda_0 : STD_LOGIC;
SIGNAL sfp_tx_0_p : STD_LOGIC;
COMPONENT Motion_control
	PORT (
	ADC_CS : OUT STD_LOGIC;
	ADC_DIN : IN STD_LOGIC;
	ADC_DOUT : OUT STD_LOGIC;
	ADC_SCLK : OUT STD_LOGIC;
	CLOCK_IN : IN STD_LOGIC;
	CSN1 : OUT STD_LOGIC;
	CSN1_1 : OUT STD_LOGIC;
	CSN2 : OUT STD_LOGIC;
	CSN2_1 : OUT STD_LOGIC;
	CSN3 : OUT STD_LOGIC;
	CSN3_1 : OUT STD_LOGIC;
	CSN4 : OUT STD_LOGIC;
	CSN4_1 : OUT STD_LOGIC;
	DIR1 : OUT STD_LOGIC;
	DIR1_1 : OUT STD_LOGIC;
	DIR2 : OUT STD_LOGIC;
	DIR2_1 : OUT STD_LOGIC;
	DIR3 : OUT STD_LOGIC;
	DIR3_1 : OUT STD_LOGIC;
	DIR4 : OUT STD_LOGIC;
	DIR4_1 : OUT STD_LOGIC;
	DIR_CONT1 : OUT STD_LOGIC;
	DIR_CONT1_1 : OUT STD_LOGIC;
	EN1 : OUT STD_LOGIC;
	EN1_1 : OUT STD_LOGIC;
	EN2 : OUT STD_LOGIC;
	EN2_1 : OUT STD_LOGIC;
	EN3 : OUT STD_LOGIC;
	EN3_1 : OUT STD_LOGIC;
	EN4 : OUT STD_LOGIC;
	EN4_1 : OUT STD_LOGIC;
	FIBER_1 : IN STD_LOGIC;
	FIBER_2 : IN STD_LOGIC;
	FIBER_3 : IN STD_LOGIC;
	FIBER_4 : IN STD_LOGIC;
	FIBER_5 : IN STD_LOGIC;
	FIBER_6 : IN STD_LOGIC;
	FIBER_7 : IN STD_LOGIC;
	FIBER_8 : IN STD_LOGIC;
	FMC2_SCL : OUT STD_LOGIC;
	FMC2_SDA : INOUT STD_LOGIC;
	GA0 : OUT STD_LOGIC;
	GA1 : OUT STD_LOGIC;
	HFLF1 : IN STD_LOGIC;
	HFLF1_1 : IN STD_LOGIC;
	HFLF2 : IN STD_LOGIC;
	HFLF2_1 : IN STD_LOGIC;
	HFLF3 : IN STD_LOGIC;
	HFLF3_1 : IN STD_LOGIC;
	HFLF4 : IN STD_LOGIC;
	HFLF4_1 : IN STD_LOGIC;
	LED_SCL : OUT STD_LOGIC;
	LED_SDA : INOUT STD_LOGIC;
	LFLF1 : IN STD_LOGIC;
	LFLF1_1 : IN STD_LOGIC;
	LFLF2 : IN STD_LOGIC;
	LFLF2_1 : IN STD_LOGIC;
	LFLF3 : IN STD_LOGIC;
	LFLF3_1 : IN STD_LOGIC;
	LFLF4 : IN STD_LOGIC;
	LFLF4_1 : IN STD_LOGIC;
	OE_CONT1 : OUT STD_LOGIC;
	OE_CONT1_1 : OUT STD_LOGIC;
	SCLK1 : OUT STD_LOGIC;
	SCLK1_1 : OUT STD_LOGIC;
	SCLK2 : OUT STD_LOGIC;
	SCLK2_1 : OUT STD_LOGIC;
	SCLK3 : OUT STD_LOGIC;
	SCLK3_1 : OUT STD_LOGIC;
	SCLK4 : OUT STD_LOGIC;
	SCLK4_1 : OUT STD_LOGIC;
	SCLM1 : INOUT STD_LOGIC;
	SCLM1_1 : INOUT STD_LOGIC;
	SDA_M1 : INOUT STD_LOGIC;
	SDA_M1_1 : INOUT STD_LOGIC;
	SDI1 : OUT STD_LOGIC;
	SDI1_1 : OUT STD_LOGIC;
	SDI2 : OUT STD_LOGIC;
	SDI2_1 : OUT STD_LOGIC;
	SDI3 : OUT STD_LOGIC;
	SDI3_1 : OUT STD_LOGIC;
	SDI4 : OUT STD_LOGIC;
	SDI4_1 : OUT STD_LOGIC;
	SDO1 : IN STD_LOGIC;
	SDO1_1 : IN STD_LOGIC;
	SDO2 : IN STD_LOGIC;
	SDO2_1 : IN STD_LOGIC;
	SDO3 : IN STD_LOGIC;
	SDO3_1 : IN STD_LOGIC;
	SDO4 : IN STD_LOGIC;
	SDO4_1 : IN STD_LOGIC;
	STEP1 : OUT STD_LOGIC;
	STEP1_1 : OUT STD_LOGIC;
	STEP2 : OUT STD_LOGIC;
	STEP2_1 : OUT STD_LOGIC;
	STEP3 : OUT STD_LOGIC;
	STEP3_1 : OUT STD_LOGIC;
	STEP4 : OUT STD_LOGIC;
	STEP4_1 : OUT STD_LOGIC;
	addr_tb : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
	din_tb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	dout_tb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	gpio_led_1 : OUT STD_LOGIC;
	gpio_led_2 : OUT STD_LOGIC;
	gpio_led_3 : OUT STD_LOGIC;
	hb_fpga : OUT STD_LOGIC;
	m10_reset : IN STD_LOGIC;
	reset : IN STD_LOGIC;
	rnw_tb : IN STD_LOGIC;
	sfp_refclk_p : IN STD_LOGIC;
	sfp_rx_0_p : IN STD_LOGIC;
	sfp_scl_0 : OUT STD_LOGIC;
	sfp_sda_0 : INOUT STD_LOGIC;
	sfp_tx_0_p : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : Motion_control
	PORT MAP (
-- list connections between master ports and signals
	ADC_CS => ADC_CS,
	ADC_DIN => ADC_DIN,
	ADC_DOUT => ADC_DOUT,
	ADC_SCLK => ADC_SCLK,
	CLOCK_IN => CLOCK_IN,
	CSN1 => CSN1,
	CSN1_1 => CSN1_1,
	CSN2 => CSN2,
	CSN2_1 => CSN2_1,
	CSN3 => CSN3,
	CSN3_1 => CSN3_1,
	CSN4 => CSN4,
	CSN4_1 => CSN4_1,
	DIR1 => DIR1,
	DIR1_1 => DIR1_1,
	DIR2 => DIR2,
	DIR2_1 => DIR2_1,
	DIR3 => DIR3,
	DIR3_1 => DIR3_1,
	DIR4 => DIR4,
	DIR4_1 => DIR4_1,
	DIR_CONT1 => DIR_CONT1,
	DIR_CONT1_1 => DIR_CONT1_1,
	EN1 => EN1,
	EN1_1 => EN1_1,
	EN2 => EN2,
	EN2_1 => EN2_1,
	EN3 => EN3,
	EN3_1 => EN3_1,
	EN4 => EN4,
	EN4_1 => EN4_1,
	FIBER_1 => FIBER_1,
	FIBER_2 => FIBER_2,
	FIBER_3 => FIBER_3,
	FIBER_4 => FIBER_4,
	FIBER_5 => FIBER_5,
	FIBER_6 => FIBER_6,
	FIBER_7 => FIBER_7,
	FIBER_8 => FIBER_8,
	FMC2_SCL => FMC2_SCL,
	FMC2_SDA => FMC2_SDA,
	GA0 => GA0,
	GA1 => GA1,
	HFLF1 => HFLF1,
	HFLF1_1 => HFLF1_1,
	HFLF2 => HFLF2,
	HFLF2_1 => HFLF2_1,
	HFLF3 => HFLF3,
	HFLF3_1 => HFLF3_1,
	HFLF4 => HFLF4,
	HFLF4_1 => HFLF4_1,
	LED_SCL => LED_SCL,
	LED_SDA => LED_SDA,
	LFLF1 => LFLF1,
	LFLF1_1 => LFLF1_1,
	LFLF2 => LFLF2,
	LFLF2_1 => LFLF2_1,
	LFLF3 => LFLF3,
	LFLF3_1 => LFLF3_1,
	LFLF4 => LFLF4,
	LFLF4_1 => LFLF4_1,
	OE_CONT1 => OE_CONT1,
	OE_CONT1_1 => OE_CONT1_1,
	SCLK1 => SCLK1,
	SCLK1_1 => SCLK1_1,
	SCLK2 => SCLK2,
	SCLK2_1 => SCLK2_1,
	SCLK3 => SCLK3,
	SCLK3_1 => SCLK3_1,
	SCLK4 => SCLK4,
	SCLK4_1 => SCLK4_1,
	SCLM1 => SCLM1,
	SCLM1_1 => SCLM1_1,
	SDA_M1 => SDA_M1,
	SDA_M1_1 => SDA_M1_1,
	SDI1 => SDI1,
	SDI1_1 => SDI1_1,
	SDI2 => SDI2,
	SDI2_1 => SDI2_1,
	SDI3 => SDI3,
	SDI3_1 => SDI3_1,
	SDI4 => SDI4,
	SDI4_1 => SDI4_1,
	SDO1 => SDO1,
	SDO1_1 => SDO1_1,
	SDO2 => SDO2,
	SDO2_1 => SDO2_1,
	SDO3 => SDO3,
	SDO3_1 => SDO3_1,
	SDO4 => SDO4,
	SDO4_1 => SDO4_1,
	STEP1 => STEP1,
	STEP1_1 => STEP1_1,
	STEP2 => STEP2,
	STEP2_1 => STEP2_1,
	STEP3 => STEP3,
	STEP3_1 => STEP3_1,
	STEP4 => STEP4,
	STEP4_1 => STEP4_1,
	addr_tb => addr_tb,
	din_tb => din_tb,
	dout_tb => dout_tb,
	gpio_led_1 => gpio_led_1,
	gpio_led_2 => gpio_led_2,
	gpio_led_3 => gpio_led_3,
	hb_fpga => hb_fpga,
	m10_reset => m10_reset,
	reset => reset,
	rnw_tb => rnw_tb,
	sfp_refclk_p => sfp_refclk_p,
	sfp_rx_0_p => sfp_rx_0_p,
	sfp_scl_0 => sfp_scl_0,
	sfp_sda_0 => sfp_sda_0,
	sfp_tx_0_p => sfp_tx_0_p
	);
init : PROCESS                                               
-- variable declarations                                     
BEGIN                                                        
        -- code that executes only once                      
WAIT;                                                       
END PROCESS init;                                           
always : PROCESS                                              
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
BEGIN                                                         
        -- code executes for every event on sensitivity list  
WAIT;                                                        
END PROCESS always;                                          
END Motion_control_arch;
