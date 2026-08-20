--slim_txrx.vhd
--kludged together transceiver based on NANDLAND's RS232 example
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity slim_txrx is
	generic(
		--g_CLKS_PER_BIT : integer := 87     -- Needs to be set correctly
		CLK_FREQ : natural := 80e6;
		BAUD_RATE : natural := 921600
    );
	port(
		--System Clk
		CLK       : in  std_logic; --system clock
		--RX ports
		RX_IN : in  std_logic; --serial input line
		DOUT_VLD     : out std_logic; --indicates output data is valid
		DOUT   : out std_logic_vector(7 downto 0); --output data byte
		--TX ports
		DIN   : in  std_logic_vector(7 downto 0); --data input byte
		DIN_VLD     : in  std_logic; --drive high to start TX
		TX_Active : out std_logic; --High when busy
		TX_OUT : out std_logic; --Serial Output
		TX_Done   : out std_logic; --Goes high for one clock cycle to indicate completion
		--test port
		test_out : out std_logic_vector(30 downto 0)
		);
end entity slim_txrx;
architecture mixed of slim_txrx is
	--generate g_CLKS_PER_BIT
	constant g_CLKS_PER_BIT : natural := (CLK_FREQ / BAUD_RATE);
	--RX signals
	type t_SM_Main_R is (s_Idle_R, s_RX_Start_Bit, s_RX_Data_Bits,
                     s_RX_Stop_Bit, s_Cleanup_R);
	signal r_SM_Main_R : t_SM_Main_R := s_Idle_R;

	signal r_RX_Data_R : std_logic := '1';
	signal r_RX_Data   : std_logic := '1';

	signal r_Clk_Count_R : integer range 0 to g_CLKS_PER_BIT-1 := 0;
	signal r_Bit_Index_R : integer range 0 to 7 := 0;  -- 8 Bits Total
	signal r_RX_Byte   : std_logic_vector(7 downto 0) := (others => '0');
	signal r_RX_DV     : std_logic := '0';
	--TX signals
	type t_SM_Main is (s_Idle, s_TX_Start_Bit, s_TX_Data_Bits,
                     s_TX_Stop_Bit, s_Cleanup);
	signal r_SM_Main : t_SM_Main := s_Idle;

	signal r_Clk_Count : integer range 0 to g_CLKS_PER_BIT-1 := 0;
	signal r_Bit_Index : integer range 0 to 7 := 0;  -- 8 Bits Total
	signal r_TX_Data   : std_logic_vector(7 downto 0) := (others => '0');
	signal r_TX_Done   : std_logic := '0';
