-- updated for LLRF 3.0, comments added for context 12/4/2020 JAL
-- moved arc buffer registers to end of HRT 4/6/21 JAL
-- JAL, 6/23/21, dout needs to be 32 bit for epics but some of the adc values are
-- unsigned 16 bit and some are signed 16 bit. We must be careful with the sign extentions. 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.numeric_std.all; -- for working with integers
USE WORK.COMPONENTS.ALL;

ENTITY REGS IS
	PORT(HB_ISA : IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;	 
		 
		 DIN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ADDR : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 LOAD : IN STD_LOGIC;
		 		 
		 TMPWRM_DATA : IN REG16_ARRAY;
		 TMPCLD_DATA : IN REG16_ARRAY;
		 ARC_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);	
		 ARC_DATA : IN REG16_ARRAY;
		 --ARC_BUFF_READY : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- removed 12/15/2020, this functionality is now handled within the Regs module
		 
		 VAC_FAULT_STATUS : IN STD_LOGIC_VECTOR(17 DOWNTO 0);		 
		 
		 DIG_TEMP : IN STD_LOGIC_VECTOR(12 DOWNTO 0);		 	 
		 	 
		 TMPCLD_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);		 
		 TMPWRM_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 
		 INTEN_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 FC_FSD_FAULT_STATUS : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 MAIN_FSD_FAULT_STATUS : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 
		 FIRST_CAVITY_FAULT	: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 
		 ARC_BUFF_DATA : IN REG16_ARRAY;	 
		 
		 ARC_LIMIT : OUT REG16_ARRAY;
		 ARC_TIMER : OUT REG16_ARRAY;
		 MASK_ARC_FAULT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ARC_FLT_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		 
		 ARC_TRIG_DELAY : OUT REG16_ARRAY;
		 ARC_STOP : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 
		 TMPCLD_LIMIT : OUT REG16_ARRAY;
		 TMPWRM_LIMIT : OUT REG16_ARRAY;
		 MASK_TMP_FAULT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 TMPCLD_FLT_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_FLT_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		 
		 
		 ARC_TST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPCLD_TST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 TMPWRM_TST : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 
		 FC_FSD_MASK : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_MASK : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 CAV_FLT_FPGA : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 FC_FSD_CLR : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_CLR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 MASK_VAC_FAULT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 VAC_FLT_CLR : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);		 
		 REG_RESET : OUT STD_LOGIC;
		 
		 DOUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0); -- JAL 6/23/21, updated to be 32 bits to support sign ext.
		 ARC_PWR : OUT REG16_ARRAY;
		 ARC_TST_FLT : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 ready_arc	 : IN STD_LOGIC_VECTOR(7 downto 0); --Not used anymore?
		 arc_adc_busy : IN STD_LOGIC_VECTOR(7 downto 0);
		
		 HELIUM_INTERLOCK_LED : OUT STD_LOGIC; -- for front panel leds. fault is latched inside regs module
		 lb_valid		: IN STD_LOGIC;
		 jtag_mux_sel_out  : OUT STD_LOGIC_VECTOR(1 downto 0);
		 intrstr_C100_out : OUT STD_LOGIC;
		 ethChipID         : IN STD_LOGIC_VECTOR(15 downto 0) -- 1/8/26, will tell which ethernet chip is used
--		 out_c_addr		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_cntlr	    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_status        : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_c_data		    : OUT std_logic_VECTOR(31 DOWNTO 0);
--		 c10_datar	       : IN  std_logic_VECTOR(31 DOWNTO 0);
--		 out_en_c_data	    : OUT std_logic		 
		 );
END ENTITY REGS;

ARCHITECTURE BEHAVIOR OF REGS IS
-- added 12/15/2020 by JAL
--component arc_buffer_module IS
--	generic(n : integer := 64); 
--	PORT(CLOCK 		        : IN STD_LOGIC;
--		 RESET 		        : IN STD_LOGIC;
--		 ready_arc	        : IN STD_LOGIC;
--		 ARC_FLT_CLR_OUT    : IN STD_LOGIC;
--		 ARC_FAULT_STATUS	  : IN STD_LOGIC; -- reference as ARC_FAULT_STATUS(I+8) in regs module
--		 MASK_ARC_FAULT_OUT : IN STD_LOGIC;
--		 ARC_STOP_OUT		  : IN STD_LOGIC;
--		 ARC_DELAY_ISA		  : IN STD_LOGIC_VECTOR(15 downto 0);
--		 ARC_DATA			  : IN STD_LOGIC_VECTOR(15 downto 0);
--		 UDP_READY			  : OUT STD_LOGIC; -- HI = udp ready to be read
--		 ARC_BUFFER         : OUT STD_LOGIC_VECTOR((n*16-1) DOWNTO 0));
--END component; 

