-- Performs the count up/count down to adjust the setpoint of each filament channel.

-- Maybe at some point get the current readback in this module and use it to adjust the filament ramp time....?

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;

entity fil_ctrl is
port (
        reset_n      : in std_logic;                     -- system reset
        clock        : in std_logic;                     -- system clock (125MHz)

        filon        : in std_logic;                     -- filaments on bit
        hvon         : in std_logic;                     -- hv on bit
        filsetin     : in std_logic_vector(15 downto 0);
        bypass       : in std_logic;

        update       : out std_logic;
        filsetout    : out std_logic_vector(15 downto 0)
    );
end fil_ctrl;


architecture rtl of fil_ctrl is

constant MINSET    :unsigned(15 downto 0) := x"2666"; -- minimum valid setpoint 0x2666 * (10/65536) = 1.5v
constant RAMPRATE  :unsigned(15 downto 0) := x"003c"; -- in sec/volt
constant RAMPCONST :unsigned(15 downto 0) := x"4A81"; -- set to floor( (CLOCK_FREQ/65536) * 10 ) 

-- register signals
type reg_type is record
    filsetcount :unsigned(15 downto 0); -- filament voltage setpoint counter
    rampcount   :unsigned(31 downto 0); -- ramp rate counter -> generates count enable for filsetcount
    filon       :std_logic;
    filset      :unsigned(15 downto 0);
    bypass      :std_logic;
end record reg_type;

signal D,Q                :reg_type; -- register inputs/outputs
signal filonedge          :std_logic;
signal rampcountlimit     :unsigned(31 downto 0);
signal filsetchange       :std_logic;
signal filset             :unsigned(15 downto 0); -- Max filament setpoint?
signal bypassoff          :std_logic;
signal filsetout_unsigned :unsigned(15 downto 0);

begin

rampcountlimit <= (RAMPRATE * RAMPCONST) - 1; 

-- filaments on/off buffer
D.filon <= filon;

-- rising edge of filaments on bit
filonedge <= '1' when (Q.filon = '0' and filon = '1') else '0';

D.rampcount <= (others => '0') when Q.rampcount = rampcountlimit
                else Q.rampcount + 1;

filset <= (unsigned(filsetin) - 3276) when (hvon = '0' and unsigned(filsetin) >= 3276) else unsigned(filsetin);

D.filset <= filset;

filsetchange <= '1' when Q.filset /= D.filset else '0';

D.filsetcount <= (others => '0') when (filon = '0' and Q.filsetcount < MINSET and Q.rampcount = rampcountlimit)    -- set to zero if < MINSET or bypassed
                                      or (filon = '1' and filset < MINSET) or (bypass = '1')
        else filset when ( (filsetchange = '1' or bypassoff = '1') and filon = '1' )
        else MINSET when (filonedge = '1' and filset >= MINSET and Q.filsetcount < MINSET)
        else (Q.filsetcount + 1) when (filon = '1' and Q.rampcount = rampcountlimit and Q.filsetcount < filset)    -- increment set point
        else (Q.filsetcount - 1) when (filon = '0' and (Q.rampcount = rampcountlimit                               -- decrement at twice the rate
                                      or Q.rampcount = ('0' & rampcountlimit(31 downto 1))) and Q.filsetcount > 0) -- Could this one be changed to "(Q.filsetcount - 2) when (filon = '0' and Q.rampcount = rampcountlimit) and Q.filsetcount > 0)"?
        else Q.filsetcount;


filsetout_unsigned <= Q.filsetcount when filon = '1' else (others => '0');
filsetout <= std_logic_vector(filsetout_unsigned);

D.bypass <= bypass;

bypassoff <= '1' when Q.bypass = '1' and D.bypass = '0' else '0';

update <= '1' when Q.rampcount = rampcountlimit else '0';

reg: process(clock,reset_n)
begin
    if (reset_n = '0') then
        Q.filsetcount <= (others => '0');
        Q.rampcount   <= (others => '0');
        Q.filon       <= '0';
        Q.filset      <= (others => '0');
        Q.bypass      <= '0';
    elsif rising_edge(clock) then
        Q <= D;
    end if;
end process reg;

end rtl;