-- 4/12/24, fixes write overload

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dpram_wrreg is
	port(reset_n	:	in	std_logic;
			rdclock	:	in	std_logic;
			wrclock	:	in	std_logic;
			data_in	:	in	std_logic_vector(17 downto 0);
			addr_in	:	in	std_logic_vector(23 downto 0);
			lb_valid	:	in	std_logic;
			lb_rnw	:	in	std_logic;
			wrreg		:	out std_logic;
			addr_out	:	out std_logic_vector(6 downto 0);
			data_out	:	out std_logic_vector(17 downto 0)
			);
end entity dpram_wrreg;
architecture behavior of dpram_wrreg is

type state_type is (st_mem_init0, st_mem_init1, st_wrinit, st_wen, st_wrdone_wait, st_wrdone_wden); 
type reg_record is record
data_in		:	std_logic_vector(17 downto 0);
addr_in		:	std_logic_vector(6 downto 0);
state		:	state_type;
addr		:	std_logic_vector(6 downto 0);
data		:	std_logic_vector(25 downto 0);
data_rdy	:	std_logic;
we			:	std_logic;
lb_wrvalid	:	std_logic;
dly_cnt	:	integer range 0 to 3;
mem_cnt		:	integer range 0 to 2**7-1;
end record reg_record;



signal d,q			:	reg_record;
	


type cdc_record is record
rdstart				:	std_logic_vector(1 downto 0);

rdaddr				:	std_logic_vector(6 downto 0);
wrreg				:	std_logic;	
data_valid			:	std_logic;
addr_out				:	std_logic_vector(6 downto 0);

data_out			:	std_logic_vector(17 downto 0);

end record cdc_record;
signal dc, qc		:	cdc_record;
signal dpram_dout	:	std_logic_vector(25 downto 0);



begin

d.lb_wrvalid	<=	'1' when lb_valid = '1' and lb_rnw = '0' and addr_in(23 downto 7) = x"0000" & '1' else '0';

process(wrclock, reset_n)
begin
	if(reset_n = '0') then
		q.addr_in	<=	(others	=>	'0');
		q.data_in	<=	(Others	=>	'0');
		q.state		<=	st_mem_init0;
		q.addr		<=	(others	=>	'0');
		q.data		<=	(others	=>	'0');
		q.lb_wrvalid	<=	'0';
		q.we			<=	'0';
		q.dly_cnt	<=	0;
		q.mem_cnt	<=	0;
	elsif(rising_edge(wrclock)) then
		q				<=	d;
	end if;
end process;

d.data_in	<=	data_in;
d.addr_in	<=	addr_in(6 downto 0);

process(q)
begin
	d.state		<=	q.state;
	d.dly_cnt	<=	q.dly_cnt;
	d.addr		<=	q.addr;
	d.data		<=	q.data;
	d.we			<=	q.we;
	d.mem_cnt	<=	q.mem_cnt;
	case q.state is
		when st_mem_init0	=>	
			d.we	<=	'1';
			d.state	<=	st_mem_init1;
		when st_mem_init1	=>
				d.we	<=	'0';
			if q.mem_cnt = 2**7-1 then
				d.state	<=	st_wrinit;
			else
				d.mem_cnt 	<= q.mem_cnt + 1;
				d.data		<=	std_logic_vector(unsigned(q.data) + 1);
				d.addr		<=	std_logic_vector(unsigned(q.addr) + 1);
				d.mem_cnt	<=	q.mem_cnt + 1;
				d.state		<=	st_mem_init0;
			end if;	
			
		when st_wrinit	=>
		d.we		<=	'0';
--		d.data_rdy	<=	'0';
			if(q.lb_wrvalid	=	'1') then				
				d.addr	<=	"000"&x"0";
				d.data	<=	'1'&q.addr_in&q.data_in;			
				d.state	<=	st_wen;
			end if;
		when st_wen	=>
			d.we		<=	'1';
			d.state	<=	st_wrdone_wait;
		when st_wrdone_wait	=>
		d.we		<=	'0';
			if(q.dly_cnt = 2) then
				d.dly_cnt <= 0;
				d.state		<=	st_wrdone_wden;
				d.data	<=	'0'&q.addr_in&q.data_in;
			else
				d.dly_cnt	<=	q.dly_cnt + 1;
			end if;
		when st_wrdone_wden	=>
			d.we		<=	'1';
			d.state		<=	st_wrinit;
		when others		=>
			d.state	<=	st_wrinit;	
	end case;
end process;	
			

dpram_mem_gen_i: entity work.dpram_gen
	generic map(n	=>	7,
				w	=>	26)				
	port map(wr_clock	=>	wrclock,
				rd_clock	=>	rdclock,
				wr_addr		=>	q.addr,
				rd_addr		=>	qc.rdaddr,
				data_in		=>	q.data,
				we			=>	q.we,
				data_out	=>	dpram_dout
				);

data_out		<=	qc.data_out;
dc.rdstart	<=	qc.rdstart(0)&dpram_dout(25);
dc.data_valid	<=	not qc.rdstart(1) and qc.rdstart(0);
dc.wrreg		<=	qc.data_valid;	

dc.addr_out	<=	dpram_dout(24 downto 18) when dc.data_valid = '1' else qc.addr_out;
dc.data_out	<=	dpram_dout(17 downto 0) when dc.data_valid = '1' else qc.data_out;

dc.rdaddr		<=	(others	=>	'0');

process(rdclock, reset_n)
begin
	if(reset_n = '0') then
		qc.rdstart	<=	"00";
		qc.wrreg	<=	'0';
		qc.data_valid	<=	'0';
		qc.addr_out	<=	(others	=>	'0');
		qc.data_out	<=	(others	=>	'0');
		qc.rdaddr		<=	(others	=>	'0');
	elsif(rising_edge(rdclock)) then
		qc				<=	dc;
	end if;
end process;

--dc.wen_addr	<=	dpram_dout(7 downto 0);
data_out	<=	qc.data_out;
addr_out	<=	qc.addr_out;
wrreg		<=	qc.wrreg;

end architecture behavior;			