component arc_buffer_module IS
	generic(n : integer := 256);      -- generic is not needed
	PORT(clock 	: IN  STD_LOGIC;      -- main clock
		  reset_n  : IN  STD_LOGIC;    -- active low reset
		  TAKE		: IN  STD_LOGIC;   -- active high trigger to indicate that data should be saved to buffer on 8k buffer
		  DONE		: OUT STD_LOGIC;   -- DONE, lets epics know that data is ready on 8k buffer
		  ADDR		: IN  STD_LOGIC_VECTOR(12 downto 0); -- requested read address 8k buffer
		  DATA		: OUT STD_LOGIC_VECTOR(15 downto 0); -- data at memeory location (to be sent over UDP module) 8k buffer
		  ADC_DATA  : IN STD_LOGIC_VECTOR(15 downto 0);
		  READY		: OUT STD_LOGIC;   -- New data writtent to buffer is ready
		  adc_busy  : IN  STD_LOGIC;
		  offset_addr : IN STD_LOGIC_VECTOR(12 downto 0));   -- offset address, how many samples after a trigger should be saved (0 means all samples are per trigger, F's-1 all samples after trigger)
END component; 


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

SIGNAL intrstr_C100           : STD_LOGIC;

SIGNAL EN_ARC_LIMIT_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_LIMIT_ISA				: REG16_ARRAY;

SIGNAL EN_ARC_TIMER_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_TIMER_ISA				: REG16_ARRAY;

SIGNAL EN_ARC_DELAY_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_DELAY_ISA				: REG16_ARRAY;

SIGNAL EN_ARC_STOP_ISA			: STD_LOGIC;
SIGNAL ARC_STOP_ISA				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_STOP_INT1				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_STOP_INT2				: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_TMPCLD_LIMIT_ISA		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_LIMIT_ISA			: REG16_ARRAY;

SIGNAL EN_TMPWRM_LIMIT_ISA		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_LIMIT_ISA			: REG16_ARRAY;

SIGNAL FAULT_STATUS_REG			: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL EN_ARC_TST_ISA			: STD_LOGIC;
SIGNAL ARC_TST_ISA				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_TST_INT1				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_TST_INT2				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_TST_INT3				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_TST_INT4				: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_ARC_PULSE_PRD			: STD_LOGIC;
SIGNAL ARC_PULSE_PRD				: STD_LOGIC_VECTOR(15 DOWNTO 0);	

SIGNAL EN_TMPWRM_TST_ISA		: STD_LOGIC;
SIGNAL TMPWRM_TST_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_TST_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_TST_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_TMPCLD_TST_ISA		: STD_LOGIC;
SIGNAL TMPCLD_TST_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_TST_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_TST_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_MASK_ARC_ISA			: STD_LOGIC;
SIGNAL EN_MASK_ARC_FAULT_OUT	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_ARC_ISA				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_ARC_INT1				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_ARC_INT2				: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_MASK_VAC_ISA			: STD_LOGIC;
SIGNAL EN_MASK_VAC_FAULT_OUT	: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_VAC_ISA				: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_VAC_INT1				: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_VAC_INT2				: STD_LOGIC_VECTOR(8 DOWNTO 0);

SIGNAL EN_MASK_TMP_FAULT		: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL EN_MASK_TMPWRM_ISA		: STD_LOGIC;
SIGNAL MASK_TMPWRM_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_TMPWRM_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_TMPWRM_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_MASK_TMPCLD_ISA		: STD_LOGIC;
SIGNAL MASK_TMPCLD_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_TMPCLD_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_TMPCLD_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_MASK_INTEN_ISA		: STD_LOGIC;
SIGNAL EN_MASK_INTEN_FAULT		: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_INTEN_ISA			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_INTEN_INT1			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_INTEN_INT2			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_INTEN_FAULT			: STD_LOGIC_VECTOR(8 DOWNTO 0);

SIGNAL EN_MASK_FC_FSD_ISA		: STD_LOGIC;
SIGNAL EN_MASK_FC_FSD_FAULT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_FC_FSD_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_FC_FSD_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_FC_FSD_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_FC_FSD_FAULT		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_CONTROL_REG_ISA		: STD_LOGIC;
SIGNAL CONTROL_REG_INT1			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL CONTROL_REG_INT2			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL CONTROL_REG_INT3			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL CONTROL_REG_INT4			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL CONTROL_REG_INT5			: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL CONTROL_REG_ISA			: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL EN_ARC_FLT_CLR_ISA		: STD_LOGIC;
SIGNAL ARC_FLT_CLR_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_FLT_CLR_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_FLT_CLR_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_TMPWRM_FLT_CLR_ISA	: STD_LOGIC;
SIGNAL TMPWRM_FLT_CLR_INT1		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_FLT_CLR_INT2		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_FLT_CLR_ISA		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_TMPCLD_FLT_CLR_ISA	: STD_LOGIC;
SIGNAL TMPCLD_FLT_CLR_INT1		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_FLT_CLR_INT2		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_FLT_CLR_ISA		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_INTEN_CLR_ISA			: STD_LOGIC;
SIGNAL INTEN_CLR_INT1			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL INTEN_CLR_INT2			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL INTEN_CLR_ISA				: STD_LOGIC_VECTOR(8 DOWNTO 0);

SIGNAL EN_FC_FSD_CLR_ISA		: STD_LOGIC;
SIGNAL FC_FSD_CLR_INT1			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FC_FSD_CLR_INT2			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FC_FSD_CLR_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_VAC_FLT_CLR_ISA		: STD_LOGIC;
SIGNAL VAC_FLT_CLR_INT1			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL VAC_FLT_CLR_INT2			: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL VAC_FLT_CLR_ISA			: STD_LOGIC_VECTOR(8 DOWNTO 0);

SIGNAL VERSION						: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL ONE							: STD_LOGIC;

SIGNAL EN_ARC_TST_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL EN_TMPWRM_TST_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL EN_TMPCLD_TST_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL EN_ARC_STOP_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL ARC_TST_OUT				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_TST_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_TST_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_STOP_OUT				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_ARC_FAULT_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL MASK_VAC_FAULT_OUT		: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL MASK_TMP_FAULT_OUT		: STD_LOGIC_VECTOR(15 DOWNTO 0);
SIGNAL ARC_FLT_CLR_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPWRM_FLT_CLR_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL TMPCLD_FLT_CLR_OUT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_CLR_OUT				: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL FC_FSD_CLR_OUT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL VAC_FLT_CLR_OUT			: STD_LOGIC_VECTOR(8 DOWNTO 0);

SIGNAL FAULT_CLEAR				: STD_LOGIC;
SIGNAL FAULT_CLEAR_FSD			: STD_LOGIC;

SIGNAL HELIUM_INTERLOCK_CLR	: STD_LOGIC;
SIGNAL HELIUM_INTERLOCK			: STD_LOGIC;

signal clr_arc_tst_cnt			: std_logic_vector(7 downto 0);
signal en_arc_tst_cnt			: std_logic_vector(7 downto 0);
signal arc_tst_cnt				: REG20_ARRAY; -- changed from reg 16 array on 7/7/21

SIGNAL EN_ARC_PWR_ISA			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL ARC_PWR_ISA				: REG16_ARRAY;

SIGNAL ARC_TST_FLT_INT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL EN_ARC_TST_FLT			: STD_LOGIC;	

-- added for arch archiver fault detection
SIGNAL arc_delay_fault			: STD_LOGIC_VECTOR(7 downto 0); -- OR the latched fault with the fault status

-- Arc buffer data archive
TYPE ARC_BUFFER_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(1023 DOWNTO 0); -- 64 samples
--TYPE ARC_BUFFER_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(4095 DOWNTO 0); -- This will hold 200 16 bit samples (make larger if interested)
--TYPE ARC_BUFFER_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(32767 DOWNTO 0); -- this will hold 2048 16 bit samples (too big for quartus...)
SIGNAL ARC_BUFFER : ARC_BUFFER_ARRAY; -- 16 bit words, oldest data is the Most Significant word, newest data is the Least Significant word
--signal ARC_BUFFER_EN : STD_LOGIC_VECTOR(7 downto 0);
signal ARC_BUFF_DATA_udp : REG16_ARRAY;

signal ARC_BUFF_DATA_out  : STD_LOGIC_VECTOR(15 downto 0); -- 8k bufer for arc adc
signal ARC_BUFF_READY, ARC_BUFF_READY_chn  : STD_LOGIC_VECTOR(7 downto 0);
signal ARC_BUFF_READY_bit : STD_LOGIC;

-- Cyclone 10 Gx remote config/download
signal en_c_addr  : StD_LOGIC;
signal en_c_cntl  : StD_LOGIC;   
signal en_c_data  : StD_LOGIC;
--signal c_addr		: StD_LOGIC_VECTOR(31 downto 0);
--signal c_cntlr	   : StD_LOGIC_VECTOR(31 downto 0);  
--signal c_data		: StD_LOGIC_VECTOR(31 downto 0);
--SIGNAL c10_status : std_logic_VECTOR(31 DOWNTO 0);
--SIGNAL c10_datar	: std_logic_VECTOR(31 DOWNTO 0);

-- JTAG Mux select, complementary bits, used to deselect the Cyclone 10 from the JTAG chain so that the max10 may be reporgrammed by itself
signal JTAGMUX    : STD_LOGIC_VECTOR(15 downto 0);
signal jtagmuxreg	: STD_LOGIC_VECTOR(15 downto 0);
signal EN_JTAGMUX : STD_LOGIC;

signal intrstr : STD_LOGIC_VECTOR(31 downto 0);
signal en_intrstr : STD_LOGIC;

signal CAVCONFIG : STD_LOGIC_VECTOR(31 downto 0);
signal en_CAVCONFIG : STD_LOGIC;

signal c10_datar, c10_status : STD_LOGIC_VECTOR(31 downto 0);

attribute noprune: boolean;

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

--

BEGIN

ONE	<= '1';
	
--===================================================================
----defining cavity fault based on all the faults-----
----CAVITY FAULT IS MADE HIGH WHEN ONE OF THE ARC, BEAMLINE VAC, WAVEGUIDE VAC,
----COLD WINDOW OR WARM WINDOW FAULT IS HIGH
--===================================================================	

CAV_FLT_GEN: FOR I IN 0 TO 7 GENERATE
	
	CAV_FLT_FPGA(I) <= (ARC_FAULT_STATUS(I+8) AND NOT MASK_ARC_FAULT_OUT(I)) OR VAC_FAULT_STATUS(I+9) OR VAC_FAULT_STATUS(17) OR
					   (TMPCLD_FAULT_STATUS(I+8) AND NOT MASK_TMP_FAULT_OUT(I+8))  OR (TMPWRM_FAULT_STATUS(I+8) AND NOT MASK_TMP_FAULT_OUT(I)) OR ARC_TST_FLT_INT(I) OR HELIUM_INTERLOCK;				   
END GENERATE;
--===================================================================	
--
--===================================================================
-- ARC Test Pulse Registers
--===================================================================

--																										??????? arc pulse tests appear to be controlled by epics
--																													pulse will be high for a fixed time and then brought low.
--																													Epics will need to bring the register low before re-starting test

ARC_TEST_GEN: FOR I IN 0 TO 7 GENERATE

ARC_TEST_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_ARC_TST_ISA,
			 INP	=> DIN(I),
			 OUP	=> ARC_TST_ISA(I)
			);
			
ARC_TEST_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_TST_ISA(I),
			 OUP	=> ARC_TST_INT1(I)
			);
			
ARC_TEST_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_TST_INT1(I),
			 OUP	=> ARC_TST_INT2(I)
			);
			
ARC_TEST_FFI4: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_TST_INT2(I),
			 OUP	=> ARC_TST_INT3(I)
			);
			
			
