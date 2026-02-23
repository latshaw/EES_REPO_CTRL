// Slot Wrapper
// James Latshaw
// 4/11/2025
//
// This is being written for the cbh20 project. There will be several 'slots' which have a range of IO ICs. This module is being written
// as a 'wrapper' which will instantiate each module, and make the IO accessible in the usual HRT memory mapped way. The generic slot
// pcb(s) have a common or shared SPI bus with exception to the Chip Select pins (CSn) which are dedicated.
// The HRT will performing muxing based on the address selected (to help with fan out). The address offset will be used to select registers 
// from this module. This is most interesting for write cases. Actual read selection is handled in the top level module.
//
// Regarding ADDR_UPPER, ensure that this is different for each instantiated slot.
// 
module slot_wrapper(
    input  clock,
    input  reset_n,
    output [3:0] csn,
    output sclk,
    input  sdi,
    output sdo,
    output [23:0] rtd1_out,
    output [23:0] rtd2_out,
    output [15:0] sense8_out,
    output [11:0] adc_1_out,
    output [11:0] adc_2_out,
    output [11:0] adc_3_out,
    output [11:0] adc_4_out,
    input  [1:0] SSR,
    input  lb_valid,
    input  lb_rnw,
    input  [23:0] lb_addr,
    input  [31:0] lb_wdata,
    output [31:0] lb_rdata_mux,
    input  [15:0] ADDR_UPPER);     // because of multiplexing, reads don't care about the upper bits. We only need this paramter for writes
    //
    //
    wire [3:0] MISO;
    wire [3:0] csn_mux, sclk_mux, mosi_mux, miso_mux;
    reg  [1:0] rtd_1_SEL, rtd_2_SEL, io_SEL, adc_SEL;
    wire [1:0] rtd_1_SEL_d, rtd_2_SEL_d, io_SEL_d, adc_SEL_d;
    //================================================================
    // SELECT_IT sequence
    //================================================================
    reg  [3:0] SELECT_IT, SELECT_IT_MASTER, SEL_PRE; // Select between SPI lines
    wire [3:0] SELECT_IT_WIRE, SEL_PRE_WIRE;
    // select_it will go high to control configure the spi bus for a specific chip
    reg [1:0] des1, des2, des3, des4; //done edge state
    wire doneEdge1, doneEdge2, doneEdge3, doneEdge4;
    wire [3:0] DONE_IT, INIT_IT_WIRE; // bad grammar, but the respective bit will go high (and stay high) once that chips SPI task has been
    reg  [3:0] DONE_IT_reg, DONE_IT_last, INIT_IT;
    // completed and it strobes its 'done' bit
    
    // some chips have a volitle, one time setup. these signals control this . set them LOW to reset the chip
    // and keep high to operate normally. We achieve this with a 2 bit code. 2'b{1=reset, 0=no reset, 1=take, = no take}
    reg  [1:0] rtdCtrl_1, rtdCtrl_2, ioexoCtrl, adcCtrl;
    wire [1:0] rtdCtrl_1W, rtdCtrl_2W, ioexoCtrlW, adcCtrlW;
    wire RE1, RE2, RE3, RE4;
    reg [3:0] RE;
    reg refresh;
    wire refresh_wire;
    reg [3:0] state;
    reg [1:0] selCount;
    reg [32:0] watchDog; //roughly 1 minute watch dog timer
    reg [15:0] watchDogResets;
    
    wire selMasterCheck;
    assign selMasterCheck = (SELECT_IT_MASTER==1 || SELECT_IT_MASTER==2 || SELECT_IT_MASTER==4 || SELECT_IT_MASTER==8)? 1'b1 : 1'b0;

     always@(posedge clock) begin
        if (reset_n==1'b0) begin
            state     <= 0;
            rtdCtrl_1 <= 0;
            rtdCtrl_2 <= 0;
            ioexoCtrl <= 0;
            adcCtrl   <= 0;
            SELECT_IT <= 0;
            selCount  <= 0;
            watchDog  <= 0;
            watchDogResets <=0;
        end else begin
            if (&watchDog) begin
                state     <= 0;
                watchDog  <= 0;
                watchDogResets <= watchDogResets + 1;
            end else begin 
                watchDog <= watchDog + 1;
                case (state)
                4'h0  : begin // reset
                    state     <= 4'h1;
                    rtdCtrl_1 <= 2'b00;
                    rtdCtrl_2 <= 2'b00;
                    ioexoCtrl <= 2'b00;
                    adcCtrl   <= 2'b00;
                    SELECT_IT <= 0;
                    selCount  <= 0;
                end
                4'h1  : begin // setup
                    state     <= 4'h2;
                    rtdCtrl_1 <= 2'b00;
                    rtdCtrl_2 <= 2'b00;
                    ioexoCtrl <= 2'b00;
                    adcCtrl   <= 2'b00;
                    SELECT_IT <= 0;
                    selCount  <= 0;
                end
                4'h2 : begin // check for interrupt
                    if (selMasterCheck) begin
                        state     <= 4'h3;
                        SELECT_IT <= SELECT_IT_MASTER;
                    end else begin
                        state     <= 4'h4;
                        SELECT_IT <= 0;
                    end
                    rtdCtrl_1 <= 2;
                    rtdCtrl_2 <= 2;
                    ioexoCtrl <= 2;
                    adcCtrl   <= 2;
                end
                4'h3 : begin // user controls spi bus
                    if (selMasterCheck) begin
                        state     <= 4'h3;
                    end else begin
                        state     <= 4'h0; // reset when done
                    end
                    
                    if (SELECT_IT==1) begin
                        rtdCtrl_1 <= 3;
                        rtdCtrl_2 <= 2;
                        ioexoCtrl <= 2;
                        adcCtrl   <= 2;
                    end else if (SELECT_IT==2) begin
                        rtdCtrl_1 <= 2;
                        rtdCtrl_2 <= 3;
                        ioexoCtrl <= 2;
                        adcCtrl   <= 2;
                    end else if (SELECT_IT==4) begin
                        rtdCtrl_1 <= 2;
                        rtdCtrl_2 <= 2;
                        ioexoCtrl <= 3;
                        adcCtrl   <= 2;
                    end else begin
                        rtdCtrl_1 <= 2;
                        rtdCtrl_2 <= 2;
                        ioexoCtrl <= 2;
                        adcCtrl   <= 3;
                    end
                    //
                    SELECT_IT <= SELECT_IT_MASTER;
                end
                4'h4 : begin // loop through spi bus (set take)
                    if (selCount==0) begin
                        SELECT_IT <= 4'b0001;
                        rtdCtrl_1 <= 3;
                        rtdCtrl_2 <= 2;
                        ioexoCtrl <= 2;
                        adcCtrl   <= 2;
                    end else if (selCount==1) begin
                        SELECT_IT <= 4'b0010;
                        rtdCtrl_1 <= 2;
                        rtdCtrl_2 <= 3;
                        ioexoCtrl <= 2;
                        adcCtrl   <= 2;
                    end else if (selCount==2) begin
                        SELECT_IT <= 4'b0100;
                        rtdCtrl_1 <= 2;
                        rtdCtrl_2 <= 2;
                        ioexoCtrl <= 3;
                        adcCtrl   <= 2;
                    end else begin
                        SELECT_IT <= 4'b1000;
                        rtdCtrl_1 <= 2;
                        rtdCtrl_2 <= 2;
                        ioexoCtrl <= 2;
                        adcCtrl   <= 3;
                    end
                    state <= 4'h5;
                    DONE_IT_last <= DONE_IT;
                end
                4'h5 : begin // loop through spi bus (watch for busy)
                    //
                    DONE_IT_last <= DONE_IT;
                    //
                    if (selMasterCheck) begin
                        state     <= 4'h2;
                    end else begin
                        if (selCount==0) begin
                            if (DONE_IT[0] == 1'b1 && DONE_IT_last[0] == 1'b0) begin
                                state <= 4'h6;
                            end else begin
                                state <= 4'h5;
                            end
                            rtdCtrl_1 <= 3;
                            rtdCtrl_2 <= 2;
                            ioexoCtrl <= 2;
                            adcCtrl   <= 2;
                        end else if (selCount==1) begin
                            if (DONE_IT[1] == 1'b1 && DONE_IT_last[1] == 1'b0) begin
                                state <= 4'h6;
                            end else begin
                                state <= 4'h5;
                            end
                            rtdCtrl_1 <= 2;
                            rtdCtrl_2 <= 3;
                            ioexoCtrl <= 2;
                            adcCtrl   <= 2;
                        end else if (selCount==2) begin
                            if (DONE_IT[2] == 1'b1 && DONE_IT_last[2] == 1'b0) begin
                                state <= 4'h6;
                            end else begin
                                state <= 4'h5;
                            end
                            rtdCtrl_1 <= 2;
                            rtdCtrl_2 <= 2;
                            ioexoCtrl <= 3;
                            adcCtrl   <= 2;
                        end else begin
                            if (DONE_IT[3] == 1'b1 && DONE_IT_last[3] == 1'b0) begin
                                state <= 4'h6;
                            end else begin
                                state <= 4'h5;
                            end
                            rtdCtrl_1 <= 2;
                            rtdCtrl_2 <= 2;
                            ioexoCtrl <= 2;
                            adcCtrl   <= 3;
                        end
                   end
                end
                4'h6 : begin // increment counters
                    rtdCtrl_1 <= 2;
                    rtdCtrl_2 <= 2;
                    ioexoCtrl <= 2;
                    adcCtrl   <= 2;
                    selCount  <= selCount + 1;
                    SELECT_IT <= 0;
                    state     <= 4'h2;
                    watchDog  <= 0; // reset watchdog with a valid spi communication
                end
                default: begin 
                    state <= 4'h0;
                end
             endcase
           end // end watch dog timer
        end
     end // end process
     //
     // the enables will go high and stay high until a reset
     //
    //================================================================
    // Common SPI bus Managment
    //================================================================
    //
    //
    //Use SELECT_IT to mux one set of SPI lanes to/from one module
    //
	assign sdo = (SELECT_IT == 4'b0001)? mosi_mux[0] : 
	             (SELECT_IT == 4'b0010)? mosi_mux[1] :
	             (SELECT_IT == 4'b0100)? mosi_mux[2] :
	             (SELECT_IT == 4'b1000)? mosi_mux[3] :
	             1'b0;
	// 
    assign sclk = (SELECT_IT == 4'b0001)? sclk_mux[0] : 
	              (SELECT_IT == 4'b0010)? sclk_mux[1] :
	              (SELECT_IT == 4'b0100)? sclk_mux[2] :
	              (SELECT_IT == 4'b1000)? sclk_mux[3] :
	              1'b0;
	// 
	// Keep CSn for a given chip HI if it is not selected               
    assign csn[0] =(SELECT_IT == 4'b0001)? csn_mux[0] : 1'b1;
    assign csn[1] =(SELECT_IT == 4'b0010)? csn_mux[1] : 1'b1;
    assign csn[2] =(SELECT_IT == 4'b0100)? csn_mux[2] : 1'b1;
    assign csn[3] =(SELECT_IT == 4'b1000)? csn_mux[3] : 1'b1;
    //
    // Keep MISO HI going into chip if it is not selected (idle HI)
    assign miso_mux[0] =(SELECT_IT == 4'b0001)? sdi : 1'b1;
    assign miso_mux[1] =(SELECT_IT == 4'b0010)? sdi : 1'b1;
    assign miso_mux[2] =(SELECT_IT == 4'b0100)? sdi : 1'b1;
    assign miso_mux[3] =(SELECT_IT == 4'b1000)? sdi : 1'b1;
    //
    //
    //
    //
    //================================================================
    // Instantiate Modules
    //================================================================
    //
    // U6
    wire [23:0] rtd1[7:0];
    wire rtd1_ready;
    AD7124 AD7124_inst1 (
        .clock          (clock),
        .reset_n        (reset_n),
        .csn            (csn_mux[0]),
        .sclk           (sclk_mux[0]),
        .sdi            (sdi), // was miso_mux[0]
        .sdo            (mosi_mux[0]),
        .data24_status  (rtd1[0]),
        .data24_adc_ctrl(rtd1[1]),
        .data24_ID      (rtd1[2]),
        .data24_IO_ctrl (rtd1[3]), 
        .data24_chn0    (rtd1[4]),   
        .data24_config0 (rtd1[5]),
        .data24_data    (rtd1[6]),
        .ctrl           (rtdCtrl_1),
        .state_out      (rtd1[7][15:0]),
        .done            (DONE_IT[0]));
        assign rtd1_ready = DONE_IT[0];
    //
    // U13
    wire [23:0] rtd2[7:0];
    wire rtd2_ready;
    AD7124 AD7124_inst2 (
        .clock          (clock),
        .reset_n        (reset_n),
        .csn            (csn_mux[1]),
        .sclk           (sclk_mux[1]),
        .sdi            (miso_mux[1]),
        .sdo            (mosi_mux[1]),
        .data24_status  (rtd2[0]),
        .data24_adc_ctrl(rtd2[1]),
        .data24_ID      (rtd2[2]),
        .data24_IO_ctrl (rtd2[3]), 
        .data24_chn0    (rtd2[4]),   
        .data24_config0 (rtd2[5]),
        .data24_data    (rtd2[6]),
        .ctrl           (rtdCtrl_2),
        .state_out      (rtd2[7][15:0]),
        .done            (DONE_IT[1]));
        assign rtd2_ready = DONE_IT[1];
    //
    // IO Expansion Chip U22
    wire [15:0] config04, config0b, config0c, config0e, config0f, drive8_rb, sense8;
    reg [7:0] drive8;
    wire [7:0] drive8_wire;
    assign drive8_wire = {drive8[7:5], SSR, drive8[2:0]}; // see notes in MAX3701 for relay order
    //assign drive8_wire = {8'h00001111}; // see notes in MAX3701 for relay order
    
    MAX7301 MAX7301_inst(
    .clock    (clock),
    .reset_n  (reset_n),
    .csn      (csn_mux[2]),
    .sclk     (sclk_mux[2]),
    .sdo      (mosi_mux[2]),
    .sdi      (miso_mux[2]),
    .config04 (config04),     
    .config0b (config0b),
    .config0c (config0c),
    .config0e (config0e),
    .config0f (config0f),
    .drive8   (drive8_wire),
    .drive8_rb(drive8_rb),
    .sense8   (sense8),
    .ctrl     (ioexoCtrl),
    .ready    (DONE_IT[2]));
    //
    // ADC Chip, U8
    wire [11:0] adc_1, adc_2, adc_3, adc_4;
    ADC1245S ADC1245S_inst(
    .clock  (clock),
    .reset_n(reset_n),
    .enable (adcCtrl[0]),
    .csn    (csn_mux[3]),
    .sclk   (sclk_mux[3]),
    .mosi   (mosi_mux[3]),
    .miso   (miso_mux[3]),
    .data1  (adc_1),
    .data2  (adc_2),
    .data3  (adc_3),
    .data4  (adc_4),
    .ready  (DONE_IT[3]));
    //
    //
    // assign rtd values as an output
    assign rtd1_out = rtd1[6][23:0];
    assign rtd2_out = rtd2[6][23:0];
    //
    //
    //================================================================
    // Register Access and Readbacks
    //================================================================
    //
    reg [31:0] rd_reg; // read data register
    assign lb_rdata_mux = rd_reg;
    //
    always@(posedge clock) begin
        if (lb_valid) begin
            case(lb_addr[7:0])
                // rtd 1
                8'h00   : rd_reg <= {8'h00, rtd1[0]};
                8'h01   : rd_reg <= {8'h00, rtd1[1]};
                8'h02   : rd_reg <= {8'h00, rtd1[2]};
                8'h03   : rd_reg <= {8'h00, rtd1[3]};
                8'h04   : rd_reg <= {8'h00, rtd1[4]};
                8'h05   : rd_reg <= {8'h00, rtd1[5]};
                8'h06   : rd_reg <= {8'h00, rtd1[6]};
                8'h07   : rd_reg <= {8'h00, rtd1[7]};
                8'h08   : rd_reg <= {28'h0000000, 3'b000, rtd1_ready};
                // rtd 2
                8'h09   : rd_reg <= {8'h00, rtd2[0]};
                8'h0A   : rd_reg <= {8'h00, rtd2[1]};
                8'h0B   : rd_reg <= {8'h00, rtd2[2]};
                8'h0C   : rd_reg <= {8'h00, rtd2[3]};
                8'h0D   : rd_reg <= {8'h00, rtd2[4]};
                8'h0E   : rd_reg <= {8'h00, rtd2[5]};
                8'h0F   : rd_reg <= {8'h00, rtd2[6]};
                8'h10   : rd_reg <= {8'h00, rtd2[7]};
                8'h11   : rd_reg <= {28'h0000000, 3'b000, rtd2_ready};
                // adc
                8'h12   : rd_reg <= {20'h00000, adc_1};
                8'h13   : rd_reg <= {20'h00000, adc_2};
                8'h14   : rd_reg <= {20'h00000, adc_3};
                8'h15   : rd_reg <= {20'h00000, adc_4};
                // io expander
                8'h16  : rd_reg <= {16'h0000, config04};
                8'h17  : rd_reg <= {16'h0000, config0b};
                8'h18  : rd_reg <= {16'h0000, config0c};
                8'h19  : rd_reg <= {16'h0000, config0e};
                8'h1A  : rd_reg <= {16'h0000, config0f};
                8'h1B  : rd_reg <= {24'h000000, drive8};     //RW
                8'h1C  : rd_reg <= {16'h0000,   sense8};
                8'h1D  : rd_reg <= {16'h0000, drive8_rb};
                // spi bus mux controller register, SELECT_IT
                8'h1E  : rd_reg <= {4'h0, 2'b00, selCount, 2'b00, rtdCtrl_1, 2'b00, rtdCtrl_2, 2'b00, ioexoCtrl, 2'b00, adcCtrl, state, SELECT_IT}; //RW
                8'h1F  : rd_reg <= {watchDogResets, 12'h000, DONE_IT};   //RW
                // add others here...
                default : rd_reg <= 32'hfacefeed;
           endcase
        end
    end

    //
    // Each read/write register must have an enable when the address matches and the rnw strobe occurs.
    // We need to pay special attention to the upper address bits
    //
     wire SELECT_IT_en;
    assign SELECT_IT_en = ((lb_rnw == 1'b0) && (lb_addr[23:0] == {ADDR_UPPER, 8'h1E}))? 1'b1 : 1'b0;
    always@(posedge clock) begin
        if (reset_n==1'b0) begin
            SELECT_IT_MASTER <= 0;
        end else begin
            if (SELECT_IT_en) begin
                SELECT_IT_MASTER <= lb_wdata[3:0];
            end
        end
    end
    //
    wire drive8_en;
    assign drive8_en = ((lb_rnw == 1'b0) && (lb_addr[23:0] == {ADDR_UPPER, 8'h1B}))? 1'b1 : 1'b0;
    always@(posedge clock) begin
        if (reset_n==1'b0) begin
            drive8 <= 0;
        end else begin
            if (drive8_en) begin
                //drive8 <= {2'b000, SSR, lb_wdata[2:0]};
                drive8 <= lb_wdata[7:0];
            end
        end
    end
    
    // assigning outputs for register mapping and controls
    assign sense8_out = sense8;
    assign adc_1_out  = adc_1;
    assign adc_2_out  = adc_2;
    assign adc_3_out  = adc_3;
    assign adc_4_out  = adc_4;
    
    
//    ila_1 ila_inst (
//    .clk(clock),
//    .probe0(SELECT_IT),
//    .probe1(SELECT_IT_MASTER),
//    .probe2(rtdCtrl_1),
//    .probe3(rtdCtrl_2),
//    .probe4(ioexoCtrl),
//    .probe5(adcCtrl),
//    .probe6(state)
//    );
    
//rtdCtrl_1 <= 3;
//rtdCtrl_2 <= 2;
//ioexoCtrl <= 2;
//adcCtrl   <= 2;

//
//
//
endmodule
