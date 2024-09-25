library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_tmp512 is
port(clock		:	in std_logic;
	reset			:	in std_logic;
	sda			:	inout std_logic;
	scl			:	out std_logic;
--	data_out	:	out std_logic_vector(15 downto 0);
	data_valid	:	out std_logic
	);
end entity i2c_tmp512;
architecture behavior of i2c_tmp512 is

signal scl_cnt_d			:	std_logic_vector(7 downto 0);
signal scl_cnt_q			:	std_logic_vector(7 downto 0);
signal wait_cnt_d			:	std_logic_vector(7 downto 0);
signal wait_cnt_q			:	std_logic_vector(7 downto 0);
signal en_wait_cnt			:	std_logic;

signal scl_d, scl_q			:	std_logic;
signal sda_d, sda_q			:	std_logic;

signal sda_in_q			:	std_logic;


signal bit_cnt_d			:	std_logic_vector(5 downto 0);
signal bit_cnt_q			:	std_logic_vector(5 downto 0);
signal en_bit_cnt			:	std_logic;
signal clr_bit_cnt			:	std_logic;
signal data_reg_in			:	std_logic_vector(27 downto 0);
signal data_reg_d			:	std_logic_vector(27 downto 0);
signal data_reg_q			:	std_logic_vector(27 downto 0);
signal ld_data_reg			:	std_logic;
signal sh_data_reg			:	std_logic;
--signal clk_done_d			:	std_logic;
--signal clk_done_q			:	std_logic;
signal i2c_clock			:	std_logic;
signal init_wait_cnt_d		:	std_logic_vector(11 downto 0);
signal init_wait_cnt_q		:	std_logic_vector(11 downto 0);

signal reg_cnt_d, reg_cnt_q	:	std_logic_vector(2 downto 0);
signal data_out_d, data_out_q	:	std_logic_vector(15 downto 0);
signal data_rd_d, data_rd_q	:	std_logic_vector(17 downto 0);

signal data_wr_reg_ltmp		:	std_logic_vector(27 downto 0);
signal data_rd_reg_ltmp		:	std_logic_vector(27 downto 0);
signal data_wr_reg_rtmp		:	std_logic_vector(27 downto 0);
signal data_rd_reg_rtmp		:	std_logic_vector(27 downto 0);
signal data_wr_reg_bvlt		:	std_logic_vector(27 downto 0);
signal data_rd_reg_bvlt		:	std_logic_vector(27 downto 0);
signal data_wr_reg_svlt		:	std_logic_vector(27 downto 0);
signal data_rd_reg_svlt		:	std_logic_vector(27 downto 0);

signal bit_cnt_reg			:	std_logic_vector(5 downto 0);



type state_type is (init, data_load, scl_high, scl_low, sda_high, sda_low, bit_check, reg_check, stop_reg, rw_done);
signal state				:	state_type;

------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
begin

data_wr_reg_svlt	<=	'0' & "1011100" & '0' & '1' & "00000100" & '1'&'1'&x"ff";
data_rd_reg_svlt	<=	'0' & "1011100" & '1' & '1' & "11111111" & '0' & "11111111" & '1';

data_wr_reg_bvlt	<=	'0' & "1011100" & '0' & '1' & "00000101" & '1'&'1'&x"ff";
data_rd_reg_bvlt	<=	'0' & "1011100" & '1' & '1' & "11111111" & '0' & "11111111" & '1';

data_wr_reg_ltmp	<=	'0' & "1011100" & '0' & '1' & "00001000" & '1'&'1'&x"ff";
data_rd_reg_ltmp	<=	'0' & "1011100" & '1' & '1' & "11111111" & '0' & "11111111" & '1';

data_wr_reg_rtmp	<=	'0' & "1011100" & '0' & '1' & "00001001" & '1'&'1'&x"ff";
data_rd_reg_rtmp	<=	'0' & "1011100" & '1' & '1' & "11111111" & '0' & "11111111" & '1';








data_reg_in		<=	data_wr_reg_svlt when reg_cnt_q(2 downto 0) = "000" else 
						data_rd_reg_svlt when reg_cnt_q(2 downto 0) = "001" else
						data_wr_reg_bvlt when reg_cnt_q(2 downto 0) = "010" else 
						data_rd_reg_bvlt when reg_cnt_q(2 downto 0) = "011" else						
						data_wr_reg_ltmp when reg_cnt_q(2 downto 0) = "100" else 
						data_rd_reg_ltmp when reg_cnt_q(2 downto 0) = "101" else 
						data_wr_reg_rtmp when reg_cnt_q(2 downto 0) = "110" else 
						data_rd_reg_rtmp;
						
						
						
						
						
						
						
