--Register interface for engineers to use
--Mimics ISA regs interface, uses short address
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;
--use work.mbp_lib.all;
--
entity mbp_regs is
	generic(
			--This number must equal the number of registers you use.
			--Example: 10 is Registers 0-9
			HRTREGS	:	natural := 106
			);
	port(
		--Static MBP ports begin
		CLK	:	in std_logic;
		RESET	:	in std_logic;
		LOAD	:	in std_logic;
		ADDR	:	in std_logic_vector(15 downto 0);
		DIN	:	in std_logic_vector(15 downto 0);
		DOUT	:	out std_logic_vector(15 downto 0);
		ADCIN :  in REG16_ARRAY;
		DACOUT:  out REG16_ARRAY
		--Static MBP ports begin
		--User ports begin:
		-- reg0	:	in std_logic_vector(15 downto 0);
		-- reg1	:	in std_logic_vector(15 downto 0);
		-- reg2	:	in std_logic_vector(15 downto 0);
		-- reg3	:	in std_logic_vector(15 downto 0);
		-- reg4	:	in std_logic_vector(15 downto 0);
		-- reg5	:	in std_logic_vector(15 downto 0);
		-- reg6	:	in std_logic_vector(15 downto 0);
		-- reg7	:	in std_logic_vector(15 downto 0);
		-- reg8	:	in std_logic_vector(15 downto 0);
		-- reg9	:	in std_logic_vector(15 downto 0)
		--User ports end.  Do not forget to omit final semicolon
		);
end mbp_regs;
architecture mixed of mbp_regs is
	type word_array is array(natural range <>) of std_logic_vector(15 downto 0);
	--
	signal shrt_addr 	: std_logic_vector(7 downto 0) := x"00";
	signal reg_ena 	: std_logic_vector(0 to (HRTREGS -1)) := (others => '0');
	signal exc_ff 		: std_logic_vector(7 downto 0) := (others => '0');
	signal reg_d 		: word_array(0 to (HRTREGS -1)) := (x"F1F1",x"0002",x"0003",x"0004",x"0005",x"0006",x"0007",x"0008",x"0009",x"000A",x"000B",x"1389",x"138A",x"138B",x"138C",x"138D",x"138E",x"138F",x"1390",x"1391",x"1392",x"1393",x"000C",x"000D",x"100E",x"000F",x"0010",x"0011",x"0012",x"0013",x"0014",x"0015",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"0000",x"FFFF",x"FFFF",x"0000",x"0000",x"FFFF",x"FFFF",x"0000",x"0000",x"0000",x"FFFF",x"FFFF",x"01F8",x"0004",x"0000",x"000A",x"0002",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"FFFF");
	signal reg_q 		: word_array(0 to (HRTREGS -1)) := (x"F1F1",x"0002",x"0003",x"0004",x"0005",x"0006",x"0007",x"0008",x"0009",x"000A",x"000B",x"1389",x"138A",x"138B",x"138C",x"138D",x"138E",x"138F",x"1390",x"1391",x"1392",x"1393",x"000C",x"000D",x"100E",x"000F",x"0010",x"0011",x"0012",x"0013",x"0014",x"0015",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"1000",x"0000",x"FFFF",x"FFFF",x"0000",x"0000",x"FFFF",x"FFFF",x"0000",x"0000",x"0000",x"FFFF",x"FFFF",x"01F8",x"0004",x"0000",x"000A",x"0002",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"0000",x"FFFF");
	signal Version 	: std_logic_vector(15 downto 0);
	signal FaultClear	: std_logic;
	signal HTRPWR		: std_logic_vector(15 downto 0);
	signal HTRIRB		: std_logic_vector(15 downto 0);
	signal HTRVRB		: std_logic_vector(15 downto 0);
	signal HTRCNTLMD	: std_logic_vector(15 downto 0);
	--signal reg_d : word_array(0 to (HRTREGS -1)) := (others => x"0000");
	--signal reg_q : word_array(0 to (HRTREGS -1)) := (others => x"0000");
	
