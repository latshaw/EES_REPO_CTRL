-- Ensures that the HV enable signals from all FCCs are present.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity hv_permit is
port(
     reset_n       :in std_logic;
     clock         :in std_logic;

     hv_permit_in  :in std_logic_vector(7 downto 0); -- 5MHz HV Permits from FCCs
     hv_permit_out :out std_logic_vector(7 downto 0)
);
end hv_permit;

architecture rtl of hv_permit is

type counter_array is array(natural range <>) of integer range 0 to 200;
type buf_array is array(natural range <>) of unsigned(2 downto 0);

type reg_type is record
     counter :counter_array(0 to 7);
     buf     :buf_array(0 to 7);
end record;

signal D,Q            :reg_type;
signal hv_permit_edge :unsigned(7 downto 0);

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin


g1: for i in 0 to 7 generate
     D.buf(i)(0) <= hv_permit_in(i);
     D.buf(i)(1) <= Q.buf(i)(0);
     D.buf(i)(2) <= Q.buf(i)(1);

     hv_permit_edge(i) <= '1' when (Q.buf(i)(2) xor Q.buf(i)(1)) = '1' else '0';

     D.counter(i) <= 0 when hv_permit_edge(i) = '1'
               else Q.counter(i) + 1 when Q.counter(i) < 200
               else Q.counter(i);

     hv_permit_out(i) <= '0' when Q.counter(i) = 200 else '1'; -- fault when no signal for 200/Fclk = 1.6us
end generate g1;


reg: process(reset_n,clock)
begin
     if (reset_n = '0') then
          Q.counter <= (others => 0);
          Q.buf     <= (others => (others => '0'));
     elsif rising_edge(clock) then
          Q <= D;
     end if;
end process reg;

end rtl;