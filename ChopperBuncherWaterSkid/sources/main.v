`timescale 1ns / 1ps

module main(
    input [7:0] sw,
    output [7:0] led
    );
    
    // Assign led output to correspond to its matching switch
    assign led = sw;
    
endmodule
