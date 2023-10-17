-- written for ADS8684
-- JAL  12/2/2020
-- SDG

-- adc will initialize and will continue to sample the adc and offload the data.
-- Because this adc is continously re-sampling, the rising edge of the 'ready' 
-- output signal can be used as the Fsample for IRR/waveforms (if needed)

-- Notes:
-- when adc first comes out of reset, it will output of all registers will be 0xFACE
-- 
-- 2/11/2021
-- raw output of adc is in Bipolar Offset Binary (BOB) format.
-- this means that FFFF = PFS = 12 VDC
--						 8000 = FSR/2 = 0 VDC
--						 0000 = NFS = -12 VDC
-- to convert from BOB to 2's complement we simply add x8000 to the adc value.
--
-- 3/31/21, updates for 125 MHz local bus clock, see clk_spi process notes.
-- I think it would have been find to run at the old counter values since the max spi is 17MHz

-- NOTE, needed to change polarity of IR sensors becuase they are backwards (somewhere...)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity ADS8684 is
	port (
		clk		    : in  std_logic; -- 125 MHz Clock (fixed)
		reset_n	    : in  std_logic;
		ADC_CSn		 : out std_logic;
		ADC_SCK      : out std_logic;
		ADC_SDI      : out std_logic; -- 12.5 MHz (fixed), max 17 MHz
		ADC_SDO      : in  std_logic;
		reg_a			 : out std_logic_vector(15 downto 0);
		reg_b			 : out std_logic_vector(15 downto 0);
		reg_c			 : out std_logic_vector(15 downto 0);
		reg_d			 : out std_logic_vector(15 downto 0);
		ready_a	    : out std_logic;
		ready_b	    : out std_logic;
		ready_c	    : out std_logic;
		ready_d	    : out std_logic -- will go hi when data is loaded into registers.
		);
	
end ADS8684;

architecture synth of ADS8684 is
	--ADC signals
	signal clk_spi, sclk_en, rdy_en : STD_LOGIC;
	signal last_state, state : STD_LOGIC_VECTOR(3 downto 0) := x"0";
	signal data_save : STD_LOGIC_VECTOR(11 downto 0);
	signal addr	  : STD_LOGIC_VECTOR(2 downto 0) := "000";
	signal chn_sel : STD_LOGIC_VECTOR(1 downto 0) := "00";
	--
	signal spi_counter : STD_LOGIC_VECTOR(3 downto 0);

