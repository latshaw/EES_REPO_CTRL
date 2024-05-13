-- 4/12/2024

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity pulse_mode_sep is
	port(clock			:	in std_logic;
			reset			:	in std_logic;
 
			pls_on		:	in std_logic_vector(15 downto 0);
			pls_perd		:	in std_logic_vector(15 downto 0);
 
			pls_out		:	out std_logic
			);
end entity pulse_mode_sep;
architecture behavior of pulse_mode_sep is
type state_type is (st_init, st_load, st_high, st_low);
type reg_record is record
state			:	state_type;
 
pls_valid	:	std_logic;
pls_on_buf	:	std_logic_vector(15 downto 0);
pls_perd_buf	:	std_logic_vector(15 downto 0);
pls_on		:	unsigned(15 downto 0);
pls_perd		:	unsigned(15 downto 0);
pls_cnt		:	unsigned(28 downto 0);
pls_out_int	:	std_logic;
pls_out		:	std_logic;
init_pls		:	std_logic;
end record reg_record;
signal d,q	:	reg_record;
begin
d.pls_on_buf		<=	pls_on;
d.pls_perd_buf		<=	pls_perd;
d.pls_valid			<=	'1' when q.pls_on_buf /= x"0000" and q.pls_perd_buf /= x"0000" and q.pls_on_buf < q.pls_perd_buf else '0';
d.init_pls			<=	q.pls_valid;
 
d.pls_out_int	<=	'1' when q.pls_on_buf /= x"0000" and q.pls_perd_buf /= x"0000" and q.pls_on_buf >= q.pls_perd_buf  else q.pls_out;
					
pls_out			<=	q.pls_out_int;
process(clock, reset)
begin
	if(reset = '0') then
		q.state			<=	st_init;
		q.pls_valid		<=	'0';
		q.pls_on_buf	<=	(others	=>	'0');
		q.pls_perd_buf	<=	(others	=>	'0');
		q.pls_on			<=	(others	=>	'0');
		q.pls_perd			<=	(others	=>	'0');
		q.pls_cnt		<=	(others	=>	'0');
		q.pls_out_int	<=	'0';
		q.pls_out		<=	'0';
		q.init_pls		<=	'0';
	elsif(rising_edge(clock)) then
			q					<=	d;
	end if;
end process;
process(q)
begin
	d.state				<=	q.state;
	d.pls_on				<=	q.pls_on;
	d.pls_perd			<=	q.pls_perd;
	d.pls_cnt			<=	q.pls_cnt;
	d.pls_out			<=	q.pls_out;
	case q.state is
		when st_init	=>	
			if q.init_pls = '1' then
			d.pls_out		<=	'0';
			d.state	<=	st_load;
			end if;
		when st_load	=>	
			d.pls_on		<=	unsigned(q.pls_on_buf);
			d.pls_out		<=	'1';
			d.pls_perd	<=	unsigned(q.pls_perd_buf);
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.state		<=	st_high;
		when st_high	=>
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.pls_out		<=	'1';
			if q.pls_cnt = q.pls_on & '0' & x"000" then
				--d.pls_cnt	<= (others	=>	'0');
				d.state		<=	st_low;
			end if;
		when st_low		=>
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.pls_out		<=	'0';
			if q.pls_cnt = q.pls_perd & '0' & x"000" then
				d.pls_cnt	<= (others	=>	'0');
				d.state		<=	st_init;
			end if;
		when others		=>	
			d.state			<=	st_init;
 
	end case;
end process;
end architecture behavior;