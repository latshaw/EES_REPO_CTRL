-- JAL 11/9/21
-- DAQ Module:
--	Goal is to interface with the AD7606B ADC on the C1841 PCB and
--  determine what data is written to onchip memory during an event.
-- 
-- 5/2/22, JAL, updates for reset and take/done buffers

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;
--for xilinx
Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY DAQ IS 
		generic(genric_clkrate : UNSIGNED(31 downto 0) := x"07735940"); -- how many clock ticks make 1 second (not used?)
				 -- sample_rate_div  : UNSIGNED(15 downto 0) := x"61A8");  -- set adc sample rate based on clock/sample_rate_div, default is 5kHz
		PORT(
		clock 	: IN  STD_LOGIC;   -- main clock
		reset_n  : IN  STD_LOGIC;   -- active low reset
		TAKE		: IN  STD_LOGIC;   -- active high trigger to indicate that data should be saved to buffer on 8k buffer
		TAKE_4k  : IN  STD_LOGIC;   -- active high trigger to indicate that data should be saved to buffer on 4k buffer
		DONE		: OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 8k buffer
		DONE_4k  : OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 4k buffer
		ADDR		: IN  reg13_array; -- requested read address 8k buffer
		DATA		: OUT reg16_array; -- data at memeory location (to be sent over UDP module) 8k buffer
		READY		: OUT STD_LOGIC;   -- New data writtent to buffer is ready
		ADDR_4k  : IN  reg11_array; -- data at memeory location (to be sent over UDP module) 4k buffer
		DATA_4k  : OUT reg16_array; -- New data writtent to buffer is ready 4k buffer
		offset_addr : IN STD_LOGIC_VECTOR(12 downto 0);   -- offset address, how many samples after a trigger should be saved (0 means all samples are per trigger, F's-1 all samples after trigger)
		offset_addr_4k : IN STD_LOGIC_VECTOR(10 downto 0);
		ADC_EN	: IN	STD_LOGIC;
		sample_rate_div : IN UNSIGNED(30 downto 0);
		-- ADC signals
		adc_busy : IN  STD_LOGIC;
		nCONVST	: OUT STD_LOGIC;
		nCS		: OUT STD_LOGIC;
		SCLK		: OUT STD_LOGIC;
		SDO_A		: IN  STD_LOGIC;
		SDO_B		: IN  STD_LOGIC;
		sync_reg : OUT STD_LOGIC_VECTOR(15 downto 0) -- used only to verify offset delay timing, current value of channel 0.
	);
END DAQ;

ARCHITECTURE DAQ OF DAQ IS 

component AD7606B IS
	generic(genric_clkrate : UNSIGNED(31 downto 0) := x"07735940"; 
			  generic_half_spi_rate  : UNSIGNED(3 downto 0) := x"1");
	PORT
	(
		clock 	: IN STD_LOGIC;  -- clock should match clock rate generic
		reset_n  : IN STD_LOGIC;  -- active low reset
		go			: IN STD_LOGIC;  -- pulse HI to initiated conversion process
		adc_busy : IN STD_LOGIC;  -- signal from ADC indicating ADC is busy with conversion
		nCONVST	: OUT STD_LOGIC;
		nCS		: OUT STD_LOGIC;
		SCLK		: OUT STD_LOGIC;
		SDO_A		: IN  STD_LOGIC;	
		SDO_B		: IN  STD_LOGIC;	
		V1			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V2			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V3			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V4			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V5			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V6			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V7			: OUT STD_LOGIC_VECTOR(15 downto 0);
		V8			: OUT STD_LOGIC_VECTOR(15 downto 0);
		busy 		: OUT std_logic								-- busy can be tied back to input for continous adc sampling
	);
END COMPONENT;


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

COMPONENT ram_2 IS -- 4k memory block (using intel M20k blocks)
		PORT(
		clock 	: IN  STD_LOGIC;  
		WREN		: IN  STD_LOGIC;
		ADDR_w	: IN  UNSIGNED(10 downto 0);     -- NOTE, different address width than the 8k, fewer registers
		ADDR_r	: IN  STD_LOGIC_VECTOR(10 downto 0);
		DATA_in	: IN  STD_LOGIC_VECTOR(15 downto 0);
		DATA_out	: OUT STD_LOGIC_VECTOR(15 downto 0)
	);
END COMPONENT;

signal v_buffer, chn_stable, chn_stable_4k  : reg16_array;



attribute noprune: boolean;
attribute noprune of chn_stable : signal is true;
attribute noprune of chn_stable_4k : signal is true;

signal adc_samp  : STD_LOGIC;
signal adc_go    : STD_LOGIC;
signal adc_re_trigger : STD_LOGIC;

signal AD7606B_busy, busy, WREN, WREN_4k : STD_LOGIC;
signal busy_d : STD_LOGIC_VECTOR(2 downto 0); -- delayed busy signal
attribute noprune of busy_d : signal is true; -- JAL 8/25/22

signal addr_counter, addr_freeze, addr_freeze_mux : UNSIGNED(12 downto 0);
signal addr_counter_4k, addr_freeze_4k, addr_freeze_4k_mux : UNSIGNED(10 downto 0);
	
signal freeze_4k, freeze_8k : STD_LOGIC;
	
signal take_pulse, take_pulse_4k, t_save, max_sample :STD_LOGIC;
	
signal state      : STD_LOGIC_VECTOR(3 downto 0);
signal state_next : STD_LOGIC_VECTOR(3 downto 0);

signal clock_counter : UNSIGNED(31 downto 0); -- will help produce SPI clock and determine when to sample SDO bits
signal spi_track     : UNSIGNED( 3 downto 0); -- will determine which tick of the SPI clock we are currently on (tick 0 to 15)
signal v_track       : UNSIGNED( 3 downto 0); -- will determine which ADC we are sampling (register v#)

signal mem_state, mem_state_4k, take_state_8k, take_state_4k : STD_LOGIC_VECTOR(3 downto 0);
signal ADDR_SEL : reg13_array;
signal ADDR_SEL_4k : reg11_array;


signal TAKE_8k_d, TAKE_8k_q, TAKE_8k_bit, refresh_CB_done_8k : STD_LOGIC;
signal TAKE_4k_d, TAKE_4k_q, TAKE_4k_bit, refresh_CB_done_4k : STD_LOGIC;

signal var_offset_4k, var_offset_8k : UNSIGNED(15 downto 0);
signal var_offset_4k_std, var_offset_8k_std : STD_LOGIC_VECTOR(15 downto 0);

signal sample_rate_div_b : UNSIGNED(30 downto 0);
--
BEGIN 
--===================================================
-- Notes and Terminology
--===================================================
-- The ADC is continously being sampled with adc_re_trigger signal.
-- the adc_samp signal is used to only save adc signals at a set rate (5, 20 kHz for example)
--
--===================================================
-- ADC Sample Rate
--===================================================
-- Determine ADC sample rate
-- note the sample_rate_div signal
--
    -- added buffer to help with timing
	process (clock, reset_n, sample_rate_div)
		begin
			if (reset_n = '0')then
                sample_rate_div_b <= "000" & x"00061A8";
			elsif clock'event and clock = '1' then		
                sample_rate_div_b <= sample_rate_div;
				end if; -- end rising edge
	end process;
--
	process (clock, reset_n, sample_rate_div_b)
		variable count    : UNSIGNED(31 downto 0)  := (others => '0'); -- main counter
		variable rate 	   : UNSIGNED(30 downto 0)  := (others => '0'); -- buffer for the moduel input sample_rate_div_b
		--variable rate_comp: UNSIGNED(30 downto 0)  := (others => '0'); -- signal for comparison
		begin
			if (reset_n = '0')then
				count    := (others => '0');
				adc_samp <= '0';	
				rate := "000" & x"00061A8";
				--rate_comp := '0' & sample_rate_div_b;
				--
			elsif clock'event and clock = '1' then		
					-- check to see if the input clock rate is too fast (faster than 25 Mhz)
					--rate_comp := '0' & sample_rate_div_b;
					-- if so, set rate to 5Khz rate. This makes 5kHz the default.
					IF sample_rate_div_b <= "000" & x"0001388" THEN
						rate := "000" & x"00061A8";
					ELSE
						rate := sample_rate_div_b;
					END IF;
					
					 IF    (count >= rate) THEN	
					--IF    (count >= x"000061A8") THEN	
						count    := (others => '0');
						adc_samp <= '1';	-- pulse high
					ELSE
						count := count + 1;
						adc_samp <= '0';
					END IF;
				end if; -- end rising edge
	end process;
	--
	--
	-- pulse stretch for the adc go
	process (clock, reset_n)
		variable stretch   :  UNSIGNED(3 downto 0)  := (others => '0');
		begin
			--
			if (reset_n = '0')then
				stretch    := (others => '0');
			elsif clock'event and clock = '1' then					
					stretch := stretch(2 downto 0) & adc_samp;
			end if; -- end rising edge
			--
			if ((ADC_EN='1') AND ((stretch(0)='1')OR(stretch(1)='1')OR(stretch(2)='1')OR(stretch(3)='1'))) THEN
				adc_go <= '1';
			else
				adc_go <= '0';
			end if;
			--
	end process;
-------
--===================================================
--  AD7606B Inst.
--===================================================
-- note that channels number is mapped differently than adc v registers
-- from the DAQ.v modules perspective, channelsmatch PCB schmatic
	AD7606B_inst : AD7606B
	generic map (generic_half_spi_rate=>x"3")
	PORT MAP (
		clock 	=> clock 	,
		reset_n  => reset_n  ,
		go			=> adc_re_trigger,--adc_go	,
		adc_busy => adc_busy ,
		nCONVST	=> nCONVST	,
		nCS		=> nCS		,
		SCLK		=> SCLK		,
		SDO_A		=> SDO_A		,
		SDO_B		=> SDO_B		,
		V1			=> v_buffer(0), -- flip order if using BNC boards
		V2			=> v_buffer(1),
		V3			=> v_buffer(2),
		V4			=> v_buffer(3),
		V5			=> v_buffer(4),
		V6			=> v_buffer(5),
		V7			=> v_buffer(6),
		V8			=> v_buffer(7),	
		busy		=> AD7606B_busy);
	--
	-- busy pulse will determine when data is stable and may be written
	-- to memory. The busy is delayed 2 cycles to ensure data is stable
	-- and to allow for rising edge detection.
	process (clock)
		begin
			if clock'event and clock = '1' then			
				busy_d <= busy_d(1 downto 0) & AD7606B_busy;
			end if;
	end process;
	-- use this with WREN
	busy <= '1' when ((busy_d(0)='1')OR(busy_d(1)='1')OR(busy_d(2)='1')) else '0';
	--
	-- AD7606B_busy = 0 means that the module is ready for the next 'go' pulse.
	-- this will cause us to sample the adc as fast as possible.
	
	--adc_re_trigger <= NOT(AD7606B_busy);
	
	
	
	-- register take bit
	process(clock, reset_n)
	begin
	   if reset_n='0' then
            TAKE_4k_q <= '0';
       elsif clock'event and clock = '1' then
            TAKE_4k_q <= TAKE_4k;
        end if;
	end process;
	
	process(clock, reset_n)
	begin
	   if reset_n='0' then
            TAKE_8k_q <= '0';
       elsif clock'event and clock = '1' then
            TAKE_8k_q <= TAKE;
        end if;
	end process;
	
	 
	-- keep the take bits value until in the done state
	-- after we are in the done state, wait until registered take goes low before setting the take_bit back to low
   PROCESS (clock, reset_n, TAKE_4k_q, mem_state_4k)
   BEGIN
		IF (reset_n = '0') THEN 
			take_state_4k    <= x"0";
      ELSIF (clock'event AND clock = '1') THEN
         CASE take_state_4k is
                when x"0"   => 
                    if TAKE_4k_q = '1' then
                        take_state_4k <= x"1";
                    else
                        take_state_4k <= x"0";
                    end if;
                when x"1"   => 
                    if mem_state_4k = x"4" then
                        take_state_4k <= x"2";
                    else
                        take_state_4k <= x"1";
                    end if;
                when x"2"   => 
                    if TAKE_4k_q = '1' then
                        take_state_4k <= x"2";
                    else
                        take_state_4k <= x"0";
                    end if;
                when others => 
                    take_state_4k <= x"0";
			end CASE;
		END  IF; -- end rising edge
	END PROCESS;
	
	-- now with the 8k buffer TAKE
   PROCESS (clock, reset_n, TAKE_8k_q, mem_state)
   BEGIN
		IF (reset_n = '0') THEN 
			take_state_8k    <= x"0";
      ELSIF (clock'event AND clock = '1') THEN
         CASE take_state_8k is
                when x"0"   => 
                    if TAKE_8k_q = '1' then
                        take_state_8k <= x"1";
                    else
                        take_state_8k <= x"0";
                    end if;
                when x"1"   => 
                    if mem_state = x"4" then
                        take_state_8k <= x"2";
                    else
                        take_state_8k <= x"1";
                    end if;
                when x"2"   => 
                    if TAKE_8k_q = '1' then
                        take_state_8k <= x"2";
                    else
                        take_state_8k <= x"0";
                    end if;
                when others => 
                    take_state_8k <= x"0";
			end CASE;
		END  IF; -- end rising edge
	END PROCESS;
	
	-- wait for 4k adc sampels to refresh the circular buffer between take
	-- commands. Will reset with a reset command or whenever the take_4k signal
	-- goes from HI to LOW
	-- NOTE THIS IS REALLY A 2k BUFFER
	--
    PROCESS (clock, reset_n, TAKE_4k_q)
        variable refresh_counter_4k : UNSIGNED(15 downto 0);
        variable last_take_4k : STD_LOGIC;
    BEGIN
        IF (reset_n = '0') or (TAKE_4k_q = '0' AND last_take_4k = '1') THEN 
            refresh_CB_done_4k <= '0';
            refresh_counter_4k := (others => '0');
        ELSIF (clock'event AND clock = '1' AND adc_samp='1') THEN
            if refresh_counter_4k >= x"0800" then
                refresh_counter_4k := x"3FFF"; -- some high value, arbitrary
                refresh_CB_done_4k <= '1';
            else
                refresh_counter_4k := refresh_counter_4k + 1;
                refresh_CB_done_4k <= '0';
            end if;
        -- for rising edge catch
        last_take_4k := TAKE_4k_q;
        END  IF; -- end rising edge
    END PROCESS;
    --
    --
    --
    PROCESS (clock, reset_n, TAKE_8k_q)
        variable refresh_counter_8k : UNSIGNED(15 downto 0);
        variable last_take_8k : STD_LOGIC;
    BEGIN
        IF (reset_n = '0') or (TAKE_8k_q = '0' AND last_take_8k = '1') THEN 
            refresh_CB_done_8k <= '0';
            refresh_counter_8k := (others => '0');
        ELSIF (clock'event AND clock = '1' AND adc_samp='1') THEN
            if refresh_counter_8k >= x"2000" then
                refresh_counter_8k := x"3FFF"; -- some high value, arbitrary
                refresh_CB_done_8k <= '1';
            else
                refresh_counter_8k := refresh_counter_8k + 1;
                refresh_CB_done_8k <= '0';
            end if;
        -- for rising edge catch
        last_take_8k := TAKE_8k_q;
        END  IF; -- end rising edge
    END PROCESS;
    --
    --
    -- Only allow main state machine to see the take bit after the buffer
    -- has been refreshed
    TAKE_4k_bit <= '0' when take_state_4k=x"0" OR refresh_CB_done_4k='0' else '1';
    --TAKE_8k_bit <= '0' when take_state_8k=x"0" OR refresh_CB_done_8k='0' else '1';
    
    --JAL 11/7/23
    TAKE_8k_bit <= '1' when TAKE_8k_q = '1' else '0';
    
	--
	--
	--
	--must allow for at least 1.25 u sec between conversions
	-- this block adds a trigger delay between conversions of 1.280 u sec
	process(clock, AD7606B_busy, reset_n)
	   variable trigger_delay : UNSIGNED(15 downto 0);
	begin
	   if AD7606B_busy = '1' or reset_n='0' then
	       trigger_delay := (others => '0');
	       adc_re_trigger <= '0';
       elsif clock'event and clock = '1' then
             if trigger_delay >= x"00A0" then
                trigger_delay := x"03FF";
                adc_re_trigger <= '1';
             else
                trigger_delay := trigger_delay + 1;
                adc_re_trigger <= '0';
             end if;
        end if;
	end process;
	
	
	--
	-- whenever the adc has new data and NOT during a adc_samp event, we will save it to chn_stable.
	-- in this way, we do not need to worry about the adc data changing during the mem_state writes.
	--
	-- for 8k data
	process (clock, reset_n)
		begin
			if reset_n='0' then
				chn_stable <= (others => x"0000");
			elsif clock'event and clock = '1' then	
				IF (AD7606B_busy = '0' AND mem_state=x"0" AND adc_samp='0') THEN
					chn_stable <= v_buffer;
				END IF;
			end if;
	end process;
	--
	-- for 4k data
	process (clock, reset_n)
		begin
			if reset_n='0' then
				chn_stable_4k <= (others => x"0000");
			elsif clock'event and clock = '1' then	
				IF (AD7606B_busy = '0' AND mem_state_4k=x"0" AND adc_samp='0') THEN
					chn_stable_4k <= v_buffer;
					-- only used for verifying offset timing delay
					sync_reg <= v_buffer(0);
					
				END IF;
			end if;
	end process;
	--
-------
--===================================================
--  Memory Bank
--===================================================
-- This module will continue to sample the ADC and write data to the memory block at a specific rate (see generics).
-- If EPICS issues a TAKE to be HI, then the memory bank (for all buffers) will be written. Once all 8k values are 
-- written, then this module will issue a DONE command (set it HI). No new values will be written to memory.
-- EPICS may then write to the ADDR(I) value and read the contents. When finished, EPICS can pull the TAKE to LOW
-- which will essentially reset the state machine. 
-- 
--
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
	--
	--
	var_offset_8k_std <= "000" & offset_addr;
	var_offset_8k <= UNSIGNED(var_offset_8k_std);
	-- main state machine for writing data to on chip memory
	PROCESS (clock, reset_n, TAKE_8k_bit)
		variable var_addr : UNSIGNED(15 downto 0); -- JAL 11/7/23, changed bit length to 15 downto 0
   BEGIN
		IF (reset_n = '0') THEN 
			mem_state    <= x"0";
			addr_counter <= (others => '0');
			var_addr := (others => '0'); -- JAL 11/7/23 changed to reset at 0
			addr_freeze <= (others => '0');
			freeze_8k <= '0';
      ELSIF (clock'event AND clock = '1') THEN
         CASE mem_state is
					when x"0"   => -- wait for next sample
						IF (adc_samp='1') THEN
							mem_state <= x"1";
							addr_counter <= addr_counter + 1;
						ELSE
							mem_state <= x"0";
						END IF;
						--
					when x"1"   => -- take check/addr increment/addr save
					    --
					    IF (TAKE_8k_bit='0') THEN 
							mem_state <= x"2";
							 addr_freeze <= (var_offset_8k(12 downto 0) + addr_counter + 2);
							 var_addr := (others => '0'); -- JAL 11/7/23 
						ELSE
						    IF freeze_8k = '0' then
						      freeze_8k <= '1';
						      addr_freeze <= (var_offset_8k(12 downto 0) + addr_counter + 2);
						    end if;
                            IF (var_addr >= var_offset_8k) THEN
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
						mem_state <= x"0"; -- else, keep sampling
						--
					when others => -- DONE, stay in this state until EPICS sets TAKE to LOW
						--
						IF (TAKE_8k_bit='0') THEN -- reset signals/vars
							mem_state    <= x"0";
							addr_counter <= (others => '0');
							var_addr     := (others => '0');  -- JAL 11/7/23 
							freeze_8k <= '0';
							addr_freeze <= (others => '0');
						ELSE
							mem_state <= x"4"; -- else, allow epics to slowly offload data, stay in this state
						END IF;
						--
			end CASE;
		END  IF; -- end rising edge
	END PROCESS;
	--
	-- 
	-- combinational
	DONE <= '1' when (mem_state=x"4") else '0';
	WREN <= '1' when ((mem_state=x"2") OR (mem_state=x"3")) else '0';
	--
	--
	GEN_RAM: 
   for I in 0 to 7 generate
		-- registered mux for address selection (might be helpful for debugging)
		PROCESS (clock)
		BEGIN
			IF (reset_n = '0') THEN 
				ADDR_SEL(I) <= (others => '0');
			ELSIF (clock'event AND clock = '1') THEN
				IF (mem_state=x"4") THEN -- If in DONE state
					ADDR_SEL(I) <= STD_LOGIC_VECTOR(addr_freeze+UNSIGNED(ADDR(I)));
				--ELSE
				--	ADDR_SEL(I) <=  STD_LOGIC_VECTOR(addr_counter);
				END IF;
			END IF;
		END PROCESS;
		--inst ram 8k ram block
		ram_8_inst : ram_8
			PORT MAP(
			clock 	=>	 CLOCK, 
			WREN		=>  WREN,
			ADDR_w	=>  addr_counter,
			ADDR_r	=>  ADDR_SEL(I),
			DATA_in	=>	 chn_stable(I),
			DATA_out	=>  DATA(I));
	end generate GEN_RAM;
--
--
--===================================================
--  Mem bank for 4k buffer 
--===================================================
-- note, this logic will be very similar to the 8k buffer but with address changes to support 4k addressing (12 bit)
--
--Catch the rising edge of the Trigger
	PROCESS (clock)
		variable tlast : STD_LOGIC;
   BEGIN
      IF (clock'event AND clock = '1') THEN
         take_pulse_4k <= NOT(tlast) AND TAKE_4k;
			tlast := TAKE_4k;
      END IF;
	END PROCESS;
	--
	--
	--
	var_offset_4k_std <= "00000" & offset_addr_4k;
	var_offset_4k <= UNSIGNED(var_offset_4k_std);
	
	-- main state machine for writing data to on chip memory
	PROCESS (clock, reset_n, TAKE_4k_bit)
		variable var_addr : UNSIGNED(15 downto 0);
   BEGIN
		IF (reset_n = '0') THEN 
			mem_state_4k    <= x"0";
			addr_counter_4k <= (others => '0');
			var_addr := (others => '0');
			addr_freeze_4k <= (others => '0');
			freeze_4k <= '0';
      ELSIF (clock'event AND clock = '1') THEN
         CASE mem_state_4k is
					when x"0"   => 
						IF (adc_samp='1') THEN
							mem_state_4k <= x"1";
							addr_counter_4k <= addr_counter_4k + 1;
						ELSE
							mem_state_4k <= x"0";
						END IF;
						--
					when x"1"   =>  
					   --
						IF (TAKE_4k_bit='0') THEN 
							mem_state_4k <= x"2";
							--addr_freeze_4k <= (others => '0');
							 addr_freeze_4k <= (var_offset_4k(10 downto 0) + addr_counter_4k + 2);
						ELSE
--						    if freeze_4k = '0' then
--                                freeze_4k      <= '1';
--                                addr_freeze_4k <= (var_offset_4k(10 downto 0) + addr_counter_4k);
--							end if;
							IF (var_addr >= var_offset_4k) THEN
								mem_state_4k <= x"4";
							ELSE
								-- continue to sample ADC until buffer fills up the offset
								mem_state_4k <= x"2";
								var_addr := var_addr + 1;
							END IF;
						END IF;
						--
					when x"2"   => -- WEN (1 of 2)
						--
						mem_state_4k <= x"3";
						--
					when x"3"   => -- WEN (2 of 2), 
						--
					    mem_state_4k <= x"0"; -- keep sampling
						--
					when others => -- DONE, stay in this state until EPICS sets TAKE to LOW
						--
						IF (TAKE_4k_bit='0') THEN -- reset signals/vars
							mem_state_4k    <= x"0";
							addr_counter_4k <= (others => '0');
							var_addr     := (others => '0');
							freeze_4k <= '0';
							addr_freeze_4k <= (others => '0');
						ELSE
							mem_state_4k <= x"4"; -- else, allow epics to slowly offload data, stay in this state
						END IF;
						--
			end CASE;
		END  IF; -- end rising edge
	END PROCESS;
	--
	--
	--
	-- 
	-- combinational
	DONE_4k <= '1' when (mem_state_4k=x"4") else '0';
	WREN_4k <= '1' when ((mem_state_4k=x"2") OR (mem_state_4k=x"3")) else '0';
	--
	--
	GEN_RAM_2k: 
   for I in 0 to 7 generate
		-- registered mux for address selection (might be helpful for debugging)
		PROCESS (clock)
		BEGIN
			IF (reset_n = '0') THEN 
				ADDR_SEL_4k(I) <= (others => '0');
			ELSIF (clock'event AND clock = '1') THEN
				IF (mem_state_4k=x"4") THEN -- If in DONE state
					ADDR_SEL_4k(I) <= STD_LOGIC_VECTOR(addr_freeze_4k+UNSIGNED(ADDR_4k(I)));
				--ELSE
				--	ADDR_SEL_4k(I) <=  STD_LOGIC_VECTOR(addr_counter_4k);
				END IF;
			END IF;
		END PROCESS;
		--inst ram 4k ram block
		ram_2_inst : ram_2
			PORT MAP(
			clock 	=>	 CLOCK, 
			WREN		=>  WREN_4k,
			ADDR_w	=>  addr_counter_4k,
			ADDR_r	=>  ADDR_SEL_4k(I),
			DATA_in	=>	 chn_stable_4k(I),
			DATA_out	=>  DATA_4k(I));
	end generate GEN_RAM_2k;
-------
--===================================================
--  
--===================================================
-------
END DAQ;