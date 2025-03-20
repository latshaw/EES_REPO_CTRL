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
# File: hpa.tcl
# Generated on: Thu Mar 20 09:50:17 2025

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "LLRF3_HPA_FPGA"]} {
		puts "Project LLRF3_HPA_FPGA is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists LLRF3_HPA_FPGA]} {
		project_open -revision LLRF3_HPA_FPGA LLRF3_HPA_FPGA
	} else {
		project_new -revision LLRF3_HPA_FPGA LLRF3_HPA_FPGA
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "Cyclone 10 GX"
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "14:46:43  OCTOBER 09, 2020"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Pro Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP "-40"
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name DEVICE 10CX105YF672I5G
	set_global_assignment -name DEVICE_FILTER_PACKAGE FBGA
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 672
	set_global_assignment -name DEVICE_FILTER_SPEED_GRADE 5
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 4
	set_global_assignment -name POWER_AUTO_COMPUTE_TJ ON
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
	set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
	set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X4"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name STRATIXII_CONFIGURATION_DEVICE MT25QU01G
	set_global_assignment -name GENERATE_PR_RBF_FILE OFF
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN ON
	set_global_assignment -name CONFIGURATION_VCCIO_LEVEL 1.8V
	set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_100MHZ
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name USE_SIGNALTAP_FILE stp1.stp
	set_global_assignment -name VHDL_FILE adc_remap.vhd
	set_global_assignment -name SDC_FILE hpa.sdc
	set_global_assignment -name QIP_FILE xcvr_phy_pll/xcvr_phy_pll.qip
	set_global_assignment -name QIP_FILE transeiver_phy_rst/transeiver_phy_rst.qip
	set_global_assignment -name QIP_FILE transceiver_phy_wrap/transceiver_phy_wrap.qip
	set_global_assignment -name VHDL_FILE MA_filter.vhd
	set_global_assignment -name VHDL_FILE filter_bank.vhd
	set_global_assignment -name VHDL_FILE bus_mux.vhd
	set_global_assignment -name VERILOG_FILE udp_com.v
	set_global_assignment -name VHDL_FILE tca9534_i2c.vhd
	set_global_assignment -name VHDL_FILE rf_permit.vhd
	set_global_assignment -name VHDL_FILE registers.vhd
	set_global_assignment -name VHDL_FILE hv_ramp.vhd
	set_global_assignment -name VHDL_FILE hv_permit.vhd
	set_global_assignment -name VHDL_FILE HPA.vhd
	set_global_assignment -name VHDL_FILE heartbeat.vhd
	set_global_assignment -name VHDL_FILE fil_regs.vhd
	set_global_assignment -name VHDL_FILE fil_ramp.vhd
	set_global_assignment -name VHDL_FILE fil_mux.vhd
	set_global_assignment -name VHDL_FILE fil_dac.vhd
	set_global_assignment -name VHDL_FILE fil_ctrl.vhd
	set_global_assignment -name VHDL_FILE fault_comp.vhd
	set_global_assignment -name VHDL_FILE dac_ctrl.vhd
	set_global_assignment -name VHDL_FILE adc_ctrl.vhd
	set_global_assignment -name VERILOG_FILE pkg_comms_top/xformer.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/udp_port_cam.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/test_tx_mac.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/speed_test.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/scanner.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/rtefi_center.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/rtefi_blob.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/reg_delay.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/precog.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/pbuf_writer.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ones_chksum.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/negotiate.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/mem_gateway.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/mac_subset.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/hello.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/hack_icmp_cksum.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/gmii_link.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ethernet_crc_add.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/eth_gtx_bridge.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ep_tx_pcs.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ep_sync_detect.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/ep_rx_pcs.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/enc_8b10b.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/dec_8b10b.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/crc8e_guts.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/construct_tx_table.v
	set_global_assignment -name VERILOG_FILE pkg_comms_top/construct.v
	set_global_assignment -name BDF_FILE LLRF3_HPA_FPGA.bdf
	set_global_assignment -name IP_FILE temp.ip
	set_global_assignment -name SIGNALTAP_FILE stp1.stp
	set_global_assignment -name OPTIMIZATION_MODE "SUPERIOR PERFORMANCE WITH MAXIMUM PLACEMENT EFFORT"
	set_global_assignment -name VHDL_FILE counter.vhd
	set_global_assignment -name AUTO_RESERVE_CLKUSR_FOR_CALIBRATION OFF
	set_location_assignment PIN_U22 -to sfp_refclk_p
	set_location_assignment PIN_U21 -to "sfp_refclk_p(n)"
	set_location_assignment PIN_AD14 -to sfp_sda_0
	set_location_assignment PIN_AD15 -to sfp_scl_0
	set_location_assignment PIN_AB24 -to sfp_rx_0_p
	set_location_assignment PIN_AC26 -to sfp_tx_0_p
	set_location_assignment PIN_M1 -to reset_n
	set_location_assignment PIN_AC13 -to clock
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_tx_0_p -entity LLRF3_HPA_FPGA
	set_location_assignment PIN_AC25 -to "sfp_tx_0_p(n)"
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_refclk_p -entity LLRF3_HPA_FPGA
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_rx_0_p -entity LLRF3_HPA_FPGA
	set_location_assignment PIN_AB23 -to "sfp_rx_0_p(n)"
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to "sfp_refclk_p(n)" -entity LLRF3_HPA_FPGA
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to "sfp_rx_0_p(n)" -entity LLRF3_HPA_FPGA
	set_location_assignment PIN_P2 -to FPGA_HB
	set_location_assignment PIN_J4 -to FPGA_IO_HB
	set_location_assignment PIN_R4 -to FPGA_OE
	set_location_assignment PIN_K4 -to FPGA_IOC_HB
	set_location_assignment PIN_U1 -to din[0]
	set_location_assignment PIN_G1 -to din[1]
	set_location_assignment PIN_N3 -to din[2]
	set_location_assignment PIN_U4 -to din[3]
	set_location_assignment PIN_H2 -to din[4]
	set_location_assignment PIN_U5 -to din[5]
	set_location_assignment PIN_V1 -to din[6]
	set_location_assignment PIN_J3 -to din[7]
	set_location_assignment PIN_T3 -to dout[0]
	set_location_assignment PIN_H5 -to dout[1]
	set_location_assignment PIN_U3 -to dout[2]
	set_location_assignment PIN_H3 -to dout[3]
	set_location_assignment PIN_K5 -to dout[4]
	set_location_assignment PIN_G3 -to dout[5]
	set_location_assignment PIN_J5 -to dout[6]
	set_location_assignment PIN_H1 -to dout[7]
	set_location_assignment PIN_T4 -to FPGA_FAULT
	set_location_assignment PIN_P5 -to TX
	set_location_assignment PIN_R5 -to RX
	set_location_assignment PIN_B13 -to hv_permit[0]
	set_location_assignment PIN_C13 -to hv_permit[1]
	set_location_assignment PIN_AD18 -to hv_permit[2]
	set_location_assignment PIN_AC18 -to hv_permit[3]
	set_location_assignment PIN_AB19 -to hv_permit[4]
	set_location_assignment PIN_AA19 -to hv_permit[5]
	set_location_assignment PIN_AC17 -to hv_permit[6]
	set_location_assignment PIN_AC16 -to hv_permit[7]
	set_location_assignment PIN_B15 -to rf_permit[0]
	set_location_assignment PIN_C15 -to rf_permit[1]
	set_location_assignment PIN_A11 -to rf_permit[2]
	set_location_assignment PIN_B11 -to rf_permit[3]
	set_location_assignment PIN_AF19 -to rf_permit[4]
	set_location_assignment PIN_AE19 -to rf_permit[5]
	set_location_assignment PIN_AA21 -to rf_permit[6]
	set_location_assignment PIN_Y21 -to rf_permit[7]
	set_location_assignment PIN_B19 -to adc_cs_n[0]
	set_location_assignment PIN_C18 -to adc_cs_n[1]
	set_location_assignment PIN_D18 -to adc_cs_n[2]
	set_location_assignment PIN_B14 -to adc_cs_n[3]
	set_location_assignment PIN_AC21 -to adc_cs_n[4]
	set_location_assignment PIN_AA18 -to adc_cs_n[5]
	set_location_assignment PIN_W19 -to adc_cs_n[6]
	set_location_assignment PIN_AA17 -to adc_cs_n[7]
	set_location_assignment PIN_AC11 -to dac_clr_n[0]
	set_location_assignment PIN_Y15 -to dac_clr_n[1]
	set_location_assignment PIN_L2 -to dac_clr_n[2]
	set_location_assignment PIN_AB14 -to dac_cs_n[0]
	set_location_assignment PIN_K1 -to dac_cs_n[1]
	set_location_assignment PIN_N2 -to dac_cs_n[2]
	set_location_assignment PIN_AF6 -to dac_sck[0]
	set_location_assignment PIN_J2 -to dac_sck[1]
	set_location_assignment PIN_M4 -to dac_sck[2]
	set_location_assignment PIN_AB13 -to dac_sdi[0]
	set_location_assignment PIN_AE6 -to dac_sdi[1]
	set_location_assignment PIN_K2 -to dac_sdi[2]
	set_location_assignment PIN_D20 -to adc_convst_n[0]
	set_location_assignment PIN_C16 -to adc_convst_n[1]
	set_location_assignment PIN_D19 -to adc_convst_n[2]
	set_location_assignment PIN_D14 -to adc_convst_n[3]
	set_location_assignment PIN_E16 -to adc_convst_n[4]
	set_location_assignment PIN_AB20 -to adc_convst_n[5]
	set_location_assignment PIN_AE14 -to adc_convst_n[6]
	set_location_assignment PIN_W17 -to adc_convst_n[7]
	set_location_assignment PIN_E20 -to adc_shdn[0]
	set_location_assignment PIN_C17 -to adc_shdn[1]
	set_location_assignment PIN_C21 -to adc_shdn[2]
	set_location_assignment PIN_D17 -to adc_shdn[3]
	set_location_assignment PIN_C11 -to adc_shdn[4]
	set_location_assignment PIN_AC20 -to adc_shdn[5]
	set_location_assignment PIN_Y20 -to adc_shdn[6]
	set_location_assignment PIN_W18 -to adc_shdn[7]
	set_location_assignment PIN_G20 -to adc_rd_n[0]
	set_location_assignment PIN_G18 -to adc_rd_n[1]
	set_location_assignment PIN_E19 -to adc_rd_n[2]
	set_location_assignment PIN_F19 -to adc_rd_n[3]
	set_location_assignment PIN_F16 -to adc_rd_n[4]
	set_location_assignment PIN_AF16 -to adc_rd_n[5]
	set_location_assignment PIN_AE15 -to adc_rd_n[6]
	set_location_assignment PIN_AF11 -to adc_rd_n[7]
	set_location_assignment PIN_W9 -to adc_db[0]
	set_location_assignment PIN_AF8 -to adc_db[1]
	set_location_assignment PIN_W8 -to adc_db[2]
	set_location_assignment PIN_AF7 -to adc_db[3]
	set_location_assignment PIN_AB6 -to adc_db[4]
	set_location_assignment PIN_AF4 -to adc_db[5]
	set_location_assignment PIN_AB5 -to adc_db[6]
	set_location_assignment PIN_AF3 -to adc_db[7]
	set_location_assignment PIN_AD7 -to adc_db[8]
	set_location_assignment PIN_AC5 -to adc_db[9]
	set_location_assignment PIN_AE7 -to adc_db[10]
	set_location_assignment PIN_AD5 -to adc_db[11]
	set_location_assignment PIN_AE10 -to adc_db[12]
	set_location_assignment PIN_Y16 -to adc_db[13]
	set_location_assignment PIN_AF9 -to adc_db[14]
	set_location_assignment PIN_AA16 -to adc_db[15]
	set_location_assignment PIN_A19 -to adc_wr_n[0]
	set_location_assignment PIN_H18 -to adc_wr_n[1]
	set_location_assignment PIN_D15 -to adc_wr_n[2]
	set_location_assignment PIN_F18 -to adc_wr_n[3]
	set_location_assignment PIN_AB21 -to adc_wr_n[4]
	set_location_assignment PIN_AE16 -to adc_wr_n[5]
	set_location_assignment PIN_Y17 -to adc_wr_n[6]
	set_location_assignment PIN_AF12 -to adc_wr_n[7]
	set_location_assignment PIN_G19 -to adc_eoc[0]
	set_location_assignment PIN_B18 -to adc_eoc[1]
	set_location_assignment PIN_C20 -to adc_eoc[2]
	set_location_assignment PIN_A14 -to adc_eoc[3]
	set_location_assignment PIN_C12 -to adc_eoc[4]
	set_location_assignment PIN_AB18 -to adc_eoc[5]
	set_location_assignment PIN_Y19 -to adc_eoc[6]
	set_location_assignment PIN_AB16 -to adc_eoc[7]
	set_location_assignment PIN_AD9 -to gpio[0]
	set_location_assignment PIN_AC10 -to gpio[1]
	set_location_assignment PIN_AE4 -to gpio[2]
	set_location_assignment PIN_M3 -to gpio[3]
	set_location_assignment PIN_L3 -to gpio[4]
	set_location_assignment PIN_AA9 -to gpio[5]
	set_location_assignment PIN_AB8 -to gpio[6]
	set_location_assignment PIN_AE5 -to gpio[7]
	set_location_assignment PIN_AA14 -to gpio[8]
	set_location_assignment PIN_Y14 -to gpio[9]
	set_location_assignment PIN_AD8 -to gpio[10]
	set_location_assignment PIN_AC8 -to gpio[11]
	set_location_assignment PIN_AC6 -to gpio[12]
	set_location_assignment PIN_AC7 -to gpio[13]
	set_location_assignment PIN_AE9 -to gpio[14]
	set_location_assignment PIN_AD10 -to gpio[15]
	set_location_assignment PIN_M5 -to gpio_dir1
	set_location_assignment PIN_N5 -to gpio_dir2
	set_location_assignment PIN_W15 -to gpio_oe1
	set_location_assignment PIN_L4 -to gpio_oe2

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
