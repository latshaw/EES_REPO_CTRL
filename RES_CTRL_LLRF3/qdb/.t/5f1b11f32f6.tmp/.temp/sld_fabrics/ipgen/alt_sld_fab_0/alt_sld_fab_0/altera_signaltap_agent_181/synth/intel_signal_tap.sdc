# (C) 2001-2018 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other 
# software and tools, and its AMPP partner logic functions, and any output 
# files from any of the foregoing (including device programming or simulation 
# files), and any associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License Subscription 
# Agreement, Intel FPGA IP License Agreement, or other applicable 
# license agreement, including, without limitation, that your use is for the 
# sole purpose of programming logic devices manufactured by Intel and sold by 
# Intel or its authorized distributors.  Please refer to the applicable 
# agreement for further details.


# $Revision: #1 
# $Date: 2017/07/31 
# $Author: zkumar 

#-------------------------------------------------------------------------------
# TimeQuest constraints to constrain the timing across asynchronous clock domain crossings.
# The idea is to minimize skew to between stp_status_bits_in_reg (acq domain) and stp_status_bits_out (tck domain)
# 
# CDC takes place between these paths (in intel_stp_status_bits_cdc component)
#

# -----------------------------------------------------------------------------
# This procedure constrains the skew between the status bit regs.
#
# The hierarchy path to the status_bits CDC instance is required as an 
# argument.
# -----------------------------------------------------------------------------
proc constrain_signaltap_status_bits_skew { path } {

    #max skew ~ 1GHz ~ 1ns (safer value)
    set_max_skew -from [ get_registers $path|stp_status_bits_in_reg\[*\] ] -to [ get_registers $path|stp_status_bits_out\[*\] ] 1.0
    

}

constrain_signaltap_status_bits_skew "[get_current_instance]|sld_signaltap_inst|sld_signaltap_body|sld_signaltap_body|jtag_acq_clk_xing|intel_stp_status_bits_cdc_u1"
