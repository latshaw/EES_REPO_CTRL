library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.components.all;

-- Note, 12 GEV version used 16 bit registers
-- 		LLRF 3.0 will be using 32 bit registers (ADDR, DIN, DOUT)
--			Added a new motorCurr for CS on TMC Stepper Driver Chip
--
--			ISA_BUS signals were the legacy way of reading and writing registes. LLRF 3.0
--			will be using SFP modules. thus, if you see a reference to isa_bus, just know 
-- 		it is likely for an SFP module (not ISA).
--	
--			ISA_BUS	SFP		Notes
--			load		rnw		load is write on high, rnw is write on low, thus need load => NOT(rnw)
-- 		addr		
--			din		
--			dout		


entity regs is
		
		PORT(heartbeat : IN STD_LOGIC;  -- heartbeat_sig, form heartbeat_isa
		 clock : IN STD_LOGIC;
		 reset : IN STD_LOGIC;
		 load : IN STD_LOGIC;        -- REGS_LD, from ISA_BUS Module
		 epcs_bsy : IN STD_LOGIC;    -- NO CONNCECT
		 abs_steps : IN reg32_array; -- abs_steps from steppers
		 addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);     --ADDR_OUT (only use lower 12 bits), from ISA_BUS
		 brd_tmp : IN STD_LOGIC_VECTOR(15 DOWNTO 0); --TEMP_DATA (from temp sensor)
		 deta_disc : IN reg2_array;                  -- 3/31/21, connected (controlled by motor_status register)
		 din : IN STD_LOGIC_VECTOR(31 DOWNTO 0);     -- ISA_SD, to ISA_BUS Module & top module (inout)
		 disc_fib : IN reg28_array;                   -- DISC, from fcc_data_acq_fiber_control
		 done_move : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- DONE_MOVE, from steppers and FCC_data_acq_fiber_control
		 dtan_fib : IN reg16_array;                   -- DETA, from fcc_data_acq_fiber_control
		 epcsr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);     -- NO CONNCECT
		 high_limit_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0); --high_limit_in, from module inputs (limit switches)
		 laccel : IN reg32_array;                         -- laccel, from steppers
		 ldir : IN STD_LOGIC_VECTOR(7 DOWNTO 0);          -- ldir, from steppers
		 low_limit_in : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  --low_limit_in, from module inputs (limit switches)
		 lsteps : IN reg32_array;                    -- lsteps, from steppers
		 lvlcty : IN reg32_array;                    -- lvlcty, from steppers
		 motion : IN STD_LOGIC_VECTOR(7 DOWNTO 0);   -- motion, from steppers
		 pzt_val : IN reg16_array;                   --PZ, from fcc_data_acq_fiber_control
		 sgn_steps : IN reg32_array;                 -- sgn_steps, from steppers
		 slow_gdr : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- SLOW_MODE, from fcc_data_acq_fiber_control
		 step_count : IN reg32_array;                -- step_count, from steppers
		 step_en : IN STD_LOGIC_VECTOR(7 DOWNTO 0);  -- 3/31/21, connected (controlled by motor_status register)
		 clear : OUT STD_LOGIC;                      -- reg_res, to resets
		 reconfig : OUT STD_LOGIC;                   -- NO CONNCECT
		 abs_stp_sub : OUT reg16_array;              -- abs_stp_sub, to steppers
		 accel : OUT reg32_array;                    -- accel, to steppers
		 clr_abs_stp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- clr_abs_stp, to steppers
		 clr_sgn_stp : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- clr_sgn_stp, to steppers
		 deta_hi : OUT reg16_array;                      -- DETA_HI, to fcc_data_acq_fiber_control
		 deta_lo : OUT reg16_array;                      -- DETA_LO, to fcc_data_acq_fiber_control
		 dir : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR, to DATA_SELECT
		 dir_flip : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- DIR_flip, flips desired motor direction for both auto and manual modes
		 disc_hi : OUT reg16_array;              --DISC_HI, to fcc_data_acq_fiber_control 
		 disc_lo : OUT reg16_array;              --DISC_LO to fcc_data_acq_fiber_control
		 done_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- DONE, to DATA_SELECT
		 dout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);      -- to REGS_D of ISA_BUS Module
		 en_sub_abs : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- en_sub_abs to steppers 
		 en_sub_sgn : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- en_sub_sgn to steppers
		 epcsa : OUT STD_LOGIC_VECTOR(23 DOWNTO 0);     -- NO CONNCECT
		 epcsc : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);      -- NO CONNCECT
		 epcsd : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      -- NO CONNCECT
		 fib_mode : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);   -- FIB_MODE_IN, to fcc_data_acq_fiber_control
		 inhibit : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);    -- inhibit, enable pins (for steppers)
		 limit : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);      -- limit, to LEDS (for limit switches)
		 low_current : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);-- low_current, low current pins (for steppers)
		 move : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);       -- MOVE, to DATA_SELECT
		 pzt_hi_lmt : OUT reg16_array;                  -- PZT_HI, to fcc_data_acq_fiber_control
		 pzt_lo_lmt : OUT reg16_array;                  -- PZT_LO, to fcc_data_acq_fiber_control
		 motorCurr_OUT   : out reg16_array;             -- TMC Current Sense (only lower 5 bits are used)
		 CHOPCONF_OUT	  : out reg16_array;					-- chopper current setting per channel. added 10/28/22
		 MRES_OUT		  : out reg16_array;					-- microstep resolution, added 10/18/22
		 step_hz : OUT reg32_array;                     -- STEP_HZ, to fcc_data_acq_fiber_control
		 steps : OUT reg32_array;                       -- STEPS, to DATA_SELECT
		 stop : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);       -- STOP, to fcc_data_acq_fiber_control and steppers
		 vlcty : OUT reg32_array;                       -- vlcty, to steppers
		 c10gx_tmp : IN STD_LOGIC_VECTOR(9 downto 0); 	-- internal temp of fpga from ip core
		 out_EEPROM_ctrl   : OUT STD_LOGIC_VECTOR(7 downto  0);  -- bit1 = RNW, bit0 = go
		 out_EEPROM_addr   : OUT STD_LOGIC_VECTOR(11 downto 0); -- 12 bit read address
		 out_EEPROM_data   : OUT STD_LOGIC_VECTOR(7 downto  0);  -- data to write to byte
		 EEPROM_datar      : IN  STD_LOGIC_VECTOR(7 downto  0);  -- data read from byte
		 out_sfp_dataw		 : OUT STD_LOGIC_VECTOR(31 downto 0); -- output from REGS to i2c module
		 sfp_datar		    : IN STD_LOGIC_VECTOR(31 downto 0);  --input from i2c module
		 out_sfp_ctrl   	 : OUT STD_LOGIC_VECTOR(31 downto 0); -- output from REGS to i2c module
		 lb_valid		    : IN STD_LOGIC;
		 rate_reg          : IN  reg32_array;
		 SINE_POS          : IN  reg10_array;
		 jtag_mux_sel_out  : OUT STD_LOGIC_VECTOR(1 downto 0)
--		 out_c_addr		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_cntlr	    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_status        : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_data		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_datar	       : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_en_c_data	    : OUT std_logic
	);

end entity regs;

architecture behavior of regs is



--verilog component
-- used for remote flash and reconfigure
--COMPONENT CYCLONE IS
--	PORT (
--			 lb_clk 		: IN STD_LOGIC;
--			 c10_addr 	: IN STD_LOGIC_VECTOR(31 downto 0);
--			 c10_data 	: IN STD_LOGIC_VECTOR(31 downto 0);
--			 c10_cntlr 	: IN STD_LOGIC_VECTOR(31 downto 0);
--			 c10_status : OUT STD_LOGIC_VECTOR(31 downto 0);
--			 c10_datar  : OUT STD_LOGIC_VECTOR(31 downto 0);
--			 we_cyclone_inst_c10_data : IN STD_LOGIC); 
--END COMPONENT;
--
COMPONENT genWave IS 
		GENERIC (K    : integer := 4;
			      mode : integer := 1;
					N    : integer := 11;
					div  : integer := 15);		
		PORT( clock 	 : IN  STD_LOGIC;   -- main clock
				reset_n   : IN  STD_LOGIC;   -- active low res
				sample_in : IN  STD_LOGIC_VECTOR(31 downto 0);
				take      : IN  STD_LOGIC;   -- active high tr 
				trigger   : IN  STD_LOGIC;   -- trigger inidca
				done      : OUT STD_LOGIC;   -- DONE, lets epi 
				addr      : IN  STD_LOGIC_VECTOR(31 downto 0); 
				dataout   : OUT STD_LOGIC_VECTOR(31 downto 0)
				);
END COMPONENT;
--

signal reset_move_buf			: std_logic;
signal en_move_buf				: std_logic;
signal move_buf					: std_logic_vector(7 downto 0);
signal move_in						: std_logic_vector(7 downto 0);
signal inhibit_en					: std_logic_vector(7 downto 0);
signal en_inhibit_en				: std_logic;
signal inhibit_int				: std_logic_vector(7 downto 0);	

signal en_move_buf1				: std_logic_vector(7 downto 0);
signal move_buf1					: std_logic_vector(7 downto 0);
signal move_buf2					: std_logic_vector(7 downto 0);

signal en_direction_isa			: std_logic;
signal reset_direction_isa		: std_logic;
signal direction_isa				: std_logic_vector(7 downto 0);

signal dir_int						: std_logic_vector(7 downto 0);

signal en_low_current_isa		: std_logic;
signal low_current_en			: std_logic_vector(7 downto 0);
signal low_current_int			: std_logic_vector(7 downto 0);

signal en_accel0_isa				: std_logic_vector(7 downto 0);
signal en_accel1_isa				: std_logic_vector(7 downto 0);
signal accel_isa					: reg32_array;
signal accel_isar					: reg32_array;

signal en_vlcty0_isa				: std_logic_vector(7 downto 0);
signal en_vlcty1_isa				: std_logic_vector(7 downto 0);
signal vlcty_isa					: reg32_array;
signal vlcty_isar					: reg32_array;

signal en_steps0_isa				: std_logic_vector(7 downto 0);
signal en_steps1_isa				: std_logic_vector(7 downto 0);
signal steps_isa					: reg32_array;

signal en_command_motor			: std_logic_vector(7 downto 0);
signal command_motor				: reg16_array; -- JAL 7/27/21 changed from reg13_array to add 'direction flip' bit, changed to 16 bit
signal status_motor				: reg14_array;
signal dir_flip_b					: std_logic_vector(7 downto 0); -- will change all stepper motor directions
signal limit_sw_mask          : std_logic_vector(7 downto 0); -- if HI, will mask out limit switches  
signal dir_flip_int				: std_logic_vector(7 downto 0);

signal en_command					: std_logic;
signal command						: std_logic_vector(15 downto 0);

signal stop_isa_in				: std_logic_vector(7 downto 0);
signal stop_isa_buf				: std_logic_vector(7 downto 0);
signal stop_isa_buf1				: std_logic_vector(7 downto 0);
signal stop_isa_buf2				: std_logic_vector(7 downto 0);
signal stop_isa					: std_logic_vector(7 downto 0);
signal stop_int					: std_logic_vector(7 downto 0);
signal crash						: std_logic_vector(7 downto 0);



signal en_clear_done				: std_logic;
signal clear_done					: std_logic_vector(7 downto 0);
signal done_move_in				: std_logic_vector(7 downto 0);
signal en_crash_isa				: std_logic;

signal status						: std_logic_vector(15 downto 0);

signal clr_done_move				: std_logic_vector(7 downto 0);
signal done							: std_logic_vector(7 downto 0);

signal en_detune					: std_logic_vector(7 downto 0);
signal dtan_isa					: reg16_array;
signal dtan							: reg16_array;

signal limit_isa					: std_logic_vector(7 downto 0);

signal version						: std_logic_vector(15 downto 0);

signal thrt							: std_logic_vector(15 downto 0);

signal one							: std_logic;

signal high_limit_ff1			: std_logic_vector(7 downto 0);
signal high_limit_ff2			: std_logic_vector(7 downto 0);
signal high_limit_ff3			: std_logic_vector(7 downto 0);
signal high_limit_ff4			: std_logic_vector(7 downto 0);
signal high_limit_ff5			: std_logic_vector(7 downto 0);
signal high_limit					: std_logic_vector(7 downto 0);

signal high_limit_pulse			: std_logic_vector(7 downto 0);
signal low_limit_pulse			: std_logic_vector(7 downto 0);

