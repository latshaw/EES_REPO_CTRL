
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity altram_dp is
generic (
    ADDR_WIDTH : positive := 3;
    DATA_WIDTH : positive := 16
);
port (
    clock     :in std_logic;
    data      :in std_logic_vector (DATA_WIDTH-1 downto 0);
    rdaddress :in std_logic_vector (ADDR_WIDTH-1 downto 0);
    wraddress :in std_logic_vector (ADDR_WIDTH-1 downto 0);
    wren      :in std_logic;

    q         :out std_logic_vector (DATA_WIDTH-1 downto 0)
);
end altram_dp;

architecture rtl of altram_dp is

type mem_type is array(0 to (2**ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);

signal    mem :mem_type;-- := (others => (others => '0'));
attribute ramstyle:string;
attribute ramstyle of mem : signal is "M20K";

signal read_addr     :std_logic_vector (ADDR_WIDTH-1 downto 0); 

begin

process(clock)
begin
    if(clock'event and clock='1') then
        if(wren='1') then
            mem(conv_integer(unsigned(wraddress))) <= data;
        end if;
            read_addr <= rdaddress;
    end if;
end process;

q <= mem(conv_integer(unsigned(read_addr)));

end rtl;

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity buffer_ram is
generic( ADDR_WIDTH :positive := 3;
         DATA_WIDTH :positive := 16);
port(
    reset_n :in std_logic;                               -- asynchronous reset
    clock   :in std_logic;                               -- write clock
      
    -- inputs
    we      :in std_logic;                               -- write enable (write data is loaded on next rising edge)
    wdata   :in std_logic_vector(DATA_WIDTH-1 downto 0); -- write data

    -- outputs
    rdata   :out std_logic_vector(DATA_WIDTH-1 downto 0) -- read data
);
end buffer_ram;

architecture rtl of buffer_ram is

signal waddr :std_logic_vector(ADDR_WIDTH-1 downto 0);

component altram_dp is
generic(
    ADDR_WIDTH :positive;
    DATA_WIDTH :positive
);
port
(
    clock     :in std_logic;
    data      :in std_logic_vector (DATA_WIDTH-1 downto 0);
    rdaddress :in std_logic_vector (ADDR_WIDTH-1 downto 0);
    wraddress :in std_logic_vector (ADDR_WIDTH-1 downto 0);
    wren      :in std_logic;

    q         :out std_logic_vector (DATA_WIDTH-1 downto 0)
);
end component;

begin

U1 : altram_dp
generic map(ADDR_WIDTH, DATA_WIDTH)
port map( clock, wdata , waddr , waddr , we , rdata );

-- address counter
process(clock,reset_n)
    variable counter : std_logic_vector(ADDR_WIDTH-1 downto 0);
begin
    if (reset_n = '0') then
        counter := (others => '0');
    elsif rising_edge(clock) then
        if (we = '1') then
            counter := counter + 1;
        end if;
    end if;
    
    waddr <= counter;
end process;

end rtl;

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;

entity sum_avg is
generic( 
    DATA_WIDTH     :positive := 16;  
    LOG2_NUMPOINTS :positive := 3; -- log2(number of points being averaged) -> number of points = power of 2
    data_format    :string   := "signed");                                     
port(
    reset_n :in std_logic;                               -- asynchronous reset
    clock   :in std_logic;                               -- write clock

    -- inputs
    we      :in std_logic;                               -- write enable (write data is loaded on next rising edge)
    newest  :in std_logic_vector(DATA_WIDTH-1 downto 0); -- write data
    oldest  :in std_logic_vector(DATA_WIDTH-1 downto 0); -- write data

    -- outputs
    average :out std_logic_vector(DATA_WIDTH-1 downto 0) -- read data
);
end sum_avg;

architecture rtl of sum_avg is

type reg_type is record
    sum :signed(DATA_WIDTH+LOG2_NUMPOINTS-1 downto 0);
    avg :signed(DATA_WIDTH-1 downto 0);
end record;

signal d,q :reg_type ; -- register inputs/outputs

-- signed versions of input data
signal newdata :signed(DATA_WIDTH downto 0);
signal olddata :signed(DATA_WIDTH downto 0);

begin 

newdata <= ( newest(DATA_WIDTH-1) & signed(newest) ) when data_format = "signed"
            else ( '0' & signed(newest) );

olddata <= ( oldest(DATA_WIDTH-1) & signed(oldest) ) when data_format = "signed"
            else ( '0' & signed(oldest) );

d.sum <= ((newdata + q.sum) - olddata) when we = '1' else q.sum;
    
d.avg <= d.sum(DATA_WIDTH+LOG2_NUMPOINTS-1 downto LOG2_NUMPOINTS) 
            when (we = '1') else q.avg; -- divide by 2^LOG2_NUMPOINTS

average <= std_logic_vector(q.avg);

process(clock,reset_n)
begin
    if (reset_n = '0') then
        q.sum <= (others => '0');
        q.avg <= (others => '0');
    elsif rising_edge(clock) then
        q <= d;
    end if;
end process;

end rtl;

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ma_filter is
generic(
    ADDR_WIDTH  :positive := 3;
    DATA_WIDTH  :positive := 16;
    data_format :string := "signed"
);
port(
    reset_n  :in std_logic;
    clock    :in std_logic;

    -- inputs
    we       :in std_logic;
    data_in  :in std_logic_vector(DATA_WIDTH-1 downto 0);

    -- outputs
    data_out :out std_logic_vector(DATA_WIDTH-1 downto 0)
);
end ma_filter;

architecture rtl of ma_filter is

component buffer_ram is 
generic(
    ADDR_WIDTH :positive;
    DATA_WIDTH :positive
);
port(
    reset_n :in std_logic;                               -- asynchronous reset
    clock   :in std_logic;                               -- write clock
    we      :in std_logic;                               -- write enable (write data is loaded on next rising edge)
    wdata   :in std_logic_vector(DATA_WIDTH-1 downto 0); -- write data
    rdata   :out std_logic_vector(DATA_WIDTH-1 downto 0) -- read data
);
end component;

component sum_avg is
generic(
    DATA_WIDTH     :positive;
    LOG2_NUMPOINTS :positive; -- log2(number of points being averaged) -> number of points = power of 2
    data_format    :string);                                 
port(
    reset_n :in std_logic;                               -- asynchronous reset
    clock   :in std_logic;                               -- write clock
    we      :in std_logic;                               -- write enable (write data is loaded on next rising edge)
    newest  :in std_logic_vector(DATA_WIDTH-1 downto 0); -- write data
    oldest  :in std_logic_vector(DATA_WIDTH-1 downto 0); -- write data
    average :out std_logic_vector(DATA_WIDTH-1 downto 0) -- read data
);
end component;

signal    rdata    :std_logic_vector(DATA_WIDTH-1 downto 0); 

begin

u1 : buffer_ram
generic map(ADDR_WIDTH,DATA_WIDTH)
port map( reset_n, clock, we, data_in, rdata );

u2 : sum_avg
generic map(DATA_WIDTH,ADDR_WIDTH,data_format)
port map( reset_n, clock, we, data_in, rdata, data_out );

end rtl;

