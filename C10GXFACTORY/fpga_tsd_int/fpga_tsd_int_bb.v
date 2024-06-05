module fpga_tsd_int (
		input  wire       corectl, // corectl.corectl
		input  wire       reset,   //   reset.reset
		output wire [9:0] tempout, // tempout.tempout
		output wire       eoc      //     eoc.eoc
	);
endmodule

