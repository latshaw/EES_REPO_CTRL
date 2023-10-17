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
# File: interlocks_control_fpga_rev_pr1_rev.tcl
# Generated on: Tue Oct 17 15:49:03 2023

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "interlocks_control_fpga_rev_pr1_rev"]} {
		puts "Project interlocks_control_fpga_rev_pr1_rev is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists interlocks_control_fpga_rev_pr1_rev]} {
		project_open -revision interlocks_control_fpga_rev_pr1_rev interlocks_control_fpga_rev_pr1_rev
	} else {
		project_new -revision interlocks_control_fpga_rev_pr1_rev interlocks_control_fpga_rev_pr1_rev
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name AUTO_RESERVE_CLKUSR_FOR_CALIBRATION OFF
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "11:47:48  NOVEMBER 19, 2020"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Pro Edition"
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name FAMILY "Cyclone 10 GX"
	set_global_assignment -name TOP_LEVEL_ENTITY interlocks_control
	set_global_assignment -name DEVICE 10CX105YF672E5G
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name USE_SIGNALTAP_FILE output_files/stp2.stp
	set_global_assignment -name POWER_AUTO_COMPUTE_TJ ON
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
	set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
	set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X1"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name GENERATE_PR_RBF_FILE OFF
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN ON
	set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_100MHZ
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name ENABLE_LOGIC_ANALYZER_INTERFACE OFF
	set_global_assignment -name VHDL_FILE gen_i2c.vhd
	set_global_assignment -name VHDL_FILE LED_CONTROL.vhd
	set_global_assignment -name SDC_FILE cyclone10gx_main.sdc
	set_global_assignment -name SDC_FILE interlocks_control_fpga_rev_pr1_rev.out.sdc
	set_global_assignment -name QIP_FILE fpga_tsd_int/fpga_tsd_int.qip
	set_global_assignment -name QIP_FILE transceiver_phy_wrap/transceiver_phy_wrap.qip
	set_global_assignment -name QIP_FILE remote_download/remote_download.qip
	set_global_assignment -name QIP_FILE epcs/epcs.qip
	set_global_assignment -name VERILOG_FILE dpram.v
	set_global_assignment -name VERILOG_FILE cyclone.v
	set_global_assignment -name VHDL_FILE ram_8.vhd
	set_global_assignment -name QIP_FILE PLL_125_to_5/PLL_125_to_5.qip
	set_global_assignment -name VHDL_FILE ADS8353.vhd
	set_global_assignment -name VERILOG_FILE pkg_comms_top/precog.v
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
	set_global_assignment -name VHDL_FILE tca9534_i2c.vhd
	set_global_assignment -name VHDL_FILE Heartbeat_ISA.vhd
	set_global_assignment -name VHDL_FILE Heartbeat_FP.vhd
	set_global_assignment -name VHDL_FILE WAVEGUIDE_VAC_FAULT.vhd
	set_global_assignment -name VHDL_FILE WARM_WINDOW_FAULT.vhd
	set_global_assignment -name VHDL_FILE VAC_FAULT_STATUS.vhd
	set_global_assignment -name VERILOG_FILE udp_com.v
	set_global_assignment -name VHDL_FILE uart_0.vhd
	set_global_assignment -name VHDL_FILE TMP_COMPARE.vhd
	set_global_assignment -name VHDL_FILE timer_0.vhd
	set_global_assignment -name VHDL_FILE TEMP_LIMIT_COEFF.vhd
	set_global_assignment -name VHDL_FILE RESETS.vhd
	set_global_assignment -name VHDL_FILE REGS.vhd
	set_global_assignment -name VHDL_FILE pio_2.vhd
	set_global_assignment -name VHDL_FILE pio_1.vhd
	set_global_assignment -name VHDL_FILE pio_0.vhd
	set_global_assignment -name VHDL_FILE onchip_memory2_0.vhd
	set_global_assignment -name VHDL_FILE MCP3202.vhd
	set_global_assignment -name VHDL_FILE lpm_ram_dq0.vhd
	set_global_assignment -name VHDL_FILE lpm_counter1.vhd
	set_global_assignment -name VHDL_FILE lpm_counter0.vhd
	set_global_assignment -name VHDL_FILE jtag_uart_0.vhd
	set_global_assignment -name VHDL_FILE ISA_BUS.vhd
	set_global_assignment -name VHDL_FILE interlocks_control.vhd
	set_global_assignment -name VHDL_FILE interlock_test.vhd
	set_global_assignment -name VHDL_FILE Interlock_LCD.vhd
	set_global_assignment -name VHDL_FILE INTERLOCK_ENABLE.vhd
	set_global_assignment -name VHDL_FILE INTEN_FC_FSD.vhd
	set_global_assignment -name VHDL_FILE IIRK_SIMPLE.vhd
	set_global_assignment -name VHDL_FILE FC_FSD.vhd
	set_global_assignment -name VHDL_FILE DAC8568_CONTROL.vhd
	set_global_assignment -name VHDL_FILE cpu_0_test_bench.vhd
	set_global_assignment -name VHDL_FILE cpu_0_oci_test_bench.vhd
	set_global_assignment -name VHDL_FILE cpu_0_mult_cell.vhd
	set_global_assignment -name VHDL_FILE cpu_0_jtag_debug_module_wrapper.vhd
	set_global_assignment -name VHDL_FILE cpu_0_jtag_debug_module_tck.vhd
	set_global_assignment -name VHDL_FILE cpu_0_jtag_debug_module_sysclk.vhd
	set_global_assignment -name VHDL_FILE cpu_0.vhd
	set_global_assignment -name VHDL_FILE components.vhd
	set_global_assignment -name VHDL_FILE COLD_WINDOW_FAULT.vhd
	set_global_assignment -name VHDL_FILE arc_test_gen.vhd
	set_global_assignment -name VHDL_FILE ARC_FAULT.vhd
	set_global_assignment -name VHDL_FILE ARC_COMPARE.vhd
	set_global_assignment -name VHDL_FILE AD7367_CONTROL.vhd
	set_global_assignment -name VHDL_FILE AD7328_CONTROL.vhd
	set_global_assignment -name VHDL_FILE ADS8684.vhd
	set_global_assignment -name VHDL_FILE arc_buffer_module.vhd
	set_global_assignment -name IP_FILE PLL_125_to_5.ip
	set_global_assignment -name SIGNALTAP_FILE stp1.stp
	set_global_assignment -name VHDL_FILE ads8353_arc.vhd
	set_global_assignment -name SIGNALTAP_FILE output_files/stp2.stp
	set_global_assignment -name IP_FILE EPCQ.ip
	set_location_assignment PIN_Y20 -to ARC_SDO_B_3
	set_location_assignment PIN_Y19 -to ARC_SDO_A_3
	set_location_assignment PIN_Y17 -to ARC_SDO_A_1
	set_location_assignment PIN_Y15 -to TMP_SDI_3
	set_location_assignment PIN_W9 -to TMP_SDO_2
	set_location_assignment PIN_W8 -to TMP_SDO_1
	set_location_assignment PIN_W19 -to ARC_SDO_B_4
	set_location_assignment PIN_W18 -to ARC_SDO_A_4
	set_location_assignment PIN_W17 -to ARC_SDO_B_2
	set_location_assignment PIN_W15 -to TMP_CS_n_3
	set_location_assignment PIN_U5 -to TMPCLDTST5_FPGA
	set_location_assignment PIN_U4 -to TMPWRMTST8_FPGA
	set_location_assignment PIN_U3 -to LED_SDA
	set_location_assignment PIN_U1 -to VAC_CAV4_FPGA
	set_location_assignment PIN_T3 -to LED_SCL
	set_location_assignment PIN_N3 -to TMP_SDO_4
	set_location_assignment PIN_N2 -to TMP_SDO_3
	set_location_assignment PIN_M4 -to TMPWRMTST5_FPGA
	set_location_assignment PIN_L4 -to TMPCLDTST8_FPGA
	set_location_assignment PIN_L2 -to TMPCLDTST6_FPGA
	set_location_assignment PIN_K5 -to VAC_CAV6_FPGA
	set_location_assignment PIN_K2 -to TMP_SDI_4
	set_location_assignment PIN_K1 -to TMPWRMTST7_FPGA
	set_location_assignment PIN_J5 -to VAC_CAV5_FPGA
	set_location_assignment PIN_J3 -to TMP_SCLK_4
	set_location_assignment PIN_J2 -to TMP_SCLK_3
	set_location_assignment PIN_H6 -to VAC_CAV1_FPGA
	set_location_assignment PIN_H5 -to VAC_CAV2_FPGA
	set_location_assignment PIN_H3 -to VAC_CAV3_FPGA
	set_location_assignment PIN_H2 -to TMP_CS_n_4
	set_location_assignment PIN_F18 -to FLT_CAV2_FPGA
	set_location_assignment PIN_H1 -to VAC_CAV8_FPGA
	set_location_assignment PIN_G3 -to VAC_CAV7_FPGA
	set_location_assignment PIN_G20 -to ARCTST2_FPGA
	set_location_assignment PIN_G19 -to ARCTST7_FPGA
	set_location_assignment PIN_E16 -to FLT_CAV1_FPGA
	set_location_assignment PIN_G1 -to VAC_BMLN_FPGA
	set_location_assignment PIN_D19 -to FLT_CAV7_FPGA
	set_location_assignment PIN_H18 -to FLT_CAV8_FPGA
	set_location_assignment PIN_F16 -to ARC_SCLK_1
	set_location_assignment PIN_D14 -to FLT_CAV4_FPGA
	set_location_assignment PIN_G18 -to FSD_MAIN_FPGA
	set_location_assignment PIN_F19 -to FLT_CAV3_FPGA
	set_location_assignment PIN_D18 -to FSD_CAV5_FPGA
	set_location_assignment PIN_D17 -to FSD_CAV6_FPGA
	set_location_assignment PIN_D15 -to FLT_CAV5_FPGA
	set_location_assignment PIN_E19 -to FLT_CAV6_FPGA
	set_location_assignment PIN_C21 -to FSD_CAV3_FPGA
	set_location_assignment PIN_C20 -to FSD_CAV4_FPGA
	set_location_assignment PIN_C18 -to FSD_CAV2_FPGA
	set_location_assignment PIN_C17 -to ARCTST4_FPGA
	set_location_assignment PIN_C16 -to ARCTST5_FPGA
	set_location_assignment PIN_C13 -to ARCTST8_FPGA
	set_location_assignment PIN_C12 -to ARC_CS_n_3
	set_location_assignment PIN_C11 -to ARC_SCLK_3
	set_location_assignment PIN_B19 -to ARCTST6_FPGA
	set_location_assignment PIN_B18 -to FSD_CAV1_FPGA
	set_location_assignment PIN_B14 -to FSD_CAV8_FPGA
	set_location_assignment PIN_B13 -to ARCTST1_FPGA
	set_location_assignment PIN_AF8 -to TMPWRMTST1_FPGA
	set_location_assignment PIN_AF7 -to TMPCLDTST4_FPGA
	set_location_assignment PIN_AF6 -to TMPCLDTST7_FPGA
	set_location_assignment PIN_AF4 -to TMPCLDTST2_FPGA
	set_location_assignment PIN_AF3 -to TMPWRMTST3_FPGA
	set_location_assignment PIN_AF16 -to ARC_SCLK_2
	set_location_assignment PIN_AF11 -to ARC_SDO_A_2
	set_location_assignment PIN_AE7 -to TMP_SDI_1
	set_location_assignment PIN_AE6 -to TMPWRMTST6_FPGA
	set_location_assignment PIN_AE16 -to ARC_CS_n_2
	set_location_assignment PIN_AE15 -to ARC_SDO_B_1
	set_location_assignment PIN_AE14 -to ARC_SDI_2
	set_location_assignment PIN_AD7 -to TMP_CS_n_1
	set_location_assignment PIN_AD5 -to TMPCLDTST3_FPGA
	set_location_assignment PIN_AC5 -to TMPWRMTST2_FPGA
	set_location_assignment PIN_AC21 -to ARC_SDI_3
	set_location_assignment PIN_AC20 -to ARC_SCLK_4
	set_location_assignment PIN_AC11 -to TMPWRMTST4_FPGA
	set_location_assignment PIN_AB6 -to TMP_SDI_2
	set_location_assignment PIN_AB5 -to TMP_SCLK_1
	set_location_assignment PIN_AB21 -to ARC_CS_n_1
	set_location_assignment PIN_AB20 -to ARC_SDI_1
	set_location_assignment PIN_AB18 -to ARC_CS_n_4
	set_location_assignment PIN_AB16 -to IPT_SHDN
	set_location_assignment PIN_AB14 -to TMP_SCLK_2
	set_location_assignment PIN_AB13 -to TMP_CS_n_2
	set_location_assignment PIN_AB11 -to TMPCLDTST1_FPGA
	set_location_assignment PIN_AA18 -to ARC_SDI_4
	set_location_assignment PIN_A19 -to ARCTST3_FPGA
	set_location_assignment PIN_A14 -to FSD_CAV7_FPGA
	set_location_assignment PIN_P2 -to LED0
	set_location_assignment PIN_N1 -to LED1
	set_location_assignment PIN_T1 -to LED2
	set_location_assignment PIN_R2 -to LED3
	set_location_assignment PIN_M1 -to RESET
	set_location_assignment PIN_Y10 -to m10_reset
	set_location_assignment PIN_U22 -to sfp_refclk_p
	set_location_assignment PIN_U21 -to "sfp_refclk_p(n)"
	set_location_assignment PIN_AB24 -to sfp_rx_0_p
	set_location_assignment PIN_AB23 -to "sfp_rx_0_p(n)"
	set_location_assignment PIN_AD15 -to sfp_scl_0
	set_location_assignment PIN_AD14 -to sfp_sda_0
	set_location_assignment PIN_AC26 -to sfp_tx_0_p
	set_location_assignment PIN_AC25 -to "sfp_tx_0_p(n)"
	set_location_assignment PIN_AD24 -to SGMII1_RX_P
	set_location_assignment PIN_AD23 -to "SGMII1_RX_P(n)"
	set_location_assignment PIN_AE26 -to SGMII1_TX_P
	set_location_assignment PIN_AE25 -to "SGMII1_TX_P(n)"
	set_location_assignment PIN_AF17 -to ETH1_RESET_N
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST1_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST2_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST3_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST4_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST5_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST6_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST7_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARCTST8_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_CS_n_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_CS_n_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_CS_n_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_CS_n_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SCLK_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SCLK_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SCLK_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SCLK_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDI_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDI_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDI_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDI_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_A_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_A_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_A_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_A_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_B_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_B_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_B_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to ARC_SDO_B_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV1_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV2_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV3_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV4_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV5_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV6_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV7_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FLT_CAV8_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV1_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV2_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV3_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV4_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV5_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV6_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV7_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_CAV8_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to FSD_MAIN_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to IPT_SHDN -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED0 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SCL -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to LED_SDA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to RESET -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST1_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST2_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST3_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST4_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST5_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST6_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST7_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPCLDTST8_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST1_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST2_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST3_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST4_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST5_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST6_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST7_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMPWRMTST8_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_CS_n_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_CS_n_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_CS_n_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_CS_n_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SCLK_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SCLK_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SCLK_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SCLK_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDI_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDI_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDI_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDI_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDO_1 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDO_2 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDO_3 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TMP_SDO_4 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_BMLN_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV1_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV2_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV3_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV4_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV5_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV6_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV7_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to VAC_CAV8_FPGA -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to m10_reset -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_refclk_p -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "CURRENT MODE LOGIC (CML)" -to sfp_rx_0_p -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_scl_0 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to sfp_sda_0 -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_tx_0_p -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to PWR_EN_5V -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to PWR_SYNC_5V -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to PWR_EN_33V -entity interlocks_control
	set_instance_assignment -name IO_STANDARD "1.8 V" -to PWR_SYNC_33V -entity interlocks_control
	set_location_assignment PIN_AB8 -to PWR_EN_5V
	set_location_assignment PIN_AA9 -to PWR_SYNC_5V
	set_location_assignment PIN_P5 -to PWR_EN_33V
	set_location_assignment PIN_T4 -to PWR_SYNC_33V
	set_location_assignment PIN_R1 -to TST_SW
	set_instance_assignment -name IO_STANDARD "1.8 V" -to TST_SW -entity interlocks_control

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