signal clr_high_limit_count	: std_logic_vector(7 downto 0);
signal en_high_limit_count		: std_logic_vector(7 downto 0);
signal high_limit_count			: cnt16_array;

signal low_limit_ff1				: std_logic_vector(7 downto 0);
signal low_limit_ff2				: std_logic_vector(7 downto 0);
signal low_limit_ff3				: std_logic_vector(7 downto 0);
signal low_limit_ff4				: std_logic_vector(7 downto 0);
signal low_limit_ff5				: std_logic_vector(7 downto 0);
signal low_limit					: std_logic_vector(7 downto 0);

signal clr_low_limit_count		: std_logic_vector(7 downto 0);
signal en_low_limit_count		: std_logic_vector(7 downto 0);
signal low_limit_count			: cnt16_array;

signal step_hz_isa				: reg16_array;
signal en_step_hz_isa			: std_logic_vector(7 downto 0);

signal deta_hi_isa				: reg16_array;
signal en_deta_hi_isa			: std_logic_vector(7 downto 0);

signal deta_lo_isa				: reg16_array;
signal en_deta_lo_isa			: std_logic_vector(7 downto 0);

signal disc_hi_isa				: reg16_array;
signal en_disc_hi_isa			: std_logic_vector(7 downto 0);

signal disc_lo_isa				: reg16_array;
signal en_disc_lo_isa			: std_logic_vector(7 downto 0);

signal epcs_data_isa				: std_logic_vector(7 downto 0);
signal epcs_addr_isa				: std_logic_vector(23 downto 0);
signal epcs_rd_data				: std_logic_vector(7 downto 0);

signal en_epcs_data				: std_logic;
signal en_epcs_lo_addr			: std_logic;
signal en_epcs_hi_addr			: std_logic;

signal sgn_lmt						: reg32_array;

signal sgn_lmt_stat				: std_logic_vector(7 downto 0);
signal abs_lmt_stat				: std_logic_vector(7 downto 0);

signal abs_lmt						: reg32_array;

signal abs_stp_sub_int			: reg16_array;

signal en_abs_lmt0_isa			: std_logic_vector(7 downto 0);
signal en_abs_lmt1_isa			: std_logic_vector(7 downto 0);

signal en_sgn_lmt0_isa			: std_logic_vector(7 downto 0);
signal en_sgn_lmt1_isa			: std_logic_vector(7 downto 0);

signal en_abs_sub_isa			: std_logic_vector(7 downto 0);

signal mask_abs_sub_isa			: std_logic_vector(7 downto 0);
signal mask_sgn_sub_isa			: std_logic_vector(7 downto 0);

signal clr_timer					: std_logic;
signal en_timer					: std_logic;
signal timer						: std_logic_vector(27 downto 0);
signal en_stp_sub					: std_logic_vector(7 downto 0);

signal abs_stp_cnt				: reg32_array;
signal sgn_stp_cnt				: reg32_array;

signal abs_stp_cnt_in			: reg32_array;
signal sgn_stp_cnt_in			: reg32_array;

signal en_pzt_hi_isa				: std_logic_vector(7 downto 0);
signal pzt_hi_int					: reg16_array;

signal en_pzt_lo_isa				: std_logic_vector(7 downto 0);
signal en_motorCurr				: std_logic_vector(7 downto 0);
signal en_MRES						: std_logic_vector(7 downto 0);
signal en_CHOPCONF				: std_logic_vector(7 downto 0);

signal en_4k_cmd              : STD_LOGIC;

signal pzt_lo_int					: reg16_array;
signal motorCurr					: reg16_array;
signal MRES							: reg16_array;
signal CHOPCONF					: reg16_array;

signal fib_mode_int				: std_logic_vector(7 downto 0);
signal slow_gdr_en				: std_logic_vector(7 downto 0);
-- 
-- 32kbit EEPROM
signal en_EEPROM_ctrl             :  STD_LOGIC;
signal en_EEPROM_addr             :  STD_LOGIC;
signal en_EEPROM_data             :  STD_LOGIC;
signal EEPROM_ctrl   :  STD_LOGIC_VECTOR(7 downto 0);  -- bit1 = RNW, bit0 = go
signal EEPROM_addr   :  STD_LOGIC_VECTOR(11 downto 0); -- 12 bit read address
signal EEPROM_data   :  STD_LOGIC_VECTOR(7 downto 0);  -- data to write to byt
--
-- Cyclone 10 Gx remote config/download
--signal en_c_addr  : StD_LOGIC;
--signal en_c_cntl  : StD_LOGIC;   
--signal en_c_data  : StD_LOGIC;
--signal c_addr		: StD_LOGIC_VECTOR(31 downto 0);
--signal c_cntlr	   : StD_LOGIC_VECTOR(31 downto 0);
--signal c10_status : StD_LOGIC_VECTOR(31 downto 0);   
--signal c_data		: StD_LOGIC_VECTOR(31 downto 0);
--signal c10_datar  : StD_LOGIC_VECTOR(31 downto 0);
--
-- c10 pv status register
-- epics will write a value to this after IOC reboot. If the fpga is reset or power
-- is lost to this one chassis, this value will be lost and the IOC will know to
-- process or reload all PVs for this chassis.
-- value must be initlaized as a zero.
signal STPRSTR    : STD_LOGIC_VECTOR(31 downto 0);
signal en_STPRSTR : STD_LOGIC;

-- JTAG Mux select, complementary bits, used to deselect the Cyclone 10 from the JTAG chain so that the max10 may be reporgrammed by itself
signal JTAGMUX    : STD_LOGIC_VECTOR(15 downto 0);
signal jtagmuxreg	: STD_LOGIC_VECTOR(15 downto 0);
signal EN_JTAGMUX : STD_LOGIC;

-- SFP controls signal enables
signal en_sfp_dataw, en_sfp_datar, en_sfp_ctrl : STD_LOGIC;
signal sfp_dataw, sfp_ctrl : STD_LOGIC_VECTOR(31 downto 0);
--
-- Cyclone 10 Gx remote config/download


attribute noprune: boolean;

signal c10_datar, c10_status : STD_LOGIC_VECTOR(31 downto 0);


signal en_c_addr  : StD_LOGIC;
signal en_c_cntl  : StD_LOGIC;   
signal en_c_data  : StD_LOGIC;

signal rate_chn, detune_chn  : reg32_array;

--1/23/23, added for mux version of address map. 
signal lb_addr_r, regbank_0, regbank_1, regbank_2, regbank_3, regbank_4, regbank_5, regbank_6, regbank_7 : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of lb_addr_r : signal is true;
attribute noprune of regbank_0 : signal is true;
attribute noprune of regbank_1 : signal is true;
attribute noprune of regbank_2 : signal is true;
attribute noprune of regbank_3 : signal is true;
attribute noprune of regbank_4 : signal is true;
attribute noprune of regbank_5 : signal is true;
attribute noprune of regbank_6 : signal is true;
attribute noprune of regbank_7 : signal is true;

signal wf_4k_command, wf_4k_status : STD_LOGIC_VECTOR(31 downto 0);
 

SIGNAL c_addr : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of c_addr : signal is true;
SIGNAL c_cntlr : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of c_cntlr : signal is true;
SIGNAL c_data : STD_LOGIC_VECTOR(31 downto 0);
attribute noprune of c_data : signal is true;
SIGNAL c_status : STD_LOGIC_VECTOR(31 downto 0); -- RO
attribute noprune of c_status : signal is true;
SIGNAL c_datar : STD_LOGIC_VECTOR(31 downto 0); -- RO
attribute noprune of c_datar : signal is true;
signal lb_strb : STD_LOGIC;
attribute noprune of lb_strb : signal is true;



--
begin
-- Constants
one <= '1';
--
--==================================================================
-- Enables en_sub_abs and en_sub_sgn once a second whenever lmt_stat is 0 and mask is 1
--==================================================================
-- 9/5/23, simple change to make the legacy version work for abs subs (not sign subs).
-- timing changed to suit 125 MHz system clock

	timer_counter: counter
			generic map(n => 28)
			port map(clock		=> clock,
						reset		=> reset,
						clear  	=> clr_timer,
						en			=> one,
						count		=> timer
						);
-- once timer is full, this will strobe a clear		
clr_timer <= '1' when timer >= x"7735940" else '0'; 
						
sub_signal_gen: for i in 0 to 7 generate
	-- clear timer will strobe hi for one clock once timer is full.
	-- enable en_sub_abs only when no abs faut, abs step counter is not alrady at 0, and abs fault limit is not masked out
	en_sub_abs(i) <= '1' when (clr_timer = '1' and abs_lmt_stat(i) = '0' and abs_steps(i) /= x"00000000" and mask_abs_sub_isa(i) = '0') else '0';
	--en_sub_sgn(i) <= '1' when (timer = x"4C4B400" and sgn_lmt_stat(i) = '0'and sgn_steps(i) /= x"00000000" and mask_sgn_sub_isa(i) = '0') else '0';
	en_sub_sgn(i) <= '0'; -- hard code signed step to never be on
end generate;
--
--==================================================================
-- High limit Switch Detection (5 buffers)
--==================================================================
--
		high_limit_reg1: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => high_limit_in,
									     output => high_limit_ff1
								       );

		high_limit_reg2: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => high_limit_ff1,
									     output => high_limit_ff2
								       );
								
		high_limit_reg3: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => high_limit_ff2,
									     output => high_limit_ff3
								       );
								
		high_limit_reg4: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => high_limit_ff3,
									     output => high_limit_ff4
								       );
								
		high_limit_reg5: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => high_limit_ff4,
									     output => high_limit_ff5
								       );
										 
high_limit_gen: for i in 0 to 7 generate
	-- JAL, 5/18/22, added mask
	-- If limit switch mask bit is set HI, then we keep the limit as alwasy LOW  (ignore limit faults)
	high_limit(i) <= '0' when limit_sw_mask(i) = '1' else  high_limit_ff5(i);
end generate;
--
--==================================================================
-- LOW limit Switch Detection (5 buffers)
--==================================================================
--
		low_limit_reg1: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => low_limit_in,
									     output => low_limit_ff1
								       );


		low_limit_reg2: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => low_limit_ff1,
									     output => low_limit_ff2
								       );
								
		low_limit_reg3: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => low_limit_ff2,
									     output => low_limit_ff3
								       );
								
		low_limit_reg4: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => low_limit_ff3,
									     output => low_limit_ff4
								        );
								
		low_limit_reg5: regne generic map(n => 8)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en	  	=> one,
									     input  => low_limit_ff4,
									     output => low_limit_ff5
								       );
--								 
low_limit_gen: for i in 0 to 7 generate
    -- JAL, 5/18/22, added mask
	 -- If limit switch mask bit is set HI, then we keep the limit as alwasy LOW  (ignore limit faults)
	low_limit(i) <= '0' when limit_sw_mask(i) = '1' else low_limit_ff5(i);
end generate;	
--
--==================================================================
-- MOVE inputs (3 buffers)
--==================================================================
--	
move_ff_gen: for i in 0 to 7 generate

	move_buf_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> one,
					     en 		=> en_move_buf1(i),
					     inp 	=> move_in(i),
					     oup 	=> move_buf(i)
					    );
					
	move_buf1_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> one,
					     en 		=> en_move_buf1(i),
					     inp 	=> move_buf(i),
					     oup 	=> move_buf1(i)
					    );
					
	move_buf2_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> one,
					     en 		=> en_move_buf1(i),
					     inp 	=> move_buf1(i),
					     oup 	=> move_buf2(i)
					    );					
-- only allows new move commands if motion is 0.
en_move_buf1(i)	<= '0' when motion(i) = '1' else '1';
-- only allow move inputs when limits are not reached
-- looks for rising edge, the move command is a pulse
move(i)			 	<= '0' when (high_limit(i) = '1' and ldir(i) = '1') or (low_limit(i) = '1' and ldir(i) = '0') or
										(accel_isa(i) = 0) or (vlcty_isa(i) = 0) or (steps_isa(i) = 0) else
										(not move_buf2(i) and move_buf1(i));					
