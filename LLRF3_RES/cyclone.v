//6-5-24 updated Remote Update (ru) section to facilitate golden image interface
module cyclone (
	// Global signals
	input lb_clk,
	input reset_n,
	// Control registers
	input [31:0] c10_addr, // external
	input [31:0] c10_data, // external
	input [31:0] c10_cntlr, // external
	output [31:0] c10_status,
	output [31:0] c10_datar, 
	input  [2:0]  ru_param,
	input  [31:0] ru_data_in,
	input  [2:0] ru_ctrl,
	output [31:0] ru_data_out,
	input we_cyclone_inst_c10_data
  );
  
  	// =============================================================
	// Clock Generationg
	// =============================================================
	// used to reconfigure the c10gx from flash after a new load
	reg [2:0] clock_cnt1, clock_cnt2, clock_cnt3, clock_cnt4, clock_cnt5, clock_cnt6, clock_cnt7, clock_cnt8, clock_cnt9, clock_cntRU; /* synthesis noprune */;
	reg [2:0] clock_cntq1, clock_cntq2, clock_cntq3, clock_cntq4, clock_cntq5, clock_cntq6, clock_cntq7, clock_cntq8, clock_cntq9, clock_cntqRU; /* synthesis noprune */;
	wire clock_rd1, clock_rd2, clock_rd3, clock_rd4, clock_rd5, clock_rd6, clock_rd7, clock_rd8, clock_rd9, clock_rdRU;

	always@(posedge lb_clk) begin // clocked with slow clock
		 clock_cntq1 <= clock_cntq1 + 3'b001; 
		 clock_cntq2 <= clock_cntq2 + 3'b001;
		 clock_cntq3 <= clock_cntq3 + 3'b001;
		 clock_cntq4 <= clock_cntq4 + 3'b001;
		 clock_cntq5 <= clock_cntq5 + 3'b001;
		 clock_cntq6 <= clock_cntq6 + 3'b001;
		 clock_cntq7 <= clock_cntq7 + 3'b001;
		 clock_cntq8 <= clock_cntq8 + 3'b001;
		 clock_cntq9 <= clock_cntq9 + 3'b001;
		 clock_cntqRU <= clock_cntqRU + 3'b001;
		 
		 clock_cnt1 <= clock_cntq1;
		 clock_cnt2 <= clock_cntq2;
		 clock_cnt3 <= clock_cntq3;
		 clock_cnt4 <= clock_cntq4;
		 clock_cnt5 <= clock_cntq5;
		 clock_cnt6 <= clock_cntq6;
		 clock_cnt7 <= clock_cntq7;
		 clock_cnt8 <= clock_cntq8;
		 clock_cnt9 <= clock_cntq9;
		 clock_cntRU <= clock_cntqRU;
	end
	//125 MHz divide by <something>. ASMII IP recommends less than 20 MHz, MICROn chip allows up to 90MHz. 
	assign clock_rd1 = clock_cnt1[2]; //use this clock to drive EPCQ/EPCS
	assign clock_rd2 = clock_cnt2[2]; 
	assign clock_rd3 = clock_cnt3[2]; 
	assign clock_rd4 = clock_cnt4[2];
	assign clock_rd5 = clock_cnt5[2];
	assign clock_rd6 = clock_cnt6[2];
	assign clock_rd7 = clock_cnt7[2];
	assign clock_rd8 = clock_cnt8[2];
	assign clock_rd9 = clock_cnt9[2];
	assign clock_rdRU = clock_cntRU[2];;
	

	
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
	
	reg  [7:0] epcs_dout_wire; // data coming from EPCS/EPCQ
	wire [7:0] epcs_dout_wire_raw, epcs_formatted;
	wire epcs_inst_busy; // busy signal from EPCS/EPCQ
	//reduce fanout for this busy signal
	reg  epcs_inst_busy_reg1 /* synthesis noprune */; 
	reg  epcs_inst_busy_reg2 /* synthesis noprune */;
	wire data_valid; // will be a pulse for one clock_rd tick when epcq dout register is valid
	wire busy_pulse_RE;
	wire busy_pulse_FE;
	wire busy_clear;
	wire shift_bytes;
	reg [3:0] dpram_sm;
	
	reg [31:0] c10_cntlr_buffer, c10_cntlr_buffer2;
	reg [31:0] c_addr_clock_rd;
	// buffer for control register
	always@(posedge clock_rd1) begin
		c10_cntlr_buffer  <= c10_cntlr;
		c10_cntlr_buffer2 <= c10_cntlr_buffer;
		//
		//c_addr_slow_b   <= c_addr_slow;
		c_addr_clock_rd <= c10_addr; // used this c10_addr register clocked by clock_rd
		// busy signal fanout reduction
		epcs_inst_busy_reg1 <= epcs_inst_busy;
		epcs_inst_busy_reg2 <= epcs_inst_busy;
	end
	
	// decode commands from c10_cntlr register
	assign epcs_write    = ( c10_cntlr_buffer2[7:0] == 8'b00001010) ? 1'b1 : 1'b0; // x0A
	assign epcs_rd       = ( c10_cntlr_buffer2[7:0] == 8'b00001001) ? 1'b1 : 1'b0; // x09
	assign epcs_erase    = ( c10_cntlr_buffer2[7:0] == 8'b00001100) ? 1'b1 : 1'b0; // x0C	
	assign epcs_ext_addr = ( c10_cntlr_buffer2[7:0] == 8'b00001011) ? 1'b1 : 1'b0; // x0B
	assign dpram_w_en    = ( c10_cntlr_buffer2[7:0] == 8'b00001101) ? 1'b1 : 1'b0; // x0D
	assign busy_clear    = ( c10_cntlr_buffer2[7:0] == 8'b00001110) ? 1'b1 : 1'b0; // x0E
	assign epcs_reconfig = ( c10_cntlr_buffer2[7:0] == 8'b11110000) ? 1'b1 : 1'b0; // xF0
	
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
	
	wire trigger_dpram_write;
	
	always@(posedge clock_rd2) begin
		epcs_rd_pulse_gen           <= {epcs_rd_pulse_gen[0], epcs_rd};
		epcs_write_pulse_gen        <= {epcs_write_pulse_gen[0], trigger_dpram_write}; // was epcs_write
		epcs_sector_erase_pulse_gen <= {epcs_sector_erase_pulse_gen[0], epcs_erase};
		epcs_ext_addr_pulse_gen     <= {epcs_ext_addr_pulse_gen[0], epcs_ext_addr};
		busy_pulse_gen              <= {busy_pulse_gen[0], epcs_inst_busy_reg1};
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
	
	assign epcs_wen_generic_pulse = ((epcs_write_pulse==1'b1) | (epcs_sector_erase_pulse==1'b1) | (epcs_ext_addr_pulse==1'b1) | (shift_bytes==1'b1)) ? 1'b1 : 1'b0;
	
	//busy signal is easy to  miss between (EPICS) controller reads. This latches the rising edge and falling edge bits
	//must be cleared between uses
//	always@(posedge lb_clk) begin
//		busy_pulse_gen  <= {busy_pulse_gen[0], epcs_inst_busy};
//	end
	
	reg    busy_RE;
	reg    busy_FE;
	wire   busy_RE_d;
	wire   busy_FE_d;
	// if eddge detected set it, otherwise keep the previous value
	assign busy_RE_d = (busy_pulse_RE==1'b1) ? 1'b1 : busy_RE;
	assign busy_FE_d = ((busy_pulse_FE==1'b1) | ( (busy_RE == 1'b1) & (busy_pulse_gen == 2'b00))) ? 1'b1 : busy_FE;
	
	always@(posedge clock_rd2) begin
		if (busy_clear == 1'b1 ) begin
			busy_RE <= 1'b0;
			busy_FE <= 1'b0;
		end else begin
			busy_RE <= busy_RE_d;
			busy_FE <= busy_FE_d;
		end
	end
	
	// catch local bus write strobe pulse and stretch it
	//we_cyclone_inst_c10_data
	reg lb_strobe_last;
	reg [3:0] lb_strobe_stretch;
	wire dpram_writer_wen;
	always@(posedge lb_clk) begin
		lb_strobe_last    <= we_cyclone_inst_c10_data;
		lb_strobe_stretch <= {lb_strobe_stretch[2:0],((we_cyclone_inst_c10_data == 1'b1) & (lb_strobe_last == 1'b0))};
	end
	//
	assign dpram_writer_wen = ((dpram_w_en==1'b1) & ((lb_strobe_stretch[3] == 1'b1) |(lb_strobe_stretch[2] == 1'b1))) ? 1'b1 : 1'b0;
	//assign dpram_writer_wen = ((dpram_w_en==1'b1) & ((lb_strobe_stretch[3] == 1'b1) | (lb_strobe_stretch[2] == 1'b1) | (lb_strobe_stretch[1] == 1'b1) | lb_strobe_stretch[0] == 1'b1)) ? 1'b1 : 1'b0;
	
	
	//only sample epcs output data once data_valid is HI. This data_valid wil strobe HI for one clock_rd tick
	//once data is valid (busy might still be HI).
//	always@(posedge clock_rd) begin
//		if (data_valid == 1'b1) begin
//		// we must reverse the bit order if we want to match against the hexout file
//			epcs_dout_wire <= epcs_formatted;
//		end
//	end
	//c10_datar can be used to access eighter dpram contents or EPCQ contents
	//assign c10_datar = epcs_dout_wire;
	// =============================================================
	// Read DPRAM helper
	// =============================================================
	// DPRAM is used to readoff the contents of a block of read registers. This reduces the number of needed waits for busy signal to fall.
	// Target is one hexout length which is 128 bytes or less. dpram set for 256 bytes. Data
	wire [7:0] dpram_addra, dpram_outb;
	reg  [7:0] addra_count /* synthesis preserve */; //JAL 5/9/24
	reg  last_dv;
	wire dpram_wena;
	wire read_en;
	always@(posedge clock_rd4) begin
		if (epcs_rd == 1'b1) begin
			if ((data_valid == 1'b0) & (last_dv == 1'b1)) begin // watch for falling edge of data_valid
				if (addra_count <= c10_data[7:0]) begin
					addra_count <= addra_count + 8'b00000001;
				end
			end
			last_dv <= data_valid;
		end else begin
			addra_count <= 0;
			last_dv <= 1'b0;
		end
	end
	//
	assign read_en = ((addra_count <= c10_data[7:0]) & (epcs_rd == 1'b1)) ? 1'b1 : 1'b0;
	assign dpram_addra = addra_count;
	assign dpram_wena = ((read_en==1'b1) & (data_valid==1'b1)) ? 1'b1 : 1'b0;
	// Reader DPRAM
	dpram #(.dw(8), .aw(8))  	read_buffer(.clka(clock_rd5), .clkb(lb_clk), .addra(dpram_addra), .dina(epcs_formatted), .wena(dpram_wena),
	 .addrb(c10_addr[7:0]), .doutb(dpram_outb));
	//Assign output byte
	assign c10_datar[7:0] = dpram_outb;
	// =============================================================
	// Write DPRAM helper
	// =============================================================
	reg [7:0] dpram_write_counter;
	//
	always@(posedge clock_rd6) begin 
		if (epcs_write == 1'b1) begin
			if (dpram_sm == 2'b00) begin
				//allow counter data to be stable (while shift is still low)
				dpram_sm <= 2'b01;
			end else if (dpram_sm == 2'b01) begin
				//pulse shift hi
				dpram_sm <= 2'b10;
			end else if (dpram_sm == 2'b10) begin
				//check to see if we just wrote the last dpram register to EPCQ
				if (dpram_write_counter < 127) begin
					dpram_write_counter <= dpram_write_counter + 8'b00000001;
					dpram_sm <= 2'b00;
				end else begin
					dpram_sm <= 2'b11;
				end
			end else begin
				//done state, will initiate a epcs_write_pulse_gen
				dpram_sm <= 2'b11;
			end
		end else begin
			//reset state
			dpram_write_counter <= 0;
			dpram_sm <= 2'b00;
		end
	end
	assign shift_bytes = (dpram_sm == 2'b01) ? 1'b1 : 1'b0;//shift bytes into EPCQ (also trigger generic WEN of EPCQ)
	assign trigger_dpram_write = (dpram_sm == 2'b11) ? 1'b1 : 1'b0; //when in done state, trigger write pulse (for EPCQ)
	//Writer DPRAM
	//get memory input byte
	wire [7:0] epcs_byte, write_dpram_dout, dpraw_w_douta;
	dpram #(.dw(8), .aw(8))  	write_buffer(.clka(lb_clk), .clkb(clock_rd7), .addra(c10_data[15:8]), .dina(c10_data[7:0]), .wena(dpram_writer_wen), .douta(dpraw_w_douta),
	 .addrb(dpram_write_counter), .doutb(write_dpram_dout));
	//
	assign epcs_byte = write_dpram_dout;
	//
	//EPCQ stores datat in 'byte reversed' format which is different then the contents in the RPD files (just flip the order of each byte)
	wire [7:0] epcs_byte_rev, illegal_write, illegal_erase;
	assign epcs_byte_rev = {epcs_byte[0], epcs_byte[1], epcs_byte[2], epcs_byte[3], epcs_byte[4], epcs_byte[5], epcs_byte[6], epcs_byte[7]}; 
	// =============================================================
	// ASMII flash controller which controls the reads and writes to the flash memory (off chip)
	// =============================================================
	EPCQ EPCQ_inst (
		.clkin         (clock_rd1),        	       //   input,   width = 1,         clkin.clk
		.read          (epcs_rd_pulse),	          //   input,   width = 1,          read.read
		.rden          (read_en),	                //   input,   width = 1,          rden.rden
		.addr          (c_addr_clock_rd),          //   input,   width = 32,          addr.addr WAS c10_addr WAS c_addr 5/10/24
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
	
	// do we need this double buffer???
	reg [31:0] c10_status_buffer, c10_status_buffer2;
	always@(posedge clock_rd2) begin
		// initial buffer
		c10_status_buffer[31:24] <= dpraw_w_douta;
		c10_status_buffer[23:8]  <= 17'b0000000000000000;
		c10_status_buffer[7]     <= dpram_w_en;
		c10_status_buffer[6]     <= read_en;
		c10_status_buffer[5]     <= busy_FE;
		c10_status_buffer[4]     <= busy_RE;
		c10_status_buffer[3]     <= illegal_erase;
		c10_status_buffer[2]     <= illegal_write;
		c10_status_buffer[1]     <= data_valid;
		c10_status_buffer[0]     <= epcs_inst_busy_reg2;
		// second buffer
		c10_status_buffer2       <= c10_status_buffer;
	end
	
	//data coming out of epcq/epcs is byte reveresed, This 'formats' it to the correct bit order
	assign epcs_formatted = {epcs_dout_wire_raw[0], epcs_dout_wire_raw[1], epcs_dout_wire_raw[2], epcs_dout_wire_raw[3], epcs_dout_wire_raw[4], epcs_dout_wire_raw[5], epcs_dout_wire_raw[6], epcs_dout_wire_raw[7]};
	//
										  
	assign c10_status = c10_status_buffer;
//	assign c10_status[31:24] = dpraw_w_douta;
//	//
//	assign c10_status[23:7] = 17'b00000000000000000;
//	assign c10_status[6] = read_en;
//	assign c10_status[5] = busy_FE;
//	assign c10_status[4] = busy_RE;
//	//
//	//
//	assign c10_status[1] = data_valid;
//	assign c10_status[0] = epcs_inst_busy;


	// =============================================================
	// Specific to remote reconfiguration:
	// =============================================================
	// used to reconfigure the c10gx from flash after a new load
	reg  [7:0] reset_timer_cnt = 8'b00000000 /* synthesis noprune */;
	wire reset_timer;

	always@(posedge clock_rd8) begin // clocked with slow clock
		 reset_timer_cnt = reset_timer_cnt + 8'b00000001;
	end
	
	//assign reset_timer = (reset_timer_cnt==255) ? 1'b1 : 1'b0;
	assign reset_timer = reset_timer_cnt[7]; // 6/3/24, changed to increase the pulse length to help c10_rd catch the reset
	//
	reg ruCONFIGq;
	wire ruCONFIGd;
	
	reg [2:0] ru_ctrl_q2, ru_ctrl_q3; // double buffer from input, does not get muxed at any point
	wire [2:0] ru_ctrl_d3;
	
	reg  [2:0]  ru_sm, ru_instr_q;
	wire [2:0]  ru_instr_d, ru_param_d, ru_ctrl_d;
	reg  [31:0] rst_cnt, ru_data_in_q, ru_data_out_q;
	wire [31:0] ru_data_in_d, ru_data_out_d;
	reg  [2:0]  ru_param_q, ru_ctrl_last, ru_ctrl_q;
	wire [31:0] ru_dout;
	reg [2:0] ruBusyStr, ruBusyStr2;
	reg ruREq, ruWEq, ruRSTq;
	reg ruBsyA, ruBsyB;
	wire ruREd, ruWEd, ruBsy, ruRSTd;
	
	// sm regs
	reg  [3:0] autoRU, autoRUnext;
	wire [3:0] autoRU_d;
	reg autoGO;
	reg [31:0] autoCNT;
	wire[31:0] autoCNT_d;
	reg [2:0]  autoINTR, autoPARAM, autoCTRL;
	wire [2:0] autoINTR_d;
	reg [31:0] autoDIN;
	
	// remote update IP, used to reconfigure the fpga with the new configuration data stroed on  flash
	remote_download c10_rd (
		.clock       (clock_rdRU), 	   //   input,   width = 1,       clock.clk
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
	
	always@(posedge clock_rd9) begin 
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
	

	// module IO notes
	//	input  [2:0]  ru_param
	//	input  [31:0] ru_data_in
	//	input  [2:0] ru_ctrl
	//	output [31:0] ru_data_out


	// simple SM to take over bus if no interupt is present within so many seconds
	//
	//clocked registers
	always@(posedge clock_rd9) begin 	
//		if (reset_n == 1'b0) begin
//			autoRU     <= 3'b000;
//			autoCNT    <= 0;
//			autoINTR   <= 3'b000;
//			ru_ctrl_q2 <= 3'b000;
//			ru_ctrl_q3 <= 3'b000;
//		end else begin
			autoRU     <= autoRUnext;
			autoCNT    <= autoCNT_d;
			autoINTR   <= autoINTR_d;
			ru_ctrl_q2 <= ru_ctrl;
			ru_ctrl_q3 <= ru_ctrl_q2;
			ruBsyB     <= ruBsy;
			ruBusyStr2 <= {ruBusyStr2[1:0], ruBsyB};
//		end
	end	
	
	// next state combinational logic
	assign ru_ctrl_d3 = ru_ctrl_q3;
// for now, no auto jump to applicaiton image
//	always@(*) begin 
//		//autoRUnext = autoRU;                         // default assigment if autoRUnext is not updated, keep curretn value
//		if (autoRU == 3'b000) begin                    // INIT
//			if (ru_ctrl_d3 == 3'b101) begin             // Send a 5 to abort auto jump to  applicaiton (this ru_ctrl is buffered from input)
//				autoRUnext = 3'b111;
//			end else if (autoCNT >= 31'h07735940) begin // After a few seconds with no abort, go to the next state
//				autoRUnext = 3'b001;
//			end else begin
//				autoRUnext = 3'b000;
//			end
//		end else if (autoRU == 3'b001) begin         // LOAD
//			autoRUnext = 3'b010;
//		end else if (autoRU == 3'b010) begin         // STOBE HI
//			autoRUnext = 3'b011;
//		end else if (autoRU == 3'b011) begin         // STROBE LOW
//			autoRUnext = 3'b100;
//		end else if (autoRU == 3'b100) begin         // BUSY LOW CHECK
//			if (ruBusyStr2[2:1] == 2'b00) begin
//				autoRUnext = 3'b101;
//			end else begin
//				autoRUnext = 3'b100;
//			end
//		end else if (autoRU == 3'b101) begin         // DONE CHECK
//			if (autoINTR >= 3'b011) begin             // instruction 011 is the last written register, after this we may reconfigure
//				autoRUnext = 3'b110;
//			end else begin
//				autoRUnext = 3'b001;
//			end
//		end else if (autoRU == 3'b110) begin         // RECONFIG
//			autoRUnext = 3'b110;
//		end else if (autoRU == 3'b111) begin         // USER CONTROL
//			autoRUnext = 3'b111;
//		end
//	end

	assign autoCNT_d  = (autoRU==3'b000)? autoCNT  + 1 : autoCNT;
	assign autoINTR_d = (autoRU==3'b101)? autoINTR + 1 : autoINTR;

	
always @(*)
begin
	case(autoINTR)
		3'b000		:	autoPARAM	 =	3'b101;			
		3'b001		:	autoPARAM	 =	3'b100;
		3'b010		:	autoPARAM	 =	3'b010;
		default		:	autoPARAM	 =	3'b011;
	endcase
end

always @(*)
begin
	case(autoINTR)
		3'b000		:	autoDIN	   =	32'h00000001;			
		3'b001		:	autoDIN	   =	32'h02000000;
		3'b010		:	autoDIN	   =	32'h00001FFF;
		default		:	autoDIN	   =	32'h00000001;
	endcase
end


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

//	wire [2:0] autoCTRLwire, autoPARAMwire;
//	wire[31:0] autoDINwire;
//	
//	assign autoCTRLwire  = autoCTRL;
//	assign autoPARAMwire = autoPARAM;	
//	assign autoDINwire   = autoDIN;

	//assign ru_data_out_d = {ru_dout[30:0], ruBsy};    // read status register (output data)  from ru
	assign ru_data_out_d = (ruBusyStr[2:1] == 2'b10) ? ru_dout : ru_data_out_q;// 6/10/24, register on falling edge of busy, else keep old value
	assign ru_ctrl_d     = (autoRU !== 3'b111)? autoCTRL  : ru_ctrl;    // input control to ru
	assign ru_data_in_d  = (autoRU !== 3'b111)? autoDIN   : ru_data_in; // input data to ru
	assign ru_param_d    = (autoRU !== 3'b111)? autoPARAM : ru_param;   // address input to ru  
	
	assign ruRSTd    = ( ru_ctrl_q == 3'b100) ? 1'b1 : 1'b0; // active hi reset
	assign ruREd     = ((ru_ctrl_q == 3'b001) & (ru_ctrl_last == 3'b000)) ? 1'b1 : 1'b0; // read enable,  Rising Edge
	assign ruWEd     = ((ru_ctrl_q == 3'b010) & (ru_ctrl_last == 3'b000)) ? 1'b1 : 1'b0; // write enable, Rising Edge
	assign ruCONFIGd = (( ru_ctrl_q == 3'b111) | (epcs_reconfig == 1'b1)) ? 1'b1 : 1'b0; // device will reconfigure when this goes HI, added feature to make back comptible with reset modul
	
	
//	reg ru_data_out_q2, ru_data_out_q3;
//	always @(posedge clock_rd9)
//	begin
//		ru_data_out_q2 <= ru_data_out_q; // from slow clock domain
//		ru_data_out_q3 <= ru_data_out_q2;
//	end
	
	
   assign ru_data_out = ru_data_out_q;

	
	
  endmodule
  
  
  
  
  
  
  
  
  
  
  
  