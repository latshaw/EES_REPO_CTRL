		
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.components.all;
use work.all;

entity cyclone10gx_digitizer_main is
    Port ( clock 					: 	in std_logic;-----this is the 100 MHz user clock
			  
           reset 					: 	in std_logic;
			  m10_reset				:	in std_logic;
			  
			  dac_dco_p				:	in std_logic;			  			  	  
			  adc_dclk_p			:	in std_logic;
			  adc_data_in			:	in std_logic_vector(8 downto 0);--8fclk,7dd1,6dd0,5dc1,4dc0,3db1,2db0,1da1,0da0		
		
			  lmk04808_sda			:	out std_logic;
			  lmk04808_scl			:	out std_logic;           
			  --lmk04808_sda			:	inout std_logic; -- IF DEF old digitizer
			  --lmk04808_sda			:	out std_logic;    
			  lmk04808_ld			:	in std_logic;
			  lmk04808_hld			:	in std_logic;
			  ad9781_sdi			:	out std_logic;
			  ad9781_sdo			:	in std_logic;  -- not used
			  ad9781_rst			:	out std_logic;
			  ad9781_ncs			:	out std_logic;
			  ad9781_sclk			:	out std_logic;
			  ad9653_pwdn			:	out std_logic;
			  ad9653_ncs			:	out std_logic;
			  ad9653_sdio			:	out std_logic;
			  ad9653_sclk			:	out std_logic;
			  lmk04808_sync		:	out std_logic;
			  lmk04808_le  		:	out std_logic;
			  ad9653_sync			:	out std_logic;
			  --ad9653_sdio_dir		:	out std_logic;			  
			  dac_data_p			:	out std_logic_vector(13 downto 0);		  
			  dac_dci_p				:	out std_logic;			  			  		  
			  pwr_sync 				: 	out STD_LOGIC;
           pwr_en 				: 	out STD_LOGIC;
			  hb_fpga				:	out std_logic;
			  
			  --adding new phy code here IF DEF
			  ETH1_RESET_N       :  out std_logic;    -- SGMII active low reset
			  eth_mdio           : out std_logic;
			  eth_mdc            : out std_logic;
			  
			  fpga_ver				: in std_logic_vector(5 downto 0); -- c10 pmod 2 for REv - and later, misc connectors with some pulls ups for older versions
			  
			  
			  sfp_sda_0				:	inout std_logic;
			  sfp_scl_0				:	out std_logic;			  
			  sfp_refclk_p			:	in std_logic;			  
			  sfp_tx_0_p			:	out std_logic;
			  sfp_rx_0_p			:	in std_logic;
			  
			  dac_ncs				: 	out std_logic;
			  dac_sclk				:	out std_logic;
			  dac0_sdi				:	out std_logic;
			  dac1_sdi				:	out std_logic;
			  dac2_sdi				:	out std_logic;		
			  dac3_sdi				:	out std_logic;
			  adc0_sdo_a			:	in std_logic;
			  adc0_sdo_b			:	in std_logic;
			  adc0_ncs				:	out std_logic;
			  adc0_sclk				:	out std_logic;
			  adc0_sdi				:	out std_logic;
			  adc1_sdo_a			:	in std_logic;
			  adc1_sdo_b			:	in std_logic;
			  adc1_ncs				:	out std_logic;
			  adc1_sclk				:	out std_logic;
			  adc1_sdi				:	out std_logic;
			  fib_in					:	in std_logic_vector(3 downto 0);
			  fib_out				:	out std_logic_vector(3 downto 0);
			  dig_in					:	in std_logic_vector(2 downto 0); -- bit 2 is SSA permit
			  dig_out				:	out std_logic_vector(3 downto 0); -- bit 1 is Heater out, bit 2 is SSA enable
			  rfsw					:	out std_logic;
			  ratn_sclk				:	out std_logic;
			  ratn_le				:	out std_logic;
			  ratn_sdata			:	out std_logic;
			  
			  led_scl				:	out std_logic;
			  led_sda				:	inout std_logic;
				
			  
			  pmod_io				:	in std_logic_vector(5 downto 0);
			  jtag_mux_sel_out   :	out std_logic -- JTAG mux select '0' - C10 and M10, '1' for M10 only
--			  pll_rd_valid				:	out std_logic
			  
			  
			  );
end cyclone10gx_digitizer_main;

architecture behavioral of cyclone10gX_digitizer_main is

component adc_lvds_rx is
	port (
		rx_in            : in  std_logic_vector(8 downto 0)  := (others => '0'); --            rx_in.export
		rx_out           : out std_logic_vector(71 downto 0);                    --           rx_out.export
		rx_bitslip_reset : in  std_logic_vector(8 downto 0)  := (others => '0'); -- rx_bitslip_reset.export
		rx_bitslip_ctrl  : in  std_logic_vector(8 downto 0)  := (others => '0'); --  rx_bitslip_ctrl.export
		rx_bitslip_max   : out std_logic_vector(8 downto 0);                     --   rx_bitslip_max.export
		ext_fclk         : in  std_logic                     := '0';             --         ext_fclk.export
		ext_loaden       : in  std_logic                     := '0';             --       ext_loaden.export
		ext_coreclock    : in  std_logic                     := '0';
		ext_vcoph        : in  std_logic_vector(7 downto 0)  := (others => '0'); --        ext_vcoph.export 		--    ext_coreclock.export
		ext_pll_locked   : in  std_logic                     := '0';             --   ext_pll_locked.export
		pll_areset       : in  std_logic                     := '0';              --       pll_areset.export
		rx_dpa_locked    : out std_logic_vector(8 downto 0);                     --    rx_dpa_locked.export
		rx_dpa_hold      : in  std_logic_vector(8 downto 0)  := (others => '0'); --      rx_dpa_hold.export
		rx_dpa_reset     : in  std_logic_vector(8 downto 0)  := (others => '0')  --     rx_dpa_reset.export
	);
end component;
component adc_pll0 is
	port (
		rst      : in  std_logic                    := '0'; --    reset.reset
		refclk   : in  std_logic                    := '0'; --   refclk.clk
		locked   : out std_logic;                           --   locked.export
		phout		: out std_logic_vector(7 downto 0);
		lvds_clk : out std_logic_vector(1 downto 0);        -- lvds_clk.lvds_clk
		loaden   : out std_logic_vector(1 downto 0);        --   loaden.loaden
		outclk_2 : out std_logic                            --  outclk2.clk				
	);
end component;
component fpga_tsd_int is
	port (
		corectl : in  std_logic                    := 'X'; -- corectl
		reset   : in  std_logic                    := 'X'; -- reset
		tempout : out std_logic_vector(9 downto 0);        -- tempout
		eoc     : out std_logic                            -- eoc
	);
end component fpga_tsd_int;	

component dac_ddr is
	port (
		ck       : in  std_logic                     := '0';             --       ck.export
		datain_h : in  std_logic_vector(14 downto 0) := (others => '0'); -- datain_h.fragment
		datain_l : in  std_logic_vector(14 downto 0) := (others => '0'); -- datain_l.fragment
		dataout  : out std_logic_vector(14 downto 0)                     --  pad_out.export
	);
end component;




signal reset_n				:	std_logic;

signal rst_wait_cnt_q	:	std_logic_vector(27 downto 0);
signal rst_wait_cnt_d	:	std_logic_vector(27 downto 0);
signal en_rst_wait_cnt	:	std_logic;

signal pwr_sync_q			:	std_logic;
signal pwr_sync_d			:	std_logic;
signal pwr_en_q			:	std_logic;
signal pwr_en_d			:	std_logic;

signal hb_cntr_q			:	std_logic_vector(28 downto 0);
signal hb_cntr_d			:	std_logic_vector(28 downto 0);

signal dac_cnt_q			:	std_logic_vector(27 downto 0);
signal dac_cnt_d			:	std_logic_vector(27 downto 0);
signal en_dac_cnt			:	std_logic;
signal dac_rst_q			:	std_logic;
signal dac_rst_d			:	std_logic;
signal tx_en_d				:	std_logic;
signal tx_en_q				:	std_logic;
signal lmk_init_d, lmk_init_q			:	std_logic;

signal dac2_i_d, dac2_i_q				:	std_logic_vector(17 downto 0);
signal dac2_q_d, dac2_q_q				:	std_logic_vector(17 downto 0);
signal dac3_i_d, dac3_i_q				:	std_logic_vector(17 downto 0);
signal dac3_q_d, dac3_q_q				:	std_logic_vector(17 downto 0);
signal dac_test2, dac_test3			:	std_logic_vector(15 downto 0);
signal dac_data_in_h, dac_data_in_l	:	std_logic_vector(14 downto 0);
signal dac_ddr_data_out_p				:	std_logic_vector(14 downto 0); 

signal adca_out			:	std_logic_vector(15 downto 0);
signal adcb_out			:	std_logic_vector(15 downto 0);
signal adcc_out			:	std_logic_vector(15 downto 0);
signal adcd_out			:	std_logic_vector(15 downto 0);
signal fclk_out			:	std_logic_vector(7 downto 0);
signal adca_out_nodc			:	std_logic_vector(15 downto 0);
signal adcb_out_nodc			:	std_logic_vector(15 downto 0);
signal adcc_out_nodc			:	std_logic_vector(15 downto 0);
signal adcd_out_nodc			:	std_logic_vector(15 downto 0);

signal adc_pll_clk_data		:	std_logic;
signal adc_pll_lvds_bit		:	std_logic_vector(1 downto 0);
signal adc_pll_lvds_en		:	std_logic_vector(1 downto 0);
signal adc_pll_phout			:	std_logic_vector(7 downto 0);
signal adc_dpa_locked		:	std_logic_vector(8 downto 0);
signal adc_dpa_hold			:	std_logic_vector(8 downto 0);
signal adc_dpa_rst			:	std_logic_vector(8 downto 0);
signal adc_dpa_match			:	std_logic_vector(8 downto 0);

signal adc_ptrn_in			:	reg9_8;
signal adc_ptrn_tgt			:	reg9_8;
signal adc_bit_align_init	:	std_logic_vector(8 downto 0);
signal ad9653_tst_ptrn		:	std_logic;	 	
signal adc_data_out			:	std_logic_vector(71 downto 0);
signal adc_bitslip_reset	:	std_logic_vector(8 downto 0);
signal adc_bitslip			:	std_logic_vector(8 downto 0);
signal adc_bitslip_max		:	std_logic_vector(8 downto 0);
signal adc_lvds_lock_d		:	std_logic;
signal adc_lvds_lock_q		:	std_logic;
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

signal bitslip_cnt_d			:	std_logic_vector(4 downto 0);
signal bitslip_cnt_q			:	std_logic_vector(4 downto 0);

signal adc_data_in_int		:	std_logic_vector(8 downto 0);
signal adc_pll_reset			:	std_logic;

signal adc_fclk_in			:	std_logic;
signal altlvds_rst			:	std_logic;

signal adca0_data_d				:	std_logic_vector(7 downto 0);
signal adca1_data_d				:	std_logic_vector(7 downto 0);
signal adcb0_data_d				:	std_logic_vector(7 downto 0);
signal adcb1_data_d				:	std_logic_vector(7 downto 0);
signal adcc0_data_d				:	std_logic_vector(7 downto 0);
signal adcc1_data_d				:	std_logic_vector(7 downto 0);
signal adcd0_data_d				:	std_logic_vector(7 downto 0);
signal adcd1_data_d				:	std_logic_vector(7 downto 0);
signal adca0_data_q				:	std_logic_vector(7 downto 0);
signal adca1_data_q				:	std_logic_vector(7 downto 0);
signal adcb0_data_q				:	std_logic_vector(7 downto 0);
signal adcb1_data_q				:	std_logic_vector(7 downto 0);
signal adcc0_data_q				:	std_logic_vector(7 downto 0);
signal adcc1_data_q				:	std_logic_vector(7 downto 0);
signal adcd0_data_q				:	std_logic_vector(7 downto 0);
signal adcd1_data_q				:	std_logic_vector(7 downto 0);

signal prbi							:	std_logic_vector(15 downto 0);
signal prbq							:	std_logic_vector(15 downto 0);
signal prbi_ext					:	std_logic_vector(17 downto 0);
signal prbq_ext					:	std_logic_vector(17 downto 0);
signal prbm							:	std_logic_vector(17 downto 0);
signal prbp							:	std_logic_vector(17 downto 0);
signal fwdi							:	std_logic_vector(15 downto 0);
signal fwdq							:	std_logic_vector(15 downto 0);
signal fwdi_ext					:	std_logic_vector(17 downto 0);
signal fwdq_ext					:	std_logic_vector(17 downto 0);
signal fwdm							:	std_logic_vector(17 downto 0);
signal fwdp							:	std_logic_vector(17 downto 0);
signal refi							:	std_logic_vector(15 downto 0);
signal refq							:	std_logic_vector(15 downto 0);
signal refi_ext					:	std_logic_vector(17 downto 0);
signal refq_ext					:	std_logic_vector(17 downto 0);
signal refm							:	std_logic_vector(17 downto 0);
signal refp							:	std_logic_vector(17 downto 0);
signal rfri							:	std_logic_vector(15 downto 0);
signal rfrq							:	std_logic_vector(15 downto 0);
signal rfri_ext					:	std_logic_vector(17 downto 0);
signal rfrq_ext					:	std_logic_vector(17 downto 0);
signal rfrm							:	std_logic_vector(17 downto 0);
signal rfrp							:	std_logic_vector(17 downto 0);

