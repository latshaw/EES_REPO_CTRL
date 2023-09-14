LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;   
-- added for reading text vectors for tb
use STD.textio.all;
use ieee.std_logic_textio.all;                 

ENTITY Motion_control_vhd_tst IS
END Motion_control_vhd_tst;
ARCHITECTURE Motion_control_arch OF Motion_control_vhd_tst IS
-- constants                                                 
-- signals                                                   
SIGNAL ADC_CS : STD_LOGIC;
SIGNAL ADC_DIN : STD_LOGIC;
SIGNAL ADC_DOUT : STD_LOGIC;
SIGNAL ADC_SCLK : STD_LOGIC;
SIGNAL CLOCK : STD_LOGIC;
SIGNAL CSN1 : STD_LOGIC;
SIGNAL CSN1_1 : STD_LOGIC;
SIGNAL CSN2 : STD_LOGIC;
SIGNAL CSN2_1 : STD_LOGIC;
SIGNAL CSN3 : STD_LOGIC;
SIGNAL CSN3_1 : STD_LOGIC;
SIGNAL CSN4 : STD_LOGIC;
SIGNAL CSN4_1 : STD_LOGIC;
SIGNAL DIR1 : STD_LOGIC;
SIGNAL DIR1_1 : STD_LOGIC;
SIGNAL DIR2 : STD_LOGIC;
SIGNAL DIR2_1 : STD_LOGIC;
SIGNAL DIR3 : STD_LOGIC;
SIGNAL DIR3_1 : STD_LOGIC;
SIGNAL DIR4 : STD_LOGIC;
SIGNAL DIR4_1 : STD_LOGIC;
SIGNAL DIR_CONT1 : STD_LOGIC;
SIGNAL DIR_CONT1_1 : STD_LOGIC;
SIGNAL EN1 : STD_LOGIC;
SIGNAL EN1_1 : STD_LOGIC;
SIGNAL EN2 : STD_LOGIC;
SIGNAL EN2_1 : STD_LOGIC;
SIGNAL EN3 : STD_LOGIC;
SIGNAL EN3_1 : STD_LOGIC;
SIGNAL EN4 : STD_LOGIC;
SIGNAL EN4_1 : STD_LOGIC;
SIGNAL FIBER_1 : STD_LOGIC;
SIGNAL FIBER_2 : STD_LOGIC;
SIGNAL FIBER_3 : STD_LOGIC;
SIGNAL FIBER_4 : STD_LOGIC;
SIGNAL FIBER_5 : STD_LOGIC;
SIGNAL FIBER_6 : STD_LOGIC;
SIGNAL FIBER_7 : STD_LOGIC;
SIGNAL FIBER_8 : STD_LOGIC;
SIGNAL FMC2_SCL : STD_LOGIC;
SIGNAL FMC2_SDA : STD_LOGIC;
SIGNAL GA0 : STD_LOGIC;
SIGNAL GA1 : STD_LOGIC;
SIGNAL HFLF1 : STD_LOGIC;
SIGNAL HFLF1_1 : STD_LOGIC;
SIGNAL HFLF2 : STD_LOGIC;
SIGNAL HFLF2_1 : STD_LOGIC;
SIGNAL HFLF3 : STD_LOGIC;
SIGNAL HFLF3_1 : STD_LOGIC;
SIGNAL HFLF4 : STD_LOGIC;
SIGNAL HFLF4_1 : STD_LOGIC;
SIGNAL LED_SCL : STD_LOGIC;
SIGNAL LED_SDA : STD_LOGIC;
SIGNAL LFLF1 : STD_LOGIC;
SIGNAL LFLF1_1 : STD_LOGIC;
SIGNAL LFLF2 : STD_LOGIC;
SIGNAL LFLF2_1 : STD_LOGIC;
SIGNAL LFLF3 : STD_LOGIC;
SIGNAL LFLF3_1 : STD_LOGIC;
SIGNAL LFLF4 : STD_LOGIC;
SIGNAL LFLF4_1 : STD_LOGIC;
SIGNAL OE_CONT1 : STD_LOGIC;
SIGNAL OE_CONT1_1 : STD_LOGIC;
SIGNAL RESET : STD_LOGIC;
SIGNAL SCLK1 : STD_LOGIC;
SIGNAL SCLK1_1 : STD_LOGIC;
SIGNAL SCLK2 : STD_LOGIC;
SIGNAL SCLK2_1 : STD_LOGIC;
SIGNAL SCLK3 : STD_LOGIC;
SIGNAL SCLK3_1 : STD_LOGIC;
SIGNAL SCLK4 : STD_LOGIC;
SIGNAL SCLK4_1 : STD_LOGIC;
SIGNAL SCLM1 : STD_LOGIC;
SIGNAL SCLM1_1 : STD_LOGIC;
SIGNAL SDA_M1 : STD_LOGIC;
SIGNAL SDA_M1_1 : STD_LOGIC;
SIGNAL SDI1 : STD_LOGIC;
SIGNAL SDI1_1 : STD_LOGIC;
SIGNAL SDI2 : STD_LOGIC;
SIGNAL SDI2_1 : STD_LOGIC;
SIGNAL SDI3 : STD_LOGIC;
SIGNAL SDI3_1 : STD_LOGIC;
SIGNAL SDI4 : STD_LOGIC;
SIGNAL SDI4_1 : STD_LOGIC;
SIGNAL SDO1 : STD_LOGIC;
SIGNAL SDO1_1 : STD_LOGIC;
SIGNAL SDO2 : STD_LOGIC;
SIGNAL SDO2_1 : STD_LOGIC;
SIGNAL SDO3 : STD_LOGIC;
SIGNAL SDO3_1 : STD_LOGIC;
SIGNAL SDO4 : STD_LOGIC;
SIGNAL SDO4_1 : STD_LOGIC;
SIGNAL STEP1 : STD_LOGIC;
SIGNAL STEP1_1 : STD_LOGIC;
SIGNAL STEP2 : STD_LOGIC;
SIGNAL STEP2_1 : STD_LOGIC;
SIGNAL STEP3 : STD_LOGIC;
SIGNAL STEP3_1 : STD_LOGIC;
SIGNAL STEP4 : STD_LOGIC;
SIGNAL STEP4_1 : STD_LOGIC;
SIGNAL addr_tb : STD_LOGIC_VECTOR(23 DOWNTO 0);
SIGNAL din_tb : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL dout_tb : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL gpio_led_1 : STD_LOGIC;
SIGNAL gpio_led_2 : STD_LOGIC;
SIGNAL gpio_led_3 : STD_LOGIC;
SIGNAL hb_fpga : STD_LOGIC;
SIGNAL m10_reset : STD_LOGIC;
SIGNAL rnw_tb : STD_LOGIC;
SIGNAL sfp_refclk_p : STD_LOGIC;
SIGNAL sfp_rx_0_p : STD_LOGIC;
SIGNAL sfp_scl_0 : STD_LOGIC;
SIGNAL sfp_sda_0 : STD_LOGIC;
SIGNAL sfp_tx_0_p : STD_LOGIC;