begin
	--ISA addr conversion
	shrt_addr <= ADDR(7 downto 0);
	--Register flip flops
	Reg_GEN : for i in 0 to (HRTREGS -1) generate
		process(RESET,CLK)
		begin
			if(RESET = '0') then
				--reg_q(i) <= (others => '0'); --initialize 0's to registers
				--reg_q(i) <= x"FFFF";
				--reg_q(i) <= std_logic_vector(to_unsigned(i + 1,16)); --initalize random values
				reg_q(i) <= reg_q(i);
			elsif(CLK'event and CLK = '1') then
				if(reg_ena(i) = '1') then
					reg_q(i) <= reg_d(i);
				end if;
			end if;
		end process;
	end generate Reg_GEN;
	--
	--Register logic:
	--Paste VHDL code from "VHDL_HRT" table in Excel spreadsheet
	--You can add conditions to the enable statement to control R/W access
	reg_ena(0) <= '1' when (LOAD = '1') and (shrt_addr = x"00") else '0';   reg_d(0) <= DIN;
reg_ena(1) <= '1' when (LOAD = '1') and (shrt_addr = x"01") else '0';   reg_d(1) <= DIN;
reg_ena(2) <= '1' when (LOAD = '1') and (shrt_addr = x"02") else '0';   reg_d(2) <= DIN;
reg_ena(3) <= '1' when (LOAD = '1') and (shrt_addr = x"03") else '0';   reg_d(3) <= DIN;
reg_ena(4) <= '1' when (LOAD = '1') and (shrt_addr = x"04") else '0';   reg_d(4) <= DIN;
reg_ena(5) <= '1' when (LOAD = '1') and (shrt_addr = x"05") else '0';   reg_d(5) <= DIN;
reg_ena(6) <= '1' when (LOAD = '1') and (shrt_addr = x"06") else '0';   reg_d(6) <= DIN;
reg_ena(7) <= '1' when (LOAD = '1') and (shrt_addr = x"07") else '0';   reg_d(7) <= DIN;
reg_ena(8) <= '1' when (LOAD = '1') and (shrt_addr = x"08") else '0';   reg_d(8) <= DIN;
reg_ena(9) <= '1' when (LOAD = '1') and (shrt_addr = x"09") else '0';   reg_d(9) <= DIN;
reg_ena(10) <= '1' when (LOAD = '1') and (shrt_addr = x"0A") else '0';   reg_d(10) <= DIN;
reg_ena(11) <= '1' when (LOAD = '1') and (shrt_addr = x"0B") else '0';   reg_d(11) <= DIN;
reg_ena(12) <= '1' when (LOAD = '1') and (shrt_addr = x"0C") else '0';   reg_d(12) <= DIN;
reg_ena(13) <= '1' when (LOAD = '1') and (shrt_addr = x"0D") else '0';   reg_d(13) <= DIN;
reg_ena(14) <= '1' when (LOAD = '1') and (shrt_addr = x"0E") else '0';   reg_d(14) <= DIN;
reg_ena(15) <= '1' when (LOAD = '1') and (shrt_addr = x"0F") else '0';   reg_d(15) <= DIN;
reg_ena(16) <= '1' when (LOAD = '1') and (shrt_addr = x"10") else '0';   reg_d(16) <= DIN;
reg_ena(17) <= '1' when (LOAD = '1') and (shrt_addr = x"11") else '0';   reg_d(17) <= DIN;
reg_ena(18) <= '1' when (LOAD = '1') and (shrt_addr = x"12") else '0';   reg_d(18) <= DIN;
reg_ena(19) <= '1' when (LOAD = '1') and (shrt_addr = x"13") else '0';   reg_d(19) <= DIN;
reg_ena(20) <= '1' when (LOAD = '1') and (shrt_addr = x"14") else '0';   reg_d(20) <= DIN;
reg_ena(21) <= '1' when (LOAD = '1') and (shrt_addr = x"15") else '0';   reg_d(21) <= DIN;
reg_ena(22) <= '1' when (LOAD = '1') and (shrt_addr = x"16") else '0';   reg_d(22) <= DIN;
reg_ena(23) <= '1' when (LOAD = '1') and (shrt_addr = x"17") else '0';   reg_d(23) <= DIN;
reg_ena(24) <= '1' when (LOAD = '1') and (shrt_addr = x"18") else '0';   reg_d(24) <= DIN;
reg_ena(25) <= '1' when (LOAD = '1') and (shrt_addr = x"19") else '0';   reg_d(25) <= DIN;
reg_ena(26) <= '1' when (LOAD = '1') and (shrt_addr = x"1A") else '0';   reg_d(26) <= DIN;
reg_ena(27) <= '1' when (LOAD = '1') and (shrt_addr = x"1B") else '0';   reg_d(27) <= DIN;
reg_ena(28) <= '1' when (LOAD = '1') and (shrt_addr = x"1C") else '0';   reg_d(28) <= DIN;
reg_ena(29) <= '1' when (LOAD = '1') and (shrt_addr = x"1D") else '0';   reg_d(29) <= DIN;
reg_ena(30) <= '1' when (LOAD = '1') and (shrt_addr = x"1E") else '0';   reg_d(30) <= DIN;
reg_ena(31) <= '1' when (LOAD = '1') and (shrt_addr = x"1F") else '0';   reg_d(31) <= DIN;
reg_ena(32) <= '1' when (LOAD = '1') and (shrt_addr = x"20") else '0';   reg_d(32) <= DIN;
reg_ena(33) <= '1' when (LOAD = '1') and (shrt_addr = x"21") else '0';   reg_d(33) <= DIN;
reg_ena(34) <= '1' when (LOAD = '1') and (shrt_addr = x"22") else '0';   reg_d(34) <= DIN;
reg_ena(35) <= '1' when (LOAD = '1') and (shrt_addr = x"23") else '0';   reg_d(35) <= DIN;
reg_ena(36) <= '1' when (LOAD = '1') and (shrt_addr = x"24") else '0';   reg_d(36) <= DIN;
reg_ena(37) <= '1' when (LOAD = '1') and (shrt_addr = x"25") else '0';   reg_d(37) <= DIN;
reg_ena(38) <= '1' when (LOAD = '1') and (shrt_addr = x"26") else '0';   reg_d(38) <= DIN;
reg_ena(39) <= '1' when (LOAD = '1') and (shrt_addr = x"27") else '0';   reg_d(39) <= DIN;
reg_ena(40) <= '1' when (LOAD = '1') and (shrt_addr = x"28") else '0';   reg_d(40) <= DIN;
reg_ena(41) <= '1' when (LOAD = '1') and (shrt_addr = x"29") else '0';   reg_d(41) <= DIN;
reg_ena(42) <= '1' when (LOAD = '1') and (shrt_addr = x"2A") else '0';   reg_d(42) <= DIN;
reg_ena(43) <= '1' when (LOAD = '1') and (shrt_addr = x"2B") else '0';   reg_d(43) <= DIN;
reg_ena(44) <= '1' when (LOAD = '1') and (shrt_addr = x"2C") else '0';   reg_d(44) <= DIN;
reg_ena(45) <= '1' when (LOAD = '1') and (shrt_addr = x"2D") else '0';   reg_d(45) <= DIN;
reg_ena(46) <= '1' when (LOAD = '1') and (shrt_addr = x"2E") else '0';   reg_d(46) <= DIN;
reg_ena(47) <= '1' when (LOAD = '1') and (shrt_addr = x"2F") else '0';   reg_d(47) <= DIN;
reg_ena(48) <= '1' when (LOAD = '1') and (shrt_addr = x"30") else '0';   reg_d(48) <= DIN;
reg_ena(49) <= '1' when (LOAD = '1') and (shrt_addr = x"31") else '0';   reg_d(49) <= DIN;
reg_ena(50) <= '1' when (LOAD = '1') and (shrt_addr = x"32") else '0';   reg_d(50) <= DIN;
reg_ena(51) <= '1' when (LOAD = '1') and (shrt_addr = x"33") else '0';   reg_d(51) <= DIN;
reg_ena(52) <= '1' when (LOAD = '1') and (shrt_addr = x"34") else '0';   reg_d(52) <= DIN;
reg_ena(53) <= '1' when (LOAD = '1') and (shrt_addr = x"35") else '0';   reg_d(53) <= DIN;
reg_ena(54) <= '1' when (LOAD = '1') and (shrt_addr = x"36") else '0';   reg_d(54) <= DIN;
reg_ena(55) <= '1' when (LOAD = '1') and (shrt_addr = x"37") else '0';   reg_d(55) <= DIN;
reg_ena(56) <= '1' when (LOAD = '1') and (shrt_addr = x"38") else '0';   reg_d(56) <= DIN;
reg_ena(57) <= '1' when (LOAD = '1') and (shrt_addr = x"39") else '0';   reg_d(57) <= DIN;
reg_ena(58) <= '1' when (LOAD = '1') and (shrt_addr = x"3A") else '0';   reg_d(58) <= DIN;
reg_ena(59) <= '1' when (LOAD = '1') and (shrt_addr = x"3B") else '0';   reg_d(59) <= DIN;
reg_ena(60) <= '1' when (LOAD = '1') and (shrt_addr = x"3C") else '0';   reg_d(60) <= DIN;
reg_ena(61) <= '1' when (LOAD = '1') and (shrt_addr = x"3D") else '0';   reg_d(61) <= DIN;
reg_ena(62) <= '1' when (LOAD = '1') and (shrt_addr = x"3E") else '0';   reg_d(62) <= DIN;
reg_ena(63) <= '1' when (LOAD = '1') and (shrt_addr = x"3F") else '0';   reg_d(63) <= DIN;
reg_ena(64) <= '1' when (LOAD = '1') and (shrt_addr = x"40") else '0';   reg_d(64) <= DIN;
reg_ena(65) <= '1' when (LOAD = '1') and (shrt_addr = x"41") else '0';   reg_d(65) <= DIN;
reg_ena(66) <= '1' when (LOAD = '1') and (shrt_addr = x"42") else '0';   reg_d(66) <= DIN;
reg_ena(67) <= '1' when (LOAD = '1') and (shrt_addr = x"43") else '0';   reg_d(67) <= DIN;
reg_ena(68) <= '1' when (LOAD = '1') and (shrt_addr = x"44") else '0';   reg_d(68) <= DIN;
reg_ena(69) <= '1' when (LOAD = '1') and (shrt_addr = x"45") else '0';   reg_d(69) <= DIN;
reg_ena(70) <= '1' when (LOAD = '1') and (shrt_addr = x"46") else '0';   reg_d(70) <= DIN;
reg_ena(71) <= '1' when (LOAD = '1') and (shrt_addr = x"47") else '0';   reg_d(71) <= DIN;
reg_ena(72) <= '1' when (LOAD = '1') and (shrt_addr = x"48") else '0';   reg_d(72) <= DIN;
reg_ena(73) <= '1' when (LOAD = '1') and (shrt_addr = x"49") else '0';   reg_d(73) <= DIN;
reg_ena(74) <= '1' when (LOAD = '1') and (shrt_addr = x"4A") else '0';   reg_d(74) <= DIN;
reg_ena(75) <= '1' when (LOAD = '1') and (shrt_addr = x"4B") else '0';   reg_d(75) <= DIN;
reg_ena(76) <= '1' when (LOAD = '1') and (shrt_addr = x"4C") else '0';   reg_d(76) <= DIN;
reg_ena(77) <= '1' when (LOAD = '1') and (shrt_addr = x"4D") else '0';   reg_d(77) <= DIN;
reg_ena(78) <= '1' when (LOAD = '1') and (shrt_addr = x"4E") else '0';   reg_d(78) <= DIN;
reg_ena(79) <= '1' when (LOAD = '1') and (shrt_addr = x"4F") else '0';   reg_d(79) <= DIN;
reg_ena(80) <= '1' when (LOAD = '1') and (shrt_addr = x"50") else '0';   reg_d(80) <= DIN;
reg_ena(81) <= '1' when (LOAD = '1') and (shrt_addr = x"51") else '0';   reg_d(81) <= DIN;
reg_ena(82) <= '1' when (LOAD = '1') and (shrt_addr = x"52") else '0';   reg_d(82) <= DIN;
reg_ena(83) <= '1' when (LOAD = '1') and (shrt_addr = x"53") else '0';   reg_d(83) <= DIN;
reg_ena(84) <= '1' when (LOAD = '1') and (shrt_addr = x"54") else '0';   reg_d(84) <= DIN;
reg_ena(85) <= '1' when (LOAD = '1') and (shrt_addr = x"55") else '0';   reg_d(85) <= DIN;
reg_ena(86) <= '1' when (LOAD = '1') and (shrt_addr = x"56") else '0';   reg_d(86) <= DIN;
reg_ena(87) <= '1' when (LOAD = '1') and (shrt_addr = x"57") else '0';   reg_d(87) <= DIN;
reg_ena(88) <= '1' when (LOAD = '1') and (shrt_addr = x"58") else '0';   reg_d(88) <= DIN;
reg_ena(89) <= '1' when (LOAD = '1') and (shrt_addr = x"59") else '0';   reg_d(89) <= DIN;
reg_ena(90) <= '1' when (LOAD = '1') and (shrt_addr = x"5A") else '0';   reg_d(90) <= DIN;
reg_ena(91) <= '1' when (LOAD = '1') and (shrt_addr = x"5B") else '0';   reg_d(91) <= DIN;
reg_ena(92) <= '1' when (LOAD = '1') and (shrt_addr = x"5C") else '0';   reg_d(92) <= DIN;
reg_ena(93) <= '1' when (LOAD = '1') and (shrt_addr = x"5D") else '0';   reg_d(93) <= DIN;
reg_ena(94) <= '1' when (LOAD = '1') and (shrt_addr = x"5E") else '0';   reg_d(94) <= DIN;
reg_ena(95) <= '1' when (LOAD = '1') and (shrt_addr = x"5F") else '0';   reg_d(95) <= DIN;
reg_ena(96) <= '1' when (LOAD = '1') and (shrt_addr = x"60") else '0';   reg_d(96) <= DIN;
reg_ena(97) <= '1' when (LOAD = '1') and (shrt_addr = x"61") else '0';   reg_d(97) <= DIN;
reg_ena(98) <= '1' when (LOAD = '1') and (shrt_addr = x"62") else '0';   reg_d(98) <= DIN;
reg_ena(99) <= '1' when (LOAD = '1') and (shrt_addr = x"63") else '0';   reg_d(99) <= DIN;
reg_ena(100) <= '1' when (LOAD = '1') and (shrt_addr = x"64") else '0';   reg_d(100) <= DIN;
reg_ena(101) <= '1' when (LOAD = '1') and (shrt_addr = x"65") else '0';   reg_d(101) <= DIN;
reg_ena(102) <= '1' when (LOAD = '1') and (shrt_addr = x"66") else '0';   reg_d(102) <= DIN;
reg_ena(103) <= '1' when (LOAD = '1') and (shrt_addr = x"67") else '0';   reg_d(103) <= DIN;
reg_ena(104) <= '1' when (LOAD = '1') and (shrt_addr = x"68") else '0';   reg_d(104) <= DIN;
reg_ena(105) <= '1' when (LOAD = '1') and (shrt_addr = x"69") else '0';   reg_d(105) <= DIN;

with shrt_addr select DOUT <=
     reg_q(0) when x"00",
     reg_q(1) when x"01",
     reg_q(2) when x"02",
     reg_q(3) when x"03",
     reg_q(4) when x"04",
     reg_q(5) when x"05",
     reg_q(6) when x"06",
     reg_q(7) when x"07",
     reg_q(8) when x"08",
     reg_q(9) when x"09",
     reg_q(10) when x"0A",
     reg_q(11) when x"0B",
     reg_q(12) when x"0C",
     reg_q(13) when x"0D",
     reg_q(14) when x"0E",
     reg_q(15) when x"0F",
     reg_q(16) when x"10",
     reg_q(17) when x"11",
     reg_q(18) when x"12",
     reg_q(19) when x"13",
     reg_q(20) when x"14",
     reg_q(21) when x"15",
     reg_q(22) when x"16",
     reg_q(23) when x"17",
     reg_q(24) when x"18",
     reg_q(25) when x"19",
     reg_q(26) when x"1A",
     reg_q(27) when x"1B",
     reg_q(28) when x"1C",
     reg_q(29) when x"1D",
     reg_q(30) when x"1E",
     reg_q(31) when x"1F",
     reg_q(32) when x"20",
     reg_q(33) when x"21",
     reg_q(34) when x"22",
     reg_q(35) when x"23",
     reg_q(36) when x"24",
     reg_q(37) when x"25",
     reg_q(38) when x"26",
     reg_q(39) when x"27",
     reg_q(40) when x"28",
     reg_q(41) when x"29",
     reg_q(42) when x"2A",
     reg_q(43) when x"2B",
     reg_q(44) when x"2C",
     reg_q(45) when x"2D",
     reg_q(46) when x"2E",
     reg_q(47) when x"2F",
     reg_q(48) when x"30",
     reg_q(49) when x"31",
     reg_q(50) when x"32",
     reg_q(51) when x"33",
     reg_q(52) when x"34",
     reg_q(53) when x"35",
     reg_q(54) when x"36",
     reg_q(55) when x"37",
     reg_q(56) when x"38",
     reg_q(57) when x"39",
     reg_q(58) when x"3A",
     reg_q(59) when x"3B",
     reg_q(60) when x"3C",
     reg_q(61) when x"3D",
     reg_q(62) when x"3E",
     reg_q(63) when x"3F",
     reg_q(64) when x"40",
     reg_q(65) when x"41",
     reg_q(66) when x"42",
     reg_q(67) when x"43",
     reg_q(68) when x"44",
     reg_q(69) when x"45",
     reg_q(70) when x"46",
     reg_q(71) when x"47",
     reg_q(72) when x"48",
     reg_q(73) when x"49",
     reg_q(74) when x"4A",
     reg_q(75) when x"4B",
     reg_q(76) when x"4C",
     reg_q(77) when x"4D",
     reg_q(78) when x"4E",
     reg_q(79) when x"4F",
     reg_q(80) when x"50",
     reg_q(81) when x"51",
     reg_q(82) when x"52",
     reg_q(83) when x"53",
     reg_q(84) when x"54",
     reg_q(85) when x"55",
     reg_q(86) when x"56",
     reg_q(87) when x"57",
     reg_q(88) when x"58",
     reg_q(89) when x"59",
     reg_q(90) when x"5A",
     reg_q(91) when x"5B",
     reg_q(92) when x"5C",
     reg_q(93) when x"5D",
     reg_q(94) when x"5E",
     reg_q(95) when x"5F",
     reg_q(96) when x"60",
     reg_q(97) when x"61",
     reg_q(98) when x"62",
     reg_q(99) when x"63",
     reg_q(100) when x"64",
     reg_q(101) when x"65",
     reg_q(102) when x"66",
     reg_q(103) when x"67",
     reg_q(104) when x"68",
     reg_q(105) when x"69",
     x"FFFF" when others;



end mixed;