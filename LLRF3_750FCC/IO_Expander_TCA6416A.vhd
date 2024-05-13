
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity IO_Expander_TCA6416A is
	port(
	reset_n 			:in std_logic;
	clock				:in std_logic;

	a1_en				:in std_logic;

	a0_port0_dir	:in std_logic_vector(7 downto 0);
	a0_port1_dir	:in std_logic_vector(7 downto 0);
	a1_port0_dir	:in std_logic_vector(7 downto 0);
	a1_port1_dir	:in std_logic_vector(7 downto 0);

	a0_port0_in		:in std_logic_vector(7 downto 0);
	a0_port1_in		:in std_logic_vector(7 downto 0);
	a1_port0_in		:in std_logic_vector(7 downto 0);
	a1_port1_in		:in std_logic_vector(7 downto 0);

	a0_port0_out	:out std_logic_vector(7 downto 0);
	a0_port1_out	:out std_logic_vector(7 downto 0);
	a1_port0_out	:out std_logic_vector(7 downto 0);
	a1_port1_out	:out std_logic_vector(7 downto 0);

	scl				:out std_logic;
	sda				:inout std_logic
	);
end entity 	IO_Expander_TCA6416A;

architecture rtl of IO_Expander_TCA6416A is

-- I2C Controller Core
component i2c
port(
	reset_n	:in 		std_logic;
	clock		:in 		std_logic;

	start   	:in		std_logic;
	stop		:in 		std_logic;
	wren		:in		std_logic;
	rden		:in		std_logic;
	ack		:in		std_logic;
	wdata		:in 		std_logic_vector(7 downto 0);

	rdata		:out 		std_logic_vector(7 downto 0);
	rdready	:out		std_logic;
	busy		:out		std_logic;
	scl		:out 		std_logic;
	sda		:inout	std_logic
);
end component;

-- registers -----------------------------------------
type reg_type is record
	wdata 		:std_logic_vector(31 downto 0);
	rdata 		:std_logic_vector(31 downto 0);
	count 		:std_logic_vector(3 downto 0);
	init_cnt 	:std_logic_vector(15 downto 0);
	addr_cnt		:std_logic;
	dir			:std_logic_vector(31 downto 0);
end record reg_type;
signal D,Q	:reg_type;
------------------------------------------------------

-- port map signals ----------------------------------
signal start 	:std_logic;
signal stop 	:std_logic;
signal wren 	:std_logic;
signal rden 	:std_logic;
signal ack		:std_logic;
signal wdata 	: std_logic_vector(7 downto 0);
signal rdata 	: std_logic_vector(7 downto 0);
signal rdready :std_logic;
signal busy 	:std_logic;
------------------------------------------------------

signal rd_low 		:std_logic;
signal rd_high 	:std_logic;
signal load			:std_logic;
signal clear		:std_logic;
signal count_en 	:std_logic;
signal go			:std_logic;
signal port0_dir 	:std_logic_vector(7 downto 0);
signal port1_dir 	:std_logic_vector(7 downto 0);
signal port0_in 	:std_logic_vector(7 downto 0);
signal port1_in 	:std_logic_vector(7 downto 0);
signal command 	:std_logic_vector(4 downto 0);

-- state machine signals
type state_type IS (s1, s2, s3, s4);
signal present_state, next_state :state_type;

type std_logic_vector_array5 is array (natural range <>) of std_logic_vector(4 downto 0);
type std_logic_vector_array8 is array (natural range <>) of std_logic_vector(7 downto 0);

-- i2c command LUT (start,stop,wren,rden,ack)
constant CMD :std_logic_vector_array5(0 to 12) := (
-- write to direction control registers	-----------
"10100",  -- start , write
"00100",  -- write
"00100",  -- write
"01100",  -- stop , write
-- write to output registers ----------------------
"10100",  -- start , write
"00100",  -- write
"00100",  -- write
"01100",  -- stop , write
-- read input registers ---------------------------
"10100",  -- start, write
"00100",  -- write
"10100",  -- (re)start , write
"00011",  -- read , ack
"01010"); -- stop , read


-- TCA6416A command data
signal DATA :std_logic_vector_array8(0 to 12);


------------------------------------------------------
begin

U1 : i2c
	port map (
		reset_n => reset_n,
		clock => clock,
		start => start,
		stop  => stop,
		wren  => wren,
		rden  => rden,
		ack	  => ack,
		wdata => wdata,
		rdata => rdata,
		rdready => rdready,
		busy	=> busy,
		scl => scl,
		sda => sda
	);	

