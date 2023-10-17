-- written for ADS8353
-- JAL  12/2/2020
-- SDG

-- adc will initialize and will continue to sample the adc and offload the data.
-- Because this adc is continously re-sampling, the rising edge of the 'ready' 
-- output signal can be used as the Fsample for IRR/waveforms (if needed)

-- Notes:
-- when adc first comes out of reset, it will output reg_a & reg_b = '0xdeadbeef'
-- when the adc is performing an initial configuration it will output reg_a & reg_b = '0xfacefeed'

-- 3/31/21, udpate for 125 Mhz local bus clock
-- see clk_spi process.

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ADS8353 is
	port (
		clk		    : in  std_logic; -- 125 MHz Clock (fixed)
		reset_n	    : in  std_logic;
		ADC_CSn		 : out std_logic;
		ADC_SCK      : out std_logic;
		ADC_SDI      : out std_logic; -- 12.5 MHz (fixed)
		ADC_SDO_A    : in  std_logic;
		ADC_SDO_B    : in  std_logic;
		reg_a			 : out std_logic_vector(15 downto 0);
		reg_b			 : out std_logic_vector(15 downto 0);
		ready_a	    : out std_logic;
		ready_b	    : out std_logic -- will go hi when data is loaded into registers.
		);
	
end ADS8353;

architecture synth of ADS8353 is
	--ADC signals
	signal clk_spi, sclk_en : STD_LOGIC;
	signal state : STD_LOGIC_VECTOR(3 downto 0) := x"0";
	signal data_save : STD_LOGIC_VECTOR(11 downto 0);
	signal addr	  : STD_LOGIC_VECTOR(2 downto 0) := "000";
	--
