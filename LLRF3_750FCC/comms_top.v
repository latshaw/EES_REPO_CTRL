// ------------------------------------
// COMMS_TOP.v
//
// NOTE: Compatible with QF2_PRE *only*. Older board versions are unsupported.
// Instantiates Ethernet and ChitChat cores and connects them to an auto-generated Quad GTX.
// Ethernet core/local-bus provides access to ChitChat operating in loopback mode.
// ------------------------------------

module comms_top
(
   
	input		clock,
	input		reset,
	
	input [2:0]	ip_sel,
	inout		sfp_sda_0,
	output	sfp_scl_0,
//	input [17:0] qdiff,
//	input [1:0] qstat,
//	input	[179:0]	cirbuf_data_in,
	
	output 			lb_clk,
	output 			lb_valid,
	output			lb_rnw,
	output [23:0] 	lb_addr,
	output [31:0] 	lb_wdata,
	output 			lb_renable,	
	input [31:0]	lb_rdata,
	
	
//	input 		rfprm,
//	input [17:0] prbi,
//	input [17:0] prbq,
//	input [143:0] fltrd,
//	input [143:0] frrmp,
//	input [17:0] deta,
//	input [17:0] cfqea,
//	input [17:0] deta2,
//	input [17:0] gmes,
//	input [17:0] pmes,
//	input [17:0] gerror,
//	input [17:0] perror,
//	input [17:0] gask,
//	input [17:0] pask,
//	input [17:0] iask,
//	input [17:0] qask,
//	input [3:0] xystat,
//	input [71:0] disc,
//	input [3:0] fib_stat,
	 
//	input		adc_data_clk,
//	input [17:0] reg_data,
	
//	input [9:0] c10gx_tmp,
//	input [15:0] lopwh,
//	input plsdone,
//	input [1:0] lmk_lock,
//	input [1:0] lmk_ref,
//	input strobe,
//	input [17:0] prmp,
//	
//	
//	output [17:0] tdoff,
//	output [17:0] mpro,
//	output [17:0] mi,
//	output [17:0] mirate,
//	output [17:0] ppro,
//	output [17:0] pi,
//	output [17:0] pirate,
//	output [17:0] xlimlo,
//	output [17:0] xlimhi,
//	output [17:0] ylimlo,
//	output [17:0] ylimhi,
//	output [17:0] gset,
//	output [17:0] pset,
//	output [17:0] prmpr,
//	output [17:0] glos,
//	output [17:0] gdcl,
//	output [1:0] maglp,
//	output [17:0] plos,
//	output [1:0] phslp,
//	output [17:0] poff,
//	output [31:0] plson,
//	output [31:0] plsoff,
//	output wavs_takei,
//	output rfon,
//	output stpena,
//	output [15:0] fib_msk_set,
//	
//	output	fault_clear,
//	output	kly_ch,	
//	output [5:0] ratn,
//	output [2:0] dac_mux_sel,
//	output [17:0] qrate,
//	output [17:0] qslope,
//	output qmsk,
//	output [17:0]	glow,
//	output [6:0]	reg_addr,
	

	
   input		sfp_refclk_p, 
   input		sfp_rx_0_p,  
   output	sfp_tx_0_p    
);

// JAL, not using SFP 5/21/24
//tca9534_i2c u3(
//			.clock				(sfp_refclk_p),
//			.reset				(reset),
//			.sda					(sfp_sda_0),
//			.scl					(sfp_scl_0),
//			.tca_config_done	(sfp_config_done0)
//			);
			

reg [31:0] ip_addr_sel;
reg [47:0]	mac_addr_sel;
reg [2:0]	ip_sel_in = 0;

//always @(posedge lb_clk) ip_sel_in	<=	ip_sel;





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

