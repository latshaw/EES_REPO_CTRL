## Generated SDC file "LLRF3_HPA_FPGA.out.sdc"

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

## DATE    "Thu Mar 20 13:04:07 2025"

##
## DEVICE  "10CX105YF672I5G"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clock} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clock}]
create_clock -name {sfp_refclk_p} -period 8.000 -waveform { 0.000 4.000 } [get_ports {sfp_refclk_p}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {inst11|u0|xcvr_native_a10_0|rx_coreclkin} -source [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|out_pld_pcs_rx_clk_out~CLKENA0|outclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst11|u0|xcvr_native_a10_0|rx_pma_clk} [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_rx_pld_pcs_interface.inst_twentynm_hssi_rx_pld_pcs_interface|pld_rx_clk}] 
create_generated_clock -name {inst11|u0|xcvr_native_a10_0|tx_pma_clk} -source [get_pins {inst11|u2|xcvr_atx_pll_a10_0|a10_xcvr_atx_pll_inst|twentynm_hssi_pma_lc_refclk_select_mux_inst|lvpecl_in}] -duty_cycle 50/1 -multiply_by 1 -master_clock {sfp_refclk_p} [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pma|gen_twentynm_hssi_pma_tx_cgb.inst_twentynm_hssi_pma_tx_cgb|cpulse_out_bus[0]}] 
create_generated_clock -name {inst11|u0|xcvr_native_a10_0|rx_pma_clk} -source [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pma|gen_twentynm_hssi_pma_cdr_refclk_select_mux.inst_twentynm_hssi_pma_cdr_refclk_select_mux|ref_iqclk[0]}] -duty_cycle 50/1 -multiply_by 1 -master_clock {sfp_refclk_p} [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pma|gen_twentynm_hssi_pma_rx_deser.inst_twentynm_hssi_pma_rx_deser|clkdiv}] 
create_generated_clock -name {inst11|u0|xcvr_native_a10_0|tx_coreclkin} -source [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|out_pld_pcs_tx_clk_out~CLKENA0|outclk}] -duty_cycle 50/1 -multiply_by 1 -master_clock {inst11|u0|xcvr_native_a10_0|tx_pma_clk} [get_pins {inst11|u0|xcvr_native_a10_0|g_xcvr_native_insts[0].twentynm_xcvr_native_inst|twentynm_xcvr_native_inst|inst_twentynm_pcs|gen_twentynm_hssi_tx_pld_pcs_interface.inst_twentynm_hssi_tx_pld_pcs_interface|pld_tx_clk}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.110  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.051  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.075  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.051  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.075  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {sfp_refclk_p}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {sfp_refclk_p}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {clock}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {clock}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.051  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.075  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -setup 0.051  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_coreclkin}] -hold 0.075  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {sfp_refclk_p}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {sfp_refclk_p}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -rise_to [get_clocks {clock}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}] -fall_to [get_clocks {clock}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.085  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.069  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.085  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.069  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.085  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.069  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -setup 0.085  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}] -hold 0.069  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_coreclkin}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -rise_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -fall_from [get_clocks {sfp_refclk_p}] -fall_to [get_clocks {sfp_refclk_p}]  0.040  
set_clock_uncertainty -rise_from [get_clocks {clock}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -rise_from [get_clocks {clock}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -rise_from [get_clocks {clock}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {clock}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -rise_from [get_clocks {clock}] -rise_to [get_clocks {clock}]  0.030  
set_clock_uncertainty -rise_from [get_clocks {clock}] -fall_to [get_clocks {clock}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clock}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -fall_from [get_clocks {clock}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|rx_pma_clk}]  0.080  
set_clock_uncertainty -fall_from [get_clocks {clock}] -rise_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {clock}] -fall_to [get_clocks {inst11|u0|xcvr_native_a10_0|tx_pma_clk}]  0.070  
set_clock_uncertainty -fall_from [get_clocks {clock}] -rise_to [get_clocks {clock}]  0.030  
set_clock_uncertainty -fall_from [get_clocks {clock}] -fall_to [get_clocks {clock}]  0.030  


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