begin
	--===========================================================================================================================
	-- ADC State Machine
	--===========================================================================================================================
	--
	process(clk_spi, reset_n)
	variable counter          : STD_LOGIC_VECTOR(7 downto  0) := x"00";
	variable man_chn_sel      : STD_LOGIC_VECTOR(1 downto  0) := "00";
	variable sdi_bits         : STD_LOGIC_VECTOR(15 downto 0) := x"0000";
	variable data_save_buffer : STD_LOGIC_VECTOR(15 downto 0);
	variable hold_reg_a, hold_reg_b, hold_reg_c, hold_reg_d : STD_LOGIC_VECTOR(15 downto 0);
	variable reset_clear 	  : STD_LOGIC; -- will be high once we come out of reset
	begin
		if reset_n = '0' then
			counter := x"00"; --reset counter
			ADC_CSn <= '1'; 	-- chip select is hi when adc is not using spi
			ADC_SDI <= '0';	-- sdi is held low when spi not in use
			sclk_en <= '0';	-- sclk enable is off
			data_save_buffer  := x"0000";
			hold_reg_a := x"face";
			hold_reg_b := x"face";
			hold_reg_c := x"face";
			hold_reg_d := x"face";
			man_chn_sel := "00";
			state <= x"1"; -- configure the adc
			sdi_bits := x"C000";
			chn_sel <= "00";
			rdy_en <= '0'; -- enable of ready pulse
			reset_clear := '1';
		elsif clk_spi'event and clk_spi='1' then -- makes changes on positive edge, adc reads them on falling edge
				--
				-- state machine
				case state is
				when x"1"   => -- data conversion state 
						-- send next manuel command register over the sdi bits for the first 16 clocks (0 to 15)
						-- then begin to read sdo data for next 16 clocks (16 to 31).
						-- After the 31st clock, all SDO bits will have been read.
						
						if 	counter >= x"0F" then -- 2/17/21 updated to >= x0F
							-- for ticks 16 to 31
							-- this SDO data is from the previous manually selected channel
							data_save_buffer := data_save_buffer(14 downto 0) & ADC_SDO; -- use shift register to shift in bits
							--
							-- check to see if we are on the last tick
							if counter >= x"1F" then -- 2/17/21 updated to >= x1F
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
							--
							ADC_SDI <= '0'; -- keep sdi outut low low
							sdi_bits := x"0000"; -- sdi bits for next conversion will be set in state 2
														
						else
							-- for ticks 0 to 15
							-- this provides the ADC with the next channel to be read
							ADC_SDI <= sdi_bits(15); -- output sdi bit
							sdi_bits := sdi_bits(14 downto 0) & '0'; -- use simple shift register to shift SDI bits out
							--
							state <= x"1";
							counter := counter + 1;
							data_save_buffer := x"0000";
							sclk_en <= '1'; -- keep sclk enabled
							ADC_CSn <= '0'; -- keep chip selected
						end if;
					-- 
					rdy_en <= '0'; 
					reset_clear := reset_clear;
					--
					hold_reg_a := hold_reg_a;
					hold_reg_b := hold_reg_b;
					hold_reg_c := hold_reg_c;
					hold_reg_d := hold_reg_d;
					--
					-- man_chn_sel is the sdi that is being written during this state.
					-- the data that is being offloaded on sdo was written during the
					-- previous frame. Thus we want to 'look back one frame'
					IF 	man_chn_sel ="00" THEN
						chn_sel <= "11";
					ELSIF man_chn_sel ="01" THEN
						chn_sel <= "00";
					ELSIF man_chn_sel ="10" THEN
						chn_sel <= "01";
					ELSE
						chn_sel <= "10";
					END IF;
					--
					--						
				when others =>  -- load data into registers and add 'between samples delay'
					--
					-- The ready signal will pulse hi (external to this state machine) indicating that the register is ready
					-- to be read.
					
					data_save_buffer := data_save_buffer;
					-- incorporate the between samples delay
					if counter >= x"01" then
						state <= x"1"; -- go to the next state, ready to re-sample
						counter := x"00";
						ADC_CSn <= '0'; -- select the chip
						sclk_en <= '0'; -- sclk disabled
						--
						reset_clear := reset_clear;
						rdy_en <= rdy_en;
						--
					elsif counter = x"00" then
					--
						state <= x"2"; -- stay in this state
						counter := counter + 1;
						ADC_CSn <= '1'; -- de-select the chip
						sclk_en <= '0'; -- sclk disabled
					--
						-- Setup sdi bits for next state
						-- register output data for the address given in the previous state
						-- hold all other output registrers. man_chn_sel is the address given in the previous state
						--
						-- added 2/11/2021 by JAL
						--			convert BOB to 2's complement by adding x8000 to recieved adc data
						--			this addition will occur first, then adc value will be assigned to its hold register
						-- 		adc value is now in 2's complement format.
						--			note, because we are converting from BOB, we do no want to add 1 to prevent overflow for PFS
						data_save_buffer := std_logic_vector( NOT(unsigned(data_save_buffer) + x"8000"));
						--
						if    man_chn_sel = "00" then
							man_chn_sel := "01";
							sdi_bits := x"C400"; -- channel 1, reg_b
							-- regsiter output data
							hold_reg_a := hold_reg_a;
							hold_reg_b := hold_reg_b;
							hold_reg_c := hold_reg_c;
							hold_reg_d := data_save_buffer;
						elsif man_chn_sel = "01" then
							man_chn_sel := "10";
							sdi_bits := x"C800"; -- channel 2, reg_c
							-- regsiter output data
							hold_reg_a := data_save_buffer;
							hold_reg_b := hold_reg_b;
							hold_reg_c := hold_reg_c;
							hold_reg_d := hold_reg_d;
						elsif man_chn_sel = "10" then
							man_chn_sel := "11";
							sdi_bits := x"CC00"; -- channel 3, reg_d
							-- regsiter output data
							hold_reg_a := hold_reg_a;
							hold_reg_b := data_save_buffer;
							hold_reg_c := hold_reg_c;
							hold_reg_d := hold_reg_d;
						else  
							man_chn_sel := "00";
							sdi_bits := x"C000"; -- channel 0, reg_a
							-- regsiter output data
							hold_reg_a := hold_reg_a;
							hold_reg_b := hold_reg_b;
							hold_reg_c := data_save_buffer;
							hold_reg_d := hold_reg_d;
						end if;
					--
					-- check to see if we are coming out of reset
						if reset_clear = '1' then
							-- we will only be in this path if we are first coming out of reset.
							-- the data in the buffer is not valid so do not give a ready pulse.
							-- pull bit 1 of the ready enable low.
							rdy_en <= '0'; 
							reset_clear := '0';
						else
							-- this should be the normal path,
							-- we are not coming out of rset, enable ready pulse
							rdy_en <= '1';
							reset_clear := '0';	
						end if;	
					--
					else
						state <= x"2"; -- stay in this state
						counter := counter + 1;
						ADC_CSn <= '1'; -- de-select the chip
						sclk_en <= '0'; -- sclk disabled
						--
						reset_clear := reset_clear;
						rdy_en <= rdy_en;
						--
					end if;
					--
					--
					ADC_SDI <= '0'; -- keep sdi low
				--
				end case;
				
		end if; -- end reset
		--
		-- continous assignment
		reg_a <= hold_reg_a;
		reg_b <= hold_reg_b;
		reg_c <= hold_reg_c;
		reg_d <= hold_reg_d;
		--
	end process;
	
	-- sclk enable mux
	ADC_SCK <= clk_spi when sclk_en = '1' else '1'; -- keep hi if not in use
	-- let parent module know that register data is ready to be read
	-- this seems redundant, but I believe it makes the module to module
	-- connections easier to understand
	ready_a <= '1' when state = x"2" and chn_sel = "00" and rdy_en ='1' else '0';
	ready_b <= '1' when state = x"2" and chn_sel = "01" and rdy_en ='1' else '0';
	ready_c <= '1' when state = x"2" and chn_sel = "10" and rdy_en ='1' else '0';
	ready_d <= '1' when state = x"2" and chn_sel = "11" and rdy_en ='1' else '0';
	
	--===========================================================================================================================
	-- ADC clock (125 Mhz to 12.5 MHz), max spi sclk frequecny is 20 MHz
	--===========================================================================================================================
	-- FOR 100 MHZ INPUT
	-- divide by 4 to go from 100 Mhz to 12.5 Mhz (4 ticks hi, 4 ticks low at the 100 Mhz rate will make a 12.5Mhz clock)
	-- delay 1 controls how many clock ticks the sclk will be HI for.
	-- delay 2 controls how many clock ticks that the sclk will be LOW for plus 1. if you want a 50% duty cycle, then
	-- set delay2 = 2*delay1 - 1
	-- delay1 was 0x3
	-- delay2 was 0x6
	-- 
	-- update for 125 Mhz clock, 3/31/21
	-- FOR 125 MHZ INPUT
	-- divide by 5 to go from 125 Mhz to 12.5 Mhz (5 ticks hi, 5 ticks low at the 125 Mhz rate will make a 12.5Mhz clock)
	-- delay 1 controls how many clock ticks the sclk will be HI for.
	-- delay 2 controls how many clock ticks that the sclk will be LOW for plus 1. if you want a 50% duty cycle, then
	-- set delay2 = 2*delay1 - 1