signal iq, iq_flt, iq_sel		:	reg18_8;

signal spi_done_d					:	std_logic_vector(1 downto 0);
signal spi_done_q					:	std_logic_vector(1 downto 0);

signal ad9653_ncs_int			:	std_logic;
signal ad9781_spi_done			:	std_logic;

signal adc_align_done			:	std_logic_vector(8 downto 0);
signal ad9653_align_done		:	std_logic;
signal ad9653_spi_done			:	std_logic;
signal lmkconfig_done			:	std_logic;

signal adc_dclk_man				:	std_logic;
signal adc_align_done_d			:	std_logic;
signal adc_align_done_q			:	std_logic;
signal ld_adc_data				:	std_logic;


signal cirbuf_data_in			:	std_logic_vector(179 downto 0);

signal adc0_a						:	std_logic_vector(15 downto 0);
signal adc0_b						:	std_logic_vector(15 downto 0);
signal adc1_a						:	std_logic_vector(15 downto 0);
signal adc1_b						:	std_logic_vector(15 downto 0);



signal dac0_in						:	std_logic_vector(15 downto 0);
signal dac1_in						:	std_logic_vector(15 downto 0);
signal dac2_in						:	std_logic_vector(15 downto 0);
signal dac3_in						:	std_logic_vector(15 downto 0);
signal cdc_count_d, cdc_count_q	:	std_logic_vector(1 downto 0);

signal dac0_out						:	std_logic_vector(15 downto 0);
signal dac1_out						:	std_logic_vector(15 downto 0);
signal dac2_out						:	std_logic_vector(15 downto 0);
signal dac3_out						:	std_logic_vector(15 downto 0);

signal hb_dig						:	std_logic;
signal hb_ioc						:	std_logic;
signal led0_in						:	std_logic_vector(7 downto 0);
signal led1_in						:	std_logic_vector(7 downto 0);

signal cos_lut, sin_lut			:	std_logic_vector(17 downto 0);
signal lut_phs_d, lut_phs_q	:	std_logic_vector(25 downto 0);
signal lut_cnt_d, lut_cnt_q	:	integer range 0 to 185;
signal adc_cos_lut_d, adc_cos_lut	:	std_logic_vector(17 downto 0);
signal adc_sin_lut_d, adc_sin_lut	:	std_logic_vector(17 downto 0);

signal lut_phs_adc_d, lut_phs_adc_q		:	std_logic_vector(25 downto 0);
signal lut_cnt_adc_d, lut_cnt_adc_q		:	integer range 0 to 92;

signal deta							:	std_logic_vector(17 downto 0);
signal deta2						:	std_logic_vector(17 downto 0);
signal disc_freq					:	reg18_4;
signal disc_stp					:	std_logic_vector(27 downto 0);

--signal ratn							:	std_logic_vector(5 downto 0);
--signal rfon							:	std_logic;
signal c10gx_tmp					:	std_logic_vector(9 downto 0);

signal dac_mux_i					:	std_logic_vector(17 downto 0);
signal dac_mux_q					:	std_logic_vector(17 downto 0);
signal dac_mux_sel				:	std_logic_vector(2 downto 0);


signal lut_phs					:	std_logic_vector(31 downto 0);

signal wav_tst_cnt_d, wav_tst_cnt_q	:	std_logic_vector(17 downto 0);
signal fib_cnt_d, fib_cnt_q	:	integer range 0 to 19;

signal fltrd					:	reg16_18;
--signal frrmp					:	reg18_8;
signal fltrd_comm				:	std_logic_vector(143 downto 0);
signal frrmp_comm				:	std_logic_vector(143 downto 0);
signal prob_i_flt				:	std_logic_vector(17 downto 0);			
signal prob_q_flt				:	std_logic_vector(17 downto 0);			
signal prob_mag				:	std_logic_vector(17 downto 0);
signal prob_phs				:	std_logic_vector(17 downto 0);

signal ipid						:	std_logic_vector(17 downto 0);
signal qpid						:	std_logic_vector(17 downto 0);
signal gpid						:	std_logic_vector(17 downto 0);
signal ppid						:	std_logic_vector(17 downto 0);
signal gask						:	std_logic_vector(17 downto 0);
signal pask						:	std_logic_vector(17 downto 0);
signal i_out					:	std_logic_vector(17 downto 0);
signal q_out					:	std_logic_vector(17 downto 0);
signal xystat, xystat_rd	:	std_logic_vector(3 downto 0);
signal tdoff					:	std_logic_vector(17 downto 0);

signal iqpro					:	std_logic_vector(17 downto 0);
signal iqi						:	std_logic_vector(17 downto 0);
signal iqirate					:	std_logic_vector(17 downto 0);

signal mpro						:	std_logic_vector(17 downto 0);
signal mi						:	std_logic_vector(17 downto 0);
signal mirate					:	std_logic_vector(17 downto 0);
signal ppro						:	std_logic_vector(17 downto 0);
signal pi						:	std_logic_vector(17 downto 0);
signal pirate					:	std_logic_vector(17 downto 0);
signal xlimlo					:	std_logic_vector(17 downto 0);
signal xlimhi					:	std_logic_vector(17 downto 0);
signal ylimlo					:	std_logic_vector(17 downto 0);
signal ylimhi					:	std_logic_vector(17 downto 0);
signal gset						:	std_logic_vector(17 downto 0);
signal pset						:	std_logic_vector(17 downto 0);
signal iset						:	std_logic_vector(17 downto 0);
signal qset						:	std_logic_vector(17 downto 0);
--signal prmp						:	std_logic_vector(17 downto 0);
--signal prmpr					:	std_logic_vector(17 downto 0);
signal glos						:	std_logic_vector(17 downto 0);
--signal maglp					:	std_logic_vector(1 downto 0);
signal maglp_q					:	std_logic_vector(1 downto 0);
signal plos						:	std_logic_vector(17 downto 0);
--signal phslp					:	std_logic_vector(1 downto 0);
signal phslp_q					:	std_logic_vector(1 downto 0);
signal poff						:	std_logic_vector(17 downto 0);
signal cos_rot					:	std_logic_vector(17 downto 0);
signal sin_rot					:	std_logic_vector(17 downto 0);
signal xin_rot					:	std_logic_vector(17 downto 0);
signal yin_rot					:	std_logic_vector(17 downto 0);
signal i_rot					:	std_logic_vector(17 downto 0);
signal q_rot					:	std_logic_vector(17 downto 0);
signal phs_rot					:	std_logic_vector(17 downto 0);
--signal deta						:	std_logic_vector(17 downto 0);
signal cfqea					:	std_logic_vector(17 downto 0);
signal rfprm					:	std_logic;

signal fault_clear, fault_clear_100			:	std_logic;

signal xdrv						:	std_logic_vector(17 downto 0);
signal ydrv						:	std_logic_vector(17 downto 0);
signal pulse_out				:	std_logic;
signal prob_phs_spr			:	std_logic_vector(17 downto 0);
signal deta_stp				:	std_logic_vector(17 downto 0);
signal prob_i_cic				:	std_logic_vector(17 downto 0); 
signal prob_q_cic				:	std_logic_vector(17 downto 0);
signal strobei_clkd4			:	std_logic;
signal strobeq_clkd4			:	std_logic;
signal reset_clk_dom_xing	:	std_logic;


signal wavs_takei				:	std_logic;

signal gdcl						:	std_logic_vector(17 downto 0);
signal glos_kly				:	std_logic_vector(17 downto 0);
signal kly_ch					:	std_logic;

signal lmk_lock				:	std_logic_vector(1 downto 0);
signal lmk_ref					:	std_logic_vector(1 downto 0);
signal adc_dac_rst			:	std_logic;
signal lmk_lock_d, lmk_ref_d				:	std_logic;
signal lmk_reset_n			:	std_logic;
--signal pll_rd_valid			:	std_logic;



signal prbm_rd, prbp_rd		:	std_logic_vector(17 downto 0);
signal glow						:	std_logic_vector(17 downto 0);


signal regbank_0_in			:	reg16_18;
signal regbank_3_in			:	reg16_18;
signal regbank_0_out			:	std_logic_vector(17 downto 0);
signal regbank_1_out			:	std_logic_vector(17 downto 0);
signal regbank_mux_data		:	reg18_8;
signal reg_bank_addr			:	std_logic_vector(7 downto 0);
signal reg_addr				:	std_logic_vector(7 downto 0);
signal reg_data				:	std_logic_vector(17 downto 0);
signal reg_data_out			:	std_logic_vector(17 downto 0);

signal lb_clk					:	std_logic;
signal lb_valid				:	std_logic;
signal lb_rnw					:	std_logic;
signal lb_addr					:	std_logic_vector(23 downto 0);
signal lb_wdata				:	std_logic_vector(31 downto 0);
signal lb_renable				:	std_logic;
signal lb_rdata				:	std_logic_vector(31 downto 0);

signal wrreg_en				:	std_logic;
signal wrreg_addr				:	std_logic_vector(6 downto 0);
signal wrreg_addr_out		:	std_logic_vector(6 downto 0);
signal wrreg_data				:	std_logic_vector(17 downto 0);
signal wrreg_en_out			:	std_logic_vector(7 downto 0);
signal wrreg_data_out		:	reg18_8;
signal wrreg_en_out_buf		:	reg16_8;


--signal reg_rw_bank0			:	reg16_18;
--signal reg_rw_bank1			:	reg16_18;
--signal reg_rw_bank2			:	reg16_18;

signal reg_rw_bank			:	reg8_16_18;
signal regbank_in				:	reg16_16_18;

signal regbank_rd_data		:	reg16_18;

--alias gset 						: 	std_logic_vector(17 downto 0) is reg_rw_bank(0)(2);
--alias pset 						: 	std_logic_vector(17 downto 0) is reg_rw_bank(0)(3);
--alias mpro						:	std_logic_vector(17 downto 0) is reg_rw_bank(0)(9);
--alias mi							:	std_logic_vector(17 downto 0) is reg_rw_bank(0)(10);
--alias mirate					:	std_logic_vector(17 downto 0) is reg_rw_bank(0)(11);
--alias ppro						:	std_logic_vector(17 downto 0) is reg_rw_bank(0)(14);
--alias pi							:	std_logic_vector(17 downto 0) is reg_rw_bank(0)(15);
--
--alias pirate					:	std_logic_vector(17 downto 0) is reg_rw_bank(1)(0);
--alias glos						:	std_logic_vector(17 downto 0) is reg_rw_bank(1)(7);
--alias plos						:	std_logic_vector(17 downto 0) is reg_rw_bank(1)(8);
--alias gdcl						:	std_logic_vector(17 downto 0) is reg_rw_bank(1)(9);
--alias poff						:	std_logic_vector(17 downto 0) is reg_rw_bank(1)(11);
--
--alias tdoff						:	std_logic_vector(17 downto 0) is reg_rw_bank(2)(0);

--alias maglp						:	std_logic_vector(1 downto 0) is reg_rw_bank(3)(2)(2 downto 1);
--alias phslp						:	std_logic_vector(1 downto 0) is reg_rw_bank(3)(2)(4 downto 3);
--
--alias rfon						:	std_logic is reg_rw_bank(5)(1)(0);
--alias ratn						:	std_logic_vector(5 downto 0) is reg_rw_bank(5)(2)(5 downto 0);

signal rfon						:	std_logic;
signal rfon_int				:	std_logic;
signal rfon_en					:	std_logic;

signal ratn						:	std_logic_vector(5 downto 0);
signal maglp					:	std_logic_vector(1 downto 0);
signal phslp					:	std_logic_vector(1 downto 0);

--alias gpid						:	std_logic_vector(17 downto 0) is regbank_in(2)(9);
--alias ppid						:	std_logic_vector(17 downto 0) is regbank_in(2)(10);
--alias i_out						:	std_logic_vector(17 downto 0) is regbank_in(2)(11);
--alias q_out						:	std_logic_vector(17 downto 0) is regbank_in(2)(12);
--alias gask						:	std_logic_vector(17 downto 0) is regbank_in(2)(13);
--alias pask						:	std_logic_vector(17 downto 0) is regbank_in(2)(14);


