library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--LIBRARY altera_mf;
--USE altera_mf.all;
--
--LIBRARY cycloneii;
--USE cycloneii.all;

entity epcs_cntl is
port(clock			: in std_logic;
	  reset			: in std_logic;
	  
--	  clk_14mhz		: out std_logic;
--	  epcs_rd		: out std_logic;
--	  addr_out		: out std_logic_vector(23 downto 0);
--	  epcs_wr		: out std_logic;
--	  data_in		: out std_logic_vector(7 downto 0);
--	  epcs_er		: out std_logic;
--	  epcs_wr_en	: out std_logic;
	  
--	  data_out		: in std_logic_vector(7 downto 0);
	  epcs_busy		: out std_logic;
	  address		: in std_logic_vector(31 downto 0);
	  data			: in std_logic_vector(7 downto 0);
	  cntl			: in std_logic_vector(3 downto 0);	  
	  result			: out std_logic_vector(7 downto 0);
	  fccid			:	out std_logic_vector(15 downto 0)
	  );
	  
end entity epcs_cntl;

architecture behavior of epcs_cntl is

signal clk_count		: std_logic_vector(2 downto 0);
signal clk_count_d	: std_logic_vector(2 downto 0);
signal clk_14mhz		:	std_logic;

signal go				: std_logic;
signal er				: std_logic;
signal rd				: std_logic;
signal wr				: std_logic;
signal wr_en			: std_logic;

signal epcs_rd			: std_logic;
signal addr_out		: std_logic_vector(31 downto 0);
signal epcs_wr			: std_logic;
signal data_in			: std_logic_vector(7 downto 0);
signal epcs_er			: std_logic;
signal epcs_wr_en		: std_logic;
	  
signal data_out		: std_logic_vector(7 downto 0);
signal epcs_busy_int	: std_logic;
signal addr_int		:	std_logic_vector(31 downto 0);
signal cntl_int		:	std_logic_vector(3 downto 0);	

signal epcs_addr_new	:	std_logic_vector(31 downto 0);

type state_type is (init, sync_clk, load, busy);
signal state			: state_type;

--component  altasmi_parallel0 IS 
--	 PORT 
--	 ( 
--		 addr	:	IN  STD_LOGIC_VECTOR (23 DOWNTO 0);
--		 busy	:	OUT  STD_LOGIC;
--		 clkin	:	IN  STD_LOGIC;
--		 data_valid	:	OUT  STD_LOGIC;
--		 datain	:	IN  STD_LOGIC_VECTOR (7 DOWNTO 0) := (OTHERS => '0');
--		 dataout	:	OUT  STD_LOGIC_VECTOR (7 DOWNTO 0);
--		 illegal_erase	:	OUT  STD_LOGIC;
--		 illegal_write	:	OUT  STD_LOGIC;
--		 rden	:	IN  STD_LOGIC;
--		 read	:	IN  STD_LOGIC := '0';
--		 reset	:	IN  STD_LOGIC := '0';
--		 sector_erase	:	IN  STD_LOGIC := '0';
--		 wren	:	IN  STD_LOGIC := '1';
--		 write	:	IN  STD_LOGIC := '0'
--	 );
--end component;

component epcs is
	port (
		addr          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- addr
		busy          : out std_logic;                                        -- busy
		clkin         : in  std_logic                     := 'X';             -- clk
		data_valid    : out std_logic;                                        -- data_valid
		datain        : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- datain
		dataout       : out std_logic_vector(7 downto 0);                     -- dataout
		illegal_erase : out std_logic;                                         -- illegal_erase
		illegal_write : out std_logic;                                        -- illegal_write
		rden          : in  std_logic                     := 'X';             -- rden
		read          : in  std_logic                     := 'X';             -- read
		reset         : in  std_logic                     := 'X';             -- reset
		sector_erase  : in  std_logic                     := 'X';             -- sector_erase
		wren          : in  std_logic                     := 'X';             -- wren
		write         : in  std_logic                     := 'X';             -- write		
		en4b_addr     : in  std_logic                     := 'X';             -- en4b_addr		
		sce           : in  std_logic_vector(2 downto 0)  := (others => 'X') -- sce
	);
end component epcs;	 

begin

fccid_rw_inst: entity work.fccid_rw
	port map(clock			=>	clock,
				reset			=>	reset,
				epcsc			=>	cntl,
				epcsa			=>	address,
				epcsb			=>	epcs_busy_int,
				epcsc_out	=>	cntl_int,
				epcsa_out	=>	addr_int,
				epcsr			=>	data_out,
				fccid			=>	fccid
				);




result		<= data_out;
data_in		<= data;
--addr_out		<= address;
addr_out		<= addr_int;

process(clock, reset)
begin
	if(reset = '0') then
		clk_count	<=	"000";
		clk_14mhz	<=	'0';
		epcs_er		<=	'0';
		epcs_wr		<=	'0';
		epcs_rd		<=	'0';
		epcs_wr_en	<=	'0';
		epcs_addr_new	<=	x"00af0000";		
	elsif(rising_edge(clock)) then
		clk_count	<=	clk_count_d;
		clk_14mhz	<=	clk_count(2);
		epcs_er		<=	er;
		epcs_wr		<=	wr;
		epcs_rd		<=	rd;
		epcs_wr_en	<=	wr_en;
		epcs_addr_new	<=	address;		
	end if;
end process;	
clk_count_d		<=	std_logic_vector(unsigned(clk_count) + 1);		

				
er		<= cntl_int(3) when state = load else '0';
wr		<= cntl_int(2) when state = load else '0';
rd		<= cntl_int(1) when state = load else '0';				
wr_en	<= (wr or er) when state = load else '0';				
go		<= cntl_int(0);

				
process(clock, reset)
begin
	if(reset = '0') then
		state <= init;
	elsif(rising_edge(clock)) then
		case state is
			
			when init		=> if go = '1' then state <= sync_clk;
									else state <= init;
									end if;
--			when init		=>	if go = '1' then
--										if epcs_addr_new = address then state	<=	init;
--										else state	<=	sync_clk;
--										end if;
--									else state	<=	init;
--									end if;	
								
			when sync_clk	=> if clk_count = "111" then state <= load;
									else state <= sync_clk;
									end if;
									
			when load		=> if clk_count = "111" then state <= busy;
									else state <= load;
									end if;
									
			when busy		=> if epcs_busy_int = '1' then state <= busy;
									else state <= init;
									end if;
									
			when others		=> state <= init;
		end case;
	end if;
end process;

altasmi_inst:  epcs 
	port map( 
				clkin				=>	clk_14mhz,
				read				=>	epcs_rd,
				rden				=>	epcs_rd,
				addr				=>	addr_out,
				write				=>	epcs_wr,
				datain			=>	data_in,
				sector_erase	=>	epcs_er,
				wren				=>	epcs_wr_en,
				reset				=>	'0',
				
				dataout			=>	data_out,
				busy				=>	epcs_busy_int,
				data_valid		=>	open,
				illegal_write	=>	open,
				illegal_erase	=>	open,
				en4b_addr		=>	'1',
				sce				=>	"000"	
			);
epcs_busy		<=	epcs_busy_int;			

end architecture behavior;