end generate;
--
--==================================================================
-- MOTOR COMMANDS (clears are active hi)
--==================================================================
--	
int_sig_gen: for i in 0 to 7 generate
	move_in(i)				<= command_motor(i)(0);
	inhibit_en(i)			<= command_motor(i)(1);
	crash(i) 				<= command_motor(i)(2);
	stop_isa_in(i) 		<= command_motor(i)(3);
	clear_done(i)			<= command_motor(i)(4);
	direction_isa(i) 		<= command_motor(i)(5);
	low_current_en(i) 	<= command_motor(i)(6);
	fib_mode_int(i)		<= command_motor(i)(7);
	clr_sgn_stp(i)			<= not command_motor(i)(8);
	clr_abs_stp(i)			<= not command_motor(i)(9);
	mask_sgn_sub_isa(i)	<= command_motor(i)(10); -- not used in LLRF 3.0 HRT
	mask_abs_sub_isa(i)	<= command_motor(i)(11); -- not used in LLRF 3.0 HRT
	slow_gdr_en(i)			<= command_motor(i)(12); -- not used in LLRF 3.0 HRT, controleld with FIBERS to FCC
	dir_flip_b(i)			<= command_motor(i)(13); -- flips direction motion for both auto and manual modes
	limit_sw_mask(i)     <= command_motor(i)(14); -- signal is masked with both limit switches. Limits will be ignored when this bit is HI.
end generate;
--
-- assign output
fib_mode <= fib_mode_int;
--
--==================================================================
-- STOP PULSE (3 buffers) detect rising edge
--==================================================================
--	
stop_ff_gen: for i in 0 to 7 generate ----stop pulse detection

	stop_buf0_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> one,
					     en 		=> one,
					     inp 	=> stop_isa_in(i),
					     oup 	=> stop_isa_buf(i)
					    );
					
	stop_buf1_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> one,
					     en 		=> one,
					     inp 	=> stop_isa_buf(i),
					     oup 	=> stop_isa_buf1(i)
					    );
					
	stop_buf2_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> one,
					     en 		=> one,
					     inp 	=> stop_isa_buf1(i),
					     oup 	=> stop_isa_buf2(i)
						  );
--detect rising edge
stop_isa(i) <= (not stop_isa_buf2(i)) and stop_isa_buf1(i);
--						  
end generate;
--
--==================================================================
-- DIRECTION and dir_flip
--==================================================================
--	
-- Note: I needd to add "not" around the port map function calls to
-- 		allow this code to compile for MODELSIM
--
dir_ff_gen: for i in 0 to 7 generate

	dir_latch_i: latch_n
			  port map(clock 	=> clock,
					     reset 	=> reset,
					     clear	=> "not"(command(0)),
					     en 		=> "not"(motion(i)),
					     inp 	=> direction_isa(i),
					     oup 	=> dir_int(i)
						  );

	dir_flip_latch_i: latch_n
		  port map(clock 	=> clock,
					  reset 	=> reset,
					  clear	=> "not"(command(0)),
					  en 		=> "not"(motion(i)), -- don't change direction while moving
					  inp 	=> dir_flip_b(i), 	-- LOW is no flip, HI means flip direction
					  oup 	=> dir_flip_int(i) -- to output
					  );
						  
end generate;
--
-- Assign outputs
dir <= dir_int;
dir_flip <= dir_flip_int;
--
--==================================================================
-- INHIBIT																				
--==================================================================
--						     
-- If 	 is LOW, then this means that something is wrong and we should stop stepping
-- 	(i.e. either a crash command was given or some limit was hit). To ignore 
--		this, you can set the enable mask to HI via the command register
inhibit_gen: for i in 0 to 7 generate	
	inhibit_int(i) <= '0' when (crash(i) = '1' or high_limit(i) = '1' or low_limit(i) = '1' or sgn_lmt_stat(i) = '1' or abs_lmt_stat(i) = '1') and inhibit_en(i) = '0' else '1';
end generate;
--
-- Assign output (updated 10/26/200)
--	Note, I updated this to be active low to be compatiable with the TMC2660 layout for LLRF 3.0
-- inhibit = HI will keep the stepper mosfets drained and LOW will enable them (active LOW)
-- here, inhibit_int is LOW whenever something is wrong and HI otherwise (active HI)
inhibit <= NOT(inhibit_int); -- convert to active low logic (as discussed above)
--
--==================================================================
-- ACCEL (writes over ISA bus with DIN)
--==================================================================
--	
accel_reg_gen_i: for i in 0 to 7 generate

		accel_isa_reg0_i: regne generic map(n => 32)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en		=> en_accel0_isa(i),
									     input  => din,
									     output => accel_isa(i)(31 downto 0)
								       );
	--
	accel_isar(i)			<= accel_isa(i) when slow_gdr(i) = '0' or slow_gdr_en(i) = '0' else ("00" & accel_isa(i)(31 downto 2));
end generate;
	--
	-- Assign output
	accel	<= accel_isar;
	--
	-- Updated to 32 bit values
	en_accel0_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"000" else '0';
	en_accel0_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"003" else '0';
	en_accel0_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"006" else '0';
	en_accel0_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"009" else '0';
	en_accel0_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"00C" else '0';
	en_accel0_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"00F" else '0';
	en_accel0_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"012" else '0';
	en_accel0_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"015" else '0';	
--
--==================================================================
-- VLCTY (wrties over ISA BUS, DIN)
--==================================================================
--	
vlcty_reg_gen_i: for i in 0 to 7 generate

		vlcty_isa_reg0_i: regne generic map(n => 32)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en		=> en_vlcty0_isa(i),
									     input  => din,
									     output => vlcty_isa(i)(31 downto 0)
								       );
	--
	vlcty_isar(i)			<= vlcty_isa(i) when slow_gdr(i) = '0' or slow_gdr_en(i) = '0' else ("000" & vlcty_isa(i)(31 downto 3));
	--
end generate;
	--
	-- Assign outputs
	vlcty <= vlcty_isar;
	--
	-- updated to 32 bit values
	en_vlcty0_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"001" else '0';
	en_vlcty0_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"004" else '0';
	en_vlcty0_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"007" else '0';
	en_vlcty0_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"00A" else '0';
	en_vlcty0_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"00D" else '0';
	en_vlcty0_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"010" else '0';
	en_vlcty0_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"013" else '0';
	en_vlcty0_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"016" else '0';
	--
--==================================================================
-- STEPS (wrties over ISA BUS, DIN)
--==================================================================
--	
steps_reg_gen_i: for i in 0 to 7 generate

		steps_isa_reg0_i: regne generic map(n => 32)
						  	 port map (clock	=> clock,
									     reset	=> reset,
									     clear	=> one,
									     en		=> en_steps0_isa(i),
									     input  	=> din,
									     output 	=> steps_isa(i)(31 downto 0)
								        );
end generate;
--
	-- Assign outputs
	steps					<= steps_isa;
	--
	-- Used to help control if ISA is writing to the upper or lower 16 bits of a register
	en_steps0_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"002" else '0';
	en_steps0_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"005" else '0';
	en_steps0_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"008" else '0';
	en_steps0_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"00B" else '0';
	en_steps0_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"00E" else '0';
	en_steps0_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"011" else '0';
	en_steps0_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"014" else '0';
	en_steps0_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"017" else '0';		
	--
	--==================================================================
	-- LOW CURRENT Enable															
	--==================================================================
	--
	-- Note 10/26/2020, this attempts to place the stepper into low current mode during steps (is this desired)
	-- this will require an SPI configuration to take effect thus the first step will like be at the current 
	-- sense value and then the remainders will be in the low current setting.
	--
	-- 4/3/23, spi configuration will always happen befrore motors move.
	--
	low_current_gen: for i in 0 to 7 generate	
		-- changed on 10/26/2020 so that we don't go into low current mode every time we move
		--low_current_int(i) <= low_current_en(i) or motion(i); 
		--low_current_int(i) <= low_current_en(i);
		-- Change to support Rama's Request 10/28/22. Will set hold current to be at its lowest when the motor is not moving.
		-- to ignore this, set the 'low current mask bit' to HI. Setting the mask, masks out the functionality and keeps
		-- a constant hold current. 
		-- 9/5/23, power on state, mask is not on. if mask enabled, motor will idle in lower current.
		low_current_int(i) <= motion(i) NOR NOT(low_current_en(i));
		-- Note low_curren_int = 1 means lowest current
		--								 0 means whatever is set by current drive register 
	end generate;
	--
	-- Assign output
	low_current <=	low_current_int;
	--
	--==================================================================
	-- Upate COMMAND register over ISA (DIN)
	--==================================================================
	--
	command_isa_reg: regne generic map(n => 16)
						 port map (clock	=> clock,
									  reset	=> reset,
									  clear	=> one,
									  en	  	=> en_command,
									  input  => din(15 downto 0),
									  output => command
									 );
	-- 
	en_command	<= '1' when load = '1' and addr(11 downto 0) = x"18" else '0';
	
	-- added 4/28/2021 not tested, we are always going to drop a few packets when the gigabit pll is reset....