--alias regbank_0_in	:	reg16_18 is fltrd;
--alias regbank_0_in(1)	:	std_logic_vector(17 downto 0) is qmesf;
--alias regbank_0_in(2)	:	std_logic_vector(17 downto 0) is gmes;
--alias regbank_0_in(3)	:	std_logic_vector(17 downto 0) is pmes;
--alias regbank_0_in(4)	:	std_logic_vector(17 downto 0) is crfpi;
--alias regbank_0_in(5)	:	std_logic_vector(17 downto 0) is crfpq;
--alias regbank_0_in(6)	:	std_logic_vector(17 downto 0) is crfp;
--alias regbank_0_in(7)	:	std_logic_vector(17 downto 0) is crfpp;
--alias regbank_0_in(8)	:	std_logic_vector(17 downto 0) is crrpi;
--alias regbank_0_in(9)	:	std_logic_vector(17 downto 0) is crrpq;
--alias regbank_0_in(10)	:	std_logic_vector(17 downto 0) is crrp;
--alias regbank_0_in(11	:	std_logic_vector(17 downto 0) is crrpp;
--alias regbank_0_in(12)	:	std_logic_vector(17 downto 0) is ifpwi;
--alias regbank_0_in(13)	:	std_logic_vector(17 downto 0) is ifpwq;
--alias regbank_0_in(14)	:	std_logic_vector(17 downto 0) is ifpwh;
--alias regbank_0_in(15)	:	std_logic_vector(17 downto 0) is ifpwp;
signal strobei_cic			:	std_logic;
signal strobeq_cic			:	std_logic;
--signal prob_i_cic				:	std_logic_vector(17 downto 0);
--signal prob_q_cic				:	std_logic_vector(17 downto 0);
signal strobei_fir			:	std_logic;
signal strobeq_fir			:	std_logic;
signal prob_i_fir				:	std_logic_vector(17 downto 0);
signal prob_q_fir				:	std_logic_vector(17 downto 0);
signal strobei_iir			:	std_logic;
signal strobeq_iir			:	std_logic;
signal strobe_mp_mux			:	std_logic;

signal wav_data_in			:	reg18_10;
signal wav_takei				:	std_logic;
signal wavstm					:	std_logic_vector(17 downto 0);
signal wav_data_out			:	reg18_10;
signal wavs_done				:	std_logic;

signal grmpr			:	std_logic_vector(15 downto 0);
signal prmpr			:	std_logic_vector(15 downto 0);
signal rmpctl			:	std_logic_vector(3 downto 0);
signal grmp				:	std_logic_vector(17 downto 0);
signal prmp				:	std_logic_vector(17 downto 0);
signal tone2iq			:	std_logic;
signal tone2iqgo		:	std_logic;
signal tone2iq_d		:	std_logic;
signal tone2iq_q		:	std_logic;

signal rfon_q			:	std_logic_vector(1 downto 0);
signal maglp_d			:	std_logic_vector(1 downto 0);
signal phslp_d			:	std_logic_vector(1 downto 0);
signal rfoff_on		:	std_logic;
signal mag_phs_lp_en	:	std_logic;
	
signal epcsb			:	std_logic;
signal cnfga			:	std_logic_vector(31 downto 0);
signal cnfgd			:	std_logic_vector(7 downto 0);
signal cnfgc			:	std_logic_vector(3 downto 0);
signal cnfgr			:	std_logic_vector(7 downto 0);
signal fccid			:	std_logic_vector(15 downto 0);

signal RHONPERD		:	std_logic_vector(15 downto 0);
signal RHPERD			:	std_logic_vector(15 downto 0);

-- 

signal xytmlim					:	std_logic_vector(17 downto 0);

signal gldeth			:  std_logic_vector(17 downto 0);
signal gldetl		   :	std_logic_vector(17 downto 0);
signal gdcltl			:	std_logic_vector(17 downto 0);
signal pldeth 		   :	std_logic_vector(17 downto 0);
signal pldetl			:	std_logic_vector(17 downto 0);
signal glde						:	std_logic_vector(17 downto 0);
signal plde						:	std_logic_vector(17 downto 0);

signal sftmsk			:	std_logic_vector(3 downto 0);	
signal rmpstat			:	std_logic_vector(1 downto 0);
signal beam_fsd_fib  : std_logic;


signal fault_clear_d			:	std_logic;
signal fault_clear_q			:	std_logic;
signal flt_clr_cnt_d			:	integer range 0 to 15;
signal flt_clr_cnt_q			:	integer range 0 to 15;
signal fib_stat				:	std_logic_vector(3 downto 0);
signal fib_msk_set			:	std_logic_vector(15 downto 0);

signal beam_fsd				:	std_logic_vector(1 downto 0);
signal sft_flt					:	std_logic_vector(7 downto 0);
signal sft_flt_q				:	std_logic_vector(7 downto 0);

signal sft_flt_edge_d		:	std_logic_vector(3 downto 0);
signal sft_flt_edge_q		:	std_logic_vector(3 downto 0);

signal ssa_prmt            : std_logic_vector(15 downto 0);
signal ssa_flt_latch_d, ssa_flt_latch_q				: std_logic;

-- remote firmware download singals
signal en_c_addr, en_c_cntl, en_c_data, en_c_bus_ctl : STD_LOGIC;
signal c10_status, c10_datar, lb_addr_r, rfwd_buf32, lb_rdata_rfwd, lb_rdata_mux, c_bus_ctl : STD_LOGIC_VECTOR(31 downto 0);

signal en_mdc_mdio : std_logic; -- older versions of the fpga have a different marvel chip which does NOT need to be configured. set this bit HI to enable writing to the marvel registers

signal fcc_id_state, fcc_id_state_p : std_logic_vector(3 downto 0);
signal addr_cnt_d, addr_cnt_q : unsigned(15 downto 0);
signal fccid_d, fccid_q : std_logic_vector(15 downto 0);
signal en_fcc_id : std_logic;



SIGNAL c_addr, c_addr_mux, c_addr_mux_d, c_addr_fccid_d, c_addr_fccid_q : STD_LOGIC_VECTOR(31 downto 0);

SIGNAL c_cntlr, c_cntlr_mux, c_cntlr_mux_d, c_cntlr_fccid_d, c_cntlr_fccid_q, c_data_mux, c_data_mux_d : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL c_data : STD_LOGIC_VECTOR(31 downto 0);
SIGNAL c_status : STD_LOGIC_VECTOR(31 downto 0); -- RO
SIGNAL c_datar : STD_LOGIC_VECTOR(31 downto 0); -- RO
signal lb_strb : STD_LOGIC;

signal jtag_mux_sel : std_logic;

--attribute noprune: boolean;
---- cyclone.v neded no prune signals
--attribute noprune of c_cntlr : signal is true;--
--attribute noprune of c_data : signal is true;--
--attribute noprune of c_status : signal is true;--
--attribute noprune of c_datar : signal is true;--
--attribute noprune of c_addr : signal is true;--
--attribute noprune of lb_strb : signal is true;--
--
---- end cyclone.v needed no prune signals
--attribute noprune of rfwd_buf32 : signal is true;
----attribute noprune of lb_rdata_mux : signal is true;
----attribute noprune of lb_rdata_rfwd : signal is true;
----attribute noprune of c_bus_ctl : signal is true;
----attribute noprune of c_cntlr_mux : signal is true;
----attribute noprune of c_addr_mux : signal is true;
----attribute noprune of en_fcc_id : signal is true;
----attribute noprune of c_addr_fccid_d, c_addr_fccid_q   : signal is true;
----attribute noprune of c_cntlr_fccid_d, c_cntlr_fccid_q : signal is true;
----attribute noprune of c_data_mux : signal is true;

signal lmk_count_q, lmk_count_d : unsigned(15 downto 0);

begin

-- ===============================================================
-- FSD fault control
-- ===============================================================
-- beam_permit_magphs will calculate glde and plde and pull beam fsd if fault exists
--
-- module will watch for pset/gset error to rise above limit set in epics
inst_beam_permit: entity work.beam_permit_magphs
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			strobe	=>	strobei_iir, -- was strobei_clkd4
			
			gset		=>	grmp, -- note this is the ramp which will eventually get to the set point
			gmes		=>	prob_mag,
			gldeth	=>	gldeth,   
			gldetl	=>	gldetl(15 downto 0),
				
			gask		=>	gpid, -- gask is after the clamp, we want to use gpid because this is before the clamp
			gdcl		=>	gdcl,
			gdcltl	=>	gdcltl(15 downto 0),
			
			pset		=>	prmp,
			pmes		=>	prob_phs,
			pldeth	=>	pldeth,
			pldetl	=>	pldetl(15 downto 0),
			xlimtm	=>	x"0000", -- was xytmlim(15 downto 0), not needed for separator
			xstathi	=>	'0', -- was xystat(1), note used
			sftmsk	=>	sftmsk, --xlimtm, gdcl,plde,glde (set 1 to mask fault)
			
			rfon		=>	rfon_q(1),					
			maglp		=>	maglp_q,
			phslp		=>	phslp_q,
			
			rmpstat	=>	rmpstat, --[1]phs_rmp, [0]grad_rmp
			
			flt_clr	=>	fault_clear,
			glde		=>	glde,
			plde		=>	plde,
			sft_flt	=>	sft_flt,
			beam_fsd	=>	beam_fsd
			);
			-- when glde or plde is ramping, we want to ignore those faults.
			rmpstat(0) <=	'0' when grmp = gset else '1'; -- ignore glde if ramping
			rmpstat(1) <=	'0' when prmp = pset else '1'; -- ignore plde if ramping
			--
			-- beam_fsd and sft_flt notes (how to know what tripped the FSD):
			--             STATUS  FAULT   Signal
			-- sft_flt bit 0       4       glde  
			-- sft_flt bit 1       5       plde  
			-- sft_flt bit 2       6       gdcl  
			-- sft_flt bit 3       7       xlim 

			regbank_in(1)(9)	  <=	glde;
			regbank_in(1)(10)   <=	plde;
			
			--x43 STAT2
			regbank_in(4)(3)(1)					<=	sft_flt_q(6);----gdcl fault
			regbank_in(4)(3)(0)					<=	sft_flt_q(2);
			regbank_in(4)(3)(11)					<= lmk04808_hld; --  MO status from LMK hold over functionality (1 means missing MO and using hold over) 
			regbank_in(4)(3)(10)					<=	lmk04808_ld;  --  MO status from LMK lock deteect (1 is good)
			--x44 STAT3
			regbank_in(4)(4)(17 downto 16)	<=	"00";
			regbank_in(4)(4)(15 downto 14)	<=	sft_flt_q(7)&sft_flt_q(3);
			regbank_in(4)(4)(13)					<=	xystat(0);
			regbank_in(4)(4)(12 downto 7)		<=	(others	=>	'0');
			regbank_in(4)(4)(6)					<=	sft_flt_q(5);------plde fault
			regbank_in(4)(4)(5)					<=	sft_flt_q(1);------plde fault
			regbank_in(4)(4)(4)					<=	'0';
			regbank_in(4)(4)(3)					<=	sft_flt_q(4);-----glde fault
			regbank_in(4)(4)(2)					<=	sft_flt_q(0);-----glde fault
			regbank_in(4)(4)(1 downto 0)		<=	(others	=>	'0');
			regbank_in(4)(5)(9)              <=	beam_fsd(1);-------fcc fsd out

			-- not needed for separator but adding in for completness
--			xlimlo		<=	reg_rw_bank(5)(11);
--			xlimhi		<=	reg_rw_bank(5)(12);
--			ylimlo		<=	reg_rw_bank(5)(13);
--			ylimhi		<=	reg_rw_bank(5)(14);
--			xytmlim		<=	reg_rw_bank(5)(15);
			
			gdcltl		<=	reg_rw_bank(6)(13);
			gldeth		<=	reg_rw_bank(6)(14);
			gldetl		<=	reg_rw_bank(6)(15);
			pldeth		<=	reg_rw_bank(7)(0);
			pldetl		<=	reg_rw_bank(7)(1);
			
			-- sftmsk is used to mask out the following faults [xlimtm,gdcl,plde,glde]
			-- order is: xlimtm (we set to be constantly masked for separator), gdcl,plde,glde
			-- gdcl -> CNTRL3 bit E (really bit 4)
			-- plde -> CNTRL4 BIT F (really bit 5)
			-- glde -> CNTRL4 bit E (really bit 4)
			sftmsk			<=	'1' & reg_rw_bank(3)(3)(4) & reg_rw_bank(3)(4)(5) & reg_rw_bank(3)(4)(4);
			
