-- Original code by Rama
-- Latshaw modified on 7/17/2020 to support LLRF 3.0 system
-- NOTES:
-- DIR = 0 is defined as positive steps and DIR = 1 is negative steps (for signed step) 
-- code modified so that we no longer need the divider circuit/module
--
-- 3/12/21, updated for 25 Mhz clock
--				incorporated decel approximation (same as velocity)
--

-- NOTE: 10/31/22, I want to add +1 to input steps in future release. OR change stepcount = (steps-1) to >= operator.





-- TO DO, make sure we are waiting for TMC configuration to be done before doing movements

library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.components.all;

-- updated 10/20/2020, port map was in a different order in motion control (changed to match)
entity stepper_driver is
	 generic (testBench : STD_LOGIC := '0');-- 1 to use as test bench, 0 otherwise
	 PORT(reset     : IN STD_LOGIC;
	 clock          : IN STD_LOGIC;
	 direction      : IN STD_LOGIC; -- DIR_OUT, from data_select
	 dir_flip		 : IN STD_LOGIC; -- flips direction input
	 move           : IN STD_LOGIC; -- MOVE_OUT, from data_select
	 done_isa       : IN STD_LOGIC; -- DONE_OUT, from data_select
	 stop           : IN STD_LOGIC; -- STOP, from regs
	 clr_sgn_step   : IN STD_LOGIC; -- clr_sgn_stp, from regs
	 clr_abs_step   : IN STD_LOGIC; -- clr_abs_stp, from regs
	 en_sub_abs     : IN STD_LOGIC; -- en_sub_abs, from regs
	 en_sub_sgn     : IN STD_LOGIC; -- en_sub_sgn, from regs
	 accel_in       : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- accel, from regs
	 period         : IN STD_LOGIC_VECTOR(26 DOWNTO 0); -- quotient(I), from step_gen generate
	 steps_in       : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- STEPS_OUT, from data_select
	 sub_stp        : IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- abs_stp_sub, from regs
	 vlcty_in       : IN STD_LOGIC_VECTOR(31 DOWNTO 0); -- vlcty, from regs
	 spi_hs_in      : IN STD_LOGIC;  -- SPI updated handshake in
	 spi_hs_out     : OUT STD_LOGIC; -- SPI updated handshake out
	 step           : OUT STD_LOGIC; -- step_buffer (to board outputs)
	 dir            : OUT STD_LOGIC; -- ldir (to board output and regs)
	 motion_led     : OUT STD_LOGIC; -- motion (to board output and regs
	 done_move      : OUT STD_LOGIC; -- DONE_MOVE to regs and fcc_data_acq_fiber_control
	 abs_step       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- abs_steps, to regs
	 accum_NA       : OUT STD_LOGIC_VECTOR(12 DOWNTO 0); -- denom(I), to step_gen generate
	 clkrate_NA     : OUT STD_LOGIC_VECTOR(26 DOWNTO 0); -- numer(I), to step_gen generate
	 laccel         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- laccel, to regs
	 lsteps         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- lsteps, to regs
	 lvlcty         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- lvlcty, to regs
	 sgn_step       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- sgn_steps, to regs
	 step_count_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- step_count, to regs
	 rate_reg       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
);
end entity stepper_driver;		 

architecture behavior of stepper_driver is



--absolute step counter (with subtraction option) module
component abs_step_module is
port(	clock				: in  std_logic;
		reset			   : in  std_logic;
		count_en       : in  std_logic;
		sub_in			: in  std_logic_vector(15 downto 0);
		abs_step_in		: in  std_logic_vector(31 downto 0);
		abs_step_out	: out std_logic_vector(31 downto 0)
	);
end component;


signal sub_stp32 : STD_LOGIC_VECTOR(31 downto 0);
signal accel32 : STD_LOGIC_VECTOR(31 downto 0);
signal vel32 : STD_LOGIC_VECTOR(31 downto 0);
signal rate32 : STD_LOGIC_VECTOR(31 downto 0);
signal steps32 : STD_LOGIC_VECTOR(31 downto 0);
signal clkrate32 : STD_LOGIC_VECTOR(31 downto 0);

signal accum, double_accel   : STD_LOGIC_VECTOR(12 downto 0); -- changed to signal
signal clkrate : STD_LOGIC_VECTOR(26 downto 0); -- changed to signal

signal en_accel             			: std_logic;
signal accel							: UNSIGNED(31 downto 0);

signal en_vlcty						: std_logic;
signal vlcty							: UNSIGNED(31 downto 0);

signal en_steps						: std_logic;
signal steps							: UNSIGNED(31 downto 0);

signal abs_step_int					: UNSIGNED(31 downto 0);
signal en_abs_steps					: std_logic;
--signal clr_abs_steps					: std_logic;

--signal clr_sgn_step				: std_logic;
signal en_sgn_steps					: std_logic;
signal sgn_step_in					: UNSIGNED(31 downto 0);
--signal sgn_step					: std_logic_vector(31 downto 0);	

signal motion_led_int				: std_logic;		

signal clr_accum_accel				: std_logic;
signal en_accum_accel				: std_logic;
signal en_accum_accel_temp			: std_logic;
signal accum_accel_in				: UNSIGNED(31 downto 0);
signal accum_accel					: UNSIGNED(31 downto 0);

signal clr_ramp_steps				: std_logic;
signal en_ramp_steps					: std_logic;
signal ramp_steps						: UNSIGNED(31 downto 0);

signal en_precipice_steps			: std_logic;
signal precipice_steps				: UNSIGNED(31 downto 0);

signal clr_step_count				: std_logic;
signal en_step_count					: std_logic;
signal step_count						: UNSIGNED(31 downto 0);
signal step_count_lag				: UNSIGNED(31 downto 0); -- same as step count but it is '1' count lagging

signal clr_step_count_isa			: std_logic;
signal en_step_count_isa			: std_logic;
signal step_count_isa_in			: UNSIGNED(31 downto 0);

signal clr_period_count				: std_logic;
signal en_period_count				: std_logic;
signal period_count					: UNSIGNED(31 downto 0);

signal half_steps						: UNSIGNED(31 downto 0);
signal step_odd						: UNSIGNED(31 downto 0);
signal step_temp						: UNSIGNED(31 downto 0);

signal temp1							: UNSIGNED(31 downto 0);
signal temp2							: UNSIGNED(31 downto 0);
signal accum_accel_temp				: UNSIGNED(31 downto 0);
signal sel1								: std_logic;
signal sel2								: std_logic;
signal temp_num						: UNSIGNED(31 downto 0);

signal rst_done_move					: std_logic;
signal en_done_move					: std_logic;

signal done_buf						: std_logic;
signal done_buf1						: std_logic;
signal done_buf2						: std_logic;
signal done_pulse, NOT_done_pulse: std_logic;
--signal done_pulse2    	    		: std_logic;

signal pulse_on_perd					: std_logic;
signal pulse_perd						: std_logic;
signal steps_end						: std_logic;
signal holding							: std_logic;
signal deceling						: std_logic;
signal acceling						: std_logic;
signal ramp_steps_zero				: std_logic;
signal count_half_step_even		: std_logic;
signal count_half_step_odd			: std_logic;

signal dir_mux							: std_logic;

signal abs_step_in_std32         : STD_LOGIC_VECTOR(31 downto 0); --JAL, 9/6/23
signal abs_step_in					: UNSIGNED(31 downto 0);
signal abs_step_in_int				: UNSIGNED(31 downto 0);

signal sgn_step_in_int1				: UNSIGNED(31 downto 0);
signal sgn_step_in_int2				: UNSIGNED(31 downto 0);

signal sgn_stp_dir 					: UNSIGNED(31 downto 0);
signal sgn_step_int 					: UNSIGNED(31 downto 0);

type state_type is (IDLE, LOAD, PULSE_ON, PULSE_OFF, PERIOD_TRACK, OP_MODE, ACCEL_MODE, DECEL_MODE, HOLD_MODE, RESULT, DONE);
signal STATE, lastState					: state_type;

type profile_mode_type is (OP_ACCEL, OP_HOLD, OP_DECEL);
signal profile_mode : profile_mode_type;

signal mul_result : UNSIGNED(44 downto 0); --use for period check

signal PULSE_ON_cnt : UNSIGNED(7 downto 0);
signal RATE_ACCM : UNSIGNED(31 downto 0);  -- rate accumulator. Used to measure a period of time between rate changes. In this case, when the rate_accm is 'full' then the rate should increase.
signal PERIOD_ACCM : UNSIGNED(31 downto 0); --period accumulator. Used to measure a period of time between steps. In this case, when the period_accm is 'full' then a PULSE_ON should occur ( a micro step should occur).

signal rate : UNSIGNED(31 downto 0);

----------end of signals for motor------------------------- 

signal one								: std_logic;
signal zeros							: UNSIGNED(31 downto 0);

begin
	--=================================================
	-- Clock Rate Generates for test bench mode
	--=================================================
--		gen_clk_tb : if testBench = '1' generate
--			-- in test bench mode, run much faster for modelsim simulations
--			---faster clock
--			clkrate	<=  "000" & x"000200"; -- adds a 1000 time scale
--		end generate gen_clk_tb;
--		--
--		gen_clk_normal : if testBench = '0' generate
--			-- normal clock
--			---this is 125,000,000 clock cycles @ 125M tics = 1 sec, dependent on frequency of operation
--			clkrate	<=  "111" & x"735940";
--			---this is 100,000,000 clock cycles @ 100M tics = 1 sec, dependent on frequency of operation
--			--clkrate	<=  "101" & x"F5E100";
--		end generate gen_clk_normal;

   clkrate	<=  "111" & x"735940";
	clkrate32 <= "00000" & clkrate;
		
	--
   -- Constants
	one		<= '1';	
	zeros		<= (others => '0');
	--clkrate	<=  "100" & x"C4B400"; -----this is 80,000,000 clock cycles @ 80MHz = 1 sec, dependent on frequency of operation
	-- FOR TESTING
	--clkrate	<=  "000" & x"002710"; -- decimal 10000, interpret this as 10000 clock cycles per step cycle
	--
   --======================================================================================================================
	-- Detect Done pulse (look for rising edge)
	--======================================================================================================================
	done_buf_i: latch_n
		  port map(clock 	=> clock,
					  reset 	=> reset,
					  clear	=> one,
					  en 		=> one,
					  inp 	=> done_isa,
					  oup 	=> done_buf
					 );
	--			
	done_buf1_i: latch_n
			  port map(clock 	=> clock,
						  reset 	=> reset,
						  clear	=> one,
						  en 		=> one,
						  inp 	=> done_buf,
						  oup 	=> done_buf1
						 );
	--			
	done_buf2_i: latch_n
			  port map(clock 	=> clock,
						  reset 	=> reset,
						  clear	=> one,
						  en 		=> one,
						  inp 	=> done_buf1,
						  oup 	=> done_buf2
						 );
	--	This is used to clear the FLIP FLOPS that save laccel, lvlcty, lsteps and dir
	done_pulse <= done_buf2 and not done_buf1;

	-- to help with routing, this done pulse can be delayed.
--	process(clock, done_pulse)
--	begin
--		if clock = '1' then	
--			done_pulse2 <= done_pulse;
--		end if;
--	end process;	
--	
	--
	--======================================================================================================================
	-- Loaded values (laccel, lvlcty, lsteps and dir)
	--======================================================================================================================
	NOT_done_pulse <= not done_pulse; -- to support modelsim simulation, can't use NOT in portmap
	accel_reg: regneUNSIGNED generic map(n => 32)
						 port map (clock	=> clock,
									  reset	=> reset,
									  clear	=> NOT_done_pulse,
									  en	  	=> en_accel,---this value of acceleration gets loaded in LOAD state
									  input  => accel_in,
									  output => accel
									 );
	--						
	vlcty_reg: regneUNSIGNED generic map(n => 32)
						 port map (clock	=> clock,
									  reset	=> reset,
									  clear	=> NOT_done_pulse,
									  en	  	=> en_vlcty,---this value of velocity gets loaded in LOAD state
									  input  => vlcty_in,
									  output => vlcty
									 );
	--						
	steps_reg: regneUNSIGNED generic map(n => 32)
						 port map (clock	=> clock,
									  reset	=> reset,
									  clear	=> NOT_done_pulse,
									  en	  	=> en_steps,---this value of steps gets loaded in LOAD state
									  input  => steps_in,
									  output => steps
									 );
	--	

	-- JAL 7/27/21, added a dir_flip mux which will allow the direction bit to be flipped.
	-- this is to help account for a possible cable issues which has the sine/cosine swapped.
	-- We will adjust dir_flip to acheive the below desired motion:
	-- direction = 0, stepper moves CW , negative steps
	-- direction = 1, stepper moves CCW, positive steps
	--
	-- Note: changed 'direction' to dir_mux in state machine logic.
	-- dir is the last direction. This reports back the assigned direction value (regardless of dir flip bit).
	-- dir also goes to motor to control the direction.
	
	dir_mux <= direction when dir_flip = '0' else NOT(direction);
	
	dir_ff: latch_n
			  port map(clock 	=> clock,
						  reset 	=> reset,
						  clear	=> NOT_done_pulse,
						  en 		=> '1',
						  inp 	=> dir_mux, 
						  oup 	=> dir		-- this becomes ldir which is the last direction of motion.
													-- this bit also goes to motor to control direction.
						 );
			 
				 
	--enable for loaded values and DIR latch					 
	en_accel		<= '1' when STATE = LOAD else '0';						
	en_vlcty		<= '1' when STATE = LOAD else '0';
	en_steps		<= '1' when STATE = LOAD else '0';
	-- Outputs of module (saved values)
	laccel	<= STD_LOGIC_VECTOR(accel);
	lvlcty	<= STD_LOGIC_VECTOR(vlcty);
	lsteps	<= STD_LOGIC_VECTOR(steps);
	--
	--======================================================================================================================
	-- Absolute Step Value counter (with subtraction option)
   --======================================================================================================================	
	-- JAL 9/6/23, modified to supput absolute step subtraction
	inst_abs_step : abs_step_module
	port map(
			clock			=> clock,         -------------------- local bus clock, assumed 125 MHz
			reset			=> clr_abs_step,  -------------------- active low reset (clears step counter)
			count_en    => en_abs_steps,  -------------------- enable an increment
			sub_in		=> STD_LOGIC_VECTOR(sub_stp),     -- decrement by this value about once per second (if no steps during timing interval)
			abs_step_in	=> STD_LOGIC_VECTOR(abs_step_int),  -- current register value
			abs_step_out=> abs_step_in_std32);  -- resulting value to be saved

	--sub_stp32 <= x"0000" & sub_stp; -- decrement value will never be negative
	--abs_step_in_int <= abs_step_int - UNSIGNED(sub_stp32);
   --
	--abs_step_in <= abs_step_in_int when en_sub_abs = '1' and  abs_step_in_int(31) = '0' else
	--					x"00000000" when en_sub_abs = '1' and  abs_step_in_int(31) = '1' else
	--					abs_step_int + 1;
   --
	abs_step_reg_0: regneUNSIGNED generic map(n => 32)---tracking total number of steps
						  	   port map (clock  	=> clock,
										    reset	=> reset,
									       clear	=> one,
									       en	   => one, -- was en_abs_steps, changed to always be enabled (increment/decrement handled by submodule now)
									       input   => abs_step_in_std32,-- was STD_LOGIC_VECTOR(abs_step_in), now is a 32 bit std logic vector
									       output  => abs_step_int
								         );		
	-- add one to this value any time we pulse, if en_sub_abs is enabled, subtract sub_steps (for each second) never go neg.
	abs_step <= STD_LOGIC_VECTOR(abs_step_int);	
   --	
	--======================================================================================================================
	-- Signed Step Counter (with subtraction option)
	--======================================================================================================================
	sgn_step_reg_0: regneUNSIGNED generic map(n => 32)
						  	   port map (clock  	=> clock,
										    reset	=> reset,
									       clear	=> clr_sgn_step,
									       en	   => en_sgn_steps,
									       input   => STD_LOGIC_VECTOR(sgn_step_in),
									       output  => sgn_step_int
								         );										
	sgn_step <= STD_LOGIC_VECTOR(sgn_step_int);
	sgn_step_in_int1 <= sgn_step_int - UNSIGNED(sub_stp32);
	sgn_step_in_int2 <= sgn_step_int + UNSIGNED(sub_stp32);
	-- logic 'subtracts' values fromt he signed step coutner wheenver en_sub_sgn is hi, otherwise is increments when dir = 0
	-- or decrements when dir = 1.										
	sgn_step_in <= sgn_step_in_int1   when (en_sub_sgn = '1' and sgn_step_in_int1(31) = '0' and sgn_step_int(31) = '0') else
						x"00000000"        when (en_sub_sgn = '1' and sgn_step_in_int1(31) = '1' and sgn_step_int(31) = '0') else
						sgn_step_in_int2   when (en_sub_sgn = '1' and sgn_step_in_int2(31) = '1' and sgn_step_int(31) = '1') else
						x"00000000"        when (en_sub_sgn = '1' and sgn_step_in_int2(31) = '0' and sgn_step_int(31) = '1') else
						sgn_step_int + 1 when dir_mux = '0'   and motion_led_int = '1'                                   else
						sgn_step_int - 1 when dir_mux = '1'   and motion_led_int = '1'                                   else
						x"00000000";
	--
	--
	--
	--======================================================================================================================
	-- Main State Machine (controls pulses and timing between pulses)
	--======================================================================================================================
	-- TMC2660 chip must have on/off pulses > 105 ns + 62.5 ns so legacy 250 ns value is acceptabe
	-- Note: The minimum pulse off time that this State Machine will produce (for a maximum velocity value) is 244.2 ms
	--signal accel32 : STD_LOGIC_VECTOR(31 downto 0);
	--signal vel32 : STD_LOGIC_VECTOR(31 downto 0);
	--signal steps32 : STD_LOGIC_VECTOR(31 downto 0);
	

	-- profile_mode (OP_ACCEL, OP_HOLD, OP_DECEL)
	

	-- this values are shifted by 2 (equivalent to a multiplication by 4) to take into account the 4 states that occur between incrementations.
	-- accel, vlcty are 32 bit UNSIGNED
	accel32 <= STD_LOGIC_VECTOR(accel(29 downto 0)) & "00";
	vel32   <= STD_LOGIC_VECTOR(vlcty(29 downto 0)) & "00";
	rate32   <= STD_LOGIC_VECTOR(rate(29 downto 0)) & "00";
	
	process(clock, reset, stop)
	begin
		if(reset = '0' or stop = '1') then
			STATE          <= IDLE;
			PULSE_ON_cnt   <= (others => '0');
			RATE_ACCM 		<= (others => '0');
			PERIOD_ACCM		<= (others => '0');
			profile_mode	<= OP_ACCEL;
			rate           <= x"00000001"; -- default rate
			--
		elsif(clock = '1' and clock'event) then
				--
				--
				case STATE is
					when LOAD		=>	--====LOAD============================================================
						-- accel, vlcty, steps will be registered in this state.
						profile_mode	<= OP_ACCEL;
						-- wait until spi_hs_in goes HI before moving on
						if spi_hs_in = '1' then
							STATE       <= PULSE_ON;
						else
							STATE       <= LOAD;
						end if;
						PULSE_ON_cnt   <= (others => '0');
						RATE_ACCM 		<= (others => '0');
						PERIOD_ACCM		<= (others => '0');
						rate           <= x"00000001"; -- default rate
						--											
					when PULSE_ON	=>	--====PULSE_ON========================================================
						-- Will send a pulse to stepepr driver chip to move the motor one micro step. The duration
						-- of this pulse will be 32*8 ns. Chip requires minimum on/off time 167.5 ns.
						if PULSE_ON_cnt >= x"32" then
							STATE <= PERIOD_TRACK;
							PULSE_ON_cnt   <= x"7F";
						else
							STATE <= PULSE_ON;
							PULSE_ON_cnt <= PULSE_ON_cnt + 1;
						end if;
						RATE_ACCM   <= RATE_ACCM + 1;
						PERIOD_ACCM <= x"00000020"; -- resets the period accumulator starts at the begining of this state. This state lasts for 32 clock ticks.
						--
					when PERIOD_TRACK	=>	--====PERIOD_TRACK=================================================
						-- rate accumulaotr is used to track when the current rate should be increased.
						-- when this accumulator is 'full' the rate will be incremented by 1. This is a ramping up of the rate set by the acceleration.
						STATE <= OP_MODE;
						RATE_ACCM   <= RATE_ACCM   + UNSIGNED(accel32);
						PERIOD_ACCM <= PERIOD_ACCM + UNSIGNED(rate32);
						PULSE_ON_cnt   <= (others => '0');
						--	
					when OP_MODE	=>	--====OP_MODE=========================================================
						-- depending on which profile_mode is selected, this will determine what action is take in this state and which of the
						-- 3 paralle states that will be taken.
						case profile_mode is
							when OP_HOLD  => 
								-- if in holding mode, set rate to velocity.
								rate         <= vlcty;
								STATE        <= HOLD_MODE;
							when OP_DECEL => 
								if RATE_ACCM >= UNSIGNED(clkrate32) then -- in deceleration mode, if rate_accum is full, then decrement rate and reset this accumulator.
									-- rate should never go less then 1 in deceleration mode
									if rate >= 2 then
										rate   <= rate - 1;
									else
										rate  <= x"00000001";
									end if;
									RATE_ACCM <=  (others => '0');
							  end if;
							  STATE     <= DECEL_MODE;
							when others   => -- ACCEL
							  if RATE_ACCM >= UNSIGNED(clkrate32) then -- in acceleration mode, if rate_accum is full, then increment rate and reset this accumulator.
									rate      <= rate + 1;
									RATE_ACCM <=  (others => '0');
							  end if;
							  STATE     <= ACCEL_MODE;
						end case;
						PULSE_ON_cnt   <= (others => '0');
						--	
					when ACCEL_MODE	=>	--====ACCEL_MODE=================================================== (1 of 3 parallel states)
						-- if the rate has increased to the point it is GTE the commanded velocity, then switch to holding mode.
						if rate >= vlcty then 
							profile_mode <=  OP_HOLD;
					   else
							profile_mode <=  OP_ACCEL;
					   end if;
						STATE          <= RESULT;
						PULSE_ON_cnt   <= (others => '0');
						--	
					when HOLD_MODE	=>	--====HOLD_MODE======================================================= (2 of 3 parallel states)
						-- When the moved number of steps + the number of steps needed to decelerate is GTE
						-- to the total number of steps, begin to decelerate
						if precipice_steps >= steps then 
							profile_mode <=  OP_DECEL;
					   else
							profile_mode <=  OP_HOLD;
					   end if;
						STATE          <= RESULT;
						PULSE_ON_cnt   <= (others => '0');
						--	
					when DECEL_MODE	=>	--====DECEL_MODE=================================================== (3 of 3 parallel states)
						-- We stay stuck in this mode until we have completed the motors movement.
						profile_mode <=  OP_DECEL;
						STATE          <= RESULT;
						PULSE_ON_cnt   <= (others => '0');
						--	
					when RESULT	=>	--====RESULT=============================================================
						--
						if step_count >= steps then
							STATE <= DONE;
						elsif PERIOD_ACCM >= UNSIGNED(clkrate32) then 
							STATE <= PULSE_ON;
						else
							STATE <= PERIOD_TRACK;
						end if;						
						PULSE_ON_cnt   <= (others => '0');
						--	
					when DONE   	=>	--====DONE============================================================
						--
						profile_mode	<= OP_ACCEL;
						STATE          <= IDLE;
						PULSE_ON_cnt   <= (others => '0');
						RATE_ACCM 		<= (others => '0');
						PERIOD_ACCM		<= (others => '0');
						--
					when OTHERS		=> --====IDLE============================================================
						-- when a move command is given and the done buffer has been cleared
						if move = '1' and done_buf2 = '0' then
							STATE          <= LOAD;
						else
							STATE          <= IDLE;
						end if;
						profile_mode	<= OP_ACCEL;
						PULSE_ON_cnt   <= (others => '0');
						RATE_ACCM 		<= (others => '0');
						PERIOD_ACCM		<= (others => '0');
						--				
				end case;
			end if;	
	end process;
	--
	--
	--
	-- SPI handshake out will go HI whenever we are in the load state.
	-- This will start a handshake process with another module which will check to see if the SPI settins are up to date.
	-- spi_hs_in will go HI when the TMC chip's commanda are up to date.
	-- The stepper driver state machine will wait for an spi_hs_in to go HI before proceeding to the next state.
	spi_hs_out <= '1' when STATE = LOAD else '0';
	--
	--
	--
	--======================================================================================================================
	-- Process to increment step counter
	--======================================================================================================================	
	--process to increment step counter
	-- Note: step_count_lag is 'one behind' step_count
	process(clock)
	begin
		if(clock = '1' and clock'event) then
			if (reset = '0' or stop = '1' or STATE = LOAD) then
				step_count     <= (others => '0');
				step_count_lag <= (others => '1');
			else
				if (en_step_count = '1') then
					step_count     <= step_count + 1;
					step_count_lag <= step_count_lag + 1;
				end if;
			end if;
		end if;
	end process;	
	--
	-- only enable once ber on pulse.
	en_step_count <= '1' when STATE = PULSE_ON and PULSE_ON_cnt = 1 else '0';
	en_sgn_steps  <= '1' when STATE = PULSE_ON and PULSE_ON_cnt = 1 else '0';
	en_abs_steps  <= '1' when STATE = PULSE_ON and PULSE_ON_cnt = 1 else '0';
	step_count_out <= STD_LOGIC_VECTOR(step_count); -- for output, this is the 'live' step progress
	--
	--
	--
	--======================================================================================================================
	-- Process to capture ramp steps
	--======================================================================================================================	
	-- The ramp_steps register is used to record how many steps it took to 'ramp up' to the velocity step rate. We assume
	-- it will take 'close' to this many to ramp back down. The ramp_steps register will increase in accordance with the
	-- step_count register until the main state machine is no longer in the acceleration mode.
	process(clock)
	begin
		if(clock = '1' and clock'event) then	
			if (reset = '0' or stop = '1' or STATE = LOAD) then
				ramp_steps   <= (others => '0');
			else
				if (en_ramp_steps = '1') then
					ramp_steps <= step_count;
				end if;
			end if;
		end if;
	end process;
	--
	--
	en_ramp_steps <= '1' when STATE = ACCEL_MODE else '0';
	--
	--
	--
	--======================================================================================================================
	-- Process to capture precipise steps
	--======================================================================================================================	
	-- The precipice steps register is used to calculate when the state machine should moving into deceleration mode.
	-- when the number of steps it took to get to veloicty + the current number of steps is GTE to the total number of steps,
	-- then the state machien should move into deceleration mode.
	-- The step_count_lag is used instead of step_count. In this way, rampup steps will be greater than or equal to the ramp down.
	-- this is done to prent decelerating to the point were we have a rate of 1.
	process(clock)
	begin
		if(clock = '1' and clock'event) then	
			if (reset = '0' or stop = '1' or STATE = LOAD) then
				precipice_steps   <= (others => '0');
			else
				if (en_precipice_steps = '1') then
					precipice_steps <= step_count_lag + ramp_steps;
				end if;
			end if;
		end if;
	end process;
	--
	--
	en_precipice_steps <= '1' when STATE = OP_MODE else '0';
	--
	--
	--
	--======================================================================================================================
	-- Combinational Logic
	--======================================================================================================================
	
	

	--need to go through and hash these out, some state names have changed thus this combinational logic will also need to be updated! :)
	
	--Notes:
	-- steps_end : 1 whenever all desired steps have been completed, 0 otherwise (including in idle state)
	-- pulse_on_perd : 1 whenever PULSE_ON has been HI for the specified amount of time, otherwise 0
	--
	-- Physical stepper control (and completion feedback)
	step						<= '1' when (STATE = PULSE_ON) else '0'; -- to module output
	--done_move				<= '1' when (STATE = lastState and steps_end = '1') else '0'; -- updated, 7/20/20
	--done_move				<= '1' when (STATE = INIT and lastState = PULSE_OFF and steps_end = '1') else '0'; -- updated 3/4/21 so that it will be a pulse 
	done_move				<= '1' when (STATE = DONE) else '0'; -- updated 3/4/21 so that it will be a pulse 
	-- Enables for steper counters
	-- 10/20/2020 changed the enables to pulse whenever there is a transition from pulse on to pulse off state
	--				  I also removed the reference to en_subtractor.
	--en_sgn_steps			<= '1' when (en_sub_sgn = '1') or (STATE = PULSE_ON and pulse_on_perd = '1') else '0';
	--en_abs_steps 			<= '1' when (en_sub_abs = '1') or (STATE = PULSE_ON and pulse_on_perd = '1') else '0';
	--en_sgn_steps			<= '1' when (STATE = PULSE_OFF and lastState = PULSE_ON) else '0';
	--en_abs_steps 			<= '1' when (STATE = PULSE_OFF and lastState = PULSE_ON) else '0';
	--
	-- LEDss
	--motion_led_int			<= '1' when (STATE = LOAD ) or (STATE = PULSE_ON) or (STATE = PULSE_OFF) else '0';
	motion_led_int			<= '1' when (STATE /= IDLE ) else '0';
	motion_led 				<= motion_led_int; -- To LEDs, module output
	-- This is used for waveforms:
	-- Only pass rate while motor is 'moving' otherwise just pass zeros 
	rate_reg <= STD_LOGIC_VECTOR(rate) when ((STATE /= IDLE) AND (STATE /= LOAD)) else x"00000000";
	-- -- -- -- -- --
	-- End of Module
	-- -- -- -- -- --
end architecture behavior;