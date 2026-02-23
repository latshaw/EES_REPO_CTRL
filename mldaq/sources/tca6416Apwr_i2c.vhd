-- JAL, mods to slow down clock
-- SFF-8742 document governms EEPROM on SFP
-- code adjusted to ensure the TX_DIABLE is low so we canused the SFP
-- working as of 1/21/2022

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--for xilinx
Library UNISIM;
use UNISIM.vcomponents.all;

entity tca6416APWR_i2c is
port(clock		:	in std_logic;
	reset			:	in std_logic;
	sel			:	in std_logic;
	data_send			:  in std_logic_vector(15 downto 0);
	sda			:	inout std_logic;
	scl			:	out std_logic;
	tca_config_done		:	out std_logic;
	ack_out    : out std_logic
	);
end entity tca6416APWR_i2c;
architecture behavior of tca6416APWR_i2c is

--attribute dont_touch : string;

signal data_sel : STD_LOGIC_VECTOR(15 downto 0);

signal scl_cnt_d			:	std_logic_vector(12 downto 0); -- JAL, made 11 bits (was 8 bits)
signal scl_cnt_q			:	std_logic_vector(12 downto 0); -- JAL, made 11 bits (was 8 bits)
signal wait_cnt_d			:	std_logic_vector(7 downto 0);
signal wait_cnt_q			:	std_logic_vector(7 downto 0);
signal en_wait_cnt		:	std_logic;
signal reg_cnt_d			:	std_logic_vector(2 downto 0);
signal reg_cnt_q			:	std_logic_vector(1 downto 0);
signal en_reg_cnt			:	std_logic;
signal clr_reg_cnt		:	std_logic;
signal data_reg_index	:	integer range 0 to 3;
signal bit_cnt_d			:	std_logic_vector(4 downto 0);
signal bit_cnt_q			:	std_logic_vector(4 downto 0);
signal en_bit_cnt			:	std_logic;
signal clr_bit_cnt		:	std_logic;
signal data_reg_in, ack_finder	:	std_logic_vector(27 downto 0);
signal data_reg_d, ack_reg_d			:	std_logic_vector(27 downto 0);
signal data_reg_q, ack_reg_q			:	std_logic_vector(27 downto 0);
signal ld_data_reg		:	std_logic;
signal sh_data_reg		:	std_logic;
signal clk_done_d			:	std_logic;
signal clk_done_q			:	std_logic;
signal i2c_clock			:	std_logic;
signal init_wait_cnt_d	:	std_logic_vector(23 downto 0);
signal init_wait_cnt_q	:	std_logic_vector(23 downto 0);
signal data_ld_cnt_d		:	std_logic_vector(2 downto 0);
signal data_ld_cnt_q		:	std_logic_vector(2 downto 0);
signal en_data_ld_cnt	:	std_logic;
signal init_wait_cnt_clr : std_logic;

signal pgm_cnt_q, pgm_cnt_d	:	std_logic_vector(3 downto 0);
signal en_pgm_cnt, T, sda_from_fpga, sda_to_fpga		:	std_logic;
type reg_data is array(3 downto 0) of std_logic_vector(15 downto 0);
--constant clk_reg_data	:	reg_data:= (x"03A8", x"0200", x"0150", x"0010");
--constant clk_reg_data	:	reg_data:= (x"0338", x"0339", x"0200", x"0106", x"0010");

--JAL
signal clk_reg_data	:	reg_data;

--attribute dont_touch of scl_cnt_q, wait_cnt_q, en_wait_cnt, reg_cnt_q, en_reg_cnt, clr_reg_cnt, data_reg_index, bit_cnt_q, en_bit_cnt, clr_bit_cnt : signal is "true";
--attribute dont_touch of data_reg_in, ack_finder, data_reg_q, ack_reg_q, ld_data_reg, sh_data_reg, clk_done_q, init_wait_cnt_q, data_ld_cnt_q, en_data_ld_cnt, init_wait_cnt_clr : signal is "true";
--attribute dont_touch of pgm_cnt_q, pgm_cnt_d, en_pgm_cnt, T, sda_from_fpga, sda_to_fpga, clk_reg_data  : signal is "true";


type state_type is (init, data_load, scl_high, scl_low, bit_check, reg_check, stop_reg, config_done);
signal state				:	state_type;

------------data_format-----------start,7bit_dev_address,W/R,Ack,8bit_reg_addr,Ack,8bit_data,A,stop
begin

