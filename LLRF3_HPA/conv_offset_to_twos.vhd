
-- Description:
--
--      Converts offset binary
--      to two's complement
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity conv_offset_to_twos is
port(
        data_in  :in std_logic_vector(15 downto 0);
        data_out :out std_logic_vector(15 downto 0)
);
end conv_offset_to_twos;

architecture a1 of conv_offset_to_twos is

begin

data_out <= std_logic_vector(unsigned(data_in) + 32768);

end a1;