-- Temp Sensor, ADT7410
-- LLRF 3.0, module for ADT temperature control (each module controls 4 temp sensors over I2C bus)
--
-- Latshaw, 11/17/2020
--
-- This module communicates over an I2C bus with a 4 temp sensors and averages their temp
-- Wire up clock with 100 MHz (or slower) and with an active low reset
-- 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY ADT_CONTROL IS
	generic (testBench : STD_LOGIC := '0'); 
	PORT
	(	
		clock      : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n    : IN  	STD_LOGIC; -- active low reset
		TEMP_DATA  : OUT  STD_LOGIC_VECTOR(15 downto 0); -- upper LED on front panel
		OE_CONT1   : OUT  STD_LOGIC;
		DIR_CONT1  : OUT  STD_LOGIC;
		SCL 		  : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
		SDA 		  : INOUT STD_LOGIC -- data line (data is bi directional), LED_SDA
	);
END ADT_CONTROL;

ARCHITECTURE rtl OF ADT_CONTROL IS 
	-- components here
	component gen_i2c IS
	generic (testBench : STD_LOGIC := '0');
	PORT
	(	
		clock     : IN  	STD_LOGIC; -- input clock (assumed 100 MHz)
		reset_n   : IN  	STD_LOGIC; -- active low reset
		EN			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
		ADDR 	 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address
		RW			 : IN  	STD_LOGIC; -- read/write, read = HI, writes = LOW
		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); -- input data, lsByte sent first
		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0); -- read data (leave OPEN if not used)
		P_width 	 : IN  	STD_LOGIC_VECTOR(1 downto 0); --Choose how many bytes to transmit
		S_ACK		 : OUT 	STD_LOGIC; -- Status for ack, HI= ack recieved, LO = no ack
		SCL 		 : OUT 	STD_LOGIC; -- output clock (should be < 400 KHz)
		SDA 		 : INOUT STD_LOGIC;  -- data line (data is bi directional)
		rdy       : OUT   STD_LOGIC;
		dir		 : OUT   STD_LOGIC
	);
	END component;
	
	-- signals here
	signal count_FULL, count_Half : STD_LOGIC_VECTOR(31 downto 0);
	signal DATA_send, DATA_get : STD_LOGIC_VECTOR(23 downto 0);
	signal adt_addr : STD_LOGIC_VECTOR(6 downto 0);
	signal adt_EN, adt_rdy, adt_dir, adt_RW, adt_oe : STD_LOGIC;
	signal adt_bytes : STD_LOGIC_VECTOR(1 downto 0);
	signal state : STD_LOGIC_VECTOR(3 downto 0);
	signal temp_1, temp_2, temp_3, temp_4 :  STD_LOGIC_VECTOR(15 downto 0);
	--
