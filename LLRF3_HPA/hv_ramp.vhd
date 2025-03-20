

-- This is a variation on dac_ctrl.vhd in which the channel that controls
-- the CPS high voltage is ramped to the set point when hv is turned on

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
use work.HPA.all;

entity hv_ramp is
generic( BASE_ADDR :unsigned(23 downto 0) := x"00006B");
port(
          reset_n      : in std_logic;                     -- system reset
          clock        : in std_logic;                     -- system clock (80MHz)

          hvon         : in std_logic;                     -- hv on/off bit
          -- local bus inputs
          lb_valid     : in std_logic;
          lb_rnw       : in std_logic;                     --
          lb_addr      : in std_logic_vector(23 downto 0); --
          lb_renable   : in std_logic;
          lb_wdata     : in std_logic_vector(15 downto 0); --

          -- dac serial
          sck          : out std_logic;                    -- serial clock
          cs_n         : out std_logic;                    -- chip select (active low)
          sdi          : out std_logic;                    -- serial data (MOSI)

          -- local bus data out
          lb_rdata     : out std_logic_vector(15 downto 0)
     );
end hv_ramp;

--==================================================================================================--
architecture rtl of hv_ramp is

type reg_type is record
    -- bus addressable registers
    data      :std_logic_vector_array16(1 to 8); -- dac data array

    -- internal registers
    rate_cnt     :unsigned(16 downto 0);            -- sample rate counter
    shift_reg    :std_logic_vector(23 downto 0);    -- serial data shift register
    shift_cnt    :unsigned(7 downto 0);             --
    load         :std_logic;
    sck          :unsigned(1 downto 0);
    ramp_cnt     :unsigned(23 downto 0);            -- high voltage ramp rate counter
    hvramp       :unsigned(15 downto 0);            -- high voltage ramp set point
    rdata_buffer :std_logic_vector(15 downto 0);
end record reg_type;

signal D,Q        :reg_type;                      -- register inputs/outputs
signal address    :integer range 0 to 7;          -- calculated address
--signal addr_temp  :std_logic_vector(23 downto 0); -- intermediate calculated address
signal write_edge :std_logic;
signal start      :std_logic;
signal addr_valid :std_logic;
signal SSA_EN     :std_logic_vector(15 downto 0); -- solid state amp enable signal (5V when HV on)

constant CMD         :std_logic_vector(3 downto 0) := "0011";
constant SRATE_LIMIT :integer := 125000; -- 125000/125MHz => 1 msec
constant RAMP_LIMIT  :integer := 9538;  -- 9538/125MHz = 76.3us which gives a ramp rate of ~ 4kV/sec


--==================================================================================================--
begin

address <= to_integer( (unsigned(lb_addr) - BASE_ADDR) ); --conv_integer(addr_temp);

-- check for valid address
addr_valid <= '1' when (unsigned(lb_addr) >= BASE_ADDR and unsigned(lb_addr) < BASE_ADDR+8) else '0';

--                _____
-- local bus read/write
D.load <= lb_valid and not lb_rnw;
write_edge <= '1' when lb_valid = '1' and lb_rnw = '0' and addr_valid = '1' else '0';--write_edge <= Q.load and addr_valid;

-- ramp counter
D.ramp_cnt <= (others => '0') when (Q.ramp_cnt = RAMP_LIMIT or hvon = '0')
            else Q.ramp_cnt + 1 when (hvon = '1' or Q.ramp_cnt > 0)
            else Q.ramp_cnt;

-- hv set point ramping
D.hvramp <= (others => '0') when hvon = '0'
            else Q.hvramp + 1 when (Q.hvramp < unsigned(Q.data(1)) and Q.ramp_cnt = RAMP_LIMIT)
            else Q.hvramp - 1 when (Q.hvramp > unsigned(Q.data(1)) and Q.ramp_cnt = RAMP_LIMIT)
            else Q.hvramp;

-- sample rate counter
D.rate_cnt <= (others => '0') when Q.rate_cnt = SRATE_LIMIT-1 else Q.rate_cnt + 1;

start <= '1' when Q.rate_cnt = 100
               or Q.rate_cnt = 200
               or Q.rate_cnt = 300
               or Q.rate_cnt = 400
               or Q.rate_cnt = 500
               or Q.rate_cnt = 600
               or Q.rate_cnt = 700
               or Q.rate_cnt = 800
               else '0';

-- shift counter
-- Counts out all of the bits for each channel tx (24 (CMD & 'xxxx' & (15 downto 0)) * 4).
D.shift_cnt <= (others => '0') when Q.shift_cnt = 96
               else Q.shift_cnt + 1 when (start = '1' or Q.shift_cnt > 0)
               else Q.shift_cnt;

-- cs_n goes low after a load to a dac register and stays low during serial data shift
cs_n <= '0' when Q.shift_cnt > 0 else '1';


-- serial clock (freq = 31.25Mhz)
D.sck <= Q.sck + 1 when Q.shift_cnt > 0 else "00";
sck <= Q.sck(1);

SSA_EN <= (others => '0') when hvon = '0' else x"7FFF";

-- shift register
D.shift_reg <= (CMD & "0000" & std_logic_vector(Q.hvramp) ) when Q.rate_cnt = 100 else
               (CMD & "0001" & SSA_EN)    when Q.rate_cnt = 200 else
               (CMD & "0010" & Q.data(3)) when Q.rate_cnt = 300 else
               (CMD & "0011" & Q.data(4)) when Q.rate_cnt = 400 else
               (CMD & "0100" & Q.data(5)) when Q.rate_cnt = 500 else
               (CMD & "0101" & Q.data(6)) when Q.rate_cnt = 600 else
               (CMD & "0110" & Q.data(7)) when Q.rate_cnt = 700 else
               (CMD & "0111" & Q.data(8)) when Q.rate_cnt = 800 else
               (Q.shift_reg(22 downto 0) & '0') when Q.sck = "11" else Q.shift_reg;

-- serial data
sdi <= Q.shift_reg(23);

D.data(1)<= lb_wdata when write_edge = '1' and address = 0 else Q.data(1);
D.data(2)<= lb_wdata when write_edge = '1' and address = 1 else Q.data(2);
D.data(3)<= lb_wdata when write_edge = '1' and address = 2 else Q.data(3);
D.data(4)<= lb_wdata when write_edge = '1' and address = 3 else Q.data(4);
D.data(5)<= lb_wdata when write_edge = '1' and address = 4 else Q.data(5);
D.data(6)<= lb_wdata when write_edge = '1' and address = 5 else Q.data(6);
D.data(7)<= lb_wdata when write_edge = '1' and address = 6 else Q.data(7);
D.data(8)<= lb_wdata when write_edge = '1' and address = 7 else Q.data(8);

D.rdata_buffer <= Q.data(address + 1);
lb_rdata <= Q.rdata_buffer;

reg: process(clock,reset_n)
begin
     if (reset_n = '0') then
          Q.shift_reg     <= (others => '0');
          Q.shift_cnt     <= (others => '0');
          Q.load          <= '0';
          Q.sck           <= (others => '0');
          Q.rate_cnt      <= (others => '0');
          Q.ramp_cnt      <= (others => '0');
          Q.hvramp        <= (others => '0');
          Q.data          <= (others => (others => '0'));
          Q.rdata_buffer  <= (others => '0');
     elsif rising_edge(clock) then
          Q <= D;
     end if;
end process reg;

end rtl;