begin
	test_out <= std_logic_vector(to_unsigned(g_CLKS_PER_BIT,test_out'length));
--BEGIN RX
	-- Purpose: Double-register the incoming data.
	-- This allows it to be used in the UART RX Clock Domain.
	-- (It removes problems caused by metastabiliy)
	p_SAMPLE : process (CLK)
	begin
	if rising_edge(CLK) then
	  r_RX_Data_R <= RX_IN;
	  r_RX_Data   <= r_RX_Data_R;
	end if;
	end process p_SAMPLE;


	-- Purpose: Control RX state machine
	p_UART_RX : process (CLK)
	begin
	if rising_edge(CLK) then
		 
	  case r_SM_Main_R is

		when s_Idle_R =>
		  r_RX_DV     <= '0';
		  r_Clk_Count_R <= 0;
		  r_Bit_Index_R <= 0;

		  if r_RX_Data = '0' then       -- Start bit detected
			r_SM_Main_R <= s_RX_Start_Bit;
		  else
			r_SM_Main_R <= s_Idle_R;
		  end if;

		   
		-- Check middle of start bit to make sure it's still low
		when s_RX_Start_Bit =>
		  if r_Clk_Count_R = (g_CLKS_PER_BIT-1)/2 then
			if r_RX_Data = '0' then
			  r_Clk_Count_R <= 0;  -- reset counter since we found the middle
			  r_SM_Main_R   <= s_RX_Data_Bits;
			else
			  r_SM_Main_R   <= s_Idle_R;
			end if;
		  else
			r_Clk_Count_R <= r_Clk_Count_R + 1;
			r_SM_Main_R   <= s_RX_Start_Bit;
		  end if;

		   
		-- Wait g_CLKS_PER_BIT-1 clock cycles to sample serial data
		when s_RX_Data_Bits =>
		  if r_Clk_Count_R < g_CLKS_PER_BIT-1 then
			r_Clk_Count_R <= r_Clk_Count_R + 1;
			r_SM_Main_R   <= s_RX_Data_Bits;
		  else
			r_Clk_Count_R            <= 0;
			r_RX_Byte(r_Bit_Index_R) <= r_RX_Data;
			 
			-- Check if we have sent out all bits
			if r_Bit_Index_R < 7 then
			  r_Bit_Index_R <= r_Bit_Index_R + 1;
			  r_SM_Main_R   <= s_RX_Data_Bits;
			else
			  r_Bit_Index_R <= 0;
			  r_SM_Main_R   <= s_RX_Stop_Bit;
			end if;
		  end if;


		-- Receive Stop bit.  Stop bit = 1
		when s_RX_Stop_Bit =>
		  -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
		  if r_Clk_Count_R < g_CLKS_PER_BIT-1 then
			r_Clk_Count_R <= r_Clk_Count_R + 1;
			r_SM_Main_R   <= s_RX_Stop_Bit;
		  else
			r_RX_DV     <= '1';
			r_Clk_Count_R <= 0;
			r_SM_Main_R   <= s_Cleanup_R;
		  end if;

				   
		-- Stay here 1 clock
		when s_Cleanup_R =>
		  r_SM_Main_R <= s_Idle_R;
		  r_RX_DV   <= '0';

			 
		when others =>
		  r_SM_Main_R <= s_Idle_R;

	  end case;
	end if;
	end process p_UART_RX;

	DOUT_VLD   <= r_RX_DV;
	DOUT <= r_RX_Byte;
--END RX
--BEGIN TX
	p_UART_TX : process (CLK)
	begin
	if rising_edge(CLK) then
		 
	  case r_SM_Main is

		when s_Idle =>
		  --TX_Active <= '0';
		  TX_Active <= '1';
		  TX_OUT <= '1';         -- Drive Line High for Idle
		  r_TX_Done   <= '0';
		  r_Clk_Count <= 0;
		  r_Bit_Index <= 0;

		  if DIN_VLD = '1' then --DIN_VLD is set to 1 to indicate transmission ready
			r_TX_Data <= DIN; --latch data byte
			r_SM_Main <= s_TX_Start_Bit;
		  else
			r_SM_Main <= s_Idle;
		  end if;

		   
		-- Send out Start Bit. Start bit = 0
		when s_TX_Start_Bit =>
		  --TX_Active <= '1';
		  TX_Active <= '0';
		  TX_OUT <= '0';

		  -- Wait g_CLKS_PER_BIT-1 clock cycles for start bit to finish
		  if r_Clk_Count < g_CLKS_PER_BIT-1 then
			r_Clk_Count <= r_Clk_Count + 1;
			r_SM_Main   <= s_TX_Start_Bit;
		  else
			r_Clk_Count <= 0;
			r_SM_Main   <= s_TX_Data_Bits;
		  end if;

		   
		-- Wait g_CLKS_PER_BIT-1 clock cycles for data bits to finish          
		when s_TX_Data_Bits =>
		  TX_OUT <= r_TX_Data(r_Bit_Index);
		   
		  if r_Clk_Count < g_CLKS_PER_BIT-1 then
			r_Clk_Count <= r_Clk_Count + 1;
			r_SM_Main   <= s_TX_Data_Bits;
		  else
			r_Clk_Count <= 0;
			 
			-- Check if we have sent out all bits
			if r_Bit_Index < 7 then
			  r_Bit_Index <= r_Bit_Index + 1;
			  r_SM_Main   <= s_TX_Data_Bits;
			else
			  r_Bit_Index <= 0;
			  r_SM_Main   <= s_TX_Stop_Bit;
			end if;
		  end if;


		-- Send out Stop bit.  Stop bit = 1
		when s_TX_Stop_Bit =>
		  TX_OUT <= '1';

		  -- Wait g_CLKS_PER_BIT-1 clock cycles for Stop bit to finish
		  if r_Clk_Count < g_CLKS_PER_BIT-1 then
			r_Clk_Count <= r_Clk_Count + 1;
			r_SM_Main   <= s_TX_Stop_Bit;
		  else
			r_TX_Done   <= '1';
			r_Clk_Count <= 0;
			r_SM_Main   <= s_Cleanup;
		  end if;

				   
		-- Stay here 1 clock
		when s_Cleanup =>
		  --TX_Active <= '0';
		  TX_Active <= '1';
		  r_TX_Done   <= '1';
		  r_SM_Main   <= s_Idle;
		   
			 
		when others =>
		  r_SM_Main <= s_Idle;

	  end case;
	end if;
	end process p_UART_TX;

	TX_Done <= r_TX_Done;
--END TX
end mixed;