--	clear_detect : process (CLOCK, reset)
--		variable cmd_0_last : STD_LOGIC;
--	begin
--		if reset = '0' then
--			cmd_0_last := '0';
--			clear 		<= '0';
--		elsif (CLOCK'event and CLOCK='1') then
--			-- look for rising edge, command(0) will go HI when we want to reset
--			clear			<= command(0) AND cmd_0_last; -- SYSTEM RESET when we detect the a 1 being written to cmd(0), this is for the rising edge only
--			cmd_0_last  := NOT(command(0));
--		end if;
--	end process clear_detect;
	
	-- Assign outputs
	clear			<= command(0); -- SYSTEM RESET
	-- For future expansion
	reconfig <= command(1); --this is for triggering the reconfiguration for eeprom(remote update mode)
	epcsc(0) <= command(2); --go bit for epcs
	epcsc(1) <= command(3); --read bit for epcs
	epcsc(2) <= command(4); --write bit for epcs
	epcsc(3) <= command(5); --erase bit for epcs
	--
	--==================================================================
	-- STOP, stop for the below conditions
	--==================================================================
	--
	stop_gen_i: for i in 0 to 7 generate
		-- detect and absolute limit
		abs_lmt_stat(i) <= '1' when abs_steps(i)(31 downto 0) = abs_lmt(i)(31 downto 0) else '0';
		-- detect a signed step limit
		sgn_lmt_stat(i) <= '1' when sgn_steps(i)(31 downto 0) = sgn_lmt(i)(31 downto 0) or (not sgn_steps(i)(31 downto 0) + '1') = sgn_lmt(i)(31 downto 0) else '0';
		-- if either limit is reached, a stop command is ussed over ISA, and inhibit mask is set to 0, or  accel/vel/steps = 0 then STOP the respective stepper
		stop(i)	<= '1' when abs_lmt_stat(i) = '1' or sgn_lmt_stat(i) = '1' or stop_isa(i) = '1' or command(0) = '1' or inhibit_int(i) = '0' or (high_limit(i) = '1' and ldir(i) = '1') or (low_limit(i) = '1' and ldir(i) = '0') or
									(accel_isa(i) = x"00000000") or (vlcty_isa(i) = x"00000000") or (fib_mode_int(i) = '0' and steps_isa(i) = x"00000000") or (fib_mode_int(i) = '1' and step_hz_isa(i) = x"0000" )else '0';
		
	end generate;
	--
	--==================================================================
	-- Motor command (update over ISA BUS)
	--==================================================================
	--
	command_motor_reg_gen_i: for i in 0 to 7 generate
		--
		command_motor_reg_i: regne generic map(n => 16) --
							 port map (clock	=> clock,
										  reset	=> reset,
										  clear	=> one,
										  en		=> en_command_motor(i),
										  input  => din(15 downto 0), -- JAL 7/27/21 changed to 14 bit to support dir_flip, 5/18 changed to 16 bit
										  output => command_motor(i)
										 );
end generate;
	--
	-- Updated for 32 bit addressing
	en_command_motor(0) <= '1' when load = '1' and addr(11 downto 0) = x"019" else '0';
	en_command_motor(1) <= '1' when load = '1' and addr(11 downto 0) = x"01A" else '0';
	en_command_motor(2) <= '1' when load = '1' and addr(11 downto 0) = x"01B" else '0';
	en_command_motor(3) <= '1' when load = '1' and addr(11 downto 0) = x"01C" else '0';
	en_command_motor(4) <= '1' when load = '1' and addr(11 downto 0) = x"01D" else '0';
	en_command_motor(5) <= '1' when load = '1' and addr(11 downto 0) = x"01E" else '0';
	en_command_motor(6) <= '1' when load = '1' and addr(11 downto 0) = x"01F" else '0';
	en_command_motor(7) <= '1' when load = '1' and addr(11 downto 0) = x"020" else '0';
	--
	--==================================================================
	-- DONE MOVE
	--==================================================================
	--
	done_move_ff_gen: for i in 0 to 7 generate
		--
		done_move_i: latch_n
				  port map(clock 	=> clock,
							  reset	=> reset,
							  clear 	=> clr_done_move(i),
							  en 		=> done_move_in(i),
							  inp 	=> one,
							  oup 	=> done(i)
						  );
	--
	done_out 			<= done;
	-- done once we see the done_move pulse from stepper OR we reach some limit
	done_move_in(i) <= done_move(i) or stop_isa(i) or not inhibit_int(i) or abs_lmt_stat(i)  or sgn_lmt_stat(i) or 
						 (high_limit(i) and ldir(i)) or (low_limit(i) and not ldir(i));				  
	--				  
	clr_done_move(i)	<= '0' when clear_done(i) = '1' else '1';
	--			
	end generate;
	--
	--==================================================================
	-- MOTOR STATUS
	--==================================================================
	--
	status_motor_gen: for i in 0 to 7 generate
		-- 11/4/2020, removed invert from low_current_int
		-- note deta_disc is 2 bits
		status_motor(i) <= slow_gdr(i) & deta_disc(i) & step_en(i) & abs_lmt_stat(i) & sgn_lmt_stat(i) & low_current_int(i) & not inhibit_int(i) & limit_isa(i) & high_limit(i) & low_limit(i) & done(i) & ldir(i) & motion(i);
	end generate;
	--
	--==================================================================
	-- Step_HZ (from ISA, DIN)
	--==================================================================
	--
	step_hz_reg_gen_i: for i in 0 to 7 generate

			step_hz_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_step_hz_isa(i),
											  input  => din(15 downto 0),
											  output => step_hz_isa(i)
											  );
			-- Only look at the lower 16 bits								  
			step_hz(i)					<= x"0000" & step_hz_isa(i);								  
											  
	end generate;
	--
	-- Only enable for the correct address, updated for 32 bit addressing
	en_step_hz_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"05D" else '0';
	en_step_hz_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"05E" else '0';
	en_step_hz_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"05F" else '0';
	en_step_hz_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"060" else '0';
	en_step_hz_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"061" else '0';
	en_step_hz_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"062" else '0';
	en_step_hz_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"063" else '0';
	en_step_hz_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"064" else '0';
	--
	--==================================================================
	-- DETA HI (from ISA, DIN)
	--==================================================================
	--
	deta_hi_reg_gen_i: for i in 0 to 7 generate

			deta_hi_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_deta_hi_isa(i),
											  input  => din(15 downto 0),
											  output => deta_hi_isa(i)
											  );
			-- Assign output								  
			deta_hi(i)					<= deta_hi_isa(i);								  
			--							  
	end generate;
	--
	-- Ensure that the correct address is being written to, updated to 32 bit addressing
	en_deta_hi_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"065" else '0';
	en_deta_hi_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"066" else '0';
	en_deta_hi_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"067" else '0';
	en_deta_hi_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"068" else '0';
	en_deta_hi_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"069" else '0';
	en_deta_hi_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"06A" else '0';
	en_deta_hi_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"06B" else '0';
	en_deta_hi_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"06C" else '0';
	--
	--==================================================================
	-- DETA LO (from ISA, DIN)
	--==================================================================
	--
	deta_lo_reg_gen_i: for i in 0 to 7 generate

			deta_lo_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_deta_lo_isa(i),
											  input  => din(15 downto 0),
											  output => deta_lo_isa(i)
											  );
			-- Assign output								  
			deta_lo(i)					<= deta_lo_isa(i);								  
			--							  
	end generate;
	--
	-- Ensure that the correct address is being written to
	en_deta_lo_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"06D" else '0';
	en_deta_lo_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"06E" else '0';
	en_deta_lo_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"06F" else '0';
	en_deta_lo_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"070" else '0';
	en_deta_lo_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"071" else '0';
	en_deta_lo_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"072" else '0';
	en_deta_lo_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"073" else '0';
	en_deta_lo_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"074" else '0';
	--
	--==================================================================
	-- DISC HI (from ISA, DIN)
	--==================================================================
	--
	disc_hi_reg_gen_i: for i in 0 to 7 generate

			disc_hi_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_disc_hi_isa(i),
											  input  => din(15 downto 0),
											  output => disc_hi_isa(i)
											  );
			-- Assign output								  
			disc_hi(i)					<= disc_hi_isa(i);								  
			--								  
	end generate;
	--
	-- Ensure that the correct address is being written to
	en_disc_hi_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"075" else '0';
	en_disc_hi_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"076" else '0';
	en_disc_hi_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"077" else '0';
	en_disc_hi_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"078" else '0';
	en_disc_hi_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"079" else '0';
	en_disc_hi_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"07A" else '0';
	en_disc_hi_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"07B" else '0';
	en_disc_hi_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"07C" else '0';
	--
	--==================================================================
	-- DISC LO (from ISA, DIN)
	--==================================================================
	--
	disc_lo_reg_gen_i: for i in 0 to 7 generate

			disc_lo_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_disc_lo_isa(i),
											  input  => din(15 downto 0),
											  output => disc_lo_isa(i)
											  );
			-- Assign output								  
			disc_lo(i)					<= disc_lo_isa(i);								  
			--								  
	end generate;
	--
	-- Ensure that the correct address is being written to
	en_disc_lo_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"07D" else '0';
	en_disc_lo_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"07E" else '0';
	en_disc_lo_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"07F" else '0';
	en_disc_lo_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"080" else '0';
	en_disc_lo_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"081" else '0';
	en_disc_lo_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"082" else '0';
	en_disc_lo_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"083" else '0';
	en_disc_lo_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"084" else '0';
	--
	--==================================================================
	-- ESPCS (ISA, over DIN)
	--==================================================================
	--
	epcs_low_addr_reg: regne generic map(n => 24)
						 port map (clock	=> clock,
									  reset	=> reset,
									  clear	=> one,
									  en		=> en_epcs_lo_addr,
									  input  => din(23 downto 0),
									  output => epcs_addr_isa
									  );
	--								  								  
	epcsa             <= epcs_addr_isa;										  
	en_epcs_lo_addr	<= '1' when load = '1' and addr(11 downto 0) = x"085" else '0';										  
	--
	epcs_write_data_reg: regne generic map(n => 8)
						 port map (clock	=> clock,
									  reset	=> reset,
									  clear	=> one,
									  en		=> en_epcs_data,
									  input  => din(7 downto 0),
									  output => epcs_data_isa
									  );
	--									  
	en_epcs_data	<= '1' when load = '1' and addr(11 downto 0) = x"086" else '0';
	epcsd <= epcs_data_isa;
	--
	--==================================================================
	-- SGN STEP LIMIT (ISA, over DIN)
	--==================================================================
	--
	sgn_steps_lmt_reg_gen_i: for i in 0 to 7 generate
		--
		sgn_lmt_isa_reg0_i: regne generic map(n => 32)
							 port map (clock	=> clock,
										  reset	=> reset,
										  clear	=> one,
										  en		=> en_sgn_lmt0_isa(i),
										  input  => din,
										  output => sgn_lmt(i)(31 downto 0)
										  );	
