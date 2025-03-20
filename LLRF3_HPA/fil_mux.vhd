--"Thoughts" Polls outputs of all fil_ctrl modules and passes the setpoint to the dac module.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

entity fil_mux is
port(
        reset_n       : in std_logic;                     -- system reset
        clock         : in std_logic;                     -- system clock (125MHz)
        
        update        : in std_logic;
        filsetout1    : in std_logic_vector(15 downto 0);
        filsetout2    : in std_logic_vector(15 downto 0);
        filsetout3    : in std_logic_vector(15 downto 0);
        filsetout4    : in std_logic_vector(15 downto 0);
        filsetout5    : in std_logic_vector(15 downto 0);
        filsetout6    : in std_logic_vector(15 downto 0);
        filsetout7    : in std_logic_vector(15 downto 0);
        filsetout8    : in std_logic_vector(15 downto 0);
        
        load_dac      : out std_logic;
        addr          : out std_logic_vector(2 downto 0);
        data          : out std_logic_vector(15 downto 0)
    );
end fil_mux;

architecture rtl of fil_mux is

type reg_type is record
    counter     :unsigned(7 downto 0);
    addr_cnt    :unsigned(2 downto 0);           
    start       :std_logic;
end record reg_type;

signal D,Q :reg_type; -- register inputs/outputs    


-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin
 
-- go high after update strobe, go low after all dac channels are updated    
D.start <= '0' when Q.addr_cnt = 7 and Q.counter = 124
            else '1' when update = '1'
            else Q.start;

-- 1 usec update rate
D.counter <= (others => '0') when Q.counter = 124
            else Q.counter + 1 when Q.start = '1'
            else Q.counter;

-- address mux counter
D.addr_cnt <= Q.addr_cnt + 1 when Q.counter = 124
            else Q.addr_cnt;
--addr <= "0000000000000000" & Q.addr_cnt & '0';
addr <= std_logic_vector(Q.addr_cnt);

-- load dac channel
load_dac <= '1' when Q.counter = 62 else '0';

with Q.addr_cnt select
    data <= filsetout1 when "000",
            filsetout2 when "001",
            filsetout3 when "010",
            filsetout4 when "011",
            filsetout5 when "100",
            filsetout6 when "101",
            filsetout7 when "110",
            filsetout8 when others;

reg: process(clock,reset_n)
begin
    if (reset_n = '0') then
        Q.counter     <= (others => '0');
        Q.addr_cnt    <= (others => '0');
        Q.start       <= '0';
    elsif rising_edge(clock) then
        Q <= D;
    end if;
end process reg;

end rtl;