module tca6416APWR(
    input clock,
    input reset_n,
    inout sda,
    output scl,
    input [15:0] led
    );
    
    
 assign PHY_RSTN = PHY_RSTN_buffer;
assign led[4] = PHY_RSTN_buffer;
assign led[5] = clk_locked;
reg [26:0] tx_clk_heartbeat=0, tx_clk90_heartbeat=0;
always @(posedge tx_clk) tx_clk_heartbeat <= tx_clk_heartbeat+1;
always @(posedge tx_clk90) tx_clk90_heartbeat <= tx_clk90_heartbeat+1;
assign led[6] = tx_clk_heartbeat[24];
assign led[7] = tx_clk90_heartbeat[24];

    
    
endmodule
