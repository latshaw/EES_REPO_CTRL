library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lmk04808 is

port(	clock			: in std_logic;-------clock is 100 mhz
		reset			: in std_logic;
		
			
		datauwire	: out std_logic;
		clkuwire		: out std_logic;
		leuwire		: out std_logic;
		
		sync			: out std_logic;
		pll_rst		: out std_logic
		
		);
		
end entity lmk04808;

architecture behavior of lmk04808 is

type reg_record is record

datauwire			:	std_logic;
clkuwire			:	std_logic;
leuwire				:	std_logic;
sync					:	std_logic;
pll_data_cnt		:	integer range 0 to 31;
pll_bit_cnt			:	integer range 0 to 31;
sclk_cnt			:	integer range 0 to 511;
le_cnt				:	integer range 0 to 1023;
wait_cnt			:	integer range 0 to 1023;
data_ld_wait_cnt	:	integer range 0 to 1023;
pll_ld_data			:	std_logic_vector(31 downto 0);
pll_data_in			:	std_logic_vector(31 downto 0);
pll_rst				:	std_logic;
end record reg_record;

signal d,q			:	reg_record;

type reg32_32 is array(31 downto 0) of std_logic_vector(31 downto 0);
signal pll_data					: reg32_32;

signal en_pll_data				: std_logic;
signal ld_pll_data				: std_logic;

signal pll_data_out_bit 		: std_logic;

signal en_pll_data_cnt			: std_logic;


signal en_pll_bit_cnt			: std_logic;
signal clr_pll_bit_cnt  		: std_logic;


signal en_sclk_cnt				: std_logic;


signal en_le_cnt					: std_logic;


signal en_data_ld_wait_cnt  	: std_logic;


signal datauwire_buf				: std_logic;
signal clkuwire_buf				: std_logic;
signal leuwire_buf				: std_logic;


signal en_wait_cnt				: std_logic;





type state_type is (init, le_low, le_low_wait, data_load, data_ld_wait, sclk_high, sclk_low, le_high, le_high_wait, pll_done);
signal state				: state_type;

begin


  
  
pll_data(0) <= x"80160180";-------init value r0

-----dividers for 93 MHz ADC clock, 186 MHz DAC clock, 93 MHz test clock
--pll_data(1) <= x"00140340";----r0
--pll_data(2) <= x"00140340";----r0
--pll_data(3) <= x"001401A1";----r1
--pll_data(4) <= x"001401A1";----r1
--pll_data(5) <= x"00140342";----r2
--pll_data(6) <= x"00140342";----r2

pll_data(1) <= x"00140400";----r0
pll_data(2) <= x"00140400";----r0

pll_data(3) <= x"00140201";----r1
pll_data(4) <= x"00140201";----r1

pll_data(5) <= x"00140402";----r2
pll_data(6) <= x"00140402";----r2

pll_data(7) <= x"00140203";----r3
pll_data(8) <= x"00140203";----r3

pll_data(9) <= x"80140184";----r4
pll_data(10) <= x"80140184";----r4

pll_data(11) <= x"80140185";----r5
pll_data(12) <= x"80140185";----r5

pll_data(13) <= x"04040006";----r6
pll_data(14) <= x"00600007";----r7

pll_data(15) <=  x"04000008";----r8
pll_data(16) <= x"55555549";----r9
pll_data(17) <= x"9102410a";----r10
pll_data(18) <= x"0000100b";----r11
pll_data(19) <= x"1b0c00ac";----r12
pll_data(20) <= x"2302006d";----r13
pll_data(21) <= x"0200000e";----r14
pll_data(22) <= x"8000800f";----r15

pll_data(23) <= x"01550410";----r16

pll_data(24) <= x"000000D8";----r24
pll_data(25) <= x"02c9c419";----r25
pll_data(26) <= x"afa8001a";----r26


-----PFD 1 MHz, PLL2 VCO 2418 MHz, 93 MHz ADC clock, 186 MHz DAC clock
--pll_data(27) <= x"1C00119b";----r27
--pll_data(28) <= x"0a00141c";----r28
--pll_data(29) <= x"0100973d";----r29
--pll_data(30) <= x"0200973e";----r30


-- IF DEF for 112 vcxop
-------this is with 112 MHz VCXO
pll_data(27) <= x"1000015b";----r27
pll_data(28) <= x"0070021c";----r28


-- IF DEF for 80 mhz vcxo
-------this is with 80 MHz VCXO
--pll_data(27) <= x"180001db";----r27
--pll_data(28) <= x"0050021c";----r28




-------------------------this is for generating 93 MHz--------------------
--
pll_data(29) <= x"010003fd";----r29--------this is used for calibrating vco, same divider as r30
pll_data(30) <= x"030003fe";----r30


------------------------this is for testing generating 95 MHz-------------
--pll_data(28) <= x"0020021c";----r28
--pll_data(29) <= x"0100027d";----r29--------this is used for calibrating vco, same divider as r30
--pll_data(30) <= x"0100027e";----r30


pll_data(31) <= x"001f001f";----r31






				
d.pll_data_in		<=	q.pll_ld_data when ld_pll_data = '1' else
							q.pll_data_in	(30 downto 0) & '0' when en_pll_data = '1' else
							q.pll_data_in;
				
pll_data_out_bit	<=	q.pll_data_in(31);				
				

					  
datauwire_buf <= '0' when (state = pll_done or state = le_high or state = le_high_wait or state = le_low or state = le_low_wait) else pll_data_out_bit;
				
