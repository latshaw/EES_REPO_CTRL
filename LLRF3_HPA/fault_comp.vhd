
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HPA.all;

entity fault_comp is
generic(BASE_ADDR :unsigned(23 downto 0) := x"000073";
        NUM_REGS  :integer := 56);
port (
        reset_n      : in std_logic;                       -- system reset
        clock        : in std_logic;                       -- system clock (125Mhz)

        -- local bus inputs
        lb_valid     : in std_logic;
        lb_rnw       : in std_logic;
        lb_addr      : in std_logic_vector(23 downto 0);
        lb_renable   : in std_logic;
        lb_wdata     : in std_logic_vector(15 downto 0);

        adc          : in std_logic_vector_array16(0 to 63);
        bypass       : in std_logic_vector(7 downto 0);

        -- local bus data out
        lb_rdata     : out std_logic_vector(15 downto 0);

        faults       : out std_logic_vector_array16(0 to 6)
    );
end fault_comp;

architecture rtl of fault_comp is

constant CLK_FREQ :integer := 125000000;

-- registers
type reg_type is record
    trip         :signed_array16(0 to 55); -- trip point array
    --KRRP_timer   :unsigned_array27(0 to 7);  -- 1 sec fault timers for KRRP
    load         :std_logic;
    rdata_buffer :signed(15 downto 0);
end record reg_type;

signal D,Q        :reg_type;               -- register inputs/outputs
signal address    :integer range 0 to 55;  -- calculated address
signal write_edge :std_logic;
signal addr_valid :std_logic;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin

-- calculate address
address <= to_integer( (unsigned(lb_addr) - BASE_ADDR) );

-- check for valid address
addr_valid <= '1' when (unsigned(lb_addr) >= BASE_ADDR and unsigned(lb_addr) < BASE_ADDR+NUM_REGS) else '0';

--                _____
-- local bus read/write
D.load <= lb_valid and not lb_rnw;
write_edge <= '1' when lb_valid = '1' and lb_rnw = '0' and addr_valid = '1' else '0';--Q.load and addr_valid;

-- trip point registers
g1: for i in 0 to 55 generate
        D.trip(i) <= signed(lb_wdata) when (write_edge = '1' and address = i) else Q.trip(i);
    end generate g1;

D.rdata_buffer <= Q.trip(address);
lb_rdata <= std_logic_vector(Q.rdata_buffer);

g7: for i in 0 to 7 generate

        -- filament voltage high 1-8 (adc index 0-7, trip index 0-7)
        faults(0)(i) <= '1' when signed(adc(i)) > Q.trip(i) else '0';

        -- filament voltage low 1-8 (adc index 0-7, trip index 8-15)
        faults(1)(i) <= '0' when bypass(i) = '1' else '1' when signed(adc(i)) < Q.trip(i+8) else '0';

        -- body current high 1-8 (adc index 32-39)
        faults(2)(i) <= '1' when signed(adc(i+32)) > Q.trip(i+32) else '0';

        -- cathode current high 1-8 (adc index 40-47)
        faults(3)(i) <= '1' when signed(adc(i+40)) > Q.trip(i+40) else '0';

        -- klystron reflected power high 1-8 (adc index 48-55) with 1 sec fault window
        --D.KRRP_timer(i) <= (others => '0') when signed(adc(i+48)) > Q.trip(i+48)
          --                  else Q.KRRP_timer(i) when Q.KRRP_timer(i) = CLK_FREQ
            --                else Q.KRRP_timer(i) + 1;

        faults(4)(i) <= '1' when signed(adc(i+48)) < Q.trip(i+48) else '0';--'1' when Q.KRRP_timer(i) = CLK_FREQ else '0';		  

        -- mod anode current high 1-8 (adc index 24-31)
        faults(5)(i) <= '1' when signed(adc(i+24)) > Q.trip(i+24) else '0';

        -- mod anode voltage high 1-8 (adc index 16-23)
        faults(6)(i) <= '1' when signed(adc(i+16)) > Q.trip(i+16) else '0';

    end generate g7;

reg: process(reset_n,clock)
begin
    if (reset_n = '0') then
        Q.trip         <= (others => (others => '0'));
        --Q.KRRP_timer   <= (others => (others => '0'));
        Q.load         <= '0';
        Q.rdata_buffer <= (others => '0');
    elsif rising_edge(clock) then
        Q <= D;
    end if;
end process reg;

end rtl;
