## Generated SDC file "C10GXFACTORY.out.sdc"

## Copyright (C) 2018  Intel Corporation. All rights reserved.
## Your use of Intel Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Intel Program License 
## Subscription Agreement, the Intel Quartus Prime License Agreement,
## the Intel FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Intel and sold by Intel or its authorized distributors.  Please
## refer to the applicable agreement for further details.


## VENDOR  "Intel Corporation"
## PROGRAM "Quartus Prime"
## VERSION "Version 18.1.0 Build 222 09/21/2018 SJ Pro Edition"

## DATE    "Mon Oct 21 10:48:23 2024"

##
## DEVICE  "10CX105YF672E5G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {~ALTERA_CLKUSR~} -period 8.000 -waveform { 0.000 4.000 } [get_pins -compatibility_mode {~ALTERA_CLKUSR~~ibuf|o}]
create_clock -name {sfp_refclk_p} -period 8.000 -waveform { 0.000 4.000 } [get_ports {sfp_refclk_p}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin} -source [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|out_pld_pcs_rx_clk_out~CLKENA0|outclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk} [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_rx_pld_pcs_interface.inst_twentynm_hssi_rx_pld_pcs_interface|pld_rx_clk}] 
create_generated_clock -name {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin} -source [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|out_pld_pcs_tx_clk_out~CLKENA0|outclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk} [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_tx_pld_pcs_interface.inst_twentynm_hssi_tx_pld_pcs_interface|pld_tx_clk}] 
create_generated_clock -name {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk} -source [get_pins {inst_comms_top|u2|xcvr_atx_pll_a10_0|a10_xcvr_atx_pll_inst|twentynm_hssi_pma_lc_refclk_select_mux_inst|lvpecl_in}] -duty_cycle 50/1 -multiply_by 1 -master_clock {sfp_refclk_p} [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pma|gen_twentynm_hssi_pma_tx_cgb.inst_twentynm_hssi_pma_tx_cgb|cpulse_out_bus[0]}] 
create_generated_clock -name {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk} -source [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pma|gen_twentynm_hssi_pma_cdr_refclk_select_mux.inst_twentynm_hssi_pma_cdr_refclk_select_mux|ref_iqclk[0]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {sfp_refclk_p} [get_pins {inst_comms_top|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pma|gen_twentynm_hssi_pma_rx_deser.inst_twentynm_hssi_pma_rx_deser|clkdiv}] 
create_generated_clock -name {CYCLONE_inst|pll20_inst|iopll_0|clk20} -source [get_pins {CYCLONE_inst|pll20_inst|iopll_0|altera_iopll_i|c10gx_pll|iopll_inst|refclk[0]}] -duty_cycle 50/1 -multiply_by 8 -divide_by 50 -master_clock {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk} [get_pins {CYCLONE_inst|pll20_inst|iopll_0|altera_iopll_i|c10gx_pll|iopll_inst|outclk[0]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -rise_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.250  
set_clock_uncertainty -rise_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -fall_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.250  
set_clock_uncertainty -rise_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.320  
set_clock_uncertainty -rise_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.320  
set_clock_uncertainty -fall_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -rise_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.250  
set_clock_uncertainty -fall_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -fall_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.250  
set_clock_uncertainty -fall_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.320  
set_clock_uncertainty -fall_from [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.320  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.320  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.320  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.040  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.069  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.040  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.069  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.320  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  0.320  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.040  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.069  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.040  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.069  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.074  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.063  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.074  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.063  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.074  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.063  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.074  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.063  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {~ALTERA_CLKUSR~}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -rise_from [get_clocks {~ALTERA_CLKUSR~}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -rise_from [get_clocks {~ALTERA_CLKUSR~}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {~ALTERA_CLKUSR~}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {~ALTERA_CLKUSR~}] -rise_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {~ALTERA_CLKUSR~}] -fall_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {~ALTERA_CLKUSR~}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -fall_from [get_clocks {~ALTERA_CLKUSR~}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -fall_from [get_clocks {~ALTERA_CLKUSR~}] -rise_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {~ALTERA_CLKUSR~}] -fall_to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {~ALTERA_CLKUSR~}] -rise_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {~ALTERA_CLKUSR~}] -fall_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {~ALTERA_CLKUSR~}]  0.030  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************

set_false_path -to [get_registers {*alt_xcvr_resync*sync_r[0]}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_10g_krfec_rx_pld_rst_n*}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_8g_g3_rx_pld_rst_n*}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pmaif_rx_pld_rst_n*}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_bitslip*}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_rx_prbs_err_clr*}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_polinv_tx*}]
set_false_path -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_polinv_rx*}]


#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -hold -end -from  [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  -to  [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] 8
set_multicycle_path -hold -end -from  [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  -to  [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] 8
set_multicycle_path -setup -end -from  [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}]  -to  [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] 8
set_multicycle_path -setup -end -from  [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}]  -to  [get_clocks {CYCLONE_inst|pll20_inst|iopll_0|clk20}] 8
set_multicycle_path -setup -end -from [get_keepers {CYCLONE_inst|cdc_*|data_latch[*]}] -to [get_keepers {CYCLONE_inst|cdc_4|data_pipe[*]}] 8
set_multicycle_path -hold -end -from [get_keepers {CYCLONE_inst|cdc_*|data_latch[*]}] -to [get_keepers {CYCLONE_inst|cdc_4|data_pipe[*]}] 8


#**************************************************************
# Set Maximum Delay
#**************************************************************

set_max_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pmaif_tx_pld_rst_n}] 50.000
set_max_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_8g_g3_tx_pld_rst_n}] 50.000
set_max_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_10g_krfec_tx_pld_rst_n}] 50.000
set_max_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pma_txpma_rstb}] 20.000
set_max_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pma_rxpma_rstb}] 20.000


#**************************************************************
# Set Minimum Delay
#**************************************************************

set_min_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pmaif_tx_pld_rst_n}] -50.000
set_min_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_8g_g3_tx_pld_rst_n}] -50.000
set_min_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_10g_krfec_tx_pld_rst_n}] -50.000
set_min_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pma_txpma_rstb}] -10.000
set_min_delay -to [get_pins -compatibility_mode {*twentynm_xcvr_native_inst|*inst_twentynm_pcs|*twentynm_hssi_*_pld_pcs_interface*|pld_pma_rxpma_rstb}] -10.000


#**************************************************************
# Set Input Transition
#**************************************************************