-- TCA6416A command data 
DATA <= (
	"010000" & Q.addr_cnt & '0', 	-- addr select , write
	x"06", 								-- register 6 (port 0 dir)
	port0_dir, 							-- port 0 dir
	port1_dir, 							-- port 1 dir

	"010000" & Q.addr_cnt & '0', 	-- addr select , write
	x"02", 								-- register 2 (port 0 output)
	port0_in, 							-- port 0 output
	port1_in, 							-- port 1 output

	"010000" & Q.addr_cnt & '0', 	-- addr select , write
	x"00", 								-- register 0 (port 0 input)
	"010000" & Q.addr_cnt & '1', 	-- addr select , read
	x"00", 								-- place holder 
	x"00");								-- place holder


-- command/data index counter
D.count <= (others => '0') when clear = '1'
				else "0000" when (Q.count = 12 and count_en = '1')
				else Q.count + 1 when count_en = '1'
				else Q.count;

-- toggle between chip 1 & 2 if enabled
D.addr_cnt <= '0' when a1_en = '0'
				else not Q.addr_cnt when next_state = s2 and Q.count = 12
				else Q.addr_cnt;

-- select input/direction data based on address
port0_dir 	<= Q.dir(7 downto 0) when Q.addr_cnt = '0' else Q.dir(15 downto 8);
port1_dir 	<= Q.dir(23 downto 16) when Q.addr_cnt = '0' else Q.dir(31 downto 24);
--port0_in 	<= Q.wdata(7 downto 0) when Q.addr_cnt = '0' else Q.wdata(15 downto 8);
port0_in 	<= Q.wdata(7 downto 0) when Q.addr_cnt = '0' else Q.wdata(23 downto 16);
--port1_in 	<= Q.wdata(23 downto 16) when Q.addr_cnt = '0' else Q.wdata(31 downto 24);
port1_in 	<= Q.wdata(15 downto 8) when Q.addr_cnt = '0' else Q.wdata(31 downto 24);

-- load dir/write/read data
D.dir <=  a1_port1_dir & a1_port0_dir & a0_port1_dir & a0_port0_dir when load = '1' else Q.dir;
D.wdata <=  a1_port1_in & a1_port0_in & a0_port1_in & a0_port0_in when load = '1' else Q.wdata;
D.rdata(7 downto 0) <= rdata when (rd_low = '1' and rdready = '1' and Q.addr_cnt = '0')
						else Q.rdata(7 downto 0);
D.rdata(15 downto 8) <= rdata when (rd_high = '1' and rdready = '1' and Q.addr_cnt = '0')
						else Q.rdata(15 downto 8);
D.rdata(23 downto 16) <= rdata when (rd_low = '1' and rdready = '1' and Q.addr_cnt = '1')
						else Q.rdata(23 downto 16);
D.rdata(31 downto 24) <= rdata when (rd_high = '1' and rdready = '1' and Q.addr_cnt = '1')
						else Q.rdata(31 downto 24);

a0_port0_out <= Q.rdata(7 downto 0);
a0_port1_out <= Q.rdata(15 downto 8);
a1_port0_out <= Q.rdata(23 downto 16);
a1_port1_out <= Q.rdata(31 downto 24);

-- reset init counter
D.init_cnt <= Q.init_cnt + 1 when Q.init_cnt < 65535 else Q.init_cnt;
go <= '1' when Q.init_cnt = 65535 else '0';

-- State Machine
process(present_state, next_state , go , busy)
begin
	case present_state is
		when s1 	=>	if go = '1' then
							next_state <= s2;
						else
							next_state <= s1;
						end if;

		when s2 	=>	next_state <= s3;

		when s3 	=>	next_state <= s4;

		when s4		=>  if busy = '0' then
							next_state <= s2;
						else 
							next_state <= s4;
						end if;
	end case;	
end process;

-- State Register
state_reg: process(clock,reset_n)
begin
	if (reset_n = '0') then
		present_state <= s1;
	elsif rising_edge(clock) then
		present_state <= next_state;
	end if;
end process state_reg;

--  State Machine Outputs
clear 	<= '1' when present_state = s1 else '0';
load 		<= '1' when present_state = s2 else '0';
count_en <= '1' when present_state = s3 else '0';
command 	<= CMD(to_integer(unsigned(Q.count))) when present_state = s3 else (others => '0');
(start, stop, wren, rden, ack ) <= std_logic_vector'(command);

wdata <= DATA(to_integer(unsigned(Q.count)));

rd_low 	<= '1' when Q.count = 12 else '0';
rd_high 	<= '1' when (Q.count = 0 and go = '1') else '0';

reg: process(reset_n,clock)
begin
	if reset_n = '0' then
		Q.wdata 		<= (others => '0');
		Q.rdata 		<= (others => '0');
		Q.count 		<= (others => '0');
		Q.init_cnt 	<= (others => '0');
		Q.addr_cnt 	<= '0';
		Q.dir  		<= (others => '0');
	elsif rising_edge(clock) then
		Q <= D;
	end if;
end process reg;			


end rtl;