BEGIN
	--
	--===================================================
	--		Couter Generates (shorter if in test bench mode)
	--===================================================

	--
	gen_counter_tb1 : if testBench = '1' generate
		-- use smaller counters to speed up test bench
		count_FULL	<= x"00000140";
		count_Half	<= x"000000A0";
	end generate gen_counter_tb1;
	--
	gen_counter_normal1 : if testBench = '0' generate
		-- real count values to support I2C
		count_FULL	<= x"0098967F";
		count_Half	<= x"004C4B40";
	end generate gen_counter_normal1;
	--
	--===================================================
	--		16 LED expansion (I2C)
	--===================================================
	--
	-- i2c module, handles 4 temperature sensors
	ADT00_i2c : gen_i2c
	 generic map (testBench=>testBench)
	 PORT MAP	(	
		clock   => clock,
		reset_n => reset_n,
		EN		  => adt_EN,
		ADDR 	  => adt_addr, -- lower 2 bits change to address different temp sensors
		RW		  => adt_RW, -- 0 for writes, 1 for reads
		DATA	  => DATA_send,
		DATA_R  => DATA_get,
		P_width => adt_bytes, -- bytes to send or get (not counting address)
		S_ACK	  => open,
		SCL 	  => SCL,
		SDA 	  => SDA,
		rdy     => adt_rdy,
		dir     => adt_dir
	);
	
	--
	--===================================================
	--		Main Process
	--===================================================
 
	process (clock, reset_n)
		variable counter  : STD_LOGIC_VECTOR(31 downto 0);
		variable addr_cnt, stal : STD_LOGIC_VECTOR(1 downto 0);
		variable rdy_pos_edge, rdy_neg_edge, last_bit: STD_LOGIC;
	begin
		if (reset_n = '0') then
			counter  := x"00000000";
			adt_addr <= "1001000";
			addr_cnt := "00";
			state <= x"0";
			
		elsif clock'event and clock = '1' then
			-- detect a ready pulse
			rdy_pos_edge := adt_rdy and NOT(last_bit);
			rdy_neg_edge := NOT(adt_rdy) and last_bit;
			last_bit  := adt_rdy;
			--
			case state is
				when x"1"   => -- CONFIGURE ADDRESS
					state 	<= x"2";
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"2"   => -- INIT EN, WAIT FOR RDY TO GO LOW
					if adt_rdy = '0' then state <= x"3"; else state <= x"2"; end if;
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"3"   => -- WAIT FOR RDY TO GO HI
					if adt_rdy = '1' then state <= x"4"; else state <= x"3"; end if;
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"4"   => -- CONFIGURE NEXT ADDRESS (1) OR GO TO MEASURE TEMP (5)
					if addr_cnt = "11" then 
						addr_cnt:= "00";
						state 	<= x"5";	
					else 
						addr_cnt := addr_cnt + 1; 
						state 	<= x"1";
					end if;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"5"   => -- CONFIGURE ADDRESS AND POINTER
					state 	<= x"6";
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"6"   => -- INIT EN, WAIT FOR RDY TO GO LOW
					if adt_rdy = '0' then state <= x"7"; else state <= x"6"; end if;
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"7"   => -- WAIT FOR RDY TO GO HI
					if adt_rdy = '1' then state <= x"8"; else state <= x"7"; end if;
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"8"   => -- CONFIGURE ADDRESS AND PREPARE TO READ DATA
					state 	<= x"9";
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"9"   => -- INIT EN, WAIT FOR RDY TO GO LOW
					if adt_rdy = '0' then state <= x"a"; else state <= x"9"; end if;
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"a"   => -- WAIT FOR RDY TO GO HI
					if adt_rdy = '1' then state <= x"b"; else state <= x"a"; end if;
					addr_cnt := addr_cnt;
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when x"b"   => -- UPDATE ADDRESS (5) OR GO TO AVERAGING MODE (c)
					if stal = "11" then
						if addr_cnt = "11" then 
							addr_cnt:= "00";
							state 	<= x"c";	
						else 
							addr_cnt := addr_cnt + 1; 
							state 	<= x"5";
						end if;
						stal := "00";
					else
						stal := stal + 1;
						addr_cnt := addr_cnt;
						state 	<= x"b";
					end if;
					adt_addr <= "10010" & addr_cnt;
				when x"c"   => -- AVERAGE TEMPERATURE
					if stal = "11" then
						state 	<= x"d";
						addr_cnt := "00";
						adt_addr <= "10010" & addr_cnt;
						stal := "00";
					else
						state 	<= x"c";
						addr_cnt := "00";
						adt_addr <= "10010" & addr_cnt;
						stal := stal + 1;
					end if;
				when x"d"   => -- REPORT TEMPERATURE, DELAY THEN (5)
					if counter >= x"05F5E10" then -- delay 1 second
						state 	<= x"5";
					else
						state 	<= x"d";
					end if;
					addr_cnt := "00";
					adt_addr <= "10010" & addr_cnt;
					stal := "00";
				when others => -- START
					state 	<= x"1";
					addr_cnt := "00";
					adt_addr <= "1001000";
					stal := "00";
			end case;
			--
			if state = x"5" then
				counter := x"00000000"; -- reset counter
			else
				counter := counter + 1; -- always increment
			end if;
			--
		end if;
	end process;
	--
	-- Continuous Assignments
	--
	-- use to intiate I2C packet
	adt_EN <= '1' when (state = x"2" OR state = x"6" OR state = x"9" ) else '0';
	-- place sda line in HI Z (in case you don't want to see ack from sensots)
	adt_OE <= '0'; 
	-- rnw
	adt_RW <= '0' when (state < x"8") else '1';
	-- configure register packet or just pointer
	DATA_send <= x"03C000" when (state <= x"4") else x"000000";
	-- how many i2c bytes to send/receive at a time
	-- will always be 2 bytes when we configure or read temps but 1 byte when we set the pointer to read temps
	adt_bytes <= "00" when (state >=x"5" and state <=x"7") else "01";
	--
	-- set OE HI to place TI buffer in HI Z (toward sensor), low to allow data to pass
	OE_CONT1 <= adt_OE;
	-- set DIR_CONT HI to send data (writes) to sensor and LOW to get data (reads)
	DIR_CONT1 <= adt_dir;
	--

	-- process for averaging
	process (clock, reset_n)
		variable temp_accum  : STD_LOGIC_VECTOR(15 downto 0);
		variable average : STD_LOGIC_VECTOR(15 downto 0);
		variable tick : STD_LOGIC_VECTOR(2 downto 0);
		variable fresh, fresh2 : STD_LOGIC; -- 1 whenever for the first clock coming into state b
	begin
		if (reset_n = '0') then
			temp_accum  := x"0000";
			average  := x"0000";
			tick := "000";
			temp_1 <= x"0000";
			temp_2 <= x"0000";
			temp_3 <= x"0000";
			temp_4 <= x"0000";
			fresh  := '1';
			fresh2 := '1';
			TEMP_DATA <= x"0000";
		elsif clock'event and clock = '1' then
			
			if     state = x"b" then -- add temperature to temp_accum
				-- we will be in state b for multiple clock cycles
				-- we only want to grab the temperature data once
				if fresh = '1' then
					temp_accum := DATA_get(15 downto 0);

					if    tick = "000" then temp_1 <= temp_accum; temp_2 <= temp_2; temp_3 <= temp_3; temp_4 <= temp_4; tick := "001";
					elsif tick = "001" then	temp_1 <= temp_1; temp_2 <= temp_accum; temp_3 <= temp_3; temp_4 <= temp_4; tick := "010";
					elsif tick = "010" then	temp_1 <= temp_1; temp_2 <= temp_2; temp_3 <= temp_accum; temp_4 <= temp_4; tick := "001";
					else							temp_1 <= temp_1; temp_2 <= temp_2; temp_3 <= temp_3; temp_4 <= temp_accum; tick := "011";
					end if;
					
				end if;
				-- do nothing until we leave this state
				fresh  := '0'; -- keep low until we leave this state
				fresh2 := '1';
								
			elsif  state = x"c" then -- average temperatures
				if fresh2 = '1' then
					average := temp_1;
					average := average + temp_2;
					average := average + temp_3;
					average := average + temp_4;
					tick := "000";
					average := "00" & average(15 downto 2);
				end if;
				fresh2 := '0';
				fresh  := '1';
			elsif  state = x"a" then -- use to reset fresh and fresh2
				fresh  := '1'; -- keep low until we leave this state
				fresh2 := '1';
			elsif  state = x"d" then -- reset temp_accum 
				temp_accum := x"0000";
				tick   := "000";
				fresh  := '1';
				fresh2 := '1';
			end if;
		end if;
		
		-- cont assignment
		 TEMP_DATA <= average;
	end process;

--
END rtl;