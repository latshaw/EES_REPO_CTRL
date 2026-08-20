--mbp_top_level.vhd
--contains modbus protocol code and
--UART communication
--
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
--
entity mbp_top_level is
	generic(
		CLK_FREQ	:	integer := 80000000;
		BAUD_RATE	:	natural := 921600;
		DEVICEADDR	:	natural := 0;
		HRTREGS	: natural := 106
	);
	port(
		CLK		:	in std_logic; --system clock input
		RESET	:	in std_logic; --active low
		RX_IN : in  std_logic; --serial input line
		REGS_DIN	: in std_logic_vector(15 downto 0);
		REGS_LD		: out std_logic;
		REGS_ADDR	: out std_logic_vector(15 downto 0);
		REGS_DOUT	: out std_logic_vector(15 downto 0);
		TX_OUT : out std_logic; --Serial Output
		ISA_ADDR_OUT : out std_logic_vector(7 downto 0);
		test_out : out std_logic_vector(30 downto 0)
	);
end mbp_top_level;
architecture mixed of mbp_top_level is
	component slim_txrx is
		generic(
			CLK_FREQ : natural := 80000000;
			BAUD_RATE : natural := 921600
		);
		port(
			CLK       : in  std_logic; --system clock
			--RX ports
			RX_IN : in  std_logic; --serial input line
			DOUT_VLD     : out std_logic; --indicates output data is valid
			DOUT   : out std_logic_vector(7 downto 0); --output data byte
			--TX ports
			DIN_VLD     : in  std_logic; --drive high to start TX
			DIN   : in  std_logic_vector(7 downto 0); --data input byte
			TX_Active : out std_logic; --High when busy
			TX_OUT : out std_logic; --Serial Output
			TX_Done   : out std_logic; --Goes high for one clock cycle to indicate completion
			test_out	: out std_logic_vector(30 downto 0)
			);
	end component slim_txrx;
	---
	component mbp is
	generic(
		CLK_FREQ	:	integer := 80000000;
		BAUD_RATE	:	natural := 921600;
		DEVICEADDR	:	natural := 0;
		HRTREGS	: natural := 106
		);
	port(
		CLK		:	in std_logic; --system clock input
		RESET	:	in std_logic; --active low
		--Serial UART Connections
		UART_DOUT_VLD	:	in std_logic;
		UART_DOUT	:	in std_logic_vector(7 downto 0);
		UART_DIN_RDY	:	in std_logic;
		OP_2_UART	: out std_logic_vector(7 downto 0);
		OP_VLD_2_UART	: out std_logic;
		--Reg Block Interface
		REGS_DIN	: in std_logic_vector(15 downto 0);
		REGS_LD		: out std_logic;
		REGS_ADDR	: out std_logic_vector(15 downto 0);
		REGS_DOUT	: out std_logic_vector(15 downto 0);
		ISA_ADDR_OUT	: out std_logic_vector(7 downto 0)
		);
	end component mbp;
	---
	signal s1,s2, s3, s4 : std_logic;
	signal a1, a2 : std_logic_vector(7 downto 0);
begin
	inst1 :slim_txrx 
		generic map(
				CLK_FREQ => CLK_FREQ,
				BAUD_RATE => BAUD_RATE
				)
		port map(
				CLK => CLK,
				RX_IN => RX_IN,
				DOUT_VLD => s1,
				DOUT => a1,
				DIN_VLD => s2,
				DIN => a2,
				TX_Active => s3,
				TX_OUT => TX_OUT,
				TX_Done => s4,
				test_out => test_out
				);
	---
	inst2 : mbp
		generic map(
				CLK_FREQ => CLK_FREQ,
				BAUD_RATE => BAUD_RATE,
				DEVICEADDR => DEVICEADDR,
				HRTREGS => HRTREGS
				)
		port map(
				CLK => CLK,
				RESET => RESET,
				UART_DOUT_VLD => s1,
				UART_DOUT => a1,
				UART_DIN_RDY => s3,
				OP_2_UART => a2,
				OP_VLD_2_UART => s2,
				REGS_DIN => REGS_DIN,
				REGS_LD => REGS_LD,
				REGS_ADDR => REGS_ADDR,
				REGS_DOUT => REGS_DOUT,
				ISA_ADDR_OUT => ISA_ADDR_OUT
				);
	---
end mixed;