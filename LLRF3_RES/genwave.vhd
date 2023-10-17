-- JAL 2/22/23
-- genWave, INTEL Specific module is used to make signals available over the network.
-- this module will sample the input signal and pass it into a buffer
-- this module uses M20k memory blocks. As it is targeted for C10GX.

-- How to use as a circular buffer in scope mode:
-- set mode to 1.
-- keep trigger bit low (don't use it)
--
-- How to use as a circular buffer to capture an event (fault mode):
-- set mode to 0.
-- pulse trigger high only when the event occurs.
--
-- in both modes, when the done flag is set, the desired data is in the buffer, ready to be accessed by the controller (EPCIS/python scripts).
--
-- How to interface with external controller (EPICS)
-- When EPICS sees done as high, it should initiate a take bit, read the frozen buffer contents, and then set take to low when finished.
-- the done bit will go low while epics is reading the buffer. The done bit will stay low even after the take bit goes low.
-- The buffer will re-fill at this time and when the buffer is ready the done signal will go hi again and the cycle repeats

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;

ENTITY genWave IS 
		GENERIC (
			K    : integer := 4095; -- set to a multiple of 2, default is for 4k
			mode : integer := 1; -- set to 1 to be in scope mode and 0 to be in fault mode. Must be 1 or 0.
			N    : integer := 11; -- set to 9 for 1k, 10 for 2k, 11 for 4k, 12 for 8k, etc
			div  : integer := 15 -- sample clock bit length (sampel clock is at rate clock_rate/2**div)
		);
		PORT(
		clock 	 : IN  STD_LOGIC;   -- main clock
		reset_n   : IN  STD_LOGIC;   -- active low reset
		sample_in : IN  STD_LOGIC_VECTOR(31 downto 0); -- input sample data, this is the data that you want to sample
		take      : IN  STD_LOGIC;   -- active high trigger to indicate that data should be saved to buffer on 4k buffer
		trigger   : IN  STD_LOGIC;   -- trigger inidcates that the buffer should freeze (in absence of a take bit). Useful for capturing fault data.
		done      : OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 4k buffer
		addr      : IN  STD_LOGIC_VECTOR(31 downto 0); -- data at memeory location (to be sent over UDP module) 4k buffer, 12 bit address for 4k
		dataout   : OUT STD_LOGIC_VECTOR(31 downto 0)  -- New data writtent to buffer is ready 4k buffer)
	);
END genWave;

ARCHITECTURE genWave OF genWave IS 

attribute noprune: boolean;

--please give smart inputs to generics
signal addr_counter, addr_counter_off : UNSIGNED(N downto 0); -- N+1 should be how many bits you need to read every address
TYPE mem IS ARRAY(0 TO K) OF UNSIGNED(31 DOWNTO 0); -- K should be the max address of your circular buffer
signal fill_limit : UNSIGNED(15 downto 0);

SIGNAL ram_block : mem; 
attribute ramstyle : string;
attribute ramstyle of ram_block : signal is "M20K";
				
signal sample_rate_count, sample_edge : UNSIGNED(div downto 0);
signal sample_clk : STD_LOGIC; -- when goes high, we want to sample the sample_in singal
signal sample_in_buffer : STD_LOGIC_VECTOR(31 downto 0);

signal wen_pulse, take_1, take_2, trigger_1, trigger_2, hold_trigger, hold_take, hold, clear, T1 : std_logic;
signal s, s_next : std_logic_vector(1 downto 0);
signal fill_count, fill_count_next : UNSIGNED(15 downto 0);

signal wenstate, holdstate : STD_LOGIC_VECTOR(2 downto 0);

signal mainstate : STD_LOGIC_VECTOR(3 downto 0);

attribute noprune of addr_counter : signal is true;
attribute noprune of addr_counter_off : signal is true;
attribute noprune of sample_rate_count : signal is true;
attribute noprune of sample_in_buffer : signal is true;
attribute noprune of wen_pulse : signal is true;
attribute noprune of fill_count : signal is true;
attribute noprune of fill_count_next : signal is true;
attribute noprune of hold_trigger : signal is true;
attribute noprune of hold_take : signal is true;
--attribute noprune of sample_clk : signal is true;

--
BEGIN 
--===================================================
-- Notes and Terminology
--===================================================
--
--	              ________...__
-- sample_clk  _/             \____
--	                 _
-- wen_pulse   ____/ \_______   
-- sample in:   ^registered
-- adddr++  :   ^registered
-- write to ram:    ^write happens here
--===================================================
-- Sample enable control
--===================================================
-- clock is at 125 MHz rate (8ns ticks)
-- coutner will roll over, will divide clock by 128 to get it close to 1 MHz (125M/128 ~= 976kHz)
-- JAL, 3/22/23, changed to 15 bit counter, should get 4k waveform to be about 1 second view.
	process (clock)
		begin
			if clock'event and clock = '1' then		
					sample_rate_count <= sample_rate_count + 1;
			end if; 
	end process; 
	--
	-- sample_en 
	sample_clk <= sample_rate_count(div);
	--WEN pulse, lasts for multiple fast clock pulses. The address and input data are kept stable at this time
	--wen_pulse  <= '1' when (sample_rate_count(14) = '1' AND hold = '0') else '0'; -- will stobe hi after the rising edge of sample_clk and for multiple fast clock tics.