ARC_TEST_FFI5: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_TST_INT3(I),
			 OUP	=> ARC_TST_INT4(I)
			);
			
arc_tst_gen_i: counter
		generic map(n => 20) -- changed to 20 bit array (19 downto 0)
		port map(clock		=> clock,		
					reset		=> reset,		
					clear		=> clr_arc_tst_cnt(i),  	
					enable	=> en_arc_tst_cnt(i),	
					count		=> arc_tst_cnt(i)
					);	

clr_arc_tst_cnt(i) <= '0' when  (arc_tst_int4(i) = '1' and arc_tst_int2(i) = '0') else '1'; ----10 hz signal
 
en_arc_tst_cnt(i) <= '1' when (arc_tst_int4(i) = '1' and arc_tst_int3(i) = '1' and arc_tst_cnt(i) < x"1E848") else '0';

-- hi for 49984 clock ticks during an arc test 
-- was C340 changed on 7/7/21 to make the arc test to 1.0 ms
-- new value is 1E848 (changed in two places)

ARC_TST(I) <= '1' when 	arc_tst_cnt(i) < x"1E848" and arc_tst_cnt(i) > x"00000" else '0'; 													-- this is a fixed value, should we update this to be the LED pulse period (HRT) "107 Arc Test LED pulse period"	
						
END GENERATE;

-- enable the arc test pulses only when the appropriate ADDR(15 downto 0)ess is written
EN_ARC_TST_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0020" ELSE '0'; -- JAL 6/21/21, changing form 0x40 to 0x20.

--===================================================================

--===================================================================
-- IR Warm/Cold Test Registers
--===================================================================
-- IR warm/cold tests also appear to be controlled by epics.
-- The test will continue until epics stops the tests
-- pulse will be high until EPICS pulls the test pulse low.
--
TMPWRM_TEST_GEN: FOR I IN 0 TO 7 GENERATE

TMPWRM_TEST_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_TMPWRM_TST_ISA,
			 INP	=> DIN(I),
			 OUP	=> TMPWRM_TST_ISA(I)
			);
			

			
END GENERATE;

-- will send a test pulse until register is re-written
TMPWRM_TST <= TMPWRM_TST_ISA;
EN_TMPWRM_TST_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0021" ELSE '0';



TMPCLD_TEST_GEN: FOR I IN 0 TO 7 GENERATE

TMPCLD_TEST_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_TMPCLD_TST_ISA,
			 INP	=> DIN(I),
			 OUP	=> TMPCLD_TST_ISA(I)
			);
			

			
END GENERATE;

-- will send a test pulse until register is re-written
TMPCLD_TST <= TMPCLD_TST_ISA;
EN_TMPCLD_TST_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0022" ELSE '0';

--===================================================================

--===================================================================
-- ARC Limit/Timer/Delay Registers
--===================================================================

GEN_ARC_LIMIT_REG: FOR I IN 0 TO 7 GENERATE	

	REGNE_ARC_LIMITI: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_ARC_LIMIT_ISA(I),
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> ARC_LIMIT_ISA(I)
				);		

END GENERATE;

ARC_LIMIT <= ARC_LIMIT_ISA;

EN_ARC_LIMIT_ISA(0)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0023" ELSE '0';
EN_ARC_LIMIT_ISA(1)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0024" ELSE '0';
EN_ARC_LIMIT_ISA(2)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0025" ELSE '0';
EN_ARC_LIMIT_ISA(3)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0026" ELSE '0';
EN_ARC_LIMIT_ISA(4)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0027" ELSE '0';
EN_ARC_LIMIT_ISA(5)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0028" ELSE '0';
EN_ARC_LIMIT_ISA(6)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0029" ELSE '0';
EN_ARC_LIMIT_ISA(7)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"002A" ELSE '0';

GEN_ARC_TIMER_REG: FOR I IN 0 TO 7 GENERATE	

	REGNE_ARC_TIMERI: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_ARC_TIMER_ISA(I),
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> ARC_TIMER_ISA(I)
				);		

END GENERATE;

ARC_TIMER <= ARC_TIMER_ISA;

EN_ARC_TIMER_ISA(0)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"002B" ELSE '0';
EN_ARC_TIMER_ISA(1)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"002C" ELSE '0';
EN_ARC_TIMER_ISA(2)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"002D" ELSE '0';
EN_ARC_TIMER_ISA(3)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"002E" ELSE '0';
EN_ARC_TIMER_ISA(4)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"002F" ELSE '0';
EN_ARC_TIMER_ISA(5)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0030" ELSE '0';
EN_ARC_TIMER_ISA(6)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0031" ELSE '0';
EN_ARC_TIMER_ISA(7)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0032" ELSE '0';

GEN_ARC_DELAY_REG: FOR I IN 0 TO 7 GENERATE	

	REGNE_ARC_DELAYI: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_ARC_DELAY_ISA(I),
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> ARC_DELAY_ISA(I)
				);		

END GENERATE;

ARC_TRIG_DELAY <= ARC_DELAY_ISA;

EN_ARC_DELAY_ISA(0)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0033" ELSE '0';
EN_ARC_DELAY_ISA(1)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0034" ELSE '0';
EN_ARC_DELAY_ISA(2)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0035" ELSE '0';
EN_ARC_DELAY_ISA(3)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0036" ELSE '0';
EN_ARC_DELAY_ISA(4)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0037" ELSE '0';
EN_ARC_DELAY_ISA(5)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0038" ELSE '0';
EN_ARC_DELAY_ISA(6)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0039" ELSE '0';
EN_ARC_DELAY_ISA(7)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"003A" ELSE '0';

--===================================================================

--===================================================================
-- ARC Stop Register
--===================================================================

ARC_STOP_GEN: FOR I IN 0 TO 7 GENERATE

ARC_STOP_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_ARC_STOP_ISA,
			 INP	=> DIN(I),
			 OUP	=> ARC_STOP_ISA(I)
			);
			
ARC_STOP_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_STOP_ISA(I),
			 OUP	=> ARC_STOP_INT1(I)
			);
			
ARC_STOP_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_STOP_INT1(I),
			 OUP	=> ARC_STOP_INT2(I)
			);
			
ARC_STOP_FFI4: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_ARC_STOP_OUT(I),
			 INP	=> NOT ARC_STOP_INT2(I),
			 OUP	=> ARC_STOP_OUT(I)
			);			
		
EN_ARC_STOP_OUT(I) <= ARC_STOP_INT1(I) XOR ARC_STOP_INT2(I);	
					
END GENERATE;

-- module output
ARC_STOP <= ARC_STOP_OUT;
-- only enable when address is written to
EN_ARC_STOP_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"003B" ELSE '0';

--===================================================================

--===================================================================
-- IR Warm/Cold limit register
--===================================================================

GEN_TMPWRM_LIMIT_REG: FOR I IN 0 TO 7 GENERATE	

	REGNE_TMPWRM_LIMITI: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_TMPWRM_LIMIT_ISA(I),
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> TMPWRM_LIMIT_ISA(I)
				);		

END GENERATE;

TMPWRM_LIMIT <= TMPWRM_LIMIT_ISA;

EN_TMPWRM_LIMIT_ISA(0)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"003C" ELSE '0';
EN_TMPWRM_LIMIT_ISA(1)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"003D" ELSE '0';
EN_TMPWRM_LIMIT_ISA(2)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"003E" ELSE '0';
EN_TMPWRM_LIMIT_ISA(3)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"003F" ELSE '0';
EN_TMPWRM_LIMIT_ISA(4)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0040" ELSE '0';
EN_TMPWRM_LIMIT_ISA(5)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0041" ELSE '0';
EN_TMPWRM_LIMIT_ISA(6)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0042" ELSE '0';
EN_TMPWRM_LIMIT_ISA(7)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0043" ELSE '0';

GEN_TMPCLD_LIMIT_REG: FOR I IN 0 TO 7 GENERATE	

	REGNE_TMPCLD_LIMITI: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_TMPCLD_LIMIT_ISA(I),
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> TMPCLD_LIMIT_ISA(I)
				);		

END GENERATE;

TMPCLD_LIMIT <= TMPCLD_LIMIT_ISA;

