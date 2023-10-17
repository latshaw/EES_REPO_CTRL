LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY ISA_BUS IS
	PORT(RESET : IN STD_LOGIC;
		 CLOCK : IN STD_LOGIC;		 
		 ISA_BALE : IN STD_LOGIC;
		 ISA_AEN : IN STD_LOGIC;
		 ISA_MEMR : IN STD_LOGIC;
		 ISA_MEMW : IN STD_LOGIC;		 
		 ISA_SMEMR : IN STD_LOGIC;
		 ISA_SMEMW : IN STD_LOGIC;
		 ISA_SBHE : IN STD_LOGIC;
		 ISA_SA : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
		 REGS_D : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 ISA_SD_DIR : OUT STD_LOGIC;
		 ISA_CS16 : OUT STD_LOGIC;		 
		 ISA_SD : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 ADDR_OUT : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
		 REGS_LD : OUT STD_LOGIC		 		 
		);
END ENTITY ISA_BUS;

ARCHITECTURE BEHAVIOR OF ISA_BUS IS

SIGNAL BALE_INT1					: STD_LOGIC;
SIGNAL BALE_INT2					: STD_LOGIC;
SIGNAL BALE_INT3					: STD_LOGIC;

SIGNAL ISA_ADDR_VALID				: STD_LOGIC;
SIGNAL ADDR_VALID					: STD_LOGIC;
SIGNAL ADDR_EN						: STD_LOGIC;
SIGNAL ADDR							: STD_LOGIC_VECTOR(19 DOWNTO 0);

SIGNAL WRADDR_VALID					: STD_LOGIC;
--SIGNAL en_write_data				: STD_LOGIC;
--SIGNAL en_write_data1				: STD_LOGIC;
--SIGNAL en_write_data2				: STD_LOGIC;

SIGNAL ISAW_INT1					: STD_LOGIC;
SIGNAL ISAW_INT2					: STD_LOGIC;
SIGNAL ISAW_INT3					: STD_LOGIC;


SIGNAL RDADDR_VALID					: STD_LOGIC;
SIGNAL EN_READ_DATA					: STD_LOGIC;
SIGNAL EN_READ_DATA1				: STD_LOGIC;
SIGNAL EN_READ_DATA2				: STD_LOGIC;
SIGNAL EN_READ_DATA3				: STD_LOGIC;


SIGNAL ISAR_INT1					: STD_LOGIC;
SIGNAL ISAR_INT2					: STD_LOGIC;
SIGNAL ISAR_INT3					: STD_LOGIC;

SIGNAL DATA_OUT						: STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL ONE							: STD_LOGIC;

--SIGNAL DIR_RESET					: STD_LOGIC;

SIGNAL ISA_SD_DIR_INT				: STD_LOGIC;
SIGNAL ISA_SD_DIR_OUT				: STD_LOGIC;


BEGIN


	ONE <= '1';		
		 
	BALE_LATCH1: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR => ONE,
					      EN	=> ONE,
					      INP	=> ISA_BALE,
					      OUP	=> BALE_INT1
					     );

	BALE_LATCH2: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR => ONE,
					      EN	=> ONE,
					      INP	=> BALE_INT1,
					      OUP	=> BALE_INT2
					     );	
					
	BALE_LATCH3: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR => ONE,
					      EN	=> ONE,
					      INP	=> BALE_INT2,
					      OUP	=> BALE_INT3
					     );	
						 
----end of triple buffering the isa bale SIGNAL-------						 
						 
					
					
	

	ISA_ADDR_VALID	<= '1' WHEN ISA_SA(19 DOWNTO 16) = x"E" ELSE '0';								
								
	ADDR_EN			<= ISA_ADDR_VALID AND BALE_INT3 AND (NOT BALE_INT2); --detecting the falling edge of bale SIGNAL AND latching the address
	ADDR_VALID		<= '1' WHEN ISA_SA(19 DOWNTO 16) = x"E" ELSE '0';     ----defining the valid address range
								
								
		
		
-----------register for latching the address-------------
						
	ADDR_REG: REGNE GENERIC MAP(N => 20)
					  	 	PORT MAP (CLOCK	 => CLOCK,
									  RESET	 => RESET,
									  CLEAR	 => ONE,
								   	  EN	 => ADDR_EN,
								   	  INPUT  => ISA_SA,
								   	  OUTPUT => ADDR
							         );
									 
	
	ADDR_OUT	<= ADDR;									 
-----------end of register for latching the address-------------
						
-----triple buffering the isa write SIGNAL------------							
	ISAW_LATCH1: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> ISA_MEMW,
					      OUP	=> ISAW_INT1
					     );
					
	ISAW_LATCH2: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> ISAW_INT1,
					      OUP	=> ISAW_INT2
					     );					

	ISAW_LATCH3: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> ISAW_INT2,
					      OUP	=> ISAW_INT3
					     );	
					     





					
