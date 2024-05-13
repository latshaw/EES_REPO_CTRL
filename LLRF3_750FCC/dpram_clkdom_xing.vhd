library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;
 
entity dpram_clkdom_xing is
	port(reset_n			:	in	std_logic;
			rdclock			:	in	std_logic;
			wrclock			:	in	std_logic;
			deta_stp_in		:	in std_logic_vector(15 downto 0);
			deta_disc_stp_in	:	in std_logic_vector(2 downto 0);
			disc_stp_in		:	in std_logic_vector(27 downto 0);
			stpena_in		:	in std_logic;
			beam_fsd_in		:	in std_logic;
			gmesstat_in		:	in std_logic;
			ratn_in			:	in std_logic_vector(5 downto 0);
			deta_stp_out	:	out std_logic_vector(15 downto 0);
			deta_disc_stp_out	:	out std_logic_vector(2 downto 0);
			disc_stp_out	:	out std_logic_vector(27 downto 0);
			stpena_out		:	out std_logic;
			beam_fsd_out	:	out std_logic;
			gmesstat_out	:	out std_logic;
			ratn_out			:	out std_logic_vector(5 downto 0)			
			);
end entity dpram_clkdom_xing;
architecture behavior of dpram_clkdom_xing is
 
type state_type is (st_init, st_load_addr, st_load_data, st_wen); 
type reg_record is record
data_in	:	std_logic_vector(17 downto 0);
state		:	state_type;
addr		:	integer range 0 to 255;
data		:	std_logic_vector(17 downto 0);
we			:	std_logic;
dly_cnt		:	unsigned(2 downto 0);
 
deta_stp	:	std_logic_vector(15 downto 0);
deta_disc_stp	:	std_logic_vector(2 downto 0);
disc_stp	:	std_logic_vector(27 downto 0);
stpena		:	std_logic;
beam_fsd	:	std_logic;
gmesstat	:	std_logic;
ratn		:	std_logic_vector(5 downto 0);
end record reg_record;
signal wraddr		:	std_logic_vector(7 downto 0);
signal rdaddr		:	std_logic_vector(7 downto 0);
signal d,q			:	reg_record;
 
 
type state_type_dr is (st_init, st_wait_data, st_chk_addr); 
type reg_record_dr is record
state		:	state_type_dr;
addr		:	integer range 0 to 255;
data		:	std_logic_vector(17 downto 0);
re			:	std_logic;
dly_cnt		:	unsigned(2 downto 0);
 
deta_stp	:	std_logic_vector(15 downto 0);
deta_disc_stp	:	std_logic_vector(2 downto 0);
disc_stp	:	std_logic_vector(27 downto 0);
disc_stp_out	:	std_logic_vector(27 downto 0);
stpena		:	std_logic;
beam_fsd	:	std_logic;
gmesstat	:	std_logic;
ratn		:	std_logic_vector(5 downto 0);
end record reg_record_dr;
signal dr,qr			:	reg_record_dr;
 
begin
 
process(wrclock, reset_n)
begin
	if(reset_n = '0') then
		q.data_in	<=	(Others	=>	'0');
		q.state		<=	st_init;
		q.addr		<=	0;
		q.data		<=	(others	=>	'0');
		q.we		<=	'0';
		q.dly_cnt	<=	"000";
		q.deta_stp	<=	(others	=>	'0');
		q.deta_disc_stp	<=	(others	=>	'0');
		q.disc_stp	<=	(others	=>	'0');
		q.stpena	<=	'0';
		q.beam_fsd	<=	'0';
		q.gmesstat	<=	'0';
		q.ratn		<=	(others	=>	'0');
	elsif(rising_edge(wrclock)) then
		q			<=	d;
	end if;
end process;
 
 
d.deta_stp		 <=	deta_stp_in;
d.deta_disc_stp <=	deta_disc_stp_in;
d.disc_stp		 <=	disc_stp_in;
d.stpena	   	 <=	stpena_in;
d.beam_fsd		 <=	beam_fsd_in;
d.gmesstat		 <=	gmesstat_in;
d.ratn			 <=	ratn_in;
 
 
with q.addr select
 
d.data_in	<=	q.disc_stp(17 downto 0) when 1,
					x"00"&q.disc_stp(27 downto 18) when 2,
					"00"&x"0"&q.deta_disc_stp&q.stpena&q.beam_fsd&q.gmesstat&q.ratn when 3,
					"00"&q.deta_stp when others;
 