EN_TMPCLD_LIMIT_ISA(0)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0044" ELSE '0';
EN_TMPCLD_LIMIT_ISA(1)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0045" ELSE '0';
EN_TMPCLD_LIMIT_ISA(2)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0046" ELSE '0';
EN_TMPCLD_LIMIT_ISA(3)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0047" ELSE '0';
EN_TMPCLD_LIMIT_ISA(4)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0048" ELSE '0';
EN_TMPCLD_LIMIT_ISA(5)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0049" ELSE '0';
EN_TMPCLD_LIMIT_ISA(6)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"004A" ELSE '0';
EN_TMPCLD_LIMIT_ISA(7)	<= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"004B" ELSE '0';

--===================================================================

--===================================================================
-- ARC Mask Register
--===================================================================

MASK_ARC_GEN: FOR I IN 0 TO 7 GENERATE

MASK_ARC_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_MASK_ARC_ISA,
			 INP	=> DIN(I),
			 OUP	=> MASK_ARC_ISA(I)
			);
			
MASK_ARC_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_ARC_ISA(I),
			 OUP	=> MASK_ARC_INT1(I)
			);
			
MASK_ARC_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_ARC_INT1(I),
			 OUP	=> MASK_ARC_INT2(I)
			);
							
END GENERATE;
-- moduel output
MASK_ARC_FAULT <= MASK_ARC_INT2;

-- used as a fault mask for a fault input to CAV_FLT_FPGA
MASK_ARC_FAULT_OUT <= MASK_ARC_INT2;

EN_MASK_ARC_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"004C" ELSE '0';

--===================================================================

--===================================================================
-- VAC Mask Register
--===================================================================

MASK_VAC_GEN: FOR I IN 0 TO 8 GENERATE

MASK_VAC_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_MASK_VAC_ISA,
			 INP	=> DIN(I),
			 OUP	=> MASK_VAC_ISA(I)
			);
			
MASK_VAC_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_VAC_ISA(I),
			 OUP	=> MASK_VAC_INT1(I)
			);
			
MASK_VAC_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_VAC_INT1(I),
			 OUP	=> MASK_VAC_INT2(I)
			);
			
END GENERATE;
-- module output
MASK_VAC_FAULT <= MASK_VAC_INT2;
-- used in dout
MASK_VAC_FAULT_OUT <= MASK_VAC_INT2;
EN_MASK_VAC_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"004D" ELSE '0';

--===================================================================

--===================================================================
-- IR warm/cold Mask Register
--===================================================================

MASK_TMPWRM_GEN: FOR I IN 0 TO 7 GENERATE

MASK_TMPWRM_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_MASK_TMPWRM_ISA,
			 INP	=> DIN(I),
			 OUP	=> MASK_TMPWRM_ISA(I)
			);
			
MASK_TMPWRM_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_TMPWRM_ISA(I),
			 OUP	=> MASK_TMPWRM_INT1(I)
			);
			
MASK_TMPWRM_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_TMPWRM_INT1(I),
			 OUP	=> MASK_TMPWRM_INT2(I)
			);
			
END GENERATE;

--module output, signals are concatenated
-- 					15 downto 8			 7 downto 0
MASK_TMP_FAULT <= MASK_TMPCLD_INT2 & MASK_TMPWRM_INT2;

MASK_TMP_FAULT_OUT <= MASK_TMPCLD_INT2 & MASK_TMPWRM_INT2;
EN_MASK_TMPWRM_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"004E" ELSE '0';

MASK_TMPCLD_GEN: FOR I IN 0 TO 7 GENERATE

MASK_TMPCLD_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_MASK_TMPCLD_ISA,
			 INP	=> DIN(I),
			 OUP	=> MASK_TMPCLD_ISA(I)
			);
			
MASK_TMPCLD_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_TMPCLD_ISA(I),
			 OUP	=> MASK_TMPCLD_INT1(I)
			);
			
MASK_TMPCLD_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_TMPCLD_INT1(I),
			 OUP	=> MASK_TMPCLD_INT2(I)
			);
			

END GENERATE;

EN_MASK_TMPCLD_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"004F" ELSE '0';

--===================================================================

--===================================================================
-- INTEN mask register, INTERLOCK DENABLE MASK ON HRT
--===================================================================

MASK_INTEN_GEN: FOR I IN 0 TO 8 GENERATE

MASK_INTEN_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_MASK_INTEN_ISA,
			 INP	=> DIN(I),
			 OUP	=> MASK_INTEN_ISA(I)
			);
			
MASK_INTEN_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_INTEN_ISA(I),
			 OUP	=> MASK_INTEN_INT1(I)
			);
			
MASK_INTEN_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_INTEN_INT1(I),
			 OUP	=> MASK_INTEN_INT2(I)
			);
			

							
END GENERATE;


MASK_INTEN_FAULT <= MASK_INTEN_INT2;

-- 9 bit module output
INTEN_MASK <= MASK_INTEN_INT2;
EN_MASK_INTEN_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0050" ELSE '0';

--===================================================================

--===================================================================
-- Fast Shutdown Mask Register
--===================================================================

MASK_FC_FSD_GEN: FOR I IN 0 TO 7 GENERATE

MASK_FC_FSD_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_MASK_FC_FSD_ISA,
			 INP	=> DIN(I),
			 OUP	=> MASK_FC_FSD_ISA(I)
			);
			
MASK_FC_FSD_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_FC_FSD_ISA(I),
			 OUP	=> MASK_FC_FSD_INT1(I)
			);
			
MASK_FC_FSD_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> MASK_FC_FSD_INT1(I),
			 OUP	=> MASK_FC_FSD_INT2(I)
			);
			
END GENERATE;

FC_FSD_MASK <= MASK_FC_FSD_INT2;

MASK_FC_FSD_FAULT <= MASK_FC_FSD_INT2; 

EN_MASK_FC_FSD_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0051" ELSE '0';

--===================================================================

--===================================================================
-- Control Register
--===================================================================

---cntrl_reg(15) - register reset
---cntrl_reg(14) - master fault clear
---cntrl_reg(13) - helium interlock clear
---cntrl_reg(1)  - helium interlock instantaneous


CNTRL_REG_GEN: FOR I IN 0 TO 15 GENERATE

CNTRL_REG_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_CONTROL_REG_ISA,
			 INP	=> DIN(I),
			 OUP	=> CONTROL_REG_INT1(I)
			);
			
CNTRL_REG_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> CONTROL_REG_INT1(I),
			 OUP	=> CONTROL_REG_INT2(I)
			);
			
CNTRL_REG_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> CONTROL_REG_INT2(I),
			 OUP	=> CONTROL_REG_INT3(I)
			);
			
CNTRL_REG_FFI4: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> CONTROL_REG_INT3(I),
			 OUP	=> CONTROL_REG_INT4(I)
			);
			
CNTRL_REG_FFI5: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> CONTROL_REG_INT4(I),
			 OUP	=> CONTROL_REG_INT5(I)
			);
			
--CONTROL_REG_ISA(I) <= CONTROL_REG_INT2(I) AND (NOT CONTROL_REG_INT3(I));	
							
END GENERATE;

CONTROL_REG_ISA <= CONTROL_REG_INT1;

EN_CONTROL_REG_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0052" ELSE '0';

REG_RESET <= CONTROL_REG_INT2(15) AND (NOT CONTROL_REG_INT3(15));

FAULT_CLEAR <= CONTROL_REG_INT1(14) AND (NOT CONTROL_REG_INT2(14));

FAULT_CLEAR_FSD <= CONTROL_REG_INT4(14) AND (NOT CONTROL_REG_INT5(14));

HELIUM_INT_FF: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> NOT HELIUM_INTERLOCK_CLR,
			 EN		=> CONTROL_REG_INT1(1),
			 INP	=> '1',
			 OUP	=> HELIUM_INTERLOCK
			);			

HELIUM_INTERLOCK_LED <= HELIUM_INTERLOCK;
			
HELIUM_INTERLOCK_CLR <= FAULT_CLEAR OR (CONTROL_REG_INT1(13) AND (NOT CONTROL_REG_INT2(13)));

