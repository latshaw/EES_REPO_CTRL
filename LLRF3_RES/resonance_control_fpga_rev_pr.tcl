# Copyright (C) 2018  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details.

# Quartus Prime: Generate Tcl File for Project
# File: resonance_control_fpga_rev_pr.tcl
# Generated on: Tue Oct 17 12:17:58 2023

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "resonance_control_fpga_rev_pr"]} {
		puts "Project resonance_control_fpga_rev_pr is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists resonance_control_fpga_rev_pr]} {
		project_open -revision resonance_control_fpga_rev_pr resonance_control_fpga_rev_pr
	} else {
		project_new -revision resonance_control_fpga_rev_pr resonance_control_fpga_rev_pr
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name AUTO_RESERVE_CLKUSR_FOR_CALIBRATION OFF
	set_global_assignment -name FAMILY "Cyclone 10 GX"
	set_global_assignment -name TOP_LEVEL_ENTITY motion_control
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:59:13  JUNE 30, 2020"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Pro Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name DEVICE 10CX105YF672E5G
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 4
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 672
	set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
	set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
	set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X1"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name GENERATE_PR_RBF_FILE OFF
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN ON
	set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_100MHZ
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name POWER_AUTO_COMPUTE_TJ ON
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON
	set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (VHDL)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name USE_SIGNALTAP_FILE stp1.stp
	set_global_assignment -name VERILOG_FILE abs_step_module.v
	set_global_assignment -name QIP_FILE EPCQ/EPCQ.qip
	set_global_assignment -name VHDL_FILE genwave.vhd
	set_global_assignment -name SDC_FILE resonance_control_fpga_rev_pr.out.sdc
	set_global_assignment -name VERILOG_FILE xformer.v
	set_global_assignment -name SDC_FILE cyclone10gx_main.sdc
	set_global_assignment -name QIP_FILE fpga_tsd_int/fpga_tsd_int.qip
	set_global_assignment -name QIP_FILE transceiver_phy_wrap/transceiver_phy_wrap.qip
	set_global_assignment -name VERILOG_FILE dpram.v
	set_global_assignment -name QIP_FILE remote_download/remote_download.qip
	set_global_assignment -name QIP_FILE epcs/epcs.qip
	set_global_assignment -name VERILOG_FILE cyclone.v
	set_global_assignment -name VHDL_FILE i2c.vhd
	set_global_assignment -name VHDL_FILE EEPROM_CONTROL.vhd
	set_global_assignment -name VHDL_FILE LED_CONTROL.vhd
	set_global_assignment -name VHDL_FILE ADT_CONTROL.vhd
	set_global_assignment -name VHDL_FILE Heartbeat_ISA.vhd
	set_global_assignment -name VHDL_FILE gen_i2c.vhd
	set_global_assignment -name VERILOG_FILE pkg_comms_top/xformer.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/udp_port_cam.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/test_tx_mac.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/speed_test.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/scanner.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/rtefi_center.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/rtefi_blob.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/reg_delay.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/qgtx_wrap.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/qgtx_reset_fsm.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/precog.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/pbuf_writer.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/patt_gen.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ones_chksum.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/negotiate.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/multi_sampler.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/mem_gateway.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/mac_subset.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/hello.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/hack_icmp_cksum.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/gtx_eth_clks.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/gmii_link.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/flag_xdomain.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ethernet_crc_add.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/eth_gtx_bridge.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ep_tx_pcs.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ep_sync_detect.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ep_rx_pcs.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/enc_8b10b.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ds_clk_buf.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/dec_8b10b.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/data_xdomain.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/crc16.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/crc8e_guts.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/construct_tx_table.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/construct.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/comms_top_regbank.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/chitchat_txrx_wrap.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/chitchat_tx.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/chitchat_rx.v
	set_global_assignment -name QIP_FILE xcvr_phy_pll/xcvr_phy_pll.qip
	set_global_assignment -name QIP_FILE transeiver_phy_rst/transeiver_phy_rst.qip
	set_global_assignment -name VERILOG_FILE udp_com.v
	set_global_assignment -name VHDL_FILE POLYNOMIAL_DIVISION.vhd
	set_global_assignment -name VHDL_FILE stepper_driver.vhd
	set_global_assignment -name VHDL_FILE resets.vhd
	set_global_assignment -name VHDL_FILE regs.vhd
	set_global_assignment -name VHDL_FILE Motion_control.vhd
	set_global_assignment -name VHDL_FILE isa_bus.vhd
	set_global_assignment -name AHDL_FILE Heartbeat.tdf
	set_global_assignment -name VHDL_FILE FIBER_CONTROL.vhd
	set_global_assignment -name VHDL_FILE FCC_DATA_OUT.vhd
	set_global_assignment -name VHDL_FILE FCC_DATA_IN.vhd
	set_global_assignment -name VHDL_FILE FCC_DATA_ACQ_FIBER_CONTROL.vhd
	set_global_assignment -name VHDL_FILE FCC_DATA_ACQ.vhd
	set_global_assignment -name VHDL_FILE DATA_SELECT.vhd
	set_global_assignment -name VHDL_FILE TMC2660.vhd
	set_global_assignment -name VHDL_FILE COMPONENTS.vhd
	set_global_assignment -name VHDL_FILE resonance_control_fpga_rev_pr.vhd
	set_global_assignment -name VHDL_FILE simulation/modelsim/Heartbeat_ISA.vhd
	set_global_assignment -name VHDL_FILE Heartbeat_FP.vhd
	set_global_assignment -name IP_FILE RAM_2_PORT.ip
	set_global_assignment -name SIGNALTAP_FILE stp_temp.stp
	set_global_assignment -name SIGNALTAP_FILE stp_udp_accel.stp
	set_global_assignment -name VHDL_FILE ram_2.vhd
	set_global_assignment -name SIGNALTAP_FILE stp1.stp
	set_global_assignment -name IP_FILE EPCQ.ip
	set_location_assignment PIN_M1 -to reset
	set_location_assignment PIN_Y10 -to m10_reset
	set_location_assignment PIN_P2 -to hb_fpga
	set_location_assignment PIN_AD14 -to sfp_sda_0
	set_location_assignment PIN_AD15 -to sfp_scl_0
	set_location_assignment PIN_AD24 -to SGMII1_RX_P
	set_location_assignment PIN_AD23 -to "SGMII1_RX_P(n)"
	set_location_assignment PIN_AE26 -to SGMII1_TX_P
	set_location_assignment PIN_AE25 -to "SGMII1_TX_P(n)"
	set_location_assignment PIN_AB24 -to sfp_rx_0_p
	set_location_assignment PIN_AB23 -to "sfp_rx_0_p(n)"
	set_location_assignment PIN_AC26 -to sfp_tx_0_p
	set_location_assignment PIN_AC25 -to "sfp_tx_0_p(n)"
	set_location_assignment PIN_D20 -to STEP1
	set_location_assignment PIN_E20 -to DIR2
	set_location_assignment PIN_B15 -to SDI2
	set_location_assignment PIN_C15 -to SDI1
	set_location_assignment PIN_A11 -to DIR1
	set_location_assignment PIN_B11 -to FIBER_5
	set_location_assignment PIN_AF19 -to FIBER_6
	set_location_assignment PIN_AE19 -to FIBER_7
	set_location_assignment PIN_AA21 -to FIBER_8
	set_location_assignment PIN_Y21 -to DIR3
	# ADC
	set_location_assignment PIN_C17 -to ADC_DOUT -comment ADC
	# ADC
	set_location_assignment PIN_C16 -to ADC_DIN -comment ADC
	set_location_assignment PIN_A19 -to ADC_CS
	# ADC
	set_location_assignment PIN_B19 -to ADC_SCLK -comment ADC
	set_location_assignment PIN_G20 -to FIBER_1
	set_location_assignment PIN_G19 -to FIBER_2
	set_location_assignment PIN_B13 -to FIBER_3
	set_location_assignment PIN_C13 -to FIBER_4
	set_location_assignment PIN_AD18 -to SCLK1
	set_location_assignment PIN_AC18 -to SCLK2
	set_location_assignment PIN_C11 -to CSN1
	set_location_assignment PIN_C12 -to CSN2
	set_location_assignment PIN_AC21 -to CSN3
	set_location_assignment PIN_AC20 -to CSN4
	set_location_assignment PIN_AB18 -to STEP3
	set_location_assignment PIN_AA18 -to EN3
	set_location_assignment PIN_Y20 -to SCLK3
	set_location_assignment PIN_Y19 -to SCLK4
	set_location_assignment PIN_W19 -to SDO1
	set_location_assignment PIN_W18 -to SDO2
	set_location_assignment PIN_AB16 -to SDO3
	set_location_assignment PIN_AA17 -to SDO4
	set_location_assignment PIN_G18 -to EN1
	set_location_assignment PIN_H18 -to STEP2
	set_location_assignment PIN_D19 -to EN2
	set_location_assignment PIN_D14 -to HFLF1
	set_location_assignment PIN_F19 -to LFLF1
	set_location_assignment PIN_F18 -to HFLF2
	set_location_assignment PIN_E16 -to LFLF2
	set_location_assignment PIN_AB21 -to HFLF3
	set_location_assignment PIN_AB20 -to LFLF3
	set_location_assignment PIN_AF16 -to HFLF4
	set_location_assignment PIN_AE16 -to LFLF4
	set_location_assignment PIN_AE14 -to STEP4
	set_location_assignment PIN_AE15 -to EN4
	set_location_assignment PIN_W17 -to SDI3
	set_location_assignment PIN_AF11 -to DIR4
	set_location_assignment PIN_AF12 -to SDI4
	set_location_assignment PIN_AE9 -to EN4_1
	set_location_assignment PIN_AD9 -to SDI4_1
	set_location_assignment PIN_AB8 -to STEP4_1
	set_location_assignment PIN_AA9 -to DIR4_1
	set_location_assignment PIN_R5 -to SDI3_1
	set_location_assignment PIN_P5 -to DIR3_1
	set_location_assignment PIN_T4 -to STEP3_1
	set_location_assignment PIN_R4 -to EN3_1
	# Temp Sensor
	set_location_assignment PIN_AA14 -to OE_CONT1 -comment "Temp Sensor"
	# Temp Sensor
	set_location_assignment PIN_Y14 -to OE_CONT1_1 -comment "Temp Sensor"
	# Temp Sensor
	set_location_assignment PIN_AD5 -to SDA_M1 -comment "Temp Sensor"
	# Temp Sensor
	set_location_assignment PIN_AC5 -to SDA_M1_1 -comment "Temp Sensor"
	# Temp Sensor
	set_location_assignment PIN_AF3 -to DIR_CONT1 -comment "Temp Sensor"
	# Temp Sensor
	set_location_assignment PIN_AF4 -to DIR_CONT1_1 -comment "Temp Sensor"
	set_location_assignment PIN_AF7 -to STEP2_1
	set_location_assignment PIN_AF8 -to DIR2_1
	set_location_assignment PIN_AC11 -to EN2_1
	set_location_assignment PIN_AB11 -to SDI2_1
	set_location_assignment PIN_AE6 -to CSN1_1
	set_location_assignment PIN_K1 -to SCLK2_1
	set_location_assignment PIN_L2 -to CSN2_1
	set_location_assignment PIN_L4 -to SCLK3_1
	set_location_assignment PIN_M4 -to CSN3_1
	set_location_assignment PIN_U4 -to SCLK4_1
	set_location_assignment PIN_U5 -to CSN4_1
	# LED Exp IO
	set_location_assignment PIN_U3 -to LED_SDA -comment "LED Exp IO"
	# LED Exp IO
	set_location_assignment PIN_T3 -to LED_SCL -comment "LED Exp IO"
	set_location_assignment PIN_AE7 -to HFLF1_1
	set_location_assignment PIN_AD7 -to LFLF1_1
	set_location_assignment PIN_AB5 -to SDO1_1
	set_location_assignment PIN_AB6 -to SDO2_1
	set_location_assignment PIN_W8 -to SDO3_1
	set_location_assignment PIN_W9 -to SDO4_1
	set_location_assignment PIN_AB13 -to STEP1_1
	set_location_assignment PIN_AB14 -to DIR1_1
	set_location_assignment PIN_Y15 -to EN1_1
	set_location_assignment PIN_W15 -to SDI1_1
	set_location_assignment PIN_N2 -to HFLF2_1
	set_location_assignment PIN_N3 -to LFLF2_1
	set_location_assignment PIN_H2 -to HFLF3_1
	set_location_assignment PIN_J3 -to LFLF3_1
	set_location_assignment PIN_G1 -to HFLF4_1
	set_location_assignment PIN_H1 -to LFLF4_1
	set_location_assignment PIN_G3 -to GA1
	set_location_assignment PIN_H3 -to GA0
	set_location_assignment PIN_H5 -to FMC2_SDA
	set_location_assignment PIN_H6 -to FMC2_SCL
	set_location_assignment PIN_AF9 -to SCLM1
	set_location_assignment PIN_AE10 -to SCLM1_1
	set_location_assignment PIN_AF6 -to SCLK1_1
	set_location_assignment PIN_N1 -to gpio_led_1
	set_location_assignment PIN_T1 -to gpio_led_2
	set_location_assignment PIN_R2 -to gpio_led_3
	set_location_assignment PIN_U22 -to sfp_refclk_p
	set_location_assignment PIN_U21 -to "sfp_refclk_p(n)"
	set_location_assignment PIN_AF17 -to ETH1_RESET_N
 	set_location_assignment PIN_AF18 -to eth_mdio
	set_location_assignment PIN_AE17 -to eth_mdc
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_rx_0_p -entity motion_control
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_tx_0_p -entity motion_control
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_refclk_p -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to reset -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ADC_CS -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ADC_DIN -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ADC_DOUT -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ADC_SCLK -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to CSN4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to m10_reset -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to hb_fpga -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to STEP1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDO1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDI1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDA_M1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SDA_M1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLM1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLM1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to SCLK1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to OE_CONT1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to OE_CONT1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LFLF1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SDA -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SCL -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to HFLF1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to GA1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to GA0 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FMC2_SDA -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FMC2_SCL -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_8 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_7 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_6 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_5 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FIBER_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to EN1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR_CONT1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR_CONT1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR4_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR4 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR3_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR2_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR1_1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to DIR1 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_sda_0 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_scl_0 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ETH1_RESET_N -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_2 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_3 -entity motion_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_1 -entity motion_control

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
