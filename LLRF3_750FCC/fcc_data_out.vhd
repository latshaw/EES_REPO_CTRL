library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fcc_data_out is

port(reset : in std_logic;
	  clock : in std_logic;
	  
	  data_out : in std_logic_vector(39 downto 0);
	  
	  fiber_data_out : out std_logic;
	  start_crc : out std_logic
	  );
	  
end entity fcc_data_out;

architecture behavior of fcc_data_out is

signal fiber_data_out_buffer 	: std_logic_vector(39 downto 0);
signal en_fiber_data_out		: std_logic;
signal ld_fiber_data_out		: std_logic;
signal fiber_data_out_tmp		: std_logic;
signal fiber_data_out_d			:	std_logic_vector(39 downto 0);
signal fiber_data_out_q			:	std_logic_vector(39 downto 0);

signal en_clk_count				: std_logic;
signal clk_count					: std_logic_vector(4 downto 0);
signal clk_count_d				: std_logic_vector(4 downto 0);

signal en_bit_count				: std_logic;
signal clr_bit_count				: std_logic;
signal bit_count					: std_logic_vector(7 downto 0);
signal bit_count_d					: std_logic_vector(7 downto 0);

signal start_crc_tmp				: std_logic;


signal clr_fiber_data_out		: std_logic;

type state_type is (init, load, start_tx, tx_data, wait_state);
signal state						: state_type;

begin

process(clock, reset)
begin
	if(reset = '0') then
		start_crc			<=	'0';
		fiber_data_out		<=	'0';
		clk_count			<=	(others	=>	'0');
		bit_count			<=	(others	=>	'0');
		fiber_data_out_q	<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		start_crc			<=	start_crc_tmp;
		fiber_data_out		<=	fiber_data_out_tmp;
		clk_count			<=	clk_count_d;
		bit_count			<=	bit_count_d;
		fiber_data_out_q	<=	fiber_data_out_d;
	end if;
end process;	



clk_count_d		<=	"00000" when en_clk_count = '1' and clk_count = "11000" else
						std_logic_vector(unsigned(clk_count)+1) when en_clk_count = '1' else
						clk_count;		
bit_count_d			<=	(others	=>	'0') when clr_bit_count = '0' else
							std_logic_vector(unsigned(bit_count) + 1) when en_bit_count = '1' else
							bit_count;
fiber_data_out_d		<=	(others	=>	'0') when clr_fiber_data_out = '0' else
								data_out when ld_fiber_data_out = '1' else
								fiber_data_out_q(38 downto 0)&'0' when en_fiber_data_out = '1' else
								fiber_data_out_q;