-- for reading files
 file file_VECTORS : text;

COMPONENT Motion_control
	generic (testBench : STD_LOGIC := '0');
	PORT (
	ADC_CS : OUT STD_LOGIC;
	ADC_DIN : IN STD_LOGIC;
	ADC_DOUT : OUT STD_LOGIC;
	ADC_SCLK : OUT STD_LOGIC;
	CLOCK : IN STD_LOGIC;
	CSN1 : OUT STD_LOGIC;
	CSN1_1 : OUT STD_LOGIC;
	CSN2 : OUT STD_LOGIC;
	CSN2_1 : OUT STD_LOGIC;
	CSN3 : OUT STD_LOGIC;
	CSN3_1 : OUT STD_LOGIC;
	CSN4 : OUT STD_LOGIC;
	CSN4_1 : OUT STD_LOGIC;
	DIR1 : OUT STD_LOGIC;
	DIR1_1 : OUT STD_LOGIC;
	DIR2 : OUT STD_LOGIC;
	DIR2_1 : OUT STD_LOGIC;
	DIR3 : OUT STD_LOGIC;
	DIR3_1 : OUT STD_LOGIC;
	DIR4 : OUT STD_LOGIC;
	DIR4_1 : OUT STD_LOGIC;
	DIR_CONT1 : OUT STD_LOGIC;
	DIR_CONT1_1 : OUT STD_LOGIC;
	EN1 : OUT STD_LOGIC;
	EN1_1 : OUT STD_LOGIC;
	EN2 : OUT STD_LOGIC;
	EN2_1 : OUT STD_LOGIC;
	EN3 : OUT STD_LOGIC;
	EN3_1 : OUT STD_LOGIC;
	EN4 : OUT STD_LOGIC;
	EN4_1 : OUT STD_LOGIC;
	FIBER_1 : IN STD_LOGIC;
	FIBER_2 : IN STD_LOGIC;
	FIBER_3 : IN STD_LOGIC;
	FIBER_4 : IN STD_LOGIC;
	FIBER_5 : IN STD_LOGIC;
	FIBER_6 : IN STD_LOGIC;
	FIBER_7 : IN STD_LOGIC;
	FIBER_8 : IN STD_LOGIC;
	FMC2_SCL : OUT STD_LOGIC;
	FMC2_SDA : INOUT STD_LOGIC;
	GA0 : OUT STD_LOGIC;
	GA1 : OUT STD_LOGIC;
	HFLF1 : IN STD_LOGIC;
	HFLF1_1 : IN STD_LOGIC;
	HFLF2 : IN STD_LOGIC;
	HFLF2_1 : IN STD_LOGIC;
	HFLF3 : IN STD_LOGIC;
	HFLF3_1 : IN STD_LOGIC;
	HFLF4 : IN STD_LOGIC;
	HFLF4_1 : IN STD_LOGIC;
	LED_SCL : OUT STD_LOGIC;
	LED_SDA : INOUT STD_LOGIC;
	LFLF1 : IN STD_LOGIC;
	LFLF1_1 : IN STD_LOGIC;
	LFLF2 : IN STD_LOGIC;
	LFLF2_1 : IN STD_LOGIC;
	LFLF3 : IN STD_LOGIC;
	LFLF3_1 : IN STD_LOGIC;
	LFLF4 : IN STD_LOGIC;
	LFLF4_1 : IN STD_LOGIC;
	OE_CONT1 : OUT STD_LOGIC;
	OE_CONT1_1 : OUT STD_LOGIC;
	RESET : IN STD_LOGIC;
	SCLK1 : OUT STD_LOGIC;
	SCLK1_1 : OUT STD_LOGIC;
	SCLK2 : OUT STD_LOGIC;
	SCLK2_1 : OUT STD_LOGIC;
	SCLK3 : OUT STD_LOGIC;
	SCLK3_1 : OUT STD_LOGIC;
	SCLK4 : OUT STD_LOGIC;
	SCLK4_1 : OUT STD_LOGIC;
	SCLM1 : INOUT STD_LOGIC;
	SCLM1_1 : INOUT STD_LOGIC;
	SDA_M1 : INOUT STD_LOGIC;
	SDA_M1_1 : INOUT STD_LOGIC;
	SDI1 : OUT STD_LOGIC;
	SDI1_1 : OUT STD_LOGIC;
	SDI2 : OUT STD_LOGIC;
	SDI2_1 : OUT STD_LOGIC;
	SDI3 : OUT STD_LOGIC;
	SDI3_1 : OUT STD_LOGIC;
	SDI4 : OUT STD_LOGIC;
	SDI4_1 : OUT STD_LOGIC;
	SDO1 : IN STD_LOGIC;
	SDO1_1 : IN STD_LOGIC;
	SDO2 : IN STD_LOGIC;
	SDO2_1 : IN STD_LOGIC;
	SDO3 : IN STD_LOGIC;
	SDO3_1 : IN STD_LOGIC;
	SDO4 : IN STD_LOGIC;
	SDO4_1 : IN STD_LOGIC;
	STEP1 : OUT STD_LOGIC;
	STEP1_1 : OUT STD_LOGIC;
	STEP2 : OUT STD_LOGIC;
	STEP2_1 : OUT STD_LOGIC;
	STEP3 : OUT STD_LOGIC;
	STEP3_1 : OUT STD_LOGIC;
	STEP4 : OUT STD_LOGIC;
	STEP4_1 : OUT STD_LOGIC;
	addr_tb : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
	din_tb : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
	dout_tb : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
	gpio_led_1 : OUT STD_LOGIC;
	gpio_led_2 : OUT STD_LOGIC;
	gpio_led_3 : OUT STD_LOGIC;
	hb_fpga : OUT STD_LOGIC;
	m10_reset : IN STD_LOGIC;
	rnw_tb : IN STD_LOGIC;
	sfp_refclk_p : IN STD_LOGIC;
	sfp_rx_0_p : IN STD_LOGIC;
	sfp_scl_0 : OUT STD_LOGIC;
	sfp_sda_0 : INOUT STD_LOGIC;
	sfp_tx_0_p : OUT STD_LOGIC
	);
