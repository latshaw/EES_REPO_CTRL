// JAL
// low pass filter, IIR Transposed DIrect Form II
// should work for a variety of input clocks.
// target application is for only acting on slow moving faults (such as temperature monitoring channels, or de-glitch spikes)
//
// In verilog, all singed math must be called out as signed. Both products in any operation must be signed
// otherwise the tools will assume you wanted an unsigned output
//
// Here are some notes on fixed point math:
//   Ux.Y means unsigned, x integer bits and Y fractional bits
//   Ux1.Y1 * Ux2.Y2 = U(x1+x2).(y1+y2)
//   rules about 2's complement hold true, despite fractional bits
//   when you truncate integer of fractional bits these rules apply.
//       1) You can always drop fractional bits and only lose that information (never round so we avoid limit cycling) 
//       2) If you want to truncate integer bits, you must take the sign into account. 
//					if MSbit = 0 and the other bits that you want to truncate plus the new MSbit are ALL NOT 0, then set to postive full scale
//             if MSbit = 1 and the other bits that you want to truncate plus the new MSbit are ALL NOT 1, then set to negative full scale
//
//  Note, the lb_clk (fast clock) must be 3 times as fast as the strobe pulse rate (the sample clock).
//
module iir_lpf (
	// Global signals
	input lb_clk,
	input reset_n,
	input strobe,
	input  [15:0] x, // 16 bit input    U16.0
	output [15:0] y  // 16 bit output
  );
  
  // strobe RE
  reg [1:0] strobe_pulse;
  
  // coefficients for 'a' and 'b' weights
  wire signed [18:0] a1, a2;      // U3.16
  wire signed [18:0] b0, b1, b2;  // U3.16
  wire signed [34:0] x_fi, y_clip;// defined to be U19.16
  reg  signed [53:0] v1, v2, yq;  // defined to be U19.16
  wire signed [53:0] v1_d, v2_d, y_d;
  wire signed [53:0] b0x_d, b1x_d, b2x_d, a1y_d, a2y_d;  // U22.32, after multiplying U3.16 * U19.16
  reg  signed [53:0] b0x, b1x, b2x, a1y, a2y;  
  //format for output, back to U16.0
  wire [15:0] y_frmt_d;
  reg  [15:0] y_frmt;

  //
  // note, some of these coefficients are negative. you can use matlab to find these (ignore a0=1 value) : [b,a] = butter(2,.01)
  // U3.16
  assign a1 = {3'b110, 16'h0B5E}; // a negative number
  assign a2 = {3'b000, 16'hF4DD}; 
  //
  assign b0 = {3'b000, 16'h0010};
  assign b1 = {3'b000, 16'h0020};
  assign b2 = {3'b000, 16'h0010}; 
  //
  // target will be U(3+16).(16+0) = U19.16
  assign x_fi = {{3{x[15]}} ,x, 16'h0000}; // sign extend MSbit, added fractional bits are zeros  U16.0 -> U19.16
  
  //below maths become U21.32
  assign b0x_d = x_fi*b0; // U19.16 * U3.16 = U21.32
  assign b1x_d = x_fi*b1;
  assign b2x_d = x_fi*b2;
  assign a1y_d = y_clip*a1; // y_clip is U19.16
  assign a2y_d = y_clip*a2;
  
  //below maths are in U21.32
  // consult the IIR Transposed Direct form II.
  // note the v1, v2 are only latched on a stobre RE pulse.
  assign y_d  = b0x + v1; 
  assign v1_d = (strobe_pulse==2'b01)? v2 + b1x -a1y : v1;
  assign v2_d = (strobe_pulse==2'b01)? b2x -a2y : v2;
  
  // tread carefully, for the a * y. We need to truncate y so that it is in U19.16 to keep the other maths simple.
  // this involves throwing away 16 fractional bits and 3 integer bits.
  // truncate U21.32 to be U19.16
  // clip check upper bits. Will set to +/-full scale to prevent overflow
  // truncate lower bits
  assign y_clip =   (yq[53] == 1'b0 & yq[52:50] !== 3'b000)? {3'b011, 32'hffffffff} : 
                    (yq[53] == 1'b1 & yq[52:50] !== 3'b111)? {3'b100, 32'h00000000} : yq[50:16];
  
  // the below format the data for output from the module
  //truncate U21.32 into U16.0
  // truncate lower 32 fractional bits
  // clip check upper bits. Will set to +/-full scale to prevent overflow
  // truncate lower bit
  assign y_frmt_d = (yq[53] == 1'b0 & yq[52:47] !== 6'b000000)? {16'h7fff} : 
                    (yq[53] == 1'b1 & yq[52:47] !== 6'b111111)? {16'h8000} : yq[47:32];
  //
  //to help make this module synth without needing to add multi cycling, I have buffered
  //some of the key multicplations with the fast clock. This module assumes that the
  // fast clock is much much faster than the sample clock (the strobe pulse rate).
  always@(posedge lb_clk) begin 
		if (reset_n == 1'b0) begin
			b0x   <= 0;
			b1x   <= 0;
			b2x   <= 0;
			a1y   <= 0;
			a2y   <= 0;
			v1    <= 0;
			v2    <= 0;
			y_frmt<= 0;
			yq    <= 0;
			strobe_pulse <= 0;
		end else begin 
			b0x   <= b0x_d;
			b1x   <= b1x_d;
			b2x   <= b2x_d;
			a1y   <= a1y_d;
			a2y   <= a2y_d;
			v1    <= v1_d;
			v2    <= v2_d;
			y_frmt<=y_frmt_d;
			yq    <= y_d;
			strobe_pulse <= {strobe_pulse[0], strobe};
		end
  end
  

  //assign output
  assign y = y_frmt;
  
  
endmodule












