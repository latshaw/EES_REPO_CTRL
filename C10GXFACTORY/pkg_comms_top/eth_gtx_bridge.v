`timescale 1ns / 1ns

// ------------------------------------
// eth_gtx_bridge.v
//
// Wrapper around rtefi_blob and gmii_link with a TX/RX path width conversion for GTX compatibility
// ------------------------------------

module eth_gtx_bridge #(
   parameter JUMBO_DW = 14, // Not used, just holdover for compatibility with older eth_gtx_bridge
   parameter GTX_DW   = 20) // Parallel GTX data width; Supported values are 10b and 20b
(
   input [31:0]			ip,
	input [47:0]			mac,
	input               gtx_tx_clk,  // Transceiver clock at half rate
   input               gmii_tx_clk, // Clock for Ethernet fabric - 125 MHz for 1GbE
   input               gmii_rx_clk,
   input  [GTX_DW-1:0] gtx_rxd,
   output [GTX_DW-1:0] gtx_txd,

   // Auto-Negotiation
   input               an_disable,
   output [6:0]        an_status,

   // Status signals
   output              rx_mon,
   output              tx_mon,

   // Ethernet configuration interface
   input               cfg_clk,
   input               cfg_enable_rx,
   input               cfg_valid,
   input  [4:0]        cfg_addr, // cfg_addr[4] = {0 - MAC/IP, 1 - UDP Ports}
   input  [7:0]        cfg_wdata,
   // Dummy ports used to trigger newad address space generation
   input  [7:0]        cfg_reg, // external
   output [4:0]        cfg_reg_addr, // external

   // Local Bus interface
   output              lb_valid,
   output              lb_rnw,
   output [23:0]       lb_addr,
   output [31:0]       lb_wdata,
   output              lb_renable,
   input  [31:0]       lb_rdata
);
   wire [7:0] gmii_rxd, gmii_txd;
   wire [9:0] gtx_txd_10;
   wire gmii_tx_en, gmii_rx_er, gmii_rx_dv;

   // ----------------------------------
   // Data width and rate conversion
   // ---------------------------------

   wire [9:0] gtx_rxd_10;

   generate if (GTX_DW==20) begin: G_GTX_DATA_CONV

      reg  [9:0] gtx_rxd_10_r;
      reg  [9:0] gtx_txd_r;
      wire [9:0] gtp_rxd_l = gtx_rxd[9:0];
      wire [9:0] gtp_rxd_h = gtx_rxd[19:10];
      reg  [19:0] gtx_txd_l;
      reg even=0;

      always @(posedge gmii_tx_clk) begin
          gtx_txd_r <= gtx_txd_10;
      end

      always @(posedge gmii_rx_clk) begin
          even         <= ~even;
          gtx_rxd_10_r <= even ? gtp_rxd_l : gtp_rxd_h;
      end

      always @(posedge gtx_tx_clk) begin
          gtx_txd_l <= {gtx_txd_10, gtx_txd_r};
      end

      assign gtx_txd = gtx_txd_l;
      assign gtx_rxd_10 = gtx_rxd_10_r;

   end else begin

      assign gtx_txd    = gtx_txd_10;
      assign gtx_rxd_10 = gtx_rxd;

   end endgenerate


   // ----------------------------------
   // PCS/PMA and GMII Bridge
   // ---------------------------------

   wire [15:0] lacr_rx;

   gmii_link i_gmii_link(
        // GMII to MAC
        .RX_CLK       (gmii_rx_clk),
        .RXD          (gmii_rxd),
        .RX_DV        (gmii_rx_dv),
        // MAC to GMII
        .GTX_CLK      (gmii_tx_clk),
        .TXD          (gmii_txd),
        .TX_EN        (gmii_tx_en),
        .TX_ER        (1'b0),
        // To Transceiver
        .txdata       (gtx_txd_10),
        .rxdata       (gtx_rxd_10),
        .rx_err_los   (1'b0),
        .an_bypass    (an_disable), // Disable auto-negotiation
        .lacr_rx      (lacr_rx),
        .an_status    (an_status)
   );

   // ----------------------------------
   // Ethernet MAC
   // ---------------------------------
   localparam SEL_MACIP = 0, SEL_UDP = 1;

   wire cfg_ipmac = (cfg_addr[4]==SEL_MACIP) & cfg_valid;
   wire cfg_udp   = (cfg_addr[4]==SEL_UDP) & cfg_valid;

   rtefi_blob #(.mac_aw(2)) badger(
      // GMII Input (Rx)
		.ip						(ip),
		.mac						(mac),
      .rx_clk              (gmii_rx_clk),
      .rxd                 (gmii_rxd),
      .rx_dv               (gmii_rx_dv),
      .rx_er               (1'b0),
      // GMII Output (Tx)
      .tx_clk              (gmii_tx_clk),
      .txd                 (gmii_txd),
      .tx_en               (gmii_tx_en),
      // Configuration
      .enable_rx           (cfg_enable_rx),
      .config_clk          (cfg_clk),
      .config_a            (cfg_addr[3:0]),
      .config_d            (cfg_wdata),
      .config_s            (cfg_ipmac),
      .config_p            (cfg_udp),
      // TX MAC Host interface
      .host_clk            (1'b0),
      .host_waddr          (3'b0),
      .host_write          (1'b0),
      .host_wdata          (16'b0),
      .tx_mac_done         (),
      // Debug ports
      .ibadge_stb          (),
      .ibadge_data         (),
      .obadge_stb          (),
      .obadge_data         (),
      .xdomain_fault       (),
      // Pass-through to user modules
      .p2_nomangle         (1'b0),
      .p3_addr             (lb_addr),
      .p3_control_strobe   (lb_valid),
      .p3_control_rd       (lb_rnw),
      .p3_control_rd_valid (lb_renable),
      .p3_data_out         (lb_wdata),
      .p3_data_in          (lb_rdata),
      .rx_mon              (rx_mon),
      .tx_mon              (tx_mon)
   );

endmodule