end generate;
	--
	-- Update limit with respect to the address
	en_sgn_lmt0_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"098" else '0';
	en_sgn_lmt0_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"099" else '0';
	en_sgn_lmt0_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"09A" else '0';
	en_sgn_lmt0_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"09B" else '0';
	en_sgn_lmt0_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"09C" else '0';
	en_sgn_lmt0_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"09D" else '0';
	en_sgn_lmt0_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"09E" else '0';
	en_sgn_lmt0_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"09F" else '0';
	--
	--==================================================================
	-- ABS STEP LIMIT (ISA, over DIN)
	--==================================================================
	--
	abs_steps_lmt_reg_gen_i: for i in 0 to 7 generate
			--
			abs_lmt_isa_reg0_i: regne generic map(n => 32)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_abs_lmt0_isa(i),
											  input  	=> din,
											  output 	=> abs_lmt(i)(31 downto 0)
											  );
			--
	end generate;
	--
	-- Update limit with respect to the address
	en_abs_lmt0_isa(0)	<= '1' when load = '1' and addr(11 downto 0) = x"0A0" else '0';
	en_abs_lmt0_isa(1)	<= '1' when load = '1' and addr(11 downto 0) = x"0A1" else '0';
	en_abs_lmt0_isa(2)	<= '1' when load = '1' and addr(11 downto 0) = x"0A2" else '0';
	en_abs_lmt0_isa(3)	<= '1' when load = '1' and addr(11 downto 0) = x"0A3" else '0';
	en_abs_lmt0_isa(4)	<= '1' when load = '1' and addr(11 downto 0) = x"0A4" else '0';
	en_abs_lmt0_isa(5)	<= '1' when load = '1' and addr(11 downto 0) = x"0A5" else '0';
	en_abs_lmt0_isa(6)	<= '1' when load = '1' and addr(11 downto 0) = x"0A6" else '0';
	en_abs_lmt0_isa(7)	<= '1' when load = '1' and addr(11 downto 0) = x"0A7" else '0';
	--
	--==================================================================
	-- ABS STEP SUB (ISA, over DIN)
	--==================================================================
	--
	abs_steps_sub_reg_gen_i: for i in 0 to 7 generate

			abs_sub_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_abs_sub_isa(i),
											  input  => din(15 downto 0),
											  output => abs_stp_sub_int(i)
											  );
	-- Assign output
	abs_stp_sub(i) <= abs_stp_sub_int(i);
	--										  
	end generate;
	--
	-- Update limit with respect to the address
	en_abs_sub_isa(0) <= '1' when load = '1' and addr(11 downto 0) = x"0A8" else '0';
	en_abs_sub_isa(1) <= '1' when load = '1' and addr(11 downto 0) = x"0A9" else '0';
	en_abs_sub_isa(2) <= '1' when load = '1' and addr(11 downto 0) = x"0AA" else '0';
	en_abs_sub_isa(3) <= '1' when load = '1' and addr(11 downto 0) = x"0AB" else '0';
	en_abs_sub_isa(4) <= '1' when load = '1' and addr(11 downto 0) = x"0AC" else '0';
	en_abs_sub_isa(5) <= '1' when load = '1' and addr(11 downto 0) = x"0AD" else '0';
	en_abs_sub_isa(6) <= '1' when load = '1' and addr(11 downto 0) = x"0AE" else '0';
	en_abs_sub_isa(7) <= '1' when load = '1' and addr(11 downto 0) = x"0AF" else '0';
	--
	--==================================================================
	-- PZT HI (ISA, over DIN)
	--==================================================================
	--
	pzt_high_limit_reg_gen_i: for i in 0 to 7 generate

			pzt_high_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_pzt_hi_isa(i),
											  input  => din(15 downto 0),
											  output => pzt_hi_int(i)
											  );
	-- Assign output
	pzt_hi_lmt(i) <= pzt_hi_int(i);
	--										  
	end generate;
	--
	-- Update limit with respect to the address
	en_pzt_hi_isa(0) <= '1' when load = '1' and addr(11 downto 0) = x"0B8" else '0';
	en_pzt_hi_isa(1) <= '1' when load = '1' and addr(11 downto 0) = x"0B9" else '0';
	en_pzt_hi_isa(2) <= '1' when load = '1' and addr(11 downto 0) = x"0BA" else '0';
	en_pzt_hi_isa(3) <= '1' when load = '1' and addr(11 downto 0) = x"0BB" else '0';
	en_pzt_hi_isa(4) <= '1' when load = '1' and addr(11 downto 0) = x"0BC" else '0';
	en_pzt_hi_isa(5) <= '1' when load = '1' and addr(11 downto 0) = x"0BD" else '0';
	en_pzt_hi_isa(6) <= '1' when load = '1' and addr(11 downto 0) = x"0BE" else '0';
	en_pzt_hi_isa(7) <= '1' when load = '1' and addr(11 downto 0) = x"0BF" else '0';
	--
	--==================================================================
	-- PZT LOW (ISA, over DIN)
	--==================================================================
	--
	pzt_low_limit_reg_gen_i: for i in 0 to 7 generate

			pzt_low_isa_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_pzt_lo_isa(i),
											  input  => din(15 downto 0),
											  output => pzt_lo_int(i)
											  );
	-- Assign output
	pzt_lo_lmt(i) <= pzt_lo_int(i);
	--										  
	end generate;
	--
	-- Update limit with respect to the address
	en_pzt_lo_isa(0) <= '1' when load = '1' and addr(11 downto 0) = x"0C0" else '0';
	en_pzt_lo_isa(1) <= '1' when load = '1' and addr(11 downto 0) = x"0C1" else '0';
	en_pzt_lo_isa(2) <= '1' when load = '1' and addr(11 downto 0) = x"0C2" else '0';
	en_pzt_lo_isa(3) <= '1' when load = '1' and addr(11 downto 0) = x"0C3" else '0';
	en_pzt_lo_isa(4) <= '1' when load = '1' and addr(11 downto 0) = x"0C4" else '0';
	en_pzt_lo_isa(5) <= '1' when load = '1' and addr(11 downto 0) = x"0C5" else '0';
	en_pzt_lo_isa(6) <= '1' when load = '1' and addr(11 downto 0) = x"0C6" else '0';
	en_pzt_lo_isa(7) <= '1' when load = '1' and addr(11 downto 0) = x"0C7" else '0';
	--
	--==================================================================
	-- Motor Current (for TMC)
	--==================================================================
	--
	motorCurr_reg_gen_i: for i in 0 to 7 generate

			motorCurr_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_motorCurr(i),
											  input  => din(15 downto 0),
											  output => motorCurr(i)
											  );
	-- Assign output
	motorCurr_OUT(i) <= motorCurr(i);
	--										  
	end generate;
	--
	-- Update limit with respect to the address
	en_motorCurr(0) <= '1' when load = '1' and addr(11 downto 0) = x"0C8" else '0';
	en_motorCurr(1) <= '1' when load = '1' and addr(11 downto 0) = x"0C9" else '0';
	en_motorCurr(2) <= '1' when load = '1' and addr(11 downto 0) = x"0CA" else '0';
	en_motorCurr(3) <= '1' when load = '1' and addr(11 downto 0) = x"0CB" else '0';
	en_motorCurr(4) <= '1' when load = '1' and addr(11 downto 0) = x"0CC" else '0';
	en_motorCurr(5) <= '1' when load = '1' and addr(11 downto 0) = x"0CD" else '0';
	en_motorCurr(6) <= '1' when load = '1' and addr(11 downto 0) = x"0CE" else '0';
	en_motorCurr(7) <= '1' when load = '1' and addr(11 downto 0) = x"0CF" else '0';
	--
	--==================================================================
	-- STPRSTR,k epics PV status register.
	--==================================================================
	-- 4/4/22
	-- Value is initialized to all zeros
	-- epics will write a value to this register after IOC restore/reboot
	-- if the chassis is reset or has the pwoer cycled, this register will be reset
	-- which will detected by an ep[ics watchdog. If STPRSTR is zeros, then
	-- epics will know to restore this chassis PVs.
	--
	en_STPRSTR <= '1' when load = '1' and addr(11 downto 0) = x"0DA" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  STPRSTR<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_STPRSTR='1') THEN 
		  STPRSTR<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	--
	--==================================================================
	-- 32kbit EEPROM
	--==================================================================
	-- 1/7/22
	--
	-- enables for RW registers 
	en_EEPROM_ctrl <= '1' when load = '1' and addr(11 downto 0) = x"0D1" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  EEPROM_ctrl<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_EEPROM_ctrl='1') THEN 
		  EEPROM_ctrl<=din(7 downto 0); 
	  END IF; 
	END PROCESS; 

	en_EEPROM_addr <= '1' when load = '1' and addr(11 downto 0) = x"0D2" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  EEPROM_addr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_EEPROM_addr='1') THEN 
		  EEPROM_addr<=din(11 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_EEPROM_data <= '1' when load = '1' and addr(11 downto 0) = x"0D3" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  EEPROM_data<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_EEPROM_data='1') THEN 
		  EEPROM_data<=din(7 downto 0); 
	  END IF; 
	END PROCESS;
	--
	-- assign module outputs to signals
	out_EEPROM_ctrl <= EEPROM_ctrl;
	out_EEPROM_addr <= EEPROM_addr;
	out_EEPROM_data <= EEPROM_data;
	
	--
	--
	--==================================================================
	-- Cyclone 10 GX remote download/reconfig
	--==================================================================
	-- 1/10/22 written
	-- 4/4/22, added to interlock fw
	--
	--
	-- This module allows us to update the firmware load saved on the EPCQ
	-- and trigger a reconfiguration of the fpga device over the network.
	-- module was desiged for C10GX but should also be compatible with Aria 10 devices.
	-- note, this is a verilog module
	CYCLONE_inst : entity work.CYCLONE
	PORT MAP(
			 lb_clk 		=> CLOCK,
			 c10_addr 	=> c_addr,
			 c10_data 	=> c_data,
			 c10_cntlr 	=> c_cntlr,
			 c10_status => c10_status,
			 c10_datar  => c10_datar,
			 we_cyclone_inst_c10_data => lb_strb,
			 ru_data_out => open);
			 
			 
	-- fimrware update registers
	lb_strb <= lb_valid AND en_c_data;
	c_status <= c10_status;
	c_datar  <= c10_datar;
			 
			 
	-- enables for RW registers 
	en_c_addr <= '1' when load = '1' and addr(11 downto 0) = x"0D5" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  c_addr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_addr='1') THEN 
		  c_addr<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_cntl <= '1' when load = '1' and addr(11 downto 0) = x"0D6" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  c_cntlr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_cntl='1') THEN 
		  c_cntlr<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_data <= '1' when load = '1' and addr(11 downto 0) = x"0D9" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  c_data<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_data='1') THEN 
		  c_data<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	--
	-- --
	-- -- --
	--==================================================================
	-- SFP I2C controls
	--==================================================================
	-- The SFP modules have the option of accessing internal control registers
	-- inside the SFP. We can monitor temperature, faults and soft controls.
	--
	-- write data
	-- UDP packet commands data to be written by I2C module.
	-- this signal will be an output from the REGS module.
	-- this includes any address or written data.
	en_sfp_dataw <= '1' when load = '1' and addr(11 downto 0) = x"0DB" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  sfp_dataw<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_sfp_dataw='1') THEN 
		  sfp_dataw<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	--
	-- read data
	-- data is read from UDP packet. This includes any status or read information.
--	en_sfp_datar <= '1' when load = '1' and addr(11 downto 0) = x"0DC" else '0';
--	PROCESS(CLOCK,reset) begin 
--	  IF(reset='0') THEN 
--		  sfp_datar<=(others => '0'); 
--	  ELSIF (CLOCK'event AND CLOCK='1' AND en_sfp_datar='1') THEN 
--		  sfp_datar<=din(31 downto 0); 
--	  END IF; 
--	END PROCESS;
	--
	-- control data
	-- UDP packet commands control data to I2C module.
	-- this signal will be an output from the REGS module.
	en_sfp_ctrl <= '1' when load = '1' and addr(11 downto 0) = x"0DD" else '0';
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  sfp_ctrl<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_sfp_ctrl='1') THEN 
		  sfp_ctrl<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	--
	out_sfp_dataw <= sfp_dataw;
	out_sfp_ctrl  <= sfp_ctrl;
	--==================================================================
	-- Microstep Resolution (for TMC)
	--==================================================================
	--
	MRES_reg_gen_i: for i in 0 to 7 generate

			MRES_reg_i: regne generic map(n => 16)
								 port map (clock	=> clock,
											  reset	=> reset,
											  clear	=> one,
											  en		=> en_MRES(i),
											  input  => din(15 downto 0),
											  output => MRES(i)
											  );
	-- Assign output
	MRES_OUT(i) <= MRES(i);
	--										  
	end generate;
	--
	-- Update enable with respect to the address
	en_MRES(0) <= '1' when load = '1' and addr(11 downto 0) = x"0DE" else '0';
	en_MRES(1) <= '1' when load = '1' and addr(11 downto 0) = x"0DF" else '0';
	en_MRES(2) <= '1' when load = '1' and addr(11 downto 0) = x"0E0" else '0';
	en_MRES(3) <= '1' when load = '1' and addr(11 downto 0) = x"0E1" else '0';
	en_MRES(4) <= '1' when load = '1' and addr(11 downto 0) = x"0E2" else '0';
	en_MRES(5) <= '1' when load = '1' and addr(11 downto 0) = x"0E3" else '0';
	en_MRES(6) <= '1' when load = '1' and addr(11 downto 0) = x"0E4" else '0';
	en_MRES(7) <= '1' when load = '1' and addr(11 downto 0) = x"0E5" else '0';
	--
	
	--==================================================================
	-- JTAG MUX SELECT, rw, 10/9/24
	--==================================================================
	--
	JTAG_reg_inst: regne generic map(n => 16)
					 port map (clock	=> clock,
								  reset	=> reset,
								  clear	=> one,
								  en		=> EN_JTAGMUX,
								  input  => din(15 downto 0),
								  output => JTAGMUX(15 downto 0)
								  );
								  
	-- double buffer output to pin
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  jtagmuxreg<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1') THEN 
		  jtagmuxreg<=JTAGMUX(15 downto 0); 
	  END IF; 
	END PROCESS;
	
	
	-- Assign output
	jtag_mux_sel_out(1 downto 0) <= NOT(jtagmuxreg(3)) & jtagmuxreg(3); -- bit 3 of xB1
	--										  
	--
	-- Update enable with respect to the address
	EN_JTAGMUX <= '1' when load = '1' and addr(11 downto 0) = x"0B1" else '0';
	
	

	
	--==================================================================
	-- Chopper Configuration (for TMC), 10/28/22
	--==================================================================
	--
--	CHOP_reg_gen_i: for i in 0 to 7 generate
--
--			CHOP_reg_i: regne generic map(n => 16)
--								 port map (clock	=> clock,
--											  reset	=> reset,
--											  clear	=> one,
--											  en		=> en_CHOPCONF(i),
--											  input  => din(15 downto 0),
--											  output => CHOPCONF(i)
--											  );
--	-- Assign output
--	CHOPCONF_OUT(i) <= CHOPCONF(i);
--	--										  
--	end generate;
--	--
--	-- Update enable with respect to the address
--	en_CHOPCONF(0) <= '1' when load = '1' and addr(11 downto 0) = x"0DF" else '0'; -- SPECIAL 2/17/23
--	
--	
--	
--	en_CHOPCONF(1) <= '1' when load = '1' and addr(11 downto 0) = x"0E7" else '0';
--	en_CHOPCONF(2) <= '1' when load = '1' and addr(11 downto 0) = x"0E8" else '0';
--	en_CHOPCONF(3) <= '1' when load = '1' and addr(11 downto 0) = x"0E9" else '0';
--	en_CHOPCONF(4) <= '1' when load = '1' and addr(11 downto 0) = x"0EA" else '0';
--	en_CHOPCONF(5) <= '1' when load = '1' and addr(11 downto 0) = x"0EB" else '0';
--	en_CHOPCONF(6) <= '1' when load = '1' and addr(11 downto 0) = x"0EC" else '0';
--	en_CHOPCONF(7) <= '1' when load = '1' and addr(11 downto 0) = x"0ED" else '0';
	--
	--
	-- --
	-- -- --
	--
	--==================================================================
	-- Waveform Viewer
	--==================================================================	
	 --RW register
	 PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  wf_4k_command<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_4k_cmd='1') THEN 
		  wf_4k_command<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	 en_4k_cmd <= '1' when load = '1' and addr(11 downto 0) = x"0E0" else '0';
	 wf_4k_status(31 downto 16) <=  x"0000"; -- others zero, RO register
	
