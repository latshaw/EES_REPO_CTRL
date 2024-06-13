module ssa_mon (
	input  clk,  //will work for any, timing is done for 93 MHz clock
	input  reset_n,
	input  clear, // set hi to clear faults/reset SM
	input  ssa_en, // digital input from SSA (HI means no fault, SSA may be turned on)
	output ssa_prmt_pulse, // when the SSA trips offline and the ssa_en goes away, then send a pulse (for RF switch readback register enable)
	output [1:0] ssa_prmt_out // ssa permit latched_fault + present
  );
  
  reg latched_fault;
  reg [15:0] fault_count;
  reg ssa_enq, clearq;
  reg [1:0] ssa_fault_stretch;
  wire [1:0] ssa_fault_stretch_d;
  wire [15:0] fault_count_d;
  wire fault_count_en, fault_count_clear, latched_fault_d, ssa_en_latched;
  
  // simple flip flops
    always@(posedge clk) begin
		clearq            <= clear;
		ssa_enq           <= ssa_en;
		ssa_fault_stretch <= ssa_fault_stretch_d; 
		fault_count       <= fault_count_d;
		latched_fault     <= latched_fault_d;
	 end
  
  // combinational logic
  assign fault_count_d       = (fault_count_clear==1'b1)? (0) :(((fault_count_en == 1'b1) & (fault_count <= 16'h03A2))? fault_count + 1 : fault_count); // clear OR increment next counter if count not exceeded
  assign fault_count_en      = (ssa_enq==1'b0)? 1'b1 : 1'b0; // enable fault counter if no ssa enable is present
  assign fault_count_clear   = (clearq == 1'b1)? 1'b1 : 1'b0; // clear fault counter (and latched fault) if clear faults goes HI
  assign ssa_fault_stretch_d = {ssa_fault_stretch[0], latched_fault}; // stretch ssa_latched fault to make a strobe so that the rising edge may be detected
  assign latched_fault_d     = (fault_count>=16'h03A2)? 1'b1 : 1'b0; // latch fault if counter is met (note, may be cleared with clear input)
  assign ssa_prmt_pulse      = (ssa_fault_stretch == 3'b001) ? 1'b1 : 1'b0; // pulse if you see a fault occur (rising edge)
  assign ssa_en_latched      = (latched_fault == 1'b1)? 1'b0 : 1'b1; // latched fault is HI when faulted. however, permit is HI when good, so we flip the bit
  assign ssa_prmt_out        = {ssa_en_latched, ssa_enq}; // OUTPUT: latched fault + present state  
  assign ssa_prmt_pulse      = (ssa_fault_stretch == 2'b01) ? 1'b1 : 1'b0; //OUTPUT: pulse if you see a fault occur (rising edge). This is to be used with RF on permit enable so that the switch opens during fault
  
endmodule