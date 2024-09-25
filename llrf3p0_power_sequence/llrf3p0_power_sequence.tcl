# Copyright (C) 2019  Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions 
# and other software and tools, and any partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Intel Program License 
# Subscription Agreement, the Intel Quartus Prime License Agreement,
# the Intel FPGA IP License Agreement, or other applicable license
# agreement, including, without limitation, that your use is for
# the sole purpose of programming logic devices manufactured by
# Intel and sold by Intel or its authorized distributors.  Please
# refer to the applicable agreement for further details, at
# https://fpgasoftware.intel.com/eula.

# Quartus Prime: Generate Tcl File for Project
# File: llrf3p0_power_sequence.tcl
# Generated on: Wed Sep 25 10:53:40 2024

# Load Quartus Prime Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "llrf3p0_power_sequence"]} {
		puts "Project llrf3p0_power_sequence is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists llrf3p0_power_sequence]} {
		project_open -revision llrf3p0_power_sequence llrf3p0_power_sequence
	} else {
		project_new -revision llrf3p0_power_sequence llrf3p0_power_sequence
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	set_global_assignment -name FAMILY "MAX 10"
	set_global_assignment -name DEVICE 10M08SAE144C8G
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION 18.1.0
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "14:02:26  NOVEMBER 18, 2019"
	set_global_assignment -name LAST_QUARTUS_VERSION "19.1.0 Lite Edition"
	set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 144
	set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 256
	set_global_assignment -name BDF_FILE llrf3p0_power_sequence.bdf
	set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
	set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
	set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
	set_global_assignment -name VHDL_FILE heartbeat_isa.vhd
	set_global_assignment -name ENABLE_SIGNALTAP OFF
	set_global_assignment -name USE_SIGNALTAP_FILE tmp512.stp
	set_global_assignment -name SIGNALTAP_FILE output_files/stp1.stp
	set_global_assignment -name VHDL_FILE power_sequence.vhd
	set_global_assignment -name ENABLE_OCT_DONE OFF
	set_global_assignment -name ENABLE_JTAG_PIN_SHARING OFF
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF
	set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -rise
	set_global_assignment -name OUTPUT_IO_TIMING_NEAR_END_VMEAS "HALF VCCIO" -fall
	set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -rise
	set_global_assignment -name OUTPUT_IO_TIMING_FAR_END_VMEAS "HALF SIGNAL SWING" -fall
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
	set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"
	set_global_assignment -name FLOW_ENABLE_POWER_ANALYZER ON
	set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE "12.5 %"
	set_global_assignment -name VHDL_FILE reset_all.vhd
	set_global_assignment -name VHDL_FILE jtag_sel.vhd
	set_global_assignment -name VHDL_FILE i2c_tmp512.vhd
	set_global_assignment -name SIGNALTAP_FILE tmp512.stp
	set_location_assignment PIN_26 -to clock
	set_location_assignment PIN_32 -to hb_max10
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clock
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to dis_grp1
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to dis_grp2
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to dis_grp3
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to dis_grp4
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to en_grp1
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to en_grp2
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to en_grp3
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to en_grp4
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to hb_max10
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset
	set_location_assignment PIN_75 -to reset
	set_location_assignment PIN_39 -to en_grp1
	set_location_assignment PIN_58 -to en_grp2
	set_location_assignment PIN_57 -to en_grp3
	set_location_assignment PIN_59 -to en_grp4
	set_location_assignment PIN_21 -to dis_grp1
	set_location_assignment PIN_22 -to dis_grp2
	set_location_assignment PIN_24 -to dis_grp3
	set_location_assignment PIN_25 -to dis_grp4
	set_location_assignment PIN_43 -to pmbus_sda
	set_location_assignment PIN_44 -to pmbus_scl
	set_location_assignment PIN_41 -to pmbus_alert
	set_location_assignment PIN_38 -to pgood_0p9v
	set_location_assignment PIN_46 -to pgood_3p3v
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood_0p9v
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood_3p3v
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pmbus_alert
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pmbus_scl
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pmbus_sda
	set_location_assignment PIN_56 -to pgood_0p95
	set_location_assignment PIN_50 -to pgood_1p8
	set_location_assignment PIN_52 -to pgood_1p8vio
	set_location_assignment PIN_55 -to pgood_vioadj
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood_0p95
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood_1p8
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood_1p8vio
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood_vioadj
	set_location_assignment PIN_65 -to ss_pok
	set_location_assignment PIN_64 -to uv_alarm
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ss_pok
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to uv_alarm
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to altera_reserved_tck
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to altera_reserved_tdi
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to altera_reserved_tdo
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to altera_reserved_tms
	set_location_assignment PIN_6 -to jtag_mux_sel
	set_location_assignment PIN_98 -to c10_reset_out
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to c10_reset_out
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to jtag_mux_sel
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to pgood
	set_location_assignment PIN_100 -to jtag_sel[1]
	set_location_assignment PIN_99 -to jtag_sel[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to jtag_sel[1]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to jtag_sel[0]
	set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to jtag_sel
	set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top

	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
