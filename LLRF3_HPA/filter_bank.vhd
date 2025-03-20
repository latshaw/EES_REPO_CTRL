
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HPA.all;

entity filter_bank is
generic(	
    ADDR_WIDTH	 :positive := 5;
    DATA_WIDTH	 :positive := 16;
    DATA_FORMAT :string := "signed";
    BASE_ADDR   :unsigned(23 downto 0) := x"00001B"
);
port(
    reset_n     :in std_logic;
    clock       :in std_logic;
    
    lb_addr     :in std_logic_vector(23 downto 0);
    we          :in std_logic;
    filter_in   :in std_logic_vector_array16(0 to 63);
    
    lb_rdata    :out std_logic_vector(15 downto 0);
    filter_out  :out std_logic_vector_array16(0 to 63)
);
end filter_bank;

architecture rtl of filter_bank is

component MA_filter is
generic(	
    ADDR_WIDTH	:positive;
    DATA_WIDTH	:positive;
    DATA_FORMAT	:string
);
port(
    reset_n  :in std_logic;
    clock    :in std_logic;

    we       :in std_logic;
    data_in  :in std_logic_vector(DATA_WIDTH-1 DOWNTO 0);

    data_out :out std_logic_vector(DATA_WIDTH-1 DOWNTO 0)
);
end component;

type reg_type is record
    rdata_buffer :std_logic_vector(15 downto 0);
end record reg_type;

signal D,Q        :reg_type;
signal filt_out   :std_logic_vector_array16(0 to 63);
signal address    :integer;

-->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>--
begin

G0: for i in 0 to 63 generate
     Ui : MA_filter
     generic map(ADDR_WIDTH, DATA_WIDTH, DATA_FORMAT)
     port map( reset_n, clock, we, filter_in(i), filt_out(i) );
end generate G0;


-- calculate address
address <= to_integer( (unsigned(lb_addr) - BASE_ADDR) );

D.rdata_buffer <= filt_out(address);
lb_rdata <= Q.rdata_buffer;
filter_out <= filt_out;

reg: process(clock,reset_n)
begin
    if (reset_n = '0') then
        Q.rdata_buffer <= (others => '0');
    elsif rising_edge(clock) then
        Q <= D;
    end if;
end process reg;

end rtl;