-- clock domain crossing from adc_pll_clk_data -> lb_clk (93 MHz-> 100 MHz)
--inst_clk_dom_xing : entity work.dpram_clkdom_xing
--port map(reset_n				=>	reset_n,
--			rdclock				=>	clock,                 -- udp clock, 100 MHz
--			wrclock				=>	adc_pll_clk_data,      -- 93 MHz clock
--			deta_stp_in			=>	x"0000",               --deta_stp(17 downto 2), -- detune angle
--			deta_disc_stp_in	=>	"000",                 --deta_disc_pzt,         -- stepper select([1..0]:deta=0, disc=1, pzt=2), [2] slow step)
--			disc_stp_in			=>	x"0000000",            --disc_stp,              -- 28 bit discriminator for stepper chassis
--			stpena_in			=>	fault_clear,                   --stpena_q,
--			beam_fsd_in			=>	beam_fsd(1),           -- beam permit signal
--			gmesstat_in			=>	'0',                   --gmesstat(1),
--			ratn_in				=>	"000000",              --ratn,  -- <<<<<< ************************* I think this is backwards. ratn needs to go from 125 to 93
--			deta_stp_out		=>	open,                  --deta_stp_fib,
--			deta_disc_stp_out	=>	open,                  --deta_disc_pzt_fib,
--			disc_stp_out		=>	open,                  --disc_stp_fib,
--			stpena_out			=>	fault_clear_100,                  --stpena_fib,
--			beam_fsd_out		=>	beam_fsd_fib,
--			gmesstat_out		=>	open,                   --gmesflt, <<<<<< ************************* is this needed for separator to kill SSA? isn't this captured in beam_fsd_fib?
--			ratn_out				=>	open                    --ratn_cdc-- <<<<<< ************************* Not used?
--			);	
			
			
fib_ctl_inst: entity work.fib_ctl -- Note, this is the 93 MHz version
port map(clock		=>	adc_pll_clk_data, -- 93 MHz clock domain
			reset		=>	reset_n,
			rfon		=>	beam_fsd(1),
			gmesflt	=>	'0',                -- gmesflt, set to HI to keep the hpa permit OFF.
			fibin		=>	fib_in(1 downto 0), --[1]interlock prmt in, [0] hpa prmt in
			fibmski	=>	fib_msk_set(1 downto 0),
			fibseto	=>	fib_msk_set(13 downto 12),
			fltclr	=>	fault_clear,        -- 93 MHz signal, buffer?
			rfprmt	=>	open,
			fibstat	=>	fib_stat,           --[3]intlk latch,[2]hpa latch,[1]intlk inst,[0]hpa inst 
			fibout	=>	fib_out(1 downto 0) --[1] fsd to interlocks/SSG, [0] hpa prmt out
			);

fib_msk_set					         <=	reg_rw_bank(3)(9)(15 downto 0);	
--regbank_in(4)(5)(5 downto 4)		<=	fib_stat(3 downto 2);
regbank_in(4)(5)(5 downto 4)		<=	fib_stat(3) & ssa_flt_latch_q; -- intlk latch and ssa prmt latch
regbank_in(4)(5)(3 downto 2)		<=	(others	=>	'0');
--regbank_in(4)(5)(1 downto 0)		<=	fib_stat(1 downto 0);
regbank_in(4)(5)(1 downto 0)		<=	fib_stat(1) & NOT(ssa_prmt(1)); -- intlk present and ssa prmt present (Low is no fault, HI is fault)

fault_clear_d		<=	'0' when flt_clr_cnt_q = 15 else
							reg_rw_bank(3)(3)(0) when wrreg_en_out_buf(3)(3) = '1' else
							fault_clear_q;
flt_clr_cnt_d	<=	0 when flt_clr_cnt_q = 15 else
						flt_clr_cnt_q + 1 when (wrreg_en_out_buf(3)(3) = '1' and reg_rw_bank(3)(3)(0) = '1' and flt_clr_cnt_q = 0) else
						flt_clr_cnt_q + 1 when flt_clr_cnt_q /= 0 else
						flt_clr_cnt_q;
fault_clear		<=	fault_clear_q;	
			
-- =============================================================== 
-- SSA interface
-- ===============================================================		 **************************** change to be 93 MHz clock
-- dig_in(2)  is for SSA permit
-- dig_out(2) is for SSA enable

-- handle SSA permit coming into FCC (from SSA). If the SSA permit goes away, then latch the fault, open RF switch.
process(adc_pll_clk_data, reset_n, fault_clear)
begin
	if(reset_n	=	'0') then
		ssa_prmt		    <= (others	=>	'0');
		ssa_flt_latch_q <= '0';
	elsif(rising_edge(adc_pll_clk_data)) then
			ssa_prmt        <= ssa_prmt(14 downto 0) & dig_in(2);
			ssa_flt_latch_q <= ssa_flt_latch_d;
	end if;
end process;

-- latch ssa permit fault if we see the SSA permit 'go away'
-- fault exists when ssa_flt_latch_q is HI
ssa_flt_latch_d <= '0' when fault_clear = '1' else
                   '1' when ssa_prmt=x"0000" and fib_msk_set(0)='0' else ssa_flt_latch_q;

regbank_in(4)(2)(8) <=	NOT(ssa_flt_latch_q); -- RF On Permit from SSA, HI is RF permit allowed, LOW is do not allow RF permit

--handle enable going to SSA
-- We will use the HPA ENa set to 1 to enable the SSA.
dig_out(2) <= fib_msk_set(12);

-- ===============================================================
-- heater pulse control
-- ===============================================================
-- dig_out(1) is for heater output

pulse_mode_sep_inst: entity work.pulse_mode_sep
	PORT MAP(clock	   => adc_pll_clk_data, -- changed to 93 MHz
			   reset    => reset_n,
			   pls_on	=> RHONPERD,     -- 16 bit, RHONPERD xF5
			   pls_perd	=> RHPERD,       -- 16 bit, RHPERD   xF6
				pls_out => dig_out(1));  -- PULSE OUT on read of FCC

			
			
-- ===============================================================
-- Diagnostic DAC loop back
-- ===============================================================

dac8831_inst_0 : entity work.dac8831
	PORT MAP(clock	=> clock,
			   reset => reset_n,
			   d_in	=> dac0_out,
			   ncs  => dac_ncs,
			   sclk => dac_sclk,
			   sdi  => dac0_sdi);
				
dac8831_inst_1 : entity work.dac8831				
	PORT MAP(clock	=> clock,
			   reset => reset_n,
			   d_in	=> dac1_out,
			   ncs  => open,
			   sclk => open,
			   sdi  => dac1_sdi);
				
dac8831_inst_2 : entity work.dac8831
	PORT MAP(clock	=> clock,
			   reset => reset_n,
			   d_in	=> dac2_out,
			   ncs  => open,
			   sclk => open,
			   sdi  => dac2_sdi);

dac8831_inst_3 : entity work.dac8831			
	PORT MAP(clock	=> clock,
			   reset => reset_n,
			   d_in	=> dac3_out,
			   ncs  => open,
			   sclk => open,
			   sdi  => dac3_sdi);
		
--IF DEF
-- ================================================================
-- MARVEL PHY INIT
-- ================================================================
-- 4/3/2024
-- FPGA board versions before REV1 have a marvel that does not need to have the mdio registers configured.
-- for the PRE REV1 boards, there are some pull ups on what I call the fpga_ver pins
-- FPGA board REV 1 and later we do need to configure the pins
-- for the REV1 boards, these are tired to C10 PMOD2. make sure these are never pulled up at power up.

en_mdc_mdio <= '0' when fpga_ver(5)= '1' or fpga_ver(4)= '1' or fpga_ver(3)= '1' or fpga_ver(2)= '1' or fpga_ver(1)= '1' or fpga_ver(0)= '1' else '1';


marvell_phy_config_inst : entity work.marvell_phy_config
	PORT MAP(
			clock	      => clock,
			reset	      => reset_n,
			en_mdc      => en_mdc_mdio,
			phy_resetn	=> ETH1_RESET_N,
			mdio	      => eth_mdio,
			mdc		   => eth_mdc,
			config_done	=>  open);

--lmk_reset_n				<=	reset and m10_reset and pmod_io(3);			
--reset_n					<=	reset and m10_reset and pmod_io(3) and not lmk_ref(0) and not lmk_lock(0);

lmk_reset_n				<=	reset and m10_reset;-- and pmod_io(3);			
reset_n					<=	reset and m10_reset;-- and pmod_io(3); removes push button
--
-- matching reset_all firmware module, without taking away PLL ayscn resets
-- aslo adding a wakeup delay timer
--process(clock, reset_n)
--begin
--	if(reset_n = '0') then
--		lmk_reset_n <= '0';
--		lmk_count_q <= (others =>'0');
--	elsif(rising_edge(clock)) then
--		if lmk_count_q >= x"0fff" then
--			lmk_count_q <= x"1fff";
--			lmk_reset_n <= '1';
--		else
--			lmk_count_q <= lmk_count_d;
--			lmk_reset_n <= '0';
--		end if;
--	end if;
--end process;
--
--lmk_count_d <= lmk_count_q + 1;

rst_wait_cnt_d		<=	std_logic_vector(unsigned(rst_wait_cnt_q) + 1) when en_rst_wait_cnt = '1' else 
							rst_wait_cnt_q;
en_rst_wait_cnt	<=	'1' when rst_wait_cnt_q /= (x"fffffff") else '0';
--pwr_sync_d			<=	'1' when rst_wait_cnt_q	> (x"0ffffff") else '0';
pwr_sync_d			<=	'1';
pwr_en_d				<=	'1';
--pwr_en_d				<=	'1' when rst_wait_cnt_q > (x"0ffffff") else '0';
lmk_init_d			<=	'1' when pwr_sync_q = '1' and rst_wait_cnt_q = (x"fffffff") else '0';

en_dac_cnt			<= '1' when pwr_sync_q = '1' and dac_cnt_q /= (x"fffffff") else '0';
dac_cnt_d			<=	std_logic_vector(unsigned(dac_cnt_q) + 1) when en_dac_cnt = '1' else
							dac_cnt_q;
dac_rst_d			<=	'1' when pwr_sync_q = '1' and dac_cnt_q < (x"0ffffff") else '0';
AD9781_rst			<=	dac_rst_q;
tx_en_d				<=	rfon;




pwr_sync				<=	pwr_sync_q;
pwr_en				<=	pwr_en_q;
hb_cntr_d			<=	std_logic_vector(unsigned(hb_cntr_q) + 1);


process(clock, lmk_reset_n)
begin
	if(lmk_reset_n = '0') then
		rst_wait_cnt_q	<=	(others => '0');
		hb_cntr_q		<=	(others => '0');
		pwr_sync_q		<=	'0';
		pwr_en_q			<=	'0';
		dac_cnt_q		<=	(others => '0');
		dac_rst_q		<= '0';
		lmk_init_q		<=	'0';
		lmk_lock(1)		<=	'0';
		lmk_ref(1)		<=	'0';
--		reset_n			<=	'0';			
	elsif(rising_edge(clock)) then
		rst_wait_cnt_q	<=	rst_wait_cnt_d;
		hb_cntr_q		<=	hb_cntr_d;
		pwr_sync_q		<=	pwr_sync_d;
		pwr_en_q			<=	pwr_en_d;
		dac_cnt_q		<=	dac_cnt_d;
		dac_rst_q		<=	dac_rst_d;
		lmk_init_q		<=	lmk_init_d;
		lmk_lock(1)		<=	lmk_lock_d;
		lmk_ref(1)		<=	lmk_ref_d;
--		reset_n			<=	not lmk_ref(0) and not lmk_lock(0);
		
	end if;
end process;


--pmod_io(5 downto 3)	<=	pmod_io(2 downto 0);


-----------------------adc_data_acq code-----------------------
adc_pll_reset	<=	not reset_n;-- 4/19/2024 attempting to get rid of neg slack on hold
	
adc_pllo_inst: adc_pll0
	port map (
		rst      => adc_pll_reset,                --    reset.reset
		refclk   => adc_dclk_p,                   --   refclk.clk
		locked   =>	adc_pll_lock_d,               --   locked.export
		phout		=>	adc_pll_phout,
		lvds_clk => adc_pll_lvds_bit(1 downto 0), -- lvds_clk.lvds_clk
		loaden   =>	adc_pll_lvds_en(1 downto 0),  --   loaden.loaden
		outclk_2 =>	adc_pll_clk_data              --  outclk2.clk		
	);

adc_lvds_lock_d	<=	adc_pll_lock_q and spi_done_q(1);


adc_lvds_rx_inst: adc_lvds_rx
		port map (
			rx_in            	=>	adc_data_in(8 downto 0), -- export
			rx_out           	=>	adc_data_out,	          -- export
			rx_bitslip_reset 	=>	"000000000",             -- export
			rx_bitslip_ctrl	=>	bitslip_ctrl_q,          -- export
			rx_bitslip_max   	=>	adc_bitslip_max,         -- export
			ext_fclk         	=>	adc_pll_lvds_bit(0),     -- export
			ext_loaden       	=>	adc_pll_lvds_en(0),      -- export
			ext_coreclock    	=>	adc_pll_clk_data,
			ext_vcoph			=>	adc_pll_phout,
			ext_pll_locked		=>	adc_lvds_lock_q,
			pll_areset       	=> adc_pll_reset,           -- export
			rx_dpa_locked    	=>	adc_dpa_locked,
			rx_dpa_hold      	=>	"000000000",
			rx_dpa_reset     	=>	"000000000"			
		);		

