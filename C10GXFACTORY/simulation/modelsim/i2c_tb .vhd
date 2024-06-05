LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;   
-- added for reading text vectors for tb
--use STD.textio.all;
--use ieee.std_logic_textio.all;                 

ENTITY i2c_vhd_tst IS
END i2c_vhd_tst;
ARCHITECTURE i2c_arch OF i2c_vhd_tst IS


signal clock   :  STD_LOGIC;
signal reset_n :  STD_LOGIC;
signal EN		:  STD_LOGIC;   
signal ADDR 	:  STD_LOGIC_VECTOR(6 downto 0);   
signal RW		:  STD_LOGIC;   
signal DATA	   :  STD_LOGIC_VECTOR(23 downto 0);
signal DATA_R, data_to_send  :  STD_LOGIC_VECTOR(23 downto 0);
signal P_width :  STD_LOGIC_VECTOR(1 downto 0);
signal S_ACK	:  STD_LOGIC;   
signal SCL 	   :  STD_LOGIC;
signal SDA 	   :  STD_LOGIC;
-- only for test bench
signal sda_OE  :  STD_LOGIC; -- mimic tri state behavior
signal observed_data, display_data : STD_LOGIC_VECTOR(7 downto 0); -- data received at sensor (per bye)
                                               

COMPONENT gen_i2c
	generic (testBench : STD_LOGIC := '0');
	PORT (
		clock     : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n   : IN  	STD_LOGIC; -- active low reset
		EN			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
		ADDR 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address
		RW			 : IN  	STD_LOGIC; -- read/write, read = HI, writes = LOW
		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); -- input data, msByte sent first
		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0); -- read data (leave OPEN if not used)
		P_width 	 : IN  	STD_LOGIC_VECTOR(1 downto 0); --Choose how many bytes to transmit (00 1 data byet, 01 2 data bytes, 10 or 11 3 data bytes)
		S_ACK		 : OUT 	STD_LOGIC; -- Status for ack, HI= ack recieved, LO = no ack
		SCL 		 : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz)
		SDA 		 : INOUT STD_LOGIC  -- data line (data is bi directional)
	);
END COMPONENT;
BEGIN
	i1 : gen_i2c
	generic map(testBench => '1')
	PORT MAP (
-- list connections between master ports and signals
	clock   =>  clock,   
	reset_n =>  reset_n, 
	EN		  =>  EN,		  
	ADDR 	  =>  ADDR, 	  
	RW		  =>  RW,		  
	DATA	  =>  DATA,	  
	DATA_R  =>	DATA_R,  
	P_width =>	P_width, 
	S_ACK	  =>  S_ACK,	  
	SCL 	  =>  SCL, 	  
	SDA 	  =>  SDA 	  
	);
	
	
clk : PROCESS                                                                                 
BEGIN             
	-- 100 MHz clock, 10 ns periods
	CLOCK <= '0'; wait for 5 ns;
	CLOCK <= '1'; wait for 5 ns; 
END PROCESS clk;
                    

	SDA <= data_to_send(23) when sda_OE = '1' else 'Z'; -- ack bits are low
						  
always : PROCESS

