	remote_download u0 (
		.clock       (_connected_to_clock_),       //   input,   width = 1,       clock.clk
		.reset       (_connected_to_reset_),       //   input,   width = 1,       reset.reset
		.read_param  (_connected_to_read_param_),  //   input,   width = 1,  read_param.read_param
		.param       (_connected_to_param_),       //   input,   width = 3,       param.param
		.reconfig    (_connected_to_reconfig_),    //   input,   width = 1,    reconfig.reconfig
		.reset_timer (_connected_to_reset_timer_), //   input,   width = 1, reset_timer.reset_timer
		.busy        (_connected_to_busy_),        //  output,   width = 1,        busy.busy
		.data_out    (_connected_to_data_out_),    //  output,  width = 32,    data_out.data_out
		.write_param (_connected_to_write_param_), //   input,   width = 1, write_param.write_param
		.data_in     (_connected_to_data_in_),     //   input,  width = 32,     data_in.data_in
		.ctl_nupdt   (_connected_to_ctl_nupdt_)    //   input,   width = 1,   ctl_nupdt.ctl_nupdt
	);