END COMPONENT;
BEGIN
	i1 : Motion_control
	generic map(testBench => '1')
	PORT MAP (
-- list connections between master ports and signals
	ADC_CS => ADC_CS,
	ADC_DIN => ADC_DIN,
	ADC_DOUT => ADC_DOUT,
	ADC_SCLK => ADC_SCLK,
	CLOCK => CLOCK,
	CSN1 => CSN1,
	CSN1_1 => CSN1_1,
	CSN2 => CSN2,
	CSN2_1 => CSN2_1,
	CSN3 => CSN3,
	CSN3_1 => CSN3_1,
	CSN4 => CSN4,
	CSN4_1 => CSN4_1,
	DIR1 => DIR1,
	DIR1_1 => DIR1_1,
	DIR2 => DIR2,
	DIR2_1 => DIR2_1,
	DIR3 => DIR3,
	DIR3_1 => DIR3_1,
	DIR4 => DIR4,
	DIR4_1 => DIR4_1,
	DIR_CONT1 => DIR_CONT1,
	DIR_CONT1_1 => DIR_CONT1_1,
	EN1 => EN1,
	EN1_1 => EN1_1,
	EN2 => EN2,
	EN2_1 => EN2_1,
	EN3 => EN3,
	EN3_1 => EN3_1,
	EN4 => EN4,
	EN4_1 => EN4_1,
	FIBER_1 => FIBER_1,
	FIBER_2 => FIBER_2,
	FIBER_3 => FIBER_3,
	FIBER_4 => FIBER_4,
	FIBER_5 => FIBER_5,
	FIBER_6 => FIBER_6,
	FIBER_7 => FIBER_7,
	FIBER_8 => FIBER_8,
	FMC2_SCL => FMC2_SCL,
	FMC2_SDA => FMC2_SDA,
	GA0 => GA0,
	GA1 => GA1,
	HFLF1 => HFLF1,
	HFLF1_1 => HFLF1_1,
	HFLF2 => HFLF2,
	HFLF2_1 => HFLF2_1,
	HFLF3 => HFLF3,
	HFLF3_1 => HFLF3_1,
	HFLF4 => HFLF4,
	HFLF4_1 => HFLF4_1,
	LED_SCL => LED_SCL,
	LED_SDA => LED_SDA,
	LFLF1 => LFLF1,
	LFLF1_1 => LFLF1_1,
	LFLF2 => LFLF2,
	LFLF2_1 => LFLF2_1,
	LFLF3 => LFLF3,
	LFLF3_1 => LFLF3_1,
	LFLF4 => LFLF4,
	LFLF4_1 => LFLF4_1,
	OE_CONT1 => OE_CONT1,
	OE_CONT1_1 => OE_CONT1_1,
	RESET => RESET,
	SCLK1 => SCLK1,
	SCLK1_1 => SCLK1_1,
	SCLK2 => SCLK2,
	SCLK2_1 => SCLK2_1,
	SCLK3 => SCLK3,
	SCLK3_1 => SCLK3_1,
	SCLK4 => SCLK4,
	SCLK4_1 => SCLK4_1,
	SCLM1 => SCLM1,
	SCLM1_1 => SCLM1_1,
	SDA_M1 => SDA_M1,
	SDA_M1_1 => SDA_M1_1,
	SDI1 => SDI1,
	SDI1_1 => SDI1_1,
	SDI2 => SDI2,
	SDI2_1 => SDI2_1,
	SDI3 => SDI3,
	SDI3_1 => SDI3_1,
	SDI4 => SDI4,
	SDI4_1 => SDI4_1,
	SDO1 => SDO1,
	SDO1_1 => SDO1_1,
	SDO2 => SDO2,
	SDO2_1 => SDO2_1,
	SDO3 => SDO3,
	SDO3_1 => SDO3_1,
	SDO4 => SDO4,
	SDO4_1 => SDO4_1,
	STEP1 => STEP1,
	STEP1_1 => STEP1_1,
	STEP2 => STEP2,
	STEP2_1 => STEP2_1,
	STEP3 => STEP3,
	STEP3_1 => STEP3_1,
	STEP4 => STEP4,
	STEP4_1 => STEP4_1,
	addr_tb => addr_tb,
	din_tb => din_tb,
	dout_tb => dout_tb,
	gpio_led_1 => gpio_led_1,
	gpio_led_2 => gpio_led_2,
	gpio_led_3 => gpio_led_3,
	hb_fpga => hb_fpga,
	m10_reset => m10_reset,
	rnw_tb => rnw_tb,
	sfp_refclk_p => sfp_refclk_p,
	sfp_rx_0_p => sfp_rx_0_p,
	sfp_scl_0 => sfp_scl_0,
	sfp_sda_0 => sfp_sda_0,
	sfp_tx_0_p => sfp_tx_0_p
	);
