-- Copyright (C) 1991-2013 Altera Corporation
-- Your use of Altera Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Altera Program License 
-- Subscription Agreement, Altera MegaCore Function License 
-- Agreement, or other applicable license agreement, including, 
-- without limitation, that your use is for the sole purpose of 
-- programming logic devices manufactured by Altera and sold by 
-- Altera or its authorized distributors.  Please refer to the 
-- applicable agreement for further details.

-- PROGRAM		"Quartus II 64-Bit"
-- VERSION		"Version 13.1.0 Build 162 10/23/2013 SJ Web Edition"
-- CREATED		"Mon Jul 13 10:29:02 2020"

--Latshaw: used quartus tool to generate this vhdl file from the BDF.
-- generated file was VERY verbose and messy. I ended up having to
-- hand wire the modules.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY FCC_DATA_ACQ_FIBER_CONTROL IS 
	PORT
	(
		RESET :  IN  STD_LOGIC;
		CLOCK :  IN  STD_LOGIC;
		deta_disc_regs : OUT reg2_array; -- added 3/31/21, will go to motor_status in regs
		step_en        : OUT STD_LOGIC_VECTOR(7 downto 0);
		DETA_HI :  IN  reg16_array;
		DETA_LO :  IN  reg16_array;
		DISC_HI :  IN  reg16_array;
		DISC_LO :  IN  reg16_array;
		DONE_MOVE :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIB_MODE :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIBER_IN :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		PZT_HI :  IN  reg16_array;
		PZT_LO :  IN  reg16_array;
		STEP_HZ :  IN  reg32_array;
		STOP :  IN  STD_LOGIC_VECTOR(7 DOWNTO 0);
		DETA :  OUT  reg16_array;
		DIRECTION :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		DISC :  OUT  reg28_array;
		DONE_ISA :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		FIB_MODE_OUT :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		MOVE :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		PZ :  OUT  reg16_array;
		SLOW_MODE :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		STEPS :  OUT  reg32_array
	);
END FCC_DATA_ACQ_FIBER_CONTROL;

ARCHITECTURE bdf_type OF FCC_DATA_ACQ_FIBER_CONTROL IS 


COMPONENT fcc_data_acq
	PORT(RESET : IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;
		 FIBER_IN : IN STD_LOGIC;
		 TRACK_ON : OUT STD_LOGIC;
		 SLOW_GDR : OUT STD_LOGIC;
		 DETA_DISC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 DETUN_ANGLE : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DISC : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
		 PZT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT fiber_control
	PORT(RESET : IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;
		 TRACK_ON : IN STD_LOGIC;
		 FIB_MODE : IN STD_LOGIC;
		 DONE_MOVE : IN STD_LOGIC;
		 STOP : IN STD_LOGIC;
		 DETA : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DETA_DISC : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 DETA_HI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DETA_LO : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DISC : IN STD_LOGIC_VECTOR(27 DOWNTO 0);
		 DISC_HI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DISC_LO : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PZT : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PZT_HI : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 PZT_LO : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 STEP_HZ : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DIR : OUT STD_LOGIC;
		 MOVE : OUT STD_LOGIC;
		 DONE_ISA : OUT STD_LOGIC;
		 FIB_MODE_OUT : OUT STD_LOGIC;
		 STEPS : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;
--declare signals

--for FCC_DATA_ACQ modules (some are inputs to FIBER_CONTROL MODULES)
signal TRACK_ON, SLOW_GDR : STD_LOGIC_VECTOR(7 downto 0); -- track on is input to fiber control module, slow_GDR is output
signal DETA_DISC : STD_LOGIC_VECTOR(15 downto 0); -- 2 bits per FCC_DATA_ACQ module, input to fiber control module
signal DETUN_ANGLE : reg16_array;              -- input to fiber control module
signal DISC_wire : reg28_array; -- input to fiber control module
signal PZT : reg16_array; -- input to fiber control module
--
--for FIBER_CONTROL module (outputs of the FCC_DATA_ACQ_FIBER_CONTROL module)
signal DIR, MOVE_wire, DONE_ISA_wire, FIB_MODE_OUT_wire : STD_LOGIC_VECTOR(7 downto 0);
signal STEPS_wire : reg32_array;
--
begin
--
-- connect deta disc
deta_disc_regs(0) <= DETA_DISC(1 downto 0);
deta_disc_regs(1) <= DETA_DISC(3 downto 2);
deta_disc_regs(2) <= DETA_DISC(5 downto 4);
deta_disc_regs(3) <= DETA_DISC(7 downto 6);
deta_disc_regs(4) <= DETA_DISC(9 downto 8);
deta_disc_regs(5) <= DETA_DISC(11 downto 10);
deta_disc_regs(6) <= DETA_DISC(13 downto 12);
deta_disc_regs(7) <= DETA_DISC(15 downto 14);

--connect enable (also called track on)
step_en(0) <= TRACK_ON(0);
step_en(1) <= TRACK_ON(1);
step_en(2) <= TRACK_ON(2);
step_en(3) <= TRACK_ON(3);
step_en(4) <= TRACK_ON(4);
step_en(5) <= TRACK_ON(5);
step_en(6) <= TRACK_ON(6);
step_en(7) <= TRACK_ON(7);


--==================================================================
-- Connections between Modules (I probably should have used generate)
--==================================================================
--
FCC_Data_0 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(0), TRACK_ON(0), SLOW_GDR(0), DETA_DISC(1 downto 0), DETUN_ANGLE(0), DISC_wire(0), PZT(0));
--
FIBER_CONT_0 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(0), FIB_MODE(0), DONE_MOVE(0), STOP(0), DETUN_ANGLE(0), DETA_DISC(1 downto 0), DETA_HI(0), 
			         DETA_LO(0), DISC_wire(0), DISC_HI(0), DISC_LO(0), PZT(0), PZT_HI(0), PZT_LO(0), STEP_HZ(0),
						DIR(0), MOVE_wire(0), DONE_ISA_wire(0), FIB_MODE_OUT_wire(0), STEPS_wire(0));