process(q)
begin
	d.state		<=	q.state;
	d.dly_cnt	<=	q.dly_cnt;
	d.addr		<=	q.addr;
	d.data		<=	q.data;
	d.we		   <=	q.we;
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
			if(q.addr = 3) then
				d.addr	<=	0;
			else	
				d.addr	<=	q.addr + 1;
			end if;	
			d.state	<=	st_load_data;	
	end case;
end process;	

 
 
process(rdclock, reset_n)
begin
	if(reset_n = '0') then		
		qr.state		<=	st_init;
		qr.addr		<=	0;
		qr.data		<=	(others	=>	'0');
		qr.re		<=	'0';
		qr.dly_cnt	<=	(others	=>	'0');
		qr.deta_stp	<=	(others	=>	'0');
		qr.deta_disc_stp	<=	(others	=>	'0');
		qr.disc_stp	<=	(others	=>	'0');
		qr.disc_stp_out	<=	(others	=>	'0');
		qr.stpena	<=	'0';
		qr.beam_fsd	<=	'0';
		qr.gmesstat	<=	'0';
		qr.ratn		<=	(others	=>	'0');		
	elsif(rising_edge(rdclock)) then
		qr			<=	dr;
	end if;
end process;	
 
wraddr	<=	std_logic_vector(to_unsigned(q.addr,8));
rdaddr	<=	std_logic_vector(to_unsigned(qr.addr,8));
 
 
----------------------------reading the data from the dual port ram--------------------------
 
process(qr)
begin
	dr.state	<=	qr.state;
	dr.dly_cnt	<=	qr.dly_cnt;
	dr.addr		<=	qr.addr;
	dr.re		<=	qr.re;
	case qr.state is
		when st_init	=>
			dr.state	<=	st_wait_data;
			dr.re		<=	'0';
		when st_wait_data	=>	
			dr.dly_cnt	<=	qr.dly_cnt + 1;
			dr.addr		<=	qr.addr;			
			if (qr.dly_cnt = "111") then
				dr.re		<=	'1';
				dr.state		<=	st_chk_addr;
			end if;		
		when st_chk_addr	=>
			dr.re		<=	'0';
			if(qr.addr = 3) then
				dr.addr	<=	0;
			else	
				dr.addr	<=	qr.addr + 1;
			end if;	
			dr.state	<=	st_wait_data;	
	end case;
end process;	
 
 
 
 
 
dpram_mem_gen_i: entity work.dpram_gen
	generic map(n	=>	8,
					w	=>	18)				
	port map(wr_clock	=>	wrclock,
				rd_clock	=>	rdclock,
				wr_addr	=>	wraddr,
				rd_addr	=>	rdaddr,
				data_in	=>	q.data,
				we			=>	q.we,
				data_out	=>	dr.data
				);
dr.deta_stp					   <=	qr.data(15 downto 0) when qr.addr = 0 and qr.re = '1' else qr.deta_stp;
dr.disc_stp(17 downto 0)	<=	qr.data when qr.addr = 1 and qr.re = '1' else qr.disc_stp(17 downto 0);
dr.disc_stp(27 downto 18)	<=	qr.data(9 downto 0) when qr.addr = 2 and qr.re = '1' else qr.disc_stp(27 downto 18);
dr.disc_stp_out				<=	qr.disc_stp when qr.addr = 3 else qr.disc_stp_out;
dr.deta_disc_stp			   <=	qr.data(11 downto 9) when qr.addr = 3 and qr.re = '1' else qr.deta_disc_stp; 		
dr.stpena					   <=	qr.data(8) when qr.addr = 3 and qr.re = '1' else qr.stpena;
dr.beam_fsd					   <=	qr.data(7) when qr.addr = 3 and qr.re = '1' else qr.beam_fsd;
dr.gmesstat					   <=	qr.data(6) when qr.addr = 3 and qr.re = '1' else qr.gmesstat;
dr.ratn						   <=	qr.data(5 downto 0) when qr.addr = 3 and qr.re = '1' else qr.ratn;
 
deta_stp_out		<=	qr.deta_stp;
deta_disc_stp_out	<=	qr.deta_disc_stp;
disc_stp_out		<=	qr.disc_stp_out;
stpena_out			<=	qr.stpena;
beam_fsd_out		<=	qr.beam_fsd;
gmesstat_out		<=	qr.gmesstat;
ratn_out			   <=	qr.ratn;					
 
 
end architecture behavior;