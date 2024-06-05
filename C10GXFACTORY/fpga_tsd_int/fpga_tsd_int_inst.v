	fpga_tsd_int u0 (
		.corectl (_connected_to_corectl_), //   input,   width = 1, corectl.corectl
		.reset   (_connected_to_reset_),   //   input,   width = 1,   reset.reset
		.tempout (_connected_to_tempout_), //  output,  width = 10, tempout.tempout
		.eoc     (_connected_to_eoc_)      //  output,   width = 1,     eoc.eoc
	);

