
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;   
-- added for reading text vectors for tb
--use STD.textio.all;
--use ieee.std_logic_textio.all;                 

ENTITY math_main IS
END math_main;
ARCHITECTURE math_main OF math_main IS

type array_16 is array (0 to 39) of Unsigned(15 downto 0);

signal U_value_1, U_value_2, U_result_1, U_result_2 : Unsigned(15 downto 0);
signal S_value_3, S_value_4, S_result_1, S_result_2 : SIGNED(15 downto 0);

signal HRT : array_16 := ( others => x"0000");

signal compare, compare2 : STD_LOGIC;

signal test : STD_LOGIC_VECTOR(7 downto 0);

BEGIN

compare <= '1' when S_result_1 > S_result_2 else '0';
compare2<= '1' when U_result_1 > U_result_2 else '0';

always : PROCESS

BEGIN
	test <=x"01";
	S_result_1 <= x"0000";
    S_result_2 <= x"0000";
	
	U_result_1 <= x"0000";
	U_result_2 <= x"0000";
	
	U_value_1 <= x"0001"; -- +1
	U_value_2 <= x"8000"; -- +32768
	S_value_3 <= x"0001"; -- +1
	S_value_4 <= x"8000"; -- -32768

	wait for 100 ns;
	test <=x"02";
	U_result_1 <= U_value_1; -- 1
	U_result_2 <= U_value_2; -- 32768
	-- res 1 is < res 2
	
	wait for 100 ns;
	test <=x"03";
	U_result_1 <= U_value_1 + U_value_2;	-- 1 + 32768 = 32769
	U_result_2 <= unsigned(S_value_4);		--  32768, does a type cast, looks at original value as if it were unsigned
	-- res 1 is greater than res 2
	
	wait for 100 ns;
	test <=x"04";
	S_result_1 <= signed(U_value_1); --1  -- this is type casting. The original value is now looked at as if it were signed.
	S_result_2 <= signed(U_value_2); -- -32768
	-- res 1 is > then res 2
	
	wait for 100 ns;
	test <=x"05";
	S_result_1 <= S_value_3 + S_value_3;		 -- 1 + 1 = 2
	S_result_2 <= signed(U_value_1) + S_value_3; -- 1 + 1 = 2
	-- res 1 is not > res 2 (same value)
	
	wait for 100 ns;
	test <=x"06";
	U_value_1 <= x"FF9C"; -- 65436
	U_value_2 <= x"0063"; -- 99
	-- res1 is > than res 2
	
	wait for 100 ns;
	test <=x"07";
	S_result_1 <= signed(U_value_1);		 				-- -100
	S_result_2 <= signed(U_value_1) + signed(U_value_2);	-- -1
	-- res 1 is not > res 2
	
	wait for 100 ns;
	test <=x"08";
	U_value_1 <= x"0064"; -- 100
	U_value_2 <= x"0063"; -- 99
	
	wait for 100 ns;
	test <=x"09";
	U_result_1 <= U_value_2 - U_value_1; -- 99-100 = -1 in 2's complement
	U_result_2 <= U_value_1 - U_value_2; -- 100 - 99 = +1
	-- res1 is > res2 because the comparitors sees this as 65535>1 and not -1>1.
	
	wait for 100 ns;
	test <=x"0a";
	S_result_1 <= signed(U_result_1); -- typecasts 0xFFFF into -1
	S_result_2 <= signed(U_result_2); -- typcasts 0x0001 to 1
	-- res 1 is not > res 2 because comparitor is looking at -1>1 which is false.
	
	wait for 100 ns;
	test <=x"0b";
	U_value_1 <= x"9c02"; --
	U_value_2 <= x"FE03"; --
	
	wait for 100 ns;
	test <=x"0c";
	S_result_1  <= signed(U_value_1(15 downto 8)) * signed(U_value_1(7 downto 0)); -- (-100)*2 = -200
	S_result_2  <= signed(U_value_2(15 downto 8)) * signed(U_value_2(7 downto 0)); -- (-2)*3 =  -6
	-- res1 is not > res 2
	
	U_result_1  <= (U_value_1(15 downto 8)) * (U_value_1(7 downto 0)); -- overflow values... 
	U_result_2  <= (U_value_2(15 downto 8)) * (U_value_2(7 downto 0)); -- overflow values...
	
	wait for 100 ns;
	test <=x"0d";
	S_result_1  <= signed(U_result_1); -- because of overflow values in previous operation, we do not get the right values...
	S_result_2  <= signed(U_result_2);
	
	wait for 100 ns;
	test <=x"0e";
	-- cast values into signed before multiplying and then return to unsigned so it can fit in vector.
	-- the U_results are 2's complement.
	
	U_result_1 <= unsigned(signed(U_value_1(15 downto 8)) * signed(U_value_1(7 downto 0))); 
	U_result_2 <= unsigned(signed(U_value_2(15 downto 8)) * signed(U_value_2(7 downto 0)) );
	
	wait for 100 ns;
	test <=x"0f";
	S_result_1  <= signed(U_result_1);
	S_result_2  <= signed(U_result_2);
	-- res 1 is not > res 2
	
	wait for 100 ns;
	test <=x"10";
	S_result_1  <= signed(U_result_2);
	S_result_2  <= signed(U_result_1);
	-- now res 1 is > res 2, -6>-200
	wait for 100 ns;
	
	assert false report "End Sim " severity failure;
	-- ==================================== CONCLUSIONS ===== :)
	-- When an unsinged value is converted to signed, the original value is looked at as if it were sign.
	-- No convertion process occurs, only type casting.
	--
	-- the output of signed arithmetic is signed.
	--
	-- The result of comparisons are boolean.
	--
	-- Ungined comparisons compare the value as if they were truly unsigned (even if represtended as 2's complement)
	-- Thus, if you have a 2's complement value that is in unsinged format, you will need to typecast it into signed
	-- before performing the comparison. 
	--
	-- unsigned multiplication, even if in 2's complement, will perform multiplciation as if values were positive
	-- must cast into signed first only if your unsinged vectors may contain 2's complement data
	--
	
END PROCESS always;    
                                      
END math_main;
