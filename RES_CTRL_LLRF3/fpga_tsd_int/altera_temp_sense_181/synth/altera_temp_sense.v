// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


module altera_temp_sense (
	corectl,
	eoc,
	reset,
	tempout);

	parameter DEVICE_FAMILY   = "MAX 10";

	input	corectl;
	input	reset;
	output	eoc;
	output	[9:0]  tempout;
	
	wire  wire_eoc;
	wire  [9:0]   wire_tempout;
	generate
        if (DEVICE_FAMILY == "Arria 10") begin
            twentynm_tsdblock   sd1( 
				.corectl(corectl),
				.eoc(wire_eoc),
				.reset(reset),
				.tempout(wire_tempout));
        end else begin // Cyclone 10 GX
            cyclone10gx_tsdblock   sd1( 
				.corectl(corectl),
				.eoc(wire_eoc),
				.reset(reset),
				.tempout(wire_tempout));
        end
    endgenerate
			
	assign
		eoc = wire_eoc,
		tempout = wire_tempout;

endmodule