fclk_d							<=	adc_data_out(71 downto 64);
adcd_data_d(15 downto 8)	<=	adc_data_out(63 downto 56);
adcd_data_d(7 downto 0)		<=	adc_data_out(55 downto 48);			
adcc_data_d(15 downto 8)	<=	adc_data_out(47 downto 40);
adcc_data_d(7 downto 0)		<=	adc_data_out(39 downto 32);
adcb_data_d(15 downto 8)	<=	adc_data_out(31 downto 24);
adcb_data_d(7 downto 0)		<=	adc_data_out(23 downto 16);
adca_data_d(15 downto 8)	<=	adc_data_out(15 downto 8);
adca_data_d(7 downto 0)		<=	adc_data_out(7 downto 0);

adca0_data_d					<=	adca_data_q(7 downto 0);
adca1_data_d					<=	adca_data_q(15 downto 8);
adcb0_data_d					<=	adcb_data_q(7 downto 0);
adcb1_data_d					<=	adcb_data_q(15 downto 8);
adcc0_data_d					<=	adcc_data_q(7 downto 0);
adcc1_data_d					<=	adcc_data_q(15 downto 8);
adcd0_data_d					<=	adcd_data_q(7 downto 0);
adcd1_data_d					<=	adcd_data_q(15 downto 8);
------------------------------------------------------------------------------------------
					


fclk_out		<=	fclk_q;
adcd_out		<=	adcd_data_q;
adcc_out		<=	adcc_data_q;
adcb_out		<=	adcb_data_q;
adca_out		<=	adca_data_q;
altlvds_rst	<=	not adc_pll_lock_q;


process(adc_pll_clk_data, reset_n)
begin
			if(reset_n = '0') then
				adc_pll_lock_q		<=	'0';
				fclk_match_q		<=	'0';
				fclk_q				<=	(others =>'0');
				adcd_data_q			<=	(others => '0');
				adcc_data_q			<=	(others => '0');
				adcb_data_q			<=	(others => '0');
				adca_data_q			<=	(others => '0');
				bitslip_in_q		<=	(others => '0');
				adcd1_data_q		<=	(others => '0');				
				adcd0_data_q		<=	(others => '0');
				adcc1_data_q		<=	(others => '0');
				adcc0_data_q		<=	(others => '0');
				adcb1_data_q		<=	(others => '0');
				adcb0_data_q		<=	(others => '0');
				adca1_data_q		<=	(others => '0');
				adca0_data_q		<=	(others => '0');
				spi_done_q			<=	"00";
				adc_align_done_q	<=	'0';
				adc_pll_lock_q		<=	'0';
				adc_lvds_lock_q	<=	'0';
				adc_cos_lut			<=	(others	=>	'0');
				adc_sin_lut			<=	(others	=>	'0');
				maglp_q				<=	"00";
				phslp_q				<=	"00";
				reg_bank_addr		<=	(others	=>	'0');
				lut_phs_adc_q		<=	(others	=>	'0');
				lut_cnt_adc_q		<=	0;
				rfon_q				<=	"00";
				tone2iq_q			<=	'0';	
				fault_clear_q		<=	'0';
				flt_clr_cnt_q		<=	0;
				sft_flt_q			<=	(others	=>	'0');
				sft_flt_edge_q		<=	(others	=>	'0');
				jtag_mux_sel_out  <= '0';
			elsif(rising_edge(adc_pll_clk_data)) then
				adc_pll_lock_q		<=	adc_pll_lock_d;
				fclk_match_q		<=	fclk_match_d;
				fclk_q				<=	fclk_d;
				adcd_data_q			<=	adcd_data_d;
				adcc_data_q			<=	adcc_data_d;
				adcb_data_q			<=	adcb_data_d;
				adca_data_q			<=	adca_data_d;
				bitslip_in_q		<=	bitslip_in_d;
				adcd1_data_q		<=	adcd1_data_d;
				adcd0_data_q		<=	adcd0_data_d;
				adcc1_data_q		<=	adcc1_data_d;
				adcc0_data_q		<=	adcc0_data_d;
				adcb1_data_q		<=	adcb1_data_d;
				adcb0_data_q		<=	adcb0_data_d;
				adca1_data_q		<=	adca1_data_d;
				adca0_data_q		<=	adca0_data_d;
				spi_done_q			<=	spi_done_d;
				adc_align_done_q	<=	adc_align_done_d;
				adc_pll_lock_q		<=	adc_pll_lock_d;
				adc_lvds_lock_q	<=	adc_lvds_lock_d;
			
				adc_cos_lut			<=	adc_cos_lut_d;
				adc_sin_lut			<=	adc_sin_lut_d;
				maglp_q				<=	maglp_d;
				phslp_q				<=	phslp_d;
				reg_bank_addr		<=	reg_addr;
				lut_phs_adc_q		<=	lut_phs_adc_d;
				lut_cnt_adc_q		<=	lut_cnt_adc_d;
				rfon_q				<=	rfon_q(0)&rfon;
				tone2iq_q			<=	tone2iq_d;
				fault_clear_q		<=	fault_clear_d;
				flt_clr_cnt_q		<=	flt_clr_cnt_d;
				sft_flt_q			<=	sft_flt;
				sft_flt_edge_q		<=	sft_flt_edge_d;
				jtag_mux_sel_out	<=	jtag_mux_sel;
			end if;
end process;


fclk_match_d	<=	'1' when fclk_q = x"ff" or fclk_q = x"00" else '0';

hb_fpga			<=	hb_cntr_q(25);

ld_adc_data		<=	'1' when adc_align_done(7 downto 0) = x"ff" else '0';

adca_dc_flt: entity work.dc_reject
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			ld_data	=>	ld_adc_data,
			d_in		=>	adca_out,
			d_out		=>	adca_out_nodc
			);
adcb_dc_flt: entity work.dc_reject
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			ld_data	=>	ld_adc_data,
			d_in		=>	adcb_out,
			d_out		=>	adcb_out_nodc
			);
adcc_dc_flt: entity work.dc_reject
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			ld_data	=>	ld_adc_data,
			d_in		=>	adcc_out,
			d_out		=>	adcc_out_nodc
			);
adcd_dc_flt: entity work.dc_reject
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			ld_data	=>	ld_adc_data,
			d_in		=>	adcd_out,
			d_out		=>	adcd_out_nodc
			);
noniq_lut_prb: entity work.noniq_adc_lut
	 port map(clock	=>	adc_pll_clk_data,
				reset		=>	reset_n,
				d_in		=>	adca_out_nodc,
				sin_lut	=>	adc_sin_lut,
				cos_lut	=>	adc_cos_lut,
				i_out		=>	iq(0),
				q_out		=>	iq(1)
				);
noniq_lut_fwd: entity work.noniq_adc_lut
	 port map(clock	=>	adc_pll_clk_data,
				reset		=>	reset_n,
				d_in		=>	adcb_out_nodc,
				sin_lut	=>	adc_sin_lut,
				cos_lut	=>	adc_cos_lut,
				i_out		=>	iq(2),
				q_out		=>	iq(3)
				);
noniq_lut_rfl: entity work.noniq_adc_lut
	 port map(clock	=>	adc_pll_clk_data,
				reset		=>	reset_n,
				d_in		=>	adcc_out_nodc,
				sin_lut	=>	adc_sin_lut,
				cos_lut	=>	adc_cos_lut,
				i_out		=>	iq(4),
				q_out		=>	iq(5)
				);
noniq_lut_rfr: entity work.noniq_adc_lut
	 port map(clock	=>	adc_pll_clk_data,
				reset		=>	reset_n,
				d_in		=>	adcd_out_nodc,
				sin_lut	=>	adc_sin_lut,
				cos_lut	=>	adc_cos_lut,
				i_out		=>	iq(6),
				q_out		=>	iq(7)
				);
				
inst_frrmp: entity work.frrmp
port map(clock			=>	adc_pll_clk_data,
			reset			=>	reset_n,
			load			=>	'1',
			prob_i		=>	iq(2),
			prob_q		=>	iq(3),
			rflc_i		=>	iq(0),
			rflc_q		=>	iq(1),
			frwd_i		=>	iq(4),
			frwd_q		=>	iq(5),
			refr_i		=>	iq(6),
			refr_q		=>	iq(7),
			fltrd			=>	fltrd
--			frrmp			=>	frrmp
			);

--wav_data_gen_i: for i in 0 to 3 generate
--	wav_data_in(2*i)	<=	fltrd(4*i);
--	wav_data_in(2*i+1)	<=	fltrd(4*i+1);
--end generate;
wav_data_in(8)			<=	(others	=>	'0');	
wav_data_in(9)			<=	(others	=>	'0');
			
wav_data_in(0)	<=	fltrd(0);
wav_data_in(1)	<=	fltrd(1);
wav_data_in(2)	<=	fltrd(8);
wav_data_in(3)	<=	fltrd(9);
wav_data_in(4)	<=	fltrd(4);
wav_data_in(5)	<=	fltrd(5);
wav_data_in(6)	<=	fltrd(12);
wav_data_in(7)	<=	fltrd(13);

wav_takei		<=	reg_rw_bank(3)(1)(0);
jtag_mux_sel	<=	reg_rw_bank(3)(1)(3); -- MAX10/C10 JTAG chain control. set to '0' for default (C10 and M10 in chain) or set to '1' to just have M10 in chain.

-- Note, these are a different order than for 1497 FCC
-- 750    version: [0]--DRMP PAUSE, [1]--DRMP FORCE, [2]--PRMP PAUSE, [3]--PRMP FORCE	
-- pause = pause th eramp, force = skip ramping and assume final value
--**  1497   version is below: 
--rmpctl(3)		<=	reg_rw_bank(3)(1)(15);
--rmpctl(2)		<=	reg_rw_bank(3)(1)(13);
--rmpctl(0)		<=	reg_rw_bank(3)(1)(12);
--rmpctl(1)		<=	reg_rw_bank(3)(1)(8);
-- end 1497 version **


rmpctl(0)		<=	reg_rw_bank(3)(1)(8);
rmpctl(1)		<=	reg_rw_bank(3)(1)(12); 
rmpctl(2)		<=	reg_rw_bank(3)(1)(15);
rmpctl(3)		<=	reg_rw_bank(3)(1)(13);

---[0]--DRMP PAUSE, [1]--DRMP FORCE, [2]--PRMP PAUSE, [3]--PRMP FORCE	

cnfga(15 downto 0)		<=	reg_rw_bank(3)(11)(15 downto 0);
cnfga(31 downto 16)		<=	reg_rw_bank(3)(12)(15 downto 0);
cnfgd							<=	reg_rw_bank(3)(13)(7 downto 0);
cnfgc							<=	reg_rw_bank(3)(14)(3 downto 0);


wavstm			<=	reg_rw_bank(6)(9);


cirbuf_data_inst: entity work.cirbuf_data
port map(wrclock		=>	adc_pll_clk_data,
			rdclock		=>	lb_clk,
			reset			=>	reset_n,
		 
			takei			=>	wav_takei,
			strobe		=>	'1',
			rate			=>	wavstm,
			isa_addr_rd =>	lb_addr,
			data_in		=>	wav_data_in,
			data_out		=>	wav_data_out,
			
			buf_done		=>	wavs_done
			);			
			
--------------------------trip data waveforms---------------------

sft_flt_edge_d(0)		<=	sft_flt(0) and not sft_flt_q(0);-----glde edge
sft_flt_edge_d(1)		<=	sft_flt(1) and not sft_flt_q(1);-----plde edge
sft_flt_edge_d(2)		<=	sft_flt(2) and not sft_flt_q(2);-----gdcl edge
sft_flt_edge_d(3)		<=	sft_flt(3) and not sft_flt_q(3);-----xlim edge


--cirbuf_data_in(179 downto 162)	<=	deta2;
--cirbuf_data_in(161 downto 144)	<=	(others	=>	'0');
--cirbuf_data_in(143 downto 126)	<=	q_out;
--cirbuf_data_in(125 downto 108)	<=	i_out;
--cirbuf_data_in(107 downto 90)		<=	fltrd(3);
--cirbuf_data_in(89 downto 72)		<=	fltrd(2);
--cirbuf_data_in(71 downto 54)		<=	fltrd(5);
--cirbuf_data_in(53 downto 36)		<=	fltrd(4);
--cirbuf_data_in(35 downto 18)		<=	fltrd(1);
--cirbuf_data_in(17 downto 0)		<=	fltrd(0);

------------------------code blocks copied from llrf 2.0 fcc algorithm-------------




--iq_mp_gen_i: for i in 0 to 7 generate
--fltrd_comm(18*i+17 downto 18*i)	<=	fltrd(i);
--frrmp_comm(18*i+17 downto 18*i)	<=	fltrd(i+8);
--end generate;
--frrmp_comm(17 downto 0)		<=	prbm_rd;
--frrmp_comm(35 downto 18)	<=	prbp_rd;



inst_cic_i: entity work.cic(cic26_2_3)
port map(clock				=>	adc_pll_clk_data,
			reset				=>	reset_n,
			strobe_integ	=>	'1',
		--	strobe_dec		:	in std_logic;
			d_in				=>	iq(2),
			d_out				=>	prob_i_cic,
			strobe_out		=>	strobei_cic
			);
