// 4/23/24 changed name dpram to dpram_lbnl to avoid conflict with FCC dpram ip core
module cyclone (
	// Global signals
	input lb_clk,
	// Control registers
	input [31:0] c10_addr, // external
	input [31:0] c_addr_slow, // external
	input [31:0] c10_data, // external
	input [31:0] c10_cntlr, // external
	output [31:0] c10_status,
	output [31:0] c10_datar, 
	input we_cyclone_inst_c10_data
  );
  
  	// =============================================================
	// Clock Generationg
	// =============================================================
	// used to reconfigure the c10gx from flash after a new load
	reg [2:0] clock_cnt = 3'b000 /* synthesis noprune */;
	wire clock_rd;

	always@(posedge lb_clk) begin // clocked with slow clock
		 clock_cnt = clock_cnt + 3'b001; //maybe change to + 1'b1 instead of +1 and see if this fixes truncation error?
	end
	//125 MHz divide by <something>. ASMII IP recommends less than 20 MHz, MICROn chip allows up to 90MHz. 
	assign clock_rd = clock_cnt[2]; //use this clock to drive EPCQ/EPCS

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
	reg [31:0] c_addr_slow_b, c_addr_clock_rd;
	// buffer for control register
	always@(posedge clock_rd) begin
		c10_cntlr_buffer  <= c10_cntlr;
		c10_cntlr_buffer2 <= c10_cntlr_buffer;
		//
		c_addr_slow_b   <= c_addr_slow;
		c_addr_clock_rd <= c_addr_slow; // used this c10_addr register clocked by clock_rd
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
	
	always@(posedge clock_rd) begin
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
	
	reg busy_RE;
	always@(posedge clock_rd) begin
		if (busy_clear == 1'b1 ) begin
			busy_RE <= 1'b0;
		end else if ((busy_pulse_RE == 1'b1) & (busy_RE == 1'b0)) begin
			busy_RE <= 1'b1;
		end else if (busy_RE == 1'b1) begin
			busy_RE <= 1'b1;
		end
	end
	//and now the same but for falling edge
	reg busy_FE;
	always@(posedge clock_rd) begin
		if (busy_clear == 1'b1 ) begin
			busy_FE <= 1'b0;
		end else if ((busy_pulse_FE == 1'b1) & (busy_FE == 1'b0)) begin
			busy_FE <= 1'b1;
		end else if (busy_FE == 1'b1)  begin
			busy_FE <= 1'b1;
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
	always@(posedge clock_rd) begin
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
	dpram_lbnl #(.dw(8), .aw(8))  	read_buffer(.clka(clock_rd), .clkb(lb_clk), .addra(dpram_addra), .dina(epcs_formatted), .wena(dpram_wena),
	 .addrb(c10_addr[7:0]), .doutb(dpram_outb));
	//Assign output byte
	assign c10_datar[7:0] = dpram_outb;
	// =============================================================
	// Write DPRAM helper
	// =============================================================
	reg [7:0] dpram_write_counter;
	//
	always@(posedge clock_rd) begin 
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
	dpram_lbnl #(.dw(8), .aw(8))  	write_buffer(.clka(lb_clk), .clkb(clock_rd), .addra(c10_data[15:8]), .dina(c10_data[7:0]), .wena(dpram_writer_wen), .douta(dpraw_w_douta),
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
		.clkin         (clock_rd),        	       //   input,   width = 1,         clkin.clk
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
	always@(posedge clock_rd) begin
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
	// Specific to remotre reconfiguration:
	// =============================================================
	// used to reconfigure the c10gx from flash after a new load
	reg  [7:0] reset_timer_cnt = 8'b00000000 /* synthesis noprune */;
	wire reset_timer;

	always@(posedge clock_rd) begin // clocked with slow clock
		 reset_timer_cnt = reset_timer_cnt + 8'b00000001;
	end
	
	assign reset_timer = (reset_timer_cnt==255) ? 1'b1 : 1'b0;
	
	// remote update IP, used to reconfigure the fpga with the new configuration data stroed on  flash.
	
	remote_download c10_rd (
		.clock       (clock_rd), 			//   input,   width = 1,       clock.clk
		.reset       (c10_cntlr[6]),     //   input,   width = 1,       reset.reset : active hi, recommended 1 reset before use
		.read_param  (1'b0),  				//   input,   width = 1,       read_param.read_param
		.param       (3'b0),      			//   input,   width = 3,       param.param
		.reconfig    (epcs_reconfig),    //   input,   width = 1,       reconfig.reconfig : set to hi to reconfigure (set hi when you want to reset with the newly loaded configuration file)
		.reset_timer (reset_timer), 		//   input,   width = 1,       reset_timer.reset_timer : reset watchdog timer
		//.busy        (),        			//   output,   width = 1,      busy.busy
		//.data_out    (),    				//   output,  width = 32,      data_out.data_out
		.write_param (1'b0),					//   input,   width = 1,       write_param.write_param
		.data_in     (c10_data),     			//   input,  width = 32,       data_in.data_in
		.ctl_nupdt   (1'b1)    				//   input,   width = 1,       ctl_nupdt.ctl_nupdt : regiser select, HI is Control register, LO is Update register
	);



  endmodule