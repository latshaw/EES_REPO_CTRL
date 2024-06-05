library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package components is

type reg32_array is array(7 downto 0) of std_logic_vector(31 downto 0);
type reg28_array is array(7 downto 0) of std_logic_vector(27 downto 0);
type reg27_array is array(7 downto 0) of std_logic_vector(26 downto 0); --added stepper motors
type reg16_array is array(7 downto 0) of std_logic_vector(15 downto 0);
type reg14_array is array(7 downto 0) of std_logic_vector(13 downto 0);
type reg13_array is array(7 downto 0) of std_logic_vector(12 downto 0);
type reg12_array is array(7 downto 0) of std_logic_vector(11 downto 0);
type reg10_array is array(7 downto 0) of std_logic_vector(9 downto 0);
type reg8_array is array(7 downto 0) of std_logic_vector(7 downto 0);
type reg7_array is array(7 downto 0) of std_logic_vector(6 downto 0);
type reg2_array is array(7 downto 0) of std_logic_vector(1 downto 0);

type cnt16_array is array(7 downto 0) of std_logic_vector(26 downto 0);


type reg16_array_unsigned is array(7 downto 0) of unsigned(15 downto 0);

--added 7/7/2020 for TMC
component FLIP_FLOP
		port(clock 	: in std_logic;
			 reset 	: in std_logic;
			 clear  : in std_logic;
			 en		: in std_logic;
			 INP	: in std_logic;
			 OUP : out std_logic
			);
end component;

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

component regneUNSIGNED
		generic(n : integer := 16); 
		port(clock 	: in std_logic;
			 reset 	: in std_logic;
			 clear  : in std_logic;
			 en		: in std_logic;
			 input	: in std_logic_vector(n-1 downto 0);
			 output : out UNSIGNED(n-1 downto 0)
			);
end component;

component counter
		generic(n : integer := 5);
		port(clock		: in std_logic;
			 reset		: in std_logic;
			 clear  	: in std_logic;
			 en			: in std_logic;
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

component shift_reg is
	generic(n : integer := 16);
	port(clock : in std_logic;
		 reset : in std_logic;
		 en : in std_logic;
		 clr : in std_logic;
		 inp : in std_logic;
		 output : out std_logic_vector(n-1 downto 0)
		 );
end component;

COMPONENT SHIFT_LEFT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 CLEAR : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END COMPONENT;

COMPONENT SHIFT_RIGHT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 CLEAR : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END COMPONENT;

COMPONENT SHIFT_LEFT_BIT IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 SHIFT_BIT : IN STD_LOGIC;
		 OUTPUT : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
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


----------------------- n bit generic register with output in UNSIGNED ---------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regneUNSIGNED is
		generic(n : integer := 16); 
		port(clock 	: in std_logic;
			 reset 	: in std_logic;
			 clear  : in std_logic;
			 en		: in std_logic;
			 input	: in std_logic_vector(n-1 downto 0);
			 output : out UNSIGNED(n-1 downto 0)
			);
end entity regneUNSIGNED;

architecture regneUNSIGNED of regneUNSIGNED is
begin

	process(clock,reset)
	begin
		if(reset = '0') then
			output <= (others => '0');
		elsif(clock = '1' and clock'event) then
			if(clear = '0') then
				output <= (others => '0');
			elsif(en = '1') then
				output <= UNSIGNED(input);
			end if;
		end if;
	end process;
end architecture regneUNSIGNED;

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
			 en			: in std_logic;
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
			elsif(en = '1') then
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
	
library ieee;
use ieee.std_logic_1164.all;

entity shift_reg is
	generic(n : integer := 16);
	port(clock : in std_logic;
		 reset : in std_logic;
		 clr : in std_logic;
		 en : in std_logic;
		 inp : in std_logic;
		 output : out std_logic_vector(n-1 downto 0)
		 );
end entity shift_reg;

architecture behavior of shift_reg is

signal temp_out	: std_logic_vector(n-1 downto 0);

begin
	
	
	process(clock, reset)
	begin
		if(reset = '0') then		
			temp_out <= (others => '0');
		elsif(clock = '1' and clock'event) then
			if(clr = '0') then
				temp_out <= (others => '0');
			elsif(en = '1') then
				temp_out <= temp_out(n-2 downto 0) & inp;
			end if;
		end if;
	end process;
	
	output	<= temp_out;	

end architecture behavior;
	
	
------end of shift register for LM74 temperature sensor-----

------SHIFT RIGHT REGISTER FOR AD7328---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_LEFT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 CLEAR : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END ENTITY SHIFT_LEFT_REG;

ARCHITECTURE BEHAVIOR OF SHIFT_LEFT_REG IS

SIGNAL SHIFT_INPUT		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);

BEGIN


	PROCESS(CLOCK, RESET)
	BEGIN
		IF(RESET = '0') THEN
			SHIFT_INPUT <= (OTHERS => '0');
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
			IF(CLEAR = '0') THEN
				SHIFT_INPUT <= (OTHERS => '0');
			ELSIF(LOAD = '1') THEN
				SHIFT_INPUT <= INP;
			ELSIF(EN = '1') THEN
				SHIFT_INPUT <= SHIFT_INPUT(N-2 DOWNTO 0) & '0';
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT <= SHIFT_INPUT(N-1);

END ARCHITECTURE BEHAVIOR;

-------------------------------------------------------
----------------------- flip flop register----------------
library ieee;
use ieee.std_logic_1164.all;

entity FLIP_FLOP is
		port(clock 	: in std_logic;
			 reset 	: in std_logic;
			 clear  : in std_logic;
			 en		: in std_logic;
			 INP	: in std_logic;
			 OUP : out std_logic
			);
end entity FLIP_FLOP;

architecture FLIP_FLOP of FLIP_FLOP is
begin

	process(clock,reset)
	begin
		if(reset = '0') then
			OUP <= '0';
		elsif(clock = '1' and clock'event) then
			if(clear = '0') then
				OUP <= '0';
			elsif(en = '1') then
				OUP <= INP;
			end if;
		end if;
	end process;
end architecture FLIP_FLOP;


-----------------flip flop register----------------

------SHIFT LEFT REGISTER WITH INPUT BIT---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_LEFT_BIT IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 SHIFT_BIT : IN STD_LOGIC;
		 OUTPUT : OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0)
		 );
END ENTITY SHIFT_LEFT_BIT;

ARCHITECTURE BEHAVIOR OF SHIFT_LEFT_BIT IS

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
				SHIFT_INPUT <= SHIFT_INPUT(N-2 DOWNTO 0) & SHIFT_BIT;
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT <= SHIFT_INPUT;

END ARCHITECTURE BEHAVIOR;

-------------------------------------------------------
------SHIFT RIGHT REGISTER FOR AD7328---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_RIGHT_REG IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 CLEAR : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END ENTITY SHIFT_RIGHT_REG;

ARCHITECTURE BEHAVIOR OF SHIFT_RIGHT_REG IS

SIGNAL SHIFT_INPUT		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);

BEGIN


	PROCESS(CLOCK, RESET)
	BEGIN
		IF(RESET = '0') THEN
			SHIFT_INPUT <= (OTHERS => '0');
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
			IF(CLEAR = '0') THEN
				SHIFT_INPUT <= (OTHERS => '0');
			ELSIF(LOAD = '1') THEN
				SHIFT_INPUT <= INP;
			ELSIF(EN = '1') THEN
				SHIFT_INPUT <= '0' & SHIFT_INPUT(N-1 DOWNTO 1);
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT <= SHIFT_INPUT(N-1);

END ARCHITECTURE BEHAVIOR;

-------------------------------------------------------


