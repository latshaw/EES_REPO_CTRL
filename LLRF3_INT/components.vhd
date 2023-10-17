library ieee;
use ieee.std_logic_1164.all;

package components is

TYPE REG23_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(22 DOWNTO 0);
TYPE REG20_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(19 DOWNTO 0);
TYPE REG16_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
TYPE REG14_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(13 DOWNTO 0);
TYPE REG13_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(12 DOWNTO 0);
TYPE REG12_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
TYPE REG11_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
TYPE REG10_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
TYPE REG5_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(4 DOWNTO 0);

component regne
		generic(n : integer := 16); 
		port(clock 	: in std_logic;
			 reset 	: in std_logic;
			 clear  : in std_logic;
			 en		: in std_logic;
			 input	: in std_logic_vector(n-1 downto 0);
			 output : out std_logic_vector(n-1 downto 0)
			);
end component;

component counter
		generic(n : integer := 5);
		port(clock		: in std_logic;
			 reset		: in std_logic;
			 clear  	: in std_logic;
			 enable		: in std_logic;
			 count		: buffer std_logic_vector(n-1 downto 0)
			);
end component;



component latch_n is
	port(clock : in std_logic;
		 reset : in std_logic;
		 clear  : in std_logic;
		 en : in std_logic;
		 inp : in std_logic;
		 oup : out std_logic
		);
end component;

COMPONENT SHIFT_LEFT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 INP : IN STD_LOGIC;
		 OUTPUT : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
		 );
END COMPONENT;

COMPONENT SHIFT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END COMPONENT;



end components;



----------------------- n bit generic register----------------
library ieee;
use ieee.std_logic_1164.all;

entity regne is
		generic(n : integer := 16); 
		port(clock 	: in std_logic;
			 reset 	: in std_logic;
			 clear  : in std_logic;
			 en		: in std_logic;
			 input	: in std_logic_vector(n-1 downto 0);
			 output : out std_logic_vector(n-1 downto 0)
			);
end entity regne;

architecture regne of regne is
begin

	process(clock,reset)
	begin
		if(reset = '0') then
			output <= (others => '0');
		elsif(clock = '1' and clock'event) then
			if(clear = '0') then
				output <= (others => '0');
			elsif(en = '1') then
				output <= input;
			end if;
		end if;
	end process;
end architecture regne;


-----------------end of n bit generic register----------------


----------------------- n bit generic counter----------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity counter is
		generic(n : integer := 5);
		port(clock		: in std_logic;
			 reset		: in std_logic;
			 clear  	: in std_logic;
			 enable		: in std_logic;
			 count		: buffer std_logic_vector(n-1 downto 0)
			);
end entity counter;

architecture counter of counter is 
begin
	process(clock,reset)
	begin
		if(reset = '0') then
			count <= (others => '0');		
		elsif(clock = '1' and clock'event) then
			if(clear = '0') then
				count <= (others => '0');		
			elsif(enable = '1') then
				count <= count + 1;
			end if;
		end if;	
	end process;
end architecture counter;				


---------------------end of n bit generic counter----------------

--------latch with set and reset --------------------

library ieee;
use ieee.std_logic_1164.all;

entity latch_n is
	port(clock : in std_logic;
		 reset : in std_logic;
		 clear  : in std_logic;
		 en : in std_logic;
		 inp : in std_logic;
		 oup : out std_logic
		);
end entity latch_n;

architecture latch_n of latch_n is
begin

	process(clock,reset)
	begin
		if(reset = '0') then
				oup <= '0';		
		elsif(clock = '1' and clock'event) then
			if(clear = '0') then
				oup <= '0';
			elsif (en = '1') then
				oup <= inp;
			end if;
		end if;	
	end process;
end architecture latch_n;			

--------end of latch with set and reset -------------------- 

--------shift register for LM74 temperature sensor----------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_LEFT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 INP : IN STD_LOGIC;
		 OUTPUT : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
		 );
END ENTITY SHIFT_LEFT_REG;

ARCHITECTURE BEHAVIOR OF SHIFT_LEFT_REG IS

SIGNAL TEMP_OUT	: STD_LOGIC_VECTOR(N-1 DOWNTO 0);

BEGIN
	
	
	PROCESS(CLOCK, RESET)
	BEGIN
		IF(RESET = '0') THEN		
			TEMP_OUT <= (OTHERS => '0');
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN	
			IF(EN = '1') THEN
				TEMP_OUT <= TEMP_OUT(N-2 DOWNTO 0) & INP;
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT	<= TEMP_OUT;	

END ARCHITECTURE BEHAVIOR;	

	
	
------end of shift register for LM74 temperature sensor-----


------SHIFT RIGHT REGISTER FOR AD7328---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END ENTITY SHIFT_REG;

ARCHITECTURE BEHAVIOR OF SHIFT_REG IS

SIGNAL SHIFT_INPUT		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);

BEGIN


	PROCESS(CLOCK, RESET)
	BEGIN
		IF(RESET = '0') THEN
			SHIFT_INPUT <= (OTHERS => '0');
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
			IF(LOAD = '1') THEN
				SHIFT_INPUT <= INP;
			ELSIF(EN = '1') THEN
				SHIFT_INPUT <= SHIFT_INPUT(N-2 DOWNTO 0) & '0';
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT <= SHIFT_INPUT(N-1);

END ARCHITECTURE BEHAVIOR;

-------------------------------------------------------





