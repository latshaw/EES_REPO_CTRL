// MAX7301, IO Expander Chip
// 03/24/2025
// James Latshaw
//
module MAX7301
    (input clock,
    input  reset_n,
    output csn,
    output sclk,
    input  sdi,             //MISO, falling edge of SCLK
    output sdo,             //MOSI, rising edge of SCLK
    output [15:0] config04,
    output [15:0] config0b,
    output [15:0] config0c,
    output [15:0] config0e,
    output [15:0] config0f,
    input  [7:0]  drive8,    // really only 5 are driven, P12, P13, P14, P15, P16
    output [15:0] drive8_rb, //read back drive8 register on MAX7301
    output [15:0] sense8,    // P17, P18, P26, P27, P28, P29, P30, P31
    input  [1:0] ctrl, 
    output ready             //will go high when in final state
    );
    
// drive8 relay notes:
// bit0     bit1    bit2      bit3   bit4
// P12,     P13,    P14,      P15,   P16
// Relay_1, Relay_2, Relay_2, SSR_1, SSR_2

localparam TW=368;      // adjust this to change size of train widths dynamically. note, for the constatns you will have to manually adjust this...
localparam TW2=176;
localparam SCLK_SPEED=3;
localparam SDI_SIZE=16;
localparam SCLK_IDLE=0; // do you want sclk to idle HIGH (set to 1) or LOW (set to 0)


//=============================================================================
// SPI clock control : set SPI clock period
//============================================================================= fast chip, sclk_period > 38.4ns
reg [7:0] drive8_reg, drive8_reg2;
reg new_drive;
reg [SCLK_SPEED:0] spi_count; // 125 MHZ / Full scale of SPI_COUNT
wire spi_clock;
    always@(posedge clock) begin
        spi_count = spi_count + 1;
//        drive8_reg = drive8;
    end
assign spi_clock = spi_count[SCLK_SPEED];

//=============================================================================
// The simplest & most silly spi pulse train that you have hopefully ever seen
//=============================================================================
reg [SDI_SIZE-1:0] sdibuffer;
reg [TW-1:0]  MOSI,  CSN,  STROBE;
reg [TW2-1:0] MOSI2, CSN2, STROBE2;
reg [SDI_SIZE-1:0] config04_reg, config0b_reg, config0c_reg, config0e_reg, config0f_reg, sense8_reg, drive8_rb_reg; // buffer for output registers
reg [7:0] tracker; // tracker to watch and increment when the strobe goes high. will be a number corresponding to which register has been read
reg [1:0] ctrl_last, ctrl_reg;
//wire [15:0] drive_sel;
//assign drive_sel = (new_drive)? 16'h0000 : 16'hffff; // if new drive, don't mask out csn, otherwise keep csn high for this transction
reg [3:0] state, state_last;

wire correctStrobe_1;
wire correctStrobe_2;

assign correctStrobe_1  = (((tracker==0) || (tracker==1) || (tracker==2) || (tracker==3) || (tracker==4)) && (STROBE[TW-1] == 1) && (STROBE[TW-2] == 0))? 1'b1 : 1'b0;
assign correctStrobe_2  = (((tracker==5) || (tracker==6)) && (STROBE2[TW2-1] == 1) && (STROBE2[TW2-2] == 0))? 1'b1 : 1'b0;

