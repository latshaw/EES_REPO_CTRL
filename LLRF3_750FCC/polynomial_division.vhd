library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity polynomial_division is
port(clock : in std_logic;
	  reset : in std_logic;
	  start_crc : in std_logic;
	  data_in : in std_logic_vector(31 downto 0);
--	  denom : in std_logic_vector(8 downto 0);-----x^8+x^2+x+1 ("100000111")
	  crc : out std_logic_vector(7 downto 0);
	  data_out_crc : out std_logic_vector(39 downto 0);
	  crc_done : out std_logic
	  );
end entity polynomial_division;

architecture behavior of polynomial_division is

signal numer_crc 				: std_logic_vector(39 downto 0);
signal numer_crc_d			: std_logic_vector(39 downto 0);
signal numer_xor				: std_logic_vector(8 downto 0);
signal numer_crc_reg			: std_logic_vector(39 downto 0);


signal crc_compare			: std_logic_vector(8 downto 0);
signal numer_crc_bit			: std_logic;

signal en_crc_reg				: std_logic;
signal ld_crc_reg				: std_logic;
signal crc_d, crc_q			:	std_logic_vector(7 downto 0);

signal crc_input				: std_logic_vector(7 downto 0);

signal en_crc_result			: std_logic;

signal en_data					: std_logic;

signal clr_shift_count		: std_logic;
signal en_shift_count		: std_logic;
signal shift_count			: std_logic_vector(4 downto 0);
signal shift_count_d			: std_logic_vector(4 downto 0);

signal en_xor_shift			: std_logic;
signal ld_xor_shift			: std_logic;
signal inp_xor_shift			: std_logic_vector(8 downto 0);
signal oup_xor_shift			: std_logic_vector(8 downto 0);
signal oup_xor_shift_d		:	std_logic_vector(8 downto 0);

signal inp_xor_shift_sel	: std_logic_vector(8 downto 0);

signal shift_sel				: std_logic;

signal en_data_out			: std_logic;
signal data_out				: std_logic_vector(39 downto 0);
signal data_out_crc_d		: std_logic_vector(39 downto 0);
signal data_out_crc_q		: std_logic_vector(39 downto 0);

signal crc_done_tmp			: std_logic;
signal numer_crc_reg_d, numer_crc_reg_q	:	std_logic_vector(30 downto 0);

type state_type is (init, load_numer, load_numer_wait, load_xor_init, en_xor, check_msb, en_numer, load_xor, result);
signal state					: state_type;

begin

numer_crc <= data_in & "00000000";
data_out <= numer_crc_reg (39 downto 8)& oup_xor_shift(7 downto 0);
inp_xor_shift <= inp_xor_shift_sel xor "100000111";
inp_xor_shift_sel <=  oup_xor_shift when shift_sel = '1' else  numer_crc_reg(39 downto 31);

process(clock, reset)
begin
	if(reset = '0') then
		crc_done	<=	'0';
		numer_crc_reg	<=	(others	=>	'0');
		data_out_crc_q	<=	(others	=>	'0');
		shift_count		<=	(others	=>	'0');
		crc_q				<=	(others	=>	'0');
		numer_crc_reg_q	<=	(others	=>	'0');
		oup_xor_shift		<=	(others	=>	'0');
	elsif(rising_edge(clock)) then
		crc_done	<=	crc_done_tmp;
		numer_crc_reg	<=	numer_crc_d;
		data_out_crc_q	<=	data_out_crc_d;
		shift_count		<=	shift_count_d;
		crc_q				<=	crc_d;
		numer_crc_reg_q	<=	numer_crc_reg_d;
		oup_xor_shift		<=	oup_xor_shift_d;
	end if;
end process;

numer_crc_d		<=	numer_crc when en_data = '1' else numer_crc_reg;
data_out_crc_d			<=	data_out when en_data_out = '1' else data_out_crc_q;

data_out_crc			<=	data_out_crc_q; 	

----------------------crc_done_out flip flop-------------------
--
--
--crc_done_ff: entity work.latch_n 
--	port map(clock	=> clock, 
--				reset => reset,
--				clear => '1', 
--				en 	=> '1',
--				inp 	=> crc_done_tmp,
--				oup	=> crc_done 
--				);
--
--
--
-----------------register for the data to be processed for crc------------------------
--numer_reg: entity work.regne
--		generic map(n => 40) 
--		port map(clock		=> clock,
--					reset 	=> reset,
--					clear		=> '1',  
--					en			=> en_data,
--					input		=> numer_crc,
--					output	=> numer_crc_reg
--					);
--					
-----------------register for data out------------------------
--data_out_reg: entity work.regne
--		generic map(n => 40) 
--		port map(clock		=> clock,
--					reset 	=> reset,
--					clear		=> '1',  
--					en			=> en_data_out,
--					input		=> data_out,
--					output	=> data_out_crc
--					);


