-- 5-5-22
-- confirmed to actually toggle the SFP enable.

-- NOTES:
-- Some of the 'bad' SFP modules only toggle if we toggle the TX -disable
-- 5-17-22, made the process faster, we only toggle tx-disable once.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tca9534_i2c is
port(clock		:	in std_logic;
	reset			:	in std_logic;
	sda			:	inout std_logic;
	scl			:	out std_logic;
	tca_config_done		:	out std_logic
	);
end entity tca9534_i2c;
architecture behavior of tca9534_i2c is

signal scl_cnt_d			:	std_logic_vector(10 downto 0);
signal scl_cnt_q			:	std_logic_vector(10 downto 0);
signal wait_cnt_d			:	std_logic_vector(15 downto 0);
signal wait_cnt_q			:	std_logic_vector(15 downto 0);
signal en_wait_cnt		:	std_logic;
signal reg_cnt_d			:	std_logic_vector(2 downto 0);
signal reg_cnt_q			:	std_logic_vector(2 downto 0);
signal en_reg_cnt			:	std_logic;
signal clr_reg_cnt		:	std_logic;
signal data_reg_index	:	integer range 0 to 4;
signal bit_cnt_d			:	std_logic_vector(4 downto 0);
signal bit_cnt_q			:	std_logic_vector(4 downto 0);
signal en_bit_cnt			:	std_logic;
signal clr_bit_cnt		:	std_logic;
signal data_reg_in		:	std_logic_vector(27 downto 0);
signal data_reg_d			:	std_logic_vector(27 downto 0);
signal data_reg_q			:	std_logic_vector(27 downto 0);
signal ld_data_reg		:	std_logic;
signal sh_data_reg		:	std_logic;
signal clk_done_d			:	std_logic;
signal clk_done_q			:	std_logic;
signal i2c_clock			:	std_logic;
signal init_wait_cnt_d	:	std_logic_vector(19 downto 0);
signal init_wait_cnt_q	:	std_logic_vector(19 downto 0);
signal data_ld_cnt_d		:	std_logic_vector(2 downto 0);
signal data_ld_cnt_q		:	std_logic_vector(2 downto 0);
signal en_data_ld_cnt	:	std_logic;

signal scl_d, scl_q		:	std_logic;
signal sda_d, sda_q		:	std_logic;	

signal ack		:	std_logic_vector(1 downto 0); -- new signal to capture ACK values

signal pgm_cnt_q, pgm_cnt_d	:	std_logic_vector(3 downto 0);
signal en_pgm_cnt			:	std_logic;
type reg_data is array(4 downto 0) of std_logic_vector(15 downto 0);
--constant clk_reg_data	:	reg_data:= (x"03A8", x"0200", x"0150", x"0010");
-- constant clk_reg_data	:	reg_data:= (x"0106", x"0107", x"0338", x"0200", x"0000"); -- 5/17/22 BEST SO FAR
constant clk_reg_data	:	reg_data:= (x"0106", x"0107", x"0338", x"0200", x"0000");
------------------------this is from the eval board----------------------
--------register 3----------------
------10101000-----------1 is input and 0 is output
------sfp_prsn,sfp_rs0,sfp_rlos,sfp_rs1,sfp_tflt,sfp_txdis,sfp_gled,sfp_rled---------------
-------register 2-----------------
--------set all to zeros to retain the polarity-----------------
--------register 1---------------------
--------01010001-----------------------
----------register 0 is all input readbacks, so write has no effect------------------------
--------------------end of the register settings from the eval board-----------------------

----------------this is for jlab cyclone 10gx board-----------------------------
--------register 3----------------
------00111000-----------1 is input and 0 is output
------not used,not used,sfp_tflt,sfp_rlos,sfp_prsn,sfp_rs1,sfp_rs0,sfp_txdis---------------
-------register 2-----------------
--------set all to zeros to retain the polarity-----------------
--------register 1---------------------
--------00000110-----------------------
----------register 0 is all input readbacks, so write has no effect------------------------

type state_type is (init, data_load, scl_high, scl_low, bit_check, reg_check, stop_reg, config_done);
signal state				:	state_type;

------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
begin

