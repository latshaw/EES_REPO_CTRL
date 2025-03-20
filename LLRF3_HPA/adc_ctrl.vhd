
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.hpa.all;

entity adc_ctrl is
port(
        reset_n     :in std_logic;
        clock       :in std_logic;

        db          :in std_logic_vector(15 downto 0);     -- adc data bus

        convst_n    :out std_logic_vector(7 downto 0);     -- conversion start
        rd_n        :out std_logic_vector(7 downto 0);     -- read
        wr_n        :out std_logic_vector(7 downto 0);     -- write
        cs_n        :out std_logic_vector(7 downto 0);     -- chip select

        we          :out std_logic;                        -- write enable
        adc_regs    :out std_logic_vector_array16(0 to 63)
);
end adc_ctrl;

architecture rtl of adc_ctrl is

component adc_remap
port(
        reset_n :in std_logic;
        clock   :in std_logic;

        adc_in  :in std_logic_vector_array16(0 to 63);
        adc_out :out std_logic_vector_array16(0 to 63)
);
end component;

type reg_type is record
    sample_cnt :unsigned(16 downto 0);
    adc_reg    :std_logic_vector_array16(0 to 63);	
    rd         :unsigned(3 downto 0);
    cs         :unsigned(7 downto 0);
    ch_cnt     :unsigned(5 downto 0);
end record reg_type;

signal D,Q :reg_type;
constant SAMPLE_CNT_LIMIT :integer := 124999; -- 1ms sample period 0.001 * fclk = 0.001 * 125e6 = 125000

---------------------------------------------------------------------------------------------------------------
begin

D.sample_cnt <= (others => '0') when Q.sample_cnt = SAMPLE_CNT_LIMIT
                else Q.sample_cnt + 1;

-- start conversion on all adc's ( fs = 1kHz )
convst_n <= "00000000" when Q.sample_cnt < 500 else "11111111";

g1: for i in 0 to 7 generate
     D.cs(i) <= '0' when Q.sample_cnt = (5000*(i+1))
             else '1' when Q.sample_cnt = (5000*(i+1) + 128)
             else Q.cs(i);
end generate g1;

D.rd <= Q.rd + 1 when Q.cs < 255 or Q.rd > 0
        else Q.rd;

g2: for i in 0 to 7 generate
     rd_n(i) <= Q.rd(3) when Q.cs(i) = '0' else '1';
end generate g2;

cs_n <= std_logic_vector(Q.cs);

D.ch_cnt <= Q.ch_cnt + 1 when Q.rd(3) = '0' and D.rd(3) = '1' else Q.ch_cnt;

g3: for i in 0 to 63 generate
     D.adc_reg(i) <= db when Q.ch_cnt = i and (Q.rd(3) = '0' and D.rd(3) = '1') else Q.adc_reg(i);
end generate g3;

wr_n <= (others => '1');

--adc_regs <= Q.adc_reg;

we <= '1' when Q.sample_cnt = 0 else '0';

adc_remap_inst: adc_remap 
port map(
           reset_n => reset_n,
           clock   => clock,
           adc_in  => Q.adc_reg,
           adc_out => adc_regs
        );

reg: process(reset_n,clock)
begin
    if (reset_n = '0') then
        Q.sample_cnt <= (others => '0');
        Q.rd         <= (others => '0');
        Q.cs         <= (others => '1');
        Q.adc_reg    <= (others => (others => '0'));
        Q.ch_cnt     <= (others => '0');
    elsif rising_edge(clock) then
        Q <= D;
    end if;
end process reg;

end rtl;