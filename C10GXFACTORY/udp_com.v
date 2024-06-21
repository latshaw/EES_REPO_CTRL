// ------------------------------------
// COMMS_TOP.v
//
// NOTE: Compatible with QF2_PRE *only*. Older board versions are unsupported.
// Instantiates Ethernet and ChitChat cores and connects them to an auto-generated Quad GTX.
// Ethernet core/local-bus provides access to ChitChat operating in loopback mode.
// ------------------------------------

module udp_com
(
     input     clock,
     input     reset_n,
	  
	  input [2:0]	ip_sel,
	  
	  output		lb_clk,

     //inout     sfp_sda_0,
     //output    sfp_scl_0,

     input     sfp_refclk_p,
     input     sfp_rx_0_p,
     output    sfp_tx_0_p,

     // Local Bus interface
     output            lb_valid,
     output            lb_rnw,
     output [23:0]     lb_addr, // if using lb_addr_raw, set this to be a reg
     output [31:0]     lb_wdata,
     output            lb_renable,
     input  [31:0]     lb_rdata,
     input  [31:0]     sfp_dataw,
	  output [31:0]     sfp_datar,
	  input  [31:0]     sfp_ctrl,
	  output sfp_config_done0
);


//tca9534_i2c u3 (
//     .clock               (clock),
//     .reset               (reset_n),
//     .sda                 (sfp_sda_0),
//     .scl                 (sfp_scl_0),
//	  .sfp_dataw           (sfp_dataw),
//	  .sfp_datar           (sfp_datar),
//	  .sfp_ctrl            (sfp_ctrl),
//     .tca_config_done     (sfp_config_done0)
//);

reg [31:0] ip_addr_sel;
reg [47:0]	mac_addr_sel;
reg [2:0]	ip_sel_in = 0;


always @(*)
begin
	case(ip_sel)
		3'b000		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd101};			
		3'b001		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd102};
		3'b010		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd103};
		3'b011		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd104};
		3'b100		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd105};
		3'b101		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd106};
		3'b110		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd107};
		3'b111		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd108};
		default		:	ip_addr_sel		=	{8'd192, 8'd168, 8'd50, 8'd101};
	endcase
end
	
always @(*)
begin
	case(ip_sel)
		3'b000		:	mac_addr_sel		=	48'h00105ad155b7;			
		3'b001		:	mac_addr_sel		=	48'h00105ad155b8;
		3'b010		:	mac_addr_sel		=	48'h00105ad155b9;
		3'b011		:	mac_addr_sel		=	48'h00105ad155ba;
		3'b100		:	mac_addr_sel		=	48'h00105ad155bb;
		3'b101		:	mac_addr_sel		=	48'h00105ad155bc;
		3'b110		:	mac_addr_sel		=	48'h00105ad155bd;
		3'b111		:	mac_addr_sel		=	48'h00105ad155be;
		default		:	mac_addr_sel		=	48'h00105ad155b7;
	endcase
end


localparam LBUS_ADDR_WIDTH = 24;
localparam LBUS_DATA_WIDTH = 32;
localparam GTX_ETH_WIDTH = 10;
// 192.168.50.110 is IP for LLRF 3.0 Resonance
//localparam IPADDR = {8'd192, 8'd168, 8'd50, 8'd110};
//localparam MACADDR = 48'h00105ad155b5;

localparam JUMBO_DW = 14;


// ----------------------------------
// Clocking
// ---------------------------------
wire sys_clk;
wire gtrefclk0;
wire gmii_tx_clk, gmii_rx_clk;
wire gtx0_tx_out_clk, gtx0_rx_out_clk;
wire gtx0_tx_usr_clk, gtx0_rx_usr_clk, gtx0_tx_usr_clk_OUT;
wire tx0_pll_lock, rx0_pll_lock;
wire gtx1_tx_out_clk, gtx1_rx_out_clk;
wire gtx1_tx_usr_clk, gtx1_rx_usr_clk;

// ----------------------------------
// GTX Instantiation
// ---------------------------------

