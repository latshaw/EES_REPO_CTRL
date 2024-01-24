library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity dpram_rdreg is
	port(reset_n	:	in	std_logic;
			rdclock	:	in	std_logic;
			wrclock	:	in	std_logic;
			data_in	:	in	std_logic_vector(17 downto 0);
			addr_in	:	in	std_logic_vector(7 downto 0);
			addr_out	:	out std_logic_vector(7 downto 0);
			data_out	:	out std_logic_vector(17 downto 0)
			);
end entity dpram_rdreg;
architecture behavior of dpram_rdreg is

type state_type is (st_init, st_load_addr, st_load_data, st_wen); 
type reg_record is record
data_in	:	std_logic_vector(17 downto 0);
state		:	state_type;
addr		:	unsigned(7 downto 0);
data		:	std_logic_vector(17 downto 0);
we			:	std_logic;
dly_cnt	:	unsigned(2 downto 0);
end record reg_record;
signal wraddr		:	std_logic_vector(7 downto 0);
signal rdaddr		:	std_logic_vector(7 downto 0);
signal d,q			:	reg_record;

begin

process(wrclock, reset_n)
begin
	if(reset_n = '0') then
		q.data_in	<=	(Others	=>	'0');
		q.state		<=	st_init;
		q.addr		<=	(others	=>	'0');
		q.data		<=	(others	=>	'0');
		q.we			<=	'0';
		q.dly_cnt	<=	"000";
	elsif(rising_edge(wrclock)) then
		q				<=	d;
	end if;
end process;

d.data_in	<=	data_in;

process(q)
begin
	d.state		<=	q.state;
	d.dly_cnt	<=	q.dly_cnt;
	d.addr		<=	q.addr;
	d.data		<=	q.data;
	d.we			<=	q.we;
	case q.state is
		when st_init	=>
			d.state	<=	st_load_data;
		when st_load_data	=>	
			d.dly_cnt	<=	q.dly_cnt + 1;
			d.addr		<=	q.addr;
			if (q.dly_cnt = "111") then
				d.data		<=	q.data_in;
				d.state		<=	st_wen;
			end if;
		when st_wen	=>
			d.we		<=	'1';
			d.state	<=	st_load_addr;
		when st_load_addr	=>
			d.we		<=	'0';
			d.addr	<=	q.addr + 1;
			d.state	<=	st_load_data;	
	end case;
end process;	
			
addr_out	<=	std_logic_vector(q.addr);

process(rdclock)
begin
	if(rising_edge(rdclock)) then
		rdaddr	<=	addr_in;
	end if;
end process;	

wraddr	<=std_logic_vector(q.addr);

dpram_mem_gen_i: entity work.dpram_gen
	generic map(n	=>	8,
					w	=>	18)				
	port map(wr_clock	=>	wrclock,
				rd_clock	=>	rdclock,
				wr_addr	=>	wraddr,
				rd_addr	=>	rdaddr,
				data_in	=>	q.data,
				we			=>	q.we,
				data_out	=>	data_out
				);



end architecture behavior;			
			