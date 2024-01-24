library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adc_bit_align is
	port(clock			:	in std_logic;
			reset			:	in std_logic;
			init_align	:	in	std_logic;
			frame_in		:	in	std_logic_vector(7 downto 0);
			frame_tgt	:	in std_logic_vector(7 downto 0);
			
			bitslip_out	:	out std_logic;
			align_done	:	out std_logic
			);
end entity adc_bit_align;

architecture behavior of adc_bit_align is

type state_type is (init, frame_check, start_bitslip, wait_bitslip, done_align);
signal state					:	state_type;

signal wait_cnt_d				:	std_logic_vector(7 downto 0);
signal wait_cnt_q				:	std_logic_vector(7 downto 0);
signal en_wait_cnt			:	std_logic;

signal start_align_in_d		:	std_logic_vector(1 downto 0);
signal start_align_in_q		:	std_logic_vector(1 downto 0);

signal start_align_d			:	std_logic;
signal start_align_q			:	std_logic;

signal frame_in_d				:	std_logic_vector(7 downto 0);
signal frame_in_q				:	std_logic_vector(7 downto 0);
signal frame_tgt_d			:	std_logic_vector(7 downto 0);
signal frame_tgt_q			:	std_logic_vector(7 downto 0);

signal bitslip_d				:	std_logic;
signal bitslip_q				:	std_logic;

signal align_done_d			:	std_logic;
signal align_done_q			:	std_logic;

begin

wait_cnt_d			<=	std_logic_vector(unsigned(wait_cnt_q) + 1) when en_wait_cnt = '1' else
							wait_cnt_q;
							
frame_in_d			<=	frame_in;
frame_tgt_d			<=	frame_tgt;
process(clock, reset)
begin
	if(reset = '0') then
		wait_cnt_q			<=	(others => '0');
		start_align_q		<=	'0';
		start_align_in_q	<=	(others => '0');
		align_done_q		<= '0';
		frame_in_q			<=	(others	=> '0');
		frame_tgt_q			<=	(others	=> '0');
		bitslip_q			<=	'0';
	elsif(rising_edge(clock)) then
		wait_cnt_q			<=	wait_cnt_d;
		start_align_q		<=	start_align_d;
		start_align_in_q	<=	start_align_in_d;
		align_done_q		<=	align_done_d;
		frame_in_q			<=	frame_in_d;
		frame_tgt_q			<=	frame_tgt_d;
		bitslip_q			<=	bitslip_d;
	end if;
end process;

start_align_in_d(0)	<=	init_align;
start_align_in_d(1)	<=	start_align_in_q(0);

start_align_d		<=	not start_align_in_q(1) and start_align_in_q(0);

bitslip_out			<=	bitslip_q;

align_done			<=	align_done_q;	


process(clock, reset)
begin
	if(reset = '0') then
		state	<= init;
	elsif(rising_edge(clock)) then
		case state is
			when init				=>	if start_align_q = '1' then state	<= frame_check;
											else state <= init;
											end if;
			when frame_check		=>	if frame_in_q = frame_tgt_q then state <= done_align;
											else state <= start_bitslip;
											end if;
			when start_bitslip	=>	state	<=	wait_bitslip;
			when wait_bitslip		=>	if wait_cnt_q = x"ff" then state <= frame_check;
											else state <= wait_bitslip;
											end if;
--			when done_align		=>	if start_align_q = '1' then state <= frame_check;
--											else state <= done_align;
--											end if;
			when done_align		=>	state <= done_align;
			when others				=>	state <= init;
		end case;
	end if;
end process;

bitslip_d			<=	'1' when state	= start_bitslip else '0';	
en_wait_cnt			<=	'1' when state = wait_bitslip else '0';
align_done_d		<=	'1' when state = done_align else '0';
end architecture behavior;
			