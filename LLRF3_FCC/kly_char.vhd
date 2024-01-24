library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity kly_char is
	port(clock		:	in std_logic;
			reset		:	in std_Logic;
			takei		:	in std_logic;
			mloop		:	in std_logic_vector(1 downto 0);	
			ploop		:	in std_logic_vector(1 downto 0);
			strobe	:	in std_logic;
			kly_ch	:	in std_logic;
			glos		:	in std_logic_vector(17 downto 0);
			glos_out	:	out std_logic_vector(17 downto 0);
			kly_ch_done		:	out std_logic
			);
end entity kly_char;
architecture behavior of kly_char is
type state_type is (st_init, state_kly, state_chk);
type reg_record is record
state				:	state_type;
takei				:	std_logic_vector(2 downto 0);
mloop				:	std_logic_vector(1 downto 0);
ploop				:	std_logic_vector(1 downto 0);
glos				:	std_logic_vector(17 downto 0);
glos_buf			:	std_logic_vector(17 downto 0);
kly_cnt			:	integer range 0 to 511;
kly_ch			:	std_logic;
kly_init			:	std_logic;
glos_clip		:	std_logic_vector(17 downto 0);
glos_acc			:	std_logic_vector(17 downto 0);
glos_out			:	std_logic_vector(17 downto 0);
kly_ch_done		:	std_logic;
end record reg_record;
signal d,q			:	reg_record;	
begin
process(clock, reset)
begin
	if(reset = '0') then
		q.state				<=	st_init;
		q.takei				<=	(others	=>	'0');
		q.mloop				<=	"00";
		q.ploop				<=	"00";
		q.glos_buf			<=	(others	=>	'0');
		q.glos				<=	(others	=>	'0');
		q.kly_ch				<=	'0';
		q.kly_init			<=	'0';
		q.glos_clip			<=	(others	=>	'0');
		q.glos_acc			<=	(others	=>	'0');
		q.glos_out			<=	(others	=>	'0');
		q.kly_ch_done		<=	'0';
	elsif(rising_edge(clock)) then
		if(strobe = '1') then
			q	<=	d;
		end if;
	end if;
end process;	
			
d.kly_ch			<=	kly_ch;
d.mloop			<=	mloop;			
d.ploop			<=	ploop;
d.glos_buf		<=	glos;
d.kly_ch			<=	kly_ch;
d.takei			<=	q.takei(1 downto 0)&takei;
d.kly_init		<= '1' when (q.mloop = "00" and q.ploop = "00" and q.glos_buf /= "00"& x"0000" and q.kly_ch = '1' and q.takei(2 downto 1) = "01") else '0';

process(q)
begin
	d.state		<=	q.state;
	d.kly_cnt	<=	q.kly_cnt;
	d.glos		<=	q.glos;
	d.glos_acc	<=	q.glos_acc;
	d.glos_out	<=	q.glos_out;
	d.kly_ch_done	<=	q.kly_ch_done;
	case q.state is
			when st_init		=>	
			d.kly_ch_done	<=	'0';
				if q.kly_init = '1' then
					d.glos	<=	q.glos_buf;
					d.state 	<=	state_kly;
				end if;
			when state_kly	=>	
				d.kly_cnt	<=	q.kly_cnt + 1;
				d.glos_out	<=	q.glos_clip;
				if q.kly_cnt = 92 then
					d.kly_cnt 	<= 0;	
					d.state		<=	state_chk;
				end if;											
			when state_chk	=>
				d.glos_acc	<=	std_logic_vector(unsigned(q.glos_acc) + 675);
				if q.glos_acc < q.glos then
					d.kly_cnt	<=	q.kly_cnt + 1;				
					d.state	<=	state_kly;
				else
					d.kly_ch_done	<=	'1';
					d.glos_acc	<=	(others	=>	'0');
					d.glos		<=	(others	=>	'0');
					d.glos_out	<=	(others	=>	'0');	
					d.state		<=	st_init;
				end if;							
		end case;
end process;
d.glos_clip		<=	q.glos when q.glos_acc > q.glos else q.glos_acc;
glos_out			<=	q.glos_out;
kly_ch_done		<=	q.kly_ch_done;

end architecture behavior;		