
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_mux is
port(
    lb_addr     :in std_logic_vector(23 downto 0); -- local bus address
    registers   :in std_logic_vector(15 downto 0); -- main control/status registers
    adc         :in std_logic_vector(15 downto 0); -- analog input registers
    fil         :in std_logic_vector(15 downto 0); -- filament set point registers
    dac         :in std_logic_vector(15 downto 0); -- mod anode set point registers
    hv          :in std_logic_vector(15 downto 0); -- high voltage/spares set points
    trip        :in std_logic_vector(15 downto 0); -- fault trip point registers

    lb_rdata    :out std_logic_vector(31 downto 0) -- local bus read data
);
end bus_mux;

architecture arch of bus_mux is

-- last address of each register set
constant REGISTERS_LAST :integer := 27;
constant ADC_LAST       :integer := 91;
constant FIL_LAST       :integer := 99;
constant DAC_LAST       :integer := 107;
constant HV_LAST        :integer := 115;
constant TRIP_LAST      :integer := 171;

begin

lb_rdata <= std_logic_vector(resize(unsigned(registers),32)) when unsigned(lb_addr) < REGISTERS_LAST+1 else
            std_logic_vector(resize(signed(adc),32)) when unsigned(lb_addr) < ADC_LAST+1 else
            std_logic_vector(resize(unsigned(fil),32)) when unsigned(lb_addr) < FIL_LAST+1 else
            std_logic_vector(resize(unsigned(dac),32)) when unsigned(lb_addr) < DAC_LAST+1 else
            std_logic_vector(resize(unsigned(hv),32)) when unsigned(lb_addr) < HV_LAST+1 else
            std_logic_vector(resize(unsigned(trip),32));

--lb_rdata <= std_logic_vector(resize(signed(adc),32));

end arch;