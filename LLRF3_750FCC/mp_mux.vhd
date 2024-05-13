library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mp_mux is
	port(clock	:	in std_logic;
		reset_n	:	in std_logic;
		strobe	:	in std_logic;
		mag_lp	:	in	std_logic_vector(1 downto 0);
		phs_lp	:	in	std_logic_vector(1 downto 0);
		glos		:	in	std_logic_vector(17 downto 0);		
		gpid		:	in	std_logic_vector(17 downto 0);
		gdcl		:	in	std_logic_vector(17 downto 0);
		poff		:	in	std_logic_vector(17 downto 0);
		ppid		:	in	std_logic_vector(17 downto 0);
		gout		:	out std_logic_vector(17 downto 0);
		pout		:	out std_logic_vector(17 downto 0);
		strobe_out	:	out std_logic
		);
end entity mp_mux;
architecture behavior of mp_mux is
type reg_record is record
mag_lp	:	std_logic_vector(1 downto 0);
phs_lp	:	std_logic_vector(1 downto 0);
glos		:	std_logic_vector(17 downto 0);
gpid		:	std_logic_vector(17 downto 0);
gdcl		:	std_logic_vector(17 downto 0);
poff		:	std_logic_vector(17 downto 0);
ppid		:	std_logic_vector(17 downto 0);
phs_int	:	std_logic_vector(17 downto 0);
gint		:	std_logic_vector(17 downto 0);
gout		:	std_logic_vector(17 downto 0);
pout		:	std_logic_vector(17 downto 0);
end record reg_record;
signal d,q	:	reg_record;
begin
d.mag_lp		<=	mag_lp;
d.phs_lp		<=	phs_lp;
d.glos		<=	glos;
d.gpid		<=	gpid;
d.gdcl		<=	gdcl;
d.poff		<=	poff;
d.ppid		<=	ppid;
d.phs_int	<=	std_logic_vector(signed(q.ppid)+signed(q.poff));
d.gint		<=	q.gpid when q.mag_lp = "10" else q.glos;
d.gout		<=	q.gint when signed(q.gint) < signed(q.gdcl) else q.gdcl;
d.pout		<=	q.phs_int when q.phs_lp = "10" else q.poff;

process(clock, reset_n)
begin
	if(reset_n	=	'0') then
		q.mag_lp		<=	(others	=>	'0');
		q.phs_lp		<=	(others	=>	'0');
		q.glos		<=	(others	=>	'0');
		q.gpid		<=	(others	=>	'0');
		q.gdcl		<=	(others	=>	'0');
		q.poff		<=	(others	=>	'0');
		q.ppid		<=	(others	=>	'0');
		q.phs_int	<=	(others	=>	'0');
		q.gint		<=	(others	=>	'0');
		q.gout		<=	(others	=>	'0');
		q.pout		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		strobe_out	<=	strobe;
		if(strobe = '1') then
			q				<=	d;
		end if;	
	end if;
end process;

gout	<=	q.gout;
pout	<=	q.pout;	
		
				



end architecture behavior;		
		