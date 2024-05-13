library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity dpram_adc_dac_clkdom_xing is
	port(reset_n			:	in	std_logic;
			rdclock			:	in	std_logic;
			wrclock			:	in	std_logic;
			i_in				:	in std_logic_vector(17 downto 0);
			q_in				:	in std_logic_vector(17 downto 0);
			
			
			
			i_out	:	out std_logic_vector(17 downto 0);
			q_out	:	out std_logic_vector(17 downto 0)
					
			);
end entity dpram_adc_dac_clkdom_xing;
architecture behavior of dpram_adc_dac_clkdom_xing is


type reg_record is record
addr		:	integer range 0 to 255;
wraddr		:	std_logic_vector(7 downto 0);
data		:	std_logic_vector(17 downto 0);
i_in		:	std_logic_vector(17 downto 0);
q_in		:	std_logic_vector(17 downto 0);
end record reg_record;
signal rdaddr		:	std_logic_vector(7 downto 0);
signal d,q			:	reg_record;
type reg_record_dr is record
addr		:	integer range 0 to 255;
data		:	std_logic_vector(17 downto 0);
rdaddr		:	std_logic_vector(7 downto 0);
i_out		:	std_logic_vector(17 downto 0);
q_out		:	std_logic_vector(17 downto 0);
end record reg_record_dr;
signal dr,qr			:	reg_record_dr;
signal acq_cnt_q		:	unsigned(1 downto 0);
signal acq_cnt_d		:	unsigned(1 downto 0);

begin

process(wrclock, reset_n)
begin
	if(reset_n = '0') then
		q.addr		<=	0;
		q.wraddr	<=	(others	=>	'0');
		q.data		<=	(others	=>	'0');
		q.i_in	<=	(others	=>	'0');
		q.q_in	<=	(others	=>	'0');		
	elsif(rising_edge(wrclock)) then
		q			<=	d;
	end if;
end process;

d.i_in		<=	i_in;
d.q_in		<=	q_in;

d.addr		<=	0 when q.addr = 7 else (q.addr + 1);

with q.addr select

d.data			<=	q.i_in when 0 | 2 | 4 |6,
					q.q_in when 1 | 3 | 5 |7,					
					(others	=>	'0') when others;

process(rdclock, reset_n)
begin
	if(reset_n = '0') then		
		qr.addr		<=	4;
		qr.data		<=	(others	=>	'0');
		qr.rdaddr	<=	(others	=>	'0');
		acq_cnt_q	<=	(others	=>	'0');
		qr.i_out	<=	(others	=>	'0');
		qr.q_out	<=	(others	=>	'0');				
	elsif(rising_edge(rdclock)) then
		acq_cnt_q	<=	acq_cnt_d;
		if(acq_cnt_q(0) = '0') then
			qr			<=	dr;
		end if;	
	end if;
end process;	

d.wraddr	<=	std_logic_vector(to_unsigned(q.addr,8));
rdaddr	<=	std_logic_vector(to_unsigned(qr.addr,8));

acq_cnt_d	<=	acq_cnt_q + 1;

dr.rdaddr	<=	std_logic_vector(to_unsigned(qr.addr,8));
dr.addr		<=	0 when qr.addr = 7 else qr.addr + 1;

dpram_mem_gen_i: entity work.dpram_gen
	generic map(n	=>	8,
					w	=>	18)				
	port map(wr_clock	=>	wrclock,
				rd_clock	=>	rdclock,
				wr_addr	=>	q.wraddr,
				rd_addr	=>	rdaddr,
				data_in	=>	q.data,
				we			=>	'1',
				data_out	=>	dr.data
				);
				
dr.i_out					<=	qr.data when qr.rdaddr(0) = '0' else qr.i_out;
dr.q_out					<=	qr.data when qr.rdaddr(0) = '1' else qr.q_out;

i_out		<=	qr.i_out;
q_out		<=	qr.q_out;

end architecture behavior;			
						