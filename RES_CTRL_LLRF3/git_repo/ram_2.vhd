-- JAL, 12/2/21
-- ram block for 2k
-- there are actually 2048 r/w registers that are each 16 bit. This allows a 11 bit counter
-- to fully access the entire range. The coutner will 'roll over' once the max index is reached (external to this module)

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;

ENTITY ram_2 IS 
		PORT(
		clock 	: IN  STD_LOGIC;  
		WREN		: IN  STD_LOGIC; -- write enable
		ADDR_w	: IN  UNSIGNED(10 downto 0); -- address of write data
		ADDR_r	: IN  STD_LOGIC_VECTOR(10 downto 0); --address of read data 
		DATA_in	: IN  STD_LOGIC_VECTOR(31 downto 0); -- data being written
		DATA_out	: OUT STD_LOGIC_VECTOR(31 downto 0) -- data read
	);
END ram_2;

ARCHITECTURE ram_2 OF ram_2 IS 


TYPE mem IS ARRAY(0 TO 2047) OF UNSIGNED(31 DOWNTO 0);
	SIGNAL ram_block : mem; 
	attribute ramstyle : string;
	attribute ramstyle of ram_block : signal is "M20K";
	
BEGIN 
	
	PROCESS (clock)
   BEGIN
      IF (clock'event AND clock = '1') THEN
         IF (WREN='1') THEN -- if write enable
            ram_block(to_integer(ADDR_w)) <= UNSIGNED(DATA_in);
         END IF;
			-- for reading
         DATA_out <= STD_LOGIC_VECTOR(ram_block(to_integer(UNSIGNED(ADDR_r))));
      END IF;
	END PROCESS;
	
end ram_2;