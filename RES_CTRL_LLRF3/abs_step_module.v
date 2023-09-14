// JAL, 9/6/2023
// Simple module to keep track of absolute steps and to slowly decrement abs steps based on the rate set by asb_steps.

// The Absolute step coutner keeps track of the total number of steps. this is useful to flag over-active tuners.
// if too many steps take place (in either direction) the absolute step counter will exceed a limit which will disable the stepper.
// Even if there is not an over-active tuner, a zone will need to have its counters cleared form time to time. The subtraction feature can
// allow the abs counter to slowly decrement over time, thus saving us from having to manually hit the clear button.

// Noisey zones will accumulate faster than the sub_in rate and will still be flagged.
// If the subtraction feature is not desired to be used, the sub_in value should be set to zero. 

module abs_step_module (
	input clock, // local bus clock, 125 MHz
	input reset, //active low reset, functionly this is a 'clear'
	input count_en, // increment abs step counter
	input [15:0] sub_in, // rate per second to decrement abs step count
	input [31:0] abs_step_in, // input (or current value) of abs_step
	output [31:0] abs_step_out //new value (or output) of abs_step
  );
   
	//Detect a rising edge conditon for the count_enable signal. this indicates that a step has occured
	reg [1:0] count_en_RE;
	wire enable_strobe;
	always@(posedge clock) begin
		count_en_RE = {count_en_RE[0],count_en};
	end
	assign enable_strobe = (count_en_RE == 2'b01)? 1'b1: 1'b0; // when HI, this wire indicates that the abs step counter should be incremented

	// Simple counter to keep timing of when decrements should happen.
   reg [26:0] counter;
  	always@(posedge clock) begin
			if (count_en == 1'b1) begin // reset counter if a new step is detected (this also prevents subtracting steps while the moto is moving).
				counter <= 27'b000000000000000000000000000;
			end else begin
				counter <= counter + 27'b000000000000000000000000001;
			end
	end
	
	wire strobe; // simple time interval tracker
	// strobe will go hi when a time interval has passed (about 1.0737 second).
	// will strobe for 1 clock cycle
	assign strobe = ((counter == 27'b111111111111111111111111111))? 1'b1 : 1'b0;
	
	wire [31:0] decrement, decrement_check;
	wire [31:0] increment;
	wire [31:0] sub_check;
	
	assign sub_check = (sub_in[15] == 1'b1)? 32'h00000000: {16'h0000,sub_in}; ///////////// see if input sub value is negative, if so don't use (set decrement rate to zero)
	assign decrement = (sub_check == 32'h00000000)? (abs_step_in) : (abs_step_in - sub_check); // decrement is current step value minus the decrement rate if not all zeros or negative
	assign decrement_check = (decrement[31] == 1'b1)? 32'h00000000 : decrement; /////////// simple check to make sure that the abs_step coutner will not go negative
	assign increment = abs_step_in + 1; /////////////////////////////////////////////////// increment current step value by 1
	
	reg [31:0] step_q;
	// gated process for determining the next value
	always@(posedge clock) begin
		if (reset == 1'b0) begin///////////////////////////////////////////////////////////////////////////////////////////////////// if reset, set abs_step count to all zeros
			step_q <= 32'h00000000; 
		end else if (enable_strobe == 1'b1) begin /////////////////////////////////////////////////////////////////////////////////// if enable counter rising edge is detected, increment
			step_q <= increment;
		end else if ((enable_strobe == 1'b0) & (strobe == 1'b1) & (decrement_check[31] == 1'b0)) begin // if enable counter is low, and a srobe time interval has passed, decrement
			step_q <= decrement_check;
		end
	end
	
	// assign output
	assign abs_step_out = step_q;
	
	endmodule