--
--
FCC_Data_1 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(1), TRACK_ON(1), SLOW_GDR(1), DETA_DISC(3 downto 2), DETUN_ANGLE(1), DISC_wire(1), PZT(1));
--
FIBER_CONT_1 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(1), FIB_MODE(1), DONE_MOVE(1), STOP(1), DETUN_ANGLE(1), DETA_DISC(3 downto 2), DETA_HI(1), 
			         DETA_LO(1), DISC_wire(1), DISC_HI(1), DISC_LO(1), PZT(1), PZT_HI(1), PZT_LO(1), STEP_HZ(1),
						DIR(1), MOVE_wire(1), DONE_ISA_wire(1), FIB_MODE_OUT_wire(1), STEPS_wire(1));
--
--
FCC_Data_2 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(2), TRACK_ON(2), SLOW_GDR(2), DETA_DISC(5 downto 4), DETUN_ANGLE(2), DISC_wire(2), PZT(2));
--
FIBER_CONT_2 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(2), FIB_MODE(2), DONE_MOVE(2), STOP(2), DETUN_ANGLE(2), DETA_DISC(5 downto 4), DETA_HI(2), 
			         DETA_LO(2), DISC_wire(2), DISC_HI(2), DISC_LO(2), PZT(2), PZT_HI(2), PZT_LO(2), STEP_HZ(2),
						DIR(2), MOVE_wire(2), DONE_ISA_wire(2), FIB_MODE_OUT_wire(2), STEPS_wire(2));
--
--
FCC_Data_3 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(3), TRACK_ON(3), SLOW_GDR(3), DETA_DISC(7 downto 6), DETUN_ANGLE(3), DISC_wire(3), PZT(3));
--
FIBER_CONT_3 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(3), FIB_MODE(3), DONE_MOVE(3), STOP(3), DETUN_ANGLE(3), DETA_DISC(7 downto 6), DETA_HI(3), 
			         DETA_LO(3), DISC_wire(3), DISC_HI(3), DISC_LO(3), PZT(3), PZT_HI(3), PZT_LO(3), STEP_HZ(3),
						DIR(3), MOVE_wire(3), DONE_ISA_wire(3), FIB_MODE_OUT_wire(3), STEPS_wire(3));
