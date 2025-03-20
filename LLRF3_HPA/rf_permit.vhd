
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rf_permit is
port(
     reset_n :in std_logic;
     clock   :in std_logic;

     rf_permit_in :in std_logic_vector(7 downto 0);
     rf_permit_out :out std_logic_vector(7 downto 0)
);
end rf_permit;


architecture rtl of rf_permit is

constant CLK_CNT_LIMIT :integer := 9;

type reg_type is record
     counter :integer range 0 to CLK_CNT_LIMIT;
     clk_out :std_logic;
end record;

signal D,Q :reg_type;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin

D.counter <= Q.counter + 1 when Q.counter < CLK_CNT_LIMIT else 0;
D.clk_out <= not Q.clk_out when Q.counter = CLK_CNT_LIMIT else Q.clk_out;

g1: for i in 0 to 7 generate
     rf_permit_out(i) <= Q.clk_out when rf_permit_in(i) = '1' else '1';
end generate g1;

reg: process(reset_n,clock)
begin
     if (reset_n = '0') then
          Q.counter <= 0;
          Q.clk_out <= '0'; 
     elsif rising_edge(clock) then
          Q <= D;
     end if;
end process reg;

end rtl;