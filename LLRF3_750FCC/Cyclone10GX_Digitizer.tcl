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
# File: Cyclone10GX_Digitizer.tcl
# Generated on: Fri Jun 21 14:45:47 2024

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "Cyclone10GX_Digitizer"]} {
		puts "Project Cyclone10GX_Digitizer is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists Cyclone10GX_Digitizer]} {
		project_open -revision Cyclone10GX_Digitizer Cyclone10GX_Digitizer
	} else {
		project_new -revision Cyclone10GX_Digitizer Cyclone10GX_Digitizer
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name TOP_LEVEL_ENTITY cyclone10gx_digitizer_main
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.0.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "16:58:54  AUGUST 13, 2018"
	set_global_assignment -name LAST_QUARTUS_VERSION "18.1.0 Pro Edition"
	set_global_assignment -name FAMILY "Cyclone 10 GX"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 100
	set_global_assignment -name DEVICE 10CX105YF672E6G
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 4
	set_global_assignment -name EDA_SIMULATION_TOOL "Active-HDL (VHDL)"
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT VHDL -section_id eda_simulation
	set_global_assignment -name POWER_AUTO_COMPUTE_TJ ON
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 672
	set_global_assignment -name STRATIXV_CONFIGURATION_SCHEME "ACTIVE SERIAL X4"
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name STRATIXII_CONFIGURATION_DEVICE MT25QU01G
	set_global_assignment -name GENERATE_PR_RBF_FILE OFF
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN ON
	set_global_assignment -name ACTIVE_SERIAL_CLOCK FREQ_100MHZ
	set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
	set_global_assignment -name VHDL_INPUT_VERSION VHDL_2008
	set_global_assignment -name VHDL_SHOW_LMF_MAPPING_MESSAGES OFF
	set_global_assignment -name TIMING_ANALYZER_MULTICORNER_ANALYSIS ON
	set_global_assignment -name NUM_PARALLEL_PROCESSORS ALL
	set_global_assignment -name VHDL_FILE reset_all.vhd
	set_global_assignment -name VERILOG_FILE cyclone_ru_only.v
	set_global_assignment -name VHDL_FILE rfwd_wrapper.vhd
	set_global_assignment -name VERILOG_FILE dpram_lbnl.v
	set_global_assignment -name VERILOG_FILE cyclone.v
	set_global_assignment -name SDC_FILE Cyclone10GX_Digitizer.out.sdc
	set_global_assignment -name VHDL_FILE dpram_adc_dac_clkdom_xing.vhd
	set_global_assignment -name VHDL_FILE fib_ctl.vhd
	set_global_assignment -name VHDL_FILE dpram_clkdom_xing.vhd
	set_global_assignment -name VHDL_FILE beam_permit_magphs.vhd
	set_global_assignment -name VHDL_FILE pulse_mode_sep.vhd
	set_global_assignment -name VHDL_FILE marvell_phy_config.vhd
	set_global_assignment -name VHDL_FILE lmk04808.vhd
	set_global_assignment -name VHDL_FILE cordic/iq2mp_18bit.vhd
	set_global_assignment -name VHDL_FILE var_att.vhd
	set_global_assignment -name VHDL_FILE noniq_dac186MHz.vhd
	set_global_assignment -name VHDL_FILE ad9653.vhd
	set_global_assignment -name VHDL_FILE Cyclone10GX_Digitizer_Main.vhd
	set_global_assignment -name IP_FILE adc_pll0.ip
	set_global_assignment -name VHDL_FILE COMPONENTS.vhd
	set_global_assignment -name VHDL_FILE HEARTBEAT_ISA.vhd -library altera_work
	set_global_assignment -name IP_FILE ip/digitizer_fpga/digitizer_fpga_clock_in.ip
	set_global_assignment -name IP_FILE ip/digitizer_fpga/digitizer_fpga_reset_in.ip
	set_global_assignment -name QSYS_FILE digitizer_fpga.qsys
	set_global_assignment -name IP_FILE ip/test_nco.ip
	set_global_assignment -name BDF_FILE Cyclone10GX_Digitizer_Top.bdf
	set_global_assignment -name IP_FILE adc_lvds_rx.ip
	set_global_assignment -name VHDL_FILE adc_data_acq.vhd
	set_global_assignment -name VHDL_FILE noniq_dac.vhd
	set_global_assignment -name IP_FILE dac_ddr.ip
	set_global_assignment -name VHDL_FILE ad9653_ddr_acq.vhd
	set_global_assignment -name IP_FILE adc_lvds_rx1.ip
	set_global_assignment -name VHDL_FILE noniq_adc.vhd
	set_global_assignment -name IP_FILE dac_ddr_1bit.ip
	set_global_assignment -name VHDL_FILE ad9781.vhd
	set_global_assignment -name VHDL_FILE adc_dac_spi.vhd
	set_global_assignment -name VHDL_FILE IIR7_SIMPLE.vhd
	set_global_assignment -name IP_FILE ip/io_diff_delay/io_diff_delay_clock_in.ip
	set_global_assignment -name IP_FILE ip/io_diff_delay/io_diff_delay_reset_in.ip
	set_global_assignment -name QSYS_FILE io_diff_delay.qsys
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
	set_global_assignment -name VHDL_FILE tca9534_i2c.vhd
	set_global_assignment -name IP_FILE ip/gxb_phy/gxb_phy_clock_in.ip
	set_global_assignment -name IP_FILE ip/gxb_phy/gxb_phy_reset_in.ip
	set_global_assignment -name IP_FILE ip/gxb_phy/gxb_phy_xcvr_native_a10_0.ip
	set_global_assignment -name IP_FILE transceiver_phy_wrap.ip
	set_global_assignment -name VERILOG_FILE comms_top.v
	set_global_assignment -name IP_FILE transeiver_phy_rst.ip
	set_global_assignment -name IP_FILE xcvr_phy_pll.ip
	set_global_assignment -name IP_FILE ip/dpram/dpram_ram_2port_0.ip
	set_global_assignment -name VHDL_FILE cirbuf_data.vhd
	set_global_assignment -name VHDL_FILE noniq_adc_lut.vhd
	set_global_assignment -name VHDL_FILE lmk03328_i2c.vhd
	set_global_assignment -name VHDL_FILE adc_bit_align.vhd
	set_global_assignment -name VHDL_FILE dpa_ptrn_match.vhd
	set_global_assignment -name VHDL_FILE iir9_simple.vhd
	set_global_assignment -name VHDL_FILE digio_test.vhd
	set_global_assignment -name VHDL_FILE dac8831.vhd
	set_global_assignment -name VHDL_FILE ads8353.vhd
	set_global_assignment -name VHDL_FILE IO_Expander_TCA6416A.vhd
	set_global_assignment -name VHDL_FILE i2c.vhd
	set_global_assignment -name VHDL_FILE heartbeat.vhd
	set_global_assignment -name VHDL_FILE cordic/mp2iq_reg_new.vhd
	set_global_assignment -name VHDL_FILE cordic/mp2iq_init_new.vhd
	set_global_assignment -name VHDL_FILE cordic/mp2iq.vhd
	set_global_assignment -name VHDL_FILE cordic/shift_by_m.vhd
	set_global_assignment -name VHDL_FILE var_attn.vhd
	set_global_assignment -name VHDL_FILE freq_disc.vhd
	set_global_assignment -name IP_FILE fpga_tsd_int.ip
	set_global_assignment -name VHDL_FILE cordic/iq2mp_init18.vhd
	set_global_assignment -name VHDL_FILE cordic/iq2mp_reg26.vhd
	set_global_assignment -name VHDL_FILE cordic/cordic_shift18.vhd
	set_global_assignment -name VHDL_FILE dc_reject.vhd
	set_global_assignment -name VHDL_FILE pkg_comms_top/comms_regbank.vhd
	set_global_assignment -name VHDL_FILE fcc_data_out.vhd
	set_global_assignment -name VHDL_FILE polynomial_division.vhd
	set_global_assignment -name VHDL_FILE stepper_data.vhd
	set_global_assignment -name VHDL_FILE frrmp.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk9.vhd
	set_global_assignment -name VHDL_FILE cordic/iq2mp_18bit_small.vhd
	set_global_assignment -name VHDL_FILE fir_prb.vhd
	set_global_assignment -name VHDL_FILE freq_disc_phs.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk13.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk10.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk6.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk2.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk5.vhd
	set_global_assignment -name VHDL_FILE rotate_matrix.vhd
	set_global_assignment -name VHDL_FILE loop_mux.vhd
	set_global_assignment -name VHDL_FILE pi_control.vhd
	set_global_assignment -name VHDL_FILE xylim.vhd
	set_global_assignment -name VHDL_FILE deta_module.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk18.vhd
	set_global_assignment -name VHDL_FILE detune_calc.vhd
	set_global_assignment -name VHDL_FILE clk_dom_xing.vhd
	set_global_assignment -name VHDL_FILE state_phs_res.vhd
	set_global_assignment -name VHDL_FILE cic.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk7.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk11.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk15.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk12.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk8.vhd
	set_global_assignment -name VHDL_FILE iir_lpfk4.vhd
	set_global_assignment -name IP_FILE pll_100MHzto40MHz.ip
	set_global_assignment -name IP_FILE epcs.ip
	set_global_assignment -name VHDL_FILE epcs_cntl.vhd
	set_global_assignment -name VHDL_FILE pulse_mode.vhd
	set_global_assignment -name VHDL_FILE kly_char.vhd
	set_global_assignment -name VHDL_FILE fccid_rw.vhd
	set_global_assignment -name VHDL_FILE pulse_mode_all.vhd
	set_global_assignment -name VHDL_FILE adc_dac_cdc.vhd
	set_global_assignment -name VHDL_FILE quench_det.vhd
	set_global_assignment -name VHDL_FILE flt_clr_cdc.vhd
	set_global_assignment -name IP_FILE ip/fast_adc_romem/fast_adc_romem_clock_in.ip
	set_global_assignment -name IP_FILE ip/fast_adc_romem/fast_adc_romem_reset_in.ip
	set_global_assignment -name VHDL_FILE fast_adc_cdc.vhd
	set_global_assignment -name IP_FILE reg_dpram.ip
	set_global_assignment -name VHDL_FILE phs_ramp.vhd
	set_global_assignment -name VHDL_FILE rdmux16to1.vhd
	set_global_assignment -name VHDL_FILE dpram_gen.vhd
	set_global_assignment -name VHDL_FILE dpram_rdreg.vhd
	set_global_assignment -name VHDL_FILE rdmux8to1.vhd
	set_global_assignment -name IP_FILE reg_rd_dpram.ip
	set_global_assignment -name VHDL_FILE dpram_wrreg.vhd
	set_global_assignment -name VHDL_FILE wrmux16to1.vhd
	set_global_assignment -name VHDL_FILE wrmux8to1.vhd
	set_global_assignment -name VHDL_FILE firn.vhd
	set_global_assignment -name VHDL_FILE mp_mux.vhd
	set_global_assignment -name VHDL_FILE grad_phs_rmp.vhd
	set_global_assignment -name IP_FILE EPCQ.ip
	set_global_assignment -name IP_FILE remote_download.ip
	set_instance_assignment -name IO_STANDARD LVDS -to adc_dclk_p -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[8] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[7] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[6] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[5] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[4] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[3] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[2] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[1] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to adc_data_in[0] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_dclk_p -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[8] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[7] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[6] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[5] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[4] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[3] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[2] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[1] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to adc_data_in[0] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_dco_p -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_dci_p -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[13] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[12] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[11] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[10] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[9] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[8] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[7] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[6] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[5] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[4] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[3] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[2] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[1] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to dac_data_p[0] -entity cyclone10gx_digitizer_main
	set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to dac_dco_p -entity cyclone10gx_digitizer_main
	set_location_assignment PIN_C17 -to adc_dclk_p
	set_location_assignment PIN_C16 -to "adc_dclk_p(n)"
	set_location_assignment PIN_D20 -to adc_data_in[8]
	set_location_assignment PIN_E20 -to "adc_data_in[8](n)"
	set_location_assignment PIN_B18 -to adc_data_in[7]
	set_location_assignment PIN_C18 -to "adc_data_in[7](n)"
	set_location_assignment PIN_G18 -to adc_data_in[6]
	set_location_assignment PIN_H18 -to "adc_data_in[6](n)"
	set_location_assignment PIN_C21 -to adc_data_in[5]
	set_location_assignment PIN_C20 -to "adc_data_in[5](n)"
	set_location_assignment PIN_D19 -to adc_data_in[4]
	set_location_assignment PIN_E19 -to "adc_data_in[4](n)"
	set_location_assignment PIN_A19 -to adc_data_in[3]
	set_location_assignment PIN_B19 -to "adc_data_in[3](n)"
	set_location_assignment PIN_D18 -to adc_data_in[2]
	set_location_assignment PIN_D17 -to "adc_data_in[2](n)"
	set_location_assignment PIN_D15 -to adc_data_in[1]
	set_location_assignment PIN_D14 -to "adc_data_in[1](n)"
	set_location_assignment PIN_G20 -to adc_data_in[0]
	set_location_assignment PIN_G19 -to "adc_data_in[0](n)"
	set_location_assignment PIN_AF19 -to dac_dco_p
	set_location_assignment PIN_AE19 -to "dac_dco_p(n)"
	set_location_assignment PIN_AD18 -to dac_dci_p
	set_location_assignment PIN_AC18 -to "dac_dci_p(n)"
	set_location_assignment PIN_AB21 -to dac_data_p[13]
	set_location_assignment PIN_AB20 -to "dac_data_p[13](n)"
	set_location_assignment PIN_AB18 -to dac_data_p[12]
	set_location_assignment PIN_AA18 -to "dac_data_p[12](n)"
	set_location_assignment PIN_AB19 -to dac_data_p[11]
	set_location_assignment PIN_AA19 -to "dac_data_p[11](n)"
	set_location_assignment PIN_AC17 -to dac_data_p[10]
	set_location_assignment PIN_AC16 -to "dac_data_p[10](n)"
	set_location_assignment PIN_AF16 -to dac_data_p[9]
	set_location_assignment PIN_AE16 -to "dac_data_p[9](n)"
	set_location_assignment PIN_AA21 -to dac_data_p[8]
	set_location_assignment PIN_Y21 -to "dac_data_p[8](n)"
	set_location_assignment PIN_Y20 -to dac_data_p[7]
	set_location_assignment PIN_Y19 -to "dac_data_p[7](n)"
	set_location_assignment PIN_AE14 -to dac_data_p[6]
	set_location_assignment PIN_AE15 -to "dac_data_p[6](n)"
	set_location_assignment PIN_W19 -to dac_data_p[5]
	set_location_assignment PIN_W18 -to "dac_data_p[5](n)"
	set_location_assignment PIN_Y17 -to dac_data_p[4]
	set_location_assignment PIN_W17 -to "dac_data_p[4](n)"
	set_location_assignment PIN_AB16 -to dac_data_p[3]
	set_location_assignment PIN_AA17 -to "dac_data_p[3](n)"
	set_location_assignment PIN_AF11 -to dac_data_p[2]
	set_location_assignment PIN_AF12 -to "dac_data_p[2](n)"
	set_location_assignment PIN_AA16 -to dac_data_p[1]
	set_location_assignment PIN_Y16 -to "dac_data_p[1](n)"
	set_location_assignment PIN_AF9 -to dac_data_p[0]
	set_location_assignment PIN_AE10 -to "dac_data_p[0](n)"
	set_location_assignment PIN_B13 -to pwr_en
	set_location_assignment PIN_C11 -to pwr_sync
	set_location_assignment PIN_F19 -to ad9781_ncs
	set_location_assignment PIN_F18 -to ad9781_rst
	set_location_assignment PIN_C13 -to ad9781_sclk
	set_location_assignment PIN_F16 -to ad9781_sdi
	set_location_assignment PIN_AC20 -to ad9653_ncs
	set_location_assignment PIN_A11 -to ad9653_sdio
	set_location_assignment PIN_AC21 -to ad9653_sclk
	set_location_assignment PIN_AC13 -to clock
	set_location_assignment PIN_M1 -to reset
	set_location_assignment PIN_Y10 -to m10_reset
	set_location_assignment PIN_P2 -to hb_fpga
	set_location_assignment PIN_AD14 -to sfp_sda_0
	set_location_assignment PIN_AD15 -to sfp_scl_0
	set_location_assignment PIN_E5 -to adc0_sclk
	set_location_assignment PIN_E4 -to adc0_ncs
	set_location_assignment PIN_D5 -to adc0_sdi
	set_location_assignment PIN_D4 -to adc1_sclk
	set_location_assignment PIN_B6 -to adc1_ncs
	set_location_assignment PIN_D10 -to adc1_sdi
	set_location_assignment PIN_E7 -to adc0_sdo_b
	set_location_assignment PIN_E6 -to adc0_sdo_a
	set_location_assignment PIN_F4 -to adc1_sdo_b
	set_location_assignment PIN_F3 -to adc1_sdo_a
	set_location_assignment PIN_G5 -to dac_sclk
	set_location_assignment PIN_G4 -to dac_ncs
	set_location_assignment PIN_F8 -to dac0_sdi
	set_location_assignment PIN_D9 -to dac1_sdi
	set_location_assignment PIN_E11 -to dac2_sdi
	set_location_assignment PIN_E10 -to dac3_sdi
	set_location_assignment PIN_C8 -to ratn_sdata
	set_location_assignment PIN_C7 -to ratn_sclk
	set_location_assignment PIN_D7 -to rfsw
	set_location_assignment PIN_A7 -to ratn_le
	set_location_assignment PIN_B10 -to led_scl
	set_location_assignment PIN_B9 -to led_sda
	set_location_assignment PIN_B3 -to fib_out[0]
	set_location_assignment PIN_A9 -to fib_out[1]
	set_location_assignment PIN_A8 -to fib_out[2]
	set_location_assignment PIN_D3 -to fib_out[3]
	set_location_assignment PIN_D2 -to fib_in[0]
	set_location_assignment PIN_C3 -to fib_in[1]
	set_location_assignment PIN_C2 -to fib_in[2]
	set_location_assignment PIN_C1 -to fib_in[3]
	set_location_assignment PIN_B1 -to dig_out[0]
	set_location_assignment PIN_A3 -to dig_out[1]
	set_location_assignment PIN_A2 -to dig_out[2]
	set_location_assignment PIN_E2 -to dig_out[3]
	set_location_assignment PIN_E1 -to dig_in[2]
	set_location_assignment PIN_F2 -to dig_in[1]
	set_location_assignment PIN_F1 -to dig_in[0]
	set_location_assignment PIN_E17 -to pmod_io[5]
	set_location_assignment PIN_F17 -to pmod_io[4]
	set_location_assignment PIN_B16 -to pmod_io[3]
	set_location_assignment PIN_F21 -to pmod_io[2]
	set_location_assignment PIN_A17 -to pmod_io[1]
	set_location_assignment PIN_A18 -to pmod_io[0]
	set_location_assignment PIN_U22 -to sfp_refclk_p
	set_location_assignment PIN_U21 -to "sfp_refclk_p(n)"
	set_location_assignment PIN_AD24 -to sfp_rx_0_p
	set_location_assignment PIN_AD23 -to "sfp_rx_0_p(n)"
	set_location_assignment PIN_AE26 -to sfp_tx_0_p
	set_location_assignment PIN_AE25 -to "sfp_tx_0_p(n)"
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_rx_0_p -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD "HIGH SPEED DIFFERENTIAL I/O" -to sfp_tx_0_p -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD LVDS -to sfp_refclk_p -entity cyclone10gx_digitizer_main
	set_location_assignment PIN_B15 -to lmk04808_sync
	set_location_assignment PIN_B11 -to lmk04808_le
	set_location_assignment PIN_B14 -to lmk04808_scl
	set_location_assignment PIN_A14 -to lmk04808_sda
	set_location_assignment PIN_AF17 -to ETH1_RESET_N
	set_location_assignment PIN_AF18 -to eth_mdio
	set_location_assignment PIN_AE17 -to eth_mdc
	set_location_assignment PIN_C12 -to ad9653_sync
	set_location_assignment PIN_C15 -to lmk04808_hld
	set_location_assignment PIN_F7 -to fpga_ver[0]
	set_location_assignment PIN_E9 -to fpga_ver[1]
	set_location_assignment PIN_D8 -to fpga_ver[2]
	set_location_assignment PIN_B5 -to fpga_ver[4]
	set_location_assignment PIN_A4 -to fpga_ver[5]
	set_location_assignment PIN_A12 -to fpga_ver[3]
	set_location_assignment PIN_E16 -to lmk04808_ld
	set_location_assignment PIN_T2 -to jtag_mux_sel_out
	set_location_assignment PIN_N1 -to gpio_led_1
	set_location_assignment PIN_T1 -to gpio_led_2
	set_location_assignment PIN_R2 -to gpio_led_3
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_1 -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_2 -entity cyclone10gx_digitizer_main
	set_instance_assignment -name IO_STANDARD "1.8 V" -to gpio_led_3 -entity cyclone10gx_digitizer_main

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