--	ram_4_chn0 : genWave
--		generic map (K=>4095,mode=>1,N=>11,div=>16) -- trigger mode
--		port map( clock 	  => clock, 	
--				    reset_n   => reset,  
--				    sample_in => rate_reg(0),
--				    take      => wf_4k_command(0),     
--				    trigger   => '0',  -- never trigger in scope mode
--				    done      => wf_4k_status(0),     
--				    addr      => addr,     
--				    dataout   => rate_chn(0));

	-- generate 4k waveform viewer for all 8 'rate' channels.
	-- the 'motor done' strobe is the tirgger witch freezes the buffers
	gen_wf_view: for i in 0 to 7 generate
		rate_ram_4_chnI_i : genWave
		generic map (K=>4095,mode=>0,N=>11,div=>16) -- fault mode
		port map( clock 	  => clock, 	
				    reset_n   => reset,  
				    sample_in => rate_reg(i),
				    take      => wf_4k_command(i),     
				    trigger   => status_motor(i)(2), -- let motor done be the trigger
				    done      => wf_4k_status(i),     
				    addr      => addr,     
				    dataout   => rate_chn(i));
					 
		detube_ram_4_chnI_i : genWave
		generic map (K=>4095,mode=>0,N=>11,div=>16) -- fault mode
		port map( clock 	  => clock, 	
				    reset_n   => reset,  
				    sample_in => dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i)(15) & dtan_fib(i),
				    take      => wf_4k_command(i),     
				    trigger   => status_motor(i)(2), -- let motor done be the trigger
				    done      => wf_4k_status(i+8),     
				    addr      => addr,     
				    dataout   => detune_chn(i));
		end generate;
	
	
	--==================================================================
	-- Multiplexer for reading the registers out to ISA bus
	--==================================================================
	-- -- --
	-- --
	--
	-- changes from 12 GEV to 30, 12 GEV was 16 bit addressed, 3.0 is byte addressed
	-- Rama confirmed that we will be using 32 bit values for addr, din, dout
	-- 		Changed dout to be 32 bit
	--	 		Old HRT appears to be 32 bit values (not 16 bit)
	-- Signals are in the correct order
	-- 		Added the CS (current sense control for TCM stepper chip)
	--
	-- only use the lower 3 nibbles for address
	--lb_addr_r same size as lb_addr_r
	-- regbank_0 thru 3, same size as dout
		
	process (clock)
	begin
		if clock'event and clock = '1' then
			if lb_valid = '1' then
				lb_addr_r <= ADDR;
			end if;
		end if;
	end process;
	
	process (clock)  -- ADDR(7 downto 6) is 00
	begin
		if clock'event and clock = '1' then
			if lb_valid = '1' then
			
				--==================================================================
				-- ADDR(7 downto 5) is 000
				--==================================================================
			
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_0 <= accel_isar(0)                ;--x"000" 
					when "0" & x"1" => regbank_0 <= vlcty_isar(0)                ;--x"001" 
					when "0" & x"2" => regbank_0 <= steps_isa(0)                 ;--x"002" 
					when "0" & x"3" => regbank_0 <= accel_isar(1)                ;--x"003" 
					when "0" & x"4" => regbank_0 <= vlcty_isar(1)                ;--x"004" 
					when "0" & x"5" => regbank_0 <= steps_isa(1)                 ;--x"005" 
					when "0" & x"6" => regbank_0 <= accel_isar(2)                ;--x"006" 
					when "0" & x"7" => regbank_0 <= vlcty_isar(2)                ;--x"007" 
					when "0" & x"8" => regbank_0 <= steps_isa(2)                 ;--x"008" 
					when "0" & x"9" => regbank_0 <= accel_isar(3)                ;--x"009" 
					when "0" & x"A" => regbank_0 <= vlcty_isar(3)                ;--x"00A" 
					when "0" & x"B" => regbank_0 <= steps_isa(3)                 ;--x"00B" 
					when "0" & x"C" => regbank_0 <= accel_isar(4)                ;--x"00C" 
					when "0" & x"D" => regbank_0 <= vlcty_isar(4)                ;--x"00D" 
					when "0" & x"E" => regbank_0 <= steps_isa(4)                 ;--x"00E" 
					when "0" & x"F" => regbank_0 <= accel_isar(5)                ;--x"00F" 
					when "1" & x"0" => regbank_0 <= vlcty_isar(5)                ;--x"010" 
					when "1" & x"1" => regbank_0 <= steps_isa(5)                 ;--x"011" 
					when "1" & x"2" => regbank_0 <= accel_isar(6)                ;--x"012" 
					when "1" & x"3" => regbank_0 <= vlcty_isar(6)                ;--x"013" 
					when "1" & x"4" => regbank_0 <= steps_isa(6)                 ;--x"014" 
					when "1" & x"5" => regbank_0 <= accel_isar(7)                ;--x"015" 
					when "1" & x"6" => regbank_0 <= vlcty_isar(7)                ;--x"016" 
					when "1" & x"7" => regbank_0 <= steps_isa(7)                 ;--x"017" 
					when "1" & x"8" => regbank_0 <= x"0000"&command              ;--x"018" 
					when "1" & x"9" => regbank_0 <= x"0000"&command_motor(0)     ;--x"019" 
					when "1" & x"A" => regbank_0 <= x"0000"&command_motor(1)     ;--x"01A" 
					when "1" & x"B" => regbank_0 <= x"0000"&command_motor(2)     ;--x"01B" 
					when "1" & x"C" => regbank_0 <= x"0000"&command_motor(3)     ;--x"01C" 
					when "1" & x"D" => regbank_0 <= x"0000"&command_motor(4)     ;--x"01D" 
					when "1" & x"E" => regbank_0 <= x"0000"&command_motor(5)     ;--x"01E" 
					when "1" & x"F" => regbank_0 <= x"0000"&command_motor(6)     ;--x"01F" 
					when others =>     regbank_0 <= x"C001FACE"				  ;-- default case
				end case;
				
				--==================================================================
				-- ADDR(7 downto 5) is 001
				--==================================================================
				
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_1 <= x"0000"&command_motor(7)     ;--x"020" 
					when "0" & x"1" => regbank_1 <= "00"&x"0000"&status_motor(0) ;--x"021" 
					when "0" & x"2" => regbank_1 <= "00"&x"0000"&status_motor(1) ;--x"022" 
					when "0" & x"3" => regbank_1 <= "00"&x"0000"&status_motor(2) ;--x"023" 
					when "0" & x"4" => regbank_1 <= "00"&x"0000"&status_motor(3) ;--x"024" 
					when "0" & x"5" => regbank_1 <= "00"&x"0000"&status_motor(4) ;--x"025" 
					when "0" & x"6" => regbank_1 <= "00"&x"0000"&status_motor(5) ;--x"026" 
					when "0" & x"7" => regbank_1 <= "00"&x"0000"&status_motor(6) ;--x"027" 
					when "0" & x"8" => regbank_1 <= "00"&x"0000"&status_motor(7) ;--x"028" 
					when "0" & x"9" => regbank_1 <= x"0000"&status               ;--x"029" 
					when "0" & x"A" => regbank_1 <= x"0000"&version              ;--x"02A" 
					when "0" & x"B" => regbank_1 <= step_count(0)                ;--x"02B" 
					when "0" & x"C" => regbank_1 <= step_count(1)                ;--x"02C" 
					when "0" & x"D" => regbank_1 <= step_count(2)                ;--x"02D" 
					when "0" & x"E" => regbank_1 <= step_count(3)                ;--x"02E" 
					when "0" & x"F" => regbank_1 <= step_count(4)                ;--x"02F" 
					when "1" & x"0" => regbank_1 <= step_count(5)                ;--x"030" 
					when "1" & x"1" => regbank_1 <= step_count(6)                ;--x"031" 
					when "1" & x"2" => regbank_1 <= step_count(7)                ;--x"032" 
					when "1" & x"3" => regbank_1 <= laccel(0)                    ;--x"033" 
					when "1" & x"4" => regbank_1 <= lvlcty(0)                    ;--x"034" 
					when "1" & x"5" => regbank_1 <= lsteps(0)                    ;--x"035" 
					when "1" & x"6" => regbank_1 <= laccel(1)                    ;--x"036" 
					when "1" & x"7" => regbank_1 <= lvlcty(1)                    ;--x"037" 
					when "1" & x"8" => regbank_1 <= lsteps(1)                    ;--x"038" 
					when "1" & x"9" => regbank_1 <= laccel(2)                    ;--x"039" 
					when "1" & x"A" => regbank_1 <= lvlcty(2)                    ;--x"03A" 
					when "1" & x"B" => regbank_1 <= lsteps(2)                    ;--x"03B" 
					when "1" & x"C" => regbank_1 <= laccel(3)                    ;--x"03C" 
					when "1" & x"D" => regbank_1 <= lvlcty(3)                    ;--x"03D" 
					when "1" & x"E" => regbank_1 <= lsteps(3)                    ;--x"03E" 
					when "1" & x"F" => regbank_1 <= laccel(4)                    ;--x"03F" 
					when others =>     regbank_1 <= x"C001FACE"				  ;-- default case
				end case;

				--==================================================================
				-- ADDR(7 downto 5) is 010
				--==================================================================
				
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_2 <= lvlcty(4)      ; --x"040" ,
					when "0" & x"1" => regbank_2 <= lsteps(5)      ; --x"041" ,
					when "0" & x"2" => regbank_2 <= laccel(5)      ; --x"042" ,
					when "0" & x"3" => regbank_2 <= lvlcty(5)      ; --x"043" ,					
					when "0" & x"4" => regbank_2 <= lsteps(5)      ; --x"044" ,
					when "0" & x"5" => regbank_2 <= laccel(6)      ; --x"045" ,
					when "0" & x"6" => regbank_2 <= lvlcty(6)      ; --x"046" ,
					when "0" & x"7" => regbank_2 <= lsteps(6)      ; --x"047" ,
					when "0" & x"8" => regbank_2 <= laccel(7)      ; --x"048" ,
					when "0" & x"9" => regbank_2 <= lvlcty(7)      ; --x"049" ,
					when "0" & x"A" => regbank_2 <= lsteps(7)      ; --x"04A" ,
					when "0" & x"B" => regbank_2 <= x"0000"&brd_tmp; --x"04B" ,-- Board temp (maximum temperature), 16 bit
					when "0" & x"C" => regbank_2 <= x"0000"&thrt   ; --x"04C" ,-- HRT version, 16 bit
					when "0" & x"D" => regbank_2 <= dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0)(15) & dtan_fib(0); -- x"04D" , -- detune angle cavity (sent over fiber for LLRF 3.0)
					when "0" & x"E" => regbank_2 <= dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1)(15) & dtan_fib(1); -- x"04E" , -- Sign extended value reported to EPICS
					when "0" & x"F" => regbank_2 <= dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2)(15) & dtan_fib(2); -- x"04F" ,
					when "1" & x"0" => regbank_2 <= dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3)(15) & dtan_fib(3); -- x"050" ,
					when "1" & x"1" => regbank_2 <= dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4)(15) & dtan_fib(4); -- x"051" ,
					when "1" & x"2" => regbank_2 <= dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5)(15) & dtan_fib(5); -- x"052" ,
					when "1" & x"3" => regbank_2 <= dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6)(15) & dtan_fib(6); -- x"053" ,
					when "1" & x"4" => regbank_2 <= dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7)(15) & dtan_fib(7); -- x"054" ,
					when "1" & x"5" => regbank_2 <= disc_fib(0)(27) & disc_fib(0)(27) & disc_fib(0)(27) & disc_fib(0)(27) & disc_fib(0) ;-- x"055", -- discrim vavity, with sign etend (in case of negative values)
					when "1" & x"6" => regbank_2 <= disc_fib(1)(27) & disc_fib(1)(27) & disc_fib(1)(27) & disc_fib(1)(27) & disc_fib(1) ;-- x"056", --	these are 28 bit values
					when "1" & x"7" => regbank_2 <= disc_fib(2)(27) & disc_fib(2)(27) & disc_fib(2)(27) & disc_fib(2)(27) & disc_fib(2) ;-- x"057",
					when "1" & x"8" => regbank_2 <= disc_fib(3)(27) & disc_fib(3)(27) & disc_fib(3)(27) & disc_fib(3)(27) & disc_fib(3) ;-- x"058",
					when "1" & x"9" => regbank_2 <= disc_fib(4)(27) & disc_fib(4)(27) & disc_fib(4)(27) & disc_fib(4)(27) & disc_fib(4) ;-- x"059",
					when "1" & x"A" => regbank_2 <= disc_fib(5)(27) & disc_fib(5)(27) & disc_fib(5)(27) & disc_fib(5)(27) & disc_fib(5) ;-- x"05A",
					when "1" & x"B" => regbank_2 <= disc_fib(6)(27) & disc_fib(6)(27) & disc_fib(6)(27) & disc_fib(6)(27) & disc_fib(6) ;-- x"05B",
					when "1" & x"C" => regbank_2 <= disc_fib(7)(27) & disc_fib(7)(27) & disc_fib(7)(27) & disc_fib(7)(27) & disc_fib(7) ;-- x"05C",
					when "1" & x"D" => regbank_2 <= x"0000"&step_hz_isa(0)      ;--x"05D", -- steps per HZ, 16 bit value
					when "1" & x"E" => regbank_2 <= x"0000"&step_hz_isa(1)      ;--x"05E",
					when "1" & x"F" => regbank_2 <= x"0000"&step_hz_isa(2)      ;--x"05F",
					when others =>     regbank_2 <= x"C001FACE" 				 ;-- default case
				end case;
				
				--==================================================================
				-- ADDR(7 downto 5) is 011
				--==================================================================
					
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_3 <= x"0000"&step_hz_isa(3)      ;--x"060",
					when "0" & x"1" => regbank_3 <= x"0000"&step_hz_isa(4)      ;--x"061",
					when "0" & x"2" => regbank_3 <= x"0000"&step_hz_isa(5)      ;--x"062",
					when "0" & x"3" => regbank_3 <= x"0000"&step_hz_isa(6)      ;--x"063",
					when "0" & x"4" => regbank_3 <= x"0000"&step_hz_isa(7)      ;--x"064",
					when "0" & x"5" => regbank_3 <= x"0000"&deta_hi_isa(0)      ;--x"065",-- detune angle HI, 16 bit value
					when "0" & x"6" => regbank_3 <= x"0000"&deta_hi_isa(1)      ;--x"066",
					when "0" & x"7" => regbank_3 <= x"0000"&deta_hi_isa(2)      ;--x"067",
					when "0" & x"8" => regbank_3 <= x"0000"&deta_hi_isa(3)      ;--x"068",
					when "0" & x"9" => regbank_3 <= x"0000"&deta_hi_isa(4)      ;--x"069",
					when "0" & x"A" => regbank_3 <= x"0000"&deta_hi_isa(5)      ;--x"06A",
					when "0" & x"B" => regbank_3 <= x"0000"&deta_hi_isa(6)      ;--x"06B",
					when "0" & x"C" => regbank_3 <= x"0000"&deta_hi_isa(7)      ;--x"06C",
					when "0" & x"D" => regbank_3 <= x"0000"&deta_lo_isa(0)      ;--x"06D",-- detune angle LO, 16 bit value
					when "0" & x"E" => regbank_3 <= x"0000"&deta_lo_isa(1)      ;--x"06E",
					when "0" & x"F" => regbank_3 <= x"0000"&deta_lo_isa(2)      ;--x"06F",
					when "1" & x"0" => regbank_3 <= x"0000"&deta_lo_isa(3)      ;--x"070",
					when "1" & x"1" => regbank_3 <= x"0000"&deta_lo_isa(4)      ;--x"071",
					when "1" & x"2" => regbank_3 <= x"0000"&deta_lo_isa(5)      ;--x"072",
					when "1" & x"3" => regbank_3 <= x"0000"&deta_lo_isa(6)      ;--x"073",
					when "1" & x"4" => regbank_3 <= x"0000"&deta_lo_isa(7)      ;--x"074",
					when "1" & x"5" => regbank_3 <= x"0000"&disc_hi_isa(0)      ;--x"075",-- DISC HI, 16 bit value
					when "1" & x"6" => regbank_3 <= x"0000"&disc_hi_isa(1)      ;--x"076",
					when "1" & x"7" => regbank_3 <= x"0000"&disc_hi_isa(2)      ;--x"077",
					when "1" & x"8" => regbank_3 <= x"0000"&disc_hi_isa(3)      ;--x"078",
					when "1" & x"9" => regbank_3 <= x"0000"&disc_hi_isa(4)      ;--x"079",
					when "1" & x"A" => regbank_3 <= x"0000"&disc_hi_isa(5)      ;--x"07A",
					when "1" & x"B" => regbank_3 <= x"0000"&disc_hi_isa(6)      ;--x"07B",
					when "1" & x"C" => regbank_3 <= x"0000"&disc_hi_isa(7)      ;--x"07C",
					when "1" & x"D" => regbank_3 <= x"0000"&disc_lo_isa(0)      ;--x"07D",-- DISC LO, 16 bit value
					when "1" & x"E" => regbank_3 <= x"0000"&disc_lo_isa(1)      ;--x"07E", 
					when "1" & x"F" => regbank_3 <= x"0000"&disc_lo_isa(2)      ;--x"07F",
					when others =>     regbank_3 <= x"C001FACE" 				 ;-- default case
				end case;

				--==================================================================
				-- ADDR(7 downto 5) is 100
				--==================================================================

				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_4 <= x"0000"&disc_lo_isa(3)      ;--x"080",
					when "0" & x"1" => regbank_4 <= x"0000"&disc_lo_isa(4)      ;--x"081",
					when "0" & x"2" => regbank_4 <= x"0000"&disc_lo_isa(5)      ;--x"082",
					when "0" & x"3" => regbank_4 <= x"0000"&disc_lo_isa(6)      ;--x"083",
					when "0" & x"4" => regbank_4 <= x"0000"&disc_lo_isa(7)      ;--x"084",
					when "0" & x"5" => regbank_4 <= x"00"&epcs_addr_isa         ;--x"085", -- EPCS address, 24 bit
					when "0" & x"6" => regbank_4 <= x"000000"&epcs_data_isa     ;--x"086", -- EPCS DATA, 8 bit
					when "0" & x"7" => regbank_4 <= x"000000"&epcsr             ;--x"087", -- EPCS READ DATA, 8 bit
					when "0" & x"8" => regbank_4 <= sgn_steps(0)                ;--x"088", -- Signed steps, 32 bit
					when "0" & x"9" => regbank_4 <= sgn_steps(1)                ;--x"089",
					when "0" & x"A" => regbank_4 <= sgn_steps(2)                ;--x"08A",
					when "0" & x"B" => regbank_4 <= sgn_steps(3)                ;--x"08B",
					when "0" & x"C" => regbank_4 <= sgn_steps(4)                ;--x"08C",
					when "0" & x"D" => regbank_4 <= sgn_steps(5)                ;--x"08D",
					when "0" & x"E" => regbank_4 <= sgn_steps(6)                ;--x"08E",
					when "0" & x"F" => regbank_4 <= sgn_steps(7)                ;--x"08F",
					when "1" & x"0" => regbank_4 <= abs_steps(0)                ;--x"090", -- absolute steps, 32 bit
					when "1" & x"1" => regbank_4 <= abs_steps(1)                ;--x"091",
					when "1" & x"2" => regbank_4 <= abs_steps(2)                ;--x"092",
					when "1" & x"3" => regbank_4 <= abs_steps(3)                ;--x"093",
					when "1" & x"4" => regbank_4 <= abs_steps(4)                ;--x"094",
					when "1" & x"5" => regbank_4 <= abs_steps(5)                ;--x"095",
					when "1" & x"6" => regbank_4 <= abs_steps(6)                ;--x"096",
					when "1" & x"7" => regbank_4 <= abs_steps(7)                ;--x"097",
					when "1" & x"8" => regbank_4 <= sgn_lmt(0)                  ;--x"098", -- signed steps limit, 32 bit
					when "1" & x"9" => regbank_4 <= sgn_lmt(1)                  ;--x"099",
					when "1" & x"A" => regbank_4 <= sgn_lmt(2)                  ;--x"09A",
					when "1" & x"B" => regbank_4 <= sgn_lmt(3)                  ;--x"09B",
					when "1" & x"C" => regbank_4 <= sgn_lmt(4)                  ;--x"09C",
					when "1" & x"D" => regbank_4 <= sgn_lmt(5)                  ;--x"09D",
					when "1" & x"E" => regbank_4 <= sgn_lmt(6)                  ;--x"09E",
					when "1" & x"F" => regbank_4 <= sgn_lmt(7)                  ;--x"09F",
					when others =>      regbank_4 <= x"C001FACE" 				 ;-- default case
				end case;
					
				--==================================================================
				-- ADDR(7 downto 5) is 101
				--==================================================================

				case ADDR(4 downto 0) is					
					when "0" & x"0" => regbank_5 <= abs_lmt(0)                  ;--x"0A0", -- absolute step limit, 32 bit
					when "0" & x"1" => regbank_5 <= abs_lmt(1)                  ;--x"0A1",
					when "0" & x"2" => regbank_5 <= abs_lmt(2)                  ;--x"0A2",
					when "0" & x"3" => regbank_5 <= abs_lmt(3)                  ;--x"0A3",
					when "0" & x"4" => regbank_5 <= abs_lmt(4)                  ;--x"0A4",
					when "0" & x"5" => regbank_5 <= abs_lmt(5)                  ;--x"0A5",
					when "0" & x"6" => regbank_5 <= abs_lmt(6)                  ;--x"0A6",
					when "0" & x"7" => regbank_5 <= abs_lmt(7)                  ;--x"0A7",
					when "0" & x"8" => regbank_5 <= x"0000"&abs_stp_sub_int(0)  ;--x"0A8", -- Absolute subtractor, 16 bit (always a positive input)
					when "0" & x"9" => regbank_5 <= x"0000"&abs_stp_sub_int(1)  ;--x"0A9",
					when "0" & x"A" => regbank_5 <= x"0000"&abs_stp_sub_int(2)  ;--x"0AA",
					when "0" & x"B" => regbank_5 <= x"0000"&abs_stp_sub_int(3)  ;--x"0AB",
					when "0" & x"C" => regbank_5 <= x"0000"&abs_stp_sub_int(4)  ;--x"0AC",
					when "0" & x"D" => regbank_5 <= x"0000"&abs_stp_sub_int(5)  ;--x"0AD",
					when "0" & x"E" => regbank_5 <= x"0000"&abs_stp_sub_int(6)  ;--x"0AE",
					when "0" & x"F" => regbank_5 <= x"0000"&abs_stp_sub_int(7)  ;--x"0AF",
					when "1" & x"0" => regbank_5 <= x"00000000"                 ;--x"0B0", --PZT Value Cavity, 16 bit was pzt_val
					when "1" & x"1" => regbank_5 <= x"0000"&JTAGMUX(15 downto 0);--x"0B1", jtag_mux_select
					when "1" & x"2" => regbank_5 <= x"00000000"                 ;--x"0B2",
					when "1" & x"3" => regbank_5 <= x"00000000"                 ;--x"0B3",
					when "1" & x"4" => regbank_5 <= x"00000000"                 ;--x"0B4",
					when "1" & x"5" => regbank_5 <= x"00000000"                 ;--x"0B5",
					when "1" & x"6" => regbank_5 <= x"00000000"                 ;--x"0B6",
					when "1" & x"7" => regbank_5 <= x"00000000"                 ;--x"0B7",
					when "1" & x"8" => regbank_5 <= x"0000"&pzt_hi_int(0)       ;--x"0B8", -- PZT HIGH limit cavity, 16 bit
					when "1" & x"9" => regbank_5 <= x"0000"&pzt_hi_int(1)       ;--x"0B9",
					when "1" & x"A" => regbank_5 <= x"0000"&pzt_hi_int(2)       ;--x"0BA",
					when "1" & x"B" => regbank_5 <= x"0000"&pzt_hi_int(3)       ;--x"0BB",
					when "1" & x"C" => regbank_5 <= x"0000"&pzt_hi_int(4)       ;--x"0BC",
					when "1" & x"D" => regbank_5 <= x"0000"&pzt_hi_int(5)       ;--x"0BD",
					when "1" & x"E" => regbank_5 <= x"0000"&pzt_hi_int(6)       ;--x"0BE",
					when "1" & x"F" => regbank_5 <= x"0000"&pzt_hi_int(7)       ;--x"0BF",
					when others =>      regbank_5 <= x"C001FACE" 				 ;-- default case
				end case;
	
				--==================================================================
				-- ADDR(7 downto 5) is 110
				--==================================================================
				
				case ADDR(4 downto 0) is
					when "0" & x"0" => regbank_6 <= x"0000"&pzt_lo_int(0)    ;--x"0C0", -- PZT LOW limit cavity, 16 bit
					when "0" & x"1" => regbank_6 <= x"0000"&pzt_lo_int(1)    ;--x"0C1",
					when "0" & x"2" => regbank_6 <= x"0000"&pzt_lo_int(2)    ;--x"0C2",
					when "0" & x"3" => regbank_6 <= x"0000"&pzt_lo_int(3)    ;--x"0C3",
					when "0" & x"4" => regbank_6 <= x"0000"&pzt_lo_int(4)    ;--x"0C4",
					when "0" & x"5" => regbank_6 <= x"0000"&pzt_lo_int(5)    ;--x"0C5",
					when "0" & x"6" => regbank_6 <= x"0000"&pzt_lo_int(6)    ;--x"0C6",
					when "0" & x"7" => regbank_6 <= x"0000"&pzt_lo_int(7)    ;--x"0C7",
					when "0" & x"8" => regbank_6 <= x"0000"&motorCurr(0)     ;--x"0C8", -- Motor Current (controls TMC max current), 16 bit
					when "0" & x"9" => regbank_6 <= x"0000"&motorCurr(1)     ;--x"0C9",
					when "0" & x"A" => regbank_6 <= x"0000"&motorCurr(2)     ;--x"0CA",
					when "0" & x"B" => regbank_6 <= x"0000"&motorCurr(3)     ;--x"0CB",
					when "0" & x"C" => regbank_6 <= x"0000"&motorCurr(4)     ;--x"0CC",
					when "0" & x"D" => regbank_6 <= x"0000"&motorCurr(5)     ;--x"0CD",
					when "0" & x"E" => regbank_6 <= x"0000"&motorCurr(6)     ;--x"0CE",
					when "0" & x"F" => regbank_6 <= x"0000"&motorCurr(7)     ;--x"0CF",
					when "1" & x"0" => regbank_6 <= "00"&x"00000"& c10gx_tmp ;--x"0D0", -- temp signal is 10 bits, dout expects 32 bits
					when "1" & x"1" => regbank_6 <= x"000000"& EEPROM_ctrl   ;--x"0D1", -- 8 bit control for eeprom
					when "1" & x"2" => regbank_6 <= x"00000"&  EEPROM_addr   ;--x"0D2", -- 12 bit eeprom addr (4k of 1 byte values = 32k bit)
					when "1" & x"3" => regbank_6 <= x"000000"& EEPROM_data   ;--x"0D3", -- byte to write
					when "1" & x"4" => regbank_6 <= x"000000"& EEPROM_datar  ;--x"0D4", -- byte that was read
					when "1" & x"5" => regbank_6 <= c_addr					  ;--x"0D5", -- EPCQ address
					when "1" & x"6" => regbank_6 <= c_cntlr	  	          ;--x"0D6", -- control bits for read writing and configurting EPCQ
					when "1" & x"7" => regbank_6 <= c10_status				  ;--x"0D7", -- checksum and status		 
					when "1" & x"8" => regbank_6 <= c10_datar 				  ;--x"0D8", -- read data
					when "1" & x"9" => regbank_6 <= c_data					  ;--x"0D9", -- data to write
					when "1" & x"A" => regbank_6 <= STPRSTR				  ;--x"0DA", -- status register for epcis PVs
					when "1" & x"B" => regbank_6 <= sfp_dataw				  ;--x"0DB", -- SFP data write register
					when "1" & x"C" => regbank_6 <= sfp_datar				  ;--x"0DC", -- SFP data write register
					when "1" & x"D" => regbank_6 <= sfp_ctrl				  ;--x"0DD", -- SFP data write register
					when "1" & x"E" => regbank_6 <= x"0000"&MRES(0)          ;--when x"0DE"
					--when "1" & x"F" => regbank_6 <= x"0000"&CHOPCONF(0)		 ;--here it is atually DF
					
					
