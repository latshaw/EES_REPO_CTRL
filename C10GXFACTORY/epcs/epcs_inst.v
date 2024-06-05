	epcs u0 (
		.clkin         (_connected_to_clkin_),         //   input,   width = 1,         clkin.clk
		.read          (_connected_to_read_),          //   input,   width = 1,          read.read
		.rden          (_connected_to_rden_),          //   input,   width = 1,          rden.rden
		.addr          (_connected_to_addr_),          //   input,  width = 32,          addr.addr
		.write         (_connected_to_write_),         //   input,   width = 1,         write.write
		.datain        (_connected_to_datain_),        //   input,   width = 8,        datain.datain
		.sector_erase  (_connected_to_sector_erase_),  //   input,   width = 1,  sector_erase.sector_erase
		.wren          (_connected_to_wren_),          //   input,   width = 1,          wren.wren
		.en4b_addr     (_connected_to_en4b_addr_),     //   input,   width = 1,     en4b_addr.en4b_addr
		.reset         (_connected_to_reset_),         //   input,   width = 1,         reset.reset
		.sce           (_connected_to_sce_),           //   input,   width = 3,           sce.sce
		.dataout       (_connected_to_dataout_),       //  output,   width = 8,       dataout.dataout
		.busy          (_connected_to_busy_),          //  output,   width = 1,          busy.busy
		.data_valid    (_connected_to_data_valid_),    //  output,   width = 1,    data_valid.data_valid
		.illegal_write (_connected_to_illegal_write_), //  output,   width = 1, illegal_write.illegal_write
		.illegal_erase (_connected_to_illegal_erase_)  //  output,   width = 1, illegal_erase.illegal_erase
	);

