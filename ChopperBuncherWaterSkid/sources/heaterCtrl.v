// Heater Control
// 6/13/2025
// The goal of this module is to regulate the heat, as measured by an RTD, by adjusting the duty cycle of the heater.
// The heater is on when a solid state relay (SSR) is turned on. By controlling the on/off times, we can control the heat.
// This module will use dead bands and a simple bang bang controller.
//      This works just like your home HVAC. Once the meaured temperature is BELOW the setpoint, the heater will TURN ON
//      until it is ABOVE the setpoint by some number of counts (determined by the dead band). The delay register can
//      be used to fine tune response. I suppose your home HAVAC might not have a deadband, but the deadband prevents
//      us from constantly cycling the SSR.
//
// Heater: We have no 'cooling' ability. We can only add heat or not add heat (allow things to 'cool off' on their own).
//      Because of this, we want to regulate AT OR ABOVE a set point. Technically, we could be +/- a certain amount around the
//      the setpoint, but we can never actively reduce the temperature.
//
// RTD Input : ensure that a LPF of some sort is filtering the data that is the input to this module. 

module heaterCtrl(
    input  clock,
    input  reset_n,
    input  [23:0] rtd1,
    output heatGo1,
    input  [31:0] set,
    input  [31:0] deadband); 

    //================================================================
    // Heater control 
    //================================================================
    //
    reg [2:0]  state_q;
    reg [2:0]  state_d;
    reg set_check, heatGo_q;
    reg set_plus_check;
    wire set_check_d, set_plus_check_d, delay_check_d, heatGo_d;
    reg delay_check;
    reg [31:0] delay_count, spc, set1, set2, set3;
    
    wire [31:0] rtd1_32, spc_d, delay_count_d;
    assign rtd1_32 = {8'h00, rtd1};
    
    always@(posedge clock) begin
            if(state_q==3'b000) begin            // INIT ///
                state_q <= 3'b001;               // go to idle
            end else if (state_q==3'b001) begin  // IDLE ///          
                state_q <= 3'b010;               // go to set_check            
            end else if (state_q==3'b010) begin  // SET_CHECK ///
                if (set_check) begin             // are we measuring above our setpoint?
                    state_q <= 3'b011;           //  (true) keep heater off
                end else begin
                    state_q <= 3'b100;           //  (false) turn heater on
                end
            end else if (state_q==3'b011) begin  // HEATER OFF //
                state_q <= 3'b001;               // go to idle
            end else if (state_q==3'b100) begin  // HEATER ON //
                state_q <= 3'b101;               // go to delay
            end else if (state_q==3'b101) begin  // DELAY //
                if (delay_check) begin           // have we delayed long enough?
                    state_q <= 3'b110;           //  (true) go to set plus check
                end else begin
                    state_q <= 3'b101;           //  (false) stay in this state longer
                end
           end else if (state_q==3'b110) begin   // SET PLUS CHECK //
                if (set_plus_check) begin        // are we a deadband amount of counts above the set point?
                    state_q <= 3'b011;           //  (true) turn heater off
                end else begin
                    state_q <= 3'b101;           //  (false) keep heater on, go to delay
                end
          end else begin
                state_q <= 3'b000;
          end
          //
          // Always register these
          set_check      <= set_check_d;
          set_plus_check <= set_plus_check_d;
          delay_count    <= delay_count_d;
          delay_check    <= delay_check_d;
          spc            <= spc_d;
          heatGo_q       <= heatGo_d;
          set1 <= set;
          set2 <= set1;
          set3 <= set2;
          //
          //
    end
    
    // check to see if the heater readback is at or above the setpoint.
    assign set_check_d = (rtd1_32 >= set3)? 1'b1 : 1'b0;
    // check to see if the set point + the deadband are higher than the heater readback
    assign set_plus_check_d = (rtd1_32 >= spc)? 1'b1 : 1'b0;
    // in the delay state, increment the counter, else reset the counter
    assign delay_count_d = (state_q == 3'b101)? delay_count+1 : 0;
    assign delay_check_d = (delay_count >= 2500000)? 1'b1 : 1'b0; //11/19/2025, reduced from 1 sec to 20 ms minimum on time
    // set plus check
    assign spc_d = set3 + deadband;
    // use bit 2 for heater on
    assign heatGo_d =(state_q[2])? 1'b1 : 1'b0;
    assign heatGo1  = heatGo_q;
  
//       ila_4 ila_4_inst1 (
//        .clk(clock),
//        .probe0(rtd1_32),
//        .probe1(set),
//        .probe2(deadband),
//        .probe3(state_q),
//        .probe4(set_check),
//        .probe5(set_plus_check),
//        .probe6(delay_count),
//        .probe7(delay_check),
//        .probe8(spc),
//        .probe9(heatGo_q));
  
endmodule
