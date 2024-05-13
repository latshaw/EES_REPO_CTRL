	gxb_phy_xcvr_native_a10_0 u0 (
		.tx_analogreset          (_connected_to_tx_analogreset_),          //   input,    width = 1,          tx_analogreset.tx_analogreset
		.tx_digitalreset         (_connected_to_tx_digitalreset_),         //   input,    width = 1,         tx_digitalreset.tx_digitalreset
		.rx_analogreset          (_connected_to_rx_analogreset_),          //   input,    width = 1,          rx_analogreset.rx_analogreset
		.rx_digitalreset         (_connected_to_rx_digitalreset_),         //   input,    width = 1,         rx_digitalreset.rx_digitalreset
		.tx_cal_busy             (_connected_to_tx_cal_busy_),             //  output,    width = 1,             tx_cal_busy.tx_cal_busy
		.rx_cal_busy             (_connected_to_rx_cal_busy_),             //  output,    width = 1,             rx_cal_busy.rx_cal_busy
		.tx_serial_clk0          (_connected_to_tx_serial_clk0_),          //   input,    width = 1,          tx_serial_clk0.clk
		.rx_cdr_refclk0          (_connected_to_rx_cdr_refclk0_),          //   input,    width = 1,          rx_cdr_refclk0.clk
		.tx_serial_data          (_connected_to_tx_serial_data_),          //  output,    width = 1,          tx_serial_data.tx_serial_data
		.rx_serial_data          (_connected_to_rx_serial_data_),          //   input,    width = 1,          rx_serial_data.rx_serial_data
		.rx_is_lockedtoref       (_connected_to_rx_is_lockedtoref_),       //  output,    width = 1,       rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata      (_connected_to_rx_is_lockedtodata_),      //  output,    width = 1,      rx_is_lockedtodata.rx_is_lockedtodata
		.tx_coreclkin            (_connected_to_tx_coreclkin_),            //   input,    width = 1,            tx_coreclkin.clk
		.rx_coreclkin            (_connected_to_rx_coreclkin_),            //   input,    width = 1,            rx_coreclkin.clk
		.tx_clkout               (_connected_to_tx_clkout_),               //  output,    width = 1,               tx_clkout.clk
		.rx_clkout               (_connected_to_rx_clkout_),               //  output,    width = 1,               rx_clkout.clk
		.tx_parallel_data        (_connected_to_tx_parallel_data_),        //   input,   width = 10,        tx_parallel_data.tx_parallel_data
		.unused_tx_parallel_data (_connected_to_unused_tx_parallel_data_), //   input,  width = 118, unused_tx_parallel_data.unused_tx_parallel_data
		.rx_parallel_data        (_connected_to_rx_parallel_data_),        //  output,   width = 10,        rx_parallel_data.rx_parallel_data
		.unused_rx_parallel_data (_connected_to_unused_rx_parallel_data_)  //  output,  width = 118, unused_rx_parallel_data.unused_rx_parallel_data
	);