--===================================================
-- buffer input signal at the rising edge of sample_clock
--===================================================

	process (clock)
		begin
			if clock'event and clock = '1' then
					addr_counter_off <= addr_counter + UNSIGNED(addr(N downto 0));
			end if; 
	end process;
	
	-- whe MSbit is HI and all others are low, this is the condiiton for sample rising edge
	sample_edge(div) <= '1';
	sample_edge(div-1 downto 0) <= (others => '0');
	
	-- will make fill limit based on the buffer size
	-- 1k -> x"03FF", 2k -> x"07FF", 4k -> x"0FFF", 8k -> x"1FFF"
	fill_limit(15 downto N+1) <= (others => '0');
	fill_limit(N downto 0)    <= (others => '1');
	
	
--===================================================
-- TAKE and DONE
--===================================================
-- DONE goes HI, when buffer is ready to take
-- scope mode: when TAKE goes HI, frezze the buffer
-- fault mode: when TAKE goes HI, buffer is still frozen at the time of the trigger event
--
--               ___________                  ________
-- DONE ..._____/           \__________...___/
--
--	                       ____...___
-- TAKE  ________________/          \___________
--
--              ^ Ready to offload data to EPICS/Controller. 
--                       ^ EPICS/controller requests to take data.
--                                   ^ EPICS/controller is done taking data
--                                           ^ Buffer is ready for next offload by EPICS OR a trigger fault has occured
--
-- flip flops, always enabled
	process(clock)
	begin
		if clock'event and clock = '1' then
		   --
			--
			case mainstate is
			when "0000" => -- Idle
				take_1     <= take;
				trigger_1  <= trigger;
				--
				if ((take = '1' AND take_1 = '0') OR (trigger = '1' AND trigger_1 = '0')) then
					-- go into branch 2
					mainstate <= "1000";
				elsif (sample_rate_count = sample_edge) then
					-- go into branch 1
					mainstate <= "0010";
				else
					-- else, wait for trigger or new sample
					mainstate <= "0000";
				end if;
			--================================================ branch 1, write enable handler
			when "0010" => -- branch 1: address ++
				addr_counter <= addr_counter + 1;
				mainstate <= "0011";
			when "0011" => -- branch 1: sample in buffer
				sample_in_buffer <= sample_in;
				mainstate <= "0100";
			when "0100" => -- branch 1: no-op
				mainstate <= "0101";
			when "0101" => -- branch 1: WEN HI
				mainstate <= "0110";
			when "0110" => -- branch 1: WEN HI
				mainstate <= "0111";
			when "0111" => -- branch 1: WEN LOW
				mainstate <= "0000"; -- next, back to IDLE
			--================================================ branch 2, offload waveform
			when "1000" => -- branch 2: wait for clear
				take_1     <= take;
				trigger_1  <= trigger;
				if (take = '0' AND take_1 = '1') then
					mainstate <= "1001";
				else
					mainstate <= "1000";
				end if;
				fill_count <= (others => '0');
			when "1001" => -- branch 2: wait for refill
				if (fill_count >= fill_limit) then
					mainstate <= "1011";
				else
					fill_count <= fill_count + 1;
					mainstate <= "1001";
				end if;
			when "1011" => -- branch 2: done
				mainstate <= "0000";
			when others =>
				mainstate <= "0000";
			end case;
			
		end if;
	end process;
	
	--perform write of sample_in_buffer at address addr_counter
	wen_pulse <= '1' when ((mainstate="0101") OR (mainstate="0110")) else '0';
	
	--perform read when a controller TAKE is asserted
	hold <= '1' when ((mainstate="1000") OR (mainstate="1001") OR (mainstate="1011")) else '0';
	
	--only one of these generates will be used.
	scope_mode_done : if mode = 1 generate
								done <= '0' when ((mainstate="1000") OR (mainstate="1001") OR (mainstate="1011"))  else '1';
						  end generate scope_mode_done;
	fault_mode_done : if mode = 0 generate
								done <= '1' when mainstate="1000" else '0';
						  end generate fault_mode_done;
	

--===================================================
--  Mem bank for buffer 
--===================================================
-- ram block
	PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (wen_pulse='1') THEN -- if write enable
            ram_block(to_integer(addr_counter)) <= UNSIGNED(sample_in_buffer);
         END IF;
			-- for reading
			if hold = '1' then
				dataout <= STD_LOGIC_VECTOR(ram_block(to_integer(addr_counter_off)+1));
			end if;
      END IF;
	END PROCESS;
	--moved assignment to outside of process. Note that this is outside of process. note that the address is registered.
	--dataout <= STD_LOGIC_VECTOR(ram_block(to_integer(addr_counter_off)));
-------
END genWave;
























