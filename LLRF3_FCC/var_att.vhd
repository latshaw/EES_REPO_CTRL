
-- transmit n bits of serial data, (one start bit, one stop bit and no parity bit disabled).  
--When transmit is complete o_latch_Done will be driven high for one clock cycle.

-- Set Generic g_CLKS_PER_BIT as follows:
-- g_CLKS_PER_BIT = (Frequency of i_Clk)/(Frequency of UART)
-- Example: 10 MHz Clock, 115200 baud UART
-- (10000000)/(115200) = 87

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity var_att is

  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;  -----use KE1 button
	 o_LEDTX_Serial : out std_logic; -- assign GPIO-03 (pin 6) - A3
    o_latch_Done   : out std_logic; -- assign GPIO-04 (pin 7) - B3
	 o_LED_clk 		: out std_logic;
	 o_LED_RFswitch :out std_logic;
	 o_Att_clk 		: out std_logic;  -- assign GPIO-02 (pin 5) - A2
------------------------------------------	 
	 i_RF_switch: in std_logic;        -- use sw1 for RF switch
	 o_RF_switch: out std_logic:='0';  -- assign GPIO-05 (pin 8)-B4
-----------------------------------------
	 i_att_switch1: in std_logic;  -- set attenuation with 3 switches
	 i_att_switch2: in std_logic;
	 i_att_switch3: in std_logic;
	 o_att_switch1: out std_logic:='0';   -- use only for LED
	 o_att_switch2: out std_logic:='0';
	 o_att_switch3: out std_logic:='0'
    );
end var_att;

architecture RTL of var_att is
 
  type t_SM_Main is (s_Idle, s_Att_clk_Gen, s_TX_Data_Bits, s_Cleanup);
  signal r_SM_Main : t_SM_Main := s_Idle;
 
  signal r_Bit_Index : integer range 0 to 5 := 5;  -- 6 Bits Total
  signal r_TX_Data   : std_logic_vector(5 downto 0) :="000000";	 -- MSB will be transimtted first !
  signal r_attenuation: std_logic_vector(5 downto 0) :="000000";
  signal r_TX_Done   : std_logic := '0';
  signal r_latch_Done : std_logic :='0';  
  signal r_LED_clk: std_logic :='0';
  signal r_Att_clk: std_logic :='0';
  ---------------------------------------------------------------------
  signal clk_SPI: std_logic :='0';
  signal scaler: integer:=0;
    
   
begin

----------------------------------------------------------------
-----------------------------------------------------------------
clk_SPI_process: process(i_clk)
	begin

			if(rising_edge(i_clk)) then
					scaler <= scaler+1;
				if (scaler=50) then				-- 6 bit transmittion will take 13 msec	   ( assuming 50 MHZ clock)
					scaler<=0;		
				end if; 
				if (scaler<30) then
					clk_SPI<='0';
					r_LED_clk <='0';
				else
					clk_SPI<='1';
				end if;
				if (scaler>40) then	
					r_LED_clk <='1';
				end if;	
			end if;
			o_LED_clk <= r_LED_clk;
		end process clk_SPI_process;

-----------------------------------------------------------------------
-----------------------------------------------------------------------

p_UART_TX : process (clk_SPI)
  begin
    if rising_edge(clk_SPI) then
         
      case r_SM_Main is
 
        when s_Idle =>
          	o_LEDTX_Serial <= '0';         -- Drive Line low for Idle
			r_latch_Done <='0';
          	r_Bit_Index <= 5;
			r_Att_clk <='0'; --o_Att_clk<='0';
 
          if i_TX_DV = '0' then
	  		  r_SM_Main <= s_TX_Data_Bits;  
          else
            r_SM_Main <= s_Idle;
          end if;
		-----------------------------------	        
        when s_TX_Data_Bits =>
			o_LEDTX_Serial <= r_TX_Data(r_Bit_Index);r_Att_clk<='1';       
		if r_Bit_Index > 0 then	 
				r_Bit_Index <= r_Bit_Index - 1;
              	r_SM_Main   <= s_Att_clk_Gen;
            else
              r_Bit_Index <= 5;
              r_SM_Main   <= s_Cleanup;
		end if;
 		 -------------------------------										
		 when s_Att_clk_Gen =>	 
			r_Att_clk <='0'; 
			r_SM_Main   <= s_TX_Data_Bits;
		--------------------------  
		when s_Cleanup =>
			r_Att_clk<='0';
			o_LEDTX_Serial <= '0';
			r_latch_Done   <= '1';	
        	r_SM_Main   <= s_Idle;           
        -------------------------
		when others =>
        	r_SM_Main <= s_Idle;
 
		end case;
    end if;	  
	
  end process p_UART_TX;
  o_Att_clk <= r_LED_clk and r_Att_clk;
  o_latch_Done <= r_latch_Done;
  o_RF_switch <=i_RF_switch;
  o_LED_RFswitch <= i_RF_switch;
  o_att_switch1 <= i_att_switch1;
  o_att_switch2 <= i_att_switch2;
  o_att_switch3 <= i_att_switch3;
  r_attenuation(5)<=i_att_switch1;
  r_attenuation(4)<=i_att_switch2;
  r_attenuation(3)<=i_att_switch3;
  
  r_TX_Data <= r_attenuation(5 downto 3) & r_TX_Data(2 downto 0);  --newest
  
  
end architecture RTL;
			 

