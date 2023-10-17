LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

-- Abbreviations and  Notes:
-- FSD 	= fast shutdown
-- FLT 	= fault
-- fc  	= field control
-- inten	= interlock enable
-- a mask ignores the fault if it occurs.

-- note, new local bus clock is 125 Mhz (8ns period). I added notes on some of the timing changes in the f/w below.

ENTITY INTEN_FC_FSD IS
	PORT(CLOCK       : IN STD_LOGIC;
		 RESET        : IN STD_LOGIC;		 
		 FC_FSD_MASK  : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- set HI to mask out that channels Field control FSD
		 INTEN_MASK   : IN STD_LOGIC_VECTOR(8 DOWNTO 0); -- [8] CORRESPONDS TO FSD MAIN MASK, set HI to mask out that channel
		 CAV_FLT_FPGA : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- fault from cavity module,HI=Fault (channel specific)
		 FC_FSD_CLEAR : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 INTEN_CLEAR  : IN STD_LOGIC_VECTOR(8 DOWNTO 0); -- set HI to clear fault latch (channel specific)
		 --FAULT_CLEAR: IN STD_LOGIC;
		 FIVE_MHZ     : IN STD_LOGIC;
		 INTEN_FPGA   : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- FSD_CAV_FPGA
		 ARC_TST_FLT  : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 	 
		 
		 INTEN_FAULT_STATUS    : OUT STD_LOGIC_VECTOR(15 DOWNTO 0); -- fault latch (15:8) & fault status (7:0) (channel specific)
		 FC_FSD_FAULT_STATUS   : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 MAIN_FSD_FAULT_STATUS : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 FSD_MAIN              : OUT STD_LOGIC;							-- machine protection system (MPS) signal. 5 Mhz unless if any channels has a fault, then it is held low
		 FIRST_CAVITY_FAULT    : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 FC_FSD_FPGA           : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)  -- should be a 5Mhz signal if all is well, will be held LOW if a CAV_FLT_FPGA fault occurs
		 );
END ENTITY INTEN_FC_FSD;

ARCHITECTURE BEHAVIOR OF INTEN_FC_FSD IS


SIGNAL FC_FSD_FAULT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FC_FSD_STATUS			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL EN_FC_FSD				: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL INTEN_FAULT			: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_STATUS			: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL MAIN_FSD_FAULT		: STD_LOGIC;
SIGNAL MAIN_FSD_STATUS		: STD_LOGIC;
SIGNAL EN_MAIN_FSD			: STD_LOGIC;

SIGNAL MAIN_FSD_CLEAR_INT1	: STD_LOGIC;
SIGNAL MAIN_FSD_CLEAR_INT2	: STD_LOGIC;

SIGNAL CLEAR_INTEN_COUNT	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL EN_INTEN_COUNT		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_INT1				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_INT2				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_INT3				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_COUNT			: REG5_ARRAY;
SIGNAL INTEN_FAULT_COND		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_STATUS_COND	: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_INTEN_FAULT		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL EN_INTEN_COUNT2		: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL CLEAR_INTEN_COUNT2	: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL INTEN_COUNT2			: REG5_ARRAY; 

SIGNAL FSD_MAIN_INT			: STD_LOGIC;

SIGNAL INTEN_INT				: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL FC_FSD_INT				: STD_LOGIC_VECTOR(8 DOWNTO 0);

SIGNAL EN_FIRST_FAULT		: STD_LOGIC;
SIGNAL FIRST_CAV_FAULT		: STD_LOGIC_VECTOR(7 DOWNTO 0);

SIGNAL ONE						: STD_LOGIC;

BEGIN

ONE <= '1';


------------inten fault and status---------------------------

---inten signal is a 5 MHz fiber input signal,absense of pulses mean it is not active



INTEN_DET_GEN: FOR I IN 0 TO 7 GENERATE

INTEN_DET_FFI1: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> INTEN_FPGA(I),
			 OUP	=> INTEN_INT1(I)
			);
			
INTEN_DET_FFI2: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> INTEN_INT1(I),
			 OUP	=> INTEN_INT2(I)
			);
			
INTEN_DET_FFI3: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> ONE,
			 EN		=> ONE,
			 INP	=> INTEN_INT2(I),
			 OUP	=> INTEN_INT3(I)
			);
			

	INTEN_COUNTI: COUNTER
		GENERIC MAP(N => 5)
		PORT MAP(CLOCK	=> CLOCK,
				 RESET	=> RESET,
				 CLEAR	=> CLEAR_INTEN_COUNT(I),
				 ENABLE	=> EN_INTEN_COUNT(I),		
				 COUNT	=> INTEN_COUNT(I)
				);
				
-- enable counter if last two ticks of inten is low (lack of 5 Mhz signal)
-- @ 125 MHz clock, this would mean that the channel has been low for 32*8ns = 256 ns. 5 Mhz period is 200 ns (100 ns low, 100 ns hi).
-- If the 5 Mhz signal is correctly coming in, this counter should be cleared once ever 100 ns, thus if the signal is missing for 256ns
-- it is likely a fault condition.
--
--@ 80 mhz clock, the period would be 12.5 ns, 32*12.5ns is 400 ns. We could change counter counter to 6 bits if we want a similar tolerance.
--
EN_INTEN_COUNT(I) <= '1' when INTEN_INT2(I) = '0' and INTEN_INT3(I) = '0' and INTEN_COUNT(I) /= "11111" else '0';

