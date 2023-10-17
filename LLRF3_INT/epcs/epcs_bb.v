module epcs (
		input  wire        clkin,         //         clkin.clk
		input  wire        read,          //          read.read
		input  wire        rden,          //          rden.rden
		input  wire [31:0] addr,          //          addr.addr
		input  wire        write,         //         write.write
		input  wire [7:0]  datain,        //        datain.datain
		input  wire        sector_erase,  //  sector_erase.sector_erase
		input  wire        wren,          //          wren.wren
		input  wire        en4b_addr,     //     en4b_addr.en4b_addr
		input  wire        reset,         //         reset.reset
		input  wire [2:0]  sce,           //           sce.sce
		output wire [7:0]  dataout,       //       dataout.dataout
		output wire        busy,          //          busy.busy
		output wire        data_valid,    //    data_valid.data_valid
		output wire        illegal_write, // illegal_write.illegal_write
		output wire        illegal_erase  // illegal_erase.illegal_erase
	);
endmodule