//reg [31:0] ip_addr_sel_in = {8'd192, 8'd168, 8'd50, 8'd101};
//
//always @(posedge lb_clk) ip_addr_sel_in	<=	ip_addr_sel;
//
//reg [47:0] mac_addr_sel_in = 48'h00105ad155b7;
//
//always @(posedge lb_clk) mac_addr_sel_in	<=	mac_addr_sel;			
			
			

			
localparam LBUS_ADDR_WIDTH = 24;
localparam LBUS_DATA_WIDTH = 32;

localparam GTX_ETH_WIDTH = 10;


//   localparam IPADDR   = {8'd192, 8'd168, 8'd50, 8'd102};//this is for fpgarffcc2
 //  localparam MACADDR  = 48'h00105ad155b8;
   localparam JUMBO_DW = 14;


   



   // ----------------------------------
   // Clocking
   // ---------------------------------
   wire sys_clk;
   wire gtrefclk0;

   wire gmii_tx_clk, gmii_rx_clk;
   wire gtx0_tx_out_clk, gtx0_rx_out_clk;
   wire gtx0_tx_usr_clk, gtx0_rx_usr_clk;
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
		.tx_analogreset     (tx_analogreset),     //   input,    width = 1,     tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset),    //   input,    width = 1,    tx_digitalreset.tx_digitalreset
		.rx_analogreset     (rx_analogreset),     //   input,    width = 1,     rx_analogreset.rx_analogreset
		.rx_digitalreset    (rx_digitalreset),    //   input,    width = 1,    rx_digitalreset.rx_digitalreset
		.tx_cal_busy        (tx_cal_busy),        //  output,    width = 1,        tx_cal_busy.tx_cal_busy
		.rx_cal_busy        (rx_cal_busy),        //  output,    width = 1,        rx_cal_busy.rx_cal_busy
		.tx_serial_clk0     (tx_serial_clk),     //   input,    width = 1,     tx_serial_clk0.clk
		.rx_cdr_refclk0     (sfp_refclk_p),     //   input,    width = 1,     rx_cdr_refclk0.clk
		.tx_serial_data     (sfp_tx_0_p),     //  output,    width = 1,     tx_serial_data.tx_serial_data
		.rx_serial_data     (sfp_rx_0_p),     //   input,    width = 1,     rx_serial_data.rx_serial_data
		.rx_is_lockedtoref  (),  //  output,    width = 1,  rx_is_lockedtoref.rx_is_lockedtoref
		.rx_is_lockedtodata (rx_is_lockedtodata), //  output,    width = 1, rx_is_lockedtodata.rx_is_lockedtodata
		.tx_coreclkin       (gtx0_tx_usr_clk),       //   input,    width = 1,       tx_coreclkin.clk
		.rx_coreclkin       (gtx0_rx_usr_clk),       //   input,    width = 1,       rx_coreclkin.clk
		.tx_clkout          (gtx0_tx_usr_clk),          //  output,    width = 1,          tx_clkout.clk
		.rx_clkout          (gtx0_rx_usr_clk),          //  output,    width = 1,          rx_clkout.clk
		.tx_parallel_data   (gtx0_txd),   //   input,  width = 10,   tx_parallel_data.tx_parallel_data
		.unused_tx_parallel_data (118'b0), //   input,  width = 118, unused_tx_parallel_data.unused_tx_parallel_data
		.rx_parallel_data   (gtx0_rxd),    //  output,  width = 10,   rx_parallel_data.rx_parallel_data
		.unused_rx_parallel_data ()  //  output,  width = 118, unused_rx_parallel_data.unused_rx_parallel_data
	);
	
		transeiver_phy_rst u1 (
		.clock              (clock),              //   input,  width = 1,              clock.clk
		.reset              (1'b0),              //   input,  width = 1,              reset.reset
		.pll_powerdown      (pll_powerdown),      //  output,  width = 1,      pll_powerdown.pll_powerdown
		.tx_analogreset     (tx_analogreset),     //  output,  width = 1,     tx_analogreset.tx_analogreset
		.tx_digitalreset    (tx_digitalreset),    //  output,  width = 1,    tx_digitalreset.tx_digitalreset
		.tx_ready           (tx_rdy),           //  output,  width = 1,           tx_ready.tx_ready
		.pll_locked         (pll_locked),         //   input,  width = 1,         pll_locked.pll_locked
		.pll_select         (1'b0),         //   input,  width = 1,         pll_select.pll_select
		.tx_cal_busy        (tx_cal_busy),        //   input,  width = 1,        tx_cal_busy.tx_cal_busy
		.rx_analogreset     (rx_analogreset),     //  output,  width = 1,     rx_analogreset.rx_analogreset
		.rx_digitalreset    (rx_digitalreset),    //  output,  width = 1,    rx_digitalreset.rx_digitalreset
		.rx_ready           (rx_rdy),           //  output,  width = 1,           rx_ready.rx_ready
		.rx_is_lockedtodata (rx_is_lockedtodata), //   input,  width = 1, rx_is_lockedtodata.rx_is_lockedtodata
		.rx_cal_busy        (rx_cal_busy)         //   input,  width = 1,        rx_cal_busy.rx_cal_busy
	);
		xcvr_phy_pll u2 (
		.pll_powerdown (pll_powerdown), //   input,  width = 1, pll_powerdown.pll_powerdown
		.pll_refclk0   (sfp_refclk_p),   //   input,  width = 1,   pll_refclk0.clk
		.tx_serial_clk (tx_serial_clk), //  output,  width = 1, tx_serial_clk.clk
		.pll_locked    (pll_locked),    //  output,  width = 1,    pll_locked.pll_locked
		.pll_cal_busy  ()   //  output,  width = 1,  pll_cal_busy.pll_cal_busy
	);







   // ----------------------------------
   // GTX Ethernet to Local-Bus bridge
   // ---------------------------------
   wire rx_mon, tx_mon;
   wire [6:0] an_status;

//   wire lb_valid, lb_rnw, lb_renable;
//   wire [LBUS_ADDR_WIDTH-1:0] lb_addr;
//	wire [LBUS_ADDR_WIDTH-1:0] lb_addr_out;
//   wire [LBUS_DATA_WIDTH-1:0] lb_wdata, lb_rdata;

   eth_gtx_bridge #(
//      .IP         (IPADDR),
//      .MAC        (MACADDR),
      .JUMBO_DW   (JUMBO_DW),
		.GTX_DW		(GTX_ETH_WIDTH)
		)
   i_eth_gtx_bridge (
      .ip				(ip_addr_sel),
		.mac				(mac_addr_sel),
		.gtx_tx_clk    (gtx0_tx_usr_clk), // Transceiver clock
      .gmii_tx_clk   (gtx0_tx_usr_clk),     // Clock for Ethernet fabric - 125 MHz for 1GbE
      .gmii_rx_clk   (gtx0_rx_usr_clk),
      .gtx_rxd       (gtx0_rxd),
      .gtx_txd       (gtx0_txd),

      // Ethernet configuration interface
      .cfg_clk       (gtx0_tx_usr_clk),
      .cfg_enable_rx (1'b1),
      .cfg_valid     (1'b0),
      .cfg_addr      (5'b0),
      .cfg_wdata     (8'b0),

      // Status signals
      .rx_mon        (rx_mon),
      .tx_mon        (tx_mon),
      .an_status     (an_status),

      // Local bus interface in gmii_tx_clk domain
      .lb_valid      (lb_valid),
      .lb_rnw        (lb_rnw),
      .lb_addr       (lb_addr),
      .lb_wdata      (lb_wdata),
      .lb_renable    (lb_renable),
      .lb_rdata      (lb_rdata)
   );

   assign lb_clk = gtx0_tx_usr_clk;
	

   // ----------------------------------
   // Optional CTRACE debugging scope
   // ---------------------------------

wire [31:0] ctr_mem_out;
//`define CTRACE_EN
//`ifdef CTRACE_EN
//
//   // Capture live data with Ctrace;
//   // Data is compressed with a form of run-length encoding. Max length
//   // of a run is determined by CTRACE_TW.
//   // CTRACE_AW determines the total number of unique data-points.
//
//   localparam CTR_DW = 16;
//   localparam CTR_TW = 16; // Determines maximum run length
//   localparam CTR_AW = 16;
//
//   wire ctr_clk = gmii_rx_clk;
//   wire ctr_start = dbg_bus[16];
//   wire [CTR_DW-1:0] ctr_data = dbg_bus[15:0];
//
//   ctrace #(
//      .dw   (CTR_DW),
//      .tw   (CTR_TW),
//      .aw   (CTR_AW))
//   i_ctrace (
//      .clk     (ctr_clk),
//      .start   (ctr_start),
//      .data    (ctr_data),
//      .lb_clk  (lb_clk),
//      .lb_addr (lb_addr[CTR_AW-1:0]),
//      .lb_out  (ctr_mem_out)
//);
//`endif

//wire [17:0]		cir_rate;
//wire [17:0]		flt_rate;
//wire [17:0]		reg_data_out;
//wire [179:0]	cirbuf_data_out;
//wire [179:0]	fault_data_out;
//
//wire [1:0] buf_done;
//wire [1:0] buf_take;
//wire [1:0] buf_rd;
//
//wire epcb;
//wire [31:0] epcsa;
//wire [7:0] epcsd;	
//wire [3:0] epcsc;
//wire [7:0] epcsr;
//
//
//wire [15:0]	fccid;



   // ----------------------------------
   // Local Bus Register Decoding
   // ---------------------------------
//   comms_top_regbank i_comms_regbank
//   (
////		.reset				  (reset),
//      .lb_clk             (lb_clk),
//      .lb_valid           (lb_valid),
//      .lb_rnw             (lb_rnw),
//      .lb_addr            (lb_addr),
//      .lb_wdata           (lb_wdata),
//      .lb_renable         (lb_renable),
//      .lb_rdata           (lb_rdata),
//		
//		.reg_data				(reg_data_out),
//		
////		.qdiff					(qdiff),
////		.qstat					(qstat),	
////		.buf_done				(buf_done),
//		.cirbuf_data			(cirbuf_data_out),
//		.fault_data				(fault_data_out[17:0])
////		.rfprm					(rfprm),
////		.prbi						(prbi),
////		.prbq						(prbq),
////		.fltrd					(fltrd),
////		.frrmp					(frrmp),
////		.deta						(deta),
////		.cfqea					(cfqea),
////		.deta2					(deta2),
////		.gmes						(gmes),
////		.pmes						(pmes),
////		.gerror					(gerror),
////		.perror					(perror),
////		.gask						(gask),
////		.pask						(pask),
////		.iask						(iask),
////		.qask						(qask),
////		.xystat					(xystat),
////		.disc						(disc),
////		.fib_stat				(fib_stat),
////		.adc_data_clk			(adc_data_clk),
////		.c10gx_tmp				(c10gx_tmp),
////		.lopwh					(lopwh),
////		.plsdone					(plsdone),	
////		.epcsb					(epcsb),
////		.epcsr					(epcsr),
////		.fccid					(fccid),
////		.lmk_lock				(lmk_lock),
////		.lmk_ref					(lmk_ref),
////		.prmp						(prmp),
////		
////		.tdoff					(tdoff),
////		.mpro						(mpro),
////		.mi						(mi),
////		.mirate					(mirate),
////		.ppro						(ppro),
////		.pi						(pi),
////		.pirate					(pirate),
////		.xlimlo					(xlimlo),
////		.xlimhi					(xlimhi),
////		.ylimlo					(ylimlo),
////		.ylimhi					(ylimhi),
////		.gset						(gset),
////		.pset						(pset),
////		.prmpr					(prmpr),
////		.glos						(glos),
////		.gdcl						(gdcl),
////		.maglp					(maglp),
////		.plos						(plos),
////		.phslp					(phslp),
////		.poff						(poff),
////		.plson					(plson),
////		.plsoff					(plsoff),
////		.rfon						(rfon),
////		.stpena					(stpena),
////		.fib_msk_set			(fib_msk_set),
////		.fault_clear			(fault_clear),
////		.ratn						(ratn),
////		.dac_mux_sel			(dac_mux_sel),
////		.cir_rate				(cir_rate),
////		.flt_rate				(flt_rate),
////		.buf_take				(buf_take),
////		.kly_ch					(kly_ch),
////		.qrate					(qrate),
////		.qslope					(qslope),
////		.qmsk						(qmsk),
////		.epcsa					(epcsa),
////		.epcsd					(epcsd),
////		.epcsc					(epcsc)
////		.glow						(glow)	
//		
//		
//
////      .rx_frame_counter_i (0),
////      .txrx_latency_i     (0),
////      .ccrx_fault_i       (0),
////      .ccrx_fault_cnt_i   (0),
////      .ccrx_los_i         (0),
////      .rx_protocol_ver_i  (0),
////      .rx_gateware_type_i (0),
////      .rx_location_i      (0),
////      .rx_rev_id_i        (0),
////      .rx_data0_i         (0),
////      .rx_data1_i         (0),
////      .rx_match0_i        (0),
////      .rx_match1_i        (0),
////      .rx_err_cnt0_i      (0),
////      .rx_err_cnt1_i      (0),
////      .an_status_i        (0),
////      .ctr_mem_out_i      (0),
////
////      .tx_location_o      (),
////      .tx_transmit_en_o   (),
////      .pgen_disable_o     (),
////      .pgen_rate_o        (),
////      .pgen_test_mode_o   (),
////      .pgen_inc_step_o    (),
////      .pgen_usr_data_o    ()
//   );
//	
//dpram_rdreg dpram_rdreg_i
//		(.reset_n(reset),
//		.rdclock(lb_clk),
//		.wrclock(adc_data_clk),
//		.data_in(reg_data),
//		.addr_in(lb_addr[6:0]),
//		.addr_out(reg_addr),
//		.data_out(reg_data_out)
//		);
	
//epcs_cntl epcs_cntl_i
//	(.clock		(lb_clk),
//	 .reset		(reset),
//	 .epcs_busy	(epcsb),
//	 .address	(epcsa),
//	 .data		(epcsd),
//	 .cntl		(epcsc),
//	 .result		(epcsr),
//	 .fccid		(fccid)
//	  );
	  

	 
//assign wavs_takei = buf_take[0];	 
//
//cirbuf_data cirbuf_data_i
//	(.wrclock	(adc_data_clk),
//	 .rdclock	(lb_clk),	
//	
//	 .reset(reset),
//		 
//	 .takei(buf_take[0]),
//	 .strobe(strobe),
//	 .rate(cir_rate),
////	 .isa_rd(buf_rd),
//	 .isa_addr_rd(lb_addr),
//	 .data_in(cirbuf_data_in),		 
//	 .data_out(cirbuf_data_out),	 
//	 .buf_done(buf_done[0])
//		 );
		
//cirbuf_data fault_data_i
//	(.wrclock	(adc_data_clk),
//	 .rdclock	(lb_clk),	
//	
//	 .reset(reset),
//		 
//	 .takei(buf_take[1]),
//	 .rate(flt_rate),
////	 .isa_rd(buf_rd),
//	 .isa_addr_rd(lb_addr),
//	 .data_in(cirbuf_data_in),		 
//	 .data_out(fault_data_out),	 
//	 .buf_done(buf_done[1])
//		 );			
   // ----------------------------------
   // Status LEDs
   // ---------------------------------
//   wire lbus_led = lb_valid&lb_rnw; // Toggle every 2**15 frames


   // LED[0] Auto-negotiation complete
   // LED[1] Received and decoded packet
//   assign LEDS = {tx_rdy, pll_locked,rx_rdy, an_status[1]};

endmodule
//D19-user_led0-AF6-LEDS[0]
//D20-user_led1-AE6-LEDS[1]
//D21-user_led2-AC6-LEDS[2]
//D22-user_led3-AC7-LEDS[3]
