library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity power_sequence is
port(clock				:	in std_logic;
		reset				:	in	std_logic;
		
		ss_pok			:	in	std_logic;
		uv_alarm			:	in std_logic;
		
		pgood_0p9v		:	in	std_logic;
		pgood_3p3v		:	in	std_logic;
		
		pgood_0p95		:	in std_logic;
		
		pgood_1p8		:	in	std_logic;
		
		pgood_1p8vio	:	in	std_logic;
		pgood_vioadj	:	in std_logic;
		
		
		en_group1		:	out std_logic;
		en_group2		:	out std_logic;
		en_group3		:	out std_logic;
		en_group4		:	out std_logic;
		
		dis_group1		:	out std_logic;
		dis_group2		:	out std_logic;
		dis_group3		:	out std_logic;
		dis_group4		:	out std_logic;
		c10_reset		:	out std_logic;
		pgood				:	out std_logic;
		pmbus_sda		:	inout std_logic;
		pmbus_scl		:	out std_logic
		);
end entity power_sequence;
architecture behavior of power_sequence is
type state_type is (init, enable1, enable2, enable3, enable4, pgood_check, pwr_done, disable4, discharge4, disable3, discharge3, disable2, discharge2, disable1, discharge1, disable_done);
signal state								:	state_type;
signal wait_cnt_d, wait_cnt_q			:	std_logic_vector(23 downto 0);
signal en_wait_cnt						:	std_logic;
signal pgood_grp1_d, pgood_grp1_q	:	std_logic;
signal pgood_grp2_d, pgood_grp2_q	:	std_logic;
signal pgood_grp3_d, pgood_grp3_q	:	std_logic;
signal pgood_grp4_d, pgood_grp4_q	:	std_logic;
signal en_group1_d, en_group1_q		:	std_logic;
signal en_group2_d, en_group2_q		:	std_logic;
signal en_group3_d, en_group3_q		:	std_logic;
signal en_group4_d, en_group4_q		:	std_logic;
signal pgood_d, pgood_q					:	std_logic;
signal ss_pok_d, ss_pok_q				:	std_logic;
signal pok_d, pok_q						:	std_logic;
signal dis_cnt_d, dis_cnt_q			:	std_logic_vector(11 downto 0);
signal en_dis_cnt							:	std_logic;
signal dis_group1_d, dis_group1_q	:	std_logic;
signal dis_group2_d, dis_group2_q	:	std_logic;
signal dis_group3_d, dis_group3_q	:	std_logic;
signal dis_group4_d, dis_group4_q	:	std_logic;
signal c10_reset_d, c10_reset_q		:	std_logic;
signal uv_alarm_d, uv_alarm_q			:	std_logic_vector(1 downto 0);
signal uv_alarm_active					:	std_logic;


begin

pmbus_sda			<=	'Z';
pmbus_scl			<=	'Z';

uv_alarm_d(0)		<=	uv_alarm;
uv_alarm_d(1)		<=	uv_alarm_q(0);
uv_alarm_active	<=	uv_alarm_q(1) and (not uv_alarm_q(0));



ss_pok_d			<=	ss_pok;
pok_d				<=	ss_pok and uv_alarm;
wait_cnt_d		<=	wait_cnt_q + '1' when en_wait_cnt = '1' else wait_cnt_q;
pgood_grp1_d	<=	pgood_3p3v and pgood_0p9v;
pgood_grp2_d	<=	pgood_0p95;
pgood_grp3_d	<=	pgood_1p8;
pgood_grp4_d	<=	pgood_1p8vio and pgood_vioadj;
dis_cnt_d		<=	dis_cnt_q + '1' when en_dis_cnt = '1' else dis_cnt_q;

en_wait_cnt		<=	'1' when (state = init and ss_pok_q = '1') or state = enable1 or (state = enable2 and pgood_grp1_q = '1') or (state = enable3 and pgood_grp2_q = '1') or
						(state = enable4 and pgood_grp3_q = '1') else '0';
en_dis_cnt		<=	'1' when state = discharge4 or state = discharge3 or state = discharge2 or state = discharge1 else '0';

c10_reset_d		<=	'1' when state = pwr_done else '0';
c10_reset		<=	c10_reset_q;						


