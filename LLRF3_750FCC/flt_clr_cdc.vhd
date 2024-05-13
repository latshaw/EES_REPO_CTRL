library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flt_clr_cdc is
port (clk1		: 	in std_logic;
		clk2		: 	in std_logic;
		reset		: 	in std_logic;
		flt_clr		:	in std_logic;
		flt_clr_out	:	out std_logic
		
		);		
end entity flt_clr_cdc;
architecture behavior of flt_clr_cdc is

type state_type1 is (init_data_send, data_ready, data_ack_wait);
signal state1						: state_type1;
type state_type2 is (init_data_acq, flt_clr_st0, flt_clr_st1, data_ready_wait);
signal state2						: state_type2;

signal flt_clr_d, flt_clr_q		:	std_logic_vector(2 downto 0);
signal init_data				:	std_logic;
signal flt_clr_out_d:	std_logic;

signal data_rdy_clk1			:	std_logic;
signal dclk1_data_rdy, qclk1_data_rdy			:	std_logic;

signal dclk1_data_ack, qclk1_data_ack			:	std_logic_vector(2 downto 0);
signal dclk2_data_rdy,qclk2_data_rdy			:	std_logic_vector(2 downto 0);

signal dclk2_data_ack, qclk2_data_ack			:	std_logic;

signal data_ack_clk2							:	std_logic;
signal data_ready_clk2							:	std_logic;
signal data_ackldg_clk1							:	std_logic;

begin
	
flt_clr_d(0)		<=	flt_clr;	
flt_clr_d(2 downto 1)		<=	flt_clr_q(1 downto 0);
init_data			<=	flt_clr_q(2);	

dclk1_data_rdy			<=	data_rdy_clk1;
dclk1_data_ack			<=	qclk1_data_ack(1 downto 0)&qclk2_data_ack;
process(clk1, reset)
begin
	if(reset = '0') then		
		qclk1_data_rdy		<=	'0';
		qclk1_data_ack		<=	(others	=>	'0');
		flt_clr_q			<=	(others	=>	'0');
	elsif(rising_edge(clk1)) then
		qclk1_data_rdy		<=	dclk1_data_rdy;
		qclk1_data_ack		<=	dclk1_data_ack;
		flt_clr_q			<=	flt_clr_d;
	end if;
end process;

dclk2_data_rdy			<=	qclk2_data_rdy(1 downto 0)&qclk1_data_rdy;
dclk2_data_ack			<=	data_ack_clk2;
process(clk2, reset)
begin
	if(reset = '0') then		
		qclk2_data_rdy		<=	(others	=>	'0');
		qclk2_data_ack		<=	'0';
		flt_clr_out		<=	'0';
	elsif(rising_edge(clk2)) then		
		qclk2_data_rdy		<=	dclk2_data_rdy;
		qclk2_data_ack		<=	dclk2_data_ack;
		flt_clr_out		<=	flt_clr_out_d;	
	end if;
end process;				
data_ready_clk2		<= (not qclk2_data_rdy(2)) and qclk2_data_rdy(1);				
data_ackldg_clk1	<= (not qclk1_data_ack(2)) and qclk1_data_ack(1);


process(clk1, reset)
begin
	if (reset = '0') then
		state1	<= init_data_send;
	elsif (rising_edge(clk1)) then	
		case state1 is	
			when init_data_send	=> 	if init_data = '1' then state1 <= data_ready;		
												else state1 <= init_data_send;
												end if;
			when data_ready		=> 	state1	<=	data_ack_wait;									
			when data_ack_wait	=> 	if data_ackldg_clk1 = '1' then state1 <= init_data_send;
									else state1	<= data_ack_wait;
									end if;										
			when others			=> state1 <= init_data_send;		
		end case;	
	end if;	
end process;
data_rdy_clk1	<= '1' when state1 = data_ack_wait else '0';

process(clk2, reset)
begin
	if (reset = '0') then
		state2	<= init_data_acq;
	elsif (rising_edge(clk2)) then	
		case state2 is	
			when init_data_acq		=>	if data_ready_clk2 = '1' then state2 <= flt_clr_st0;
										else state2 <= init_data_acq;
										end if;		
--			when flt_clr_st0		=> 	state2 	<= flt_clr_st1;
			when flt_clr_st0		=>		state2	<=	flt_clr_st1;			
			when flt_clr_st1		=> 	state2	<=	data_ready_wait;										
			when data_ready_wait	=> 	if data_ready_clk2 = '1' then state2 <= flt_clr_st0;
										else state2	<= data_ready_wait;
										end if;										
			when others				=>	state2 <= init_data_acq;		
		end case;	
	end if;	
end process;
flt_clr_out_d			<=	'1' when state2 = flt_clr_st0 or state2 = flt_clr_st1 else '0';
--flt_clr_out_d(2 downto 1)	<=	flt_clr_out_q(1 downto 0);
--flt_clr_out				<=	flt_clr_out_q;

data_ack_clk2	<= '1' when state2 = data_ready_wait else '0';
end architecture behavior;
			
			