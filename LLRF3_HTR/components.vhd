library ieee;
use ieee.std_logic_1164.all;

package components is

TYPE REG23_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(22 DOWNTO 0);
TYPE REG16_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(15 DOWNTO 0);
TYPE REG14_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(13 DOWNTO 0);
TYPE REG13_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(12 DOWNTO 0);
TYPE REG12_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(11 DOWNTO 0);
TYPE REG11_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(10 DOWNTO 0);
TYPE REG10_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(9 DOWNTO 0);
TYPE REG5_ARRAY IS ARRAY(7 DOWNTO 0) OF STD_LOGIC_VECTOR(4 DOWNTO 0);
TYPE REG32_8 IS ARRAY (7 DOWNTO 0) OF STD_LOGIC_VECTOR(31 DOWNTO 0);

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



COMPONENT FLIP_FLOP IS
	PORT(CLOCK 	: IN STD_LOGIC;
		  RESET 	: IN STD_LOGIC;
		  CLEAR  : IN STD_LOGIC;
		  EN 		: IN STD_LOGIC;
		  INP 	: IN STD_LOGIC;
		  OUP 	: OUT STD_LOGIC
		  );
END COMPONENT;

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

component shift_reg_FCC is
	generic(n : integer := 16);
	port(clock : in std_logic;
		 reset : in std_logic;
		 en : in std_logic;
		 clr : in std_logic;
		 inp : in std_logic;
		 output : out std_logic_vector(n-1 downto 0)
		 );
end component;

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

COMPONENT SHIFT_LEFT_REG_FCC IS
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

COMPONENT SHIFT_SQUARE_ROOT IS
	GENERIC(N : INTEGER := 64);
	PORT(CLOCK 		: IN STD_LOGIC;
		  RESET 	: IN STD_LOGIC;
		  CLEAR		: IN STD_LOGIC;
		  EN 		: IN STD_LOGIC;
		  LOAD 		: IN STD_LOGIC;
		  INP 		: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);		  
		  SHIFT_IN	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		  OUTPUT 	: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  SHIFT_BIT	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
		  );
END COMPONENT;

COMPONENT SQUARE_ROOT IS

	PORT(CLOCK		: IN STD_LOGIC;
	     RESET		: IN STD_LOGIC;
		 GO			: IN STD_LOGIC;
		 DATA_IN	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DATA_OUT	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DONE_OUT	: OUT STD_LOGIC
		 );
END COMPONENT;

COMPONENT SHIFT_LEFT_REG_ADS8353 IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK	: IN STD_LOGIC;
		  RESET	: IN STD_LOGIC;
		  EN		: IN STD_LOGIC;
		  LOAD	: IN STD_LOGIC;
		  INP		: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  OUTPUT	: OUT STD_LOGIC
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

--------FLIP with RESET --------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FLIP_FLOP IS
	PORT(CLOCK 	: IN STD_LOGIC;
		  RESET 	: IN STD_LOGIC;
		  CLEAR  : IN STD_LOGIC;
		  EN 		: IN STD_LOGIC;
		  INP 	: IN STD_LOGIC;
		  OUP 	: OUT STD_LOGIC
		 );
END ENTITY FLIP_FLOP;

ARCHITECTURE FLIP_FLOP of FLIP_FLOP IS
BEGIN

	PROCESS(CLOCK,RESET)
	BEGIN
		IF(RESET = '0') THEN
				OUP <= '0';		
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
			IF(CLEAR = '0') THEN
				OUP <= '0';
			ELSIF (EN = '1') THEN
				OUP <= INP;
			END IF;
		END IF;	
	END PROCESS;
END ARCHITECTURE FLIP_FLOP;			

--------END of FLIP FLOP with RESET -------------------- 
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

--------shift register for POLYNOMIAL DIVISION----------
	
library ieee;
use ieee.std_logic_1164.all;

entity shift_reg_fcc is
	generic(n : integer := 16);
	port(clock : in std_logic;
		 reset : in std_logic;
		 clr : in std_logic;
		 en : in std_logic;
		 inp : in std_logic;
		 output : out std_logic_vector(n-1 downto 0)
		 );
end entity shift_reg_fcc;

architecture behavior of shift_reg_fcc is

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
	
	
------end of shift register for POLYNOMIAL DIVISION-----

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

------SHIFT RIGHT REGISTER FOR POLYNOMIAL DIVISION---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_LEFT_REG_FCC IS
	GENERIC(N : INTEGER := 16);
	PORT(CLOCK : IN STD_LOGIC;
		 RESET : IN STD_LOGIC;
		 EN : IN STD_LOGIC;
		 CLEAR : IN STD_LOGIC;
		 LOAD : IN STD_LOGIC;
		 INP : IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		 OUTPUT : OUT STD_LOGIC
		 );
