// James Latshaw
// 2/14/2025
// target chip is ADC1245SC
// simple spi interface. ADC has 4 registers which can be accessed by changing the command bit. 
// Change the command bit to set what will be read during the next cycle
// ->take data from miso after rising edge of sclk
// ->ensure mosi data is stable before rising edge of sclk
// ->sclk is recommended 3.2 to 8 MHz : for sclk, we 9 fast clock ticks low and 9 high -> 1/144ns -> 6.9 MHz clock rate (or a little slower)
// -> written for a target system clock of 125 MHz.
//
module ADC1245S(
    input clock,
    input reset_n,
    input enable,
    output csn,
    output sclk,
    output mosi,
    input miso,
    output [11:0] data1,
    output [11:0] data2,
    output [11:0] data3,
    output [11:0] data4,
    output ready
    );
//
//=============================================================================
// Core State Machine
//============================================================================= 
//
reg first, enable_last; // don't keep the first set of reads
wire first_d;
reg [1:0] cmd_count;
wire [1:0] cmd_count_d;
reg [7:0] state, state_last, delay_done, bit_count;
wire [7:0] delay_done_d, bit_count_d;
reg [7:0] state_d; // technically this will be used for combinational logic
wire [15:0] cmd_mux, cmd_d;
reg [3:0] state_count;
wire [3:0] state_count_d;
reg get_MISO, set_MOSI, en, done;
wire get_MISO_d, set_MOSI_d, enable_d, done_d;
(* dont_touch = "yes" *)  reg [15:0] MOSI_SR, MISO_SR, cmd;
wire [15:0] MOSI_SR_d, MISO_SR_d, CMD_d;
reg [11:0]  dout1, dout2, dout3, dout4;
wire [11:0] dout1_d, dout2_d, dout3_d, dout4_d;
wire load_new; // just to simplify the logic for loading in a new command
//
//