--data_reg_in		<=	data_rd_reg_in;
bit_cnt_reg		<=	"010010" when reg_cnt_q(0) = '0' else "011011";	
--bit_cnt_reg		<=	"101101";
scl_cnt_d		<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
i2c_clock		<=	scl_cnt_q(7);
wait_cnt_d		<=	std_logic_vector(unsigned(wait_cnt_q) + 1) when en_wait_cnt = '1' else wait_cnt_q;
bit_cnt_d		<=	(others => '0') when clr_bit_cnt = '0' else
						std_logic_vector(unsigned(bit_cnt_q) + 1) when en_bit_cnt = '1' else
						bit_cnt_q;
data_reg_d		<=	data_reg_in when ld_data_reg = '1' else
						data_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
						data_reg_q;

init_wait_cnt_d	<=	std_logic_vector(unsigned(init_wait_cnt_q) + 1);
reg_cnt_d		<=	std_logic_vector(unsigned(reg_cnt_q) + 1) when state = rw_done else reg_cnt_q;
	
data_rd_d		<=	data_rd_q(16 downto 0) & sda_in_q when (state = scl_high and reg_cnt_q(0) = '1') else data_rd_q;
data_out_d		<=	data_rd_q(17 downto 10) & data_rd_q(8 downto 1) when (reg_cnt_q(0) = '1' and state = rw_done) else data_out_q;	

data_valid		<=	'1' when data_out_q = x"0305" else '0';
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
		data_reg_q			<=	(others => '0');
--		clk_done_q			<=	'0';
		init_wait_cnt_q		<=	(others	=>	'0');
		reg_cnt_q			<=	(others	=>	'0');
		data_rd_q			<=	(others	=>	'0');
		data_out_q			<=	(others	=>	'0');
		sda_q				<=	'1';
		scl_q				<=	'1';
		sda_in_q			<=	'1';
--		data_out			<=	(others	=>	'0');
	elsif(rising_edge(i2c_clock)) then
		wait_cnt_q			<=	wait_cnt_d;
		bit_cnt_q			<=	bit_cnt_d;
		data_reg_q			<=	data_reg_d;
--		clk_done_q			<=	clk_done_d;
		init_wait_cnt_q		<=	init_wait_cnt_d;
		reg_cnt_q			<=	reg_cnt_d;
		data_rd_q			<=	data_rd_d;
		data_out_q			<=	data_out_d;
		sda_q				<=	sda_d;
		scl_q				<=	scl_d;
		sda_in_q			<=	sda;
--		data_out			<=	data_out_q;
	end if;
end process;	
process(i2c_clock, reset)
begin
	if(reset = '0') then
		state	<=	init;
	elsif(rising_edge(i2c_clock)) then
		case state is
			when init			=>	if init_wait_cnt_q = x"fff" then state <= data_load;											
										else state	<=	init;
										end if;
			when data_load		=>	state <= scl_high;			
			when scl_high		=>	state	<=	scl_low;
			when scl_low		=>	state <= bit_check;
			
			when bit_check		=>	if bit_cnt_q =  bit_cnt_reg then state <= reg_check;
									else state <= scl_high;
									end if;									
			when reg_check		=>	state <= stop_reg;
			when stop_reg		=>	if wait_cnt_q = x"ff" then state <= rw_done;
										else state <= stop_reg;
										end if;
			when rw_done		=>	state	<=	data_load;							
			when others			=>	state <= init;
		end case;
	end if;
end process;
en_wait_cnt			<=	'1' when state = stop_reg  else '0';
clr_bit_cnt			<=	'0' when state = reg_check else '1';
en_bit_cnt			<=	'1' when state = bit_check else '0';

ld_data_reg			<=	'1' when state = data_load else '0';
sh_data_reg			<=	'1' when state = scl_low else '0';
scl_d					<=	'0' when state = scl_low or state = bit_check else '1';
sda_d					<=	'1' when state = init or state = data_load or state = stop_reg or state = rw_done else
						'0' when state = reg_check else
						data_reg_q(27);
						
scl					<=	'0' when scl_q = '0' else 'Z';
sda					<=	'0' when sda_q = '0' else 'Z';
						
						


end architecture behavior;	