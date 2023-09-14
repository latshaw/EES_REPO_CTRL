
    (*altera_attribute = "-name INTERFACE_TYPE \"altera:instrumentation:fabric_monitor:1.0\" -section_id ***reserved_a10_xcvr***; -name INTERFACE_ROLE \"altera_clk_user\" -to \"altera_clk_user\" -section_id ***reserved_a10_xcvr***;\
-name INTERFACES \"\
    {\
        'version' : '1',\
        'interfaces' : [\
            {\
                'type' : 'altera:instrumentation:fabric_monitor:1.0',\
                'ports' : [\
                    {\
                        'name' : 'altera_clk_user',\
                        'role' : 'altera_clk_user'\
                    }\
                ],\
                'parameters' : [\
                    {\
                        'name' : 'SECTION_ID',\
                        'value' : '***reserved_a10_xcvr***'\
                    }\
                ]\
            }\
        ]\
    }\
    \" -to |;\
-name SDC_STATEMENT \"if { [get_collection_size [get_pins -compatibility_mode -nowarn ~ALTERA_CLKUSR~~ibuf|o]] > 0 } { create_clock -name ~ALTERA_CLKUSR~ -period 8 [get_pins -compatibility_mode -nowarn ~ALTERA_CLKUSR~~ibuf|o] }\"" *)

module alt_sld_fab_0_altera_a10_xcvr_reset_sequencer_181_qo5sgxi (
    input wire altera_clk_user,
    input wire clk_in_0,  // Unused (this is part of a reset ep configured which isn't configured as a clock input)
    input  wire reset_req_0,
    output wire reset_out_0,
    input wire clk_in_1,  // Unused (this is part of a reset ep configured which isn't configured as a clock input)
    input  wire reset_req_1,
    output wire reset_out_1
);
    
wire [2-1:0] reset_req;
wire [2-1:0] reset_out;

// Assgnments to break apart the bus
assign reset_req[0]  = reset_req_0;
assign reset_out_0  = reset_out[0];
assign reset_req[1]  = reset_req_1;
assign reset_out_1  = reset_out[1];

  wire altera_clk_user_int;
  twentynm_oscillator ALTERA_INSERTED_INTOSC_FOR_TRS
  (
    .clkout(altera_clk_user_int),
    .clkout1(),
    .oscena(1'b1)
  );

altera_xcvr_reset_sequencer
#(
  .CLK_FREQ_IN_HZ              ( 125000000 ),
  .RESET_SEPARATION_NS         ( 200       ),
  .NUM_RESETS                  ( 2    )              // total number of resets to sequence
                                                     // rx/tx_analog, pll_powerdown
) altera_reset_sequencer (
  // Input clock
  .altera_clk_user             ( altera_clk_user_int ),       // Connect to CLKUSR
  // Reset requests and acknowledgements
  .reset_req                   ( reset_req       ),
  .reset_out                   ( reset_out       ) 
);
endmodule
