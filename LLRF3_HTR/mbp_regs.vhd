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
			HRTREGS	:	natural := 9
			);
	port(
		--Static MBP ports begin
		CLK				: in std_logic;
		RESET				: in std_logic;
		LOAD				: in std_logic;
		ADDR				: in std_logic_vector(15 downto 0);
		DIN				: in std_logic_vector(15 downto 0);
		LCLMDIN			: in std_logic;
		DOUT				: out std_logic_vector(15 downto 0);
		ADCIN 			: in REG16_ARRAY;
		DACOUT			: out REG16_ARRAY;
		FILTER_CONTROL	: out std_logic_vector(15 downto 0);
		REMOTE			: out std_logic;
		LOCAL				: out std_logic
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
	
	type	RegisterRecord is record
	CNTLMD				: std_logic_vector(15 downto 0);
	LCLPWR				: std_logic_vector(15 downto 0);
	IRB					: std_logic_vector(15 downto 0);
	VRB					: std_logic_vector(15 downto 0);
	FVER					: std_logic_vector(15 downto 0);
	HVER					: std_logic_vector(15 downto 0);
	DAC					: std_logic_vector(15 downto 0);
	RSTR					: std_logic_vector(15 downto 0);
	HB						: std_logic_vector(23 downto 0);
	DACSET				: std_logic_vector(15 downto 0);
	CNTLMDFB				: std_logic_vector(15 downto 0);
	LCLRMT				: std_logic;
	end record RegisterRecord;

	--
	signal d, q			: RegisterRecord;
	signal shrt_addr 	: std_logic_vector(7 downto 0) := x"00";
	signal FaultClear	: std_logic;
begin

	--ISA addr conversion
	shrt_addr <= ADDR(7 downto 0);
	--Register flip flops
	process(RESET,CLK)
	begin
		if(RESET = '0') then
			q.CNTLMD 	<= (others => '0'); --initialize 0's to registers
			q.LCLPWR 	<= x"7A7D";			  -- Initalize with DAC output in local mode for ~100W.
			q.IRB 		<= (others => '0'); --initialize 0's to registers
			q.VRB			<= (others => '0'); --initialize 0's to registers
			q.FVER		<= (x"0001");
			q.HVER		<= (x"0001"); 
			q.DAC			<= (others => '0'); --initialize 0's to registers
			q.RSTR 		<= (others => '0'); --initialize 0's to registers
			q.HB 			<= (others => '0'); --initialize 0's to registers
			q.DACSET		<= (others => '0'); --initialize 0's to registers
		elsif(CLK'event and CLK = '1') then
				FILTER_CONTROL	<= x"0003";
				q <= d;
		end if;
	end process;
	
	--Register logic:
	--Paste VHDL code from "VHDL_HRT" table in Excel spreadsheet
	--You can add conditions to the enable statement to control R/W access
			-- Hold prior values until changed.
			d.CNTLMD 	<= DIN when (LOAD = '1') and (shrt_addr = x"00") else q.CNTLMD;
			d.LCLPWR 	<= DIN when (LOAD = '1') and (shrt_addr = x"01") else q.LCLPWR;
			d.IRB 		<= ADCIN(0);	-- IRB
			d.VRB 		<= ADCIN(1);	-- VRB
			d.FVER 		<= q.FVER;
			d.HVER 		<= q.HVER;
			d.DAC 		<= DIN when (LOAD = '1') and (shrt_addr = x"06") else q.DAC;
			d.RSTR 		<= DIN when (LOAD = '1') and (shrt_addr = x"07") else q.RSTR;
			d.HB <= std_logic_vector(unsigned(q.HB) + 1);


		  
			
			d.LCLRMT			<= q.CNTLMD(0) or LCLMDIN;
			d.CNTLMDFB		<= q.CNTLMD(15 downto 1) & q.LCLRMT;
			
			d.DACSET			<= q.DAC when q.LCLRMT = '0' else q.LCLPWR;
			DACOUT(0)		<= q.DACSET;			-- Set DAC drive.
			
			REMOTE	<= '1' when q.LCLRMT = '0' else '0';
			LOCAL		<= '1' when q.LCLRMT = '1' else '0';
			


		with shrt_addr select DOUT <=
		  q.CNTLMDFB	when x"00",
		  q.LCLPWR		when x"01",
		  q.IRB			when x"02",
		  q.VRB			when x"03",
		  q.FVER			when x"04",
		  q.HVER			when x"05",
		  q.DACSET		when x"06",
		  q.RSTR 		when x"07",
		  b"000" & x"000" & q.HB(23)		  	when x"08",
		  x"FFFF" 		when others;

end mixed;