clk : PROCESS                                                                                 
BEGIN             
	-- 100 MHz clock, 10 ns periods
	CLOCK <= '0'; wait for 5 ns;
	CLOCK <= '1'; wait for 5 ns; 
END PROCESS clk;
                                     
always : PROCESS
	variable I_max   : integer;
	variable v_ILINE : line;   
	variable packet  : STD_LOGIC_VECTOR(123 downto 0);
	variable delay	  : STD_LOGIC_VECTOR(31 downto 0);
	-- structure:  rnw addr data fibers hflf lflf rests delay
	-- bits     :   4   28   32    8     8    8     4    32  
BEGIN
	-- for reading text file
	file_open(file_VECTORS, "input_vectors.txt",  read_mode);
   -- file_open(file_RESULTS, "output_results.txt", write_mode); -- example of writing outputs  
	RESET 	 <='0';
	m10_reset <= '0';
	--
	addr_tb <= x"000000";
	din_tb  <= x"00000000";
	rnw_tb  <= '0';
	--
	HFLF1 	<= '0'; LFLF1	 <= '0'; FIBER_1 <= '0';
	HFLF1_1 	<= '0'; LFLF1_1 <= '0'; FIBER_2 <= '0';
	HFLF2 	<= '0'; LFLF2	 <= '0'; FIBER_3 <= '0';
	HFLF2_1	<= '0'; LFLF2_1 <= '0'; FIBER_4 <= '0';
	HFLF3 	<= '0'; LFLF3	 <= '0'; FIBER_5 <= '0';
	HFLF3_1	<= '0'; LFLF3_1 <= '0'; FIBER_6 <= '0';
	HFLF4 	<= '0'; LFLF4	 <= '0'; FIBER_7 <= '0';
	HFLF4_1	<= '0'; LFLF4_1 <= '0'; FIBER_8 <= '0';
	--
	wait for 100 ns;
	--
	-- continue to loop until every line is read from the file
	while not endfile(file_VECTORS) loop
      readline(file_VECTORS, v_ILINE); -- raw data form file
      read(v_ILINE, packet); -- converted into packet's type, std_logic_vector
		--assign file data
		delay		:= packet(31 downto 0);
		RESET 	<= packet(32);
		m10_reset<= packet(33);
		-- 35, 34 For future use
		 LFLF1	<= packet(36); HFLF1   <= packet(44); FIBER_1 <= packet(52);
		 LFLF2   <= packet(37); HFLF2   <= packet(45); FIBER_2 <= packet(53);
		 LFLF3	<= packet(38); HFLF3   <= packet(46); FIBER_3 <= packet(54);
		 LFLF4   <= packet(39); HFLF4	  <= packet(47); FIBER_4 <= packet(55);
		 LFLF1_1	<= packet(40); HFLF1_1 <= packet(48); FIBER_5 <= packet(56);
		 LFLF2_1 <= packet(41); HFLF2_1 <= packet(49); FIBER_6 <= packet(57);
		 LFLF3_1	<= packet(42); HFLF3_1 <= packet(50); FIBER_7 <= packet(58);
		 LFLF4_1 <= packet(43); HFLF4_1 <= packet(51); FIBER_8 <= packet(59);
		--
		din_tb  <= packet(91 downto 60);
		addr_tb <= packet(115 downto 92);
		-- 119 downto 116
		rnw_tb  <= packet(120);
		--
		-- incorporate programmed delay
		I_max := to_integer(unsigned(delay));
		for I in 0 to I_max loop
			wait for 10 ns;
		end loop;
		--
		-- Proceed to the next loop
		--
	end loop;
--	m10_reset <= '1';
--	RESET <='1';
--	wait for 10 ns;
--	-- init all rw registers to 0
--	for I in 0 to 206 loop
--		rnw_tb  <= '0';
--		addr_tb <= STD_LOGIC_VECTOR(to_unsigned(4*I, addr_tb'length));
--		wait for 20 ns; -- 2 clocks
--	end loop;	
--	rnw_tb  <= '1'; -- now read only
--	wait for 30*1000 ns; -- led ports should be configured and be outputting led data
	
	
	wait for 100 ns;
	file_close(file_VECTORS);
	assert false report "End Sim " severity failure;
	
END PROCESS always;    
                                      
END Motion_control_arch;
