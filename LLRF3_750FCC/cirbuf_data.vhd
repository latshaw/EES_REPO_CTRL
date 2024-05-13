-------------------------------------------------------------------------------
--
-- Title       : cirbuf_data
-- Design      : shift_by_m
-- Author      : bachimanchi
-- Company     : Jefferson Lab
--
-------------------------------------------------------------------------------
--
-- File        : c:\My_Designs\Separator\shift_by_m\src\cirbuf_data.vhd
-- Generated   : Fri Dec  7 16:08:54 2018
-- From        : interface description file
-- By          : Itf2Vhdl ver. 1.22
--
-------------------------------------------------------------------------------
--
-- Description : 
--
-------------------------------------------------------------------------------

--{{ Section below this comment is automatically maintained
--   and may be overwritten
--{entity {cirbuf_data} architecture {beahvior}}

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use work.components.all;
LIBRARY lpm;
USE lpm.lpm_components.all;


entity cirbuf_data is
	port(	wrclock		:	in std_logic;
			rdclock		:	in std_logic;		
			reset			:	in std_logic;
		 
			takei			:	in std_logic;
			strobe		:	in std_logic;
			rate			:	in std_logic_vector(17 downto 0);
			isa_addr_rd : 	in std_logic_vector(23 downto 0);		 
			data_in		:	in reg18_10;
			data_out		:	out reg18_10;
			
			buf_done		: 	out std_logic
			);
		 
	
end cirbuf_data;

--}} End of automatically maintained section

architecture behavior of cirbuf_data is
	component dpram_ram_2port_0 is
		port (
			data_a    : in  std_logic_vector(17 downto 0) := (others => 'X'); -- datain_a
			q_a       : out std_logic_vector(17 downto 0);                    -- dataout_a
			data_b    : in  std_logic_vector(17 downto 0) := (others => 'X'); -- datain_b
			q_b       : out std_logic_vector(17 downto 0);                    -- dataout_b
			address_a : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address_a
			address_b : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address_b
			wren_a    : in  std_logic                     := 'X';             -- wren_a
			wren_b    : in  std_logic                     := 'X';             -- wren_b
			clock_a   : in  std_logic                     := 'X';             -- clk
			clock_b   : in  std_logic                     := 'X'              -- clk
		);
	end component dpram_ram_2port_0;




signal rate_reg_d			:	std_logic_vector(17 downto 0);
signal rate_reg_q			:	std_logic_vector(17 downto 0);
signal en_rate_reg		:	std_logic;

signal rate_cnt_q			:	std_logic_vector(17 downto 0);
signal rate_cnt_d			: 	std_logic_vector(17 downto 0);
signal en_rate_cnt		:	std_logic;
signal clr_rate_cnt		:	std_logic;

signal addr_cnt_q			: 	std_logic_vector(11 downto 0);
signal addr_cnt_d			: 	std_logic_vector(11 downto 0);
signal en_addr_cnt		:	std_logic;

signal addr_reg_q			:	std_logic_vector(11 downto 0);
signal addr_reg_d			:	std_logic_vector(11 downto 0);
signal en_addr_reg		:	std_logic;

signal data_reg_d			:	reg18_10;
signal data_reg_q			:	reg18_10;

signal en_data_reg		:	std_logic;


signal mem_wen_q			:	std_logic;
signal mem_wen_d			:	std_logic;

signal en_data_acq		:	std_logic;

signal takei_q  			: 	std_logic_vector(2 downto 0);
signal takei_d  			: 	std_logic_vector(2 downto 0);

signal en_q					:	std_logic_vector(3 downto 0);
signal en_d					:	std_logic_vector(3 downto 0);

signal mem_addr_rd_q  	: 	std_logic_vector(11 downto 0);
signal mem_addr_rd_d  	: 	std_logic_vector(11 downto 0);

signal mem_addr_q     	: 	std_logic_vector(11 downto 0);
signal mem_addr_d     	: 	std_logic_vector(11 downto 0);

signal wen_q          	: 	std_logic;
signal wen_d          	: 	std_logic;

signal buf_done_q     	: 	std_logic;
signal buf_done_d     	: 	std_logic;
signal en_buf_done    	: 	std_logic;
signal clr_buf_done   	: 	std_logic;

signal init_data_acq		:	std_logic;

signal data_out_mem		:	reg18_10;


signal takei_rd_q  			: 	std_logic_vector(2 downto 0);
signal takei_rd_d  			: 	std_logic_vector(2 downto 0);
signal init_data_acq_rd		:	std_logic;


signal isa_rd				:	std_logic;
signal data_out_a			:	reg18_10;



type state_type is (st_init, st_rate_cnt_chk, st_data_acq, st_wen, st_addr_chk, st_done);
signal state				:	state_type;


begin




process(wrclock, reset, strobe)
begin
	if(reset = '0') then
		state	<=	st_init;
	elsif(rising_edge(wrclock) and strobe = '1') then
		case state is
			when st_init			=>	if init_data_acq = '1' and rate_reg_q /= "00"& x"0000" then state	<=	st_rate_cnt_chk;
											else state	<=	st_init;
											end if;
			when st_rate_cnt_chk	=>	if rate_cnt_q = std_logic_vector(unsigned(rate_reg_q) - 1) then state	<=	st_data_acq;
											else state	<=	st_rate_cnt_chk;
											end if;
			when st_data_acq		=>	state	<=	st_wen;
			when st_wen				=>	state	<=	st_addr_chk;
			when st_addr_chk		=>	if addr_cnt_q = x"fff" then state	<=	st_done;
											else state	<=	st_rate_cnt_chk;
											end if;
			when st_done			=>	state	<=	st_init;
		end case;
	end if;