--					when "10" & x"B" => regbank_6 <= x"0000"&CHOPCONF(5)		 ;--when x"0EB"
--					when "10" & x"C" => regbank_6 <= x"0000"&CHOPCONF(6)		 ;--when x"0EC"
--					when "10" & x"D" => regbank_6 <= x"0000"&CHOPCONF(7)		 ;--when x"0ED"
					when others =>      regbank_6 <= x"00000000" 				 ;-- default case
				end case;
			
			   --==================================================================
				-- ADDR(7 downto 5) is 111
				--==================================================================

				case ADDR(4 downto 0) is					
					when "0" & x"0" => regbank_7 <= wf_4k_command               ;--x"0E0",
					when "0" & x"1" => regbank_7 <= wf_4k_status                ;--x"0E1",

					when "1" & x"0" => regbank_7 <= "00" & x"00000"&SINE_POS(0)  ;--when x"0F0"
					when "1" & x"1" => regbank_7 <= "00" & x"00000"&SINE_POS(1)  ;--when x"0F1"
					when "1" & x"2" => regbank_7 <= "00" & x"00000"&SINE_POS(2)  ;--when x"0F2"
					when "1" & x"3" => regbank_7 <= "00" & x"00000"&SINE_POS(3)  ;--when x"0F3"
					when "1" & x"4" => regbank_7 <= "00" & x"00000"&SINE_POS(4)  ;--when x"0F4"
					when "1" & x"5" => regbank_7 <= "00" & x"00000"&SINE_POS(5)  ;--when x"0F5"
					when "1" & x"6" => regbank_7 <= "00" & x"00000"&SINE_POS(6)  ;--when x"0F6"
					when "1" & x"7" => regbank_7 <= "00" & x"00000"&SINE_POS(7)  ;--when x"0F7"
 
