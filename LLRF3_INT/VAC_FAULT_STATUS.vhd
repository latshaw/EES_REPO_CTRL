-- debounce added by JAL 12/15/2020
-- updated for 125 Mhz local clock (note, vales kept the same, but period changed because faster clokc), 3/31/21

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL; -- needed for counter
USE WORK.COMPONENTS.ALL;

ENTITY VAC_FAULT_STATUS IS
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 VAC_BMLN_FPGA : IN STD_LOGIC; -- fault input, HI=fault
		 VAC_WAVGD_FPGA : IN STD_LOGIC_VECTOR(7 DOWNTO 0); -- fault input, HI=fault
		 MASK_VAC_FAULT : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
		 VAC_FAULT_CLEAR : IN STD_LOGIC_VECTOR(8 DOWNTO 0); -- set hi to mask fault
		 VAC_FAULT : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);--[8] BL VAC FAULT, [7..0] WG VAC FAULT, latched value
		 VAC_STATUS : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)--[8] BL VAC STATUS, [7..0] WG VAC STATUS, unlatched current value
		 );
END ENTITY VAC_FAULT_STATUS; 

ARCHITECTURE BEHAVIOR OF VAC_FAULT_STATUS IS

SIGNAL EN_VAC_FAULT		: STD_LOGIC_VECTOR(8 DOWNTO 0);
SIGNAL INP_VAC_FAULT		: STD_LOGIC_VECTOR(8 DOWNTO 0);
-- added 12/15/2020, JAL
SIGNAL debounce_FAULT : STD_LOGIC_VECTOR(8 DOWNTO 0);


SIGNAL ONE					: STD_LOGIC;


BEGIN

ONE <= '1';

--wave guide fault detection

GEN_VAC_FAULT: FOR I IN 0 TO 7 GENERATE

	EN_VAC_FAULT(I) <= (VAC_WAVGD_FPGA(I) AND (NOT MASK_VAC_FAULT(I))) AND debounce_FAULT(I);

	VAC_STATUS(I) <=  VAC_WAVGD_FPGA(I);
	
	VAC_WG_FAULT_LATCHI: LATCH_N
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 CLEAR	=> NOT VAC_FAULT_CLEAR(I),
			 EN		=> EN_VAC_FAULT(I),
			 INP		=> ONE,
			 OUP		=> VAC_FAULT(I)
			);	
	
END GENERATE;

-- beamlime fault detection

	VAC_BL_FAULT_LATCHI: LATCH_N
	PORT MAP(CLOCK	=> CLOCK,
			 RESET	=> RESET,
			 CLEAR	=> NOT VAC_FAULT_CLEAR(8),
			 EN		=> EN_VAC_FAULT(8),
			 INP		=> ONE,
			 OUP		=> VAC_FAULT(8)
			);
			
	EN_VAC_FAULT(8) <=  (VAC_BMLN_FPGA AND (NOT MASK_VAC_FAULT(8))) AND debounce_FAULT(8);
	VAC_STATUS(8) 	<= VAC_BMLN_FPGA;	

-- debounce process IF 100 MHZ
-- 1000 ticks at 100 MHz is 10 micro second debounc (10 u sec)
-- 1000 = 0x03e7

-- debounce process IF 125 MHZ, 3/31/21
-- 1000 ticks at 125 MHz is 8 micro second debounc (8 u sec)
-- 1000 = 0x03e7
	GEN_VAC_debounce: FOR I IN 0 TO 7 GENERATE
		--
		process(CLOCK, RESET)
			variable counter : STD_LOGIC_VECTOR(15 downto 0);
		begin
			if (RESET = '0') then
				counter := x"0000";
			elsif clock'event and clock = '1' then
				-- simple debounce, check to ensure the fault has lasted for at least 10 u sec
				IF (VAC_WAVGD_FPGA(I)='1' AND MASK_VAC_FAULT(I)='0') and (counter >= x"03e7") THEN
					-- fault has existed for desired time, allow faul to be latched
					debounce_FAULT(I) <= '1';
					counter := x"FFFF";
				ELSE
					-- fault has not existed for desired amount of time, do not allow fault to be latched
					debounce_FAULT(I) <= '0';
					counter := counter + 1;
				END IF;
			end if;
		end process;
		--
	END GENERATE;

	-- same as above except for the beamline fault
	process(CLOCK, RESET)
		variable counter : STD_LOGIC_VECTOR(15 downto 0);
	begin
		if (RESET = '0') then
			counter := x"0000";
		elsif clock'event and clock = '1' then
			-- simple debounce, check to ensure the fault has lasted for at least 10 u sec
			IF (VAC_BMLN_FPGA='1' AND MASK_VAC_FAULT(8)='0') and (counter >= x"03e7") THEN
				-- fault has existed for desired time, allow faul to be latched
				debounce_FAULT(8) <= '1';
				counter := x"FFFF";
			ELSE
				-- fault has not existed for desired amount of time, do not allow fault to be latched
				debounce_FAULT(8) <= '0';
				counter := counter + 1;
			END IF;
		end if;
	end process;

END ARCHITECTURE;
