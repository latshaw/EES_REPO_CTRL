
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all; 

entity i2c is
port(
	reset_n	:in 		std_logic;
	clock		:in 		std_logic;
	
	start   	:in		std_logic;
	stop		:in 		std_logic;
	wren		:in		std_logic;
	rden		:in		std_logic;
	ack		:in		std_logic;
	wdata		:in 		std_logic_vector(7 downto 0);

	rdata		:out 		std_logic_vector(7 downto 0);
	rdready	:out		std_logic;
	busy		:out		std_logic;
	scl		:out 		std_logic;
	sda		:inout	std_logic
);
end i2c;



architecture rtl of i2c is

-- registers -----------------------------------------
type reg_type is record			   
	clk_400kHz 	:std_logic_vector(15 downto 0);
	sda_reg 		:std_logic_vector(51 downto 0);
	scl_reg 		:std_logic_vector(51 downto 0);
	shift_cnt	:std_logic_vector(15 downto 0);
	rdata			:std_logic_vector(7 downto 0);
	rden			:std_logic;
end record reg_type;
signal D,Q	:reg_type;
------------------------------------------------------

signal shift_en		:std_logic;
signal sda_start 		:std_logic_vector(8 downto 0);
signal scl_start 		:std_logic_vector(5 downto 0);
signal sda_stop 		:std_logic_vector(6 downto 0);
signal scl_stop 		:std_logic_vector(3 downto 0);
signal sda_ack 		:std_logic_vector(3 downto 0);
signal scl_falling 	:std_logic;
constant CLOCK_DATA 	:std_logic_vector(41 downto 0) := "000011001100110011001100110011001100110000";


begin
		
-- 400kHz strobe
D.clk_400kHz <= (others => '0') when Q.clk_400kHz = 250
				else Q.clk_400kHz + 1 when wren = '1' or rden = '1' or Q.shift_cnt > 0
				else Q.clk_400kHz;

-- shift counter
D.shift_cnt <= (others => '0') when Q.shift_cnt = 51
			else Q.shift_cnt + 1 when (Q.clk_400kHz = 249 and Q.shift_cnt > 0) or wren = '1' or rden = '1'
			else Q.shift_cnt;


shift_en <= '1' when Q.shift_cnt > 0 else '0';

sda_start 	<= "111100000" when start = '1' else (others => '1');
scl_start 	<= "111111" when start = '1' else (others => '0');
sda_stop		<= "0000011" when stop = '1' else (others => '1');
scl_stop 	<= "1111" when stop = '1' else (others => '0');
sda_ack 		<= "1111" when ack = '0' else "0000";

-- clock shift register
D.scl_reg <= 	scl_start
				& CLOCK_DATA
			   	& scl_stop
				when (wren = '1' or rden = '1')
				else Q.scl_reg(50 downto 0) & Q.scl_reg(0)
				when Q.clk_400kHz = 249
				else Q.scl_reg;


-- data shift register
D.sda_reg <= 	sda_start
				& wdata(7) & wdata(7) & wdata(7) & wdata(7)
			   	& wdata(6) & wdata(6) & wdata(6) & wdata(6)
			   	& wdata(5) & wdata(5) & wdata(5) & wdata(5)
			   	& wdata(4) & wdata(4) & wdata(4) & wdata(4)
			   	& wdata(3) & wdata(3) & wdata(3) & wdata(3)
			   	& wdata(2) & wdata(2) & wdata(2) & wdata(2)
			   	& wdata(1) & wdata(1) & wdata(1) & wdata(1)
			   	& wdata(0) & wdata(0) & wdata(0) & wdata(0)
				& sda_ack
			   	& sda_stop
				when wren = '1'
				else sda_start & x"FFFFFFFF" & sda_ack & sda_stop
				when rden = '1'
				else Q.sda_reg(50 downto 0) & Q.sda_reg(0)
				when Q.clk_400kHz = 249
				else Q.sda_reg;

-- clock falling edge
scl_falling <= '1' when  Q.scl_reg(51) = '1' and D.scl_reg(51) = '0' else '0';

-- enable data read
D.rden <= '1' when rden = '1'
			else '0' when scl_falling = '1' and Q.shift_cnt = 44
			else Q.rden;

-- read ready strobe
rdready <= '1' when Q.rden = '1' and D.rden = '0' else '0';

D.rdata <= Q.rdata(6 downto 0) & sda when ( scl_falling = '1' and Q.shift_cnt > 10 and Q.shift_cnt < 42 )
				else Q.rdata;
rdata <= Q.rdata;

scl <= '0' when Q.scl_reg(51) = '0' else 'Z';

sda <= '0' when Q.sda_reg(51) = '0' else 'Z';

busy <= shift_en;

reg: process(reset_n,clock)
begin
	if reset_n = '0' then
		Q.clk_400kHz 	<= (others => '0');
		Q.sda_reg 		<= (others => '1');
		Q.scl_reg 		<= (others => '1');
		Q.shift_cnt 	<= (others => '0');
		Q.rdata 			<= (others => '0');
		Q.rden 			<= '0';
	elsif rising_edge(clock) then
		Q <= D;
	end if;
end process reg;

end rtl;
