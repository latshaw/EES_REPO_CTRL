// remote_download_altera_remote_update_181_d5quj5a.v

// This file was auto-generated from altera_remote_update_hw.tcl.  If you edit it your changes
// will probably be lost.
// 
// Generated using ACDS version 18.1 222

`timescale 1 ps / 1 ps
module remote_download_altera_remote_update_181_d5quj5a (
		input  wire        clock,       //       clock.clk
		input  wire        reset,       //       reset.reset
		input  wire        read_param,  //  read_param.read_param
		input  wire [2:0]  param,       //       param.param
		input  wire        reconfig,    //    reconfig.reconfig
		input  wire        reset_timer, // reset_timer.reset_timer
		output wire        busy,        //        busy.busy
		output wire [31:0] data_out,    //    data_out.data_out
		input  wire        ctl_nupdt    //   ctl_nupdt.ctl_nupdt
	);

	altera_remote_update_core #(
		.DEVICE_FAMILY ("Cyclone 10 GX")
	) remote_update_core (
		.read_param  (read_param),  //   input,   width = 1,  read_param.read_param
		.param       (param),       //   input,   width = 3,       param.param
		.reconfig    (reconfig),    //   input,   width = 1,    reconfig.reconfig
		.reset_timer (reset_timer), //   input,   width = 1, reset_timer.reset_timer
		.clock       (clock),       //   input,   width = 1,       clock.clk
		.reset       (reset),       //   input,   width = 1,       reset.reset
		.busy        (busy),        //  output,   width = 1,        busy.busy
		.data_out    (data_out),    //  output,  width = 32,    data_out.data_out
		.ctl_nupdt   (ctl_nupdt)    //   input,   width = 1,   ctl_nupdt.ctl_nupdt
	);

endmodule