fiber_data_out_tmp	<=	fiber_data_out_q(39);								
										  
	process(clock, reset)
	begin
		if(reset = '0') then
			state <= init;
		elsif(clock = '1' and clock'event) then
			
			case state is
			
				when init			=> state <= load;
				
				when load			=> state <= start_tx;
				
				when start_tx		=> if(clk_count = "11000") then state <= tx_data;
											else state <= start_tx;
											end if;
				
				when tx_data		=> if(bit_count = "00100111" and clk_count = "11000") then state <= wait_state;
											else state <= tx_data;
											end if;
										
				when wait_state	=> if(bit_count = "11101110") then state <= load;
											else state <= wait_state;
											end if;
											
				when others			=> state <= init;
										
			end case;

		end if;			
	end process;
	
start_crc_tmp			<= '1' when state = load else '0';
	
en_clk_count			<= '1' when state = start_tx or state = tx_data else '0';

en_bit_count			<= '1' when state = wait_state or ((state = start_tx or state = tx_data) and (clk_count = "11000")) else '0';
clr_bit_count			<= '0' when state = load else '1';

en_fiber_data_out 	<= '1' when  (state = start_tx or state = tx_data) and (clk_count = "11000") else '0';
ld_fiber_data_out		<= '1' when (state = load) else '0';
clr_fiber_data_out	<= '0' when (state = tx_data and bit_count = "00100111" and clk_count = "11000" ) else '1';


end architecture behavior;

--library ieee;
--use ieee.std_logic_1164.all;
--use ieee.numeric_std.all;
--
--entity fcc_data_out is
--
--port(reset : in std_logic;
--	  clock : in std_logic;
--	  
--	  data_out : in std_logic_vector(39 downto 0);
--	  
--	  fiber_data_out : out std_logic;
--	  start_crc : out std_logic
--	  );
--	  
--end entity fcc_data_out;
--
--architecture behavior of fcc_data_out is
--
--signal fiber_data_out_buffer 	: std_logic_vector(39 downto 0);
--signal en_fiber_data_out		: std_logic;
--signal ld_fiber_data_out		: std_logic;
--signal fiber_data_out_tmp		: std_logic;
--signal fiber_data_out_d			:	std_logic_vector(39 downto 0);
--signal fiber_data_out_q			:	std_logic_vector(39 downto 0);
--
--signal en_clk_count				: std_logic;
--signal clk_count					: std_logic_vector(2 downto 0);
--signal clk_count_d				: std_logic_vector(2 downto 0);
--
--signal en_bit_count				: std_logic;
--signal clr_bit_count				: std_logic;
--signal bit_count					: std_logic_vector(6 downto 0);
--signal bit_count_d					: std_logic_vector(6 downto 0);
--
--signal start_crc_tmp				: std_logic;
--
--
--signal clr_fiber_data_out		: std_logic;
--
--type state_type is (init, load, start_tx, tx_data, wait_state);
--signal state						: state_type;
--
--begin
--
--process(clock, reset)
--begin
--	if(reset = '0') then
--		start_crc			<=	'0';
--		fiber_data_out		<=	'0';
--		clk_count			<=	(others	=>	'0');
--		bit_count			<=	(others	=>	'0');
--		fiber_data_out_q	<=	(others	=>	'0');
--	elsif(rising_edge(clock)) then
--		start_crc			<=	start_crc_tmp;
--		fiber_data_out		<=	fiber_data_out_tmp;
--		clk_count			<=	clk_count_d;
--		bit_count			<=	bit_count_d;
--		fiber_data_out_q	<=	fiber_data_out_d;
--	end if;
--end process;	
--
--
----------------------start crc flip flop-------------------
--
--
----start_crc_ff: entity work.latch_n 
----	port map(clock	=> clock, 
----				reset => reset,
----				clear => '1', 
----				en 	=> '1',
----				inp 	=> start_crc_tmp,
----				oup	=> start_crc 
----				);
--
--
--
--	------clock counter------------------------
--	
----	clk_counter: entity work.counter
----		generic map(n => 3)
----		port map(clock		=> clock,
----					reset		=> reset,
----					clear  	=> '1',
----					enable	=> en_clk_count,
----					count		=> clk_count
----					);
--	------end of clock counter------------------------
--clk_count_d		<=	std_logic_vector(unsigned(clk_count)+1) when en_clk_count = '1' else clk_count;		
--	
--	------bit counter------------------------
--	
----	bit_counter: entity work.counter
----		generic map(n => 7)
----		port map(clock		=> clock,
----					reset		=> reset,
----					clear  	=> clr_bit_count,
----					enable	=> en_bit_count,
----					count		=> bit_count
----					);
--	------end of bit counter------------------------
--bit_count_d			<=	(others	=>	'0') when clr_bit_count = '0' else
--							std_logic_vector(unsigned(bit_count) + 1) when en_bit_count = '1' else
--							bit_count;
--
--
----	
----	fiber_data_out_reg: entity work.shift_left_reg
----	generic map(n => 40)
----	port map(clock	=> clock,
----		 reset 	=> reset,
----		 en 		=> en_fiber_data_out,
----		 clear	=> clr_fiber_data_out,
----		 load		=> ld_fiber_data_out, 
----		 inp		=> data_out, 
----		 output	=> fiber_data_out_tmp
----		 );
--		 
--fiber_data_out_d		<=	(others	=>	'0') when clr_fiber_data_out = '0' else
--								data_out when ld_fiber_data_out = '1' else
--								fiber_data_out_q(38 downto 0)&'0' when en_fiber_data_out = '1' else
--								fiber_data_out_q;
--fiber_data_out_tmp	<=	fiber_data_out_q(39);								
--		 
--		 
---------fiber data out flip flop------------		 
----	fiber_data_out_ff: entity work.latch_n
----	port map(clock	=> clock,	 
----				reset	=> reset, 
----				clear	=> '1', 
----				en		=> '1', 
----				inp	=> fiber_data_out_tmp, 
----				oup	=> fiber_data_out 
----				);
--
--   --------end of fiber data out register---------------
--												  
--
--												  
--												  
--	process(clock, reset)
--	begin
--		if(reset = '0') then
--			state <= init;
--		elsif(clock = '1' and clock'event) then
--			
--			case state is
--			
--				when init			=> state <= load;
--				
--				when load			=> state <= start_tx;
--				
--				when start_tx		=> if(clk_count = "111") then state <= tx_data;
--											else state <= start_tx;
--											end if;
--				
--				when tx_data		=> if(bit_count = "0100111" and clk_count = "111") then state <= wait_state;
--											else state <= tx_data;
--											end if;
--										
--				when wait_state	=> if(bit_count = "1101111") then state <= load;
--											else state <= wait_state;
--											end if;
--											
--				when others			=> state <= init;
--										
--			end case;
--
--		end if;			
--	end process;
--	
--start_crc_tmp			<= '1' when state = load else '0';
--	
--en_clk_count			<= '1' when state = start_tx or state = tx_data else '0';
--
--en_bit_count			<= '1' when state = wait_state or ((state = start_tx or state = tx_data) and (clk_count = "111")) else '0';
--clr_bit_count			<= '0' when state = load else '1';
--
--en_fiber_data_out 	<= '1' when  (state = start_tx or state = tx_data) and (clk_count = "111") else '0';
--ld_fiber_data_out		<= '1' when (state = load) else '0';
--clr_fiber_data_out	<= '0' when (state = tx_data and bit_count = "0100111" and clk_count = "111" ) else '1';
--
--
--end architecture behavior;