END ENTITY SHIFT_LEFT_REG_FCC;

ARCHITECTURE BEHAVIOR OF SHIFT_LEFT_REG_FCC IS

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

------SHIFT LEFT REGISTER for square root---------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY SHIFT_SQUARE_ROOT IS
	GENERIC(N : INTEGER := 64);
	PORT(CLOCK 		: IN STD_LOGIC;
		  RESET		: IN STD_LOGIC;
		  CLEAR		: IN STD_LOGIC;
		  EN 		: IN STD_LOGIC;
		  LOAD 		: IN STD_LOGIC;		  
		  INP 		: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  SHIFT_IN	: IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		  OUTPUT 	: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  SHIFT_BIT	: OUT STD_LOGIC_VECTOR(1 DOWNTO 0)

		  );
END ENTITY;

ARCHITECTURE BEHAVIOR OF SHIFT_SQUARE_ROOT IS

SIGNAL SHIFT_INPUT		: STD_LOGIC_VECTOR(N-1 DOWNTO 0);


BEGIN



	PROCESS(CLOCK, RESET)
	BEGIN
		IF(RESET = '0') THEN
			SHIFT_INPUT <= (OTHERS => '0');
		ELSIF(CLOCK = '1' AND CLOCK'EVENT) THEN
			IF (CLEAR = '0') THEN 
				SHIFT_INPUT <= (OTHERS => '0');
			ELSIF(LOAD = '1') THEN
				SHIFT_INPUT <= INP;
			ELSIF(EN = '1') THEN
				SHIFT_INPUT <= SHIFT_INPUT(N-3 DOWNTO 0) & SHIFT_IN;
			END IF;
		END IF;
	END PROCESS;
	
	OUTPUT 		<= SHIFT_INPUT;
	SHIFT_BIT	<= SHIFT_INPUT(N-1 DOWNTO N-2);


END ARCHITECTURE BEHAVIOR;

-------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE WORK.COMPONENTS.ALL;


ENTITY SQUARE_ROOT IS

	PORT(CLOCK		: IN STD_LOGIC;
	     RESET		: IN STD_LOGIC;
		 GO			: IN STD_LOGIC;
		 DATA_IN	: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 DATA_OUT	: OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
		 DONE_OUT	: OUT STD_LOGIC
		 );
		 
END ENTITY SQUARE_ROOT;

ARCHITECTURE BEHAVIOR OF SQUARE_ROOT IS

SIGNAL RADICAND					: STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL SHIFT_RADICAND_OUT		: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL SHIFT_RADICAND_INT		: STD_LOGIC_VECTOR(63 DOWNTO 0);
SIGNAL EN_SHIFT_RADICAND		: STD_LOGIC;
SIGNAL LD_RADICAND				: STD_LOGIC;
SIGNAL CLR_RADICAND				: STD_LOGIC;

SIGNAL EN_QUOTIENT				: STD_LOGIC;
SIGNAL LD_QUOTIENT				: STD_LOGIC;
SIGNAL QUOTIENT_BIT				: STD_LOGIC;
SIGNAL QUOTIENT_INT				: STD_LOGIC_VECTOR(31 DOWNTO 0);

SIGNAL SHIFT_SUBTRACT_A			: STD_LOGIC;
SIGNAL LD_SUBTRACT_A			: STD_LOGIC;
SIGNAL SUBTRACT_RESULT			: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SUBTRACT_A				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SUBTRACT_A_SHIFT			: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL CLR_SUBTRACT_A			: STD_LOGIC;

SIGNAL SHIFT_SUBTRACT_B			: STD_LOGIC;
SIGNAL LD_SUBTRACT_B			: STD_LOGIC;
SIGNAL SUBTRACT_B				: STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL SUBTRACT_B_SHIFT			: STD_LOGIC_VECTOR(1 DOWNTO 0);
SIGNAL CLR_SUBTRACT_B			: STD_LOGIC;

SIGNAL EN_LOOP_COUNT			: STD_LOGIC;
SIGNAL LOOP_COUNT				: STD_LOGIC_VECTOR(4 DOWNTO 0);

SIGNAL EN_RESULT				: STD_LOGIC;

SIGNAL QUOTIENT_INT_UNADJ : STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL QUOTIENT_INT_ADJ : STD_LOGIC_VECTOR(15 DOWNTO 0);

SIGNAL DONE_OUT_BUF     : STD_LOGIC;
SIGNAL DONE_OUT_BUF1    : STD_LOGIC;

TYPE STATE_TYPE IS (INIT, LOAD_QUOTIENT_INT, LOAD_DATA, LOAD_SUB_REG, ENA_QUOTIENT, SHIFT_RADICAND, ENA_SUB_REG, DONE);
SIGNAL STATE					: STATE_TYPE;

BEGIN
	
RADICAND		<= DATA_IN & X"00000000";
	
RADICAND_REG: SHIFT_SQUARE_ROOT
	GENERIC MAP(N => 64)
	PORT MAP(CLOCK 		=> CLOCK,
		  	 RESET		=> RESET,
		  	 CLEAR		=> CLR_RADICAND,
			 EN 		=> EN_SHIFT_RADICAND,
		  	 LOAD 		=> LD_RADICAND,
		  	 INP 		=> RADICAND,
			 SHIFT_IN	=> "00",
		  	 OUTPUT 	=> SHIFT_RADICAND_INT,
			 SHIFT_BIT	=> SHIFT_RADICAND_OUT  
		  	 );
			   
QUOTIENT_REG: SHIFT_LEFT_BIT
	GENERIC MAP(N => 32)
	PORT MAP(CLOCK 		=> CLOCK,
		  	 RESET		=> RESET,
		  	 EN 		=> EN_QUOTIENT,
			 LOAD		=> LD_QUOTIENT,  
		  	 INP 		=> X"00000000",
			 SHIFT_BIT	=> QUOTIENT_BIT, 
		  	 OUTPUT 	=> QUOTIENT_INT
		  	 );
			   
SQUARE_ROOT_LOOP_COUNTER: COUNTER
		GENERIC MAP(N => 5)
		PORT MAP(CLOCK		=> CLOCK,
			 	 RESET		=> RESET,
			 	 CLEAR  	=> '1',
			 	 ENABLE		=> EN_LOOP_COUNT,
			 	 COUNT		=> LOOP_COUNT
				 );
			   
SUBTRACT_REGA: SHIFT_SQUARE_ROOT
	GENERIC MAP(N => 32)
	PORT MAP(CLOCK 		=> CLOCK,
		  	 RESET		=> RESET,
		  	 CLEAR		=> CLR_SUBTRACT_A,
			 EN 		=> SHIFT_SUBTRACT_A,
		  	 LOAD 		=> LD_SUBTRACT_A,
			 SHIFT_IN	=> SHIFT_RADICAND_INT(63 DOWNTO 62),  
		  	 INP 		=> SUBTRACT_RESULT,
		  	 OUTPUT 	=> SUBTRACT_A,
			 SHIFT_BIT	=> SUBTRACT_A_SHIFT
		  	 );			   

SUBTRACT_REGB: SHIFT_SQUARE_ROOT
	GENERIC MAP(N => 32)
	PORT MAP(CLOCK 		=> CLOCK,
		  	 RESET		=> RESET,
		  	 CLEAR		=> CLR_SUBTRACT_B,
			 EN 		=> SHIFT_SUBTRACT_B,
		  	 LOAD 		=> LD_SUBTRACT_B,
			 SHIFT_IN	=> "01",  
		  	 INP 		=> QUOTIENT_INT,
		  	 OUTPUT 	=> SUBTRACT_B,
			 SHIFT_BIT	=> SUBTRACT_B_SHIFT
		  	 );
			   
SUBTRACT_RESULT		<= SUBTRACT_A - SUBTRACT_B WHEN QUOTIENT_BIT = '1' ELSE SUBTRACT_A;

QUOTIENT_BIT	<= '1' WHEN (SUBTRACT_A > SUBTRACT_B OR SUBTRACT_A = SUBTRACT_B) AND SUBTRACT_A /= X"00000000" ELSE '0';
	
RESULT_UNADJ_REG: REGNE
		GENERIC MAP(N => 32) 
		PORT MAP(CLOCK 	=> CLOCK,
			 	 RESET 	=> RESET,
			 	 CLEAR  => '1',
			 	 EN		=> EN_RESULT,
			 	 INPUT	=> QUOTIENT_INT,
			 	 OUTPUT => QUOTIENT_INT_UNADJ
				 );
				 
QUOTIENT_INT_ADJ <= (QUOTIENT_INT_UNADJ(31 DOWNTO 16) + '1') WHEN QUOTIENT_INT_UNADJ(15) = '1' ELSE QUOTIENT_INT_UNADJ(31 DOWNTO 16); 


RESULT_ADJ_REG: REGNE
		GENERIC MAP(N => 16) 
		PORT MAP(CLOCK 	=> CLOCK,
			 	 RESET 	=> RESET,
			 	 CLEAR  => '1',
			 	 EN		=> '1',
			 	 INPUT	=> QUOTIENT_INT_ADJ,
			 	 OUTPUT => DATA_OUT
				 );
				 
EN_DONE_OUT_FF0: FLIP_FLOP
	PORT MAP(CLOCK  => CLOCK,
		       RESET  => RESET,
		       CLEAR  => '1',
		       EN     => '1',
		       INP    => DONE_OUT_BUF, 	
		       OUP    => DONE_OUT_BUF1
		      );	
		      
EN_DONE_OUT_FF1: FLIP_FLOP
	PORT MAP(CLOCK  => CLOCK,
		       RESET  => RESET,
		       CLEAR  => '1',
		       EN     => '1',
		       INP    => DONE_OUT_BUF1, 	
		       OUP    => DONE_OUT
		       );

	PROCESS(CLOCK, RESET)
	BEGIN
		IF RESET = '0' THEN
			STATE <= INIT;
		ELSIF CLOCK = '1' AND CLOCK'EVENT THEN
			
			CASE STATE IS
				
				WHEN INIT				=> IF GO = '1' THEN STATE <= LOAD_QUOTIENT_INT;
									   		ELSE STATE <= INIT;
									   		END IF;
									   
				WHEN LOAD_QUOTIENT_INT	=> STATE <= LOAD_DATA;
									   
				WHEN LOAD_DATA			=> STATE <= LOAD_SUB_REG;
				
				WHEN LOAD_SUB_REG		=> STATE <= ENA_QUOTIENT;
				
				WHEN ENA_QUOTIENT		=> IF LOOP_COUNT /= "11111" THEN STATE <= SHIFT_RADICAND;
									  		 ELSE STATE <= DONE;
									   		END IF;
									   
				WHEN SHIFT_RADICAND		=> STATE <= ENA_SUB_REG;
				
				WHEN ENA_SUB_REG		=> STATE <= ENA_QUOTIENT;
				
				WHEN DONE				=> STATE <= INIT;
				
				WHEN OTHERS				=> STATE <= INIT;
				
			END CASE;
		END IF;
	END PROCESS;
				
LD_RADICAND			<= '1' WHEN STATE = LOAD_DATA ELSE '0';
LD_QUOTIENT			<= '1' WHEN STATE = LOAD_QUOTIENT_INT ELSE '0';
	
EN_SHIFT_RADICAND	<= '1' WHEN STATE = SHIFT_RADICAND ELSE '0';
	
LD_SUBTRACT_A		<= '1' WHEN STATE = LOAD_DATA OR STATE = SHIFT_RADICAND ELSE '0';	
LD_SUBTRACT_B		<= '1' WHEN STATE = LOAD_DATA OR STATE = SHIFT_RADICAND ELSE '0';
	
SHIFT_SUBTRACT_A	<= '1' WHEN STATE = LOAD_SUB_REG OR STATE = ENA_SUB_REG ELSE '0';
SHIFT_SUBTRACT_B	<= '1' WHEN STATE = LOAD_SUB_REG OR STATE = ENA_SUB_REG ELSE '0';
	
EN_QUOTIENT			<= '1' WHEN STATE = ENA_QUOTIENT ELSE '0';	
	
EN_RESULT			<= '1' WHEN STATE = DONE ELSE '0';
DONE_OUT_BUF			<= '1' WHEN STATE = DONE ELSE '0';
	
EN_LOOP_COUNT		<= '1' WHEN STATE = ENA_QUOTIENT ELSE '0';
	
CLR_RADICAND		<= '0' WHEN STATE = DONE ELSE '1';
	
CLR_SUBTRACT_A		<= '0' WHEN STATE = DONE ELSE '1';
	
CLR_SUBTRACT_B		<= '0' WHEN STATE = DONE ELSE '1';
	


	
END ARCHITECTURE BEHAVIOR;

--------------------------------SHIFT REGISTER ADS8353----------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY SHIFT_LEFT_REG_ADS8353 IS
	GENERIC(N : INTEGER :=16);
	PORT(CLOCK	: IN STD_LOGIC;
		  RESET	: IN STD_LOGIC;
		  EN		: IN STD_LOGIC;
		  LOAD	: IN STD_LOGIC;
		  INP		: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  OUTPUT	: OUT STD_LOGIC
		  );
END ENTITY SHIFT_LEFT_REG_ADS8353;

ARCHITECTURE BEHAVIOR OF SHIFT_LEFT_REG_ADS8353 IS

SIGNAL SHIFT_INPUT : STD_LOGIC_VECTOR(N-1 DOWNTO 0);

BEGIN

	PROCESS(CLOCK, RESET)
	BEGIN
		IF RESET = '0' THEN 
			SHIFT_INPUT	<= (OTHERS => '0');
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