// Instantiate wizard-generated GTX transceiver
// Configured by gtx_ethernet.tcl and gtx_gen.tcl
// Refer to qgtx_wrap_pack.vh for port map

wire [GTX_ETH_WIDTH-1:0]    gtx0_rxd, gtx0_txd;

// Status signals
wire gt_cpll_locked;
wire gt_txrx_resetdone;
wire gt0_rxfsm_resetdone, gt0_txfsm_resetdone;
wire [2:0] gt0_rxbufstatus;
wire [1:0] gt0_txbufstatus;
wire gt1_rxfsm_resetdone, gt1_txfsm_resetdone;
wire [2:0] gt1_rxbufstatus;
wire [1:0] gt1_txbufstatus;
wire gt1_rxbyteisaligned;
wire tx_analogreset;
wire tx_digitalreset;
wire rx_analogreset;
wire rx_digitalreset;
wire tx_cal_busy;
wire rx_cal_busy;
wire rx_is_lockedtodata;
wire pll_powerdown;
wire pll_locked;
wire tx_serial_clk;
wire tx_rdy;
wire rx_rdy;


transceiver_phy_wrap u0 (
     .tx_analogreset              (tx_analogreset),         // input,  width = 1, tx_analogreset.tx_analogreset
     .tx_digitalreset             (tx_digitalreset),        // input,  width = 1, tx_digitalreset.tx_digitalreset
     .rx_analogreset              (rx_analogreset),         // input,  width = 1, rx_analogreset.rx_analogreset
     .rx_digitalreset             (rx_digitalreset),        // input,  width = 1, rx_digitalreset.rx_digitalreset
     .tx_cal_busy                 (tx_cal_busy),            // output, width = 1, tx_cal_busy.tx_cal_busy
     .rx_cal_busy                 (rx_cal_busy),            // output, width = 1, rx_cal_busy.rx_cal_busy
     .tx_serial_clk0              (tx_serial_clk),          // input,  width = 1, tx_serial_clk0.clk
     .rx_cdr_refclk0              (sfp_refclk_p),           // input,  width = 1, rx_cdr_refclk0.clk
     .tx_serial_data              (sfp_tx_0_p),             // output, width = 1, tx_serial_data.tx_serial_data
     .rx_serial_data              (sfp_rx_0_p),             // input,  width = 1, rx_serial_data.rx_serial_data
     .rx_is_lockedtoref           (),                       // output, width = 1, rx_is_lockedtoref.rx_is_lockedtoref
     .rx_is_lockedtodata          (rx_is_lockedtodata),     // output, width = 1, rx_is_lockedtodata.rx_is_lockedtodata
     .tx_coreclkin                (gtx0_tx_usr_clk),        // input,  width = 1, tx_coreclkin.clk
     .rx_coreclkin                (gtx0_rx_usr_clk),        // input,  width = 1, rx_coreclkin.clk
     .tx_clkout                   (gtx0_tx_usr_clk),    // output, width = 1, tx_clkout.clk
     .rx_clkout                   (gtx0_rx_usr_clk),        // output, width = 1, rx_clkout.clk
     .tx_parallel_data            (gtx0_txd),               // input,  width = 10, tx_parallel_data.tx_parallel_data
     .unused_tx_parallel_data     (118'b0),                 // input,  width = 118, unused_tx_parallel_data.unused_tx_parallel_data
     .rx_parallel_data            (gtx0_rxd),               // output, width = 10, rx_parallel_data.rx_parallel_data
     .unused_rx_parallel_data     ()                        // output, width = 118, unused_rx_parallel_data.unused_rx_parallel_data
);

//wire gtx0_tx_usr_clk = gtx0_tx_usr_clk_OUT;

transeiver_phy_rst u1 (
     .clock                  (clock),                  // input,  width = 1, clock.clk
     .reset                  (1'b0),                   // input,  width = 1, reset.reset
     .pll_powerdown          (pll_powerdown),          // output, width = 1, pll_powerdown.pll_powerdown
     .tx_analogreset         (tx_analogreset),         // output, width = 1, tx_analogreset.tx_analogreset
     .tx_digitalreset        (tx_digitalreset),        // output, width = 1, tx_digitalreset.tx_digitalreset
     .tx_ready               (tx_rdy),                 // output, width = 1, tx_ready.tx_ready
     .pll_locked             (pll_locked),             // input,  width = 1, pll_locked.pll_locked
     .pll_select             (1'b0),                   // input,  width = 1, pll_select.pll_select
     .tx_cal_busy            (tx_cal_busy),            // input,  width = 1, tx_cal_busy.tx_cal_busy
     .rx_analogreset         (rx_analogreset),         // output, width = 1, rx_analogreset.rx_analogreset
     .rx_digitalreset        (rx_digitalreset),        // output, width = 1, rx_digitalreset.rx_digitalreset
     .rx_ready               (rx_rdy),                 // output, width = 1, rx_ready.rx_ready
     .rx_is_lockedtodata     (rx_is_lockedtodata),     // input,  width = 1, rx_is_lockedtodata.rx_is_lockedtodata
     .rx_cal_busy            (rx_cal_busy)             // input,  width = 1, rx_cal_busy.rx_cal_busy
);


xcvr_phy_pll u2 (
     .pll_powerdown     (pll_powerdown),     // input,  width = 1, pll_powerdown.pll_powerdown
     .pll_refclk0       (sfp_refclk_p),      // input,  width = 1, pll_refclk0.clk
     .tx_serial_clk     (tx_serial_clk),     // output, width = 1, tx_serial_clk.clk
     .pll_locked        (pll_locked),        // output, width = 1, pll_locked.pll_locked
     .pll_cal_busy      ()                   // output, width = 1, pll_cal_busy.pll_cal_busy
);


// ----------------------------------
// GTX Ethernet to Local-Bus bridge
// ---------------------------------

wire rx_mon, tx_mon;
wire [6:0] an_status;
// 3/19/21, appended RAW to the end of these
// to show that they are directly from the i eth gtx bridge
//
//wire lb_valid_raw, lb_rnw_raw, lb_renable_raw;
wire [LBUS_ADDR_WIDTH-1:0] lb_addr_raw;
//wire [LBUS_DATA_WIDTH-1:0] lb_wdata_raw, lb_rdata_raw;


eth_gtx_bridge #(
     .JUMBO_DW     (JUMBO_DW),
     .GTX_DW       (GTX_ETH_WIDTH)
)
i_eth_gtx_bridge (
      .ip				   (ip_addr_sel),
		.mac			    	(mac_addr_sel),
     .gtx_tx_clk        (gtx0_tx_usr_clk),     // Transceiver clock
     .gmii_tx_clk       (gtx0_tx_usr_clk),     // Clock for Ethernet fabric - 125 MHz for 1GbE
     .gmii_rx_clk       (gtx0_rx_usr_clk),
     .gtx_rxd           (gtx0_rxd),
     .gtx_txd           (gtx0_txd),

     // Ethernet configuration interface
     .cfg_clk           (gtx0_tx_usr_clk),
     .cfg_enable_rx     (1'b1),
     .cfg_valid         (1'b0),
     .cfg_addr          (5'b0),
     .cfg_wdata         (8'b0),

     // Status signals
     .rx_mon            (rx_mon),
     .tx_mon            (tx_mon),
     .an_status         (an_status),

     // Local bus interface in gmii_tx_clk domain
     .lb_valid          (lb_valid),
     .lb_rnw            (lb_rnw),
     .lb_addr           (lb_addr), // was lb_addr_raw, changed to fix race condition
     .lb_wdata          (lb_wdata),
     .lb_renable        (lb_renable),
     .lb_rdata          (lb_rdata)
);

// added 3/19/21, JAL
// goal is to pass gtx0_tx_usr_clk is run local bus logic off of this clock. 
assign lb_clk = gtx0_tx_usr_clk;
// JAL 7/12/21, was causing a race condition with the resonacne chassis when
// the sequencer would write a register in between polling.
//always @(posedge gtx0_tx_usr_clk) if (lb_valid) lb_addr <= lb_addr_raw;



endmodule
