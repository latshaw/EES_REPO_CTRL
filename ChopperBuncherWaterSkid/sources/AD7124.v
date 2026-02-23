//3/6/2025
//JAL
//The Module will be in reset while ctrl is 0.
// once ctrl is not 0, then a pulse train will start which will reet the adc, set and readback registeers. These are the TW values.
// while the TW train is being sent, there will be an initDone traing filling up with 1's
// once initDone is full of 1's the TW train will freeze and the TW2 train will begin
// The TW2 train will read the 24 bit RTD data.

// Attempting to configure the internal registers in this way
// x01 adc control, cont sample, full pwoer mode, internal clock                                           x01c0                    
// x03 IO control, 100 uA, on AIN0 and AIN2                                                                x0?01204
// x09 Channel 0, enabled, AINP = AIN1, AINM = AIN3                                                        x8023
// x19 Config 1, lowest burn out current, buffer all, REFIN+/- selected, unipolar,  PGA gain=2             x01E1

// after reset of chip, it requires 90 MCLK tics to reset.
// MCLK depends on power mode (for slowest, 90/76.8khz = 1.18 ms to reset)
// so pick SPI clock divider to be such that a few spi clock periods will be 1.18 ms...
// eval boad has 'long sclk HI' pulses for each 8th, 16th pulse... and somtimes once every 16 for 24 bit signals
// seems to help
//
module AD7124(
    input  clock,
    input  reset_n,
    output csn,
    output sclk,
    input  sdi, // MISO, falling edge of SCLK
    output sdo, // MOSI, rising edge of SCLK
    output [23:0] data24_status,   //x00
    output [23:0] data24_adc_ctrl, //x01
    output [23:0] data24_ID,       //x05
    output [23:0] data24_IO_ctrl,  //x03
    output [23:0] data24_chn0,     //x09
    output [23:0] data24_config0,  //x19
    output [23:0] data24_data,     //x02
    input  [1:0]  ctrl, 
    output [15:0] state_out,
    output done
    );

// The rules for this chip...
// SPI mode 3, data goes out on falling edge, sampled on rising edge
// 64 sclk tics with MOSI=1 will reset the chip. Allow 5 micro seconds after this reset event. 
// SCLK HI time/LOW time must be a min of 100ns.
////
///
//
parameter spiClkDiv = 4;
reg [spiClkDiv-1:0] spi_count;
wire spi_clock;
always@(posedge clock) begin
    spi_count = spi_count + 1;
end // end process
assign spi_clock = spi_count[spiClkDiv-1];
//
///
//// 
////
///
//

// new data is available after the falling edge.
// for the last bit, the miso will go high very shortly after the rising edge of sclk.
// this is why we have this snippet of code to capture the miso shortly after it is set but before it idles
reg [1:0] spiEdge, ctrl_last, ctrl_reg;
reg sdiReg;
wire sdiWire;
always@(posedge clock) begin
        spiEdge <= {spiEdge[0], spi_clock};
        sdiReg  <= sdiWire;
