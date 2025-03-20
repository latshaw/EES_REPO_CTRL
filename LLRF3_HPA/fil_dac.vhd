-- Sets the output value for each of the filament channels.
-- D/A Converter controller for Linear Technology LTC2600

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HPA.all;

entity fil_dac is
port(
        reset_n  : in std_logic;                     -- system reset
        clock    : in std_logic;                     -- system clock (125MHz)

        load     : in std_logic;                     --
        data     : in std_logic_vector(15 downto 0); --
        addr     : in std_logic_vector(2 downto 0);  --

        sck      : out std_logic;                    -- serial clock
        cs_n     : out std_logic;                    -- chip select (active low)
        sdi      : out std_logic                     -- serial data (MOSI)
     );
end fil_dac;

architecture rtl of fil_dac is

-- registers
type reg_type is record
    -- bus addressable registers
    data         :std_logic_vector_array16(1 to 8); -- dac set registers

    -- internal registers
    rate_cnt     :unsigned(16 downto 0);         -- sample rate counter
    shift_reg    :std_logic_vector(23 downto 0); -- serial data shift register
    shift_cnt    :unsigned(7 downto 0);          -- serial shift counter
    sck          :unsigned(1 downto 0);
end record reg_type;

signal D,Q           :reg_type;                      -- register inputs/outputs
signal address       :integer range 0 to 7;          -- calculated address
signal write_edge    :std_logic;
signal start         :std_logic;

constant CMD         :std_logic_vector(3 downto 0) := "0011";
constant SRATE_LIMIT :integer := 125000; -- 125000/125MHz => 1 msec

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin

-- convert address to integer
address <= to_integer(unsigned(addr));

-- sample rate counter
D.rate_cnt <= (others => '0') when Q.rate_cnt = SRATE_LIMIT-1 else Q.rate_cnt + 1;

-- start triggers for serial transmit
start <= '1' when Q.rate_cnt = 100 -- D/A channel 1
               or Q.rate_cnt = 200 -- D/A channel 2
               or Q.rate_cnt = 300
               or Q.rate_cnt = 400
               or Q.rate_cnt = 500
               or Q.rate_cnt = 600
               or Q.rate_cnt = 700
               or Q.rate_cnt = 800 -- D/A channel 8
               else '0';

-- shift counter
-- Counts out all of the bits for each channel tx (24 (CMD & 'xxxx' & (15 downto 0)) * 4).
D.shift_cnt <= (others => '0') when Q.shift_cnt = 96
               else Q.shift_cnt + 1 when (start = '1' or Q.shift_cnt > 0)
               else Q.shift_cnt;

-- chip select
cs_n <= '0' when Q.shift_cnt > 0 else '1';

-- serial clock (freq = Fclk/4)
D.sck <= Q.sck + 1 when Q.shift_cnt > 0 else "00";
sck <= Q.sck(1);

-- shift register
D.shift_reg <= (CMD & "0000" & Q.data(1)) when Q.rate_cnt = 100 else
               (CMD & "0001" & Q.data(2)) when Q.rate_cnt = 200 else
               (CMD & "0010" & Q.data(3)) when Q.rate_cnt = 300 else
               (CMD & "0011" & Q.data(4)) when Q.rate_cnt = 400 else
               (CMD & "0100" & Q.data(5)) when Q.rate_cnt = 500 else
               (CMD & "0101" & Q.data(6)) when Q.rate_cnt = 600 else
               (CMD & "0110" & Q.data(7)) when Q.rate_cnt = 700 else
               (CMD & "0111" & Q.data(8)) when Q.rate_cnt = 800 else
               (Q.shift_reg(22 downto 0) & '0') when Q.sck = "11" else Q.shift_reg;

-- serial data out
sdi <= Q.shift_reg(23);
--Load in DAC setpoints given from fil_mux.
D.data(1)<= data when load = '1' and address = 0 else Q.data(1);
D.data(2)<= data when load = '1' and address = 1 else Q.data(2);
D.data(3)<= data when load = '1' and address = 2 else Q.data(3);
D.data(4)<= data when load = '1' and address = 3 else Q.data(4);
D.data(5)<= data when load = '1' and address = 4 else Q.data(5);
D.data(6)<= data when load = '1' and address = 5 else Q.data(6);
D.data(7)<= data when load = '1' and address = 6 else Q.data(7);
D.data(8)<= data when load = '1' and address = 7 else Q.data(8);


reg: process(clock,reset_n)
begin
     if (reset_n = '0') then
          Q.shift_reg     <= (others => '0');
          Q.shift_cnt     <= (others => '0');
          Q.sck           <= (others => '0');
          Q.rate_cnt      <= (others => '0');
          Q.data          <= (others => (others => '0'));
     elsif rising_edge(clock) then
          Q <= D;
     end if;
end process reg;

end rtl;