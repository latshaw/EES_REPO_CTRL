------this block generates the trigger signal for acquiring the waveforms
------if not in pulse mode epics_takei will be the cirbuftake signal
------if in pulse mode, after takei rising edge wait for the rising edge of pulse_out to initiate the data acquisition	

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cirbufs_takei is
	port(clock		:	in	std_logic;
		reset		:	in	std_logic;
		epics_takei	:	in	std_logic;
		pulse_out	:	in	std_logic;
		maglp		:	in	std_logic_vector(1 downto 0);
		cirbuftake	:	out std_logic
		);
end entity cirbufs_takei;

architecture behavior of cirbufs_takei is

type reg_record is record
maglp			:	integer range 0 to 3;
takei			:	std_logic_vector(1 downto 0);
takei_rising	:	std_logic;


pulse			:	std_logic_vector(1 downto 0);
pulse_rising		:	std_logic;


cirbuf_pulse	:	std_logic;
cirbuftake		:	std_logic;
end record reg_record;
signal d,q		:	reg_record;
begin

d.maglp			<=	to_integer(unsigned(maglp));
d.takei			<=	q.takei(0)&epics_takei;

d.takei_rising	<=	not q.takei(1) and q.takei(0);					


d.pulse			<=	q.pulse(0)&pulse_out;
d.pulse_rising	<=	not q.pulse(1) and q.pulse(0);


d.cirbuf_pulse	<=	'0' when q.takei_rising = '1' else
						'1' when q.pulse_rising = '1' else
						q.cirbuf_pulse;

d.cirbuftake	<=	q.cirbuf_pulse when q.maglp = 3 else q.takei(0);

	
cirbuftake		<=	q.cirbuftake;
	
process(clock, reset)
begin
	if(reset = '0') then
		q.maglp			<=	0;
		q.takei			<=	(others	=>	'0');
		q.takei_rising	<=	'0';
		
		q.pulse			<=	(others	=>	'0');
		q.pulse_rising	<=	'0';
		q.cirbuf_pulse	<=	'0';
		q.cirbuftake	<=	'0';
	elsif(rising_edge(clock)) then
		q				<=	d;
	end if;
end process;	

	
end architecture behavior;	