process(clock, reset,uv_alarm_active)
begin
	if(reset = '0') then
		state	<=	init;
	elsif(uv_alarm_active = '1') then
		state	<=	disable4;
	elsif(rising_edge(clock)) then
		case state is
			when init		=>	if ss_pok_q = '1' then
										if wait_cnt_q	=	x"ffffff" then	state	<= enable1;
										else state	<=	init;
										end if;
									else state	<=	init;
									end if;	
			when enable1	=>	if wait_cnt_q = x"ffffff" then state	<=	enable2;
									else state	<=	enable1;
									end if;
			when enable2	=>	if pgood_grp1_q = '1' then
										if wait_cnt_q = x"ffffff" then state	<=	enable3;
										else state	<=	enable2;
										end if;
									else state	<=	enable2;
									end if;
			when enable3	=>	if pgood_grp2_q = '1' then
										if wait_cnt_q = x"ffffff" then state	<=	enable4;
										else state	<=	enable3;
										end if;
									else state	<=	enable3;
									end if;						
			when enable4	=>	if pgood_grp3_q = '1' then
										if wait_cnt_q = x"ffffff" then state	<=	pgood_check;
										else state	<=	enable4;
										end if;
									else state	<=	enable4;
									end if;
			when pgood_check	=>	if pgood_grp4_q = '1' then	state		<=	pwr_done;
										else state	<=	pgood_check;
										end if;					
			when pwr_done		=>	state	<=	pwr_done;
			when disable4		=>	state	<=	discharge4;
			when discharge4	=>	if dis_cnt_q = x"fff" then state	<=	disable3;
										else state	<=	discharge4;
										end if;
			when disable3		=>	state	<=	discharge3;
			when discharge3	=>	if dis_cnt_q = x"fff" then state	<=	disable2;
										else state	<=	discharge3;
										end if;		
			when disable2		=>	state	<=	discharge2;
			when discharge2	=>	if dis_cnt_q = x"fff" then state	<=	disable1;
										else state	<=	discharge2;
										end if;			
			when disable1		=>	state	<=	discharge1;
			when discharge1	=>	if dis_cnt_q = x"fff" then state	<=	disable_done;
										else state	<=	discharge1;
										end if;
			when disable_done	=>	if	pok_q = '1' then state	<=	init;
										else state	<=	disable_done;
										end if;
			when others			=>	state	<=	disable_done;			
		end case;
	end if;
end process;

en_group1_d			<=	'1' when state = enable1 and wait_cnt_q = x"ffffff" else
							'0' when state = disable1 else en_group1_q;
en_group2_d			<=	'1' when state = enable2 and wait_cnt_q = x"ffffff" else
							'0' when state = disable2 else en_group2_q;
en_group3_d			<=	'1' when state = enable3 and wait_cnt_q = x"ffffff" else
							'0' when state = disable3 else en_group3_q;
en_group4_d			<=	'1' when state = enable4 and wait_cnt_q = x"ffffff" else
							'0' when state = disable4 else en_group4_q;

dis_group1_d		<=	'1' when state = discharge1 else
							'0' when state = disable_done else dis_group1_q;
dis_group2_d		<=	'1' when state = discharge2 else
							'0' when state = disable_done else dis_group1_q;
dis_group3_d		<=	'1' when state = discharge3 else
							'0' when state = disable_done else dis_group1_q;
dis_group4_d		<=	'1' when state = discharge4 else
							'0' when state = disable_done else dis_group1_q;							


pgood_d				<=	'1' when state = pwr_done else '0';
process(clock, reset)
begin
	if(reset = '0') then
		wait_cnt_q		<=	(others	=>	'0');
		dis_cnt_q		<=	(others	=>	'0');
		pgood_grp1_q	<=	'0';
		pgood_grp2_q	<=	'0';
		pgood_grp3_q	<=	'0';
		pgood_grp4_q	<=	'0';
		en_group1_q		<=	'0';
		en_group2_q		<=	'0';
		en_group3_q		<=	'0';
		en_group4_q		<=	'0';
		dis_group1_q	<=	'0';
		dis_group2_q	<=	'0';
		dis_group3_q	<=	'0';
		dis_group4_q	<=	'0';
		pgood_q			<=	'0';
		ss_pok_q			<=	'0';
		pok_q				<=	'0';
		c10_reset_q		<=	'0';
		uv_alarm_q		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		wait_cnt_q		<=	wait_cnt_d;
		dis_cnt_q		<=	dis_cnt_d;
		pgood_grp1_q	<=	pgood_grp1_d;
		pgood_grp2_q	<=	pgood_grp2_d;
		pgood_grp3_q	<=	pgood_grp3_d;
		pgood_grp4_q	<=	pgood_grp4_d;
		en_group1_q		<=	en_group1_d;
		en_group2_q		<=	en_group2_d;
		en_group3_q		<=	en_group3_d;
		en_group4_q		<=	en_group4_d;
		dis_group1_q	<=	dis_group1_d;
		dis_group2_q	<=	dis_group2_d;
		dis_group3_q	<=	dis_group3_d;
		dis_group4_q	<=	dis_group4_d;
		pgood_q			<=	pgood_d;
		ss_pok_q			<=	ss_pok_d;
		pok_q				<=	pok_d;
		c10_reset_q		<=	c10_reset_d;
		uv_alarm_q		<=	uv_alarm_d;
	end if;
end process;	
		
en_group1	<=	en_group1_q;
en_group2	<=	en_group2_q;
en_group3	<=	en_group3_q;
en_group4	<=	en_group4_q;
dis_group1	<=	dis_group1_q;
dis_group2	<=	dis_group2_q;
dis_group3	<=	dis_group3_q;
dis_group4	<=	dis_group4_q;

pgood			<=	pgood_q;




end architecture behavior;		