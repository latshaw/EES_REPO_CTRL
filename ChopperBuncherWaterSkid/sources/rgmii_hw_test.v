// RGMII Hardware Test
// mostly just instantiates hw_test
// Initial target is AC701
// Modified for Nexys Video (Artix 7) implementtion.

module rgmii_hw_test(
    // ip signal info
    input [31:0] ip, 
    input [47:0] mac,
	// 200 MHz typical
	input SYSCLK_P, // 100 Mhz
// `ifndef MARBLE_TEST
	// input SYSCLK_N,
// `endif

	// RGMII Tx port
	output [3:0] RGMII_TXD,
	output RGMII_TX_CTRL,
	output RGMII_TX_CLK,

	// RGMII Rx port
	input [3:0] RGMII_RXD,
	input RGMII_RX_CTRL,
	input RGMII_RX_CLK,

	// Reset command to PHY
	output PHY_RSTN,

	// SPI pins, can give access to configuration
	// input SCLK,
	// input CSB,
	// input MOSI,

	// SPI boot flash programming port
// `ifndef CHIP_FAMILY_7SERIES
	// output BOOT_CCLK,
// `endif
	// output BOOT_CS_B,
	// input  BOOT_MISO,
	// output BOOT_MOSI,

// `ifdef MARBLE_TEST
	// output VCXO_EN,
// `endif
    output lb_clk, 
    output [23:0] lb_addr,
    output lb_valid,
    output lb_rnw,
    output [31:0] lb_wdata,
    input  [31:0] lb_rdata,
	// Something physical
	input RESET,
	output [7:0] led
);



//       ila_6 ila_6_inst1 (
//        .clk(lb_clk),
//        .probe0(lb_addr),
//        .probe1(lb_valid),
//        .probe2(lb_rnw),
//        .probe3(lb_wdata),
//        .probe4(lb_rdata));


`ifdef MARBLE_TEST
assign VCXO_EN = 1;
wire SYSCLK_N = 0;
parameter in_phase_tx_clk = 1;
`else
parameter in_phase_tx_clk = 0;
`endif

// Standardized interface, hardware-dependent implementation
wire tx_clk, tx_clk90;
wire clk_locked;
wire pll_reset = 0;  // or RESET?
gmii_clock_handle clocks(
	.sysclk_p(SYSCLK_P),
	.sysclk_n(SYSCLK_N),
	.reset(pll_reset),
	.clk_eth(tx_clk),
	.clk_eth_90(tx_clk90),
	.clk_locked(clk_locked)
);

// Double-data-rate conversion
wire vgmii_tx_clk, vgmii_tx_clk90, vgmii_rx_clk;
wire [7:0] vgmii_txd, vgmii_rxd;
wire vgmii_tx_en, vgmii_tx_er, vgmii_rx_dv, vgmii_rx_er;
gmii_to_rgmii #(.in_phase_tx_clk(in_phase_tx_clk)) gmii_to_rgmii_i(
	.rgmii_txd(RGMII_TXD),
	.rgmii_tx_ctl(RGMII_TX_CTRL),
	.rgmii_tx_clk(RGMII_TX_CLK),
	.rgmii_rxd(RGMII_RXD),
	.rgmii_rx_ctl(RGMII_RX_CTRL),
	.rgmii_rx_clk(RGMII_RX_CLK),

	.gmii_tx_clk(tx_clk),
	.gmii_tx_clk90(tx_clk90),
	.gmii_txd(vgmii_txd),
	.gmii_tx_en(vgmii_tx_en),
	.gmii_tx_er(vgmii_tx_er),
	.gmii_rxd(vgmii_rxd),
	.gmii_rx_clk(vgmii_rx_clk),
	.gmii_rx_dv(vgmii_rx_dv),
	.gmii_rx_er(vgmii_rx_er)
);

`ifdef CHIP_FAMILY_7SERIES
wire BOOT_CCLK;
// See XAPP1081 p.25: 7 Series FPGAs Access to the SPI Clock
// and UG470 p. 90: STARTUPE2 Primitive
STARTUPE2 set_cclk(.USRCCLKO(BOOT_CCLK), .USRCCLKTS(1'b0));
defparam vgmii.rtefi.p4_client.engine.seven = 1;
`endif

// JAL, check phy reset
wire PHY_RSTN_buffer;

hw_test vgmii(
    .ip(ip), .mac(mac),
	.vgmii_tx_clk(tx_clk), .vgmii_txd(vgmii_txd),
	.vgmii_tx_en(vgmii_tx_en), .vgmii_tx_er(vgmii_tx_er),
	.vgmii_rx_clk(vgmii_rx_clk), .vgmii_rxd(vgmii_rxd),
	.vgmii_rx_dv(vgmii_rx_dv), .vgmii_rx_er(vgmii_rx_er),
	.phy_rstn(PHY_RSTN_buffer), .clk_locked(clk_locked),
    .lb_clk_out(lb_clk), 
    .lb_addr_out(lb_addr),
    .lb_valid(lb_valid),
    .lb_rnw(lb_rnw),
    .lb_wdata(lb_wdata),
    .lb_rdata(lb_rdata),
    .RESET(RESET), .LED(led[3:0])
);

// JAL, check phy reset
assign PHY_RSTN = PHY_RSTN_buffer;
assign led[4] = PHY_RSTN_buffer;
assign led[5] = clk_locked;
reg [26:0] tx_clk_heartbeat=0, tx_clk90_heartbeat=0;
always @(posedge tx_clk) tx_clk_heartbeat <= tx_clk_heartbeat+1;
always @(posedge tx_clk90) tx_clk90_heartbeat <= tx_clk90_heartbeat+1;
assign led[6] = tx_clk_heartbeat[24];
assign led[7] = tx_clk90_heartbeat[24];






endmodule
