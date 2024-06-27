-- written for ADS8684
-- JAL  12/2/2020
-- SDG
-- major updates as of 6/26/24

-- adc will initialize and will continue to sample the adc and offload the data.
-- Because this adc is continously re-sampling, the rising edge of the 'ready' 
-- output signal can be used as the Fsample for IRR/waveforms (if needed)

-- Notes:
-- raw output of adc is in Bipolar Offset Binary (BOB) format.
-- this means that FFFF = PFS = 12 VDC
--						 8000 = FSR/2 = 0 VDC
--						 0000 = NFS = -12 VDC
-- to convert from BOB to 2's complement we simply add x8000 to the adc value.
-- HOWEVER, we also invert data because the IR inputs are flipped.
-- so we needed to change polarity of IR sensors becuase they are backwards (somewhere... on the pcb)

library ieee;
use ieee.std_logic_1164.all;
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
	signal readyREG_d, readyREG_q : STD_LOGIC_VECTOR(3 downto 0);
	--
	signal SDI_q, SDI_d, SDO_q, SDO_d : UNSIGNED(15 downto 0);
	signal regAq, regAd, regBq, regBd, regCq, regCd, regDq, regDd : UNSIGNED(15 downto 0);
	--
	signal spi_counter_q, spi_counter_d : UNSIGNED(2 downto 0); -- half rate of sclk period
	signal reset_counter_q, reset_counter_d : UNSIGNED(11 downto 0); -- hold in reset at init
	signal delay_counter_q, delay_counter_d : UNSIGNED(11 downto 0); -- delay between samples
	signal sclk_counter_q, sclk_counter_d   : UNSIGNED(4 downto 0); -- 32 sclk pulses
	signal chan_sel_q, chan_sel_d           : UNSIGNED(1 downto 0); -- reading 4 channels

	
	-- arranged in general state machine order
	type state_type is (INIT, DELAY, SCLK_LOW1, SCLK_LOW2, SCLK_HI1, SCLK_HI2, SCLK_HI3, SCLK_HI4, SCLK_LOW3, SCLK_LOW4); 
	signal state_d, state_q			: state_type;
	
	
