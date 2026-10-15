// James Latshaw
// CIC filter with a down sample of 8, differential delay is 1 (M=8/8), 3 stages
// the triggerout can be used as a strobe for new data at the decimated sample rate.
// note : R can easily be changed but note that this will also impact differential delay M = D/R must = 1
// with this f/w

module cic_8(
    input  clk,     // system clock
    input  reset_n, // needed to clear integrators and counter
    input  strobein,
    input  [15:0] xin,
    output [15:0] yout,
    output triggerout
    );
    
    reg [1:0] clk_count;
    wire clk_clock;
    assign clk_clock = clk_count[1];
    always@(posedge clk) begin
        if (clk_count == 4'b1111) begin
            clk_count = 4'b0000;
        end else begin
            clk_count = clk_count + 1;
        end
    end // end process
    
    // first determine how many bits we need to sign extend, bit growth:
	// N = number of stages = 3
	// R = rate reduction = 8
	// M = differential delay/R = 8/8 = 1
	// New register bit size = ceiling(Nlog2(RM)^N) = 3*log2(8)+16=9+16= 25 bits  
    wire signed [24:0] xse, xdecm;
    reg  signed [24:0] xsed1, xsed2, xsed3, comb1, comb2, comb3, yse;
    reg [2:0] count8; // use for M
	reg [1:0] strbRE; // risined edge of the strobe will clock signals  
    
    assign xse = {{9{xin[15]}},xin}; // sign extend by 9 bits
    
	always@(posedge clk_clock) begin
		strbRE <= {strbRE[0], strobein};
		if (reset_n) begin
			if (strbRE==2'b01) begin
				xsed1 <= xse + xsed1;
				xsed2 <= xse + xsed1 + xsed2;
				xsed3 <= xse + xsed1 + xsed2 + xsed3;
				count8 <= count8 + 1;
			end
		end else begin
			xsed1  <= 0;
			xsed2  <= 0;
			xsed3  <= 0;
			count8 <= 0;
		end
	end
	
	always@(posedge clk_clock) begin
		if ((&count8) & (strbRE==2'b01)) begin
			comb1 <= xse + xsed1 + xsed2 + xsed3;
			comb2 <= xse + xsed1 + xsed2 + xsed3 - comb1;
			comb3 <= xse + xsed1 + xsed2 + xsed3 - comb1 - comb2;
		end
	end
	
	always@(posedge clk_clock) begin
		if ((&count8) & (strbRE==2'b01)) begin
			yse <= xse + xsed1 + xsed2 + xsed3 - comb1 - comb2 - comb3;
		end
	end

    assign yout = yse[24:9]; // gain = (RM)^N = (Rate_change*Dif_Delay)^Stages=(8*1)^3=512 or shift by 9 bits to normalize
	assign triggerout = ((&count8) & (strbRE==2'b01))? 1'b1 : 1'b0;
	
endmodule