--	
--	process(clk, reset_n)
--		variable counter : STD_LOGIC_VECTOR(3 downto 0) := x"0";
--		constant delay1 : STD_LOGIC_VECTOR(3 downto 0) := x"4"; -- will be hi for this duration
--		constant delay2 : STD_LOGIC_VECTOR(3 downto 0) := x"8"; -- after the hi time, it will be low for this duration + 1 tick
--	begin
--		if reset_n = '0' then
--			counter := x"0";
--			clk_spi <= '0';
--		elsif clk'event and clk = '1' then 
--				if (counter <= delay1) then -- sclk is hi
--					counter := counter + 1;
--					clk_spi  <= '1';
--				elsif (counter > delay1) and (counter <= delay2)  then -- sclk is low
--					counter := counter + 1;
--					clk_spi  <= '0';
--				else -- sclk is low, reset counter for next iteration
--					counter := x"0";
--					clk_spi  <= '0';
--				end if;
--		end if;
--	end process;

	-- JAL, 6/28/2023, new SPI clock useses a simple counter. divier by 4, so
	-- spi rate will be 125 MHz /4 = 7.8125 MHz
	process(clk, reset_n)
	begin
		if reset_n = '0' then
			spi_counter <= (OTHERS => '0');
		elsif clk'event and clk = '1' then 
				spi_counter <= spi_counter + 1;
		end if;
	end process;
	clk_spi <= spi_counter(3);
	--
	--
end architecture;