begin
	--===========================================================================================================================
	-- Main Register
	--===========================================================================================================================
	-- Note, ADC covnersion happens at follwing edge of CSn
	--       ADC reads them on falling edge of SCLK
	--
	process(clk, reset_n)
	begin
		if reset_n = '0' then
			state_q         <= INIT;
			reset_counter_q <= (others	=>	'0');
			delay_counter_q <= (others	=>	'0');
			sclk_counter_q  <= (others	=>	'0');
			chan_sel_q      <= (others	=>	'0');
			SDI_q           <= (others	=>	'0');
			SDO_q           <= (others	=>	'0');
			readyREG_q      <= (others => '0');
			regAq           <= (others	=>	'0');
			regBq           <= (others	=>	'0');
			regCq           <= (others	=>	'0');
			regDq           <= (others	=>	'0');
		elsif clk'event and clk='1' then 
			state_q         <= state_d;
			reset_counter_q <= reset_counter_d;
			delay_counter_q <= delay_counter_d;
			sclk_counter_q  <= sclk_counter_d;
			chan_sel_q      <= chan_sel_d;
			SDI_q           <= SDI_d;
			SDO_q           <= SDO_d;
			readyREG_q      <= readyREG_d;
			regAq           <= regAd;
			regBq           <= regBd;
			regCq           <= regCd;
			regDq           <= regDd;
		end if; -- end reset
	end process;
	--
	--
	--===========================================================================================================================
	-- ADC State Machine
	--===========================================================================================================================
	--	SCLK will be HI for 4 fast clock ticks and LOW for 4 fast clock ticks per one SCLK period
	-- note this is a combinational process
	process(reset_n, state_q, reset_counter_q, delay_counter_q, sclk_counter_q)
	begin
		if reset_n = '0' then
			state_d <= INIT;
		--elsif clk'event and clk='1' then -- fast clock
		else
				case state_q is
				when INIT    => if reset_counter_q >= x"0ff" then --initial wakeup delay
											state_d <= DELAY;
										else
											state_d <= INIT;
										end if;
				when DELAY     => if delay_counter_q >= x"0ff" then -- delay between ADC samples
											state_d <= SCLK_LOW1;
										else
											state_d <= DELAY;
										end if;
				when SCLK_LOW1 => state_d <= SCLK_LOW2;		
				when SCLK_LOW2 => state_d <= SCLK_HI1;
				when SCLK_HI1  => state_d <= SCLK_HI2;
				when SCLK_HI2  => state_d <= SCLK_HI3;
				when SCLK_HI3  => state_d <= SCLK_HI4;
				when SCLK_HI4  => state_d <= SCLK_LOW3;
				when SCLK_LOW3 => state_d <= SCLK_LOW4;
				when others    => if sclk_counter_q = x"1F" then -- SCLK_LOW4
											state_d <= DELAY;
										else
											state_d <= SCLK_LOW1;
										end if;
				end case;		
		end if; -- end reset
		--
		--
	end process;
	
	-- counters
	reset_counter_d <= x"000" when state_q /= INIT  else reset_counter_q + 1; -- only increment counter in init state, o/w reset
	delay_counter_d <= x"000" when state_q /= DELAY else delay_counter_q + 1; -- only incrment counte rin  delay state, o/w reset
	sclk_counter_d  <= sclk_counter_q + 1 when state_q = SCLK_LOW4  else sclk_counter_q; -- will roll over after 32 SCLK pulses
	chan_sel_d      <= chan_sel_q + 1     when state_q = SCLK_LOW4 AND sclk_counter_q = x"1F"  else chan_sel_q; -- will roll over after all 4 channles are read
	-- spi data word : changes based on which adc is read. 
	-- note, the direction is from the prespective of the ADC (so it matches the datasheet)
	-- SDO is from ADC to FPGA
	-- SDI is from FPGA to ADC
	--
	-- next SDI word is established during DELAY state
   -- MSbit is shifted out on last SCLK_LOW state	
	SDI_d <= x"C000" when chan_sel_q = "00" AND state_q = DELAY else -- channel 0, reg_a
	         x"C400" when chan_sel_q = "01" AND state_q = DELAY else -- channel 1, reg_b
				x"C800" when chan_sel_q = "10" AND state_q = DELAY else -- channel 2, reg_c
				x"CC00" when chan_sel_q = "11" AND state_q = DELAY else -- channel 3, reg_d
				SDI_q(14 downto 0) & '0' when state_q = SCLK_LOW4  else -- shift out MSbit
				SDI_q;                                                  -- o/w keep current value
	--
	-- SDO wil come in during the last 16 sclk pulses.
   --	ADC expects data to be registered at falling edge of SCLK which for us is the rising edge of the SCLK_LLOW3 state
	SDO_d <= SDO_q(14 downto 0) & '0'     when state_q = SCLK_LOW3 and sclk_counter_q <= x"0F" else -- first 16 ticks, shift in zeros to reset the buffer
	         SDO_q(14 downto 0) & ADC_SDO when state_q = SCLK_LOW3 and sclk_counter_q >= x"10" else -- last 16 ticks, read in data
				SDO_q;                                                                                 -- o/w hold register value		
	--
	-- ready bit will pulse HI when a given channel has clocked all bits
	readyREG_d(0) <= '1' when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "00" else '0';
	readyREG_d(1) <= '1' when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "01" else '0';
	readyREG_d(2) <= '1' when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "10" else '0';
	readyREG_d(3) <= '1' when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "11" else '0';			
	--
	--
	-- When data is ready, update the corresponding register. we need to invert it and add x8000 to convert to 2's complement
	regAd <= NOT(SDO_q) + x"8000" when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "00" else regAq;
	regBd <= NOT(SDO_q) + x"8000" when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "01" else regBq;
	regCd <= NOT(SDO_q) + x"8000" when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "10" else regCq;
	regDd <= NOT(SDO_q) + x"8000" when state_q = SCLK_LOW4 and sclk_counter_q = x"1F" and chan_sel_q = "11" else regDq;
	--
	--
	--===========================================================================================================================
	-- Module Outputs
	--===========================================================================================================================
	ADC_SDI <= SDI_q(15);
	ADC_CSn <= '1' when state_q = INIT OR state_q = DELAY else '0';
	ADC_SCK <= '0' when state_q = SCLK_LOW1 OR state_q = SCLK_LOW2 OR state_q = SCLK_LOW3 OR state_q = SCLK_LOW4 else '1'; -- keep hi if not in use
	reg_a   <= STD_LOGIC_VECTOR(regAq);
	reg_b   <= STD_LOGIC_VECTOR(regBq);
	reg_c   <= STD_LOGIC_VECTOR(regCq);
	reg_d   <= STD_LOGIC_VECTOR(regDq);
	-- data is truly ready at falling edge of ready pulse
	ready_a <= readyREG_q(0); 
	ready_b <= readyREG_q(1);
	ready_c <= readyREG_q(2);
	ready_d <= readyREG_q(3);
	--
	--
end architecture;