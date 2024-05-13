library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fccid_rw is
	port(clock	:	in std_logic;
			reset	:	in std_logic;
			epcsc	:	in std_logic_vector(3 downto 0);
			epcsa	:	in	std_logic_vector(31 downto 0);
			epcsb	:	in	std_logic;
			epcsc_out	:	out std_logic_vector(3 downto 0);
			epcsa_out	:	out std_logic_vector(31 downto 0);
			epcsr	:	in std_logic_vector(7 downto 0);
			fccid	:	out std_logic_vector(15 downto 0)
			);
end entity fccid_rw;
architecture behavior of fccid_rw is
type state_type is (st_init, st_go1, st_sync_clk, st_go0, st_busy, st_addr ,st_done);
type reg_record is record
clk_count	:	unsigned(5 downto 0);
epcsc_in		:	std_logic_vector(3 downto 0);
epcsa_in		:	std_logic_vector(31 downto 0);
epcsc			:	std_logic_vector(3 downto 0);
epcsa			:	std_logic_vector(31 downto 0);
epcsb			:	std_logic;
epcsr			:	std_logic_vector(7 downto 0);
fccid			:	std_logic_vector(15 downto 0);
state			:	state_type;
end record;
signal d,q	:	reg_record;	




begin
d.epcsc_in	<=	epcsc;
d.epcsa_in	<=	epcsa;
d.epcsb		<=	epcsb;
d.epcsr		<=	epcsr;


process(clock, reset)
begin
	if(reset = '0') then
		q.clk_count	<=	(others	=>	'0');
		q.epcsc_in	<=	(others	=>	'0');
		q.epcsa_in	<=	(others	=>	'0');
		q.epcsc		<=	"0010";
		q.epcsa		<=	x"00af0000";
		q.epcsb		<=	'1';
		q.epcsr		<=	(others	=>	'0');
		q.state		<=	st_init;
		q.fccid		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		q				<=	d;
	end if;
end process;

process(q)
begin
		d.state		<=	q.state;
		d.clk_count	<=	q.clk_count;
		d.epcsc		<=	q.epcsc;
		d.epcsa		<=	q.epcsa;
		d.fccid		<=	q.fccid;
		case q.state is
			when st_init	=>
				d.epcsa	<=	x"00af0000";
				d.epcsc	<=	"0010";
				d.state	<=	st_go1;
			when st_go1		=>
				d.epcsc	<=	"0011";
				d.state	<=	st_sync_clk;
			when st_sync_clk	=>
				d.clk_count	<=	q.clk_count + 1;
				if(q.clk_count = "111111") then
					d.state	<=	st_go0;
				end if;
			when st_go0	=>	
				d.epcsc	<=	"0010";
				d.state	<=	st_busy;
			when st_busy	=>	
				if (q.epcsb = '0') then
					d.state	<=	st_addr;
				end if;
			when st_addr	=>
				if q.epcsa = x"00af0000" then
					d.fccid(7 downto 0)	<=	q.epcsr;
					d.epcsa					<=	x"00af0001";
					d.epcsc					<=	"0010";
					d.state					<=	st_go1;
				else
					d.fccid(15 downto 8)	<=	q.epcsr;
					d.epcsc					<=	"0000";
					d.state					<=	st_done;
				end if;
			when st_done	=>	
				d.epcsc	<=	q.epcsc_in;
				d.epcsa	<=	q.epcsa_in;
		end case;
end process;

fccid			<=	q.fccid;
--epcsc_out	<=	q.epcsc_in(3 downto 2) & q.epcsc;
epcsc_out	<=	q.epcsc;
epcsa_out	<=	q.epcsa;

end architecture behavior;			