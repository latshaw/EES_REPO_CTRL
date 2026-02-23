// Heater Control
// 11/21/2025 initial
// 12/1/2025 final sum now has cain of 2^12
// 12/3/2025 fixed negative slop saturation for error
//
// artix dsp asre 25x18 so i choose soemthing smaller
// lower percsiion for integral term seems necessary
// try to make a modelsim where we see it converge and not overbounce...
// make sure new bit lengths meet timing
// also, the old sum code seems to have anunche of front loaded zeros...


module PICtrl(
    input  clock,
    input  reset_n, // strobing this will also clear the integral accumulator
    input signed [31:0] set,
    input signed [23:0] rtd1,
    input signed [22:0] pgain, // U3.20
    input signed [22:0] igain, // U3.20
    input  [31:0] onMin, // Prevent short cycle, 12ish ms should be shortest for chosen SSR
    input  [31:0] maxPeriod, // max period in clock tics (timebase will supercede this if lower)
    input  [31:0] timebase, //use to adjust cycle rate
    output [31:0] onPeriod,  //readback to know if we are saturated, in clock tics
    output [31:0] driveOut,
    output [31:0] counter,
    output heatGo1); 
	
    //================================================================
    // Timebase
    //================================================================
    // minimum ontime should be 12 ish ms, minimum controller speed should probably be 60 Hz
    //parameter spiClkDiv = 5; // for implemenatation set to 20
    reg [31:0] spi_count, timebasereg1, timebasereg2, maxPeriodreg1, maxPeriodreg2, onMinreg1, onMinreg2;
    wire spi_clock;
    always@(posedge clock) begin
        timebasereg1 <= timebase;
        timebasereg2 <= timebasereg1;
        if ((reset_n==1'b0) || (timebasereg1 !== timebasereg2)) begin
            spi_count <= 0;
        end else if (spi_count >= timebasereg2) begin 
            spi_count <= 0;
        end else begin
            spi_count <= spi_count + 1;
        end
    end // end process
    
    assign counter = spi_count;
    
    //
    //================================================================
    // PI control 
    //================================================================
    // simple PI controller, clears integral term on reset
    // negative values will be in 2's complement (in verilog for signed math to work, 
	// everything must be declared signed)
    reg  signed [31:0] error;
    wire signed [31:0] rtdSgnExt;
    
    reg  signed [16:0] errorCLip;
    wire signed [16:0] errorCLip_d;
    wire signed [39:0] pro, integral_d, integralMul, integralAdd_d, error_d, sum_d, integralWindUp;
    reg  signed [39:0] integral, sum, sumAdd, sumClip, integralAdd, integralAddClip;

    always@(posedge clock) begin
		error       <= error_d;
		integral    <= integral_d;
		sumAdd      <= sum_d;
		sum         <= sumClip;
		errorCLip   <= errorCLip_d;
		integralAdd <= integralAdd_d;
		
		//overflow protection for sum
		if (pro[39]==1'b0 && integral[39]==1'b0 && sumAdd[39]==1'b1) begin
			sumClip <= 40'h7fffffffff;
		end else if (pro[39]==1'b1 && integral[39]==1'b1 && sumAdd[39]==1'b0) begin
			sumClip <= 40'h8000000000;
		end else begin
			sumClip <= sumAdd;
		end
		
		//overflow protection for integration
		if (integralMul[39]==1'b0 && integral[39]==1'b0 && integralAdd[39]==1'b1) begin
			integralAddClip <= 40'h7fffffffff;
		end else if (integralMul[39]==1'b1 && integral[39]==1'b1 && integralAdd[39]==1'b0) begin
			integralAddClip <= 40'h8000000000;
		end else begin
			integralAddClip <= integralAdd;
		end
    end 
	
	assign rtdSgnExt = {8'h00, rtd1}; // sign extend 24bit input to make Q32.0
	assign error_d    = set - rtdSgnExt; //Q32.0  assign error_d    = (spi_count == 0)? set - rtdSgnExt : error; 
	assign errorCLip_d= (error[31] == 1'b0 & error[30:16] != 15'b000000000000000)? {1'b0,16'hffff} : 
                        (error[31] == 1'b1 & error[30:16] != 15'b111111111111111)? {1'b1,16'h0000} : error[16:0]; //Q17.0

	assign pro = errorCLip*pgain;            // Q17.0*Q3.20 = Q20.20
	assign integralMul = errorCLip*igain;    
	assign integralAdd_d = integralMul + integral; 
	//assign integralWindUp =(integralAddClip[23] == 1'b0 & integralAddClip[22:15] !== 8'd0)? {24'h01ffff} : 
    //                      (integralAddClip[23] == 1'b1 & integralAddClip[22:15] !== 8'd1)? {24'hfe0001} : integralAddClip; //Q15.9 with windup protection
	assign integral_d = (reset_n)? (spi_count == 0)? integralAddClip : integral : 0;// reset when closing switch to help prevent windup
	assign sum_d      = pro + integral; //assign sum_d      = (spi_count == 0)? pro + integral : sum;
    //
    //================================================================
    // PWM control 
    //================================================================
    // goal is to take the result from the PI and convert this into a pulse of variable duty cycle
    // maxPeriod determins the period length, drive determines the duty cycle
    // onMin is short cycle protection. Device can drive for period lengths :  onMin < x < maxPeriod
    // clear resets all counters
    
    wire [31:0] drivePre_d;
    reg  [31:0] drivePre, drive, count, onPeriodCalc;    
    reg  heatGo1Calc;
    wire heatGo1Calc_d;
    
    always@(posedge clock) begin
        maxPeriodreg1 <= maxPeriod;
        maxPeriodreg2 <= maxPeriodreg1;
        
        onMinreg1 <= onMin;
        onMinreg2 <= onMinreg1;
        // register drive value at end of last cycle, freezes drive signal
        if (spi_count == 0) begin
            drive <= drivePre_d;
            //drive   <= drivePre; // double buffer input??
        end       
        
        // apply limits to drive to produce onPeriodCalc
        if (drive < onMinreg2) begin // short cycle protection
            onPeriodCalc <= 0;
            heatGo1Calc <= 1'b0;
        end else if (drive > maxPeriodreg2) begin // use to limit total on time
            onPeriodCalc <= maxPeriodreg2; 
            heatGo1Calc <= heatGo1Calc_d;
        end else begin
            onPeriodCalc <= drive;
            heatGo1Calc <= heatGo1Calc_d;
        end
    end 
    
    //13'b0000000000000
    //Truncate fractionap bits, U32.0, if negative set to 0, add saturation protection (same either way?)
    assign drivePre_d = (sum[39]==1'b1)? 0 : sum[38:7];//12/1/25, on time has some gain, otherwise we will be limited to short duty cycles
    assign onPeriod = onPeriodCalc;
    assign heatGo1Calc_d = (spi_count <= onPeriodCalc)? 1'b1 : 1'b0;
    assign heatGo1 = heatGo1Calc;
    
    assign driveOut = drive;

endmodule
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
  