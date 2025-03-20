
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
generic(N :positive := 16);
port(
     reset_n     :in std_logic;
     clock       :in std_logic;

     count       :out std_logic_vector(N-1 downto 0)
);
end counter;


architecture rtl of counter is


type reg_type is record
count     :unsigned(N-1 downto 0);
end record reg_type;

signal D,Q :reg_type;

begin

D.count <= Q.count + 1;

count <= std_logic_vector(Q.count);


process(reset_n,clock)
begin
     if reset_n = '0' then
          Q.count <= (others => '0');
     elsif rising_edge(clock) then
          Q <= D;
     end if;
end process;

end rtl;