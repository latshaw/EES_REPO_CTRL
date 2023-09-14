LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;   
-- added for reading text vectors for tb
--use STD.textio.all;
--use ieee.std_logic_textio.all;                 

ENTITY stepper_TB IS
END stepper_TB;
ARCHITECTURE stepper_TB_ARCH OF stepper_TB IS

signal reset            : STD_LOGIC;
signal clock            : STD_LOGIC;
signal direction        : STD_LOGIC;
signal move             : STD_LOGIC;
signal done_isa         : STD_LOGIC;
signal stop             : STD_LOGIC;
signal clr_sgn_step     : STD_LOGIC;
signal clr_abs_step     : STD_LOGIC;
signal en_sub_abs       : STD_LOGIC;
signal en_sub_sgn       : STD_LOGIC;
signal accel_in         : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal period           : STD_LOGIC_VECTOR(26 DOWNTO 0);
signal steps_in         : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sub_stp          : STD_LOGIC_VECTOR(15 DOWNTO 0);
signal vlcty_in         : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal step             : STD_LOGIC;
signal dir              : STD_LOGIC;
signal motion_led       : STD_LOGIC;
signal done_move        : STD_LOGIC;
signal abs_step         : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal accum_NA         : STD_LOGIC_VECTOR(12 DOWNTO 0);
signal clkrate_NA       : STD_LOGIC_VECTOR(26 DOWNTO 0);
signal laccel           : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal lsteps           : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal lvlcty           : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal sgn_step         : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal step_count_out   : STD_LOGIC_VECTOR(31 DOWNTO 0);

COMPONENT stepper_driver
	generic (testBench : STD_LOGIC := '0');
	PORT(reset         : IN STD_LOGIC;
		 clock          : IN STD_LOGIC;
		 direction      : IN STD_LOGIC; -- DIR_OUT, from data_select
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
		 step_count_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  -- step_count, to regs
	);
END COMPONENT;

BEGIN

	stepper_I : stepper_driver
	generic map (testBench=>'1') -- use test bench, faster counts (times 1000)
	PORT MAP(
	reset          => reset         ,
	clock          => clock         ,
	direction      => direction     , 
	move           => move          , 
	done_isa       => done_isa      , 
	stop           => stop          , 
	clr_sgn_step   => clr_sgn_step  , 
	clr_abs_step   => clr_abs_step  , 
	en_sub_abs     => en_sub_abs    , 
	en_sub_sgn     => en_sub_sgn    , 
	accel_in       => accel_in      ,
	period         => period        ,
	steps_in       => steps_in      ,
	sub_stp        => sub_stp       ,
	vlcty_in       => vlcty_in      ,
	step           => step          , 
	dir            => dir           , 
	motion_led     => motion_led    , 
	done_move      => done_move     ,
	abs_step       => abs_step      ,
	accum_NA       => accum_NA      ,
	clkrate_NA     => clkrate_NA    ,
	laccel         => laccel        ,
	lsteps         => lsteps        ,
	lvlcty         => lvlcty        ,
	sgn_step       => sgn_step      ,
	step_count_out => step_count_out);

clk : PROCESS                                                                                 
BEGIN             
	-- 125 MHz clock, 8 ns periods
	CLOCK <= '0'; wait for 4 ns;
	CLOCK <= '1'; wait for 4 ns; 
END PROCESS clk;

always : PROCESS

BEGIN
	reset <= '0';
	direction    <='0';
	move         <='0';
	done_isa     <='0';
	stop         <='0';
	clr_sgn_step <='0';
	clr_abs_step <='0';
	en_sub_abs   <='0';
	en_sub_sgn   <='0';
				 
	accel_in     <= x"00000003";
	--period       <= "00" & x"FFFFFF";
	steps_in     <= x"000001FF";
	sub_stp      <= x"0000";
	vlcty_in     <= x"0000000F";
	
	wait for 100 ns;
	reset <= '1';
	wait for 100 ns;
	move         <='1';
	wait for 100 ns;
	move         <='0';
	
	
	
	wait for 1000*800 ns;
	
	assert false report "End Sim " severity failure;
	
END PROCESS always;    
                                      
END stepper_TB_ARCH;