-- clear counter if we see the 5Mhz clock (last 2 ticks are hi)
CLEAR_INTEN_COUNT(I) <=  '0' WHEN INTEN_CLEAR(I) = '1' OR (INTEN_CLEAR(I) = '0' AND (INTEN_INT2(I) = '1' OR INTEN_INT3(I) = '1') AND INTEN_COUNT(I) /= "11111") ELSE '1';

--if iten was low for too long, the 5Mhz keep alive is low meaning a fault should be issued for that channel
INTEN_FAULT_COND(I) <= '1' WHEN INTEN_COUNT(I) = "11111" ELSE '0';
--

-- unfiltered status
INTEN_STATUS(I) <= INTEN_FAULT_COND(I);

INTEN_FAULT_FFI: LATCH_N
	PORT MAP(CLOCK	=> CLOCK, 
			 RESET	=> RESET,
			 CLEAR	=> NOT INTEN_CLEAR(I),
			 EN		=> EN_INTEN_FAULT(I),
			 INP	=> ONE,
			 OUP	=> INTEN_FAULT(I)
			);
-- enable fault latch if the fault conditione exist and is not masked out.			
EN_INTEN_FAULT(I) <= INTEN_FAULT_COND(I) AND NOT INTEN_MASK(I);
							
END GENERATE;

-- concatenate the fault latch and the the unfiltered fault status
INTEN_FAULT_STATUS <= INTEN_FAULT & INTEN_STATUS;--5 MHz signal status and latched from FC chassis


--holds the value of which caivty faulted first (should be one hot unless mutlipe cavities fail at the same time)
FIRST_CAVITY_FAULT <= FIRST_CAV_FAULT;
--INTEN_FAULT_STATUS <= INTEN_FAULT & FIRST_CAV_FAULT;---5 MHz latched from FC chassis and first cavity fault



--------First Cavity Fault------------

FIRST_FAULT_REG: REGNE
		GENERIC MAP(N => 8) 
		PORT MAP(CLOCK	=> CLOCK, 	
				 RESET	=> RESET,	 
				 CLEAR	=> NOT INTEN_CLEAR(8), ---USING THE SAME CLEAR AS BEAM FSD
				 EN		=> EN_FIRST_FAULT,		
				 INPUT	=> INTEN_FAULT,	
				 OUTPUT	=> FIRST_CAV_FAULT
				);

-- only enable the first cavity fault resgister on only the first fault.
EN_FIRST_FAULT <= '1' WHEN (INTEN_FAULT /= "00000000") AND FIRST_CAV_FAULT = "00000000" ELSE '0';

--------------------------------------
--
--------------------------------------

--fault from register module. This is a channel specific fault registered in the regs module.
FC_FSD_STATUS <= CAV_FLT_FPGA;

FC_FSD_LATCH_GEN: FOR I IN 0 TO 7 GENERATE

	FC_FSD_LATCH_FFI1: LATCH_N
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR	=> NOT FC_FSD_CLEAR(I),
				 EN		=> EN_FC_FSD(I),
				 INP	=> ONE,
				 OUP	=> FC_FSD_FAULT(I) -- LOW means normal, HI means fault
				);
	-- enable the fault to be latched if not masked
	EN_FC_FSD(I) <= CAV_FLT_FPGA(I) AND (NOT FC_FSD_MASK(I));
	--allow 5 Mhz signal to be passed through unless if a fault is latched, then hold this signal LOW
	FC_FSD_FPGA(I) <= FIVE_MHZ AND (NOT FC_FSD_FAULT(I));

END GENERATE;

	MAIN_FSD_LATCH_FF: LATCH_N
		PORT MAP(CLOCK	=> CLOCK, 
				 RESET	=> RESET,
				 CLEAR	=> NOT INTEN_CLEAR(8),
				 EN		=> EN_MAIN_FSD,
				 INP	=> ONE,
				 OUP	=> MAIN_FSD_FAULT
				);
--keep low unless if there is a FSD fault (from reg) or inten fault (loss of 5Mhz fiber).
--if either of these faults occur, set to HI
FSD_MAIN_INT <= '0' WHEN (FC_FSD_FAULT = x"00" AND INTEN_FAULT = x"00") ELSE '1';
--enable if not masked.
EN_MAIN_FSD <= FSD_MAIN_INT AND (NOT INTEN_MASK(8));
--will pass through 5 Mhz if no faults, otherwise will pull line low which indicates a fault
FSD_MAIN <= FIVE_MHZ AND NOT MAIN_FSD_FAULT;

MAIN_FSD_STATUS <= FSD_MAIN_INT;

--concatanate fault status
FC_FSD_FAULT_STATUS <= FC_FSD_FAULT & FC_FSD_STATUS;
MAIN_FSD_FAULT_STATUS <= MAIN_FSD_FAULT & MAIN_FSD_STATUS;

END ARCHITECTURE BEHAVIOR;