BEGIN
	reset_n <= '0';
	ADDR  <= "1001011"; -- references a specific i2c chip
	P_width <= "00";
	RW <= '0'; -- write mode
	EN <= '0';
	DATA <= x"A55A1E";
	data_to_send <= x"A55A1E"; -- to send from sensor to module during read mode, msb must be 1 for write mode
	observed_data <= x"00"; -- data that sensor sees
	display_data <= x"00"; -- make the observed data easier to display for simulation
	sda_OE <= '1';
	wait for 100 ns;
	reset_n <= '1';
	
	
	--===================================================================
	-- Test Writes (1 byte)
	--===================================================================
	P_width <= "00";
	RW <= '0'; -- write mode
	wait for 100 ns;
	EN <= '1'; -- go signal
		
		for J in 0 to 1 loop -- size of P_width
			observed_data <= x"00"; -- reset sensor data
			for I in 0 to 7 loop
				sda_OE <= '0'; -- keep hi Z (from temp sensor's perspective)
				wait until SCL = '1'; 
				observed_data <= observed_data(6 downto 0) & SDA;
			end loop;
			wait until SCL = '0';
			wait for 34 ns;
			sda_OE <= '1'; -- provide the ack
			display_data <= observed_data; -- to make simulation easier to read
			wait until SCL = '1';
			wait for 10 ns;	
		end loop;
		--
		sda_OE <= '0'; -- for idle condition
		EN <= '0'; -- pull go signal low to setup for next test
		-- done with this test
	wait for 500 ns;
	
	--===================================================================
	-- Test Writes (2 bytes)
	--===================================================================
	P_width <= "01";
	RW <= '0'; -- write mode
	wait for 100 ns;
	EN <= '1'; -- go signal
		
		for J in 0 to 2 loop -- size of P_width
			observed_data <= x"00"; -- reset sensor data
			for I in 0 to 7 loop
				sda_OE <= '0'; -- keep hi Z (from temp sensor's perspective)
				wait until SCL = '1'; 
				observed_data <= observed_data(6 downto 0) & SDA;
			end loop;
			wait until SCL = '0';
			wait for 34 ns;
			sda_OE <= '1'; -- provide the ack
			display_data <= observed_data; -- to make simulation easier to read
			wait until SCL = '1';
			wait for 10 ns;	
		end loop;
		--
		sda_OE <= '0'; -- for idle condition
		EN <= '0'; -- pull go signal low to setup for next test
		-- done with this test
	wait for 500 ns;
	
	--===================================================================
	-- Test Writes (3 bytes)
	--===================================================================
	P_width <= "10"; -- or 11
	RW <= '0'; -- write mode
	wait for 100 ns;
	EN <= '1'; -- go signal
		
		for J in 0 to 3 loop -- size of P_width
			observed_data <= x"00"; -- reset sensor data
			for I in 0 to 7 loop
				sda_OE <= '0'; -- keep hi Z (from temp sensor's perspective)
				wait until SCL = '1'; 
				observed_data <= observed_data(6 downto 0) & SDA;
			end loop;
			wait until SCL = '0';
			wait for 34 ns;
			sda_OE <= '1'; -- provide the ack
			display_data <= observed_data; -- to make simulation easier to read
			wait until SCL = '1';
			wait for 10 ns;	
		end loop;
	--
	sda_OE <= '0'; -- for idle condition
	EN <= '0'; -- pull go signal low to setup for next test
	-- done with this test
	wait for 500 ns;
	
	--===================================================================
	-- Test Reads (1 byte)
	--===================================================================
	data_to_send <= x"A55A1E"; -- refresh signal
	P_width <= "00";
	RW <= '1'; -- read mode
	wait for 100 ns;
	EN <= '1'; -- go signal
	-- address data to sensor
	observed_data <= x"00"; -- reset sensor data
	for I in 0 to 7 loop
		sda_OE <= '0'; --  keep hi Z (from temp sensor's perspective)
		wait until SCL = '1'; 
		observed_data <= observed_data(6 downto 0) & SDA;
	end loop;
	wait until SCL = '0';
	wait for 34 ns;
	sda_OE <= '1'; -- provide the ack
	display_data <= observed_data; -- to make simulation easier to read
	wait until SCL = '1';
	wait for 10 ns;
	-- 
	-- now in reading mode, want to send data over buss
		for J in 0 to 0 loop -- size of P_width -1
			observed_data <= x"00"; -- reset sensor data
			for I in 0 to 7 loop
				sda_OE <= '1'; --  send msb of data_to_send
				wait until SCL = '1'; 
				observed_data <= observed_data(6 downto 0) & SDA;
				wait for 10 ns;
				data_to_send <= data_to_send(22 downto 0) & '0'; -- shift register
			end loop;
			wait until SCL = '0';
			wait for 34 ns;
			sda_OE <= '1'; -- provide the ack (might not work base on how i defiend the tri-state buffer)
			display_data <= observed_data; -- to make simulation easier to read
			wait until SCL = '1';
			wait for 10 ns;	
		end loop;
		--
		sda_OE <= '0'; -- for idle condition
		EN <= '0'; -- pull go signal low to setup for next test
		-- done with this test
	wait for 500 ns;
	
	--===================================================================
	-- Test Reads (2 bytes)
	--===================================================================
	data_to_send <= x"A55A1E"; -- refresh signal
	P_width <= "01";
	RW <= '1'; -- read mode
	wait for 100 ns;
	EN <= '1'; -- go signal
	-- address data to sensor
	observed_data <= x"00"; -- reset sensor data
	for I in 0 to 7 loop
		sda_OE <= '0'; --  keep hi Z (from temp sensor's perspective)
		wait until SCL = '1'; 
		observed_data <= observed_data(6 downto 0) & SDA;
	end loop;
	wait until SCL = '0';
	wait for 34 ns;
	sda_OE <= '1'; -- provide the ack
	display_data <= observed_data; -- to make simulation easier to read
	wait until SCL = '1';
	wait for 10 ns;
	-- 
	-- now in reading mode, want to send data over buss
		for J in 0 to 1 loop -- size of P_width -1
			observed_data <= x"00"; -- reset sensor data
			for I in 0 to 7 loop
				sda_OE <= '1'; --  send msb of data_to_send
				wait until SCL = '1'; 
				observed_data <= observed_data(6 downto 0) & SDA;
				wait for 10 ns;
				data_to_send <= data_to_send(22 downto 0) & '0'; -- shift register
			end loop;
			wait until SCL = '0';
			wait for 34 ns;
			sda_OE <= '1'; -- provide the ack (might not work base on how i defiend the tri-state buffer)
			display_data <= observed_data; -- to make simulation easier to read
			wait until SCL = '1';
			wait for 10 ns;	
		end loop;
		--
		sda_OE <= '0'; -- for idle condition
		EN <= '0'; -- pull go signal low to setup for next test
		-- done with this test
	wait for 500 ns;
	
	--===================================================================
	-- Test Reads (3 bytes)
	--===================================================================
	data_to_send <= x"A55A1E"; -- refresh signal
	P_width <= "10"; -- or 11
	RW <= '1'; -- read mode
	wait for 100 ns;
	EN <= '1'; -- go signal
	-- address data to sensor
	observed_data <= x"00"; -- reset sensor data
	for I in 0 to 7 loop
		sda_OE <= '0'; --  keep hi Z (from temp sensor's perspective)
		wait until SCL = '1'; 
		observed_data <= observed_data(6 downto 0) & SDA;
	end loop;
	wait until SCL = '0';
	wait for 34 ns;
	sda_OE <= '1'; -- provide the ack
	display_data <= observed_data; -- to make simulation easier to read
	wait until SCL = '1';
	wait for 10 ns;
	-- 
	-- now in reading mode, want to send data over buss
		for J in 0 to 2 loop -- size of P_width -1
			observed_data <= x"00"; -- reset sensor data
			for I in 0 to 7 loop
				sda_OE <= '1'; --  send msb of data_to_send
				wait until SCL = '1'; 
				observed_data <= observed_data(6 downto 0) & SDA;
				wait for 10 ns;
				data_to_send <= data_to_send(22 downto 0) & '0'; -- shift register
			end loop;
			wait until SCL = '0';
			wait for 34 ns;
			sda_OE <= '1'; -- provide the ack (might not work base on how i defiend the tri-state buffer)
			display_data <= observed_data; -- to make simulation easier to read
			wait until SCL = '1';
			wait for 10 ns;	
		end loop;
		--
		sda_OE <= '0'; -- for idle condition
		EN <= '0'; -- pull go signal low to setup for next test
		-- done with this test
	wait for 500 ns;
	
	
	assert false report "End Sim " severity failure;
	
END PROCESS always;    
                                      
END i2c_arch;