//
//
reg SCLK_bug, MOSI_bug, MISO_bug, CS_bug;
wire SCLK_bugd, MISO_bugd, CS_bugd;
always@(posedge clock) begin
    SCLK_bug <= SCLK_bugd;
    MOSI_bug <= MOSI_SR[15];
    MISO_bug <= MISO_bugd;
    CS_bug   <= CS_bugd;
    if (reset_n == 1'b0) begin
        state      <= 0;
        MOSI_SR    <= 0;
        MISO_SR    <= 0;
        en         <= 0;
        done       <= 0;
        dout1      <= 0;
        dout2      <= 0;
        dout3      <= 0;
        dout4      <= 0;
        delay_done <= 0;
        cmd_count  <= 0;
        bit_count  <= 0;
        cmd        <= 0;
        first      <= 0;
        enable_last<= 0;
        state_last <=0;
   end  else begin
        state      <= state_d;
        MOSI_SR    <= MOSI_SR_d;
        MISO_SR    <= MISO_SR_d;
        en         <= enable_d;
        done       <= done_d;
        dout1      <= dout1_d;
        dout2      <= dout2_d;
        dout3      <= dout3_d;
        dout4      <= dout4_d;
        delay_done <= delay_done_d;
        bit_count  <= bit_count_d;
        cmd_count  <= cmd_count_d;
        cmd        <= cmd_d;
        first      <= first_d;
        state_last <= state;
        enable_last<= en;
    end
end // end process
//
// main state machine, comibational logic
always @ (en, state, delay_done, bit_count, enable_last) begin
    case(state)
      8'h00  : ////////////////////////////////////////// IDLE
        if (en) begin
            state_d = 8'h01;
        end else begin
            state_d = 8'h00;
        end
      8'h01  : ////////////////////////////////////////// LOAD COMMAND - increment delay_done
        if (delay_done==8'hff) begin
            state_d = 8'h02;
        end else begin
            state_d = 8'h01;
        end
      8'h02  : ////////////////////////////////////////// SCLK_LOW - increment bit_count
        state_d = 8'h03;
      8'h03  : ////////////////////////////////////////// SCLK_LOW - setup mosi bit
        state_d = 8'h07; 
      8'h07  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h08;
      8'h08  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h09;
      8'h09  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h0A;        
      8'h0A  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h0B;
      8'h0B  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h0C;             
      8'h0C  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h0D;       
      8'h0D  : ////////////////////////////////////////// SCLK_LOW
        state_d = 8'h04;          
      8'h04  : ////////////////////////////////////////// SCLK_HI -- shift in miso bit
        state_d = 8'h0E;
      8'h0E  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h0F;
      8'h0F  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h10;
      8'h10  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h11;
      8'h11  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h12;
      8'h12  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h13;
      8'h13  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h14;
      8'h14  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h15;
      8'h15  : ////////////////////////////////////////// SCLK_HI
        state_d = 8'h05;
      8'h05  : ////////////////////////////////////////// SCLK_HI and CHECK 
        if (bit_count==8'h10) begin
            state_d = 8'h06;
        end else begin
            state_d = 8'h02;
        end
      8'h06  : ////////////////////////////////////////// SAVE  - clear bit_count - increment cmd_count
        if (enable_last == 1'b0 && en == 1'b1 ) begin
            state_d = 8'h01;
        end else begin
            state_d = 8'h06;
        end
      default: 
           state_d = 8'h00;
    endcase
end
//
assign delay_done_d = (state == 8'h01)? delay_done + 1 : 8'h00;//added delay between samples (sometimes required by datasheet)
assign bit_count_d  = (state == 8'h06)? 8'h00 : (state == 8'h02)? bit_count + 1 : bit_count; // used to track which spi bit the state machine is on
assign cmd_count_d = ((state == 8'h01) && (state_last == 8'h06))? cmd_count + 1 : cmd_count; // tracks which of the 4 adc register we are reading. note this will automatically roll over

// note, the cmd_mux is shifted 1 bit to the right since we shift this during the sclk low
// there are four adc registers to read adn can be accessed by feeding x00, x04, x08 or x0C to read adc register 1,2,3 or 4 respectfully
assign cmd_mux = (cmd_count == 2'b00)? 16'h0000 : (cmd_count == 2'b01)? 16'h0400 : (cmd_count == 2'b10)? 16'h0800 : 16'h0C00; 
assign cmd_d = cmd_mux;
//I plan to delete this... not used?
assign first_d = (state==8'h00)? 1'b0 : ((state==8'h06) && (cmd_count==2'b11))? 1'b1 : first; // ignore the first full set of reads
//
// done is set HI if we are in the done/idle state. Used to allow spi bus management to know it is free for another task
assign done_d   = ((state == 8'h00) || (state == 8'h06))? 1'b1 : 1'b0;
// take in the external enable. enable must be HIGH to start the state machine. However, if the
// state machine is currently running, allow it to finishe before taking in the new enable
assign enable_d = enable;//(done)? enable : en; // sync enable with spi clock
//
// Shift registers for mosi and miso data
assign MOSI_SR_d  = (state == 8'h01)? cmd : (state == 8'h03)? {MOSI_SR[14:0],1'b0}: MOSI_SR; // master out, slave in. This is the command to read the register
assign MISO_SR_d  = (state == 8'h01)? 8'h0000 : (state == 8'h04)? {MISO_SR[14:0], miso}: MISO_SR; // shift in MISO, MSBit will be the left most. data from adc
//
// below handles spi bus
assign csn = ((state == 8'h00) || (state == 8'h01) || (state == 8'h06))? 1'b1 : 1'b0;
assign sclk  = ((state == 8'h02) || (state == 8'h03) || (state == 8'h07) || (state == 8'h08) || (state == 8'h09) || (state == 8'h0A) || (state == 8'h0B) || (state == 8'h0C) || (state == 8'h0D))? 1'b0 : 1'b1;
assign mosi = MOSI_SR[15];
//
// Register 12 bit adc output at the end of reading the 16 SCLK tics
// note the cmd determines which input will be converted on the NEXT sample and hold cycle
assign dout1_d  = ((state == 8'h06) && (state_last == 8'h05) && (cmd_count == 2'b01))? MISO_SR[11:0] : dout1;
assign dout2_d  = ((state == 8'h06) && (state_last == 8'h05) && (cmd_count == 2'b10))? MISO_SR[11:0] : dout2;
assign dout3_d  = ((state == 8'h06) && (state_last == 8'h05) && (cmd_count == 2'b11))? MISO_SR[11:0] : dout3;
assign dout4_d  = ((state == 8'h06) && (state_last == 8'h05) && (cmd_count == 2'b00))? MISO_SR[11:0] : dout4;
//
// connect registers to module outputs
assign data1 = dout1;
assign data2 = dout2;
assign data3 = dout3;
assign data4 = dout4;
//
assign ready = (state == 8'h06)? 1'b1 : 1'b0;
//

assign SCLK_bugd = (sclk)? 1'b1 : 1'b0;
assign MISO_bugd = (miso)? 1'b1 : 1'b0;
assign CS_bugd   = (csn)? 1'b1 : 1'b0;

//ila_2 ila_0_inst(.clk(clock), 
//.probe0(CS_bug),
//.probe1(SCLK_bug),
//.probe2(MISO_bug),
//.probe3(MOSI_bug),
//.probe4(dout1),
//.probe5(dout2),
//.probe6(dout3),
//.probe7(dout4),
//.probe8(cmd_count),
//.probe9(state)
//);


// where i left off
// results are different with adn without the ILA module
// i tried to slow don the clock by increasing the duration of the sclk hi and lows so that we math the datasheet's clock range
// now there is lots of noise on the MISO
// at the slower clock rate, we do seem to be more responsive around 0 but also there is LOTS of flicking...
// maube try to just sample channel 1. maybe also try to connect the grounds.

endmodule






