-------register for 27 bits that will be shifted for calculating crc-----------------
					
--numer_crc_shift_reg: entity work.shift_left_reg
--	generic map(n => 31)
--	port map(clock		=> clock,	
--				reset		=> reset,
--				en			=> en_crc_reg,
--				clear		=> '1',
--				load		=> ld_crc_reg,
--				inp		=> numer_crc_reg(30 downto 0),
--				output	=> numer_crc_bit
--				);
numer_crc_reg_d	<=	numer_crc_reg(30 downto 0) when ld_crc_reg = '1' else
							numer_crc_reg_q(29 downto 0)&'0' when en_crc_reg = '1' else
							numer_crc_reg_q;
numer_crc_bit		<=	numer_crc_reg_q(30);				
				
----------register for 9 bit register (xor and shift input bit from numerator)----------------
				
--xor_shift_reg: entity work.shift_left_bit
--	generic map(n => 9)
--	port map(clock			=> clock,	
--				reset			=> reset,
--				en				=> en_xor_shift,
--				load			=> ld_xor_shift,
--				shift_bit	=> numer_crc_bit,
--				inp			=> inp_xor_shift,
--				output		=> oup_xor_shift
--				);
oup_xor_shift_d	<=	inp_xor_shift when ld_xor_shift = '1' else
							oup_xor_shift(7 downto 0)&numer_crc_bit when en_xor_shift = '1' else
							oup_xor_shift;				

				
				
--crc_result_reg: entity work.regne
--		generic map(n => 8) 
--		port map(clock		=> clock,
--					reset 	=> reset,
--					clear		=> '1',  
--					en			=> en_crc_result,
--					input		=> oup_xor_shift(7 downto 0),
--					output	=> crc
--					);
crc_d			<=	oup_xor_shift(7 downto 0) when en_crc_result = '1' else crc_q;
crc			<=	crc_q;					
					
--shift_bit_counter: entity work.counter
--		generic map(n => 5)
--		port map(clock		=> clock,	
--					reset		=> reset,
--					clear		=> clr_shift_count,
--					enable	=> en_shift_count,
--					count		=> shift_count
--					);
shift_count_d		<=	"00000" when clr_shift_count = '0' else
							std_logic_vector(unsigned(shift_count) + 1) when en_shift_count = '1' else
							shift_count;
					
					
					
	process(clock, reset)
	begin
		if(reset = '0') then
			state <= init;
		elsif (clock = '1' and clock'event) then
			
			case state is
				
				when init				=> if start_crc = '1' then state <= load_numer;
												else state <= init;
												end if;
												
				when load_numer		=> state <= load_numer_wait;
				
				when load_numer_wait	=> state <= load_xor_init;
									
				when load_xor_init	=> state <= en_xor;
				
				when en_xor				=> state <= check_msb;
				
--				when wait_xor			=> state <= check_msb;
				
				when check_msb			=> if oup_xor_shift(8) = '0' then
													if shift_count = "11110" then state <= result;
													else state <= en_numer;
													end if;
												else state <= load_xor;
												end if;
												
				when load_xor			=> if shift_count = "11110" then state <= result;
												else state <= en_numer;
												end if;
												
				when en_numer			=> state <= en_xor;
		
--				when wait_numer		=> state <= en_xor;
										
				when result				=> state <= init;
				
				when others				=> state <= init;
				
			end case;
		end if;
	end process;
	
ld_crc_reg <= '1' when state = load_numer_wait else '0';
en_crc_reg <= '1' when state = en_numer else '0';
	
en_data <= '1' when state = load_numer else '0';

en_data_out <= '1' when state = result else '0';

shift_sel <= '0' when state = load_numer or state = load_xor_init else '1';
		
en_crc_result <= '1' when state = result else '0';
					
en_xor_shift <= '1' when state = en_xor else '0';

ld_xor_shift <= '1' when state = load_xor_init or state = load_xor else '0';

en_shift_count <= '1' when state = en_numer else '0';
clr_shift_count <= '0' when state = load_numer else '1';

crc_done_tmp <= '1' when state = result else '0';

end architecture behavior;