always@(negedge spi_clock) begin
    //
    //
    ctrl_reg  <= ctrl;
    ctrl_last <= ctrl_reg;
    //
    state_last <= state;
    if (reset_n==1'b0) begin
        state       <= 0;
        CSN         <= 0;
        MOSI        <= 0;
        STROBE      <= 0;
        CSN2        <= 0;
        MOSI2       <= 0;
        STROBE2     <= 0;
        drive8_reg2 <= 0;
        drive8_reg  <= 0;
    end else if (state==0) begin
        if (ctrl_reg[1]==1'b1) begin // wait for SM to come out of reset command
            state <= 1;
        end else begin
            state <=0;
        end
        // reset all of the pre-staged spi comms
        CSN    <= {16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,16'hffff};
        MOSI   <= {16'h0000,16'h0401,16'h0000,16'h0b55,16'h0000,16'h0ca9,16'h0000,16'h0eaa,16'h0000,16'h0faa,16'h0000,16'h8400,16'h0000,16'h8b00,16'h0000,16'h8c00,16'h0000,16'h8e00,16'h0000,16'h8f00,16'h0000,16'h0000,16'h0000};
        STROBE <= {16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h0000,16'h8000,16'h0000,16'h8000,16'h0000,16'h8000,16'h0000,16'h8000,16'h0000,16'h8000};   
        //                                                                                             v   84_data            8b_data           8c_data           8e_data            8f_data
        CSN2   <= {16'hffff,16'h0000,16'hffff,16'hffff,        16'hffff,16'h0000,16'hffff};
        MOSI2  <= {16'hffff,16'hda00,16'hffff,8'h4c,drive8_reg2,16'hffff,16'hcc00,16'hffff};
         //                 read_x5a            write_x4c
         //ports 25 thru 31 are bits 0 thru 5
         //                                     pots 12 through 19
        STROBE2<= {16'h0000,16'h0000,16'h0000,16'h0000,         16'h8000,16'h0000,16'h0000};
        //                                     sense_readback   
    end else if (state==1) begin
        if (ctrl_reg[1]==1'b0) begin
            // if ever ctrl[1] goes low, we treat this as a soft reset request
            state <= 0;
        end else begin
            state <= 1;
            if (((tracker==8'h00) || (tracker==8'h01) || (tracker==8'h02) || (tracker==8'h03) || (tracker==8'h04)) && (ctrl_reg[0]==1'b1))  begin
                CSN      <=   {CSN[TW-2:0],      CSN[TW-1]};
                MOSI     <=   {MOSI[TW-2:0],     MOSI[TW-1]};
                STROBE   <=   {STROBE[TW-2:0],   STROBE[TW-1]};
            end else if (((tracker==8'h05) || (tracker==8'h06)) && (ctrl_reg[0]==1'b1))  begin
                CSN2      <=   {CSN2[TW2-2:0],      CSN2[TW2-1]};
                MOSI2     <=   {MOSI2[TW2-2:0],     MOSI2[TW2-1]};
                STROBE2   <=   {STROBE2[TW2-2:0],   STROBE2[TW2-1]};
            end else if (tracker==8'h07) begin
                CSN2   = {16'hffff,16'h0000,16'hffff,16'h0000,16'hffff,16'h0000,        16'hffff,16'h0000,16'hffff,16'h0000,16'hffff};
                // Note, read the sense register twice. Reads requests are answered on the next cycle
                //                   Req read          data_read
                MOSI2  = {16'hffff,8'h4c,drive8_reg,16'hffff,16'hda00,16'hffff,16'hcc00,16'hffff,16'hcc00,16'hffff,16'hffff,16'hffff};
                STROBE2= {16'h0000,16'h0000,        16'h0000,16'h0000,16'h0000,16'h0000,16'h8000,16'h0000,16'h8000,16'h0000,16'h0000};
                drive8_reg  <= drive8;
                drive8_reg2 <= drive8_reg; // get last drive register value for the next time tracker==7
            end
       end // end ctrl[1] check
   end //end reset, state check
end // end process


//=============================================================================
// Use STOBRE and tracker to know which register we are reading back
//============================================================================= ?? data sheet makes it look like we need to shift in LSB *after* the last bit
always@(negedge spi_clock) begin

    sdibuffer <= {sdibuffer[SDI_SIZE-1:0],sdi}; // bring the MISO into a shift register
    if (state==0) begin
        tracker <= 0;
    end else if (tracker==7 && ctrl_reg[0]==1'b1 && ctrl_last[0]==1'b0) begin
        tracker <= 5;
    end else begin
         // note, tracker state 7 will not have a strobe, this is only to reset the SM. we treat tracker==7 as a stobe signal
         if (correctStrobe_1 || correctStrobe_2 || tracker==7) begin // when HI, we just finished reading a register
            case (tracker)
                    8'h00  : begin config04_reg  <= sdibuffer; tracker <= 1; end 
                    8'h01  : begin config0b_reg  <= sdibuffer; tracker <= 2; end
                    8'h02  : begin config0c_reg  <= sdibuffer; tracker <= 3; end
                    8'h03  : begin config0e_reg  <= sdibuffer; tracker <= 4; end
                    8'h04  : begin config0f_reg  <= sdibuffer; tracker <= 5; end
                    8'h05  : begin sense8_reg    <= sdibuffer; tracker <= 6; end
                    8'h06  : begin drive8_rb_reg <= sdibuffer; tracker <= 7; end
                    8'h07  : begin                             tracker <= 7; end // stay here until a new ctrl[0] pulse comes in
                    default: begin tracker <= 0; end  
            endcase 
        end
    end
end

wire sel_io;
assign sel_io = ((tracker==8'h05)||(tracker==8'h06)||(tracker==8'h07))? 1'b1 : 1'b0;
assign ready  = (tracker==8'h07)? 1'b1 : 1'b0;

// assign output registers
assign config04  = config04_reg;
assign config0b  = config0b_reg;
assign config0c  = config0c_reg;
assign config0e  = config0e_reg;
assign config0f  = config0f_reg; 
assign sense8    = sense8_reg;
assign drive8_rb = drive8_rb_reg;
 
// spi signals
assign sclk     = ((CSN2[TW2-1] && sel_io) || (CSN[TW-1] && ~sel_io))? SCLK_IDLE : spi_clock;
assign csn      = (sel_io)? CSN2[TW2-1]  : CSN[TW-1];
assign sdo      = (sel_io)? MOSI2[TW2-1] : MOSI[TW-1];
       
//       ila_5 ila_5_inst1 (
//        .clk(clock),
//        .probe0(config04_reg),
//        .probe1(config0b_reg),
//        .probe2(config0c_reg),
//        .probe3(config0e_reg),
//        .probe4(config0f_reg),
//        .probe5(drive8_reg),
//        .probe6(drive8_rb_reg),
//        .probe7(csn),
//        .probe8(sclk),
//        .probe9(sdi),
//        .probe10(sdo));


//    ila_0 ila_inst (
//    .clk(clock),
//    .probe0(csn),
//    .probe1(sclk),
//    .probe2(sdo),
//    .probe3(sdi),
//    .probe4(ctrl_reg),
//    .probe5(tracker),
//    .probe6(state),
//    .probe7(sense8_reg),
//    .probe8(drive8_rb_reg)
//    );
    
    


endmodule