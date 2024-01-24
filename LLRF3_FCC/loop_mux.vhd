-----------------------------------------mux to select signals for drive
-------mag loop 0, phase loop 0 is tone mode
-------mag loop 0, phase loop 1 is free running select
-------mag loop 2, phase loop 1 is gradient lock sel
-------mag loop 2, phase loop 2 is gradient and phase locked(GDR)
-------mag loop 3, phase loop 1 is pulse mode


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity loop_mux is
port	(clock	:	in std_logic;
		reset		:	in std_logic;
		load		:	in std_logic;
		mag_lp	:	in std_logic_vector(1 downto 0);
		phs_lp	:	in std_logic_vector(1 downto 0);
		pulse_out	:	in std_logic;
		
		glos		:	in std_logic_vector(17 downto 0);
		gdcl		:	in std_logic_vector(17 downto 0);	
		glos_kly	:	in std_logic_vector(17 downto 0);
		kly_ch	:	in std_logic;
		gpid		:	in std_logic_vector(17 downto 0);		
		gmes		:	in std_logic_vector(17 downto 0);
		
		plos		:	in std_logic_vector(17 downto 0);
		pmes		:	in std_logic_vector(17 downto 0);
		ppid		:	in std_logic_vector(17 downto 0);		
		poff		:	in std_logic_vector(17 downto 0);
		
		xout		:	out std_logic_vector(17 downto 0);
		yout		:	out std_logic_vector(17 downto 0);
		phs		:	out std_logic_vector(17 downto 0)
		);
end entity loop_mux;
architecture behavior of loop_mux is
type reg_record is record
mag_lp_int	:	integer range 0 to 3;
phs_lp_int	:	integer range 0 to 3;
pulse_out	:	std_logic;
glos			:	std_logic_vector(17 downto 0);
gdcl			:	std_logic_vector(17 downto 0);
glos_kly		:	std_logic_vector(17 downto 0);
kly_ch		:	std_logic;
gpid			:	std_logic_vector(17 downto 0);
gmes			:	std_logic_vector(17 downto 0);
plos			:	std_logic_vector(17 downto 0);
pmes			:	std_logic_vector(17 downto 0);
ppid			:	std_logic_vector(17 downto 0);
poff			:	std_logic_vector(17 downto 0);
xout			:	std_logic_vector(17 downto 0);
yout			:	std_logic_vector(17 downto 0);
phs			:	std_logic_vector(17 downto 0);
phs_int		:	std_logic_vector(17 downto 0);
pulse_glos	:	std_logic_vector(17 downto 0);
pulse_glos_out	:	std_logic_vector(17 downto 0);
glos_mux		:	std_logic_vector(17 downto 0);
glos_out		:	std_logic_vector(17 downto 0);
end record;
signal d,q	:	reg_record;
begin
d.mag_lp_int	<=	to_integer(unsigned(mag_lp));
d.phs_lp_int	<=	to_integer(unsigned(phs_lp));
d.pulse_out	<=	pulse_out;
d.glos		<=	glos;
d.gdcl		<=	gdcl;
d.glos_kly	<=	glos_kly;
d.kly_ch		<=	kly_ch;
d.gpid		<=	gpid;
d.gmes		<=	gmes;
d.plos		<=	plos;
d.pmes		<=	pmes;
d.ppid		<=	ppid;
d.poff		<=	poff;
d.phs_int	<=	std_logic_vector(signed(q.pmes)+signed(q.poff));
d.glos_mux	<=	q.glos when q.kly_ch = '0' else q.glos_kly;
d.glos_out	<=	q.glos_mux when q.glos_mux < q.gdcl else q.gdcl;
d.pulse_glos		<=	q.glos when q.pulse_out = '1' else (others	=>	'0');
d.pulse_glos_out	<=	q.pulse_glos when q.pulse_glos < q.gdcl else q.gdcl;
with q.mag_lp_int select
			d.xout	<=	q.pulse_glos_out when 3,
							q.gpid when 2,
							q.gmes when 1,
							q.glos_out when others;
			d.yout	<=	q.ppid when q.phs_lp_int = 2 else (others	=>	'0');
			d.phs		<=	q.plos when q.phs_lp_int = 0 else q.phs_int;						
			
process(clock, reset)
begin
	if(reset = '0') then
		q.mag_lp_int	<=	0;
		q.phs_lp_int	<=	0;
		q.pulse_out		<=	'0';
		q.glos			<=	(others	=>	'0');
		q.gdcl			<=	(others	=>	'0');
		q.glos_kly		<=	(others	=>	'0');
		q.kly_ch			<=	'0';
		q.gpid			<=	(others	=>	'0');
		q.gmes			<=	(others	=>	'0');
		q.plos			<=	(others	=>	'0');
		q.pmes			<=	(others	=>	'0');
		q.ppid			<=	(others	=>	'0');
		q.poff			<=	(others	=>	'0');		
		q.xout			<=	(others	=>	'0');
		q.yout			<=	(others	=>	'0');
		q.phs				<=	(others	=>	'0');
		q.phs_int		<=	(others	=>	'0');
		q.pulse_glos	<=	(others	=>	'0');
		q.pulse_glos_out	<=	(others	=>	'0');		
		q.glos_mux		<=	(others	=>	'0');
		q.glos_out		<=	(others	=>	'0');		
	elsif(rising_edge(clock)) then
		if(load = '1') then
			q	<=	d;
		end if;	
	end if;
end process;

xout		<=	q.xout;
yout		<=	q.yout;
phs		<=	q.phs;	
								
end architecture behavior;						