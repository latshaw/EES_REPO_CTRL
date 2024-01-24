library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_mode is
	port(clock			:	in std_logic;
			reset			:	in std_logic;
--			strobe	:	in std_logic;
--			takei		:	in std_logic;
--			ch_dis	:	in	std_logic;
--			mloop		:	in std_logic_vector(1 downto 0);
			pls_on		:	in std_logic_vector(15 downto 0);
			pls_off		:	in std_logic_vector(15 downto 0);
			plsmode		:	in	std_logic_vector(1 downto 0);
			plstrig_in	:	in	std_logic;
			pls_out		:	out std_logic
--			pls_done	:	out std_logic
			);
end entity pulse_mode;
architecture behavior of pulse_mode is
--type state_type is (st_init, st_load, st_high, st_low, st_done);
type state_type is (st_init, st_load, st_high, st_low);
type reg_record is record
state			:	state_type;
--mloop			:	std_logic_vector(1 downto 0);
--takei			:	std_logic_vector(2 downto 0);
plsmode		:	std_logic_vector(1 downto 0);
plstrig_in	:	std_logic_vector(1 downto 0);
pls_valid	:	std_logic;
pls_on_buf	:	std_logic_vector(15 downto 0);
pls_off_buf	:	std_logic_vector(15 downto 0);
pls_on		:	unsigned(15 downto 0);
pls_off		:	unsigned(15 downto 0);
pls_cnt		:	unsigned(26 downto 0);
pls_out_int	:	std_logic;
pls_out		:	std_logic;
--pls_done		:	std_logic;
init_pls		:	std_logic;
end record reg_record;
signal d,q	:	reg_record;
begin
--d.mloop			<=	mloop;
--d.takei			<=	q.takei(1 downto 0) & takei;
d.plsmode			<=	plsmode;
d.plstrig_in(0)	<=	plstrig_in;
d.plstrig_in(1)	<=	q.plstrig_in(0);
d.pls_on_buf		<=	pls_on;
d.pls_off_buf		<=	pls_off;
--d.init_pls			<=	'1' when q.takei(2 downto 1) = "10" and q.pls_on_buf /= x"0000" else '0';
d.pls_valid			<=	'1' when q.pls_on_buf /= x"0000" and q.pls_off_buf /= x"0000" else '0';
	
d.init_pls			<=	'1' when (q.pls_valid = '1' and q.plsmode = "01") or ------valid all the time in internal mode
										(q.pls_valid = '1' and q.plsmode = "10" and q.plstrig_in(0) = '1' and q.plstrig_in(1) = '0') else ------rising edge of the external trig in external trigger mode
										'0';

d.pls_out_int	<=	q.plstrig_in(1) when q.plsmode = "11" else q.pls_out;-----follow the external pulse in the external level mode										
pls_out			<=	q.pls_out_int;
--pls_done		<=	q.pls_done;
process(clock, reset)
begin
	if(reset = '0') then
		q.state			<=	st_init;
--		q.mloop			<=	(others	=>	'0');
--		q.takei			<=	(others	=>	'0');
		q.plsmode		<=	(others	=>	'0');
		q.plstrig_in	<=	(others	=>	'0');
		q.pls_valid		<=	'0';
		q.pls_on_buf	<=	(others	=>	'0');
		q.pls_off_buf	<=	(others	=>	'0');
		q.pls_on			<=	(others	=>	'0');
		q.pls_off			<=	(others	=>	'0');
		q.pls_cnt		<=	(others	=>	'0');
		q.pls_out_int	<=	'0';
		q.pls_out		<=	'0';
--		q.pls_done		<=	'0';
		q.init_pls		<=	'0';
	elsif(rising_edge(clock)) then
			q					<=	d;
	end if;
end process;
process(q)
begin
	d.state				<=	q.state;
	d.pls_on				<=	q.pls_on;
	d.pls_off			<=	q.pls_off;
	d.pls_cnt			<=	q.pls_cnt;
	d.pls_out			<=	q.pls_out;
--	d.pls_done			<=	q.pls_done;
	case q.state is
		when st_init	=>	
			if q.init_pls = '1' then
			d.pls_out		<=	'0';
--			d.pls_cnt		<=	q.pls_cnt + 1;
--			d.pls_done		<=	'0';
			d.state	<=	st_load;
			end if;
		when st_load	=>	
			d.pls_on		<=	unsigned(q.pls_on_buf);
			d.pls_out		<=	'1';
			d.pls_off	<=	unsigned(q.pls_off_buf);
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.state		<=	st_high;
		when st_high	=>
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.pls_out		<=	'1';
			if q.pls_cnt = q.pls_on & "00" & x"00" then
				d.pls_cnt	<= (others	=>	'0');
				d.state		<=	st_low;
			end if;
		when st_low		=>
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.pls_out		<=	'0';
			if q.pls_cnt = q.pls_off & "00" & x"00" then
				d.pls_cnt	<= (others	=>	'0');
				d.state		<=	st_init;
			end if;
		when others		=>	
			d.state			<=	st_init;
--		when st_done	=>
--			d.pls_done		<=	'1';
--			if q.takei(2 downto 1) = "01" then
--				d.pls_done	<=	'0';
--				d.state			<=	st_init;
--			end if;	
	end case;
end process;
end architecture behavior;	