inst_cic_q: entity work.cic(cic26_2_3)
port map(clock				=>	adc_pll_clk_data,
			reset				=>	reset_n,
			strobe_integ	=>	'1',
		--	strobe_dec		:	in std_logic;
			d_in				=>	iq(3),
			d_out				=>	prob_q_cic,
			strobe_out		=>	strobeq_cic
			);			
inst_fir_lpf_i: entity work.firn
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			ld_in		=>	strobei_cic,	
			d_in		=>	prob_i_cic,
			d_out		=>	prob_i_fir,
			ld_out	=>	strobei_fir
			);
inst_fir_lpf_q: entity work.firn
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			ld_in		=>	strobeq_cic,	
			d_in		=>	prob_q_cic,
			d_out		=>	prob_q_fir,
			ld_out	=>	strobeq_fir
			);
inst_iir_lpf_i: entity work. iir_lpfk11
port map(clock 	=>	adc_pll_clk_data,
			reset 	=>	reset_n,
			load		=>	strobei_fir,
			d_in		=>	prob_i_fir,
			d_out		=>	prob_i_flt,
			ld_out	=>	strobei_iir
			);
inst_iir_lpf_q: entity work. iir_lpfk11
port map(clock 	=>	adc_pll_clk_data,
			reset 	=>	reset_n,
			load		=>	strobeq_fir,
			d_in		=>	prob_q_fir,
			d_out		=>	prob_q_flt,
			ld_out	=>	strobeq_iir
			);			
			
			
-- not needed for injector, but needed for separator since we want glde and plde
inst_iq2mp_18bit: entity work.iq2mp_18bit
port map(clock =>	adc_pll_clk_data,
			reset =>	reset_n,
			load	=>	strobei_iir,
			i 		=>	prob_i_flt,
			q	 	=>	prob_q_flt,	  
			mag 	=>	prob_mag,
			phs 	=>	prob_phs
			);
grad_phs_ramp_inst: entity work. grad_phs_rmp
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			strobe	=>	'1',
			dmes		=>	fltrd(2),
			pmes		=>	fltrd(3),
			dset		=>	gset,
			pset		=>	pset,
			drmpr		=>	grmpr,---DEFLECTION RAMP RATE
			prmpr		=>	prmpr,---PHASE RAMP RATE
			rfon		=>	rfon,
			gdr		=>	tone2iq_q,
			rmpctl	=>	rmpctl,---[0]--DRMP PAUSE, [1]--DRMP FORCE, [2]--PRMP PAUSE, [3]--PRMP FORCE		
			drmp		=>	grmp,
			prmp		=>	prmp,
			tone2iqgo		=>	tone2iqgo
			);




-- 4/22/24 added ramp rates for sep
gset_pset_iset_qset: entity work.mp2iq
port map(clock		=>	adc_pll_clk_data,
			reset 	=>	reset_n,
			load		=>	'1',
			mag 		=>	grmp, -- was gset
			phs_h		=>	prmp, -- was pset  
			phs_l		=>	x"00",
			i 			=>	iset,
			q 			=>	qset
			);
			
			
rfoff_on		<=	not rfon_q(0) and rfon_q(1);			
			
maglp_d(0)	<=	'0';
phslp_d(0)	<=	'0';

--wrreg_en_out_buf(3)(2)
sft_flt_edge_d(2)		<=	sft_flt(2) and not sft_flt_q(2);-----gdcl edge
-- three ways to switch mode: switch mode on screen changes, open switch, or press tone2iqgo OR GDCL rising edge of fault
mag_phs_lp_en	<=	wrreg_en_out_buf(3)(2) or rfoff_on or tone2iqgo or sft_flt_edge_q(2);

tone2iq			<=	reg_rw_bank(3)(2)(5);

--tone2iq_d		<=	tone2iq and (rfon_q(0)) and (not tone2iqgo) when mag_phs_lp_en = '1' else
--						tone2iq_q;
tone2iq_d		<=	tone2iq and (not rfoff_on) and (not tone2iqgo) when mag_phs_lp_en = '1' else
						tone2iq_q;						

maglp_d(1)	<=	(maglp(1) or tone2iqgo) and (not rfoff_on) and (not sft_flt_edge_q(2)) when mag_phs_lp_en = '1' else
					maglp_q(1);
phslp_d(1)	<=	(phslp(1) or tone2iqgo) and (not rfoff_on) and (not sft_flt_edge_q(2)) when mag_phs_lp_en = '1' else
					phslp_q(1);
				
				
			
			
			
inst_imes_pi_control: entity work.pi_control
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_iir,
			rfon		=>	rfon,
			mploop	=>	maglp_q,
			set		=>	iset,	
			mes		=>	prob_i_flt,
			pgain		=> iqpro(15 downto 0),
			igain		=>	iqi(15 downto 0),
			irate		=>	iqirate(15 downto 0),
			pi_out	=> ipid
			);

inst_qmes_pi_control: entity work.pi_control
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_iir,
			rfon		=>	rfon,
			mploop	=>	phslp_q,
			set		=>	qset,	
			mes		=>	prob_q_flt,
			pgain		=> iqpro(15 downto 0),
			igain		=>	iqi(15 downto 0),
			irate		=>	iqirate(15 downto 0),
			pi_out	=> qpid			
			);
			
iq2mp_pid: entity work. iq2mp_18bit
port map(clock 	=>	adc_pll_clk_data,
			reset 	=>	reset_n,
			load		=>	strobei_iir,
			i 			=>	ipid,
			q	 		=>	qpid,	  
			mag 		=>	gpid,
			phs 		=>	ppid
			);	  			
--inst_xylim: entity work.xylim
--port map(clock		=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			load		=>	strobei_iir,
--			xin		=>	gpid,
--			yin		=>	(others	=>	'0'),
--			xlimhi	=>	gdcl,
--			xlimlo	=>	(others	=>	'0'),
--			ylimhi	=>	(others	=>	'0'),
--			ylimlo	=>	(others	=>	'0'),
--			xout		=>	xdrv,
--			yout		=>	open,
--			xstat		=>	open,---[0]xlimlo,[1]xlimhi
--			ystat		=>	open----[2]ylimlo,[3]ylimhi
--			);
--i_out			<=	prob_i_flt when maglp_q = "01" and phslp_q = "01" else i_rot;
--q_out			<=	prob_q_flt when maglp_q = "01" and phslp_q = "01" else q_rot;

--inst_mp2iq: entity work.mp2iq
--port map(clock		=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			load		=> strobei_clkd4,
--			mag		=> "01"&x"ffff",
--			phs_h		=> phs_rot,
--			phs_l		=>	x"00",
--	  		i			=> cos_rot,
--			q			=> sin_rot
--			);
--inst_rotate: entity work.rotate_matrix
--port map(clock		=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			load		=>	strobei_clkd4,
--			xin		=>	xin_rot,
--			yin		=>	yin_rot,
--			cos		=>	cos_rot,
--			sin		=>	sin_rot,
--			xout		=>	i_rot,
--			yout		=>	q_rot
--			);
inst_loop_mux: entity work.mp_mux
port map(clock			=>	adc_pll_clk_data,
			reset_n		=>	reset_n,
			strobe		=>	strobei_iir,
			mag_lp		=>	maglp_q,
			phs_lp		=>	phslp_q,
			glos			=>	glos,
			gpid			=>	gpid,
			gdcl			=>	gdcl,
			poff			=>	poff,
			ppid			=>	ppid,
			gout			=>	xin_rot,
			pout			=>	phs_rot,
			strobe_out=>	strobe_mp_mux
			);	
--inst_loop_mux: entity work.loop_mux
--port map(clock			=>	adc_pll_clk_data,
--			reset			=>	reset_n,
--			load			=>	strobei_iir,
--			mag_lp		=>	maglp_q,
--			phs_lp		=>	phslp_q,
--			pulse_out	=>	open,
--			glos			=>	glos,
--			gdcl			=>	gdcl,
--			glos_kly		=>	(others	=>	'0'),
--			kly_ch		=>	'0',
--			gpid			=>	gpid,
--			gmes			=>	prob_mag,
--			plos			=>	plos,
--			pmes			=>	prob_phs,
--			ppid			=>	ppid,
--			poff			=>	poff,
--			xout			=>	xin_rot,
--			yout			=>	open,
--			phs			=>	phs_rot
--			);

inst_mp2iq: entity work.mp2iq
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=> strobe_mp_mux,
			mag		=> xin_rot,
			phs_h		=> phs_rot,
			phs_l		=>	x"00",
	  		i			=> i_out,
			q			=> q_out
			);			

inst_iq2mp_small_drv: entity work.iq2mp_18bit_small
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			i			=>	i_out,
			q 			=>	q_out,
			load		=>	open,
			m			=>	gask,
			p			=>	pask
			);

-------------------------------------------------rd mux and dpram for the readback registers-------------------

maglp			<= reg_rw_bank(3)(2)(2 downto 1);
phslp			<=	reg_rw_bank(3)(2)(4 downto 3);

-- rfon			<=	reg_rw_bank(5)(2)(0) AND NOT(ssa_flt_latch_q); -- 4/18/24 rf switch may ONLY be closed if SSA permit is good
-- 4/22/24, we want RF on state to clear of switch is opened for an FPGA initiated reason
-- with the below logic, if an SSA fault occurs, this will initiate the opening the RF switch from fimrware.
rfon_int			<=	reg_rw_bank(5)(2)(0) AND NOT(ssa_flt_latch_q); -- disable RF_on if ssa fault occurs
rfon_en			<=	wrreg_en_out_buf(5)(2) or ssa_flt_latch_q;     -- enable a write to the RF on register
rfon			   <=	rfon_int when rfon_en = '1' else					  -- if enabled, update the rfon bit, otherwise keep the current value
						rfon_q(0);

ratn			<=	reg_rw_bank(5)(3)(5 downto 0);


regbank_in(0)		<=	fltrd;


regbank_in(1)(0)	<=	prob_i_flt;
regbank_in(1)(1)	<=	prob_q_flt;
regbank_in(1)(2)	<=	fltrd(2);
regbank_in(1)(3)	<=	fltrd(3);
regbank_in(1)(4)	<=	grmp;
regbank_in(1)(5)	<=	iset;
regbank_in(1)(6)	<=	qset;
regbank_in(1)(7)	<=	"00"&x"0007"; 
regbank_in(1)(8)	<=	"00"&x"0008";
--regbank_in(1)(9)	<=	"00"&x"0009";
--regbank_in(1)(10)	<=	"00"&x"000a";
regbank_in(1)(11)	<=	"00"&x"000b";
regbank_in(1)(12)	<=	"00"&x"000c";
regbank_in(1)(13)	<=	"00"&x"000d";
regbank_in(1)(14)	<=	"00"&x"000e";
regbank_in(1)(15)	<=	"00"&x"000f";

--regbank_dummy_data_gen: for i in 2 to 7 generate
--	regbank_ro_data(i)	<=	(others	=>	'0');
--end generate;

regbank_in(2)(9)	<=	gpid;
regbank_in(2)(10)	<=	ppid;
regbank_in(2)(11)	<=	i_out;
regbank_in(2)(12)	<=	q_out;
regbank_in(2)(13)	<=	gask;
regbank_in(2)(14)	<=	pask;

grmpr						<=	reg_rw_bank(0)(0)(15 downto 0);
prmpr						<=	reg_rw_bank(5)(7)(15 downto 0);
gset 						<= reg_rw_bank(0)(2);
pset 						<= reg_rw_bank(0)(3);


iqpro						<=	reg_rw_bank(0)(4);
iqi						<= reg_rw_bank(0)(5);
iqirate					<= reg_rw_bank(0)(6);



mpro						<= reg_rw_bank(0)(9);
mi							<= reg_rw_bank(0)(10);
mirate					<= reg_rw_bank(0)(11);
ppro						<= reg_rw_bank(0)(14);
pi							<= reg_rw_bank(0)(15);

pirate					<= reg_rw_bank(1)(0);
glos						<= reg_rw_bank(1)(7);
plos						<= reg_rw_bank(1)(8);
gdcl						<= reg_rw_bank(1)(9);
poff						<= reg_rw_bank(1)(11);

tdoff						<= reg_rw_bank(2)(0);


regbank_in(3)(0)	<=	cfqea;
regbank_in(3)(1)	<=	deta;	

regbank_in(3)(7)	<=	"00"&adc0_a;			-- x37,  LOPWh 	  

-- on read ADC diagnostic dB9
-- SEP Notes CAVFLW. pins 1/6
-- SEP Notes CAVTMP, pins 2/7
-- SEP Notes HTRTMP, pins 3/8
           
regbank_in(3)(8)	<=	(not adc0_b(15))&(not adc0_b(15))&(not adc0_b(15))&adc0_b(14 downto 0);  --x38, RHTRTMP
regbank_in(3)(9)	<=	(not adc1_a(15))&(not adc1_a(15))&(not adc1_a(15))&adc1_a(14 downto 0);  --x39, RCAVTMP
regbank_in(5)(5)  <= (not adc1_b(15))&(not adc1_b(15))&(not adc1_b(15))&adc1_b(14 downto 0);  --x55, RCAVFLW

