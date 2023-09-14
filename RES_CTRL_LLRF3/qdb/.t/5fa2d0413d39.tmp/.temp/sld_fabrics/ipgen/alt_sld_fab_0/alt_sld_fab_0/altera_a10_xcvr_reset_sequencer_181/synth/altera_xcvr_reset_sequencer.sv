// (C) 2001-2018 Intel Corporation. All rights reserved.
// Your use of Intel Corporation's design tools, logic functions and other 
// software and tools, and its AMPP partner logic functions, and any output 
// files from any of the foregoing (including device programming or simulation 
// files), and any associated documentation or information are expressly subject 
// to the terms and conditions of the Intel Program License Subscription 
// Agreement, Intel FPGA IP License Agreement, or other applicable 
// license agreement, including, without limitation, that your use is for the 
// sole purpose of programming logic devices manufactured by Intel and sold by 
// Intel or its authorized distributors.  Please refer to the applicable 
// agreement for further details.


`timescale 1ps/1ps
module altera_xcvr_reset_sequencer
#(
    parameter CLK_FREQ_IN_HZ      = 100000000,
    parameter RESET_SEPARATION_NS = 100,
    parameter NUM_RESETS          = 1 // total number of resets to sequence
                                      // rx/tx_analog, pll_powerdown
) (
    // Input clock
    input                     altera_clk_user,      // Connect to CLKUSR
    // Reset requests and acknowledgements
    input   [NUM_RESETS-1:0]  reset_req,
    output  [NUM_RESETS-1:0]  reset_out
);

// Determine needed size for scheduling counter
localparam  SCHED_COUNT_MAX   = NUM_RESETS-1;
localparam  SCHED_COUNT_SIZE  = clogb2(NUM_RESETS-1);
localparam  [SCHED_COUNT_SIZE-1:0] SCHED_COUNT_ADD = {{SCHED_COUNT_SIZE-1{1'b0}},1'b1};

// These parameters calculate the counter width and count for reset separation
localparam  [63:0] INITIAL_COUNT  = (CLK_FREQ_IN_HZ * RESET_SEPARATION_NS) / 1000000000;

// Round counter limit up if needed
localparam  [63:0] ROUND_COUNT    = (((INITIAL_COUNT * 1000000000) / CLK_FREQ_IN_HZ) < RESET_SEPARATION_NS)
                            ? (INITIAL_COUNT + 1) : INITIAL_COUNT;

// Use given counter limit if provided (RESET_COUNT), otherwise use calculated counter limit
localparam  RESET_COUNT_MAX   = ROUND_COUNT - 1;
localparam  RESET_COUNT_SIZE  = clogb2(RESET_COUNT_MAX);
localparam  [RESET_COUNT_SIZE-1:0] RESET_COUNT_ADD   = {{RESET_COUNT_SIZE-1{1'b0}},1'b1};


// Need to self-generate internal reset signal
(*preserve*) reg reg1 = 1'b1;
wire  reset_n;

// Synchronized reset_req inputs
wire  [NUM_RESETS-1:0]  reset_req_sync;

// Reset output registers (must be synchronized at destination logic)
reg   [NUM_RESETS-1:0]  reset_out_reg;
reg   [NUM_RESETS-1:0]  reset_out_stage;
wire  reset_match;    // determines if scheduled input matches output

// Round robin scheduling counter
reg   [SCHED_COUNT_SIZE-1:0]  sched_counter;
wire  sched_timeout;  // time to advance schedule counter

// Delay counter (for staggering reset outputs)
reg   [RESET_COUNT_SIZE-1:0]  reset_counter;
wire  reset_timeout;  // time to restart reset separation counter

//***************************************************************************//
//*********************** Internal reset generation *************************//
alt_xcvr_resync #(
  .SYNC_CHAIN_LENGTH(3),
  .INIT_VALUE(0)
  ) reset_n_generator (
    .clk    (altera_clk_user),
    .reset  (1'b0           ),
    .d      (reg1           ),
    .q      (reset_n        )
);
//********************* End Internal reset generation ***********************//
//***************************************************************************//



//***************************************************************************//
//********************* Reset input synchronization *************************//
alt_xcvr_resync #(
  .SYNC_CHAIN_LENGTH(3),
  .WIDTH(NUM_RESETS),
  .INIT_VALUE(0)
  ) reset_req_synchronizers (
    .clk    (altera_clk_user),
    .reset  (~reset_n       ),
    .d      (reset_req      ),
    .q      (reset_req_sync )
  );

//******************* End reset input synchronization ***********************//
//***************************************************************************//

//***************************************************************************//
//************************* Reset sequencer logic ***************************//
assign  reset_match = reset_out_reg[sched_counter] == reset_req_sync[sched_counter];
assign  reset_timeout = reset_counter == RESET_COUNT_MAX;
assign  sched_timeout = sched_counter == SCHED_COUNT_MAX;

assign	reset_out = reset_out_stage;
// Scheduler, reset counter, and output register logic
always @(posedge altera_clk_user or negedge reset_n)
  if(~reset_n) begin
    reset_out_reg   <= {NUM_RESETS{1'b0}};
    sched_counter   <= {SCHED_COUNT_SIZE{1'b0}};
    reset_counter   <= {RESET_COUNT_SIZE{1'b0}};
  end else begin
    if(reset_timeout || reset_match) begin

      // Update the scheduled output to match the input
      reset_out_reg[sched_counter]  <= reset_req_sync[sched_counter];

      // reset the separation counter
      reset_counter <= {RESET_COUNT_SIZE{1'b0}};

      // advance the schedule counter
      if(sched_timeout)
        sched_counter <=  {SCHED_COUNT_SIZE{1'b0}}; 
      else
        sched_counter <=  sched_counter + SCHED_COUNT_ADD;
    end else begin
      reset_counter <= reset_counter + RESET_COUNT_ADD;
    end
  end

// Add register stage
always @(posedge altera_clk_user) begin
  reset_out_stage <= reset_out_reg;
end

//*********************** End Reset sequencer logic *************************//
//***************************************************************************//

////////////////////////////////////////////////////////////////////
// Return the number of bits required to represent an integer
// E.g. 0->1; 1->1; 2->2; 3->2 ... 31->5; 32->6
//
function integer clogb2;
  input integer input_num;
  begin
    for (clogb2=0; input_num>0 && clogb2<256; clogb2=clogb2+1)
      input_num = input_num >> 1;
    if(clogb2 == 0)
      clogb2 = 1;
  end
endfunction

endmodule