--
--
FCC_Data_4 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(4), TRACK_ON(4), SLOW_GDR(4), DETA_DISC(9 downto 8), DETUN_ANGLE(4), DISC_wire(4), PZT(4));
--
FIBER_CONT_4 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(4), FIB_MODE(4), DONE_MOVE(4), STOP(4), DETUN_ANGLE(4), DETA_DISC(9 downto 8), DETA_HI(4), 
			         DETA_LO(4), DISC_wire(4), DISC_HI(4), DISC_LO(4), PZT(4), PZT_HI(4), PZT_LO(4), STEP_HZ(4),
						DIR(4), MOVE_wire(4), DONE_ISA_wire(4), FIB_MODE_OUT_wire(4), STEPS_wire(4));
--
--
FCC_Data_5 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(5), TRACK_ON(5), SLOW_GDR(5), DETA_DISC(11 downto 10), DETUN_ANGLE(5), DISC_wire(5), PZT(5));
--
FIBER_CONT_5 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(5), FIB_MODE(5), DONE_MOVE(5), STOP(5), DETUN_ANGLE(5), DETA_DISC(11 downto 10), DETA_HI(5), 
			         DETA_LO(5), DISC_wire(5), DISC_HI(5), DISC_LO(5), PZT(5), PZT_HI(5), PZT_LO(5), STEP_HZ(5),
						DIR(5), MOVE_wire(5), DONE_ISA_wire(5), FIB_MODE_OUT_wire(5), STEPS_wire(5));
--
--
FCC_Data_6 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(6), TRACK_ON(6), SLOW_GDR(6), DETA_DISC(13 downto 12), DETUN_ANGLE(6), DISC_wire(6), PZT(6));
--
FIBER_CONT_6 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(6), FIB_MODE(6), DONE_MOVE(6), STOP(6), DETUN_ANGLE(6), DETA_DISC(13 downto 12), DETA_HI(6), 
			         DETA_LO(6), DISC_wire(6), DISC_HI(6), DISC_LO(6), PZT(6), PZT_HI(6), PZT_LO(6), STEP_HZ(6),
						DIR(6), MOVE_wire(6), DONE_ISA_wire(6), FIB_MODE_OUT_wire(6), STEPS_wire(6));
--
--
FCC_Data_7 : fcc_data_acq 
         PORT MAP(RESET, CLOCK, FIBER_IN(7), TRACK_ON(7), SLOW_GDR(7), DETA_DISC(15 downto 14), DETUN_ANGLE(7), DISC_wire(7), PZT(7));
--
FIBER_CONT_7 : fiber_control
         PORT MAP(RESET, CLOCK, TRACK_ON(7), FIB_MODE(7), DONE_MOVE(7), STOP(7), DETUN_ANGLE(7), DETA_DISC(15 downto 14), DETA_HI(7), 
			         DETA_LO(7), DISC_wire(7), DISC_HI(7), DISC_LO(7), PZT(7), PZT_HI(7), PZT_LO(7), STEP_HZ(7),
						DIR(7), MOVE_wire(7), DONE_ISA_wire(7), FIB_MODE_OUT_wire(7), STEPS_wire(7));
--
--==================================================================
-- Assign Module Outputs
--==================================================================
		DETA          <= DETUN_ANGLE;        -- Output of FCC_DATA_ACQ
		DIRECTION     <= DIR;                -- Ouptut of FIBER_CONTROL
		DISC          <= DISC_wire;          -- Output of FCC_DATA_ACQ
		DONE_ISA      <= DONE_ISA_wire;      -- Ouptut of FIBER_CONTROL
		FIB_MODE_OUT  <= FIB_MODE_OUT_wire;  -- Ouptut of FIBER_CONTROL
		MOVE          <= MOVE_wire;          -- Ouptut of FIBER_CONTROL
		PZ            <= PZT;                -- Output of FCC_DATA_ACQ
		SLOW_MODE     <= SLOW_GDR;           -- Output of FCC_DATA_ACQ
		STEPS         <= STEPS_wire;         -- Ouptut of FIBER_CONTROL
--
-- end module
END bdf_type;