-- note, r/w start counting at x80, so reg_rw_bank(0)(0)
--dac0_out <= reg_rw_bank(2)(13)(15 downto 0);  -- xAD
--dac1_out <= reg_rw_bank(2)(14)(15 downto 0);  -- xAE
--dac2_out <= reg_rw_bank(2)(15)(15 downto 0);  -- xAF
--dac3_out <= reg_rw_bank(3)(0)(15 downto 0);   -- xB0

-- note, pin assignment is mirrored
dac3_out <= reg_rw_bank(2)( 9)(15 downto 0);  -- xA9, DACS1, pins 1/6
dac2_out <= reg_rw_bank(2)(10)(15 downto 0);  -- xAA, DACS2, pins 2/7
dac1_out <= reg_rw_bank(2)(11)(15 downto 0);  -- xAB, DACS3, pins 3/8
dac0_out <= reg_rw_bank(2)(12)(15 downto 0);  -- xAC, DACS4, pins 4/8


RHONPERD <= reg_rw_bank(7)(5)(15 downto 0); -- 16 bit, RHONPERD xF5
RHPERD	<= reg_rw_bank(7)(6)(15 downto 0); -- 16 bit, RHPERD   xF6


--regbank_in(3)(7)	<=	"00"&adc0_a;		             
--regbank_in(3)(8)	<=	adc0_b(15)&adc0_b(15)&adc0_b;  
--regbank_in(3)(9)	<=	adc1_a(15)&adc1_a(15)&adc1_a; 


regbank_in(3)(15)	<=	x"00"&c10gx_tmp;

regbank_in(4)(2)(17 downto 10)	<=	(others	=>	'0');
regbank_in(4)(2)(9)					<=	epcsb;
--regbank_in(4)(2)(8)					<=	'1';               -- bit 8 is the RF On permit
regbank_in(4)(2)(7 downto 1)		<=	(others	=>	'0');  
regbank_in(4)(2)(0)					<=	wavs_done;

regbank_in(4)(8)(17 downto 8)	<=	(others	=>	'0');
regbank_in(4)(8)(7 downto 0)	<=	cnfgr;


regbank_in(5)(3)	<=	"00"&fccid;
regbank_in(5)(4)	<=	prmp;

	
regbank_mux_i_gen: for i in 0 to 15 generate
regbank0_mux_i:entity work.rdmux16to1
	port map(clock	=>	adc_pll_clk_data,
			reset		=>	reset_n,
			data_in	=>	regbank_in(i),
			addr_in	=>	reg_addr(3 downto 0),
			data_out	=>	regbank_rd_data(i)
			);
end generate;

-------------------------
-- Blocks 8,9,A ALL registers
regbnk_rw_ro_gen_1: for i in 0 to 2 generate 
	regbank_in(i+8)(15 downto 0)		<=	reg_rw_bank(i)(15 downto 0);			
end generate;
--
-------------------------
-- Block B,                                                                                                        registers 0 through 1
regbank_in_gen_11_1: for i in 0 to 1 generate
	regbank_in(11)(i)			<=	reg_rw_bank(3)(i);
end generate;
regbank_in(11)(2)			<=	reg_rw_bank(3)(2)(17 downto 6) & tone2iq_q & phslp_q & maglp_q&reg_rw_bank(3)(2)(0); -- register  2
regbank_in(11)(3)			<=	reg_rw_bank(3)(3)(17 downto 1)&fault_clear_q;                                        -- register  3
regbank_in_gen_11_2: for i in 4 to 15 generate                                                                  -- registers 4 through 15
regbank_in(11)(i)			<=	reg_rw_bank(3)(i);
end generate;
-------------------------
-------------------------
-- Block C ALL registers
regbnk_rw_ro_gen_12: for i in 0 to 15 generate
	regbank_in(12)(i)		<=	reg_rw_bank(4)(i);			
end generate;
-------------------------
-------------------------
-- Block D,                                                               registers 0 and 1
regbank_in_gen_13_1: for i in 0 to 1 generate 
	regbank_in(13)(i)			<=	reg_rw_bank(5)(i);
end generate;
regbank_in(13)(2)			<=	reg_rw_bank(5)(2)(17 downto 1) & rfon_q(1); -- register  2
regbank_in_gen_13_2: for i in 3 to 15 generate                         -- registers 3 through 15
	regbank_in(13)(i)			<=	reg_rw_bank(5)(i);  
end generate;
-------------------------
-------------------------
-- Blocks E,F  ALL registers
regbnk_rw_ro_gen_3: for i in 6 to 7 generate
	regbank_in(i+8)(15 downto 0)		<=	reg_rw_bank(i)(15 downto 0);			
end generate;
-------------------------

--regbank1_mux_i:entity work.rdmux16to1
--	port map(clock	=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			data_in	=>	regbank_0_in,
--			addr_in	=>	reg_addr(3 downto 0),
--			data_out	=>	regbank_rd_data(1)
--			);
--
--regbank3_mux_i:entity work.rdmux16to1
--	port map(clock	=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			data_in	=>	regbank_3_in,
--			addr_in	=>	reg_addr(3 downto 0),
--			data_out	=>	regbank_rd_data(3)
--			);
--			
--
--
--regbank8_mux_i:entity work.rdmux16to1
--	port map(clock	=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			data_in	=>	reg_rw_bank(0),
--			addr_in	=>	reg_addr(3 downto 0),
--			data_out	=>	regbank_rd_data(8)
--			);
--regbank9_mux_i:entity work.rdmux16to1
--	port map(clock	=>	adc_pll_clk_data,
--			reset		=>	reset_n,
--			data_in	=>	reg_rw_bank(1),
--			addr_in	=>	reg_addr(3 downto 0),
--			data_out	=>	regbank_rd_data(9)
--			);

			

regbank_mux_i:entity work.rdmux16to1
	port map(clock	=>	adc_pll_clk_data,
			reset		=>	reset_n,
			data_in	=>	regbank_rd_data,
			addr_in	=>	reg_addr(7 downto 4),
			data_out	=>	reg_data
			);
			
dpram_rdreg_inst: entity work.dpram_rdreg
	port map(reset_n	=>	reset_n,
				rdclock	=>	lb_clk,
				wrclock	=>	adc_pll_clk_data,
				data_in	=>	reg_data,
				addr_in	=>	lb_addr(7 downto 0),
				addr_out	=>	reg_addr,
				data_out	=>	reg_data_out
				);
	

			
			

			
comms_regbank_inst: entity work. comms_regbank
--	generic(LB_AWI			:	integer := 24;
--			LB_DWI			:	integer	:=	32
--		);
	port map(reset				=>	reset_n,
				lb_clk			=>	lb_clk,
				lb_valid			=>	lb_valid,
				lb_rnw			=>	lb_rnw,
				lb_addr			=>	lb_addr,
				lb_wdata			=>	lb_wdata,
				lb_renable		=>	lb_renable,
				lb_rdata			=>	lb_rdata,
				
				wav_data			=>	wav_data_out,
				reg_data			=>	reg_data_out	
				);
			
		
dpram_wrreg_inst: entity work. dpram_wrreg
	port map(reset_n		=>	reset_n,
				rdclock		=>	adc_pll_clk_data,
				wrclock		=>	lb_clk,
				data_in		=>	lb_wdata(17 downto 0),
				addr_in		=>	lb_addr,
				lb_valid		=>	lb_valid,
				lb_rnw		=>	lb_rnw,
				wrreg			=>	wrreg_en,
				addr_out		=>	wrreg_addr,
				data_out		=>	wrreg_data
				);
				
wrreg_wrmuxstg1_inst: entity work. wrmux8to1
	port map(clock			=>	adc_pll_clk_data,
				reset			=>	reset_n,
				data_in		=>	wrreg_data,
				addr_in		=>	wrreg_addr,
				strobe		=>	wrreg_en,
				strobe_out	=>	wrreg_en_out,
				addr_out		=>	wrreg_addr_out,
				data_out		=>	wrreg_data_out
				);


wrreg_wrmux_gen_i: for i in 0 to 7 generate				
wrreg_wrmuxstg2_inst_i: entity work. wrmux16to1
	port map(clock			=>	adc_pll_clk_data,
				reset			=>	reset_n,
				data_in		=>	wrreg_data_out(i),
				addr_in		=>	wrreg_addr_out,
				strobe		=>	wrreg_en_out(i),
				strobe_out	=>	wrreg_en_out_buf(i),
				addr_out		=>	open,
				data_out		=>	reg_rw_bank(i)
				);
end generate;				

				

				
		


				


----------------ethernet communication module from berkeley------------------
inst_comms_top: entity work.comms_top
port map(clock				=>	clock,
			reset				=>	lmk_reset_n,
			ip_sel			=>	pmod_io(2 downto 0),
			sfp_sda_0		=>	sfp_sda_0,
			sfp_scl_0		=>	sfp_scl_0,
			
			lb_clk			=>	lb_clk,
			lb_valid			=>	lb_valid,
			lb_rnw			=>	lb_rnw,
			lb_addr			=>	lb_addr,  --output, EPICS -> HRT, what address is being written
			lb_wdata			=>	lb_wdata, -- output, EPICS -> HRT, what data is being written to the given address
			lb_renable		=>	lb_renable,
			lb_rdata			=>	lb_rdata, -- was lb_rdata, input EPICS <- HRT, HRT is supplying the requested readback at a given address
			


			sfp_refclk_p	=>	sfp_refclk_p,
			sfp_rx_0_p		=>	sfp_rx_0_p,
			sfp_tx_0_p		=>	sfp_tx_0_p	
			);
			
			

	
--================================================================ 
-- start cyclone rfwd specific
--================================================================ 	
-- cyclone specific remote firmware download (rfwd)
--
--	rfwd_wrapper_inst : entity work.rfwd_wrapper
--	port map( lb_clk			   =>  lb_clk,			
--			    adc_pll_clk_data =>  adc_pll_clk_data, 
--			    reset_n			   =>  reset_n,			  
--			    lb_valid         =>  lb_valid,         
--			    fccid            =>  fccid,            
--			    c_bus_ctl        =>  c_bus_ctl,        
--			    lb_addr          =>  lb_addr,          
--			    lb_wdata         =>  lb_wdata,         
--			    lb_rdata_rfwd    =>  lb_rdata_rfwd,    
--			    lb_rnw           =>  lb_rnw);

	-- this process muxes between our arbitrary register blocks
	-- x000000 to xEFFFFF is for HRT and waveforms
	-- xF00000 to xFFFFFF is for remote firmware download specific blocks (arbitary)
--	lb_rdata_mux <= lb_rdata_rfwd when c_bus_ctl = x"abcdefCC" else lb_rdata; -- don't delay read data if coming from 93MHz clock domain. 
	--
--================================================================ 
-- end cyclone rfwd specific
--================================================================ 	
			
-----------------pll lock and latch status---------------------
--lmk_lock_d	<=	'0' when fault_clear = '1' else
--					'1' when lmk_lock(0) = '1' else
--					lmk_lock(1);
--lmk_ref_d	<=	'0' when fault_clear = '1' else
--					'1' when lmk_ref(0) = '1' else
--					lmk_ref(1);					
			
-------------------------------------------configuring the clock to generate the clocks needed for adc, dac----			

lmk004808_spi_config: entity work.lmk04808			
port map(clock			=>	clock,   -- Note, We are now using the 100 MHz clock, vs v5 uses sfp_refclk_p
			reset			=>	lmk_reset_n,
			datauwire	=>	lmk04808_sda,
			clkuwire		=>	lmk04808_scl,
			leuwire		=>	lmk04808_le,
			sync			=>	lmk04808_sync,
			pll_rst		=>	lmkconfig_done
			);		

-- IF DEF,  old digitizer
--lmk03328_i2c_config: entity work.lmk03328_i2c
--port map(clock			=>	clock,
--			reset			=>	lmk_reset_n,
--			init_config	=> lmk_init_q,
--			sda			=>	lmk03328_sda,
--			scl			=>	lmk03328_scl,
--			clk_done		=>	lmkconfig_done
----			pll_lock		=>	open,
----			pll_ref		=>	open
----			pll_rd_valid	=>	pll_rd_valid
--			);
			
----------------initializing dac (ad9781)
ad9781_inst: entity work.ad9781
port map(clock		=>	clock,
			reset		=>	reset_n,
		
			spi_init	=>	lmkconfig_done,		
			nCS		=>	ad9781_ncs,
			sclk		=>	ad9781_sclk,		
			sdio		=>	ad9781_sdi,		
			spi_done	=>	open
			);			
			
			
