module test_nco (
		input  wire        clk,       // clk.clk
		input  wire        reset_n,   // rst.reset_n
		input  wire        clken,     //  in.clken
		input  wire [31:0] phi_inc_i, //    .phi_inc_i
		output wire [17:0] fsin_o,    // out.fsin_o
		output wire        out_valid  //    .out_valid
	);
endmodule