end process;
	
	


rate_reg_d				<=	rate when en_rate_reg = '1' else
								rate_reg_q;
rate_cnt_d				<=	(others => '0') when rate_cnt_q = std_logic_vector(unsigned(rate_reg_q) - 1) or clr_rate_cnt = '0' else
								std_logic_vector(unsigned(rate_cnt_q) + 1) when en_rate_cnt = '1' else
								rate_cnt_q;
addr_cnt_d				<=	std_logic_vector(unsigned(addr_cnt_q) + 1) when en_addr_cnt = '1' else
								addr_cnt_q;
								
en_addr_cnt				<=	'1' when state = st_addr_chk else '0';
en_rate_reg				<=	'1' when state = st_init else '0';																
en_rate_cnt				<=	'0' when state = st_init or state = st_done else '1';								
clr_rate_cnt			<=	'0' when state = st_done else '1';
en_addr_reg				<=	'1' when state = st_data_acq else '0';
en_data_reg				<=	'1' when state = st_data_acq else '0';								
mem_wen_d				<=	'1' when state = st_wen else '0';

takei_d(0)          	<= takei;
takei_d(2 downto 1) 	<= takei_q(1 downto 0);
init_data_acq			<=	takei_q(1) and not takei_q(2);


clr_buf_done    		<=  not (takei_q(1) and not takei_q(0));
en_buf_done     		<=  '1' when state = st_done else '0';

buf_done_d      		<=	'0' when clr_buf_done = '0' else
								'1' when en_buf_done = '1' else
                    		buf_done_q;
                    
buf_done        		<=  buf_done_q;                   


--mem_addr_rd_d 			<=  std_logic_vector(unsigned(isa_addr_rd(11 downto 0)) + unsigned(addr_cnt_q)) when isa_addr_rd(23 downto 12) /= x"000" else mem_addr_rd_q;
takei_rd_d(0)          	<= takei;
takei_rd_d(2 downto 1) 	<= takei_rd_q(1 downto 0);
init_data_acq_rd			<=	takei_rd_q(1) and not takei_rd_q(2);
mem_addr_rd_d 			<= isa_addr_rd(11 downto 0) when isa_addr_rd(23 downto 12) /= x"000"else
								mem_addr_rd_q;


data_mem_gen_i:for i in 0 to 9 generate				
data_reg_d(i)			<=	data_in(i) when en_data_reg = '1' else
								data_reg_q(i);							
end generate;
--data_out(179 downto 162)	<=	data_out_mem(9);
--data_out(161 downto 144)	<=	data_out_mem(8);
--data_out(143 downto 126)	<=	data_out_mem(7);
--data_out(125 downto 108)	<=	data_out_mem(6);
--data_out(107 downto 90)		<=	data_out_mem(5);
--data_out(89 downto 72)		<=	data_out_mem(4);
--data_out(71 downto 54)		<=	data_out_mem(3);							
--data_out(53 downto 36)		<=	data_out_mem(2);
--data_out(35 downto 18)		<=	data_out_mem(1);
--data_out(17 downto 0)		<=	data_out_mem(0);

addr_reg_d			<=	addr_cnt_q when en_addr_reg = '1' else addr_reg_q;
wen_d     			<= mem_wen_q;

	
process(rdclock, reset)
begin
	if(reset = '0') then
		mem_addr_rd_q 	<= 	(others 	=>	'0');
		takei_rd_q		<=		(others	=>	'0');	
	elsif(rising_edge(rdclock)) then
		mem_addr_rd_q 	<= 	mem_addr_rd_d;
		takei_rd_q		<=		takei_rd_d;
	end if;
end process;	
		

process(wrclock, reset)
begin
	if(reset = '0') then
		rate_reg_q		<=		(others 	=> '0');
		rate_cnt_q		<=		(others 	=> '0');
		addr_cnt_q		<=		(others 	=> '0');
		addr_reg_q		<=		(others	=> '0');
		data_reg_q		<=		(others	=>	(others	=>	'0'));
		mem_wen_q		<=		'0';
		wen_q       	<= 	'0';
		takei_q     	<= 	(others 	=> '0');
		buf_done_q  	<= 	'0';
	elsif(rising_edge(wrclock)) then		
		if(strobe = '1') then
			takei_q     	<= 	takei_d;
			rate_reg_q		<=		rate_reg_d;
			rate_cnt_q		<=		rate_cnt_d;
			addr_cnt_q		<=		addr_cnt_d;
			addr_reg_q		<=		addr_reg_d;
			data_reg_q		<=		data_reg_d;
			mem_wen_q		<=		mem_wen_d;
			wen_q       	<= 	wen_d;
			buf_done_q  	<= 	buf_done_d;
		end if;	
	end if;
end process;




mem_dpram_gen_i: for i in 0 to 9 generate
u1_j: dpram_ram_2port_0
		port map(
					data_a    =>	data_reg_q(i),	 -- datain_a
					q_a       =>	open,                    -- dataout_a
					data_b    =>	"00"&x"0000", -- datain_b
					q_b       =>	data_out(i),                    -- dataout_b
					address_a =>	addr_cnt_q, -- address_a
					address_b =>	mem_addr_rd_q, -- address_b
					wren_a    =>	wen_q,             -- wren_a
					wren_b    =>	'0',             -- wren_b
					clock_a   =>	wrclock,             -- clk
					clock_b   =>	rdclock              -- clk
					);
end generate;					

end behavior;