-----------------------------intializing ad9653 with a test pattern for aligning the adc data---------------			
spi_done_d(1)			<=	spi_done_q(0);
spi_done_d(0)			<=	ad9653_spi_done;			
ad9653_spi_inst: entity work.ad9653
port map(clock		=>	clock,
			reset		=>	reset_n,		
			spi_init	=>	lmkconfig_done,
			adc_align_done	=>	ad9653_align_done,		
			nCS		=>	ad9653_ncs,
			sclk		=>	ad9653_sclk,
			sync		=>	ad9653_sync,  
			--pdwn		=>	ad9653_pwdn, -- IF DEF, old digitizer, now used for lmk04808
			sdio		=>	ad9653_sdio,
			--sdio_dir	=>	ad9653_sdio_dir, IF DEF old digitizer, not needed when using lmk04808
			spi_done	=>	ad9653_spi_done
			);
---------------dpa reset, pattern match and dpa hold---------
adc_ptrn_in(0)		<=	adca_data_q(7 downto 0);
adc_ptrn_in(1)		<=	adca_data_q(15 downto 8);
adc_ptrn_in(2)		<=	adcb_data_q(7 downto 0);
adc_ptrn_in(3)		<=	adcb_data_q(15 downto 8);
adc_ptrn_in(4)		<=	adcc_data_q(7 downto 0);
adc_ptrn_in(5)		<=	adcc_data_q(15 downto 8);
adc_ptrn_in(6)		<=	adcd_data_q(7 downto 0);
adc_ptrn_in(7)		<=	adcd_data_q(15 downto 8);
adc_ptrn_in(8)		<=	fclk_q;
adc_ptrn_tgt(0)	<=	x"9c";
adc_ptrn_tgt(1)	<=	x"a1";
adc_ptrn_tgt(2)	<=	x"9c";
adc_ptrn_tgt(3)	<=	x"a1";
adc_ptrn_tgt(4)	<=	x"9c";
adc_ptrn_tgt(5)	<=	x"a1";
adc_ptrn_tgt(6)	<=	x"9c";
adc_ptrn_tgt(7)	<=	x"a1";
adc_ptrn_tgt(8)	<=	x"f0";
 
dpa_ptrn_match_inst_gen_i: for i in 0 to 8 generate
--dpa_ptrn_match_i: dpa_ptrn_match
--	port map(
--				clock			=>	adc_pll_clk_data,	
--				reset			=>	reset,
--				dpa_locked	=>	adc_dpa_locked(i),
--				ptrn_in		=>	adc_ptrn_in(i),
--				ptrn_tgt		=>	adc_ptrn_tgt(i),
--				dpa_rst		=>	adc_dpa_rst(i),
--				dpa_hold		=>	adc_dpa_hold(i),
--				dpa_match	=>	adc_dpa_match(i)
--				);



adc_bit_align_inst: entity work.adc_bit_align
	port map(clock			=>	adc_pll_clk_data,
				reset			=>	reset_n,
				init_align	=>	adc_bit_align_init(i),
				frame_in		=>	adc_ptrn_in(i),
				frame_tgt	=>	adc_ptrn_tgt(i),
				bitslip_out	=>	bitslip_ctrl_q(i),
				align_done	=>	adc_align_done(i)
				);
end generate;

ad9653_align_done			<=	'1' when adc_align_done = "111111111" else '0';
adc_bit_align_gen_i: for i in 0 to 8 generate
adc_bit_align_init(i)	<=	adc_dpa_locked(i) and not adc_align_done(i);
end generate;
------------------mp2iq cordic for generating sine and cosine for dac------------------
dac_lut_cordic: entity work.mp2iq
port map(clock		=>	dac_dco_p,
			reset 	=>	reset_n,
			load		=>	'1',
			mag 		=>	"01"&x"ffff",
			phs_h		=>	lut_phs_q(25 downto 8),	  
			phs_l		=>	lut_phs_q(7 downto 0),
			i 			=>	cos_lut,
			q 			=>	sin_lut
			);
lut_phs_d	<=	(others	=>	'0') when lut_cnt_q = 185 else std_logic_vector(unsigned(lut_phs_q) + 25256024);
lut_cnt_d	<=	0 when lut_cnt_q = 185 else lut_cnt_q + 1;

------------------mp2iq cordic for generating sine and cosine for adc -----------------
adc_lut_cordic: entity work.mp2iq
port map(clock		=>	adc_pll_clk_data,
			reset 	=>	reset_n,
			load		=>	'1',
			mag 		=>	"01"&x"ffff",
			phs_h		=>	lut_phs_adc_q(25 downto 8),	  
			phs_l		=>	lut_phs_adc_q(7 downto 0),
			i 			=>	adc_cos_lut_d,
			q 			=>	adc_sin_lut_d
			);
lut_phs_adc_d	<=	(others	=>	'0') when lut_cnt_adc_q = 92 else std_logic_vector(unsigned(lut_phs_adc_q) + 50512048);
lut_cnt_adc_d	<=	0 when lut_cnt_adc_q = 92 else lut_cnt_adc_q + 1;



--dac2_i_d		<=	"00"&x"ffff";
--dac2_q_d		<=	"00"&x"00ff";
--
dac3_i_d		<=	"00"&x"0000";
dac3_q_d		<=	"00"&x"0000";

			


--adc_dac_cdc_inst: entity work. adc_dac_cdc
--port map(reset			=>	reset_n,
--			adc_clk		=>	adc_pll_clk_data,
--			dac_clk		=>	dac_dco_p,
--			strobe_in	=>	strobei_iir,
--			i_in			=>	i_out,
--			q_in			=>	q_out,
--			i_out			=>	dac2_i_d,
--			q_out			=>	dac2_q_d,
--			strobe_out	=>	open
--			);
--==================================================================
-- Adding clock domain crossing from 93 MHz to 186 MHz
--==================================================================
-- 4/19/2020
-- i_out and q_out are running at adc_pll_clk_data


dpram_adc_dac_clkdom_xing_inst : entity work.dpram_adc_dac_clkdom_xing
		port map (
			reset_n => reset_n,
			rdclock => dac_dco_p,
			wrclock => adc_pll_clk_data,
			i_in => i_out,
			q_in => q_out,
			i_out => dac2_i_d,
			q_out => dac2_q_d);

-- was below on 4/19/2020
--cdc_count_d	<=	std_logic_vector(unsigned(cdc_count_q) + 1); -- dac_dco_p clock
--dac2_i_d			<=	i_out when cdc_count_q(0) = '0' else dac2_i_q;
--dac2_q_d			<=	q_out when cdc_count_q(0) = '0' else dac2_q_q;
-- older below
--dac3_i_d			<=	i_out when cdc_count_q(0) = '0' else dac3_i_q;
--dac3_q_d			<=	q_out when cdc_count_q(0) = '0' else dac3_q_q;

--==================================================================

process(dac_dco_p, reset_n)
begin
	if(reset_n	= '0') then
		dac2_i_q			<=	(others 	=> '0');
		dac2_q_q			<=	(others 	=> '0');
		dac3_i_q			<=	(others 	=> '0');
		dac3_q_q			<=	(others 	=> '0');
		cdc_count_q		<=	(others	=>	'0');
		lut_phs_q		<=	(others	=>	'0');
		lut_cnt_q		<=	0;
		tx_en_q			<= '0';
	elsif(rising_edge(dac_dco_p)) then
		dac2_i_q		<=	dac2_i_d;
		dac2_q_q		<=	dac2_q_d;
		dac3_i_q		<=	dac3_i_d;
		dac3_q_q		<=	dac3_q_d;
		cdc_count_q	<=	cdc_count_d;
		lut_phs_q	<=	lut_phs_d;
		lut_cnt_q	<=	lut_cnt_d;
		tx_en_q			<= tx_en_d;	
	end if;
end process;
							
noniq_dac_186mhz_inst0: entity work.noniq_dac186MHz
port map(clock		=>	dac_dco_p,
			reset		=>	reset_n,
			tx_en		=> tx_en_q,
			i_in		=> dac2_i_q(17 downto 2),
			q_in		=> dac2_q_q(17 downto 2),
			sin_lut	=>	sin_lut,
			cos_lut	=>	cos_lut,
			d_out		=> dac_test2
			);
noniq_dac_186mhz_inst1: entity work.noniq_dac186MHz
port map(clock		=>	dac_dco_p,
			reset		=>	reset_n,
			tx_en		=> tx_en_q,
			i_in		=> dac3_i_q(17 downto 2),
			q_in		=> dac3_q_q(17 downto 2),
			sin_lut	=>	sin_lut,
			cos_lut	=>	cos_lut,
			d_out		=> dac_test3
			);	
dac_data_in_h(14)				<=	'1';
dac_data_in_h(13 downto 0)	<=	dac_test2(15 downto 2);
dac_data_in_l(14)				<=	'0';
dac_data_in_l(13 downto 0)	<=	dac_test3(15 downto 2);
dac_ddr_inst: dac_ddr
port map(ck       =>	dac_dco_p,
			datain_h =>	dac_data_in_h,
			datain_l =>	dac_data_in_l,
			dataout  =>	dac_ddr_data_out_p
		);	

dac_dci_p	<=	dac_ddr_data_out_p(14);
dac_data_p	<= dac_ddr_data_out_p(13 downto 0);


	


---------------------diag adc code------------------------
adc0_inst: entity work.ads8353
port map(clock 	=>	adc_pll_clk_data,
			nreset 	=>	reset_n,
			sdo_a 	=>	adc0_sdo_a,--dig_a(11),
			sdo_b 	=>	adc0_sdo_b,--dig_a(12),
			ncs 		=>	adc0_ncs,--dig_a(17),
			sclk 		=>	adc0_sclk,--dig_a(18),
			sdi 		=>	adc0_sdi,--dig_a(16),
			data_cha =>	adc0_a,
			data_chb =>	adc0_b
			);
adc1_inst: entity work.ads8353
port map(clock 	=>	adc_pll_clk_data,
			nreset 	=>	reset_n,
			sdo_a 	=>	adc1_sdo_a,--dig_a(9),
			sdo_b 	=>	adc1_sdo_b,--dig_a(10),
			ncs 		=>	adc1_ncs,--dig_a(14),
			sclk 		=>	adc1_sclk,--dig_a(15),
			sdi 		=>	adc1_sdi,--dig_a(13),
			data_cha =>	adc1_a,
			data_chb =>	adc1_b
			);
			

-----------------------diag led code------------------------
hb_inst: entity work.heartbeat
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
	  	  	hb_dig	=>	hb_dig,
			hb_ioc	=>	hb_ioc
			);
led0_in(0)	<=	hb_ioc;
led0_in(1)	<=	hb_dig;
led0_in(2)	<=	rfon;
led0_in(3)	<=	lmk_lock(1) or lmk_ref(1);
led0_in(4)	<=	'0';
led0_in(7 downto 5)	<=	"000";

io_expander_inst: entity work.IO_Expander_TCA6416A
port map(reset_n 			=>	reset_n,
			clock				=>	adc_pll_clk_data,
			a1_en				=>	'0',
			a0_port0_dir	=>	x"00",
			a0_port1_dir	=>	x"00",
			a1_port0_dir	=>	x"00",
			a1_port1_dir	=>	x"00",

			a0_port0_in		=>	led0_in,	
			a0_port1_in		=>	led0_in,
			a1_port0_in		=>	x"00",
			a1_port1_in		=>	x"00",

			a0_port0_out	=>	open,
			a0_port1_out	=>	open,
			a1_port0_out	=>	open,
			a1_port1_out	=>	open,

			scl				=>	led_scl,--dig_b(17),
			sda				=>	led_sda--dig_b(16)
			);

rfsw			<=	rfon;
-------------------variable attenuator and rf switch------
	var_att_inst: entity work.var_attn
	port map(clock	=>	adc_pll_clk_data,
				reset	=>	reset_n,
				d_in	=>	ratn,
		
				sclk	=>	ratn_sclk,--dig_a(1),
				le		=>	ratn_le,--dig_b(18),
				sdata	=>	ratn_sdata--dig_a(2)
				);
-----------fpga internal temperature sensor--------------
inst_fpga_tsd: fpga_tsd_int
port map(
		corectl =>	'1',
		reset   =>	'0',
		tempout =>	c10gx_tmp,
		eoc     =>	open
	);
------------------deta module----------------------
deta_module_inst: entity work. deta_module
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	'1',
			prb_i		=>	iq(2),
			prb_q		=>	iq(3),
			fwd_i		=>	iq(4),
			fwd_q		=>	iq(5),
			tdoff		=>	tdoff,
			
			deta		=>	deta,
			cfqea		=>	cfqea,
			deta2		=>	open,
			dtnerr	=>	open
			);
------------------epcs control for remote firmware and fcc id---------------- module used to r/w the fcc register
epcs_cntl_inst: entity work. epcs_cntl
port map(clock			=>	adc_pll_clk_data,
			reset			=>	adc_pll_lock_q,
			epcs_busy	=>	epcsb,
			address		=>	cnfga,
			data			=>	cnfgd,
			cntl			=>	cnfgc,	  
			result		=>	cnfgr,
			fccid			=>	fccid
			);			


			 

									






end architecture behavioral;