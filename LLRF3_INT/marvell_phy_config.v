// Marvell PHY Configuration
// James Latshaw
// 1/22/2026
//
// There are to marvel phy chips installed in several configurations of the 10GX fpga board. 
// PHY chip 88E1512, model number 011101, DOES NOT COME UP IN GIGABIT, NEED TO CONFIGURE
// PHY chip 88E1111, model number 001100, automatically comes up in GIGABIT (NO NEED TO CONFIGURE)
//
// Fortunately, we can read the PHY ID to know which is which.
//
//  88E1111 was the first PHY chip used and it does not need configured. Also, for those C10GX FPGA
//  carriers not all of the MDIO/MDC pins are connected. So if the PHY ID can't be reached it is this one.
//
//  88E1512 must be configured. If the PHY ID matches this then we will configure the chip.
//
// In both cases we will hold the chip in reset per the datasheet.

module marvell_phy_config (
	input clock,
	input reset,
	input en_mdc,
	output phy_resetn,
	inout mdio,
	output mdc,
	output config_done,
	output [15:0] chipId);

	reg [7:0] clk_div;
	always @(posedge clock) begin
		if (reset)
			clk_div <= clk_div + 1;
		else
			clk_div <= 0;
	end
	
	reg  [15:0] regID;
	wire [15:0] regWire;
	
	reg [3:0] state, packet;
	reg [7:0] wakeCouter; 
	reg [31:0] dataw, dataR;
	reg [4:0] bitCount;
	reg [5:0] waitBetween;
	reg rnw;
	reg mdioR;
	
	always @(posedge clock) begin
		if (reset) begin
			if (clk_div==8'b10000000) begin
				regID <= regWire;
				case(state)
					4'h0 : begin
						// hold PHY in reset and allow to waek up
						if (&wakeCouter) begin
							wakeCouter <= 0;
							state <= 4'h1;
						end else begin
							wakeCouter <= wakeCouter + 1;
							state <= 4'h0;
						end
					end
					4'h1 : begin
						// load the next packet
						case (packet) //         rnw      zeros     addr      TA      data
							4'h0:     dataw <= {4'b0101, 5'b00000, 5'b10110, 2'b10, 16'h0000}; // reg 22, go to page 0   write command ///4'h1:     dataw <= {4'b0110, 5'b00000, 5'b00010, 2'b00 16'h0000}; //                           ??? read reg  3 page 0     read
							4'h1:     dataw <= {4'b0110, 5'b00000, 5'b00011, 2'b00, 16'h0000}; // reg  3 page 0          read command
							4'h2:     dataw <= {4'b0101, 5'b00000, 5'b10110, 2'b10, 16'h0012}; // reg 22 go to page 18   write command
							4'h3:     dataw <= {4'b0101, 5'b00000, 5'b10100, 2'b10, 16'h0201}; // reg 20, write x0201    write command
							4'h4:     dataw <= {4'b0101, 5'b00000, 5'b10100, 2'b10, 16'h8201}; // reg 20, write x8201    write command
							default : dataw <= {4'b0101, 5'b00000, 5'b10110, 2'b00, 16'h0000}; // default case
						endcase
						state    <= 4'h3;
						bitCount <= 0;
					end
					//skip state 2?
					4'h3 : begin
						//determine if this is a read or write operation
						if (dataw[31:28]==4'b0110)
							rnw <= 1'b1;
						else
							rnw <= 1'b0;
						state <= 4'h4;
					end
					4'h4 : begin	
						// issue 32 ticks 
						if (&bitCount)
							state <= 4'h5;
						else
							state <= 4'h4;
						bitCount <= bitCount + 1;
						dataw    <= {dataw[30:0], dataw[31]};
						//if (bitCount !== 5'b11110)
						if (packet == 4'h1) //we read PHY ID on packet 1
							dataR    <= {dataR[30:0], mdio};
					end
					4'h5 : begin
						// allow pause between packets
						if (&waitBetween)
							state <= 4'h6;
						else
							state <= 4'h5;
						waitBetween <= waitBetween + 1;
					end
					4'h6 : begin
						// assess marvell ID
						// PHY chip 88E1512, model number 011101, DOES NOT COME UP IN GIGABIT, NEED TO CONFIGURE
						// PHY chip 88E1111, model number 001100, automatically comes up in GIGABIT (NO NEED TO CONFIGURE)
						if (packet == 4'h1) begin
							if (dataR[9:4]==6'b011101)
								state <= 4'h7; //we need to configure the phy
							else
								state <= 4'h8; // no need to configure
						end else begin
							state <= 4'h7;
						end
					end
					4'h7 : begin
						// incrment packet or go to done state
						if (packet>= 4'h4)
							state <= 4'h8;
						else
							state <= 4'h1;
						packet <= packet + 1;
					end
					default : begin 
						// wait forever or until reset
						state <= 4'h8; 
					end
				endcase
			end
		end else begin
			// Reset logic goes here
			state <= 0;
			wakeCouter <= 0;
			dataw <= 0;
			waitBetween <= 0;
			bitCount <= 0;
			dataR <= 0;
			packet <= 0;
			regID <= 0;
		end
	end
	
	//mdio needs to be Hi-Z for reads
	always @(*)
	begin
		if ((state <= 3) | (state >= 5))
			mdioR <= 1'b1;
		else if (bitCount <= 4'hd)
			mdioR <= dataw[31];
		else if (rnw)
			mdioR <= 1'bZ;
		else
			mdioR <= dataw[31];
	end
	
	assign mdc  = clk_div[7];
	assign mdio = mdioR;
	
	
	assign phy_resetn = (state==4'h0)? 1'b0 : 1'b1;
	assign config_done = (state==4'h8)? 1'b1 : 1'b0;
	assign regWire = dataR[15:0];
	assign chipId = regID;
	
 // 4/2/2025 added functionality to read back the ID register to determine the model number. 
 // PHY chip 88E1512, model number 011101, DOES NOT COME UP IN GIGABIT, NEED TO CONFIGURE
 // PHY chip 88E1111, model number 001100, automatically comes up in GIGABIT (NO NEED TO CONFIGURE)
 // reminder don't forget to make mdio and inout

//entity marvell_phy_config is
//port(clock	:	in std_logic;
//	reset	:	in std_logic;
//	en_mdc : in std_logic; -- during power on, set HI to enable mdc/mdio register config. Marvel reset happens in any case.
//	phy_resetn	:	out std_logic;
//	mdio	:	inout std_logic;
//	mdc		:	out std_logic;
//	config_done	:	out std_logic;
//	chipId : out std_logic_vector(15 downto 0)
//	);
//end marvell_phy_config;

 

//
//--reg22_w			<= x"0201";----page 18 register 20, set mode[2:0] to "001" ----SGMII to copper
//--reg22_w			<=	x"8201";---reset the phy
//
//-- only need to specify read registers, all others are NO HI Z
//data_hi_z 		<=	"0"  & "00" & "00" & "00000" & "00000" & "10" & x"FFFF" & x"00"            when addr_count_q = "00001" else -- read reg 3 page 0
//						"0"  & "00" & "00" & "00000" & "00000" & "10" & x"FFFF" & x"00"            when addr_count_q = "00010" else -- read reg 3 page 0
//					   "0"  & "00" & "00" & "00000" & "00000" & "00" & x"0000" & x"00";  -- all other addresses (non-reads)
//
//
//data_in_phy		<=	"1"  & "01" & "01" & "00000" & "10110" & "Z0" & x"0000" & x"FF"            when addr_count_q = "00000" else-----    reg 22, go to page 0
//						"1"  & "01" & "10" & "00000" & "00010" & "Z0" & "ZZZZZZZZZZZZZZZZ" & x"FF" when addr_count_q = "00001" else -- read reg  3 page 0
//						"1"  & "01" & "10" & "00000" & "00011" & "Z0" & "ZZZZZZZZZZZZZZZZ" & x"FF" when addr_count_q = "00010" else -- read reg  3 page 0
//						"1"  & "01" & "01" & "00000" & "10110" & "10" & x"0012" & x"FF"            when addr_count_q = "00011" else-----    reg 22 go to page 18
////					   "1"  & "01" & "01" & "00000" & "10100" & "10" & x"0201" & x"FF"            when addr_count_q = "00100" else-----    reg 20, write x0201
////					   "1"  & "01" & "01" & "00000" & "10100" & "10" & x"8201" & x"FF";                                           -----    reg 20, write x8201
//
//			when addr_check	=>	 if (addr_count_q = "00010") and (device_id_q(9 downto 4) /= "011101") then -- read ID register
//											-- see note at top of file for which marvel PHY goes with which device ID
//											-- note, we are just making sure that the PHY is NOT the 88E1512. If we are NOT 88E1512, then no
//											-- need to configure the chip (just skip to done state).
//											state <= phy_config_done;
//										elsif addr_count_q = "00101" then 

endmodule