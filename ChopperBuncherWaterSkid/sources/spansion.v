
// JAL 6/27/22 started moving this over for spansion QSPI flash
// JAL 9/13/22 added ICAPE2 module with the goal of IPROG (software reconfiguration). NOT WORKING YET

module spansion (
	// Global signals
	input lb_clk,
	// Control registers
	input [31:0] c10_addr, // external
	input [31:0] c10_data, // external
	input [31:0] c10_cntlr, // external
	output [31:0] c10_status,
	output [31:0] c10_datar, 
	input we_cyclone_inst_c10_data,
	output qspi_cs ,
    inout [3:0] qspi_dq
  );

    // buffer user inputs to assist with timing(* KEEP = "TRUE" *)
     reg [31:0] c10_addr_buf   ;
     reg [31:0] c10_data_buf   ;
     reg [8:0] c10_cntlr_buf  ;
     reg [31:0] c10_cntlr_buf1 ;
     reg [31:0] c10_cntlr_buf2 ;
     reg [31:0] c10_datar_buf  ;
     reg [31:0] c10_status_buf ;
     always@(posedge lb_clk) begin
        c10_addr_buf   = c10_addr;
        c10_data_buf   = c10_data;
        c10_cntlr_buf = c10_cntlr[8:0];
        //c10_status_buf = c10_cntlr_buf; // for debug only
        //c10_datar_buf  = c10_data_buf; // for debug only
     end

	
	wire [31:0] epcs_addr_mux;
	wire flash_clk;
	// ====================================================================
	// QSPI specific state machine
	// ====================================================================
	// startup primitive is needed to access the SCK (pin L12 on FPGA)
    STARTUPE2 #(
      .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
      .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
   )
   STARTUPE2_inst (
      .CFGCLK(),       // 1-bit output: Configuration main clock output
      .CFGMCLK(),     // 1-bit output: Configuration internal oscillator clock output
      .EOS(),             // 1-bit output: Active high output signal indicating the End Of Startup.
      .PREQ(),           // 1-bit output: PROGRAM request to fabric output
      .CLK(1'b0),             // 1-bit input: User start-up clock input
      .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      .KEYCLEARB(1'b0), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      .PACK(1'b0),           // 1-bit input: PROGRAM acknowledge input
      .USRCCLKO(flash_clk),   // 1-bit input: User CCLK input    *** This is the SPI_SCK
      .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
      .USRDONEO(1'b1),   // 1-bit input: User DONE pin output control
      .USRDONETS(1'b0)  // 1-bit input: User DONE 3-state enable output
   );
	
	// target chip is a cypress/spansion/infineon S25FL128S
	 reg [15:0] qspi_state /* synthesis noprune */;
	 reg [15:0] qspi_state_next /* synthesis noprune */;
	 reg [3:0] mode /* synthesis noprune */;
	wire [3:0] spi_dq_TO_FPGA;
	wire [3:0] spi_dq_FROM_FPGA;
	wire [3:0] spi_dq_T;
	reg [3:0] mode_mux;
	//(* KEEP = "TRUE" *) reg [31:0] addr/* synthesis noprune */;
	 reg [31:0] addr/* synthesis noprune */;
	 reg [31:0] dataw/* synthesis noprune */;
	 reg [55:0] MOSI/* synthesis noprune */;
	 reg [55:0] MISO/* synthesis noprune */;
	 reg [8:0] max_byte/* synthesis noprune */;
	 reg [8:0] byte_cnt/* synthesis noprune */;
	 reg [2:0] bit_cnt; // will auto reset
	 reg [7:0] accm_reg; // for page read accumulations
	 reg qspi_rnw/* synthesis noprune */;
	 reg oe/* synthesis noprune */; //oe goes HI when we want to see MISO data (from flash module)
	

	//=============================================================================
	// 128 byte page write information
	//=============================================================================
	// once we have new data, wait one clock and then pulse dpram write enable hi
	wire epcs_buffer_wen;
	(* KEEP = "TRUE" *)  reg  [2:0] epcs_buffer_wen_pulse = 3'b000 /* synthesis noprune */;
	always@(posedge lb_clk) begin // clocked with slow clock
		 epcs_buffer_wen_pulse <= {epcs_buffer_wen_pulse[1:0], we_cyclone_inst_c10_data}; // shift in new bit
	end	
	// we only want to look at the rising edge
	assign epcs_buffer_wen = (((epcs_buffer_wen_pulse[2]==1'b0) && (epcs_buffer_wen_pulse[1]==1'b1)) || ((epcs_buffer_wen_pulse[1]==1'b0) && (epcs_buffer_wen_pulse[0]==1'b1))) ? 1'b1 : 1'b0; // check for rising edge
	
	
	wire [7:0] epcs_buffer_addra;
	//note that this pulse is delayed up to 32 slow clock cycles (adjust c10_page_load_done if interested)
	//(* KEEP = "TRUE" *) reg [31:0] <name>/* synthesis noprune */;
//	(* KEEP = "TRUE" *)  reg  [31:0] c10_page_load_pulse = 8'h00000000 /* synthesis noprune */;
//	wire c10_page_load_done;	
//	always@(posedge lb_clk) begin // clocked with slow clock
//		 c10_page_load_pulse <= {c10_page_load_pulse[30:0], (epcs_buffer_addra==63)}; // shift in new bit
//	end	
//	assign c10_page_load_done = ~c10_page_load_pulse[2] & c10_page_load_pulse[1]; // rising edge detection
	
	reg [7:0] epcs_page_count /* synthesis noprune */;
	wire [15:0] epcs_dpram_out;
	reg write_byte_cntr;
	assign epcs_buffer_addra = c10_data[23:16];
	
	wire [15:0] dpram_douta;

	// dpram that we use to load data to be written to flash
	// we load it in 128 byte packets (so data can be sent in one ethernet frame)
	dpram #(.dw(16), .aw(8)) 
	epcs_buffer(.clka(lb_clk), .clkb(lb_clk),
	 .addra(epcs_buffer_addra), .dina(c10_data[15:0]), .wena(epcs_buffer_wen), .douta(dpram_douta),
	 .addrb(epcs_page_count), .doutb(epcs_dpram_out));
	 
	  wire [15:0] epcs_bytes; 
	  assign epcs_bytes = epcs_dpram_out;//{epcs_dpram_out[7:0], epcs_dpram_out[15:8]}; 
	
	//=============================================================================
	// Main state machine
	//=============================================================================
    always@(posedge lb_clk) begin
        case (qspi_state)
        16'h00 : begin // Idle
        
            case (c10_cntlr_buf[7:0])
                8'h01 : begin // page write state machine
                    mode_mux = 4'h7;
                end 
                8'h02 : begin// byte read
                    mode_mux = 4'h6;
               end 
               8'h04 : begin // bank enable
                    mode_mux = 4'h4;
               end 
               8'h08 : begin // erase
                    mode_mux = 4'h3;
               end 
               8'h10 : begin// SR1
                    mode_mux = 4'h5;
               end 
               8'h20 : begin // CLSR
                    mode_mux = 4'h2;
               end 
               8'h40 : begin// WREN
                    mode_mux = 4'h1;                
                end 
                8'h80 : begin // WRDI
                    mode_mux = 4'h8;  
                    end              
                default: begin
                    mode_mux = 4'h0;
                end
            endcase

            // only enter loop for known control commandds (on hot encoding)
           if ((c10_cntlr_buf == 1) || (c10_cntlr_buf == 2) || (c10_cntlr_buf == 4) || (c10_cntlr_buf == 8) || (c10_cntlr_buf == 16) || (c10_cntlr_buf == 32) || (c10_cntlr_buf == 64) || (c10_cntlr_buf == 128))   begin
                qspi_state = 1;              
            end else begin
                qspi_state = 0;
            end
            mode = 0;
            byte_cnt = 0;
            bit_cnt = 0;
            
            accm_reg = 0;
            c10_cntlr_buf2 = c10_cntlr_buf;
            epcs_page_count = 0;
            write_byte_cntr = 1'b0;
            
        end
        16'h01 : begin // Buffer inputs
            qspi_state = 2;
            mode = mode_mux;
            addr = c10_addr;
            dataw = c10_data_buf;// {16'h0000,epcs_bytes};
            epcs_page_count = 0;
            write_byte_cntr = 1'b0;
            byte_cnt = 0;
            bit_cnt = 0;
            
            accm_reg = 0;
        end
        16'h02 : begin // Instruction load
            qspi_state = 3;
            byte_cnt = 0;
            bit_cnt = 0;
            
            accm_reg = 0;
            epcs_page_count = 0;
            write_byte_cntr = 1'b0;
            case (mode)
                4'h1 : begin // WREN, write enable
                    MOSI = 56'h06ffffffffffff;
                    MISO = 56'hffffffffffffff;
                    max_byte = 0;
                    qspi_rnw = 0;
                end
                4'h2 : begin // CLSR, clear status regiser/fault
                    MOSI = 56'h30ffffffffffff;
                    MISO = 56'hffffffffffffff;
                    max_byte = 0;
                    qspi_rnw = 0;
                end
                4'h3 : begin // BE, bulk erase entire flash
                    MOSI = 56'h60ffffffffffff;
                    MISO = 56'hffffffffffffff;
                    max_byte = 0;
                    qspi_rnw = 0;
                end
                4'h4 : begin // BRWR, back address write
                    MOSI = 56'h1780ffffffffff;  // ** double check what bit needs to be written for BRWR
                    MISO = 56'hffffffffffffff;
                    max_byte = 1;
                    qspi_rnw = 0;
                end
                4'h5 : begin // SR1, busy check
                    MOSI = 56'h05ffffffffffff;
                    MISO = 56'hDEADBEEFFACE12; // test, init data won't be used but will help in aligning data
                    max_byte = 1;
                    qspi_rnw = 1;
                end
                4'h6 : begin // 4READ, can be a bulk read
                    MOSI = {8'h13,addr,16'hffff}; //56'h13ffffffffffff;
                    MISO = 56'h00000000000000;
                    if (dataw==128) begin
                        max_byte = 132; // for 128 page reads
                    end else begin
                        max_byte = 5;
                    end
                    qspi_rnw = 1;
                end
                4'h7 : begin // 4PP, can be a bulk write
                    MOSI = {8'h12,addr,epcs_bytes[15:0]}; //56'h06ffffffffffff;
                    MISO = 56'hffffffffffffff;
                    max_byte = 132;
                    qspi_rnw = 0;
                end
                4'h8 : begin // WRDI, clear write enable
                    MOSI = 56'h04ffffffffffff; //56'h06ffffffffffff;
                    MISO = 56'hffffffffffffff;
                    max_byte = 0;
                    qspi_rnw = 0;
                end
                default : begin // default is CLSR, clear status regiser/fault
                    MOSI = 56'h30ffffffffffff;
                    MISO = 56'hffffffffffffff;
                    max_byte = 0;
                    qspi_rnw = 0;
                end
            endcase
        end
        16'h03 : begin // CSN LOW
            qspi_state = 4;
            byte_cnt = 0;
            bit_cnt = 0;
            write_byte_cntr = 1'b0;
            accm_reg = 0;
        end
        16'h04 : begin // SPI HI
            qspi_state = 5;
//            if ((write_byte_cntr==1'b1) && (bit_cnt == 7)) begin
//                epcs_page_count = epcs_page_count + 1;
//            end
        end
        16'h05 : begin // SPI HI
            qspi_state = 6;
        end
        16'h06 : begin // SPI LOW, next setup

                if ((bit_cnt == 7) && (byte_cnt == max_byte))
                begin
                    qspi_state = 8;
                    bit_cnt = bit_cnt + 1;
                    accm_reg = accm_reg + {MISO[6:0], spi_dq_TO_FPGA[0]};
                    // shift register
                     MOSI = {MOSI[54:0],1'b0}; 
                end 
                else if (bit_cnt == 7)
                begin
                    qspi_state = 7;
                    byte_cnt = byte_cnt + 1;
                    bit_cnt = bit_cnt + 1;
                    if (byte_cnt >=5) begin // are we starting the 5th byte for writes 9/8/22
                           if (byte_cnt >= 6) begin // only run accumulator incrementation for bytes 6 and on 9/8/22
                                accm_reg = accm_reg + {MISO[6:0], spi_dq_TO_FPGA[0]};  // for verifying checksum
                           end
                           //dpram contents store 2 bytes per address. increment epcs_page_counter every other time
                           if (write_byte_cntr==1'b0) begin
                                write_byte_cntr = ~write_byte_cntr; //this one it counter is just toggling
                                MOSI = {epcs_bytes,40'h0000000000}; // MSbit is shifted out
                                //MOSI = {MOSI[54:0],1'b0};  // continue with normal shifts (LSByte still has data to write
                           end else begin
                                 write_byte_cntr = ~write_byte_cntr; //this one it counter is just toggling
                                 MOSI = {MOSI[54:0],1'b0}; 
                                 epcs_page_count = epcs_page_count + 1;
                                 //MOSI = {40'h0000000000,epcs_bytes}; // new epcs_bytes loaded during SPI HI state and is now ready
                                 //MOSI = {epcs_bytes,40'h0000000000}; // MSbit is shifted out
                           end                        
                     end
                     else
                     begin
                         // shift register
                         MOSI = {MOSI[54:0],1'b0}; 
                     end
                end
                else
                begin
                    qspi_state = 7;
                    bit_cnt = bit_cnt + 1;
                    // shift register
                     MOSI = {MOSI[54:0],1'b0}; 
                end
                //shift register
                MISO = {MISO[54:0], spi_dq_TO_FPGA[0]}; 
        end
        16'h07 : begin // SPI LOW
            qspi_state = 4; 
        end
        16'h08 : begin // CSN go HI
            qspi_state = 9;
           // byte_cnt = 0;
            //bit_cnt = 0;
        end
        16'h09 : begin // Done
            //qspi_state = 0;
            //byte_cnt = 0;
            //bit_cnt = 0;
            if (c10_cntlr_buf==0) begin // wait for cntrl to be set to 0, allows time to read results with python scripts
                qspi_state = 0;
            end else begin
                qspi_state = 9;
            end
        end
        default : begin // default case
            qspi_state = 0;
            byte_cnt = 0;
            bit_cnt = 0;
        end
        endcase
	end

  assign epcs_inst_busy = (qspi_state==0) ? 1'b0 : 1'b1; // **** what about handling busy checks for an erase? maybe in python code???
  assign epcs_dout_wire = MISO[7:0];



	//=============================================================================
	// Physical outputs
	//=============================================================================

  // output for chip select pin (CSN)
  assign qspi_cs = ((qspi_state==3)||(qspi_state==4)||(qspi_state==5)||(qspi_state==6)||(qspi_state==7)) ? 1'b0 : 1'b1; 
  // SCLK
  assign flash_clk = ((qspi_state==4) || (qspi_state==5)) ? 1'b1 : 1'b0; // 125MHz/4
  //tristate pins
  assign spi_dq_FROM_FPGA = MOSI[55];
  assign qspi_dq[0] =  MOSI[55];
  //assign spi_dq_FROM_FPGA = oe; // for debug only
  // NOTE: only intend to read 1 byte with this setup.
  assign spi_dq_T[0] = 1'b1;//((qspi_rnw == 1) && (byte_cnt == max_byte)) ? 1'b1 : 1'b0;  // T going HI puts IOBUF in tristate
  assign spi_dq_T[2] = (mode==4'h7) ? 1'b0 : 1'b1; // if in write mode, set IOBUF to output mode else keep in HI Z
  // assign spi_dq_T[0] = (((qspi_rnw == 1) && (byte_cnt == 5) && (max_byte !== 1)) || ((qspi_rnw == 1) && (byte_cnt == 1) && (max_byte == 1))) ? 1'b1 : 1'b0; 
  // qspi tristate buffers 
  // qspi io 0
  IOBUF #(.DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) spi_dq_inst_0 
  (.O(spi_dq_TO_FPGA[0]), .IO(qspi_dq[1]), .I(spi_dq_FROM_FPGA[0]), .T(spi_dq_T[0]));
//  // qspi io 1
//  IOBUF #(.DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) spi_dq_inst_1 
//  (.O(spi_dq_To_FPGA[1]), .IO(qspi_dq[1]), .I(spi_dq_FROM_FPGA[1]), .T(spi_dq_T[1]));
//  // qspi io 2
  IOBUF #(.DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) spi_dq_inst_2 // WP, write protect signal
  (.O(), .IO(qspi_dq[2]), .I(1'b0), .T(spi_dq_T[2])); // pull WP low when in write mode, else leave in HI Z
  // qspi io 3
//  IOBUF #(.DRIVE(12), .IBUF_LOW_PWR("TRUE"), .IOSTANDARD("DEFAULT"), .SLEW("SLOW") ) spi_dq_inst_3 
//  (.O(spi_dq_To_FPGA[3]), .IO(qspi_dq[3]), .I(spi_dq_FROM_FPGA[3]), .T(spi_dq_T[3]));
    // buffer outputs
    always@(posedge lb_clk) begin
        c10_status_buf = {epcs_page_count[7:0], mode_mux ,mode, qspi_state}; // to help with debug
        if  (mode == 4'h6) begin // set write data to 128 to display accumulator data. We can change this later if it is anoying but you don't need thte write reg for reads.
            c10_datar_buf = {24'h000000,accm_reg}; // output accum data
        end else if (mode == 4'h7) begin
            c10_datar_buf = {8'h00, epcs_buffer_addra[7:0], dpram_douta};
        end else begin            
            c10_datar_buf = MISO[31:0]; // output data read
        end
     end
    assign c10_status = c10_status_buf;
    assign c10_datar = c10_datar_buf;
  
  
  wire flash_clk_div;
  (* KEEP = "TRUE" *) reg [7:0] flash_clk_div_count;
  always@(posedge lb_clk) begin //Note the same as statup flash clock. Change name if this works 
        flash_clk_div_count = flash_clk_div_count + 1;
  end
  // must be less than 100 Mhz or 70 Mhz depending on the speed grade.
  //the reconfig can be slow. Per DS181 pg 59
  assign flash_clk_div = flash_clk_div_count[7];
  
  //remote configuration AND setting of next boot address WBSTAR)
  (* KEEP = "TRUE" *) reg [31:0] icap_out;
   (* KEEP = "TRUE" *) reg [31:0] icap_in;
  wire [31:0] icap_in_swap;
  wire CSIB;
  wire RDWRB;
  (* KEEP = "TRUE" *) reg [7:0] icap_state;
  
  //note,we need to bitswap the data bytes
  // using flash clock/spi configuration clock
  always@(posedge flash_clk_div) begin
        case (icap_state[7:0])
            8'h00 : begin // watch for go command
                if (c10_cntlr_buf == 165) begin  // this is the reconfigure chip from flash memory command. Maybe double buffer this? changed from 255 on 1/4/23
                    icap_state = 1;
                    icap_in = 32'hFFFFFFFF;
                end else begin
                    icap_state = 0;
                    icap_in = 32'hFFFFFFFF;
                end
            end 
            8'h01 : begin // sync word
                icap_in = 32'hFFFFFFFF;
                icap_state = 2;  
            end  
            8'h02 : begin // sync word
                icap_in = 32'hAA995566;
                icap_state = 3;  
            end  
             8'h03 : begin // type 1 NO OP instruction
                icap_in = 32'h20000000;
                icap_state = 4;  
            end  
            8'h04 : begin // type 1 write 1 WBSTAR instruction
                icap_in = 32'h30020001;
                icap_state = 5;  
            end  
            8'h05 : begin // WBSTAR
                icap_in = 32'h00000000;
                icap_state = 6;  
            end      
            8'h06 : begin // type 1 write 1 words to CMD
                icap_in = 32'h30008001;
                icap_state = 7;  
            end   
            8'h07 : begin // IPROG Command
                icap_in = 32'h0000000F;
                icap_state = 8;  
            end   
            8'h08 : begin // Type 1 No Op insturction
                icap_in = 32'h20000000;
                icap_state = 9;  
            end   
            default: begin
                icap_in = 32'hFFFFFFFF;
                icap_state = 0; 
            end
        endcase
   end
       
  assign CSIB  = (icap_state==0) ? 1'b1 : 1'b0;
  assign RDWRB = (icap_state==0) ? 1'b1 : 1'b0;
  //bitswap per byte per UG470 pg 77
  assign icap_in_swap[31:24] = {icap_in[24], icap_in[25], icap_in[26], icap_in[27], icap_in[28], icap_in[29], icap_in[30], icap_in[31]};
  assign icap_in_swap[23:16] = {icap_in[16], icap_in[17], icap_in[18], icap_in[19], icap_in[20], icap_in[21], icap_in[22], icap_in[23]};
  assign icap_in_swap[15:8]  = {icap_in[8],  icap_in[9],  icap_in[10], icap_in[11], icap_in[12], icap_in[13], icap_in[14], icap_in[15]};
  assign icap_in_swap[7:0]   = {icap_in[0],  icap_in[1],  icap_in[2],  icap_in[3],  icap_in[4],  icap_in[5],  icap_in[6],  icap_in[7]};
  
    ICAPE2 #(
      .DEVICE_ID(0'h3651093),     // Specifies the pre-programmed Device ID value to be used for simulation h3651093
                                  // purposes.
      .ICAP_WIDTH("X32"),         // Specifies the input and output data width.
      .SIM_CFG_FILE_NAME("NONE")  // Specifies the Raw Bitstream (RBT) file to be parsed by the simulation
                                  // model.
   )
   ICAPE2_inst (
      .O(),             // 32-bit output: Configuration data output bus
      .CLK(flash_clk_div),     // 1-bit input: Clock Input
      .CSIB(CSIB),      // 1-bit input: Active-Low ICAP Enable
      .I(icap_in_swap), // 32-bit input: Configuration data input bus
      .RDWRB(RDWRB)     // 1-bit input: Read/Write Select input
   );

  
  
  
  endmodule