FAULT_STATUS_REG(15) <= VAC_FAULT_STATUS(17);-----BL VAC LATCHCED
FAULT_STATUS_REG(14) <= MAIN_FSD_FAULT_STATUS(1);----MAIN FSD LATCHED
FAULT_STATUS_REG(13 DOWNTO 8) <= (OTHERS => '0');
FAULT_STATUS_REG(7) <= VAC_FAULT_STATUS(8);------BL VAC PRESENT		
FAULT_STATUS_REG(6) <= MAIN_FSD_FAULT_STATUS(0);----MAIN FSD PRESENT
FAULT_STATUS_REG(5 DOWNTO 2) <= (OTHERS => '0');
FAULT_STATUS_REG(1) <= HELIUM_INTERLOCK;-----HELIUM INTERLOCK LATCHED
FAULT_STATUS_REG(0) <= HB_ISA;

--===================================================================

--===================================================================
-- ARC Fault Clear Register
--===================================================================

ARC_FLT_CLR_GEN: FOR I IN 0 TO 7 GENERATE

ARC_FLT_CLR_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_ARC_FLT_CLR_ISA,
			 INP	=> DIN(I),
			 OUP	=> ARC_FLT_CLR_ISA(I)
			);
			
ARC_FLT_CLR_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_FLT_CLR_ISA(I),
			 OUP	=> ARC_FLT_CLR_INT1(I)
			);
			
ARC_FLT_CLR_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> ARC_FLT_CLR_INT1(I),
			 OUP	=> ARC_FLT_CLR_INT2(I)
			);
			
ARC_FLT_CLR_OUT(I) <= (ARC_FLT_CLR_INT1(I) AND NOT ARC_FLT_CLR_INT2(I)) OR FAULT_CLEAR;	
							
END GENERATE;

ARC_FLT_CLR <= ARC_FLT_CLR_OUT;
EN_ARC_FLT_CLR_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0055" ELSE '0';

--===================================================================

--===================================================================
-- IR Warm/Cold Fault Clear Register
--===================================================================

TMPWRM_FLT_CLR_GEN: FOR I IN 0 TO 7 GENERATE

TMPWRM_FLT_CLR_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_TMPWRM_FLT_CLR_ISA,
			 INP	=> DIN(I),
			 OUP	=> TMPWRM_FLT_CLR_ISA(I)
			);
			
TMPWRM_FLT_CLR_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> TMPWRM_FLT_CLR_ISA(I),
			 OUP	=> TMPWRM_FLT_CLR_INT1(I)
			);
			
TMPWRM_FLT_CLR_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> TMPWRM_FLT_CLR_INT1(I),
			 OUP	=> TMPWRM_FLT_CLR_INT2(I)
			);
			
TMPWRM_FLT_CLR_OUT(I) <= (TMPWRM_FLT_CLR_INT1(I) AND NOT TMPWRM_FLT_CLR_INT2(I)) OR FAULT_CLEAR;	
							
END GENERATE;

TMPWRM_FLT_CLR <= TMPWRM_FLT_CLR_OUT; 
EN_TMPWRM_FLT_CLR_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0056" ELSE '0';



TMPCLD_FLT_CLR_GEN: FOR I IN 0 TO 7 GENERATE

TMPCLD_FLT_CLR_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_TMPCLD_FLT_CLR_ISA,
			 INP	=> DIN(I),
			 OUP	=> TMPCLD_FLT_CLR_ISA(I)
			);
			
TMPCLD_FLT_CLR_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> TMPCLD_FLT_CLR_ISA(I),
			 OUP	=> TMPCLD_FLT_CLR_INT1(I)
			);
			
TMPCLD_FLT_CLR_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> TMPCLD_FLT_CLR_INT1(I),
			 OUP	=> TMPCLD_FLT_CLR_INT2(I)
			);
			
TMPCLD_FLT_CLR_OUT(I) <= (TMPCLD_FLT_CLR_INT1(I) AND NOT TMPCLD_FLT_CLR_INT2(I)) OR FAULT_CLEAR;	
							
END GENERATE;

TMPCLD_FLT_CLR <= TMPCLD_FLT_CLR_OUT;
EN_TMPCLD_FLT_CLR_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0057" ELSE '0';

--===================================================================

--===================================================================
-- INTEN Fault Clear Register, INTERLOCK ENABLE CLEAR ON HRT
--===================================================================

INTEN_CLR_FF_GEN: FOR I IN 0 TO 8 GENERATE

INTEN_CLR_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_INTEN_CLR_ISA,
			 INP	=> DIN(I),
			 OUP	=> INTEN_CLR_ISA(I)
			);
			
INTEN_CLR_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> INTEN_CLR_ISA(I),
			 OUP	=> INTEN_CLR_INT1(I)
			);
			
INTEN_CLR_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> INTEN_CLR_INT1(I),
			 OUP	=> INTEN_CLR_INT2(I)
			);
			
							
END GENERATE;


INTEN_CLR_GEN: FOR I IN 0 TO 7 GENERATE

INTEN_CLR_OUT(I) <= (INTEN_CLR_INT1(I) AND NOT INTEN_CLR_INT2(I)) OR FAULT_CLEAR;

END GENERATE;

INTEN_CLR_OUT(8) <= (INTEN_CLR_INT1(8) AND NOT INTEN_CLR_INT2(8)) OR FAULT_CLEAR_FSD;

INTEN_CLR <= INTEN_CLR_OUT;
EN_INTEN_CLR_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0058" ELSE '0';

--===================================================================

--===================================================================
-- Fast Shutdown Fault Clear Register
--===================================================================

FC_FSD_CLR_GEN: FOR I IN 0 TO 7 GENERATE

FC_FSD_CLR_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_FC_FSD_CLR_ISA,
			 INP	=> DIN(I),
			 OUP	=> FC_FSD_CLR_ISA(I)
			);
			
FC_FSD_CLR_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> FC_FSD_CLR_ISA(I),
			 OUP	=> FC_FSD_CLR_INT1(I)
			);
			
FC_FSD_CLR_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> FC_FSD_CLR_INT1(I),
			 OUP	=> FC_FSD_CLR_INT2(I)
			);
			
FC_FSD_CLR_OUT(I) <= (FC_FSD_CLR_INT1(I) AND NOT FC_FSD_CLR_INT2(I)) OR FAULT_CLEAR_FSD;	
							
END GENERATE;

FC_FSD_CLR <= FC_FSD_CLR_OUT;
EN_FC_FSD_CLR_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0059" ELSE '0';

--===================================================================

--===================================================================
-- VAC Fault Clear Register
--===================================================================

VAC_FLT_CLR_GEN: FOR I IN 0 TO 8 GENERATE

VAC_FLT_CLR_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> EN_VAC_FLT_CLR_ISA,
			 INP	=> DIN(I),
			 OUP	=> VAC_FLT_CLR_ISA(I)
			);
			
VAC_FLT_CLR_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> VAC_FLT_CLR_ISA(I),
			 OUP	=> VAC_FLT_CLR_INT1(I)
			);
			
VAC_FLT_CLR_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> VAC_FLT_CLR_INT1(I),
			 OUP	=> VAC_FLT_CLR_INT2(I)
			);
			
VAC_FLT_CLR_OUT(I) <= (VAC_FLT_CLR_INT1(I) AND NOT VAC_FLT_CLR_INT2(I)) OR FAULT_CLEAR;	
							
END GENERATE;

VAC_FLT_CLR <= VAC_FLT_CLR_OUT;
EN_VAC_FLT_CLR_ISA <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"005A" ELSE '0';

--===================================================================

--=================================================================== 
-- DAC power reisters
--===================================================================
-- not needed for 3.0, however I updated the registers
-- 
GEN_ARC_PWR_REG: FOR I IN 0 TO 7 GENERATE	

	REGNE_ARC_PWRI: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_ARC_PWR_ISA(I),
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> ARC_PWR_ISA(I)
				);		

END GENERATE;

EN_ARC_PWR_ISA(0) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"005B" ELSE '0';
EN_ARC_PWR_ISA(1) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"005C" ELSE '0';
EN_ARC_PWR_ISA(2) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"005D" ELSE '0';
EN_ARC_PWR_ISA(3) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"005E" ELSE '0';
EN_ARC_PWR_ISA(4) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"005F" ELSE '0';
EN_ARC_PWR_ISA(5) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0060" ELSE '0';
EN_ARC_PWR_ISA(6) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0061" ELSE '0';
EN_ARC_PWR_ISA(7) <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0062" ELSE '0';


ARC_PWR <= ARC_PWR_ISA;
--===================================================================

