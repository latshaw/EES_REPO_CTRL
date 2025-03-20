-- Gets filament setpoint data from the EPICS connected local bus to pass to other modules and feeds the current filament value back to the local bus.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
use work.HPA.all;

entity fil_regs is
generic( BASE_ADDR :unsigned(23 downto 0) := x"00005B");
port (
        reset_n     : in std_logic;                      -- system reset
        clock       : in std_logic;                      -- system clock (125MHz)

        -- local bus inputs
        lb_valid     : in std_logic;
        lb_rnw       : in std_logic;                     --
        lb_addr      : in std_logic_vector(23 downto 0); --
        lb_renable   : in std_logic;
        lb_wdata     : in std_logic_vector(15 downto 0); --

        -- local bus data out
        lb_rdata     : out std_logic_vector(15 downto 0);

        fil_set      : out std_logic_vector_array16(0 to 7)
     );
end fil_regs;

architecture rtl of fil_regs is

-- register signals
type reg_type is record
    filsetpoint  :std_logic_vector_array16(0 to 7); -- set point registers
    load         :std_logic;
    rdata_buffer :std_logic_vector(15 downto 0);
end record reg_type;

signal D,Q        :reg_type;                      -- register inputs/outputs
--signal addr_temp  :std_logic_vector(23 downto 0); -- intermidiate calculated address
signal address    :integer range 0 to 7;          -- calculated address
signal write_edge :std_logic;
signal addr_valid :std_logic;


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin

-- calculate address
--addr_temp <= (lb_addr - BASE_ADDR) when (lb_addr >= BASE_ADDR and lb_addr < BASE_ADDR+8)
--            else (others => '0');

address <= to_integer( (unsigned(lb_addr) - BASE_ADDR) );

-- check for valid address
addr_valid <= '1' when (unsigned(lb_addr) >= BASE_ADDR and unsigned(lb_addr) < BASE_ADDR+8) else '0';
--                _____
-- local bus read/write
D.load <= lb_valid and not lb_rnw;
write_edge <= '1' when lb_valid = '1' and lb_rnw = '0' and addr_valid = '1' else '0';--write_edge <= Q.load and addr_valid;

g1: for i in 0 to 7 generate
    D.filsetpoint(i) <= lb_wdata when write_edge = '1' and address = i
                        else Q.filsetpoint(i);
    end generate g1;

D.rdata_buffer <= Q.filsetpoint(address); -- index into register block
lb_rdata <= Q.rdata_buffer;
fil_set <= Q.filsetpoint;

reg: process(clock,reset_n)
begin
	if (reset_n = '0') then
      Q.filsetpoint <= (others => (others => '0'));
      Q.load <= '0';
      Q.rdata_buffer <= (others => '0');
	elsif rising_edge(clock) then
		Q <= D;
	end if;
end process reg;

end rtl;