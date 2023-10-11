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
-- CREATED		"Mon Jul 13 10:06:15 2020"

-- Latshaw: Generated VHDL from BDF. Renamed syntheized wires to more meaninful names.

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY FCC_DATA_ACQ IS 
	PORT
	(
		FIBER_IN :  IN  STD_LOGIC;
		CLOCK :  IN  STD_LOGIC;
		RESET :  IN  STD_LOGIC;
		TRACK_ON :  OUT  STD_LOGIC;
		SLOW_GDR :  OUT  STD_LOGIC;
		DETA_DISC :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		DETUN_ANGLE :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0);
		DISC :  OUT  STD_LOGIC_VECTOR(27 DOWNTO 0);
		PZT :  OUT  STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END FCC_DATA_ACQ;

ARCHITECTURE bdf_type OF FCC_DATA_ACQ IS 

COMPONENT fcc_data_in
	PORT(RESET : IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;
		 FIBER_IN_DATA : IN STD_LOGIC;
		 CRC_DONE : IN STD_LOGIC;
		 CRC_IN : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 START_CRC : OUT STD_LOGIC;
		 TRACK_ON : OUT STD_LOGIC;
		 SLOW_MODE : OUT STD_LOGIC;
		 CRC_DATA : OUT STD_LOGIC_VECTOR(39 DOWNTO 0);
		 DENOM : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
		 DETA : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DETA_DISC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
		 DISC : OUT STD_LOGIC_VECTOR(27 DOWNTO 0);
		 PZT : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
	);
END COMPONENT;

COMPONENT polynomial_division
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 START_CRC : IN STD_LOGIC;
		 DATA_IN : IN STD_LOGIC_VECTOR(39 DOWNTO 0);
		 DENOM : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 CRC_DONE : OUT STD_LOGIC;
		 CRC : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		 DATA_OUT_CRC : OUT STD_LOGIC_VECTOR(39 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	CRC_DONE_SIG :  STD_LOGIC;
SIGNAL	CRC_IN_SIG :  STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL	START_CRC_SIG :  STD_LOGIC;
SIGNAL	DATA_IN_SIG :  STD_LOGIC_VECTOR(39 DOWNTO 0);
SIGNAL	DENOM_SIG :  STD_LOGIC_VECTOR(8 DOWNTO 0);


BEGIN 



FCC_data_input_module : fcc_data_in
PORT MAP(RESET => RESET,
		 CLOCK => CLOCK,
		 FIBER_IN_DATA => FIBER_IN,
		 CRC_DONE => CRC_DONE_SIG,
		 CRC_IN => CRC_IN_SIG,
		 START_CRC => START_CRC_SIG,
		 TRACK_ON => TRACK_ON,
		 SLOW_MODE => SLOW_GDR,
		 CRC_DATA => DATA_IN_SIG,
		 DENOM => DENOM_SIG,
		 DETA => DETUN_ANGLE,
		 DETA_DISC => DETA_DISC,
		 DISC => DISC,
		 PZT => PZT);


poly_div : polynomial_division
PORT MAP(CLOCK => CLOCK,
		 RESET => RESET,
		 START_CRC => START_CRC_SIG,
		 DATA_IN => DATA_IN_SIG,
		 DENOM => DENOM_SIG,
		 CRC_DONE => CRC_DONE_SIG,
		 CRC => CRC_IN_SIG);


END bdf_type;