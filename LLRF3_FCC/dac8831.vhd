library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dac8831 is
	port(clock	:	in std_logic;
		reset	:	in std_logic;
		d_in	:	in std_logic_vector(15 downto 0);
		
		ncs		:	out std_logic;
		sclk	:	out std_logic;
		sdi		:	out std_logic
		);
end entity dac8831;
architecture behavior of dac8831 is
signal d_in_d, d_in_q			:	std_logic_vector(15 downto 0);
signal sclk_d, sclk_q			:	std_logic;
signal cs_d, cs_q				:	std_logic;
signal sdi_d, sdi_q				:	std_logic;
signal wait_cnt_d, wait_cnt_q	:	integer range 0 to 127;
signal sclk_cnt_d, sclk_cnt_q	:	integer range 0 to 3;
type state_type is (st_init, st_acq, st_ncs, st_sclkl, st_sclkh, st_update);
signal state_d, state_q			:	state_type;
begin
ncs		<=	cs_q;
sclk	<=	sclk_q;
sdi		<=	sdi_q;
process(clock, reset)
begin
	if(reset = '0') then
		state_q		<=	st_init;
		d_in_q		<=	(others	=>	'0');
		sclk_q		<=	'1';
		cs_q		<=	'1';
		sdi_q		<=	'0';
		wait_cnt_q	<=	0;
		sclk_cnt_q	<=	0;
	elsif(rising_edge(clock)) then
		state_q		<=	state_d;
		d_in_q		<=	d_in_d;
		sclk_q		<=	sclk_d;
		cs_q		<=	cs_d;
		sdi_q		<=	sdi_d;
		wait_cnt_q	<=	wait_cnt_d;
		sclk_cnt_q	<=	sclk_cnt_d;
	end if;
end process;
process(state_q, d_in, d_in_q, sclk_q, cs_q, sdi_q, wait_cnt_q, sclk_cnt_q)
begin
	d_in_d		<=	d_in_q;
	sclk_d		<=	sclk_q;
	cs_d		<=	cs_q;
	sdi_d		<=	sdi_q;
	wait_cnt_d	<=	wait_cnt_q;
	sclk_cnt_d	<=	sclk_cnt_q;
	state_d		<=	state_q;
	case state_q is
		when st_init	=>	
			state_d		<=	st_acq;		
		when st_acq		=>	
			wait_cnt_d	<=	wait_cnt_q + 1;
			state_d		<=	st_ncs;
			d_in_d		<=	not d_in(15)&d_in(14 downto 0);
		when st_ncs		=>
			wait_cnt_d	<=	wait_cnt_q + 1;
			cs_d		<=	'0';
			if(wait_cnt_q	=	6) then
				state_d		<=	st_sclkl;	
			end if;
		when st_sclkl	=>
			wait_cnt_d	<=	wait_cnt_q + 1;
			sclk_cnt_d	<=	sclk_cnt_q + 1;
			sclk_d		<=	'0';
			sdi_d		<=	d_in_q(15);			
			if(sclk_cnt_q	= 1) then
				state_d		<=	st_sclkh;				
			end if;
		when st_sclkh	=>
			wait_cnt_d	<=	wait_cnt_q + 1;			
			sclk_d		<=	'1';
			if(sclk_cnt_q = 3) then
				sclk_cnt_d <= 0;
				d_in_d		<=	d_in_q(14 downto 0)&'0';
				if(wait_cnt_q = 70) then
					state_d	<=	st_update;
				else 
					state_d	<=	st_sclkl;
				end if;
			else
				sclk_cnt_d	<=	sclk_cnt_q + 1;
			end if;
		when st_update	=>			 
			 cs_d		<=	'1';
			 if(wait_cnt_q = 124) then
				 wait_cnt_d	<=	0;
				 state_d	<=	st_acq;
			else
				wait_cnt_d	<=	wait_cnt_q + 1;
			end if;
	end case;
end process;	
				
end architecture behavior;	
		