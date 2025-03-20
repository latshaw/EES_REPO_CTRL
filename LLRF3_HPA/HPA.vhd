
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package HPA is

type std_logic_vector_array2 is array(natural range <>) of std_logic_vector(1 downto 0);
type std_logic_vector_array3 is array(natural range <>) of std_logic_vector(2 downto 0);
type std_logic_vector_array4 is array(natural range <>) of std_logic_vector(3 downto 0);
type std_logic_vector_array5 is array(natural range <>) of std_logic_vector(4 downto 0);
type std_logic_vector_array6 is array(natural range <>) of std_logic_vector(5 downto 0);
type std_logic_vector_array7 is array(natural range <>) of std_logic_vector(6 downto 0);
type std_logic_vector_array8 is array(natural range <>) of std_logic_vector(7 downto 0);
type std_logic_vector_array9 is array(natural range <>) of std_logic_vector(8 downto 0);
type std_logic_vector_array10 is array(natural range <>) of std_logic_vector(9 downto 0);
type std_logic_vector_array11 is array(natural range <>) of std_logic_vector(10 downto 0);
type std_logic_vector_array12 is array(natural range <>) of std_logic_vector(11 downto 0);
type std_logic_vector_array13 is array(natural range <>) of std_logic_vector(12 downto 0);
type std_logic_vector_array14 is array(natural range <>) of std_logic_vector(13 downto 0);
type std_logic_vector_array15 is array(natural range <>) of std_logic_vector(14 downto 0);
type std_logic_vector_array16 is array(natural range <>) of std_logic_vector(15 downto 0);
type std_logic_vector_array17 is array(natural range <>) of std_logic_vector(16 downto 0);
type std_logic_vector_array18 is array(natural range <>) of std_logic_vector(17 downto 0);
type std_logic_vector_array19 is array(natural range <>) of std_logic_vector(18 downto 0);
type std_logic_vector_array20 is array(natural range <>) of std_logic_vector(19 downto 0);
type std_logic_vector_array21 is array(natural range <>) of std_logic_vector(20 downto 0);
type std_logic_vector_array22 is array(natural range <>) of std_logic_vector(21 downto 0);
type std_logic_vector_array23 is array(natural range <>) of std_logic_vector(22 downto 0);
type std_logic_vector_array24 is array(natural range <>) of std_logic_vector(23 downto 0);
type std_logic_vector_array25 is array(natural range <>) of std_logic_vector(24 downto 0);
type std_logic_vector_array26 is array(natural range <>) of std_logic_vector(25 downto 0);
type std_logic_vector_array27 is array(natural range <>) of std_logic_vector(26 downto 0);
type std_logic_vector_array28 is array(natural range <>) of std_logic_vector(27 downto 0);
type std_logic_vector_array29 is array(natural range <>) of std_logic_vector(28 downto 0);
type std_logic_vector_array30 is array(natural range <>) of std_logic_vector(29 downto 0);
type std_logic_vector_array31 is array(natural range <>) of std_logic_vector(30 downto 0);
type std_logic_vector_array32 is array(natural range <>) of std_logic_vector(31 downto 0);

type unsigned_array2 is array(natural range <>) of unsigned(1 downto 0);
type unsigned_array3 is array(natural range <>) of unsigned(2 downto 0);
type unsigned_array4 is array(natural range <>) of unsigned(3 downto 0);
type unsigned_array5 is array(natural range <>) of unsigned(4 downto 0);
type unsigned_array6 is array(natural range <>) of unsigned(5 downto 0);
type unsigned_array7 is array(natural range <>) of unsigned(6 downto 0);
type unsigned_array8 is array(natural range <>) of unsigned(7 downto 0);
type unsigned_array9 is array(natural range <>) of unsigned(8 downto 0);
type unsigned_array10 is array(natural range <>) of unsigned(9 downto 0);
type unsigned_array11 is array(natural range <>) of unsigned(10 downto 0);
type unsigned_array12 is array(natural range <>) of unsigned(11 downto 0);
type unsigned_array13 is array(natural range <>) of unsigned(12 downto 0);
type unsigned_array14 is array(natural range <>) of unsigned(13 downto 0);
type unsigned_array15 is array(natural range <>) of unsigned(14 downto 0);
type unsigned_array16 is array(natural range <>) of unsigned(15 downto 0);
type unsigned_array17 is array(natural range <>) of unsigned(16 downto 0);
type unsigned_array18 is array(natural range <>) of unsigned(17 downto 0);
type unsigned_array19 is array(natural range <>) of unsigned(18 downto 0);
type unsigned_array20 is array(natural range <>) of unsigned(19 downto 0);
type unsigned_array21 is array(natural range <>) of unsigned(20 downto 0);
type unsigned_array22 is array(natural range <>) of unsigned(21 downto 0);
type unsigned_array23 is array(natural range <>) of unsigned(22 downto 0);
type unsigned_array24 is array(natural range <>) of unsigned(23 downto 0);
type unsigned_array25 is array(natural range <>) of unsigned(24 downto 0);
type unsigned_array26 is array(natural range <>) of unsigned(25 downto 0);
type unsigned_array27 is array(natural range <>) of unsigned(26 downto 0);
type unsigned_array28 is array(natural range <>) of unsigned(27 downto 0);
type unsigned_array29 is array(natural range <>) of unsigned(28 downto 0);
type unsigned_array30 is array(natural range <>) of unsigned(29 downto 0);
type unsigned_array31 is array(natural range <>) of unsigned(30 downto 0);
type unsigned_array32 is array(natural range <>) of unsigned(31 downto 0);