process(clock, reset)
begin
	if(reset = '0') then
		q.datauwire				<=	'0';
		q.clkuwire				<=	'0';
		q.leuwire				<=	'1';
		q.pll_data_cnt			<=	0;
		q.pll_bit_cnt			<=	0;
		q.sclk_cnt				<=	0;
		q.le_cnt					<=	0;
		q.wait_cnt				<=	0;
		q.data_ld_wait_cnt	<=	0;
		q.pll_ld_data			<=	(others	=>	'0');
		q.pll_data_in			<=	(others	=>	'0');
		q.sync				   <=	'0';
		q.pll_rst            <= '0'; -- JAL, 6/13/24 
	elsif(rising_edge(clock)) then
		q							<=	d;
	end if;
end process;


d.datauwire		<=	datauwire_buf;
d.clkuwire		<=	clkuwire_buf;
d.leuwire		<=	leuwire_buf;


datauwire		<=	q.datauwire;
clkuwire			<=	q.clkuwire;	
leuwire			<=	q.leuwire;
sync				<=	q.sync;
pll_rst			<=	q.pll_rst;	
				

d.pll_data_cnt		<=		q.pll_data_cnt + 1 when en_pll_data_cnt = '1' and q.pll_data_cnt /= 31 else
							q.pll_data_cnt;
d.pll_bit_cnt		<=	0 when clr_pll_bit_cnt = '0' else
							q.pll_bit_cnt + 1 when en_pll_bit_cnt = '1' and q.pll_bit_cnt /= 31 else
							q.pll_bit_cnt;
d.sclk_cnt		<=	0 when q.sclk_cnt = 511 else
							q.sclk_cnt + 1 when en_sclk_cnt = '1' else
							q.sclk_cnt;
d.le_cnt		<=	0 when q.le_cnt = 1023 else
							q.le_cnt + 1 when en_le_cnt = '1' else
							q.le_cnt;
d.wait_cnt		<=	0 when q.wait_cnt = 1023 else
							q.wait_cnt + 1 when en_wait_cnt = '1' else
							q.wait_cnt;
d.data_ld_wait_cnt		<=	0 when q.data_ld_wait_cnt = 1023 else
							q.data_ld_wait_cnt + 1 when en_data_ld_wait_cnt = '1' else
							q.data_ld_wait_cnt;							
					

				
				
with q.pll_data_cnt select				
d.pll_ld_data	<= pll_data(0) when 0,
					pll_data(1) when 1,
					pll_data(2) when 2,
					pll_data(3) when 3,
					pll_data(4) when 4,
					pll_data(5) when 5,
					pll_data(6) when 6,
					pll_data(7) when 7,
					pll_data(8) when 8,
					pll_data(9) when 9,
					pll_data(10) when 10,
					pll_data(11) when 11,
					pll_data(12) when 12,
					pll_data(13) when 13,
					pll_data(14) when 14,
					pll_data(15) when 15,
					pll_data(16) when 16,
					pll_data(17) when 17,
					pll_data(18) when 18,
					pll_data(19) when 19,
					pll_data(20) when 20,
					pll_data(21) when 21,
					pll_data(22) when 22,
					pll_data(23) when 23,
					pll_data(24) when 24,
					pll_data(25) when 25,
					pll_data(26) when 26,
					pll_data(27) when 27,
					pll_data(28) when 28,
					pll_data(29) when 29,
					pll_data(30) when 30,
					pll_data(31) when 31,
					x"00000000" when others;
					
					
	process(clock, reset)
	begin
		if reset = '0' then
			state <= init;
		elsif (rising_edge(clock)) then
			case state is
			
				when init			=> if q.wait_cnt = 1023 then state <= le_low;
											else state <= init;
											end if;
				
				when le_low			=> state <= le_low_wait;
				
				when le_low_wait	=> if q.le_cnt = 1023 then state <= data_load;
											else state <= le_low_wait;
											end if;
										
				when data_load		=> state <= data_ld_wait;
				  
				when data_ld_wait => if q.data_ld_wait_cnt = 1023 then state <= sclk_high;				
											else state <= data_ld_wait;				
											end if;  
				
				when sclk_high		=> if q.sclk_cnt = 255 then state <= sclk_low;
											else state <= sclk_high;
											end if;
											
				when sclk_low		=> if q.sclk_cnt = 511 then
												if q.pll_bit_cnt = 31 then state <= le_high;
												else state <= sclk_high;
												end if;
											else state <= sclk_low;
											end if;
											
				when le_high		=> state <= le_high_wait;
				
				when le_high_wait	=> if q.le_cnt = 1023 then
												if q.pll_data_cnt = 31 then state <= pll_done;
												else state <= le_low;
												end if;
											else state <= le_high_wait;
											end if;
											

											
				when pll_done		=> state <= pll_done;
										
				
				when others			=> state <= init;
				
			end case;
			
		end if;
	end process;
	
	
en_sclk_cnt				<= '1' when state = sclk_low or state = sclk_high else '0';
clr_pll_bit_cnt		<= '0' when state = data_load else '1';

en_wait_cnt				<= '1' when state = init else '0';

en_pll_bit_cnt			<= '1' when state = sclk_low and q.sclk_cnt = 511 else '0';
en_pll_data 			<= '1' when state = sclk_low and q.sclk_cnt = 271 else '0';

en_pll_data_cnt		<= '1' when state = le_high_wait and q.le_cnt = 1023 else '0';
en_le_cnt				<= '1' when state = le_low_wait or state = le_high_wait else '0';
en_data_ld_wait_cnt 	<= '1' when state = data_ld_wait else '0';
ld_pll_data				<= '1' when state = data_load else '0';
clkuwire_buf			<= '1' when state = sclk_high else '0';
leuwire_buf				<= '1' when state = init or state = le_high or state = le_high_wait else '0';

d.pll_rst					<= '1' when state = pll_done else '0';

--d.sync						<= '1' when state = pll_done else '0';
d.sync					<=	'0';

end architecture behavior;
		
		

