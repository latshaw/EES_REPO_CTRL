

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;


entity heartbeat is
	port (	 
				reset_n				:in std_logic;
				clock					:in std_logic;
				
				-- inputs
				ioc_ok 				:in std_logic;
				
				-- outputs
				fpga_hrtb			:out std_logic;
				ioc_hrtb				:out std_logic
		 );
end heartbeat;


architecture rtl of heartbeat is

type statetype is (s0, s1, s2, s3);

signal state	     :statetype;
signal alt :std_logic;


begin

process(clock, reset_n)
variable count	:std_logic_vector(28 downto 0);
begin
		if ( reset_n = '0' ) then
			state <= s0;
			alt <= '0';
		elsif rising_edge(clock) then
			case state is
				when s0 		=>	if ( count < 10000000 ) then --9599996
										count := count + 1;
										state <= s0;
									else
										count := (others => '0');
										state <= s1;
									end if;
				when s1   	=>	if ( count < 8000000 ) then --7679996
										count := count + 1;
										state <= s1;
									else
										count := (others => '0');
										state <= s2;
									end if;
				when s2	  	=>	if ( count < 8000000 ) then --7679996
										count := count + 1;
										state <= s2;
									else
										count := (others => '0');
										state <= s3;
									end if;
				when s3		=>	if ( count < 50000000 ) then --51839996
										count := count + 1;
										state <= s3;
									else
										count := (others => '0');
										state <= s0;
										alt <= not alt;
									end if;
			end case;			
		end if;
end process;

fpga_hrtb <= '0' when (state = s1 or state = s3) or alt = '0' else '1';
ioc_hrtb <= '0' when (state = s1 or state = s3 or ioc_ok = '0') or alt = '1' else '1';
	
end rtl;
