library ieee;
use ieee.std_logic_1164.all;

package components is

type reg13_16 is array(15 downto 0) of std_logic_vector(12 downto 0);
type reg16_16 is array(15 downto 0) of std_logic_vector(15 downto 0);
type reg16_18 is array(15 downto 0) of std_logic_vector(17 downto 0);
type reg8_16_18 is array (7 downto 0) of reg16_18;
type reg16_16_18 is array (15 downto 0) of reg16_18;
type reg16_19 is array(15 downto 0) of std_logic_vector(18 downto 0);
type reg16_8 is array(7 downto 0) of std_logic_vector(15 downto 0);
type reg18_8 is array(7 downto 0) of std_logic_vector(17 downto 0);
type reg16_10 is array(9 downto 0) of std_logic_vector(15 downto 0);
type reg18_10 is array(9 downto 0) of std_logic_vector(17 downto 0);
type reg18_9 is array (8 downto 0) of std_logic_vector(17 downto 0);
type reg16_4 is array(3 downto 0) of std_logic_vector(15 downto 0);
type reg18_26 is array(17 downto 0) of std_logic_vector(25 downto 0);
type reg18_4 is array(3 downto 0) of std_logic_vector(17 downto 0);
type reg9_8 is array(8 downto 0) of std_logic_vector(7 downto 0);



end package components;