type signed_array2 is array(natural range <>) of signed(1 downto 0);
type signed_array3 is array(natural range <>) of signed(2 downto 0);
type signed_array4 is array(natural range <>) of signed(3 downto 0);
type signed_array5 is array(natural range <>) of signed(4 downto 0);
type signed_array6 is array(natural range <>) of signed(5 downto 0);
type signed_array7 is array(natural range <>) of signed(6 downto 0);
type signed_array8 is array(natural range <>) of signed(7 downto 0);
type signed_array9 is array(natural range <>) of signed(8 downto 0);
type signed_array10 is array(natural range <>) of signed(9 downto 0);
type signed_array11 is array(natural range <>) of signed(10 downto 0);
type signed_array12 is array(natural range <>) of signed(11 downto 0);
type signed_array13 is array(natural range <>) of signed(12 downto 0);
type signed_array14 is array(natural range <>) of signed(13 downto 0);
type signed_array15 is array(natural range <>) of signed(14 downto 0);
type signed_array16 is array(natural range <>) of signed(15 downto 0);
type signed_array17 is array(natural range <>) of signed(16 downto 0);
type signed_array18 is array(natural range <>) of signed(17 downto 0);
type signed_array19 is array(natural range <>) of signed(18 downto 0);
type signed_array20 is array(natural range <>) of signed(19 downto 0);
type signed_array21 is array(natural range <>) of signed(20 downto 0);
type signed_array22 is array(natural range <>) of signed(21 downto 0);
type signed_array23 is array(natural range <>) of signed(22 downto 0);
type signed_array24 is array(natural range <>) of signed(23 downto 0);
type signed_array25 is array(natural range <>) of signed(24 downto 0);
type signed_array26 is array(natural range <>) of signed(25 downto 0);
type signed_array27 is array(natural range <>) of signed(26 downto 0);
type signed_array28 is array(natural range <>) of signed(27 downto 0);
type signed_array29 is array(natural range <>) of signed(28 downto 0);
type signed_array30 is array(natural range <>) of signed(29 downto 0);
type signed_array31 is array(natural range <>) of signed(30 downto 0);
type signed_array32 is array(natural range <>) of signed(31 downto 0);


constant XKHRTB  :integer := 0;
constant HPARSTR :integer := 1;
constant XKHRTV  :integer := 2;
constant XKFIRMV :integer := 3;
constant XKDIN   :integer := 4;
constant XKDOUT  :integer := 5;
constant XKFWT   :integer := 6;
constant XKDAQ   :integer := 7;
constant XKFLTC  :integer := 8;
constant XKRFP   :integer := 9;
constant XKCSR   :integer := 10;
constant XKBYP   :integer := 11;
constant KFLT1   :integer := 12;
constant KFLT2   :integer := 13;
constant KFLT3   :integer := 14;
constant KFLT4   :integer := 15;
constant KFLT5   :integer := 16;
constant KFLT6   :integer := 17;
constant KFLT7   :integer := 18;
constant KFLT8   :integer := 19;
constant KFLTC1  :integer := 20;
constant KFLTC2  :integer := 21;
constant KFLTC3  :integer := 22;
constant KFLTC4  :integer := 23;
constant KFLTC5  :integer := 24;
constant KFLTC6  :integer := 25;
constant KFLTC7  :integer := 26;
constant KFLTC8  :integer := 27;


end;

package body HPA is

end package body;