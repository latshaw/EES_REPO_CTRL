library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.all;

entity adc_data_acq is

port(	reset	:	in std_logic;
		clock	:	in std_logic;
		
		adc_init		:	in std_logic;
		bitslip_en	:	in std_logic;
		adc_dclk_p	:	in std_logic;
		adc_rx_in	:	in std_logic_vector(8 downto 0);
		
		adca_out		:	out std_logic_vector(15 downto 0);
		adcb_out		:	out std_logic_vector(15 downto 0);
		adcc_out		:	out std_logic_vector(15 downto 0);
		adcd_out		:	out std_logic_vector(15 downto 0);
		fclk_out		:	out std_logic_vector(7 downto 0);
		fclk_match	:	out std_logic;
		adc_pll_lock	:	out std_logic
		);
		

end entity adc_data_acq;

architecture behavior of adc_data_acq is

component adc_pll0 is
	port (
		rst      : in  std_logic                    := '0'; --    reset.reset
		refclk   : in  std_logic                    := '0'; --   refclk.clk
		locked   : out std_logic;                           --   locked.export
		lvds_clk : out std_logic_vector(1 downto 0);        -- lvds_clk.lvds_clk
		loaden   : out std_logic_vector(1 downto 0);        --   loaden.loaden
		outclk_2 : out std_logic                            --  outclk2.clk
	);
end component;	

component adc_lvds_rx is
		port (
			rx_in            : in  std_logic_vector(8 downto 0)  := (others => 'X'); -- export
			rx_out           : out std_logic_vector(71 downto 0);                    -- export
			rx_bitslip_reset : in  std_logic_vector(8 downto 0)  := (others => 'X'); -- export
			rx_bitslip_ctrl  : in  std_logic_vector(8 downto 0)  := (others => 'X'); -- export
			rx_bitslip_max   : out std_logic_vector(8 downto 0);                     -- export
			ext_fclk         : in  std_logic                     := 'X';             -- export
			ext_loaden       : in  std_logic                     := 'X';             -- export
			ext_coreclock    : in  std_logic                     := 'X';             -- export
			pll_areset       : in  std_logic                     := 'X'              -- export
		);
end component adc_lvds_rx;		




signal adc_pll_clk_data		:	std_logic;
signal adc_pll_lvds_bit		:	std_logic_vector(1 downto 0);
signal adc_pll_lvds_en		:	std_logic_vector(1 downto 0); 	

signal adc_data_out			:	std_logic_vector(71 downto 0);
signal adc_bitslip_reset	:	std_logic_vector(8 downto 0);
signal adc_bitslip			:	std_logic_vector(8 downto 0);
signal adc_bitslip_max		:	std_logic_vector(8 downto 0);

signal fclk_d					:	std_logic_vector(7 downto 0);
signal fclk_q					:	std_logic_vector(7 downto 0);
signal adcd_data_d			:	std_logic_vector(15 downto 0);	
signal adcd_data_q			:	std_logic_vector(15 downto 0);
signal adcc_data_d			:	std_logic_vector(15 downto 0);	
signal adcc_data_q			:	std_logic_vector(15 downto 0);
signal adcb_data_d			:	std_logic_vector(15 downto 0);	
signal adcb_data_q			:	std_logic_vector(15 downto 0);
signal adca_data_d			:	std_logic_vector(15 downto 0);	
signal adca_data_q			:	std_logic_vector(15 downto 0);
signal adc_pll_lock_d		:	std_logic;
signal adc_pll_lock_q		:	std_logic;
signal fclk_match_d			:	std_logic;
signal fclk_match_q			:	std_logic;
signal bitslip_in_d			:	std_logic_vector(1 downto 0);
signal bitslip_in_q			:	std_logic_vector(1 downto 0);
signal bitslip_go_d			:	std_logic;
signal bitslip_go_q			:	std_logic;
signal bitslip_ctrl_d		:	std_logic_vector(8 downto 0);
signal bitslip_ctrl_q		:	std_logic_vector(8 downto 0);

	
begin

adc_pllo_inst: adc_pll0
	port map (
		rst      	=> reset, --    reset.reset
		refclk   	=> adc_dclk_p,--   refclk.clk
		locked   	=>	adc_pll_lock_d,                           --   locked.export
		lvds_clk		=>	adc_pll_lvds_bit,        -- lvds_clk.lvds_clk
		loaden		=>	adc_pll_lvds_en,        --   loaden.loaden
		outclk_2		=>	adc_pll_clk_data                            --  outclk2.clk
	);

adc_lvds_rx_inst: adc_lvds_rx
		port map (
			rx_in            	=>	adc_rx_in, -- export
			rx_out           	=>	adc_data_out,	                    -- export
			rx_bitslip_reset 	=>	"000000000", -- export
			rx_bitslip_ctrl	=>	bitslip_ctrl_q, -- export
			rx_bitslip_max   	=>	adc_bitslip_max,                     -- export
			ext_fclk         	=>	adc_pll_lvds_bit(0),                                  -- export
			ext_loaden       	=>	adc_pll_lvds_en(0),             -- export
			ext_coreclock    	=>	adc_pll_clk_data,
			pll_areset       	=> reset              -- export
		);

fclk_d		<=	adc_data_out(71 downto 64);
adcd_data_d	<=	adc_data_out(63 downto 48);			
adcc_data_d	<=	adc_data_out(47 downto 32);
adcb_data_d	<=	adc_data_out(31 downto 16);
adca_data_d	<=	adc_data_out(15 downto 0);

fclk_out		<=	fclk_q;
adcd_out		<=	adcd_data_q;
adcc_out		<=	adcc_data_q;
adcb_out		<=	adcb_data_q;
adca_out		<=	adca_data_q;



process(clock, reset)
begin
			if(reset = '0') then
				adc_pll_lock_q		<=	'0';
				fclk_match_q		<=	'0';
				fclk_q			<=	(others =>'0');
				adcd_data_q			<=	(others => '0');
				adcc_data_q			<=	(others => '0');
				adcb_data_q			<=	(others => '0');
				adca_data_q			<=	(others => '0');
				bitslip_in_q		<=	(others => '0');
				bitslip_go_q		<= '0';
				bitslip_ctrl_q		<=	(others => '0');
			elsif(rising_edge(clock)) then
				adc_pll_lock_q		<=	adc_pll_lock_d;
				fclk_match_q		<=	fclk_match_d;
				fclk_q				<=	fclk_d;
				adcd_data_q			<=	adcd_data_d;
				adcc_data_q			<=	adcc_data_d;
				adcb_data_q			<=	adcb_data_d;
				adca_data_q			<=	adca_data_d;
				bitslip_in_q		<=	bitslip_in_d;
				bitslip_go_q		<=	bitslip_go_d;
				bitslip_ctrl_q		<=	bitslip_ctrl_d;
			end if;
end process;

bitslip_in_d(0)	<=	bitslip_en;
bitslip_in_d(1)	<=	bitslip_in_q(0);

bitslip_go_d		<=	bitslip_in_q(1) and not bitslip_in_q(0);

bitslip_ctrl_d		<=	(others => bitslip_go_q);



fclk_match_d	<=	'1' when fclk_q = x"ff" or fclk_q = x"00" else '0';
  			



end architecture behavior;