data_reg_index	<= to_integer(unsigned (reg_cnt_q));
-- note, ack are expected at bits 9 and 18 (zero indexed values)
--                                         bit 9 ack                                        bit 19 ack                                       master ack (don't care)
data_reg_in		<=	'0' & "0100000" & '0' & '1' & clk_reg_data(data_reg_index)(15 downto 8) & '1' & clk_reg_data(data_reg_index)(7 downto 0) & '1';
scl_cnt_d		<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
i2c_clock		<=	scl_cnt_q(10);
wait_cnt_d		<=	std_logic_vector(unsigned(wait_cnt_q) + 1) when state = stop_reg else (others => '0'); -- JAL, added reset to between packet counter
bit_cnt_d		<=	(others => '0') when clr_bit_cnt = '0' else
						std_logic_vector(unsigned(bit_cnt_q) + 1) when en_bit_cnt = '1' else
						bit_cnt_q;
reg_cnt_d		<=	(others => '0') when clr_reg_cnt = '0' else
						std_logic_vector(unsigned(reg_cnt_q) + 1) when en_reg_cnt = '1' else
						reg_cnt_q;
data_ld_cnt_d	<=	std_logic_vector(unsigned(data_ld_cnt_q) + 1) when en_data_ld_cnt = '1' else
						data_ld_cnt_q;				
data_reg_d		<=	data_reg_in when ld_data_reg = '1' else
						data_reg_q(26 downto 0) & sda when sh_data_reg = '1' else
						data_reg_q; -- Rama's update to bring in ACK from slave device
--data_reg_d		<=	data_reg_in when ld_data_reg = '1' else
--						data_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
--						data_reg_q; -- code was this
tca_config_done			<=	clk_done_q;
init_wait_cnt_d	<=	std_logic_vector(unsigned(init_wait_cnt_q) + 1) when init_wait_cnt_q /= x"03FFF" else
							init_wait_cnt_q;
pgm_cnt_d		<=	std_logic_vector(unsigned(pgm_cnt_q) + 1) when en_pgm_cnt = '1' else pgm_cnt_q;


ack <= data_reg_q(18)&data_reg_q(9); -- the slave device should provide an ack at these bits

process(clock,reset)
begin
	if(reset = '0') then
		scl_cnt_q	<=	(others => '0');
	elsif(rising_edge(clock)) then
		scl_cnt_q	<=	scl_cnt_d;
	end if;
end process;
process(i2c_clock,reset)
begin
	if(reset = '0') then
		wait_cnt_q			<=	(others => '0');
		bit_cnt_q			<=	(others => '0');
		reg_cnt_q			<=	(others => '0');
		data_reg_q			<=	(others => '0');
		clk_done_q			<=	'0';
		init_wait_cnt_q	<=	(others	=>	'0');
		pgm_cnt_q			<=	(others	=>	'0');
		data_ld_cnt_q		<=	(others	=>	'0');
		scl_q					<=	'1';
		sda_q					<=	'1';
	elsif(rising_edge(i2c_clock)) then
		wait_cnt_q			<=	wait_cnt_d;
		bit_cnt_q			<=	bit_cnt_d;
		reg_cnt_q			<=	reg_cnt_d;
		data_reg_q			<=	data_reg_d;
		clk_done_q			<=	clk_done_d;
		init_wait_cnt_q	<=	init_wait_cnt_d;
		data_ld_cnt_q		<=	data_ld_cnt_d;
		pgm_cnt_q			<=	pgm_cnt_d;
		scl_q					<=	scl_d;
		sda_q					<=	sda_d;
	end if;
end process;	
process(i2c_clock, reset)
begin
	if(reset = '0') then
		state	<=	init;
	elsif(rising_edge(i2c_clock)) then
		case state is
			when init			=>	if init_wait_cnt_q = x"03FFF" then state <= data_load;											
										else state	<=	init;
										end if;
			when data_load		=>	state <= scl_high;			
			when scl_high		=>	state <= scl_low;
			when scl_low		=>	state <= bit_check;
			when bit_check		=>	if bit_cnt_q = "11011" then state <= reg_check;
										else state <= scl_high;
										end if;
			when reg_check		=>	if reg_cnt_q = "100" then state <= config_done;
										else state <= stop_reg;
										end if;
			when stop_reg		=>	if wait_cnt_q = x"3FFF" then state <= data_load;
										else state <= stop_reg;
										end if;
    		when config_done	=>	state	<=	config_done;							
--			when config_done	=>	if(data_ld_cnt_q = "11") then state <= config_done;
--										else state <= data_load;
--										end if;
--			when config_done	=>	if pgm_cnt_q =  "1111" then state	<=	config_done;							
--										else state	<=	data_load;
--										end if;					
			when others			=>	state <= init;
		end case;
	end if;
end process;
en_wait_cnt			<=	'1' when state = stop_reg  else '0';
clr_bit_cnt			<=	'0' when state = reg_check else '1';
en_bit_cnt			<=	'1' when state = bit_check else '0';
en_reg_cnt			<=	'1' when (state = reg_check and ack = "00" ) else '0';
en_data_ld_cnt		<=	'1' when state = config_done and data_ld_cnt_q /= "100" else '0';
clr_reg_cnt			<=	'0' when state = reg_check and reg_cnt_q = "100" else '1';
--clr_reg_cnt			<=	'1';
ld_data_reg			<=	'1' when state = data_load else '0';
sh_data_reg			<=	'1' when state = scl_low else '0';
scl_d					<=	'0' when state = scl_low or state = bit_check else '1';
sda_d					<=	'1' when state = init or state = data_load or state = stop_reg or state = config_done else
							'0' when state = reg_check else
							data_reg_q(27);
scl					<= '0' when scl_q = '0' else 'Z';
sda					<=	'0' when sda_q = '0' else 'Z';							
							
							
clk_done_d			<=	'1' when state = config_done else '0';
en_pgm_cnt			<=	'1' when state = config_done and pgm_cnt_q /= "1111" else '0';		
end architecture behavior;	