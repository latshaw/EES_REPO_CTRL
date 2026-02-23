// Marble Mini testing variant of this module
module gmii_clock_handle(
	input sysclk_p,
	input sysclk_n,
	input reset,
	output clk_eth,  // 125 MHz
	output clk_eth_90,
	output clk_locked
);
// No clk_pin output port:  that only gets used by GMII hardware,
// and we're RGMII.  RGMII Tx clock pin handling is in gmii_to_rgmii.v.

// 20 MHz clock in x50, then divide by 8 to get clk_eth (tx_clk)
xilinx7_clocks #(
	.DIFF_CLKIN("BYPASS"),
	.CLKIN_PERIOD(10.0),  // cahnged to 10 ns JAL as we have  100 Mhz clock
	.MULT     (10),     // changed to 10, this maakes a 1000 Mhz
	.DIV0     (8)       // 1000 / 8 = 125 MHz
) clocks_i(
	.sysclk_p (sysclk_p),
	.sysclk_n (sysclk_n),
	.reset    (reset),
	.clk_out0 (clk_eth),
	.clk_out2 (clk_eth_90),
	.locked   (clk_locked)
);

endmodule