--data_reg_in		<=	'0' & "0100000" & '0' & 'Z' & clk_reg_data(data_reg_index)(15 downto 8) & 'Z' & clk_reg_data(data_reg_index)(7 downto 0) & 'Z'; -- INTEL
i2c_clock		<=	scl_cnt_q(12); -- made to trigger on MSbit
tca_config_done <=	clk_done_q;
--
-- producs the i2c clock
-- i2c clock is at 50% duty cycle, with rate being input clock/2k, 125M/2k = about 60k Hz (assumes 12 bit counter)
process(clock,reset)
begin
	if(reset = '0') then
		scl_cnt_q	<=	(others => '0');
	elsif(clock'event and clock = '1') then
		scl_cnt_q	<=	std_logic_vector(unsigned(scl_cnt_q) + 1);
	end if;
end process;	
--
--
--clk_reg_data <= (x"0600", x"0700", x"02" & data_send(15 downto 8), x"03" & data_send(7 downto 0));
clk_reg_data <= (x"0600", x"0700", x"025A5", x"035A");
--
-- main state machine
process(i2c_clock, reset)
    variable counter_1, counter_2 : UNSIGNED(15 downto 0);
    variable counter_bits : UNSIGNED(4 downto 0);
     variable counter_reg : UNSIGNED(1 downto 0);
begin
	if(reset = '0') then
		state	<=	init;
		counter_1 :=	(others => '0');
		counter_bits := (others => '0');
		counter_reg := (others => '0');
		counter_2 := (others => '0');
		data_reg_q <= (others => '0');
		ack_reg_q  <= (others => '0');
		--data_reg_in   <= (others => '0');
		--ack_finder  <= (others => '0');
		reg_cnt_q  <= (others => '0');
		--
	elsif(i2c_clock'event and i2c_clock='1') then
		case state is
			when init			=>	if counter_1 >= x"001f" then  -- stay in init for 32 i2c ticks
			                             state        <= data_load;	
			                             counter_1	  :=	(others => '0');								
									else 
									     state        <=	init;
									     counter_1    := counter_1 + 1;
									end if;
			when data_load		=>	state <= scl_high;		
                                    data_reg_q		<=	data_reg_in;
                                    ack_reg_q	   	<=	ack_finder; 
			when scl_high		=>	state <= scl_low;
			when scl_low		=>	state <= bit_check;
			                        data_reg_q	 <= data_reg_q(26 downto 0) & '0';
			                        ack_reg_q   <= ack_reg_q(26 downto 0) & '0';
			when bit_check		=>	if counter_bits = "11011" then -- if 27 bits HAVE been sent
			                             state <= reg_check;
			                             counter_bits := (others => '0');
								    else 
								         state <= scl_high;
								         counter_bits := counter_bits + 1;
									end if;
			when reg_check		=>	if counter_reg = "11" then 
			                             state <= init; -- done sneding all packets
			                             counter_reg := (others => '0');
								    else 
								        state <= stop_reg; -- move on to the next packet
								        counter_reg := counter_reg + 1;
								    end if;
			when stop_reg		=>	if counter_2 >= x"001f" then 
			                             state <= data_load;
			                             counter_2 := (others => '0');
								    else 
								          state <= stop_reg;
								          counter_2 := counter_2 + 1;
									end if;						
			
			when others			=>	state <= init;
		end case;
		--
		reg_cnt_q <= STD_LOGIC_VECTOR(counter_reg);
	end if;
end process;
data_reg_index	<= to_integer(unsigned (reg_cnt_q));
ack_finder      <=  '0' & "0000000" & '0' & '1' & "00000000" & '1' & "00000000" & '1'; -- only HI when ack expected	


-- what data goes to LEDS
-- all's F's to test them (make sure they all work).
data_sel <= data_send when sel = '0' else x"FFFF";

data_reg_in <=	'0' & "0100000" & '0' & '0' & x"06" & '0' & x"00" & '0' when reg_cnt_q ="00" else
                '0' & "0100000" & '0' & '0' & x"07" & '0' & x"00" & '0' when reg_cnt_q ="01" else
                '0' & "0100000" & '0' & '0' & x"02" & '0' & data_sel(7 downto 0)  & '0' when reg_cnt_q ="10" else
                '0' & "0100000" & '0' & '0' & x"03" & '0' & data_sel(15 downto 8) & '0';

--en_wait_cnt			<=	'1' when state = stop_reg  else '0';
--clr_bit_cnt			<=	'0' when state = reg_check else '1';
--en_bit_cnt			<=	'1' when state = bit_check else '0';
--en_reg_cnt			<=	'1' when state = reg_check else '0';
--en_data_ld_cnt		<=	'1' when state = config_done else '0';
----clr_reg_cnt			<=	'0' when state = reg_check and reg_cnt_q = "100" else '1';
--clr_reg_cnt			<=	'0' when reg_cnt_q = "100" else '1';
----clr_reg_cnt			<=	'1';
--ld_data_reg			<=	'1' when state = data_load else '0';
--sh_data_reg			<=	'1' when state = scl_low else '0';
scl					<=	'0' when state = scl_low or state = bit_check else '1';
sda_from_fpga		<=	'1' when state = init or state = data_load or state = stop_reg or state = config_done else
							'0' when state = reg_check else
							data_reg_q(27);
--clk_done_d			<=	'1' when state = config_done else '0';
--en_pgm_cnt			<=	'1' when state = config_done and pgm_cnt_q /= "1111" else '0';	
--en_pgm_cnt			<=	'1' when state = config_done else '0';		
--init_wait_cnt_clr   <=  '1' when state = init else '0';


---- sda data output from fpga
--data_reg_d		<=	data_reg_in                   when ld_data_reg = '1' else
--				    data_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
--				    data_reg_q;
----expected sda input to fpga				    
--ack_reg_d	   	<=	ack_finder                    when ld_data_reg = '1' else
--				    ack_reg_q(26 downto 0) & '0' when sh_data_reg = '1' else
--				    ack_reg_q;

-- output enable for xilinx IOBUF module
-- HI means data to FPGA   
-- LO means data from FPGA
T <= ack_reg_q(27);

ack_out <= sda_to_fpga;

	-- Added for Xilinx 3/24/22
   IOBUF_inst : IOBUF
   generic map (
      DRIVE => 12,
      IOSTANDARD => "DEFAULT",
      SLEW => "SLOW")
   port map (
      O =>  sda_to_fpga,      -- Buffer output (to fpga from external IC)
      IO => sda,              -- Buffer inout port (connect directly to top-level port)
      I =>  sda_from_fpga,    -- Buffer input (from fpga)
      T =>  T                 -- 3-state enable input, high=input (HI Z output, allows fpga to see external IC data), low=output (outputs data to external IC)
   );

end architecture behavior;	