
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.hpa.all;

entity adc_remap is
port(
    reset_n :in std_logic;
    clock   :in std_logic;

    adc_in  :in std_logic_vector_array16(0 to 63);
    adc_out :out std_logic_vector_array16(0 to 63)
);
end adc_remap;

architecture rtl of adc_remap is

type reg_type is record
    reg :std_logic_vector_array16(0 to 63);
end record reg_type;

signal D,Q :reg_type;

-- physical channel mapping index
constant KFVM3 :integer := 0;
constant KMAV3 :integer := 1;
constant KFVM4 :integer := 2;
constant KMAV4 :integer := 3;
constant KBCU3 :integer := 4;
constant KCCU3 :integer := 5;
constant KBCU4 :integer := 6;
constant KCCU4 :integer := 7;
constant KCCU2 :integer := 8;
constant KBCU2 :integer := 9;
constant KCCU1 :integer := 10;
constant KBCU1 :integer := 11;
constant KMAV2 :integer := 12;
constant KFVM2 :integer := 13;
constant KMAV1 :integer := 14;
constant KFVM1 :integer := 15;
constant KFVM7 :integer := 16;
constant KMAV7 :integer := 17;
constant KFVM8 :integer := 18;
constant KMAV8 :integer := 19;
constant KBCU7 :integer := 20;
constant KCCU7 :integer := 21;
constant KBCU8 :integer := 22;
constant KCCU8 :integer := 23;
constant KCCU6 :integer := 24;
constant KBCU6 :integer := 25;
constant KCCU5 :integer := 26;
constant KBCU5 :integer := 27;
constant KMAV6 :integer := 28;
constant KFVM6 :integer := 29;
constant KMAV5 :integer := 30;
constant KFVM5 :integer := 31;
constant KFIM1 :integer := 32;
constant KFIM2 :integer := 33;
constant KFIM5 :integer := 34;
constant KFIM6 :integer := 35;
constant KFIM3 :integer := 36;
constant KFIM4 :integer := 37;
constant KFIM7 :integer := 38;
constant KFIM8 :integer := 39;
constant TM4   :integer := 40;
constant TM3   :integer := 41;
constant KMAI8 :integer := 42;
constant KMAI7 :integer := 43;
constant TM2   :integer := 44;
constant TM1   :integer := 45;
constant KMAI6 :integer := 46;
constant KMAI5 :integer := 47;
constant KMAI4 :integer := 48;
constant KMAI3 :integer := 49;
constant KPSV  :integer := 50;
constant KPSI  :integer := 51;
constant KMAI2 :integer := 52;
constant KMAI1 :integer := 53;
constant ADC0  :integer := 54;
constant ADC1  :integer := 55;
constant KRRP8 :integer := 56;
constant KRRP7 :integer := 57;
constant KRRP4 :integer := 58;
constant KRRP3 :integer := 59;
constant KRRP6 :integer := 60;
constant KRRP5 :integer := 61;
constant KRRP2 :integer := 62;
constant KRRP1 :integer := 63;

--<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<--
begin

-- channel re-mapping based on HRT
D.reg(0)  <= adc_in(KFVM1);
D.reg(1)  <= adc_in(KFVM2);
D.reg(2)  <= adc_in(KFVM3);
D.reg(3)  <= adc_in(KFVM4);
D.reg(4)  <= adc_in(KFVM5);
D.reg(5)  <= adc_in(KFVM6);
D.reg(6)  <= adc_in(KFVM7);
D.reg(7)  <= adc_in(KFVM8);
D.reg(8)  <= std_logic_vector(unsigned(adc_in(KFIM1)) + 32768); -- Filament current is unsigned
D.reg(9)  <= std_logic_vector(unsigned(adc_in(KFIM2)) + 32768);
D.reg(10) <= std_logic_vector(unsigned(adc_in(KFIM3)) + 32768);
D.reg(11) <= std_logic_vector(unsigned(adc_in(KFIM4)) + 32768);
D.reg(12) <= std_logic_vector(unsigned(adc_in(KFIM5)) + 32768);
D.reg(13) <= std_logic_vector(unsigned(adc_in(KFIM6)) + 32768);
D.reg(14) <= std_logic_vector(unsigned(adc_in(KFIM7)) + 32768);
D.reg(15) <= std_logic_vector(unsigned(adc_in(KFIM8)) + 32768);
D.reg(16) <= adc_in(KMAV1);
D.reg(17) <= adc_in(KMAV2);
D.reg(18) <= adc_in(KMAV3);
D.reg(19) <= adc_in(KMAV4);
D.reg(20) <= adc_in(KMAV5);
D.reg(21) <= adc_in(KMAV6);
D.reg(22) <= adc_in(KMAV7);
D.reg(23) <= adc_in(KMAV8);
D.reg(24) <= adc_in(KMAI1);
D.reg(25) <= adc_in(KMAI2);
D.reg(26) <= adc_in(KMAI3);
D.reg(27) <= adc_in(KMAI4);
D.reg(28) <= adc_in(KMAI5);
D.reg(29) <= adc_in(KMAI6);
D.reg(30) <= adc_in(KMAI7);
D.reg(31) <= adc_in(KMAI8);
D.reg(32) <= adc_in(KBCU1);
D.reg(33) <= adc_in(KBCU2);
D.reg(34) <= adc_in(KBCU3);
D.reg(35) <= adc_in(KBCU4);
D.reg(36) <= adc_in(KBCU5);
D.reg(37) <= adc_in(KBCU6);
D.reg(38) <= adc_in(KBCU7);
D.reg(39) <= adc_in(KBCU8);
D.reg(40) <= adc_in(KCCU1);
D.reg(41) <= adc_in(KCCU2);
D.reg(42) <= adc_in(KCCU3);
D.reg(43) <= adc_in(KCCU4);
D.reg(44) <= adc_in(KCCU5);
D.reg(45) <= adc_in(KCCU6);
D.reg(46) <= adc_in(KCCU7);
D.reg(47) <= adc_in(KCCU8);
D.reg(48) <= adc_in(KRRP1);
D.reg(49) <= adc_in(KRRP2);
D.reg(50) <= adc_in(KRRP3);
D.reg(51) <= adc_in(KRRP4);
D.reg(52) <= adc_in(KRRP5);
D.reg(53) <= adc_in(KRRP6);
D.reg(54) <= adc_in(KRRP7);
D.reg(55) <= adc_in(KRRP8);
D.reg(56) <= adc_in(TM1);
D.reg(57) <= adc_in(TM2);
D.reg(58) <= adc_in(TM3);
D.reg(59) <= adc_in(TM4);
D.reg(60) <= adc_in(KPSV);
D.reg(61) <= adc_in(KPSI);
D.reg(62) <= adc_in(ADC0);
D.reg(63) <= adc_in(ADC1);

adc_out <= Q.reg;

reg: process(reset_n,clock)
begin
if reset_n = '0' then
    Q <= (others => (others => (others => '0')));
elsif rising_edge(clock) then
     Q <= D;
end if;
end process reg;

end rtl;