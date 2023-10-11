-- EEPROM_CONTROL 12/20/2021
-- JAL
-- Goal of this module to access the EEPROM chip AT24C32D chip.
-- This module will be generic in that it will be able to wrie to any address on the 32k bit EEPROM
-- however the intent is for storing MAC/IP/non volitile information which we want to be
-- available post power cycle.
--
-- 1/5/22, working. maybe add a hash check feature?
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY EEPROM_CONTROL IS
	PORT
	(	
		clock      		: IN		STD_LOGIC; -- input clock (assumed 125 MHz)
		reset_n    		: IN		STD_LOGIC; -- active low reset
		EEPROM_RNW		: IN 		STD_LOGIC; -- Read Not Write for eeprom address
		EEPROM_go		: IN		STD_LOGIC; -- go, or begin process
		EEPROM_STAT	 	: OUT 	STD_LOGIC_VECTOR(2 downto 0); -- idc_ack & EEPROM_DIR & i2c_rdy
		EEPROM_ADDR		: IN 		STD_LOGIC_VECTOR(11 downto 0); -- address of EEPROM, max is 32k bit (we read 1 byte at each address)
		EEPROM_DATA		: IN 		STD_LOGIC_VECTOR(7 downto 0); -- Data to write to EEPROM
		EEPROM_DATAR	: OUT 	STD_LOGIC_VECTOR(7 downto 0); -- Data read from EEPROM
		EEPROM_SCL 		: OUT 	STD_LOGIC; -- output clock (should be < 400 KHz), LED_SCL
		EEPROM_SDA 		: INOUT 	STD_LOGIC -- data line (data is bi directional), LED_SDA
	);
END EEPROM_CONTROL;

ARCHITECTURE rtl OF EEPROM_CONTROL IS 
	-- components here
	component i2c IS
	generic (testBench : STD_LOGIC := '0');
	PORT
		(
		clock     : IN  	STD_LOGIC; -- input clock
		reset_n   : IN  	STD_LOGIC; -- active low reset
		GO			 : IN 	STD_LOGIC; -- pulse the enable hi to start I2C bus
		ADDR 	 	 : IN  	STD_LOGIC_VECTOR(6 downto 0); -- 7 bit address, typically hardwired
		RNW		 : IN  	STD_LOGIC;
		DATA		 : IN  	STD_LOGIC_VECTOR(23 downto 0); 
		DATA_R	 : OUT 	STD_LOGIC_VECTOR(23 downto 0);
	   DONE		 : OUT	STD_LOGIC;
		SCL 		 : OUT 	STD_LOGIC; 
		SDA 		 : INOUT STD_LOGIC 
	);
	END component;
	
	-- signals here
	signal I2C_DATA : STD_LOGIC_VECTOR(23 downto 0);
	signal I2C_ADDR : STD_LOGIC_VECTOR(6 downto 0);
	signal EEPROM_EN, EEPROM_DIR, go_pulse, i2c_rdy, idc_ack : STD_LOGIC;
	signal i2c_read_data, oe_list : STD_LOGIC_VECTOR(23 downto 0);
	signal state : STD_LOGIC_VECTOR(3 downto 0);
	--
BEGIN
	--
	--===================================================
	--		16 LED expansion (I2C)
	--===================================================
	--
	 EEPROM_i2c : i2c
	 generic map (testBench=>'0')
	 PORT MAP	(	
		clock   => clock,
		reset_n => reset_n,
		GO		  => EEPROM_EN,
		ADDR 	  => I2C_ADDR,
		RNW	  => EEPROM_RNW,
		DATA	  => I2C_DATA,
		DATA_R  => i2c_read_data,
		SCL 	  => EEPROM_SCL,
		SDA 	  => EEPROM_SDA,
		DONE    => i2c_rdy
	);
	--
	--
	-- based on hard wired resistors
	I2C_ADDR <= "1010011"; -- c1842, c1763
	--oe_list <= x"0000ff";
	--
	--===================================================
	--		Main Process
	--===================================================
	-- Reset: power cycling seems to be the only reliable way to reset the AT24C32D
	--
	-- Reads: Supply the address of the byte that you wish to read and read that byte only
	--
	-- Writes: supply the address of the byte that you want to write and write to that byte only
	-- 
	--	Notes:
	-- I2C packet : component_address + rnw + memory_address_upper + memory_address_lower + Data_Byte
	-- component_address = "1010011" because of hard wired pull up/downs
	--
	-- because of eeprom size is 32 k bits (so we don't need 16 bits of address
	-- we only need 12 bits, memory_address_upper = "0000xxxx", 
	--

		process (clock, reset_n)
			--variable counter     : STD_LOGIC_VECTOR(31 downto 0)  := x"00000000";
		begin
			if (reset_n = '0') then
				--
				--counter		:= (others => '0');
				EEPROM_EN <= '0';
				I2C_DATA <= (others => '0');
				--
			elsif clock'event and clock = '1' then
				--
				CASE state is
					when x"0"   => -- IDLE: stay in this state until we see a go pulse
						IF go_pulse = '1' THEN
							state <= x"1";-- go to next state
						ELSE
							state <= x"0"; -- else, stay in this state
						END IF;
						EEPROM_EN <= '0';
					when x"1"   => -- Build data Packet: 
						--
						I2C_DATA <= x"0" & EEPROM_ADDR & EEPROM_DATA;
						state <= x"2";
						EEPROM_EN <= '0';
						--
					when x"2"   => -- CHECK IF BUS IS READY
						IF i2c_rdy = '1' THEN
							state <= x"3";
							EEPROM_EN <= '1'; -- begin enable pulse
						ELSE
							state <= x"2";
							EEPROM_EN <= '0'; -- keep enable pulse low
						END IF;
					when x"3"   => -- SEND PACKET
						-- make sure ready goes low indicating that the the I2C module has detected the go pulse
						IF i2c_rdy = '0' THEN
							state <= x"4"; -- only go to the next state if the go pulse has been recieved
						ELSE
							state <= x"3";
						END IF;
						--
						EEPROM_EN <= '1';
						--
					when x"4"   => -- WAIT UNTIL READY AGAIN
						--
						EEPROM_EN <= '0';
						--
						IF i2c_rdy = '1' THEN
							state <= x"5";
						ELSE
							state <= x"4";
						END IF;
					when x"5"   => -- Prep Data
						state <= x"6";
						EEPROM_EN <= '0';
					when others =>  -- DONE
						state <= x"0"; -- go to IDLE
						EEPROM_EN <= '0';
					end CASE;
				--
			end if; -- end reset catch
		end process;
		--
		--EEPROM_STAT  <= idc_ack & EEPROM_DIR & i2c_rdy;
		EEPROM_STAT  <= "00" & i2c_rdy;
		EEPROM_DATAR <= i2c_read_data(7 downto 0);
		--===================================================
		-- Process to catch rising edge of EEPROM_go
		--===================================================
		-- catch rising edge of EEPROM_go (module input
		-- and have a 1 clock pulse on go_pulse.
		process (clock, reset_n)
			variable EEPROM_go_last : STD_LOGIC := '0';
		begin
			if (reset_n = '0') then
				EEPROM_go_last := EEPROM_go;
				go_pulse <= '0';
			elsif clock'event and clock = '1' then
				go_pulse <= NOT(EEPROM_go_last) AND EEPROM_go;
				EEPROM_go_last := EEPROM_go;
			end if; -- end reset catch
		end process;
		--
		-- 
		--  
--
END rtl;










