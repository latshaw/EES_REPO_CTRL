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
			HRTREGS	:	natural := 7
			);
	port(
		--Static MBP ports begin
		CLK				: in std_logic;
		RESET				: in std_logic;
		LOAD				: in std_logic;
		ADDR				: in std_logic_vector(15 downto 0);
		DIN				: in std_logic_vector(15 downto 0);
		DOUT				: out std_logic_vector(15 downto 0);
		ADCIN 			: in REG16_ARRAY;
		DACOUT			: out REG16_ARRAY;
		FILTER_CONTROL	: out std_logic_vector(15 downto 0)
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
	signal reg_d 		: word_array(0 to (HRTREGS -1)) := (x"F1F1",x"0002",x"0003",x"0004",x"0005",x"0006",x"0007");
	signal reg_q 		: word_array(0 to (HRTREGS -1)) := (x"F1F1",x"0002",x"0003",x"0004",x"0005",x"0006",x"0007");
	signal Version 	: std_logic_vector(15 downto 0);
	signal FaultClear	: std_logic;
	signal HTRPWR		: unsigned(31 downto 0);
	signal HTRIRB		: unsigned(15 downto 0);
	signal HTRVRB		: unsigned(15 downto 0);
	signal HTRCNTLMD	: std_logic_vector(15 downto 0);
	signal DACCNTLd	: REG16_ARRAY;
	signal DACCNTLq	: REG16_ARRAY;
	--signal reg_d : word_array(0 to (HRTREGS -1)) := (others => x"0000");
	--signal reg_q : word_array(0 to (HRTREGS -1)) := (others => x"0000");	
begin



--	HeaterPID: HEAT_CONTROL
--	port map(clock					=> CLK,
--				reset					=> RESET,
--				requested_watts	=> HTRPWR,
--				current_readback	=> HTRIRB,
--				voltage_readback	=> HTRVRB,
--				DAC_setpoint		=> DACCNTLq(0),
--				p_gain				=> HTRP,
--				i_gain				=> HTRI,
--				d_gain				=> HTRD,
--				new_DAC_setpoint	=> DACCNTLd(0)
--			);
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
	
	process(RESET,CLK)
		begin
			if(RESET = '0') then
				DACCNTLq(0) <= (others => '0');
				FILTER_CONTROL	<= x"0000";
			elsif(CLK'event and CLK = '1') then
				FILTER_CONTROL	<= x"0001";
				DACCNTLq <= DACCNTLd;
				DACOUT	<= ADCIN;
			end if;
		end process;
	--
	--Register logic:
	--Paste VHDL code from "VHDL_HRT" table in Excel spreadsheet
	--You can add conditions to the enable statement to control R/W access
	     reg_ena(0) <= '1' when (LOAD = '1') and (shrt_addr = x"00") else '0';   reg_d(0) <= DIN;
		  reg_ena(1) <= '1' when (LOAD = '1') and (shrt_addr = x"01") else '0';   reg_d(1) <= DIN;
		  reg_ena(2) <= '1';   reg_d(2) <= x"FFFF";
		  reg_ena(3) <= '1';   reg_d(3) <= x"FFFF";
		  reg_ena(4) <= '1';   reg_d(4) <= x"FFFF";
		  reg_ena(5) <= '1';   reg_d(5) <= x"FFFF";
		  reg_ena(6) <= '1' when (LOAD = '1') and (shrt_addr = x"06") else '0';   reg_d(6) <= DIN;


	with shrt_addr select DOUT <=
     reg_q(0) when x"00",
     reg_q(1) when x"01",
     reg_q(2) when x"02",
     reg_q(3) when x"03",
     reg_q(4) when x"04",
     reg_q(5) when x"05",
     reg_q(6) when x"06",
     x"FFFF" when others;

end mixed;