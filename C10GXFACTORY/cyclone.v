//6-5-24 updated Remote Update (ru) section to facilitate golden image interface
//10/14/24, heavy re-org to truly seperate slow/fst clock domains
// where i left off, look slike address is being written, maybe look into read/read-en somehow resetting the read process
// dpram_data_20 contnets seem to be written when assigned as a constant
module cyclone (
	// Global signals
	input lb_clk,
	input reset_n,
	// Control registers
	input  [31:0] c10_addr, // external, all bits used
	input  [31:0] c10_data, // external, only lower 16 bits used
	input  [31:0] c10_cntlr, // external, only lower 8 bits used
	output [31:0] c10_status, // all bits used
	output [31:0] c10_datar, // only lower 8 bits used
	input  [2:0]  ru_param,
	input  [31:0] ru_data_in,
	input  [2:0] ru_ctrl,
	output [31:0] ru_data_out,
	input we_cyclone_inst_c10_data
  );
  
  	// =============================================================
	// Clock Generationg
	// =============================================================
	//
	wire clk_20; // 20 MHz clock to drive all 'slow clock' logic
	wire pll20_rst;
	assign pll20_rst = (reset_n==1'b1)? 1'b0 : 1'b1;
	//
	//pll inst
	pll20 pll20_inst (.rst(pll20_rst), //active hi reset
		               .refclk(lb_clk), .outclk_0(clk_20));
	//
	//
	wire [31:0] c10_status_125;
	wire [31:0] c10_status_d_125;
	reg  [2:0] dummy_addr125;
	wire [2:0] dummy_addr125_d;
	reg  [1:0] wrsm;
	wire [1:0] wrsm_d;
	wire cdc_we;
	//
	reg [31:0] state_var_125;
	wire[31:0] state_var_125_d;
	reg [31:0] state_var_20;
	wire[31:0] state_var_20_d;
	//
	//
	reg  [31:0] c10_status_20;
	wire [31:0] c10_status_d_20;
	 
	reg [2:0] dummy_addr20;
	wire[2:0] dummy_addr20_d;
	reg [8:0] wrsm_20;
	wire[8:0] wrsm_20_d;
	wire cdc_we_20;

	reg  [31:0] c10_addr_20 /* synthesis noprune*/;
	wire [31:0] c10_addr_20_d;
	reg  [15:0] c10_data_20 /* synthesis noprune*/;
	wire [15:0] c10_data_20_d;
	wire [7:0]  c10_cntlr_20;//, dpraw_w_douta_20;
	//
	//
	reg  [2:0]  ru_param_20, ru_ctrl_20 /* synthesis noprune*/; 
	wire [5:0]  ru_p_c_d_in;
	wire [5:0]  ru_p_c_d;
	reg  [31:0] ru_data_in_20 /* synthesis noprune*/;
	wire [31:0] ru_data_in_d_20;
	wire [31:0] ru_data_out_20;

	
	wire [31:0] c10_addr_d_20;
	wire [15:0] c10_data_d_20;
	wire [7:0]  c10_cntlr_d_20, dpraw_w_douta;//, dpraw_w_douta_d_20, ;
	//
	// EPCQ CDC
	 data_xdomain #(.size(32)) cdc_1 (
			.clk_in(lb_clk), .gate_in(1'b1), .data_in(c10_addr),             //fast clock, TX
			.clk_out(clk_20), .data_out(c10_addr_20_d));                     //slow clock, RX
	 data_xdomain #(.size(16)) cdc_2 (
			.clk_in(lb_clk), .gate_in(1'b1), .data_in(c10_data[15:0]),       //fast clock, TX
			.clk_out(clk_20), .data_out(c10_data_20_d));                     //slow clock, RX
	 data_xdomain #(.size(8)) cdc_3 (
			.clk_in(lb_clk), .gate_in(1'b1), .data_in(c10_cntlr[7:0]),       //fast clock, TX
			.clk_out(clk_20), .data_out(c10_cntlr_20));                      //slow clock, RX
	 data_xdomain #(.size(32)) cdc_4 (
			.clk_in(clk_20), .gate_in(1'b1), .data_in(c10_status_d_20),      //slow clock, TX
			.clk_out(lb_clk), .data_out(c10_status_125));                    //fast clock, RX
	// RU cDC
	assign ru_p_c_d_in = {ru_param, ru_ctrl};
	data_xdomain #(.size(6)) cdc_5 (
			.clk_in(lb_clk), .gate_in(1'b1), .data_in(ru_p_c_d_in),  //fast clock, TX
			.clk_out(clk_20), .data_out(ru_p_c_d));                          //slow clock, RX
	data_xdomain #(.size(32)) cdc_6 (
			.clk_in(lb_clk), .gate_in(1'b1), .data_in(ru_data_in),           //fast clock, TX
			.clk_out(clk_20), .data_out(ru_data_in_d_20));                      //slow clock, RX
	data_xdomain #(.size(32)) cdc_7 (
			.clk_in(clk_20), .gate_in(1'b1), .data_in(ru_data_out_20),       //slow clock, TX
			.clk_out(lb_clk), .data_out(ru_data_out));                       //fast clock, RX
			
	 // note upper most byte is not from clk_20 domain
	 assign c10_status[31:24] = dpraw_w_douta;// note, this is read back data from the fast clock domain. no need for cdc for this byte
	 assign c10_status[23:0] = c10_status_125[23:0];
	//	
	// =============================================================
	// Control signals
	// =============================================================
	wire epcs_write;
	wire epcs_write_pulse;
	wire epcs_rd_pulse;
	wire epcs_rd;
	wire epcs_erase;
	wire epcs_sector_erase_pulse;
	wire epcs_ext_addr;
	wire epcs_ext_addr_pulse;
	wire epcs_reconfig;
	wire epcs_wen_generic_pulse;
	wire dpram_w_en;
	//
	reg  [7:0] epcs_dout_wire; // data coming from EPCS/EPCQ
	wire [7:0] epcs_dout_wire_raw, epcs_formatted;
	wire epcs_inst_busy; // busy signal from EPCS/EPCQ
	//reduce fanout for this busy signal
	reg  epcs_inst_busy_reg; // there were no prunes...
	wire data_valid; // will be a pulse for one clock_rd tick when epcq dout register is valid
	wire busy_pulse_RE;
	wire busy_pulse_FE;
	wire busy_clear;
	wire shift_bytes;
	
	//
	//
	// decode commands from c10_cntlr register
	assign epcs_write    = ( c10_cntlr_20[7:0] == 8'b00001010) ? 1'b1 : 1'b0; // x0A
	assign epcs_rd       = ( c10_cntlr_20[7:0] == 8'b00001001) ? 1'b1 : 1'b0; // x09
	assign epcs_erase    = ( c10_cntlr_20[7:0] == 8'b00001100) ? 1'b1 : 1'b0; // x0C	
	assign epcs_ext_addr = ( c10_cntlr_20[7:0] == 8'b00001011) ? 1'b1 : 1'b0; // x0B
	assign dpram_w_en    = ( c10_cntlr_20[7:0] == 8'b00001101) ? 1'b1 : 1'b0; // x0D
	assign busy_clear    = ( c10_cntlr_20[7:0] == 8'b00001110) ? 1'b1 : 1'b0; // x0E
	assign epcs_reconfig = ( c10_cntlr_20[7:0] == 8'b11110000) ? 1'b1 : 1'b0; // xF0
	
	// =============================================================
	// EPCS/EPCQ pulse timing and bit swizzling :)
	// =============================================================
	// Some signals are required to pulse for only once clock_rd tick
	// There is a clock domain corssing from 125 MHz (control bit) and the rd_clock (125/6).
	reg [1:0] epcs_rd_pulse_gen;
	reg [1:0] epcs_write_pulse_gen;
	reg [1:0] epcs_sector_erase_pulse_gen;
	reg [1:0] epcs_ext_addr_pulse_gen;
	reg [1:0] busy_pulse_gen;
	reg [3:0] delayed_bsy;
	reg busy_RE /* synthesis noprune */;
	reg busy_FE /* synthesis noprune */;
	wire re_flag, fe_flag;
	
	wire trigger_dpram_write;
	
	always@(posedge clk_20) begin
		epcs_rd_pulse_gen           <= {epcs_rd_pulse_gen[0], epcs_rd};
		epcs_write_pulse_gen        <= {epcs_write_pulse_gen[0], trigger_dpram_write}; // was epcs_write
		epcs_sector_erase_pulse_gen <= {epcs_sector_erase_pulse_gen[0], epcs_erase};
		epcs_ext_addr_pulse_gen     <= {epcs_ext_addr_pulse_gen[0], epcs_ext_addr};
		busy_pulse_gen              <= {busy_pulse_gen[0], epcs_inst_busy_reg};
		epcs_inst_busy_reg          <= delayed_bsy[3];//epcs_inst_busy; most of the time at least 2 clocks AFTER busy done are needed, this delay is for that
		delayed_bsy                 <= {delayed_bsy[2:0], epcs_inst_busy};
	end
	// rising edge detection of epcs_rd.  Pulse epcs_rd_pulse hi for one clock_rd tick (per EPCS IP spec)
	// note, 12'hfc0 is a falling edge
	//       12'h03f is a rising edge
	assign epcs_rd_pulse =                     (epcs_rd_pulse_gen == 2'b01) ? 1'b1 : 1'b0;
	assign epcs_write_pulse =               (epcs_write_pulse_gen == 2'b01) ? 1'b1 : 1'b0;
	assign epcs_sector_erase_pulse = (epcs_sector_erase_pulse_gen == 2'b01) ? 1'b1 : 1'b0;
	assign epcs_ext_addr_pulse =         (epcs_ext_addr_pulse_gen == 2'b01) ? 1'b1 : 1'b0;
	assign busy_pulse_FE =                        (busy_pulse_gen == 2'b10) ? 1'b1 : 1'b0; //catch falling edge of busy signal
	assign busy_pulse_RE =                        (busy_pulse_gen == 2'b01) ? 1'b1 : 1'b0; //cath rising edge of busy signal
	//
	//busy flag is hard to catch from IP core. Below logic helps keep from synth away and handles odd ball timing
	assign re_flag = ((busy_pulse_RE==1'b1) & (busy_RE==1'b0))? 1'b1 : busy_RE;
	// falling edge flag auto clears if RE is cleared.
	assign fe_flag = (busy_RE==1'b0)? (1'b0) : ((((busy_pulse_FE==1'b1) & (busy_FE==1'b0)) | (busy_pulse_gen==2'b00) )? 1'b1 : busy_FE);
	
	
	assign epcs_wen_generic_pulse = ((epcs_write_pulse==1'b1) | (epcs_sector_erase_pulse==1'b1) | (epcs_ext_addr_pulse==1'b1) | (shift_bytes==1'b1)) ? 1'b1 : 1'b0;
	
	//busy signal is easy to  miss between (EPICS) controller reads. This latches the rising edge and falling edge bits
	//must be cleared between uses
	

	always@(posedge clk_20) begin
		if (busy_clear == 1'b1 ) begin
			busy_RE <= 1'b0;
			busy_FE <= 1'b0;
		end else begin
			busy_RE <= re_flag;
			busy_FE <= fe_flag;
		end
	end
	
	// catch local bus write strobe pulse and stretch it
	// we_cyclone_inst_c10_data
	reg lb_strobe_last;
	reg [3:0] lb_strobe_stretch;
	wire dpram_writer_wen;
	always@(posedge lb_clk) begin
		lb_strobe_last    <= we_cyclone_inst_c10_data;
		lb_strobe_stretch <= {lb_strobe_stretch[2:0],((we_cyclone_inst_c10_data == 1'b1) & (lb_strobe_last == 1'b0))};
	end
	//
	assign dpram_writer_wen = (( c10_cntlr[7:0] == 8'b00001101) & ((lb_strobe_stretch[3] == 1'b1) |(lb_strobe_stretch[2] == 1'b1))) ? 1'b1 : 1'b0; //was dpram_w_en but this is 20Mhz domain, switched to c10_cntlr for dpram we flad, xD
	//
	//
	//
	//
	//
	//
	//
	//
	//
	// =============================================================
	// Read DPRAM helper
	// =============================================================
	// DPRAM is used to readoff the contents of a block of read registers. This reduces the number of needed waits for busy signal to fall.
	// Target is one hexout length which is 128 bytes or less. dpram set for 256 bytes. Data
	wire [7:0] dpram_addra, dpram_outb;
	reg  [7:0] addra_count;
	wire [7:0] addra_count_d;
	reg read_en_pulse;

	reg  last_dv, last_dv2;
	wire dpram_wena;
	reg read_en;
	wire read_en_d;
	reg  [7:0] epcs_formatted_reg;
	wire [7:0] epcs_formatted_d;
	wire start_rd_con;
	
	always@(posedge clk_20) begin
		if (epcs_rd == 1'b0) begin
			addra_count        <= 8'h00;
			last_dv            <= 1'b0;
			last_dv2           <= 1'b0;
			read_en            <= 1'b0;
			read_en_pulse      <= 1'b0;
			epcs_formatted_reg <= 8'h00;
		end else begin
			addra_count        <= addra_count_d;
			last_dv            <= data_valid;
			last_dv2           <= last_dv;
			read_en            <= read_en_d;
			read_en_pulse      <= read_en_pulse_d;
			epcs_formatted_reg <= epcs_formatted_d;
		end
	end
	//
	//
	reg [7:0] frmt_dout /* synthesis noprune*/;
	always@(posedge clk_20) begin 
		frmt_dout   <= epcs_formatted;
		c10_addr_20 <= c10_addr_20_d;
		c10_data_20 <= c10_data_20_d;
	end
	//
	//
	//assign addra_count_d   = (data_valid_reg == 1'b1)? addra_count + 8'b00000001 : addra_count;
	//
	// read enable is valid when address counter <= the set number of bytes (nominally 128)
	assign start_rd_con    = (((epcs_inst_busy_reg==1'b0) & (read_en==1'b0)) | ((epcs_inst_busy_reg==1'b0) & (read_en==1'b1)) | ((epcs_inst_busy_reg==1'b1) & (read_en==1'b1)))? 1'b1: 1'b0;
	assign read_en_d       =  ((start_rd_con==1'b1) & (addra_count <= c10_data_20[7:0])) ? 1'b1 : 1'b0;
	assign read_en_pulse_d =  ((start_rd_con==1'b1) & (addra_count <= c10_data_20[7:0]) & (read_en==1'b0)) ? 1'b1 : 1'b0;
	//
	// timing: data_valid comes in, epcs reg is set, next clock the data is written, then address is incremented
	//assign epcs_formatted_d = (data_valid==1'b1)? epcs_formatted : epcs_formatted_reg;
	assign dpram_wena       = ((read_en==1'b1) & (last_dv==1'b1)) ? 1'b1 : 1'b0;
	assign addra_count_d    = ((last_dv2 == 1'b1) & (addra_count <= c10_data_20[7:0]))? addra_count + 8'h01 : addra_count;
	assign dpram_addra      = addra_count;
	//
	//
	// Reader DPRAM  epcs_formatted 
	dpram_lbnl #(.dw(8), .aw(8))  	read_buffer(.clka(clk_20), .clkb(lb_clk), .addra(addra_count), .dina(frmt_dout), .wena(dpram_wena),
	 .addrb(c10_addr[7:0]), .doutb(dpram_outb));
	//Assign output byte
	assign c10_datar[7:0] = dpram_outb;
	//
	//
	//
	//
	//
	//
	//
	//
	//
	// =============================================================
	// Write DPRAM helper
	// =============================================================
	reg  [7:0] dpram_write_counter;
	wire [7:0] dpram_write_counter_d;
	reg  [1:0] dpram_sm;
	reg  [1:0] dpram_sm_d;
	wire [1:0] last_reg_flag;
	//	
	always@(posedge clk_20) begin 
		if (epcs_write == 1'b0) begin
			//reset state
			dpram_write_counter <= 0;
			dpram_sm <= 2'b00;
		end else begin
			dpram_sm <= dpram_sm_d;
			dpram_write_counter <= dpram_write_counter_d;
		end
	end
	//
	//
	// combinational logic
	always @(*)
	begin
		case(dpram_sm)
			2'b00		:	dpram_sm_d = 2'b01; //allow counter data to be stable (while shift is still low)
			2'b01		:	dpram_sm_d = 2'b10; //pulse shift hi
			2'b10		:	dpram_sm_d = last_reg_flag; //check to see if we just wrote the last dpram register to EPCQ
			default	:	dpram_sm_d = 2'b11; // stay here until busy clear is issued (the epcq write process must occur), done state, will initiate a epcs_write_pulse_gen
		endcase
	end
	//
	assign last_reg_flag         = ((dpram_write_counter < 127) & (dpram_sm == 2'b10)) ? 2'b00 : 2'b11;
	assign dpram_write_counter_d = ((dpram_write_counter < 127) & (dpram_sm == 2'b10)) ? dpram_write_counter + 8'b00000001 : dpram_write_counter;
	assign shift_bytes           = (dpram_sm == 2'b01) ? 1'b1 : 1'b0;//shift bytes into EPCQ (also trigger generic WEN of EPCQ)
	assign trigger_dpram_write   = (dpram_sm == 2'b11) ? 1'b1 : 1'b0; //when in done state, trigger write pulse (for EPCQ)
	
	//Writer DPRAM
	//get memory input byte
	wire [7:0] epcs_byte, write_dpram_dout;
	dpram_lbnl #(.dw(8), .aw(8))  	write_buffer(.clka(lb_clk), .clkb(clk_20), .addra(c10_data[15:8]), .dina(c10_data[7:0]), .wena(dpram_writer_wen), .douta(dpraw_w_douta),
	 .addrb(dpram_write_counter), .doutb(write_dpram_dout));
	//
	assign epcs_byte = write_dpram_dout;
	//
	//EPCQ stores datat in 'byte reversed' format which is different then the contents in the RPD files (just flip the order of each byte)
	wire [7:0] epcs_byte_rev;
	wire illegal_write, illegal_erase;
	assign epcs_byte_rev = {epcs_byte[0], epcs_byte[1], epcs_byte[2], epcs_byte[3], epcs_byte[4], epcs_byte[5], epcs_byte[6], epcs_byte[7]}; 
	//
	//
	//
	// =============================================================
	// ASMII flash controller which controls the reads and writes to the flash memory (off chip)
	// =============================================================
	EPCQ EPCQ_inst (
		.clkin         (clk_20),        	          //   input,   width = 1,         clkin.clk
		.read          (read_en_pulse),	          //   input,   width = 1,          read.read
		.rden          (read_en),	                //   input,   width = 1,          rden.rden
		.addr          (c10_addr_20),              //   input,   width = 32,          addr.addr WAS c10_addr WAS c_addr 5/10/24
		.write         (epcs_write_pulse),         //   input,   width = 1,         write.write
		.datain        (epcs_byte_rev),            //   input,   width = 8,        datain.datain NOTE may need to conver to little endian
		.shift_bytes   (shift_bytes),              //   input,   width = 1,   shift_bytes.shift_bytes
		.sector_erase  (epcs_sector_erase_pulse),  //   input,   width = 1,  sector_erase.sector_erase, set hi to erase
		.wren          (epcs_wen_generic_pulse),   //   input,   width = 1,          wren.wren
		.en4b_addr     (epcs_ext_addr_pulse),      //   input,   width = 1,     en4b_addr.en4b_addr
		.reset         (1'b0),       			       //   input,  width = 1,         reset.reset
		.sce           (3'b000),          	       //   input,   width = 3,           sce.sce
		.dataout       (epcs_dout_wire_raw),       //  output,   width = 8,       dataout.dataout
		.busy          (epcs_inst_busy),           //  output,   width = 1,          busy.busy
		.data_valid    (data_valid),    	          //  output,   width = 1,    data_valid.data_valid
		.illegal_write (illegal_write), 		       //  output,   width = 1, illegal_write.illegal_write
		.illegal_erase (illegal_erase)  		       //  output,   width = 1, illegal_erase.illegal_erase
	);
	
	wire [31:0] c10_status_buffer;
	assign c10_status_buffer[31:24] = 8'h00;// note blanking these here, but really this will be dpraw_w_douta @ lb_clk domain 
	assign c10_status_buffer[23:16] = c10_data_20[7:0];//c10_cntlr_20[7:0];
	//assign c10_status_buffer[23:8]  = 17'b0000000000000000;
	assign c10_status_buffer[15:8]  = c10_addr_20[15:8];
	assign c10_status_buffer[7]     = dpram_w_en;
	assign c10_status_buffer[6]     = read_en;
	assign c10_status_buffer[5]     = busy_FE;
	assign c10_status_buffer[4]     = busy_RE;
	assign c10_status_buffer[3]     = illegal_erase;
	assign c10_status_buffer[2]     = illegal_write;
	assign c10_status_buffer[1]     = last_dv;
	assign c10_status_buffer[0]     = epcs_inst_busy_reg;
	
	//data coming out of epcq/epcs is byte reveresed, This 'formats' it to the correct bit order
	assign epcs_formatted = (data_valid==1'b1)? {epcs_dout_wire_raw[0], epcs_dout_wire_raw[1], epcs_dout_wire_raw[2], epcs_dout_wire_raw[3], epcs_dout_wire_raw[4], epcs_dout_wire_raw[5], epcs_dout_wire_raw[6], epcs_dout_wire_raw[7]} : frmt_dout;
	//										  
	assign c10_status_d_20 = c10_status_buffer;
	//
	//
	//
	//
	// =============================================================
	// Specific to remote reconfiguration:
	// =============================================================
	//
	//
	//
	always@(posedge clk_20) begin 
		ru_param_20   <= ru_p_c_d[5:3];
		ru_ctrl_20    <= ru_p_c_d[2:0];
		ru_data_in_20 <= ru_data_in_d_20;
	end
	//
	//
	//
	// used to reconfigure the c10gx from flash after a new load
	reg  [7:0] reset_timer_cnt = 8'h00 /* synthesis noprune */;
	wire reset_timer;
	//
	always@(posedge clk_20) begin // clocked with slow clock
		 reset_timer_cnt = reset_timer_cnt + 8'h01;
	end
	assign reset_timer = reset_timer_cnt[7]; // 6/3/24, changed to increase the pulse length to help c10_rd catch the reset
	//
	//
	reg ruCONFIGq;
	wire ruCONFIGd;
	reg  [2:0]  ru_ctrl_q2, ru_ctrl_q3; // double buffer from input, does not get muxed at any point
	wire [2:0]  ru_ctrl_d3;
	reg  [2:0]  ru_sm, ru_instr_q;
	wire [2:0]  ru_instr_d, ru_param_d, ru_ctrl_d;
	reg  [31:0] rst_cnt, ru_data_in_q, ru_data_out_q;
	wire [31:0] ru_data_in_d, ru_data_out_d;
	reg  [2:0]  ru_param_q, ru_ctrl_last, ru_ctrl_q;
	wire [31:0] ru_dout;
	reg  [2:0] ruBusyStr, ruBusyStr2;
	reg ruREq, ruWEq, ruRSTq;
	reg ruBsyA, ruBsyB;
	wire ruREd, ruWEd, ruBsy, ruRSTd;
	//
	// sm regs
	reg  [3:0]  autoRU, autoRUnext;
	wire [3:0]  autoRU_d;
	reg autoGO;
	reg  [31:0] autoCNT;
	wire [31:0] autoCNT_d;
	reg  [2:0]  autoINTR, autoPARAM, autoCTRL;
	wire [2:0]  autoINTR_d;
	reg  [31:0] autoDIN;
	//
	// remote update IP, used to reconfigure the fpga with the new configuration data stroed on the flash
	remote_download c10_rd (
		.clock       (clk_20), 	         //   input,   width = 1,       clock.clk
		.reset       (ruRSTq),           //   input,   width = 1,       reset.reset : active hi, recommended 1 reset before use
		.read_param  (ruREq),  				//   input,   width = 1,       read_param.read_param
		.param       (ru_param_q),      	//   input,   width = 3,       param.param
		.reconfig    (ruCONFIGq),        //   input,   width = 1,       reconfig.reconfig : set to hi to reconfigure (set hi when you want to reset with the newly loaded configuration file)
		.reset_timer (reset_timer), 		//   input,   width = 1,       reset_timer.reset_timer : reset watchdog timer
		.busy        (ruBsy),        	   //   output,   width = 1,      busy.busy
		.data_out    (ru_dout),    		//   output,  width = 32,      data_out.data_out
		.write_param (ruWEq),				//   input,   width = 1,       write_param.write_param
		.data_in     (ru_data_in_q),     //   input,  width = 32,       data_in.data_in
		.ctl_nupdt   (1'b0)    				//   input,   width = 1,       ctl_nupdt.ctl_nupdt : regiser select, HI is Control register, LO is Update register
	);
	//
	always@(posedge clk_20) begin 
			//
			ru_instr_q    <= ru_instr_d;
			ru_data_in_q  <= ru_data_in_d;
			ru_data_out_q <= ru_data_out_d;
			ru_param_q    <= ru_param_d;
			ruREq         <= ruREd;
			ruWEq         <= ruWEd;
			ruRSTq        <= ruRSTd;
			ruCONFIGq     <= ruCONFIGd;
			ru_ctrl_q     <= ru_ctrl_d;
			ru_ctrl_last  <= ru_ctrl_q;
			ruBsyA        <= ruBsy;
			ruBusyStr     <= {ruBusyStr[1:0], ruBsyA};
	end
	//
	// Simple SM to take over bus if no interupt is present within so many seconds
	//
	//clocked registers
	always@(posedge clk_20) begin 	
		autoRU     <= autoRUnext;
		autoCNT    <= autoCNT_d;
		autoINTR   <= autoINTR_d;
		ru_ctrl_q2 <= ru_ctrl_20;
		ru_ctrl_q3 <= ru_ctrl_q2;
		ruBsyB     <= ruBsy;
		ruBusyStr2 <= {ruBusyStr2[1:0], ruBsyB};
	end	
	//
	// Next state combinational logic
	assign ru_ctrl_d3 = ru_ctrl_q3;
	//
	wire [2:0] delay_start000;
	wire [2:0] bsy_check100;
	wire [2:0] done_check101;
	//
	always @(*)
	begin
		case(autoRU)
			3'b000		:	autoRUnext	 =	delay_start000; // INIT
			3'b001		:	autoRUnext	 =	3'b010;         // LOAD
			3'b010		:	autoRUnext	 =	3'b011;         // STOBE HI
			3'b011		:	autoRUnext	 =	3'b100;         // STROBE LOW
			3'b100		:	autoRUnext	 =	bsy_check100;   // BUSY LOW CHECK
			3'b101		:	autoRUnext	 =	done_check101;  // DONE CHECK, Instruction 011 is the last written register, after this we may reconfigur
			3'b110		:	autoRUnext	 =	3'b110;         // RECONFIG
			default		:	autoRUnext	 =	3'b111;         // USER CONTROL
		endcase
	end
	//
	assign delay_start000 = (ru_ctrl_d3 == 3'b101)?  (3'b111) : ((autoCNT >= 31'h07735940)? 3'b001 : 3'b000);
	assign bsy_check100   = (ruBusyStr2[2:1] == 2'b00)? 3'b101 : 3'b100;
	assign done_check101  = (autoINTR >= 3'b011)? 3'b110 : 3'b001;
	//
	assign autoCNT_d  = (autoRU==3'b000)? autoCNT  + 1 : autoCNT;
	assign autoINTR_d = (autoRU==3'b101)? autoINTR + 3'b001 : autoINTR;
	//
	always @(*)
	begin
		case(autoINTR)
			3'b000		:	autoPARAM	 =	3'b101;			
			3'b001		:	autoPARAM	 =	3'b100;
			3'b010		:	autoPARAM	 =	3'b010;
			default		:	autoPARAM	 =	3'b011;
		endcase
	end
	//
	always @(*)
	begin
		case(autoINTR)
			3'b000		:	autoDIN	   =	32'h00000001;			
			3'b001		:	autoDIN	   =	32'h02000000;
			3'b010		:	autoDIN	   =	32'h00001FFF;
			default		:	autoDIN	   =	32'h00000001;
		endcase
	end
	//
	always @(*)
	begin
		case(autoRU)
			3'b000		:	autoCTRL		=	3'b100; // reset			
			3'b001		:	autoCTRL		=	3'b000;
			3'b010		:	autoCTRL		=	3'b010; // WE
			3'b011		:	autoCTRL		=	3'b000;
			3'b100		:	autoCTRL		=	3'b000;
			3'b101		:	autoCTRL		=	3'b000;
			3'b110		:	autoCTRL		=	3'b111; // reconfigure
			3'b111		:	autoCTRL		=	3'b000; // user control state
			default		:	autoCTRL		=	3'b000;
		endcase
	end
	//
	//assign ru_data_out_d = {ru_dout[30:0], ruBsy};    // read status register (output data)  from ru
	assign ru_data_out_d = (ruBusyStr[2:1] == 2'b10) ? ru_dout : ru_data_out_q; // 6/10/24, register on falling edge of busy, else keep old value
	assign ru_ctrl_d     = (autoRU !== 3'b111)? autoCTRL       : ru_ctrl_20;    // input control to ru
	assign ru_data_in_d  = (autoRU !== 3'b111)? autoDIN        : ru_data_in_20; // input data to ru
	assign ru_param_d    = (autoRU !== 3'b111)? autoPARAM      : ru_param_20;   // address input to ru  
	//
	assign ruRSTd         = ( ru_ctrl_q == 3'b100) ? 1'b1 : 1'b0; // active hi reset
	assign ruREd          = ((ru_ctrl_q == 3'b001) & (ru_ctrl_last == 3'b000)) ? 1'b1 : 1'b0; // read enable,  Rising Edge
	assign ruWEd          = ((ru_ctrl_q == 3'b010) & (ru_ctrl_last == 3'b000)) ? 1'b1 : 1'b0; // write enable, Rising Edge
	assign ruCONFIGd      = ( ru_ctrl_q == 3'b111) ? 1'b1 : 1'b0; // device will reconfigure when this goes HI
   assign ru_data_out_20 = ru_data_out_q;// pass signal in clk_out domain through CDC to lb_clk domain
	//
 endmodule
  
  
  
  
  
  
  
  
  
  
  
  