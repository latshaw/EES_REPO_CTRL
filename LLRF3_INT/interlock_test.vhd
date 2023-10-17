library ieee;
use ieee.std_logic_1164.all;
use work.components.all;

entity interlock_test is
	port(clock : in std_logic;
		 reset : in std_logic;
		 
		 jmpr : in std_logic_vector(11 downto 0);
		 
		 isa_bale : in std_logic;
		 isa_aen : in std_logic;
		 isa_smemw : in std_logic;
		 isa_smemr : in std_logic;
		 isa_memw : in std_logic;
		 isa_memr : in std_logic;
		 isa_sbhe : in std_logic;
		 isa_reset : in std_logic;
		 isa_sa : in std_logic_vector(19 downto 0);
		 
		 fsd_cav : in std_logic_vector(7 downto 0);
		 
		 led : out std_logic_vector(3 downto 0);
		 
		 arc_test : out std_logic_vector(7 downto 0);
		 tmpwrm_test : out std_logic_vector(7 downto 0);
		 tmpcld_test : out std_logic_vector(7 downto 0);
		 
		 isa_sd : inout std_logic_vector(15 downto 0);
		 isa_sd_dir : out std_logic;
		 isa_memcs16 : out std_logic;
		 
		 flt_cav : out std_logic_vector(8 downto 0)
		 );
end entity interlock_test;

architecture behavior of interlock_test is


signal inp_led				: std_logic_vector(3 downto 0);
signal en_led				: std_logic;

signal en_tmptst			: std_logic;
signal tmp_test				: std_logic_vector(15 downto 0);

signal en_isa_sa			: std_logic;

signal isa_sa_out			: std_logic_vector(15 downto 0);







signal one					: std_logic;

begin

	one <= '1';

	flt_cav <= isa_aen & fsd_cav;
	
	isa_memcs16 <= isa_reset;
	
	arc_test <= jmpr(7 downto 0);
	
	
	
	
	test_isa_cntlr: regne
		generic map(n => 4) 
		port map(clock	=> clock, 	
				 reset	=> reset,	
				 clear	=> one,
				 en		=> en_led,		
				 input	=> inp_led,	
				 output	=> led
				);
	
	en_led <= '1' when jmpr(11 downto 8) = "1000" or jmpr(11 downto 8) = "0100" else '0';
				
	inp_led <= (isa_memr & isa_memw & isa_smemr & isa_smemw) when jmpr(11 downto 8) = "1000" else
			   isa_sa(19 downto 16) when jmpr(11 downto 8) = "0100" else
			   (others => '0');
			   
	test_isa_sd: regne
		generic map(n => 16) 
		port map(clock	=> clock, 	
				 reset	=> reset,	
				 clear	=> one,
				 en		=> en_tmptst,		
				 input	=> isa_sd,	
				 output	=> tmp_test
				);	
				
	en_tmptst <= '1' when jmpr(11 downto 8) = "1000" else '0';
	isa_sd_dir <= '1' when jmpr(11 downto 8) = "0100" else '0'; 
	tmpwrm_test <= tmp_test(15 downto 8);
	tmpcld_test <= tmp_test(7 downto 0);


	test_isa_sa: regne
		generic map(n => 16) 
		port map(clock	=> clock, 	
				 reset	=> reset,	
				 clear	=> one,
				 en		=> en_isa_sa,		
				 input	=> isa_sa(15 downto 0),	
				 output	=> isa_sa_out
				);
				
	isa_sd <= isa_sa_out when jmpr(11 downto 8) = "0100" else (others => 'Z'); 	
	
	en_isa_sa <= '1' when jmpr(11 downto 8) = "0100" else '0';



end architecture behavior;