end
assign sdiWire = (spiEdge == 2'b01)? sdi : sdiReg;

reg  [23:0] data24_statusR, data24_adc_ctrlR, data24_IDR, data24_IO_ctrlR, data24_chn0R, data24_config0R, data24_dataR;    
wire [23:0] data24_statusD, data24_adc_ctrlD, data24_IDD, data24_IO_ctrlD, data24_chn0D, data24_config0D, data24_dataD;    

reg [31:0] sleeper;

reg  [91:0] profile, mask, status, load;
wire [91:0] profiled;
reg  [7:0] profileCount;
reg  [3:0] state, lastState;

reg dataNotReady;

always@(posedge spi_clock) begin
    //
    ctrl_reg  <= ctrl;
    ctrl_last <= ctrl_reg;
    //
    if (state == 0) begin
        if (ctrl_reg[1] == 1'b1) begin
            state = 1;
            profileCount <= 0;
        end else begin
            state = 0;
            profileCount <= 0;
        end
        sleeper <= 0;
    end else if (state == 1) begin 
        ////// case statement which picks between 'profiles'
        case (profileCount)
            8'h00  : begin profile <= 92'hfffffffffffffffffffffff; // reset
                           mask    <= 92'h00f00f00f00f00f00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h01  : begin profile <= 92'h000000000000000010000C0; // reg  1, adc control x01c0 was h000000000000000010010C0. turned off internal ref
                           mask    <= 92'hfffffffffffffff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end                        
            8'h02  : begin profile <= 92'h0000000000000300001200A; // reg  3, io control x001204 was (on left) now AIN4 is is on and both current sources at 750 uA
                           mask    <= 92'hffffffffffff00f00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end            
            8'h03  : begin profile <= 92'h00000000000000009080023; // reg  9, channel0 x8023
                           mask    <= 92'hfffffffffffffff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end          
            8'h04  : begin profile <= 92'h000000000000000190010E1; // reg  19, config0 x01E1
                           mask    <= 92'hfffffffffffffff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end              
            8'h05  : begin profile <= 92'h00000000000000000045000; // reg  5, read id register 2
                           mask    <= 92'hffffffffffffffffff00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h06  : begin profile <= 92'h00000000000000041000000; // reg  1, read
                           mask    <= 92'hfffffffffffffff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h07  : begin profile <= 92'h00000000000043000000000; // reg  3, read
                           mask    <= 92'hffffffffffff00f00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h08  : begin profile <= 92'h00000000000000049000000; // reg  9, read
                           mask    <= 92'hfffffffffffffff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h09  : begin profile <= 92'h00000000000000059000000; // reg  19, read
                           mask    <= 92'hfffffffffffffff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h0a  : begin profile <= 92'h00000000000000000040000; // reg  0, status register
                           mask    <= 92'hffffffffffffffffff00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end 
            8'h0b  : begin profile <= 92'h00000000000420000000000; // reg  2, read the data off of reg 2
                           mask    <= 92'hfffffffffff00ff00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
            8'h0c  : begin profile <= 92'hfffffffffffffffffffffff; // go to done
                           mask    <= 92'h00f00f00f00f00f00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 8;
                        end
            default: begin profile <= 92'hfffffffffffffffffffffff; // default state
                           mask    <= 92'h00f00f00f00f00f00f00f00;
                           status  <= 92'h00000000000000000000000;
                           load    <= 92'hfffffffffffffffffffffff;
                           state   <= 2;
                        end
         endcase
        //////
    end else if (state == 2) begin // sclk low
        state <= 3;
    end else if (state == 3) begin // sclk high
        load    <= {load[90:0], sdiReg};
        profile <= {profile[90:0], 1'b0};
        status  <= {status[90:0], 1'b1};
        mask    <= {mask[90:0], 1'b1};
        if (&status) begin // reduction operator, if status is all 1's
            state <= 4;
        end else begin
            state <= 2;
        end
    end else if (state == 4) begin // save load and sclk high
        state   <= 5;
        sleeper <= 0;
    end else if (state == 5) begin // sleep
        if (profileCount == 0) begin
            if( sleeper <= 5000) begin
                sleeper <= sleeper + 1;
                state <= 5;
            end else begin 
                state <= 6;
            end
        end else begin
            state <= 6;
//            if( sleeper <= 100) begin
//                sleeper <= sleeper + 1;
//                state <= 5;
//            end else begin 
//                state <= 6;
//            end
        end        
    end else if (state == 6) begin // increment profile 
        if ((dataNotReady) && (profileCount == 10)) begin // after reading status register, check dataNotReady bit
            profileCount <= 10; // if new data is not ready, keep reading status register until it is ready
        end else begin
            profileCount <= profileCount + 1;
        end
        state <= 7;
    end else if (state == 7) begin // sleep more
        state <= 1;
    end else if (state == 8) begin // wait until next take
        if (ctrl_reg[1]==1'b1 && ctrl_last[1]==1'b0) begin // RE, of init (reset) bit
            state        <= 0;
            profileCount <= 0;
        end else if (ctrl_reg[0]==1'b1 && ctrl_last[0]==1'b0) begin // RE, take bit
            state        <= 1;
            profileCount <= 1;
        end else begin
            state        <= 8;   
            profileCount <= 0;
        end
    end else begin
        state <= 0;
    end
    
    //in always statment, register wires
    data24_statusR   <= data24_statusD;
    data24_adc_ctrlR <= data24_adc_ctrlD;
    data24_IDR       <= data24_IDD;
    data24_IO_ctrlR  <= data24_IO_ctrlD;
    data24_chn0R     <= data24_chn0D;
    data24_config0R  <= data24_config0D;
    data24_dataR     <= data24_dataD;
    dataNotReady     <= data24_statusR[7];
end

// mux, if in save state and profile count matches, set wire to load, else keep last registered value
assign data24_IDD       = ((state == 4) && (profileCount == 5))?  {16'h0000, load[8:1]}                  : data24_IDR;
assign data24_adc_ctrlD = ((state == 4) && (profileCount == 6))?  {8'h00, load[20:13], load[8:1]}        : data24_adc_ctrlR;
assign data24_statusD   = ((state == 4) && (profileCount == 10))? {16'h0000, load[8:1]}                  : data24_statusR;
assign data24_IO_ctrlD  = ((state == 4) && (profileCount == 7))?  {load[32:25], load[20:13], load[8:1]}  : data24_IO_ctrlR;
assign data24_chn0D     = ((state == 4) && (profileCount == 8))?  {8'h00, load[20:13], load[8:1]}        : data24_chn0R;
assign data24_config0D  = ((state == 4) && (profileCount == 9))?  {8'h00, load[20:13], load[8:1]}        : data24_config0R;
assign data24_dataD     = ((state == 4) && (profileCount == 11))? {load[32:25], load[20:13], load[8:1]}  : data24_dataR;
// assign actual module outputs (wires)
assign data24_status   = data24_statusR;
assign data24_adc_ctrl = data24_adc_ctrlR;
assign data24_ID       = data24_IDR;
assign data24_IO_ctrl  = data24_IO_ctrlR;
assign data24_chn0     = data24_chn0R;
assign data24_config0  = data24_config0R;
assign data24_data     = data24_dataR;

//
///
////
////
///
//
// note, for profileCoutn xb and xc we will keep csn low
assign csn  = ((state==2) || (state==3))? 1'b0 : 1'b1;
//assign csn  = (state ==8)? 1'b1: 1'b0;
assign sclk = (state==2)? mask[91] : 1'b1;
assign sdo  = profile[91];
assign done = (state ==8)? 1'b1: 1'b0;
//
///
////

//ila_3 ila_inst (
//.clk(clock),
//.probe0(ctrl_last),
//.probe1(ctrl_reg),
//.probe2(state),
//.probe3(profileCount),
//.probe4(data24_dataR),
//.probe5(done),
//.probe6(data24_statusR)
//);

endmodule