begin
	--===========================================================================================================================
	-- ADC State Machine
	--===========================================================================================================================
	--
	process(clk_spi, reset_n)
	variable counter : STD_LOGIC_VECTOR(7 downto 0) := x"00";
	variable sdi_bits    : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
	variable data_save_buffer_a, hold_reg_a : STD_LOGIC_VECTOR(15 downto 0);
	variable data_save_buffer_b, hold_reg_b : STD_LOGIC_VECTOR(15 downto 0);
	begin
		if reset_n = '0' then
			counter := x"00"; --reset counter
			ADC_CSn <= '1'; 	-- chip select his hi when adc is not using spi
			ADC_SDI <= '0';	-- sdi is held low when spi not in use
			sclk_en <= '0';	-- sclk enable is off
			data_save_buffer_a := x"0000";
			data_save_buffer_b := x"0000";
			hold_reg_a := x"dead";
			hold_reg_b := x"beef";
			state <= x"F"; -- configure the adc
		elsif clk_spi'event and clk_spi='1' then -- makes changes on positive edge, adc reads them on falling edge
				-- state machine
				case state is
				when x"0"   => -- adc configuration state
						-- very similar to the data conversion state except we write to the configuration register
						-- over the sdi line and ignore the sdo data
						
						if 	counter > x"0D" then
							-- for ticks 16 to 31
							state <= x"0";
							data_save_buffer_a := x"face";
							data_save_buffer_b := x"feed";
							--
							-- check to see if we are on the last tick
							if counter > x"1F" then
								state <= x"2"; -- go to ready state
								counter := x"00";
								sclk_en <= '0'; -- disable sclk
								ADC_CSn <= '1'; -- de-select chip
							else
								state <= x"0";
								counter := counter + 1;
								sclk_en <= '1'; -- keep sclk enabled
								ADC_CSn <= '0'; -- keep chip selected
							end if;
														
						else
							-- for ticks 0 to 15
							state <= x"0";
							counter := counter + 1;
							data_save_buffer_a := x"face";
							data_save_buffer_b := x"feed";
							sclk_en <= '1'; -- keep sclk enabled
							ADC_CSn <= '0'; -- keep chip selected
						end if;
					-- 
					ADC_SDI <= sdi_bits(15); -- keep sdi low
					sdi_bits := sdi_bits(14 downto 0) & '0'; -- shift sdi bits out to adc, backfill with zeros
					hold_reg_a := data_save_buffer_a;
					hold_reg_b := data_save_buffer_b;
					--
				when x"1"   => -- data conversion state 
						-- send low sdi bits for the first 16 clcoks (0 to 15)
						-- then begin to read sdo data for next 16 clocks (16 to 31)
						-- ensure to go to the next state after the 31st clock
						
						if 	counter > x"0D" then
							-- for ticks 16 to 31
							data_save_buffer_a := data_save_buffer_a(14 downto 0) & ADC_SDO_A; -- use shift register to shift in bits
							data_save_buffer_b := data_save_buffer_b(14 downto 0) & ADC_SDO_B;
							--
							-- check to see if we are on the last tick
							if counter > x"1F" then
								state <= x"2"; -- go to the next state
								counter := x"00";
								sclk_en <= '0'; -- disable sclk
								ADC_CSn <= '1'; -- de-select chip
							else
								state <= x"1";
								counter := counter + 1;
								sclk_en <= '1'; -- keep sclk enabled
								ADC_CSn <= '0'; -- keep chip selected
							end if;
														
						else
							-- for ticks 0 to 15
							state <= x"1";
							counter := counter + 1;
							data_save_buffer_a := x"0000";
							data_save_buffer_b := x"0000";
							sclk_en <= '1'; -- keep sclk enabled
							ADC_CSn <= '0'; -- keep chip selected
						end if;
					-- 
					ADC_SDI <= '0'; -- keep sdi low
					sdi_bits := x"0000"; -- not needed for this state, keep low
					hold_reg_a := hold_reg_a;
					hold_reg_b := hold_reg_b;
					--						
				when x"2"   => -- load data into registers and add 'between samples delay'
					-- ready signal will pulse hi (external to this state machine)
					-- keep register values the same
					data_save_buffer_a := data_save_buffer_a;
					data_save_buffer_b := data_save_buffer_b;
					-- incorporate the between samples delay
					if counter >= x"01" then
						state <= x"1"; -- go to the next state, ready to re-sample
						counter := x"00";
						ADC_CSn <= '0'; -- select the chip
						sclk_en <= '0'; -- sclk disabled
					else
						state <= x"2"; -- stay in this state
						counter := counter + 1;
						ADC_CSn <= '1'; -- de-select the chip
						sclk_en <= '0'; -- sclk disabled
					end if;
					ADC_SDI <= '0'; -- keep sdi low
					sdi_bits := x"0000"; -- not needed for this state, keep low
					-- register output data
					hold_reg_a := data_save_buffer_a;
					hold_reg_b := data_save_buffer_b;
				--
				when others => -- coming out of reset
					-- incorporate a wake up delay
					if counter >= x"03" then
						state <= x"0"; -- go to adc configuration state
						counter := x"00";
						ADC_CSn <= '0'; -- select the chip
						sclk_en <= '0'; -- sclk disabled
					else
						state <= x"F"; -- stay in this state
						counter := counter + 1;
						ADC_CSn <= '1'; -- de-select the chip
						sclk_en <= '0'; -- sclk disabled
					end if;
					sdi_bits := x"8040"; --setup sdi bits for configuration
					-- ======= SPI =======
					-- SPI config notes (for each for bits)
					-- (wnr + address=000) (0000) (set intenral dac ref 0010) (0000)
					-- =======     =======
					ADC_SDI <= '0';
					data_save_buffer_a := data_save_buffer_a;
					data_save_buffer_b := data_save_buffer_b;
					hold_reg_a := hold_reg_a;
					hold_reg_b := hold_reg_b;
				end case;
				
		end if; -- end reset
		--
		-- continous assignment
		reg_a <= hold_reg_a;
		reg_b <= hold_reg_b;
	end process;
	
	-- sclk enable mux
	ADC_SCK <= clk_spi when sclk_en = '1' else '1'; -- keep hi if not in use
	-- let parent module know that register data is ready to be read
	-- this seems redundant, but I believe it makes the module to module
	-- connections easier to understand
	ready_a <= '1' when state = x"2" else '0';
	ready_b <= '1' when state = x"2" else '0';
	
	--===========================================================================================================================
	-- ADC clock (100 Mhz to 12.5 MHz), max spi sclk frequecny is 20 MHz
	--===========================================================================================================================
	-- FOR 100 MHz clock
	-- divide by 4 to go from 100 Mhz to 12.5 Mhz (4 ticks hi, 4 ticks low at the 100 Mhz rate will make a 12.5Mhz clock)
	-- delay 1 controls how many clock ticks the sclk will be HI for.
	-- delay 2 controls how many clock ticks that the sclk will be LOW for plus 1. if you want a 50% duty cycle, then
	-- set delay2 = 2*delay1 - 1
	-- delay1 was 0x3
	-- delay2 was 0x6
	--
	---- FOR 125 MHz clock
	-- divide by 5 to go from 125 Mhz to 12.5 Mhz (5 ticks hi, 5 ticks low at the 125 Mhz rate will make a 12.5Mhz clock)
	-- delay 1 controls how many clock ticks the sclk will be HI for.
	-- delay 2 controls how many clock ticks that the sclk will be LOW for plus 1. if you want a 50% duty cycle, then
	-- set delay2 = 2*delay1 - 1
	
	process(clk, reset_n)
		variable counter : STD_LOGIC_VECTOR(3 downto 0) := x"0";
		constant delay1 : STD_LOGIC_VECTOR(3 downto 0) := x"4"; -- will be hi for this duration
		constant delay2 : STD_LOGIC_VECTOR(3 downto 0) := x"8"; -- after the hi time, it will be low for this duration + 1 tick
	begin
		if reset_n = '0' then
			counter := x"0";
			clk_spi <= '0';
		elsif clk'event and clk = '1' then 
				if (counter <= delay1) then -- sclk is hi
					counter := counter + 1;
					clk_spi  <= '1';
				elsif (counter > delay1) and (counter <= delay2)  then -- sclk is low
					counter := counter + 1;
					clk_spi  <= '0';
				else -- sclk is low, reset counter for next iteration
					counter := x"0";
					clk_spi  <= '0';
				end if;
		end if;
	end process;
	--
	--
end architecture;