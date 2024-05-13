	test_nco u0 (
		.clk       (_connected_to_clk_),       //   input,   width = 1, clk.clk
		.reset_n   (_connected_to_reset_n_),   //   input,   width = 1, rst.reset_n
		.clken     (_connected_to_clken_),     //   input,   width = 1,  in.clken
		.phi_inc_i (_connected_to_phi_inc_i_), //   input,  width = 32,    .phi_inc_i
		.fsin_o    (_connected_to_fsin_o_),    //  output,  width = 18, out.fsin_o
		.out_valid (_connected_to_out_valid_)  //  output,   width = 1,    .out_valid
	);

