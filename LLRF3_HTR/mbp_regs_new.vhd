--Register interface for engineers to use
--Mimics ISA regs interface, uses short address
--20 March 2024 update
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
--use work.mbp_lib.all;
--
entity mbp_regs_new is
	generic(
			--This number must equal the number of registers you use.
			--Example: 10 is Registers 0-9
			HRTREGS	:	natural := 7
			);
	port(
		--Static MBP ports begin
		CLK		:	in std_logic;
		RESET	:	in std_logic; --ACTIVE HIGH!!!
		LOAD	:	in std_logic;
		ADDR	:	in std_logic_vector(15 downto 0);
		DIN		:	in std_logic_vector(15 downto 0);
		DOUT	:	out std_logic_vector(15 downto 0);
		--Static MBP ports end
		--User ports begin:
		hrtbt : in std_logic
		--User ports end.  Do not forget to omit final semicolon
		);
end mbp_regs_new;
architecture mixed of mbp_regs_new is
	type word_array is array(natural range <>) of std_logic_vector(15 downto 0);
	--
	signal shrt_addr : std_logic_vector(7 downto 0) := x"00";
	signal reg_ena : std_logic_vector(0 to (HRTREGS -1)) := (others => '0');
	signal exc_ff : std_logic_vector(7 downto 0) := (others => '0');
	type dff is record
		reg : word_array(0 to (HRTREGS -1));-- := (others => x"FFFF");
	end record dff;
	signal d,q : dff;
	--
begin
	--ISA addr conversion
	shrt_addr <= ADDR(7 downto 0);
	--
	process(reset,clk)
	begin
		if(rising_edge(clk)) then
			if reset = '1' then
				q.reg <= (others => x"0000");
				--q.reg(1) <= x"DEAD";
				--q.reg(2) <= x"BEEF";
			else
				q <= d;
			end if;
		end if;
	end process;	
	--
	--Register logic:
	--Paste VHDL code from "VHDL_HRT" table in Excel spreadsheet
	--You can add conditions to the enable statement to control R/W access
	reg_ena(0) <= '1' when (LOAD = '1') and (shrt_addr = x"00") else '0';   d.reg(0) <= DIN;
	reg_ena(1) <= '1';   d.reg(1) <= x"DEAD";
	reg_ena(2) <= '1';   d.reg(2) <= x"BEEF";
	reg_ena(3) <= '1' when (LOAD = '1') and (shrt_addr = x"03") else '0';   d.reg(3) <= DIN;
	reg_ena(4) <= '1' when (LOAD = '1') and (shrt_addr = x"04") else '0';   d.reg(4) <= DIN;
	reg_ena(5) <= '1' when (LOAD = '1') and (shrt_addr = x"05") else '0';   d.reg(5) <= DIN;
	reg_ena(6) <= '1' when (LOAD = '1') and (shrt_addr = x"06") else '0';   d.reg(6) <= DIN;
	reg_ena(7) <= '1';   d.reg(7) <= x"AAAA";
	reg_ena(8) <= '1';   d.reg(8) <= x"BBBB";
	reg_ena(9) <= '1';   d.reg(9) <= x"CCCC";
	reg_ena(10) <= '1';   d.reg(10) <= x"DDDD";
	reg_ena(11) <= '1' when (LOAD = '1') and (shrt_addr = x"0B") else '0';   d.reg(11) <= DIN;
	reg_ena(12) <= '1';   d.reg(12) <= x"0000";
	--
    with shrt_addr select DOUT <=
    q.reg(0) when x"00",
    q.reg(1) when x"01",
    q.reg(2) when x"02",
    q.reg(3) when x"03",
    q.reg(4) when x"04",
    q.reg(5) when x"05",
    q.reg(6) when x"06",
    q.reg(7) when x"07",
    q.reg(8) when x"08",
    q.reg(9) when x"09",
    q.reg(10) when x"0A",
    q.reg(11) when x"0B",
    q.reg(12) when x"0C",
	x"FFFF" when others;



end mixed;