--	WRADDR_VALID	<= '1' WHEN (ADDR(19 DOWNTO 8) = x"d00") ELSE '0'; --defining write address range
--	en_write_data	<= ADDR_VALID AND ((NOT ISAW_INT2) AND ISAW_INT3); -- detecting the falling edge of isa write						
	REGS_LD	<= ADDR_VALID AND ((NOT ISAW_INT2) AND ISAW_INT3); -- detecting the falling edge of isa write						

----end of triple buffering the isa write SIGNAL-------

-----triple buffering the isa read SIGNAL------------	
							
	ISAR_LATCH1: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> ISA_MEMR,
					      OUP	=> ISAR_INT1
					     );
					
	ISAR_LATCH2: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> ISAR_INT1,
					      OUP	=> ISAR_INT2
					     );	
					
	ISAR_LATCH3: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> ISAR_INT2,
					      OUP	=> ISAR_INT3
					     );							
					
--	RDADDR_VALID	<= '1' WHEN (ADDR(19 DOWNTO 8) = x"d00") ELSE '0'; --defining read address range
	EN_READ_DATA	<= ADDR_VALID AND ((NOT ISAR_INT2) AND ISAR_INT3); -- detecting the falling edge of isa read
	
----end of triple buffering the isa read SIGNAL-------								
	
-----double buffering internal wite SIGNAL------------		
	
--	en_w_latch1: LATCH_N
--				 PORT MAP(CLOCK	=> CLOCK, 
--					      RESET	=> RESET,
--						  CLEAR	=> ONE,
--					      EN	=> ONE,
--					      INP	=> en_write_data,
--					      OUP	=> en_write_data1
--					     );
--					
--	en_w_latch2: LATCH_N
--				 PORT MAP(CLOCK	=> CLOCK, 
--					      RESET	=> RESET,
--						  CLEAR	=> ONE,
--					      EN	=> ONE,
--					      INP	=> en_write_data1,
--					      OUP	=> en_write_data2
--					     );
						 
--	regs_ld		<= en_write_data2 AND (NOT en_write_data1); --SIGNAL for writing to internal registers
	


----end of double buffering internal write SIGNAL-------
----this is for adding 3 extra CLOCK cycles before grabbing the data to OUTPUT register



	EN_R_LATCH1: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> EN_READ_DATA,
					      OUP	=> EN_READ_DATA1
					     );
					
	EN_R_LATCH2: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> EN_READ_DATA1,
					      OUP	=> EN_READ_DATA2
					     );
					
	EN_R_LATCH3: LATCH_N
				 PORT MAP(CLOCK	=> CLOCK, 
					      RESET	=> RESET,
						  CLEAR	=> ONE,
					      EN	=> ONE,
					      INP	=> EN_READ_DATA2,
					      OUP	=> EN_READ_DATA3
					     );
					     

				

					



--------------register for DATA_OUT after the mux AND before isa bus -------------	

		ISA_OUT_REG: REGNE GENERIC MAP(N => 16)
					  PORT MAP (CLOCK	=> CLOCK,
								RESET	=> RESET,
								CLEAR	=> ONE,
								EN		=> EN_READ_DATA3,
								INPUT	=> regs_d,
								OUTPUT 	=> DATA_OUT
							   );
							

	
--------------end register for DATA_OUT after the mux AND before isa bus -------------

--	isa_dir_latch: LATCH_N
--				 PORT MAP(CLOCK	=> CLOCK, 
--					      RESET	=> RESET,
--						  CLEAR	=> ONE,
--					      EN	=> ONE,
--					      INP	=> NOT ISA_SD_DIR_INT,
--					      OUP	=> ISA_SD_DIR_OUT
--					     );


--	isa_sd_dir <= NOT ISA_SD_DIR_OUT;


--	RESET_LATCH1: LATCH_N
--				 PORT MAP(CLOCK	=> CLOCK, 
--					      RESET	=> RESET,
--						  CLEAR => ONE,
--					      EN	=> ONE,
--					      INP	=> ONE,
--					      OUP	=> DIR_RESET
--					     );




		
	
	ISA_CS16		<= '0';
	

	
	ISA_SD_DIR		<= '1' WHEN  (ISAR_INT3 = '0' AND ADDR_VALID = '1') ELSE '0'; --defining direction of isa bus   							
	
--	isa_sd_dir		<= ADDR_VALID AND ISAR_INT2;
	
--	ISA_SD_DIR_INT	<= '0' WHEN  (ISAR_INT3 = '0' AND ADDR(19 DOWNTO 8) = x"d00") ELSE '1'; --defining direction of isa bus   							
	
	ISA_SD			<= DATA_OUT WHEN (EN_READ_DATA1 = '0' AND EN_READ_DATA2 = '0' AND EN_READ_DATA3 = '0' AND ISAR_INT3 = '0') ELSE (OTHERS => 'Z'); --defining OUTPUT to isa bus
	
	
	
END ARCHITECTURE BEHAVIOR;