--=================================================================== 
-- ARC Pulse Period
--===================================================================
-- On HRT this is ARC TEST LED PULSE PERIOD

	REGNE_ARC_PULSE_PRD: REGNE
		GENERIC MAP(N => 16)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> ONE,
				 EN		=> EN_ARC_PULSE_PRD,
				 INPUT	=> DIN(15 downto 0),
				 OUTPUT	=> ARC_PULSE_PRD
				);		

EN_ARC_PULSE_PRD <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0063" ELSE '0';

--===================================================================

--===================================================================
-- ARC TST FLT (ARC Test Fault)
--===================================================================
-- JAL, simulates a channel specific ARC fault. Will cause cav_flt_fpga to trip for that channel.
-- Does not functionaly light up the arc detector LED, but it simulates the response (i.e. cav_flt_fpga will trip).
-- this will fault regardless of if ARC mask is set.
--
	REGNE_ARC_TEST_FLT: REGNE
		GENERIC MAP(N => 8)
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR 	=> NOT FAULT_CLEAR,
				 EN		=> EN_ARC_TST_FLT,
				 INPUT	=> DIN(7 DOWNTO 0),
				 OUTPUT	=> ARC_TST_FLT_INT
				);		

EN_ARC_TST_FLT <= '1' WHEN LOAD = '1' AND ADDR(15 downto 0) = x"0065" ELSE '0'; -- JAL 6/21/21, changed from 0x20 to 0x65

ARC_TST_FLT <= ARC_TST_FLT_INT;

--===================================================================

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

--===================================================================

--===================================================================
-- ARC Buffer Record for viewing faults (fault viewer only, does not have a scope mode)
--===================================================================
	-- goal is to load arc data into an 8k circular buffer. when a fault is latched, this buffer will freeze and may be read out
	-- by epics (slowly). The RAM values are directly addressable over the HRT.
	-- Below is a map of which address range corresponds to each cirular buffer. Note, the lower 12 bits of ADDR are sent
	-- to all circular buffers for reading. However, the read data output (that is, which arc waveform is being read) is
	-- deterimined by ADDR(17 downto 14)
	-- ====================================== note, x1fff = 8191 which is for 8192 values and is 8k, 13 bit addressing
	-- channel | address start | address stop
	-- 0			 x02000    		  x03FFF
	-- 1			 x04000			  x05FFF
	-- 2			 x06000			  x07FFF
	-- 3  		 x08000			  x09FFF
	-- 4	 		 x0A000			  x0BFFF
	-- 5			 x0C000  		  x0DFFF
	-- 6			 x0E000			  x0FFFF
	-- 7         x10000			  x11FFF
	-- ======================================
	--
	-- shift register which handles saving arc data (8k samples, for 8 arc channels)
	-- if an arc fault occurs (on any arc channel), save data on all circular buffers
	--		Note, if interested in simulating faults, add a control bit here to do that.
	arc_delay_fault(0) <= ARC_FAULT_STATUS(8) OR ARC_FAULT_STATUS(9) OR ARC_FAULT_STATUS(10) OR ARC_FAULT_STATUS(11) OR ARC_FAULT_STATUS(12) OR ARC_FAULT_STATUS(13) OR ARC_FAULT_STATUS(14) OR ARC_FAULT_STATUS(15);
	--
	ARC_BUFFER_GEN: FOR I IN 0 TO 7 GENERATE	
		-- inst circular buffer
		arc_buffer_I: arc_buffer_module
		GENERIC MAP(n => 64) -- generic is not used...
		PORT MAP(CLOCK              => CLOCK,										-- clock (assumed 125 Mhz)
					reset_n            => RESET,										-- active low reset
					TAKE	             => ARC_FAULT_STATUS(I+8),             -- common take bit for all channels which is an ARC Fault on any channel
					DONE					 => ARC_BUFF_READY(I),                 -- done bit
					ADDR					 => ADDR(12 downto 0),                 -- address to read from RAM
					DATA					 => ARC_BUFF_DATA_udp(I)(15 downto 0), -- read value from RAM
					ADC_DATA				 => ARC_DATA(I),	                     -- input data from ADC
					READY					 => open,										-- note used
					adc_busy				 => arc_adc_busy(I),                   -- busy signal from ADC
					offset_addr		    => ARC_DELAY_ISA(I)(12 downto 0)      -- address delay for optional midpoint sampling
					);
		--
	END GENERATE; -- end ARC_BUFFER_GEN generate statement
	
	-- Once any of the channels are done being filled, this will go HIGH for epics to offload.
	-- ARC_BUFF_READY(0) is the status bit for epics
	--ARC_BUFF_READY(0) <= ARC_BUFF_READY_chn(7) OR ARC_BUFF_READY(6) OR ARC_BUFF_READY(5) OR ARC_BUFF_READY(4) OR ARC_BUFF_READY(3) OR ARC_BUFF_READY(2) OR ARC_BUFF_READY(1) OR ARC_BUFF_READY(0);
	--ARC_BUFF_READY(7 downto 2) <= "000000";

	-- with select statement for choosing which circular buffer is sent as DOUT from registers
	WITH ADDR(17 DOWNTO 0) SELECT
	ARC_BUFF_DATA_out <= ARC_BUFF_DATA_udp(0)      WHEN (x"02000") TO (x"03FFF") , -- JAL 2/24/22, added for 8k buffer
								ARC_BUFF_DATA_udp(1)      WHEN (x"04000") TO (x"05FFF") ,
								ARC_BUFF_DATA_udp(2)      WHEN (x"06000") TO (x"07FFF") ,
								ARC_BUFF_DATA_udp(3)      WHEN (x"08000") TO (x"09FFF") ,
								ARC_BUFF_DATA_udp(4)      WHEN (x"0A000") TO (x"0BFFF") ,
								ARC_BUFF_DATA_udp(5)      WHEN (x"0C000") TO (x"0DFFF") ,
								ARC_BUFF_DATA_udp(6)      WHEN (x"0E000") TO (x"0FFFF") ,
								ARC_BUFF_DATA_udp(7)      WHEN (x"10000") TO (x"11FFF") ,
								(OTHERS => '0')           WHEN OTHERS;
	--
	--
	
	--==================================================================
	-- intrstr, interlocks register status
	--==================================================================
	-- 4/5/22
	-- this pv will be initialized to zeros. epics will set it to a value once
	-- all pvs are set. If a power cycle or glitch occurs, this register will returnback to zero
	-- and epics will reload all registers as if doing a IOC restore.
	-- 
	-- bit 0, is save restore status (0=not restored, 1=restored)
	en_intrstr <= '1' when load = '1' and addr(11 downto 0) = x"06e" else '0';
	PROCESS(CLOCK,reset, en_intrstr) begin 
	  IF(reset='0') THEN 
		  intrstr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_intrstr='1') THEN 
		  intrstr<=din(31 downto 0); 
	  END IF; 
	END PROCESS;
	--==================================================================
	-- CAVCONFIG  sets the C100_intrstr
	--==================================================================
	-- The IR sensor for C100 and C75s has flipped polarity. 
	-- this register configures the IR sensor limits/readbacks for the respective IR sensor
	--
	en_CAVCONFIG <= '1' when load = '1' and addr(11 downto 0) = x"06d" else '0';
	PROCESS(CLOCK,reset, en_CAVCONFIG) begin 
	  IF(reset='0') THEN 
		  CAVCONFIG<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_CAVCONFIG='1') THEN 
		  CAVCONFIG<=din(31 downto 0); 
	  END IF; 
	END PROCESS;
	-- bit 0, not used
	-- bit 1, C100 status (0=C75, 1=C100)
	PROCESS(CLOCK,reset) begin 
	  IF(reset='0') THEN 
		  intrstr_C100 <= '0';
	  ELSIF (CLOCK'event AND CLOCK='1') THEN 
		  intrstr_C100<=CAVCONFIG(1); 
	  END IF; 
	END PROCESS;
	
	intrstr_C100_out <= intrstr_C100;
	
	--==================================================================
	-- Cyclone 10 GX remote download/reconfig
	--==================================================================
	-- 1/10/22 written
	-- 3/3/22, added to interlock fw
	--
	--
	-- This module allows us to update the firmware load saved on the EPCQ
	-- and trigger a reconfiguration of the fpga device over the network.
	-- module was desiged for C10GX but should also be compatible with Aria 10 devices.
	-- note, this is a verilog module
	CYCLONE_inst : entity work.CYCLONE
	PORT MAP(
			 lb_clk 		=> CLOCK,
			 reset_n    => RESET,
			 c10_addr 	=> c_addr,
			 c10_data 	=> c_data,
			 c10_cntlr 	=> c_cntlr,
			 c10_status => c10_status,
			 c10_datar  => c10_datar,
			 we_cyclone_inst_c10_data => (lb_valid AND en_c_data),
			 ru_data_out => open);
			 
			 
	-- fimrware update registers
	c_status <= c10_status;
	c_datar  <= c10_datar;
			 
			 
	-- enables for RW registers 
	en_c_addr <= '1' when load = '1' and addr(11 downto 0) = x"0D5" else '0';
	PROCESS(CLOCK,reset, en_c_addr) begin 
	  IF(reset='0') THEN 
		  c_addr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_addr='1') THEN 
		  c_addr<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_cntl <= '1' when load = '1' and addr(11 downto 0) = x"0D6" else '0';
	PROCESS(CLOCK,reset, en_c_cntl) begin 
	  IF(reset='0') THEN 
		  c_cntlr<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_cntl='1') THEN 
		  --c_cntlr<=din(31 downto 0); 
		  -- bit 7 can be used to reconfigure the FPGA. here, this is being masked out.
		  -- FPGA will need to be power cycled to reload MICRON memory contents (SPIFLASH)
		  c_cntlr<=din(31 downto 0);-- & '0' & din(6 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_data <= '1' when load = '1' and addr(11 downto 0) = x"0D9" else '0';
	PROCESS(CLOCK,reset, en_c_data) begin 
	  IF(reset='0') THEN 
		  c_data<=(others => '0'); 
	  ELSIF (CLOCK'event AND CLOCK='1' AND en_c_data='1') THEN 
		  c_data<=din(31 downto 0); 
	  END IF; 
	END PROCESS; 

	-- Assign module outputs
--	out_c_addr		<= c_addr;
--	out_c_cntlr		<= c_cntlr;
--	out_c_data		<= c_data;
--	out_en_c_data 	<= en_c_data;
	--
	-- --
	-- -- --
	--
	--
--===================================================================
-- python script notes
--c_addr   ='0d5'
--c_cntlr  ='0d6'
--c_status ='0d7'
--c_datar  ='0d8'
--c_data   ='0d9'
--===================================================================
-- DOUT Control for reads
--===================================================================
-- JAL 6/23/21, updated to support sign ext of 16 bit adcs.
-- IR ADCs (warm/cold window) and the corresponding limits are signed 16 bit
-- ARC ADCs and the corresponding limits  are unsigned, 16 bit

	-- look at address and only sign extend these signed registers (all others will have 0's extended).
	WITH ADDR(15 DOWNTO 0) SELECT
	DOUT(31 downto 16)<=	( OTHERS =>TMPWRM_DATA(0)(15))           WHEN (x"0008") ,
								( OTHERS =>TMPWRM_DATA(1)(15))           WHEN (x"0009") ,
								( OTHERS =>TMPWRM_DATA(2)(15))           WHEN (x"000A") ,
								( OTHERS =>TMPWRM_DATA(3)(15))           WHEN (x"000B") ,
								( OTHERS =>TMPWRM_DATA(4)(15))           WHEN (x"000C") ,
								( OTHERS =>TMPWRM_DATA(5)(15))           WHEN (x"000D") ,
								( OTHERS =>TMPWRM_DATA(6)(15))           WHEN (x"000E") ,
								( OTHERS =>TMPWRM_DATA(7)(15))           WHEN (x"000F") ,
								( OTHERS =>TMPCLD_DATA(0)(15))           WHEN (x"0010") ,
								( OTHERS =>TMPCLD_DATA(1)(15))           WHEN (x"0011") ,
								( OTHERS =>TMPCLD_DATA(2)(15))           WHEN (x"0012") ,
								( OTHERS =>TMPCLD_DATA(3)(15))           WHEN (x"0013") ,
								( OTHERS =>TMPCLD_DATA(4)(15))           WHEN (x"0014") ,
								( OTHERS =>TMPCLD_DATA(5)(15))           WHEN (x"0015") ,
								( OTHERS =>TMPCLD_DATA(6)(15))           WHEN (x"0016") ,
								( OTHERS =>TMPCLD_DATA(7)(15))           WHEN (x"0017") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(0)(15))      WHEN (x"003C") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(1)(15))      WHEN (x"003D") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(2)(15))      WHEN (x"003E") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(3)(15))      WHEN (x"003F") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(4)(15))      WHEN (x"0040") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(5)(15))      WHEN (x"0041") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(6)(15))      WHEN (x"0042") ,
								( OTHERS =>TMPWRM_LIMIT_ISA(7)(15))      WHEN (x"0043") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(0)(15))      WHEN (x"0044") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(1)(15))      WHEN (x"0045") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(2)(15))      WHEN (x"0046") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(3)(15))      WHEN (x"0047") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(4)(15))      WHEN (x"0048") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(5)(15))      WHEN (x"0049") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(6)(15))      WHEN (x"004A") ,
								( OTHERS =>TMPCLD_LIMIT_ISA(7)(15))      WHEN (x"004B") ,
		                                                CAVCONFIG(31 downto 16)               	  when (x"006d"),
								intrstr(31 downto 16)               	  when (x"006e"),
								c_addr(31 downto 16)							  when (x"00D5"), -- EPCQ address
								c_cntlr(31 downto 16)	    				  when (x"00D6"), -- control bits for read writing and configurting EPCQ
								c10_status(31 downto 16)					  when (x"00D7"), -- checksum and status
								c10_datar(31 downto 16)	  					  when (x"00D8"), -- read data
								c_data(31 downto 16)			 				  when (x"00D9"),	-- data to write							
								( OTHERS => ARC_BUFF_DATA_out(15))	 	  WHEN OTHERS;
