module dpram_ram_2port_0 (
		input  wire [17:0] data_a,    //    data_a.datain_a
		output wire [17:0] q_a,       //       q_a.dataout_a
		input  wire [17:0] data_b,    //    data_b.datain_b
		output wire [17:0] q_b,       //       q_b.dataout_b
		input  wire [11:0] address_a, // address_a.address_a
		input  wire [11:0] address_b, // address_b.address_b
		input  wire        wren_a,    //    wren_a.wren_a
		input  wire        wren_b,    //    wren_b.wren_b
		input  wire        clock_a,   //   clock_a.clk
		input  wire        clock_b    //   clock_b.clk
	);
endmodule

