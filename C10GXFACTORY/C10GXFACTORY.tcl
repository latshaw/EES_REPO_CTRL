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
# File: C10GXFACTORY.tcl
# Generated on: Wed Jun  5 15:03:25 2024

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "C10GXFACTORY"]} {
		puts "Project C10GXFACTORY is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists C10GXFACTORY]} {
		project_open -revision C10GXFACTORY C10GXFACTORY
	} else {
		project_new -revision C10GXFACTORY C10GXFACTORY
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "15:59:13  JUNE 30, 2020"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Pro Edition"
	set_global_assignment -name AUTO_RESERVE_CLKUSR_FOR_CALIBRATION OFF
	set_global_assignment -name FAMILY "Cyclone 10 GX"
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
	set_global_assignment -name USE_SIGNALTAP_FILE output_files/stp1.stp
	set_global_assignment -name VHDL_FILE marvell_phy_config.vhd
	set_global_assignment -name QIP_FILE EPCQ/EPCQ.qip
	set_global_assignment -name SDC_FILE C10GXFACTORY.out.sdc
	set_global_assignment -name SDC_FILE cyclone10gx_main.sdc
	set_global_assignment -name QIP_FILE fpga_tsd_int/fpga_tsd_int.qip
	set_global_assignment -name QIP_FILE transceiver_phy_wrap/transceiver_phy_wrap.qip
	set_global_assignment -name VERILOG_FILE dpram.v
	set_global_assignment -name QIP_FILE remote_download/remote_download.qip
	set_global_assignment -name QIP_FILE epcs/epcs.qip
	set_global_assignment -name VERILOG_FILE cyclone.v
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
	set_global_assignment -name VHDL_FILE COMPONENTS.vhd
	set_global_assignment -name VHDL_FILE C10GXFACTORY.vhd
	set_global_assignment -name IP_FILE EPCQ.ip
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_rx_0_p -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_tx_0_p -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_refclk_p -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to reset -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to m10_reset -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to hb_fpga -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SDA -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SCL -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_sda_0 -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_scl_0 -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ETH1_RESET_N -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to eth_mdio -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to eth_mdc -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_2 -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_3 -entity C10GXFACTORY
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_1 -entity C10GXFACTORY
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
	# LED Exp IO
	set_location_assignment PIN_U3 -to LED_SDA -comment "LED Exp IO"
	# LED Exp IO
	set_location_assignment PIN_T3 -to LED_SCL -comment "LED Exp IO"
	set_location_assignment PIN_N1 -to gpio_led_1
	set_location_assignment PIN_T1 -to gpio_led_2
	set_location_assignment PIN_R2 -to gpio_led_3
	set_location_assignment PIN_U22 -to sfp_refclk_p
	set_location_assignment PIN_U21 -to "sfp_refclk_p(n)"
	set_location_assignment PIN_AF17 -to ETH1_RESET_N
	set_location_assignment PIN_AF18 -to eth_mdio
	set_location_assignment PIN_AE17 -to eth_mdc
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_rx_0_p -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_tx_0_p -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_refclk_p -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to reset -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to m10_reset -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to hb_fpga -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SDA -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SCL -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_sda_0 -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_scl_0 -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ETH1_RESET_N -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to eth_mdio -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to eth_mdc -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_2 -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_3 -entity resonance_control_fpga_rev_pr
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_1 -entity resonance_control_fpga_rev_pr
	set_location_assignment PIN_F7 -to fpga_ver[0]
	set_location_assignment PIN_E9 -to fpga_ver[1]
	set_location_assignment PIN_D8 -to fpga_ver[2]
	set_location_assignment PIN_A12 -to fpga_ver[3]
	set_location_assignment PIN_A4 -to fpga_ver[5]
	set_location_assignment PIN_B5 -to fpga_ver[4]

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
