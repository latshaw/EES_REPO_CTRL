-- JAL, 12/15/2020
-- This module will handle arc buffer shift registers for LLRF 3.0 interlocks f/w
-- JAL, 2/24/22
-- Major updates to incorporate circular buffers
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;

ENTITY arc_buffer_module IS
	generic(n : integer := 256); 
	PORT(clock 	: IN  STD_LOGIC;      -- main clock
		  reset_n  : IN  STD_LOGIC;    -- active low reset
		  TAKE		: IN  STD_LOGIC;   -- active high trigger to indicate that data should be saved to buffer on 8k buffer
		  DONE		: OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 8k buffer
		  ADDR		: IN  STD_LOGIC_VECTOR(12 downto 0); -- requested read address 8k buffer
		  DATA		: OUT STD_LOGIC_VECTOR(15 downto 0); -- data at memeory location (to be sent over UDP module) 8k buffer
		  ADC_DATA  : IN  STD_LOGIC_VECTOR(15 downto 0); -- data from ADC (what is loaded into the circular buffer)
		  READY		: OUT STD_LOGIC;   -- Not needed
		  adc_busy  : IN  STD_LOGIC; -- from adc to indicate that the adc is 'busy' fetching new data.
		  offset_addr : IN STD_LOGIC_VECTOR(12 downto 0));   -- offset address, how many samples after a trigger should be saved (0 means all samples are at trigger, F's-1 all samples after trigger)
END ENTITY arc_buffer_module; 

ARCHITECTURE BEHAVIOR OF arc_buffer_module IS


COMPONENT ram_8 IS -- 8k memory block (using intel M20k blocks)
		PORT(
		clock 	: IN  STD_LOGIC;  
		WREN		: IN  STD_LOGIC;
		ADDR_w	: IN  UNSIGNED(12 downto 0);
		ADDR_r	: IN  STD_LOGIC_VECTOR(12 downto 0);
		DATA_in	: IN  STD_LOGIC_VECTOR(15 downto 0);
		DATA_out	: OUT STD_LOGIC_VECTOR(15 downto 0)
	);
END COMPONENT;

signal v_buffer, chn_stable, chn_stable_4k  : STD_LOGIC_VECTOR(15 downto 0);

attribute noprune: boolean;
attribute noprune of chn_stable : signal is true;

signal adc_samp  : STD_LOGIC;
signal adc_go    : STD_LOGIC;
signal adc_re_trigger : STD_LOGIC;

signal busy, WREN : STD_LOGIC;
signal busy_d : STD_LOGIC_VECTOR(2 downto 0); -- delayed busy signal

signal addr_counter, addr_freeze, addr_freeze_mux : UNSIGNED(12 downto 0);
	
signal take_pulse, t_save, max_sample :STD_LOGIC;
	
signal state      : STD_LOGIC_VECTOR(3 downto 0);
signal state_next : STD_LOGIC_VECTOR(3 downto 0);

signal clock_counter : UNSIGNED(31 downto 0); -- will help produce SPI clock and determine when to sample SDO bits
signal spi_track     : UNSIGNED( 3 downto 0); -- will determine which tick of the SPI clock we are currently on (tick 0 to 15)
signal v_track       : UNSIGNED( 3 downto 0); -- will determine which ADC we are sampling (register v#)

signal mem_state : STD_LOGIC_VECTOR(3 downto 0);
signal ADDR_SEL  : STD_LOGIC_VECTOR(12 downto 0);

signal freeze, freeze_pulse : STD_LOGIC;

SIGNAL var_offset_step : STD_LOGIC_VECTOR(15 downto 0);
SIGNAL var_offset		  : UNSIGNED(15 downto 0);

BEGIN
--
-- convert input offset into unsigne

var_offset_step <= "000" & offset_addr(12 downto 0);
var_offset      <= UNSIGNED(var_offset_step);
--
--===================================================
-- ADC Sample Rate
--===================================================
-- Determine ADC sample rate
-- fixed sample rate
-- 
	process (clock, reset_n)
		variable count    : UNSIGNED(31 downto 0)  := (others => '0'); -- main counter
		variable rate 	   : UNSIGNED(31 downto 0)  := (others => '0'); -- sample rate
		begin
			if (reset_n = '0')then
				count    := (others => '0');
				adc_samp <= '0';	
				rate := x"00000341";   -- 150.060024 kHz
				--rate := x"00001388"; -- 25 kHz
			   --rate := x"000061A8"; -- 5 kHz
				--
			elsif clock'event and clock = '1' then		
					rate := x"00000341";   -- 150.060024  kHz
					--rate := x"00001388"; -- 25 kHz
					--rate := x"000061A8"; -- 5 kHz
					--
					IF    (count >= rate) THEN	
						count    := (others => '0');
						adc_samp <= '1';	-- pulse high
					ELSE
						count := count + 1;
						adc_samp <= '0';
					END IF;
				end if; -- end rising edge
	end process;
-------
--===================================================
--  getting data from external ADC module
--===================================================
	-- for 8k data
	-- only save stable data to circaul buffer. When adc is not busy, data is satable.
	process (clock, reset_n)
		begin
			if reset_n='0' then
				chn_stable <= (others => '0');
			elsif clock'event and clock = '1' then	
				IF (adc_busy = '0' AND mem_state=x"0" AND adc_samp='0') THEN
					chn_stable <= ADC_DATA;
				END IF;
			end if;
	end process;
	--
-------
--===================================================
--  Memory Bank
--===================================================
   -- Goal is to save adc samples to a circular buffer at a specified rate. When a adc_sample pulses is HI, the stable
	-- ADC data will be saved to the circular buffer. The buffer will continue to fill and overwrite itself until
	-- EPICS issues a TAKE bit (or a fault is present). Then the buffer will continue to sample the number of samples
	-- specified by offset_addr and then the buffer will freeze. The DONE bit will go HI and no new data will be written
	-- to the ciruclar buffer. This allows EPICS to read the circular buffer over UDP. 
	-- When EPICS is done reading, it can set the TAKE bit to LOW or clear the fault and the circular buffer will resume
	-- sampling data until another TAKE/FAULT event occur.
	--
	-- If offset_addr is set to all 0's, the circular buffer will freeze as soon as a fault occurs (all data is before the fault event).
	-- If offset_addr is set to N, the circular buffer will sample N adc_samp periods (some data is before and some data is after the fault).
	-- ARC has 500 micro second pulses and when adc_samp period set to 150 kHz (ADC sampels faster than this but we are putting it on the circular buffer at this rate)
	-- then set offset = xFFF or 4095 to have the pulse appear in the middle of the 8k buffer view.
	-- 
	-- Catch the rising edge of the Trigger
	PROCESS (clock)
		variable tlast : STD_LOGIC;
   BEGIN
      IF (clock'event AND clock = '1') THEN
         take_pulse <= NOT(tlast) AND TAKE;
			tlast := TAKE;
      END IF;
	END PROCESS;
	--
	-- address freeze: mux that feeds into register. New values updated whenever we have a takepulse
	-- addr_counter: 
	-- main state machine for writing data to on chip memory
	PROCESS (clock, reset_n)
		variable var_addr : UNSIGNED(15 downto 0);
   BEGIN
		IF (reset_n = '0') THEN 
			mem_state    <= x"0";
			addr_counter <= (others => '0');
			var_addr := (others => '0');
			--addr_freeze <= (others => '0');
			freeze <= '0';
      ELSIF (clock'event AND clock = '1') THEN
			--
			--
         CASE mem_state is
					when x"0"   => -- wait for next sample
						--
						IF (adc_samp='1') THEN
							mem_state <= x"1";
							addr_counter <= addr_counter + 1;
						ELSE
							mem_state <= x"0";
						END IF;
						--
					when x"1"   => 
						-- simple check for take bit
						IF TAKE = '0' THEN
							mem_state <= x"2";
							var_addr := (others => '0');
						ELSE
							-- init the address freeze
							freeze <= '1';
							IF (var_addr >= var_offset) THEN
								mem_state <= x"4";
							ELSE
								-- continue to sample ADC until buffer fills up the offset
								mem_state <= x"2";
								var_addr := var_addr + 1;
							END IF;
							--							
						END IF;						
						--
					when x"2"   => -- WEN (1 of 2)
						--
						mem_state <= x"3";
						--
					when x"3"   => -- WEN (2 of 2), 
						--
						mem_state <= x"0"; -- keep sampling
						--
					when others => -- DONE, stay in this state until EPICS sets TAKE to LOW
						--
						IF (TAKE='0') THEN -- reset signals/vars
							mem_state    <= x"0";
							addr_counter <= (others => '0');
							var_addr     := (others => '0');
							freeze       <= '0';
						ELSE
							mem_state <= x"4"; -- else, allow epics to slowly offload data, stay in this state
						END IF;
						--
			end CASE;
		END  IF; -- end rising edge
	END PROCESS;
	--
	-- 
	--
	-- Freeze rising edge detection
	-- finds freeze_pulse
	--
	PROCESS (clock)
		variable f_last : STD_LOGIC;
   BEGIN
      IF (clock'event AND clock = '1') THEN
         freeze_pulse <= NOT(f_last) AND freeze;
			f_last := freeze;
      END IF;
	END PROCESS;
	--
	PROCESS (clock, freeze)
   BEGIN
      IF (freeze='0')THeN
			addr_freeze <=  (others => '0');
		ELSIF (clock'event AND clock = '1') AND (freeze_pulse = '1') THEN
			addr_freeze <= (var_offset(12 downto 0) + addr_counter);
      END IF;
	END PROCESS;
	--
	--
	--
	-- combinational
	DONE        <= '1' when (mem_state=x"4") else '0';
	WREN        <= '1' when ((mem_state=x"2") OR (mem_state=x"3")) else '0';
	--
	--
	--
	-- registered mux for address selection (might be helpful for debugging)
	PROCESS (clock)
	BEGIN
		IF (reset_n = '0') THEN 
			ADDR_SEL <= (others => '0');
		ELSIF (clock'event AND clock = '1') THEN
			--IF (mem_state=x"4") THEN -- If in DONE state
				ADDR_SEL <= STD_LOGIC_VECTOR(addr_freeze+UNSIGNED(ADDR));
			--END IF;
		END IF;
	END PROCESS;
	--inst ram 8k ram block
	ram_8_inst : ram_8
		PORT MAP(
		clock 	=>	 CLOCK, 
		WREN		=>  WREN,
		ADDR_w	=>  addr_counter,
		ADDR_r	=>  ADDR_SEL,
		DATA_in	=>	 chn_stable,
		DATA_out	=>  DATA);
-------
--===================================================================
END ARCHITECTURE;