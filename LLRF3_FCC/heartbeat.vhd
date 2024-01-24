library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use work.components.all;

entity heartbeat is

port(clock	: in std_logic;
	  reset	: in std_logic;
	  	  
	  hb_dig	: out std_logic;
	  hb_ioc	: out std_logic
	  );
	  
end entity heartbeat;

architecture behavior of heartbeat is

type state_type is (s0, s1, s2, s3, s4, s5, s6, s7);
signal y						: state_type;

signal en_hb_count						: std_logic;
signal clr_hb_count						: std_logic;
signal hb_count_d, hb_count			: std_logic_vector(25 downto 0);


begin
process(clock, reset)
begin
	if(reset = '0') then
		hb_count	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		hb_count	<=	hb_count_d;
	end if;
end process;
hb_count_d	<=	(others	=>	'0') when clr_hb_count = '0' else
					std_logic_vector(unsigned(hb_count) + 1) when en_hb_count = '1' else
					hb_count;				



process(clock, reset)
begin
	if reset = '0' then y <= s0;
	elsif (clock = '1' and clock'event) then
		case y is
		
			when s0	=>	if hb_count	= "00" & x"6ddcfd" then y <= s1;
							else y <= s0;
							end if;
							
			when s1	=> if hb_count = "00" & x"57e3fd" then y <= s2;
							else y <= s1;
							end if;
							
			when s2	=>	if hb_count = "00" & x"57e3fd" then y <= s3;
							else y <= s2;
							end if;
							
			when s3	=> if hb_count = "10" & x"5142fd" then y <= s4;
							else y <= s3;
							end if;
							
			when s4	=>	if hb_count	= "00" & x"6ddcfd" then y <= s5;
							else y <= s4;
							end if;
							
			when s5	=> if hb_count = "00" & x"57e3fd" then y <= s6;
							else y <= s5;
							end if;
							
			when s6	=>	if hb_count = "00" & x"57e3fd" then y <= s7;
							else y <= s6;
							end if;
							
			when s7	=> if hb_count = "10" & x"5142fd" then y <= s0;
							else y <= s7;
							end if;
							
			when others	=> y <= s0;
			
		end case;
		
	end if;
end process;
	

clr_hb_count 	<= '0' when ((y = s0 or y = s4) and hb_count = "00" & x"6ddcfd")	or ((y = s1 or y = s2 or y = s5 or y = s6) and hb_count = "00" & x"7d8ed7") or 
									((y = s3 or y = s7) and hb_count = "10" & x"5142fd") else '1';			

en_hb_count 	<= '1' when ((y = s0 or y = s4) and hb_count /= "00" & x"6ddcfd")	or ((y = s1 or y = s2 or y = s5 or y = s6) and hb_count /= "00" & x"7d8ed7") or 
									((y = s3 or y = s7) and hb_count /= "10" & x"5142fd") else '0';
	

		


hb_dig			<= '1' when y = s0 or y = s2 else '0';
hb_ioc			<= '1' when y = s4 or y = s6 else '0';

--hb_ioc			<= hrt_ioc and isa_oe_buf2;
									

end architecture behavior;