--					when "0" & x"2" => regbank_7 <= abs_lmt(2)                  ;--x"0E2",
--					when "0" & x"3" => regbank_7 <= abs_lmt(3)                  ;--x"0E3",
--					when "0" & x"4" => regbank_7 <= abs_lmt(4)                  ;--x"0E4",
--					when "0" & x"5" => regbank_7 <= abs_lmt(5)                  ;--x"0E5",
--					when "0" & x"6" => regbank_7 <= abs_lmt(6)                  ;--x"0E6",
--					when "0" & x"7" => regbank_7 <= abs_lmt(7)                  ;--x"0E7",
--					when "0" & x"8" => regbank_7 <= x"0000"&abs_stp_sub_int(0)  ;--x"0E8",
--					when "0" & x"9" => regbank_7 <= x"0000"&abs_stp_sub_int(1)  ;--x"0E9",
--					when "0" & x"A" => regbank_7 <= x"0000"&abs_stp_sub_int(2)  ;--x"0EA",
--					when "0" & x"B" => regbank_7 <= x"0000"&abs_stp_sub_int(3)  ;--x"0EB",
--					when "0" & x"C" => regbank_7 <= x"0000"&abs_stp_sub_int(4)  ;--x"0EC",
--					when "0" & x"D" => regbank_7 <= x"0000"&abs_stp_sub_int(5)  ;--x"0ED",
--					when "0" & x"E" => regbank_7 <= x"0000"&abs_stp_sub_int(6)  ;--x"0EE",
--					when "0" & x"F" => regbank_7 <= x"0000"&abs_stp_sub_int(7)  ;--x"0EF",
--					when "1" & x"0" => regbank_7 <= rate_reg(0)                 ;--x"0F0",
--					when "1" & x"1" => regbank_7 <= rate_reg(1)                 ;--x"0F1",
--					when "1" & x"2" => regbank_7 <= rate_reg(2)                 ;--x"0F2",
--					when "1" & x"3" => regbank_7 <= rate_reg(3)                 ;--x"0F3",
--					when "1" & x"4" => regbank_7 <= rate_reg(4)                 ;--x"0F4",
--					when "1" & x"5" => regbank_7 <= rate_reg(5)                 ;--x"0F5",
--					when "1" & x"6" => regbank_7 <= rate_reg(6)                 ;--x"0F6",
--					when "1" & x"7" => regbank_7 <= rate_reg(7)                 ;--x"0F7",
--					when "1" & x"8" => regbank_7 <= x"0000"&pzt_hi_int(0)       ;--x"0F8", 
--					when "1" & x"9" => regbank_7 <= x"0000"&pzt_hi_int(1)       ;--x"0F9",
--					when "1" & x"A" => regbank_7 <= x"0000"&pzt_hi_int(2)       ;--x"0FA",
--					when "1" & x"B" => regbank_7 <= x"0000"&pzt_hi_int(3)       ;--x"0FB",
--					when "1" & x"C" => regbank_7 <= x"0000"&pzt_hi_int(4)       ;--x"0FC",
--					when "1" & x"D" => regbank_7 <= x"0000"&pzt_hi_int(5)       ;--x"0FD",
--					when "1" & x"E" => regbank_7 <= x"0000"&pzt_hi_int(6)       ;--x"0FE",
--					when "1" & x"F" => regbank_7 <= x"0000"&pzt_hi_int(7)       ;--x"0FF",
					when others =>     regbank_7 <= x"C001FACE" 				      ;-- default case
				end case;
				
				
			end if; -- end for strobe /lb_valid signal
			
			--==================================================================
			-- waveform Mux, configured for 4k waveforms
			--==================================================================
			-- 4k block ram buffers
			--
			-- ADDR(16 downto 12)		Buffer
			-- 00000							HRT registers (other multiplexing going on here)
			-- 00001 						rate_chn0
			-- 00010 						rate_chn1
			-- 00011 						rate_chn2
			-- 00100 						rate_chn3
			-- 00101 						rate_chn4
			-- 00110 						rate_chn5
			-- 00111 						rate_chn6
			-- 01000 						rate_chn7
			-- 01001							detune_chn0
			-- 01010							detune_chn1
			-- 01011							detune_chn2
			-- 01100							detune_chn3
			-- 01101							detune_chn4
			-- 01110							detune_chn5
			-- 01111							detune_chn6
			-- 10000							detune_chn7
			--==================================================================
			-- Main MUX
			--==================================================================
			-- notice that we are using lb_addr_r which is a registered version of ADDR
			case lb_addr_r(16 downto 12) is
				-- case for wave form viewer, 11 downto 0 is the 4k address being read
				when "00001"   => dout <= rate_chn(0); 
				when "00010"   => dout <= rate_chn(1);
				when "00011"   => dout <= rate_chn(2);
				when "00100"   => dout <= rate_chn(3);
				when "00101"   => dout <= rate_chn(4);
				when "00110"   => dout <= rate_chn(5);
				when "00111"   => dout <= rate_chn(6);
				when "01000"   => dout <= rate_chn(7);
				when "01001"   => dout <= detune_chn(0); 
				when "01010"   => dout <= detune_chn(1);
				when "01011"   => dout <= detune_chn(2);
				when "01100"   => dout <= detune_chn(3);
				when "01101"   => dout <= detune_chn(4);
				when "01110"   => dout <= detune_chn(5);
				when "01111"   => dout <= detune_chn(6);
				when "10000"   => dout <= detune_chn(7);
				when others   => 
					-- others case for generic registers (not waveforms
					case lb_addr_r(7 downto 5) is
					when "000"   => dout <= regbank_0;
					when "001"   => dout <= regbank_1;
					when "010"   => dout <= regbank_2;
					when "011"   => dout <= regbank_3;
					when "100"   => dout <= regbank_4;
					when "101"   => dout <= regbank_5;
					when "110"   => dout <= regbank_6;
					when "111"   => dout <= regbank_7;
					when others  => dout <= x"00000000"; -- default if no valid options are selected.
					end case;				
			end case;
		end if; -- end for rising edge check
	end process;				
	--
	--
	-- Version Notes:
	-- 	with no inversion for deta and disc, crash is enabled based on the limit switch and direction, 
	-- 	pzt is included in the control algorithm, an option to enable or disable the absolute and signed 
	-- 	counter for tracking steps, slow acceleration and velocity based on a status bit from fcc
	status	<=  "000" & x"000" & heartbeat;
	-- x"000E" LLRF 3.0 versions
	version	<= x"0067"; -- LLRF 3.0 Resonance 6/3/22 (limit switch mask), 
								-- 7/26/22,  switch to marvel chip instead of SFP, FW version x11
								-- 10/18/22, microstepping resolution bits added, FW Version x12
								-- 10/28/22, chopper configuration added, FW x13
								-- 1/23/23,  new chopper and micro stepping, FW x14
								-- 1/23/23,  improved memory mux, 64 micro step per full step, FW x17
								-- 1/30/23, experimental load for varriable micro step rate and chopper configurations. FW, x18
								-- 3/28/23, restored chopper settings to x11 settings, added waveforms, slowed cyclone flash mem clock to IP spec (LTE 20MHz)
								--				load has variable micro stepping and (maskable) low current hold feature.
								-- 4/13/23, Fixed cyclone.v module to work with newer version of python (caused by red hat version upgrade) FWx23
								--9/5/23, x24,  making default hold current is full. mask has to be applied to allow for low current when not moving.
								--						and abs subtract slow decounter.
								-- 11/7/24, removing AC13/100 MHz clock x67
	thrt     <= x"0006"; -- LLRF 3.0 Resonance 3/2/2021
	--
	--==================================================================
	-- HI OR LOW limit detect 
	--==================================================================
	--
	limit_gen_i: for i in 0 to 7 generate
		limit_isa(i)	<= high_limit(i) or low_limit(i);	
	end generate;
	--
	-- Assign output
	limit	<= limit_isa;
	--
	-- --
	-- -- --
end architecture behavior;