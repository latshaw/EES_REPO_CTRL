library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pulse_mode_all is
	port(clock		:	in std_logic;
			reset		:	in std_logic;
			strobe	:	in std_logic;
			takei		:	in std_logic;
			mloop		:	in std_logic_vector(1 downto 0);
			pls_on	:	in std_logic_vector(31 downto 0);
			pls_off	:	in std_logic_vector(31 downto 0);
			pls_out	:	out std_logic;
			pls_done	:	out std_logic
			);
end entity pulse_mode_all;
architecture behavior of pulse_mode is
type state_type is (st_init, st_load, st_high, st_low, st_done);
type reg_record is record
state			:	state_type;
mloop			:	std_logic_vector(1 downto 0);
takei			:	std_logic_vector(2 downto 0);
pls_on_buf	:	std_logic_vector(31 downto 0);
pls_off_buf	:	std_logic_vector(31 downto 0);
pls_on		:	unsigned(31 downto 0);
pls_off		:	unsigned(31 downto 0);
pls_cnt		:	unsigned(31 downto 0);
pls_out		:	std_logic;
pls_done		:	std_logic;
init_pls		:	std_logic;
end record reg_record;
signal d,q	:	reg_record;
begin
d.mloop			<=	mloop;
d.takei			<=	q.takei(1 downto 0) & takei;
d.pls_on_buf		<=	pls_on;
d.pls_off_buf		<=	pls_off;
d.init_pls			<=	'1' when q.takei(2 downto 1) = "01" and q.pls_on_buf /= x"00000000" else '0';	
pls_out			<=	q.pls_out;
pls_done		<=	q.pls_done;
process(clock, reset)
begin
	if(reset = '0') then
		q.state			<=	st_init;
		q.mloop			<=	(others	=>	'0');
		q.takei			<=	(others	=>	'0');
		q.pls_on_buf	<=	(others	=>	'0');
		q.pls_off_buf	<=	(others	=>	'0');
		q.pls_on			<=	(others	=>	'0');
		q.pls_off			<=	(others	=>	'0');
		q.pls_cnt		<=	(others	=>	'0');
		q.pls_out		<=	'0';
		q.pls_done		<=	'0';
		q.init_pls		<=	'0';
	elsif(rising_edge(clock)) then
		if (strobe = '1') then
			q					<=	d;
		end if;	
	end if;
end process;
process(q)
begin
	d.state				<=	q.state;
	d.pls_on				<=	q.pls_on;
	d.pls_off			<=	q.pls_off;
	d.pls_cnt			<=	q.pls_cnt;
	d.pls_out			<=	q.pls_out;
	d.pls_done			<=	q.pls_done;
	case q.state is
		when st_init	=>	
			if q.init_pls = '1' then
			d.pls_done		<=	'0';
			d.state	<=	st_load;
			end if;
		when st_load	=>	
			d.pls_on		<=	unsigned(q.pls_on_buf);
			d.pls_off	<=	unsigned(q.pls_off_buf);
			d.state		<=	st_high;
		when st_high	=>
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.pls_out		<=	'1';
			if q.pls_cnt = q.pls_on then
				d.pls_cnt	<= (others	=>	'0');
				d.state		<=	st_low;
			end if;
		when st_low		=>
			d.pls_cnt		<=	q.pls_cnt + 1;
			d.pls_out		<=	'0';
			if q.pls_cnt = q.pls_off then
				d.pls_cnt	<= (others	=>	'0');
				d.state		<=	st_done;
			end if;
		when st_done	=>
			d.pls_done		<=	'1';
			if q.takei(2 downto 1) = "10" then
				d.pls_done	<=	'0';
				d.state			<=	st_init;
			end if;	
	end case;
end process;
end architecture behavior;			