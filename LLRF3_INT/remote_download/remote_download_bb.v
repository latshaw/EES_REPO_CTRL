module remote_download (
		input  wire        clock,       //       clock.clk
		input  wire        reset,       //       reset.reset
		input  wire        read_param,  //  read_param.read_param
		input  wire [2:0]  param,       //       param.param
		input  wire        reconfig,    //    reconfig.reconfig
		input  wire        reset_timer, // reset_timer.reset_timer
		output wire        busy,        //        busy.busy
		output wire [31:0] data_out,    //    data_out.data_out
		input  wire        write_param, // write_param.write_param
		input  wire [31:0] data_in,     //     data_in.data_in
		input  wire        ctl_nupdt    //   ctl_nupdt.ctl_nupdt
	);
endmodule