--
	-- only the lower 16 bits of address are needed
	-- dout will output 16 bits
	WITH ADDR(15 DOWNTO 0) SELECT

	DOUT(15 downto 0)<=ARC_DATA(0) WHEN (x"0000") ,
			ARC_DATA(1)              WHEN (x"0001") ,
			ARC_DATA(2)              WHEN (x"0002") ,
			ARC_DATA(3)              WHEN (x"0003") ,
			ARC_DATA(4)              WHEN (x"0004") ,
			ARC_DATA(5)              WHEN (x"0005") ,
			ARC_DATA(6)              WHEN (x"0006") ,
			ARC_DATA(7)              WHEN (x"0007") ,
			TMPWRM_DATA(0)           WHEN (x"0008") ,
			TMPWRM_DATA(1)           WHEN (x"0009") ,
			TMPWRM_DATA(2)           WHEN (x"000A") ,
			TMPWRM_DATA(3)           WHEN (x"000B") ,
			TMPWRM_DATA(4)           WHEN (x"000C") ,
			TMPWRM_DATA(5)           WHEN (x"000D") ,
			TMPWRM_DATA(6)           WHEN (x"000E") ,
			TMPWRM_DATA(7)           WHEN (x"000F") ,
			TMPCLD_DATA(0)           WHEN (x"0010") ,
			TMPCLD_DATA(1)           WHEN (x"0011") ,
			TMPCLD_DATA(2)           WHEN (x"0012") ,
			TMPCLD_DATA(3)           WHEN (x"0013") ,
			TMPCLD_DATA(4)           WHEN (x"0014") ,
			TMPCLD_DATA(5)           WHEN (x"0015") ,
			TMPCLD_DATA(6)           WHEN (x"0016") ,
			TMPCLD_DATA(7)           WHEN (x"0017") ,		
			ARC_FAULT_STATUS         WHEN (x"0018") ,
			TMPWRM_FAULT_STATUS      WHEN (x"0019") ,
			TMPCLD_FAULT_STATUS      WHEN (x"001A") ,
			INTEN_FAULT_STATUS       WHEN (x"001B") ,
			FC_FSD_FAULT_STATUS      WHEN (x"001C") , 
			VAC_FAULT_STATUS(16 DOWNTO 9) & VAC_FAULT_STATUS(7 DOWNTO 0) WHEN (x"001D") ,
			FAULT_STATUS_REG         WHEN (x"001E") ,
			"000" & DIG_TEMP         WHEN (x"001F") , -- now this is the temp sensor inside fpga, 10 bits
			(x"00" & ARC_TST_ISA)    WHEN (x"0020") ,
			(x"00" & TMPWRM_TST_ISA) WHEN (x"0021") ,
			(x"00" & TMPCLD_TST_ISA) WHEN (x"0022") ,			
			ARC_LIMIT_ISA(0)         WHEN (x"0023") ,
			ARC_LIMIT_ISA(1)         WHEN (x"0024") ,
			ARC_LIMIT_ISA(2)         WHEN (x"0025") ,
			ARC_LIMIT_ISA(3)         WHEN (x"0026") ,
			ARC_LIMIT_ISA(4)         WHEN (x"0027") ,
			ARC_LIMIT_ISA(5)         WHEN (x"0028") ,
			ARC_LIMIT_ISA(6)         WHEN (x"0029") ,
			ARC_LIMIT_ISA(7)         WHEN (x"002A") ,
			ARC_TIMER_ISA(0)         WHEN (x"002B") ,
			ARC_TIMER_ISA(1)         WHEN (x"002C") ,
			ARC_TIMER_ISA(2)         WHEN (x"002D") ,
			ARC_TIMER_ISA(3)         WHEN (x"002E") ,
			ARC_TIMER_ISA(4)         WHEN (x"002F") ,
			ARC_TIMER_ISA(5)         WHEN (x"0030") ,
			ARC_TIMER_ISA(6)         WHEN (x"0031") ,
			ARC_TIMER_ISA(7)         WHEN (x"0032") ,
			ARC_DELAY_ISA(0)         WHEN (x"0033") ,
			ARC_DELAY_ISA(1)         WHEN (x"0034") ,
			ARC_DELAY_ISA(2)         WHEN (x"0035") ,
			ARC_DELAY_ISA(3)         WHEN (x"0036") ,
			ARC_DELAY_ISA(4)         WHEN (x"0037") ,
			ARC_DELAY_ISA(5)         WHEN (x"0038") ,
			ARC_DELAY_ISA(6)         WHEN (x"0039") ,
			ARC_DELAY_ISA(7)         WHEN (x"003A") ,
			(x"00" & ARC_STOP_ISA)   WHEN (x"003B") ,
			TMPWRM_LIMIT_ISA(0)      WHEN (x"003C") ,
			TMPWRM_LIMIT_ISA(1)      WHEN (x"003D") ,
			TMPWRM_LIMIT_ISA(2)      WHEN (x"003E") ,
			TMPWRM_LIMIT_ISA(3)      WHEN (x"003F") ,
			TMPWRM_LIMIT_ISA(4)      WHEN (x"0040") ,
			TMPWRM_LIMIT_ISA(5)      WHEN (x"0041") ,
			TMPWRM_LIMIT_ISA(6)      WHEN (x"0042") ,
			TMPWRM_LIMIT_ISA(7)      WHEN (x"0043") ,
			TMPCLD_LIMIT_ISA(0)      WHEN (x"0044") ,
			TMPCLD_LIMIT_ISA(1)      WHEN (x"0045") ,
			TMPCLD_LIMIT_ISA(2)      WHEN (x"0046") ,
			TMPCLD_LIMIT_ISA(3)      WHEN (x"0047") ,
			TMPCLD_LIMIT_ISA(4)      WHEN (x"0048") ,
			TMPCLD_LIMIT_ISA(5)      WHEN (x"0049") ,
			TMPCLD_LIMIT_ISA(6)      WHEN (x"004A") ,
			TMPCLD_LIMIT_ISA(7)      WHEN (x"004B") ,			
			x"00" & MASK_ARC_FAULT_OUT              WHEN (x"004C") ,
			x"0" & "000" & MASK_VAC_FAULT_OUT       WHEN (x"004D") ,
			x"00" & MASK_TMP_FAULT_OUT(7 DOWNTO 0)  WHEN (x"004E") ,
			x"00" & MASK_TMP_FAULT_OUT(15 DOWNTO 8) WHEN (x"004F") ,
			x"0" & "000" & MASK_INTEN_FAULT         WHEN (x"0050") ,
			x"00" & MASK_FC_FSD_FAULT               WHEN (x"0051") ,
			CONTROL_REG_ISA                         WHEN (x"0052") ,
			VERSION                                 WHEN (x"0053") ,
			x"00" & ARC_BUFF_READY                  WHEN (x"0054") ,
			x"00" & ARC_FLT_CLR_OUT                 WHEN (x"0055") ,
			x"00" & TMPWRM_FLT_CLR_OUT              WHEN (x"0056") ,
			x"00" & TMPCLD_FLT_CLR_OUT              WHEN (x"0057") ,
			x"0" & "000" & INTEN_CLR_OUT            WHEN (x"0058") ,
			x"00" & FC_FSD_CLR_OUT                  WHEN (x"0059") ,
			x"0" & "000" & VAC_FLT_CLR_OUT          WHEN (x"005A") ,
			ARC_PWR_ISA(0)                          WHEN (x"005B") ,
			ARC_PWR_ISA(1)                          WHEN (x"005C") ,
			ARC_PWR_ISA(2)                          WHEN (x"005D") ,
			ARC_PWR_ISA(3)                          WHEN (x"005E") ,
			ARC_PWR_ISA(4)                          WHEN (x"005F") ,
			ARC_PWR_ISA(5)                          WHEN (x"0060") ,
			ARC_PWR_ISA(6)                          WHEN (x"0061") ,
			ARC_PWR_ISA(7)                          WHEN (x"0062") ,
			ARC_PULSE_PRD                           WHEN (x"0063") ,
			x"00" & FIRST_CAVITY_FAULT              WHEN (x"0064") ,
			x"00" & ARC_TST_FLT_INT                 WHEN (x"0065") ,
			x"0000"						 when (x"0066") , -- spares added
			x"0000"						 when (x"0067") , -- spares added
			x"0000"						 when (x"0068") , -- spares added
			x"0000"						 when (x"0069") , -- spares added
			x"0000"						 when (x"006a") , -- spares added
			x"0000"						 when (x"006b") , -- spares added
			x"0000"						 when (x"006c") , -- spares added
			CAVCONFIG(15 downto 0)	   	                 when (x"006d") , -- cavity configuration
			intrstr(15 downto 0)		 when (x"006e"),  -- epics pv watchdog 
			JTAGMUX(15 downto 0)         when (x"00B1"),  -- jtag_mux_select
			c_addr(15 downto 0)		     when (x"00D5"),  -- EPCQ address
			c_cntlr(15 downto 0)	     when (x"00D6"),  -- control bits for read writing and configurting EPCQ
			c10_status(15 downto 0)	     when (x"00D7"),  -- checksum and status
			c10_datar(15 downto 0)	     when (x"00D8"),  -- read data
			c_data(15 downto 0)		     when (x"00D9"),  -- data to write	
			ethChipID                    when (x"00DA"),
			ARC_BUFF_DATA_out            WHEN OTHERS;

				
	-- LLRF 3.0 firmware version will start with '30'
	VERSION <= x"753A"; -- UPDATE BY JAL FOR LLRF 3.0
							  -- 3001, init
							  -- 3002, hrt change to move arc buffer data to end of hrt.
							  -- 3004, ramas arc adc code
							  -- 3005, circular buffer for arc fault capture
							  -- 3006, remote firmware download added
							  -- making fw version easier to read.
							  -- decimal 30,001 stable udp module code
							  -- decimal 30,002 inverted IR sensors
							  -- decimal 30,003 removed all ways to remotely reset interlocks chassis including remote coniguration
							  -- decimal 30,004 swticehd to Marvel PHY chip
							  -- decimal 30,005 'simple' fimrware download, lowered IR sPI to 7.8 MHz
							  -- decimal 30,006 new name to make 2 versions of 30,005 less confusing
							  -- decimal 30,007 fix timing issue caused by temp sensore that may have been breaking remote firmware download
							  -- x7538, removed AC13 10 MHZ clock
							  -- x"7539", added c100/c75 switch to IR sensor
							  -- x"753A", added marvell ID chip detection
	
END ARCHITECTURE;
