--3/20/2025 added a clock and lb_valid to keep lb_addr stable
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_mux is
port(
	 clock       : in std_logic; -- clock
	 lb_valid    : in std_logic; -- hi if local bus is valid
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

signal lb_addr_r : std_logic_vector(23 downto 0); 

begin

-- when we have a lb_valid strobe, register the new address
process (clock, lb_valid, lb_addr)
begin
	if clock'event and clock = '1' then
		-- watch for new udp packet local bus valid signal to go HI. When it does, register the new address
		if   (lb_valid='1') then
			lb_addr_r <= lb_addr;
		end if;
		--
	end if;
end process;

-- note, address used is lb_addr_r
lb_rdata <= std_logic_vector(resize(unsigned(registers),32)) when unsigned(lb_addr_r) < REGISTERS_LAST+1 else
            std_logic_vector(resize(signed(adc),32)) when unsigned(lb_addr_r) < ADC_LAST+1 else
            std_logic_vector(resize(unsigned(fil),32)) when unsigned(lb_addr_r) < FIL_LAST+1 else
            std_logic_vector(resize(unsigned(dac),32)) when unsigned(lb_addr_r) < DAC_LAST+1 else
            std_logic_vector(resize(unsigned(hv),32)) when unsigned(lb_addr_r) < HV_LAST+1 else
            std_logic_vector(resize(unsigned(trip),32));

--lb_rdata <= std_logic_vector(resize(signed(adc),32));

end arch;