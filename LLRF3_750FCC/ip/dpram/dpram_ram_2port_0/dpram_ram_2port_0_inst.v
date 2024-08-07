	dpram_ram_2port_0 u0 (
		.data_a    (_connected_to_data_a_),    //   input,  width = 18,    data_a.datain_a
		.q_a       (_connected_to_q_a_),       //  output,  width = 18,       q_a.dataout_a
		.data_b    (_connected_to_data_b_),    //   input,  width = 18,    data_b.datain_b
		.q_b       (_connected_to_q_b_),       //  output,  width = 18,       q_b.dataout_b
		.address_a (_connected_to_address_a_), //   input,  width = 12, address_a.address_a
		.address_b (_connected_to_address_b_), //   input,  width = 12, address_b.address_b
		.wren_a    (_connected_to_wren_a_),    //   input,   width = 1,    wren_a.wren_a
		.wren_b    (_connected_to_wren_b_),    //   input,   width = 1,    wren_b.wren_b
		.clock_a   (_connected_to_clock_a_),   //   input,   width = 1,   clock_a.clk
		.clock_b   (_connected_to_clock_b_)    //   input,   width = 1,   clock_b.clk
	);

