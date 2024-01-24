		
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
			  lmk03328_sda			:	inout std_logic;
			  lmk03328_scl			:	out std_logic;           
			  ad9781_sdi			:	out std_logic;
			  ad9781_sdo			:	in std_logic;
			  ad9781_rst			:	out std_logic;
			  ad9781_ncs			:	out std_logic;
			  ad9781_sclk			:	out std_logic;
			  ad9653_pwdn			:	out std_logic;
			  ad9653_ncs			:	out std_logic;
			  ad9653_sdio			:	out std_logic;
			  ad9653_sclk			:	out std_logic;
			  ad9653_sync			:	out std_logic;
			  ad9653_sdio_dir		:	out std_logic;			  
			  dac_data_p			:	out std_logic_vector(13 downto 0);		  
			  dac_dci_p				:	out std_logic;			  			  		  
			  pwr_sync 				: 	out STD_LOGIC;
           pwr_en 				: 	out STD_LOGIC;
			  hb_fpga				:	out std_logic;
			  
			  
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
			  dig_in					:	in std_logic_vector(2 downto 0);
			  dig_out				:	out std_logic_vector(3 downto 0);
			  rfsw					:	out std_logic;
			  ratn_sclk				:	out std_logic;
			  ratn_le				:	out std_logic;
			  ratn_sdata			:	out std_logic;
			  
			  led_scl				:	out std_logic;
			  led_sda				:	inout std_logic;
				
			  
			  pmod_io				:	in std_logic_vector(5 downto 0)
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
signal fwrst				:	std_logic;
signal brd_reset			:	std_logic;

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
signal ld_adc_data_d				:	std_logic;


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

signal hb_isa						:	std_logic;
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
signal prob_mag_c				:	std_logic_vector(17 downto 0);			
signal prob_mag				:	std_logic_vector(17 downto 0);
signal prob_phs				:	std_logic_vector(17 downto 0);
signal phs_sml_disc			:	std_logic_vector(17 downto 0);
signal phs_med_disc			:	std_logic_vector(17 downto 0);
signal phs_lrg_disc			:	std_logic_vector(17 downto 0);
signal phs_xlrg_disc			:	std_logic_vector(17 downto 0);
signal disc_out				:	reg18_4;

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
signal i_rot_flt				:	std_logic_vector(17 downto 0);
signal q_rot_flt				:	std_logic_vector(17 downto 0);
signal i_rot_flt_d			:	std_logic_vector(17 downto 0);
signal i_rot_flt_q			:	std_logic_vector(17 downto 0);
signal q_rot_flt_d			:	std_logic_vector(17 downto 0);
signal q_rot_flt_q			:	std_logic_vector(17 downto 0);
signal iqflt					:	std_logic;
signal phs_rot					:	std_logic_vector(17 downto 0);
--signal deta						:	std_logic_vector(17 downto 0);
signal cfqea					:	std_logic_vector(17 downto 0);
signal rfprm					:	std_logic;
signal fib_stat				:	std_logic_vector(3 downto 0);
signal fib_msk_set			:	std_logic_vector(15 downto 0);

signal fault_clear			:	std_logic;

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
signal glow_d, glow_q		:	std_logic;


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




signal reg_rw_bank			:	reg8_16_18;
signal regbank_in				:	reg16_16_18;

signal regbank_rd_data		:	reg16_18;



signal rfon						:	std_logic;
signal ratn						:	std_logic_vector(5 downto 0);
signal ratn_cdc				:	std_logic_vector(5 downto 0);
signal maglp					:	std_logic_vector(1 downto 0);
signal phslp					:	std_logic_vector(1 downto 0);


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
--signal wav_takei				:	std_logic;
signal wavs_takei				:	std_logic;
signal wavstm					:	std_logic_vector(17 downto 0);
signal wav_data_out			:	reg18_10;
signal wavs_done				:	std_logic;

signal wavh_takei				:	std_logic;
signal wavh_takei_q			:	std_logic_vector(1 downto 0);
signal wavhtm					:	std_logic_vector(17 downto 0);
signal wavh_data_out			:	reg18_10;
signal wavh_done				:	std_logic;

signal harv_trig				:	std_logic_vector(15 downto 0);
signal harv_takei_d			:	std_logic;
signal harv_takei				:	std_logic;
signal harv_takei_cirbuf	:	std_logic;
signal trig_delay				:	std_logic_vector(15 downto 0);

signal en_trig_d				:	std_logic;
signal en_trig					:	std_logic;

signal extfsd					:	std_logic_vector(2 downto 0);
signal clmpedge_d				:	std_logic_vector(1 downto 0);
signal clmpedge_q				:	std_logic_vector(1 downto 0);


signal rfonedge				:	std_logic;
signal zoneedge				:	std_logic;
signal gmesedge				:	std_logic;
signal clmpedge				:	std_logic;
signal fsdedgeext				:	std_logic;
signal fsdedgeint				:	std_logic;

signal zoneedge_cnt_d		:	unsigned(6 downto 0);
signal zoneedge_cnt_q		:	unsigned(6 downto 0);

signal fsdcnt_d, fsdcnt_q	:	integer range 0 to 31;

signal extfsdtrig_d			:	std_logic;
signal extfsdtrig_q			:	std_logic;

signal zonetrigin_d			:	std_logic_vector(2 downto 0);
signal zonetrigin_q			:	std_logic_vector(2 downto 0);
signal zonetrigout_d			:	std_logic;
signal zonetrigout			:	std_logic;

signal grmpr			:	std_logic_vector(17 downto 0);
signal prmpr			:	std_logic_vector(17 downto 0);
signal rmpctl			:	std_logic_vector(3 downto 0);
signal grmp				:	std_logic_vector(17 downto 0);
signal prmp				:	std_logic_vector(17 downto 0);
signal rmpstat			:	std_logic_vector(1 downto 0);
signal tone2iq			:	std_logic;
signal tone2iqgo		:	std_logic;
signal tone2iq_d		:	std_logic;
signal tone2iq_q		:	std_logic;

signal rfon_d			:	std_logic;
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



signal qdiff			:	std_logic_vector(17 downto 0);
signal qrate			:	std_logic_vector(17 downto 0);
signal qslope			:	std_logic_vector(17 downto 0);
signal qstat			:	std_logic_vector(1 downto 0);
signal qmsk				:	std_logic;

signal plson			:	std_logic_vector(15 downto 0);
signal plsoff			:	std_logic_vector(15 downto 0);
signal plsdone			:	std_logic;
signal plsmode			:	std_logic_vector(1 downto 0);
signal cirbuf_pulse	:	std_logic;	

signal stpena			:	std_logic;
signal stpena_d		:	std_logic;
signal stpena_q		:	std_logic;
signal deta_disc_pzt	:	std_logic_vector(2 downto 0);
signal stpena_fib				:	std_logic;
signal deta_stp_fib			:	std_logic_vector(15 downto 0);
signal disc_stp_fib			:	std_logic_vector(27 downto 0);
signal deta_disc_pzt_fib	:	std_logic_vector(2 downto 0);

signal qstat_rd				:	std_logic_vector(1 downto 0);
signal crc_done_stp			:	std_logic;
signal crc_data_stp			:	std_logic_vector(31 downto 0);
signal start_crc_stp			:	std_logic;
signal crc_data_out_stp		:	std_logic_vector(39 downto 0);

signal phs_spr_in				:	std_logic_vector(17 downto 0);
signal phs_pi_in				:	std_logic_vector(17 downto 0);

signal adc_rst_n				:	std_logic;
signal kly_ch_done			:	std_logic;
signal rfon_int				:	std_logic;
signal rfon_en					:	std_logic;

signal fault_clear_d			:	std_logic;
signal fault_clear_q			:	std_logic;
signal flt_clr_cnt_d			:	integer range 0 to 15;
signal flt_clr_cnt_q			:	integer range 0 to 15;
signal beam_fsd				:	std_logic_vector(1 downto 0);
signal beam_fsd_buf			:	std_logic_vector(1 downto 0);
signal beam_fsd_fib			:	std_logic;
signal xytmlim					:	std_logic_vector(17 downto 0);

signal gdcltl					:	std_logic_vector(17 downto 0);
signal gldeth					:	std_logic_vector(17 downto 0);
signal gldetl					:	std_logic_vector(17 downto 0);
signal pldeth					:	std_logic_vector(17 downto 0);
signal pldetl					:	std_logic_vector(17 downto 0);
signal glde						:	std_logic_vector(17 downto 0);
signal plde						:	std_logic_vector(17 downto 0);

signal sft_flt					:	std_logic_vector(7 downto 0);
signal sft_flt_q				:	std_logic_vector(7 downto 0);

signal sft_flt_edge_d		:	std_logic_vector(3 downto 0);
signal sft_flt_edge_q		:	std_logic_vector(3 downto 0);

signal gmeslvl			:	std_logic_vector(17 downto 0);
signal gmestmr			:	std_logic_vector(17 downto 0);
signal gmesmsk			:	std_logic;
signal gmesstat		:	std_logic_vector(1 downto 0);
signal gmesflt			:	std_logic;
signal gmesstat_q		:	std_logic_vector(1 downto 0);

signal lopwth			:	std_logic_vector(17 downto 0);	
signal lopwtl			:	std_logic_vector(17 downto 0);
signal lopwmsk			:	std_logic;
signal lopwstat		:	std_logic_vector(1 downto 0);

signal sftmsk			:	std_logic_vector(3 downto 0);	


signal adc_seek_out			:	std_logic_vector(31 downto 0);

begin

inst_reset_all: entity  work.reset_all
port map(clock		=>	clock,
			brd		=>	brd_reset,
			reg		=>	'1',
			pll		=>	lmkconfig_done,
			
			pllrst	=>	lmk_reset_n,
			fwrst		=>	reset_n
			);


--lmk_reset_n				<=	reset and m10_reset and pmod_io(3);			
--reset_n					<=	reset and m10_reset and pmod_io(3) and not lmk_ref(0) and not lmk_lock(0);

--lmk_reset_n				<=	reset and m10_reset and pmod_io(3);			
brd_reset				<=	reset and m10_reset and pmod_io(3);



adc_rst_n				<=	adc_lvds_lock_q;	


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
tx_en_d				<=	rfon_q(1);




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
adc_pll_reset	<=	not reset_n;
	
adc_pllo_inst: adc_pll0
	port map (
		rst      => adc_pll_reset, --    reset.reset
		refclk   => adc_dclk_p, --   refclk.clk
		locked   =>	adc_pll_lock_d,                           --   locked.export
		phout		=>	adc_pll_phout,
		lvds_clk => adc_pll_lvds_bit(1 downto 0),       -- lvds_clk.lvds_clk
		loaden   =>	adc_pll_lvds_en(1 downto 0),        --   loaden.loaden
		outclk_2 =>	adc_pll_clk_data                            --  outclk2.clk		
	);

adc_lvds_lock_d	<=	adc_pll_lock_q and spi_done_q(1);

--adc_rst_n			<=	adc_lvds_lock_q;


adc_lvds_rx_inst: adc_lvds_rx
		port map (
			rx_in            	=>	adc_data_in(8 downto 0), -- export
			rx_out           	=>	adc_data_out,	                    -- export
			rx_bitslip_reset 	=>	"000000000", -- export
			rx_bitslip_ctrl	=>	bitslip_ctrl_q, -- export
			rx_bitslip_max   	=>	adc_bitslip_max,                     -- export
			ext_fclk         	=>	adc_pll_lvds_bit(0),                                  -- export
			ext_loaden       	=>	adc_pll_lvds_en(0),             -- export
			ext_coreclock    	=>	adc_pll_clk_data,
			ext_vcoph			=>	adc_pll_phout,
			ext_pll_locked		=>	adc_lvds_lock_q,
			pll_areset       	=> adc_pll_reset,              -- export
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
				rfon_q				<=	(others	=>	'0');
				stpena_q				<=	'0';
				phs_spr_in			<=	(others	=>	'0');
				fault_clear_q		<=	'0';
				flt_clr_cnt_q		<=	0;
				i_rot_flt_q			<=	(others	=>	'0');
				q_rot_flt_q			<=	(others	=>	'0');
				wavh_takei_q		<=	(others	=>	'0');
				harv_takei			<=	'0';
				en_trig				<=	'0';
				extfsd				<=	(others	=>	'0');
				extfsdtrig_q		<=	'0';
				fsdcnt_q				<=	0;
				zoneedge_cnt_q		<=	(others	=>	'0');
				beam_fsd_buf		<=	(others	=>	'0');
				clmpedge_q			<=	(others	=>	'0');
				zonetrigin_q		<=	(others	=>	'0');
				zonetrigout			<=	'0';
				sft_flt_q			<=	(others	=>	'0');
				sft_flt_edge_q		<=	(others	=>	'0');
				gmesstat_q			<=	(others	=>	'0');
				glow_q				<=	'0';
				ld_adc_data			<=	'0';
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
				rfon_q				<=	rfon_q(0)&rfon_d;
				stpena_q				<=	stpena;
				phs_spr_in			<=	phs_pi_in;
				fault_clear_q		<=	fault_clear_d;
				flt_clr_cnt_q		<=	flt_clr_cnt_d;
				i_rot_flt_q			<=	i_rot_flt_d;
				q_rot_flt_q			<=	q_rot_flt_d;
				wavh_takei_q		<=	wavh_takei_q(0)&wavh_takei;
				harv_takei			<=	harv_takei_d;
				en_trig				<=	en_trig_d;
				extfsd				<=	extfsd(1 downto 0)&fib_in(2);
				extfsdtrig_q		<=	extfsdtrig_d;
				fsdcnt_q				<=	fsdcnt_d;
				zoneedge_cnt_q		<=	zoneedge_cnt_d;
				beam_fsd_buf		<=	beam_fsd_buf(0)&beam_fsd(1);
				clmpedge_q			<=	clmpedge_d;
				zonetrigin_q		<=	zonetrigin_d;
				zonetrigout			<=	zonetrigout_d;
				sft_flt_q			<=	sft_flt;
				sft_flt_edge_q		<=	sft_flt_edge_d;
				gmesstat_q			<=	gmesstat_q(0)&gmesstat(1);
				glow_q				<=	glow_d;
				ld_adc_data			<=	ld_adc_data_d;
			end if;
end process;
	

fclk_match_d	<=	'1' when fclk_q = x"ff" or fclk_q = x"00" else '0';

hb_fpga			<=	hb_cntr_q(25);

ld_adc_data_d		<=	'1' when adc_align_done(7 downto 0) = x"ff" else '0';

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



cirbufs_takei_inst: entity work.cirbufs_takei
	port map(clock			=>	adc_pll_clk_data,
				reset			=>	reset_n,
				epics_takei	=>	wavs_takei,
				pulse_out	=>	pulse_out,
				maglp			=>	maglp_q,
				cirbuftake	=>	cirbuf_pulse
			);			


cirbuf_data_inst_0: entity work.cirbuf_data
port map(wrclock		=>	adc_pll_clk_data,
			rdclock		=>	lb_clk,
			reset			=>	reset_n,
		 
			takei			=>	cirbuf_pulse,
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









harv_takei_d	<=	'1' when wavh_takei_q(0) = '1' and wavh_takei_q(1) = '0' else
						'0' when en_trig = '1' else
						harv_takei;
						
clmpedge_d(0)	<=	(xystat(0) or xystat(1) or xystat(2) or xystat(3)) and maglp_q(1) and not maglp_q(0) and phslp_q(1) and not phslp_q(0);							
clmpedge_d(1)	<=	clmpedge_q(0);	

						
fsdcnt_d			<=	0 when extfsd(2) /= extfsd(1) else
						fsdcnt_q + 1 when fsdcnt_q /= 31 else
						fsdcnt_q;

extfsdtrig_d	<=	'1' when fsdcnt_q = 30 else '0';						

zonetrigin_d(0)	<=	dig_in(0);
zonetrigin_d(2 downto 1)	<=	zonetrigin_q(1 downto 0);						


rfonedge			<=	rfon_q(1) and not rfon_q(0) and harv_trig(1);------------1 to 0 transition
zoneedge			<=	not zonetrigin_q(2) and zonetrigin_q(1) and harv_trig(2);-------0 to 1 transition
gmesedge			<=	not gmesstat_q(1) and gmesstat_q(0) and harv_trig(3);
clmpedge			<=	not clmpedge_q(1) and clmpedge_q(0) and harv_trig(4);-----0 to 1 transition
fsdedgeext		<=	not extfsdtrig_q and extfsdtrig_d and harv_trig(5);------0 to 1 transition
fsdedgeint		<=	beam_fsd_buf(1) and not beam_fsd_buf(0) and harv_trig(8);-------1 to 0 transition		<=	

en_trig_d		<=	rfonedge or zoneedge or gmesedge or clmpedge or fsdedgeext or fsdedgeint;

zoneedge_cnt_d		<=	zoneedge_cnt_q + 1 when (rfonedge = '1' or gmesedge = '1' or zoneedge = '1' or clmpedge = '1' or fsdedgeext = '1' or fsdedgeint = '1') and zoneedge_cnt_q = "0000000" else
							zoneedge_cnt_q + 1 when zoneedge_cnt_q /= "0000000" else
							zoneedge_cnt_q;
zonetrigout_d		<=	'0' when zoneedge_cnt_q = "0000000" else '1';

dig_out(0)			<=	zonetrigout;



harv_delay_inst: entity work.harv_trig_delay
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			strobe	=>	'1',
			takei		=>	harv_takei,
			trgd		=>	trig_delay,
			takeo		=>	harv_takei_cirbuf
			);







cirbuf_data_inst_1: entity work.cirbufh_data
port map(wrclock		=>	adc_pll_clk_data,
			rdclock		=>	lb_clk,
			reset			=>	reset_n,
		 
			takei			=>	harv_takei_cirbuf,
			strobe		=>	'1',
			rate			=>	wavhtm,
			isa_addr_rd =>	lb_addr,
			data_in		=>	wav_data_in,
			data_out		=>	wavh_data_out,
			
			buf_done		=>	wavh_done
			);						




------------------------code blocks copied from llrf 2.0 fcc algorithm-------------








inst_cic_i: entity work.cic(behavior)
port map(clock				=>	adc_pll_clk_data,
			reset				=>	reset_n,
			strobe_integ	=>	'1',
		--	strobe_dec		:	in std_logic;
			d_in				=>	iq(2),
			d_out				=>	prob_i_cic,
			strobe_out		=>	strobei_clkd4
			);
inst_cic_q: entity work.cic(behavior)
port map(clock				=>	adc_pll_clk_data,
			reset				=>	reset_n,
			strobe_integ	=>	'1',
		--	strobe_dec		:	in std_logic;
			d_in				=>	iq(3),
			d_out				=>	prob_q_cic,
			strobe_out		=>	strobeq_clkd4
			);
inst_fir_lpf_i: entity work.fir_prb
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_clkd4,	
			d_in		=>	prob_i_cic,
			d_out		=>	prob_i_flt
			);
inst_fir_lpf_q: entity work.fir_prb
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobeq_clkd4,	
			d_in		=>	prob_q_cic,
			d_out		=>	prob_q_flt
			);			
			
			
inst_iq2mp_18bit: entity work.iq2mp_18bit
port map(clock =>	adc_pll_clk_data,
			reset =>	reset_n,
			load	=>	strobei_clkd4,
			i 		=>	prob_i_flt,
			q	 	=>	prob_q_flt,
			mag_c	=>	prob_mag_c,			
			mag 	=>	prob_mag,
			phs 	=>	prob_phs
			);
			
--inst_iir7_lpf_i_rot:entity work.iir_lpfk7
--port map(clock	=>	adc_pll_clk_data,
--			reset =>	reset_n,
--			load	=>	strobei_clkd4,
--			d_in	=>	i_rot,
--			d_out	=>	i_rot_flt
--			);
--inst_iir7_lpf_q_rot:entity work.iir_lpfk7
--port map(clock	=>	adc_pll_clk_data,
--			reset =>	reset_n,
--			load	=>	strobei_clkd4,
--			d_in	=>	q_rot,
--			d_out	=>	q_rot_flt
--			);
			
--i_rot_flt_d		<=	i_rot_flt when iqflt = '1' else i_rot;
--q_rot_flt_d		<=	q_rot_flt when iqflt = '1' else q_rot;	

i_rot_flt_d			<=	i_rot;
q_rot_flt_d			<=	q_rot;




i_out			<=	prob_i_flt when maglp_q = "01" and phslp_q = "01" else i_rot_flt_q;
q_out			<=	prob_q_flt when maglp_q = "01" and phslp_q = "01" else q_rot_flt_q;

inst_mp2iq: entity work.mp2iq
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=> strobei_clkd4,
			mag		=> "01"&x"ffff",
			phs_h		=> phs_rot,
			phs_l		=>	x"00",
	  		i			=> cos_rot,
			q			=> sin_rot
			);
inst_rotate: entity work.rotate_matrix
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_clkd4,
			xin		=>	xin_rot,
			yin		=>	yin_rot,
			cos		=>	cos_rot,
			sin		=>	sin_rot,
			xout		=>	i_rot,
			yout		=>	q_rot
			);	
inst_loop_mux: entity work.loop_mux
port map(clock			=>	adc_pll_clk_data,
			reset			=>	reset_n,
			load			=>	strobei_clkd4,
			mag_lp		=>	maglp_q,
			phs_lp		=>	phslp_q,
			pulse_out	=>	pulse_out,
			glos			=>	glos,
			gdcl			=>	gdcl,
			glos_kly		=>	glos_kly,
			kly_ch		=>	kly_ch,
			gpid			=>	xdrv,
			gmes			=>	prob_mag,
			plos			=>	plos,
			pmes			=>	prob_phs,
			ppid			=>	ydrv,
			poff			=>	poff,
			xout			=>	xin_rot,
			yout			=>	yin_rot,
			phs			=>	phs_rot
			);
			
			
inst_mag_ramp: entity work.phs_ramp
	port map(clock		=>	adc_pll_clk_data,
				reset		=>	reset_n,
				strobe	=>	strobei_clkd4,
				rmpctl	=>	rmpctl(1 downto 0),
				pset		=>	gset,
				prmpr		=>	grmpr,
				prmp		=>	grmp,
				rmpstat	=>	rmpstat(0)
				);						
			
			
			
inst_mag_pi_control: entity work.pi_control
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_clkd4,
			rfon		=>	rfon_q(1),
			mploop	=>	maglp_q,
			set		=>	grmp,	
			mes		=>	prob_mag,
			pgain		=> mpro(15 downto 0),
			igain		=>	mi(15 downto 0),
			irate		=>	mirate(15 downto 0),
			pi_out	=> gpid
			);
			


			
					
inst_phs_ramp: entity work.phs_ramp
	port map(clock		=>	adc_pll_clk_data,
				reset		=>	reset_n,
				strobe	=>	strobei_clkd4,
				rmpctl	=>	rmpctl(3 downto 2),
				pset		=>	pset,
				prmpr		=>	prmpr,
				prmp		=>	prmp,
				rmpstat	=>	rmpstat(1)
				);			
--phs_pi_in	<=	std_logic_vector(signed(pset) - signed(prob_phs));
phs_pi_in	<=	std_logic_vector(signed(prmp) - signed(prob_phs));

			
inst_spr: entity work.state_phs_res
generic map(w => 18)
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_clkd4,
			ang_in	=>	phs_spr_in,
			ang_out	=>	prob_phs_spr
			);
			
inst_phs_pi_control: entity work.pi_control
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_clkd4,
			rfon		=>	rfon_q(1),
			mploop	=>	phslp_q,
			set		=>	prob_phs_spr,	
			mes		=>	"00"&x"0000",
			pgain		=> ppro(15 downto 0),
			igain		=>	pi(15 downto 0),
			irate		=>	pirate(15 downto 0),
			pi_out	=> ppid
			);
			
			
inst_xylim: entity work.xylim
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	strobei_clkd4,
			xin		=>	gpid,
			yin		=>	ppid,
			xlimhi	=>	xlimhi,
			xlimlo	=>	xlimlo,
			ylimhi	=>	ylimhi,
			ylimlo	=>	ylimlo,
			beam_fsd	=>	beam_fsd(1),
			xout		=>	xdrv,
			yout		=>	ydrv,
			xstat		=>	xystat(1 downto 0),---[0]xlimlo,[1]xlimhi
			ystat		=>	xystat(3 downto 2)----[2]ylimlo,[3]ylimhi
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




regbank_in(0)		<=	fltrd;


regbank_in(1)(0)	<=	prob_i_flt;
regbank_in(1)(1)	<=	prob_q_flt;
regbank_in(1)(2)	<=	prob_mag;
regbank_in(1)(3)	<=	prob_phs;
regbank_in(1)(4)	<=	grmp;
regbank_in(1)(5)	<=	(others	=>	'0');
regbank_in(1)(6)	<=	(others	=>	'0');
regbank_in(1)(7)	<=	"00"&x"0007";
regbank_in(1)(8)	<=	"00"&x"0008";
regbank_in(1)(9)	<=	glde;
regbank_in(1)(10)	<=	plde;
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
regbank_in(2)(15)	<=	qdiff;

grmpr						<=	reg_rw_bank(0)(0);
gset 						<= reg_rw_bank(0)(2);
pset 						<= reg_rw_bank(0)(3);

regbank_in(3)(0)	<=	cfqea;
regbank_in(3)(1)	<=	deta;
regbank_in(3)(2)	<=	disc_out(2);
regbank_in(3)(3)	<=	disc_out(1);
regbank_in(3)(4)	<=	disc_out(0);
regbank_in(3)(6)	<=	disc_out(3);
regbank_in(3)(7)	<=	"00"&adc0_a;		
regbank_in(3)(8)	<=	(not adc0_b(15))&(not adc0_b(15))&(not adc0_b(15))&adc0_b(14 downto 0);
regbank_in(3)(9)	<=	(not adc1_a(15))&(not adc1_a(15))&(not adc1_a(15))&adc1_a(14 downto 0);
regbank_in(3)(15)	<=	x"00"&c10gx_tmp;

regbank_in(4)(0)	<=	"00"&x"006a";-----firmware version
regbank_in(4)(1)	<=	"00"&x"0002";-----hrt version

regbank_in(4)(2)(17 downto 16)	<=	(others	=>	'0');
regbank_in(4)(2)(15 downto 13)	<=	xystat(3 downto 1);
regbank_in(4)(2)(12 downto 11)	<=	rmpstat;
regbank_in(4)(2)(10)					<=	lopwstat(1);

rfprm										<=	fib_stat(3) or fib_stat(2) or qstat(1);

regbank_in(4)(2)(9)					<=	'0';
regbank_in(4)(2)(8)					<=	not rfprm;
regbank_in(4)(2)(7 downto 3)		<=	(others	=>	'0');
regbank_in(4)(2)(2)					<=	hb_isa;
regbank_in(4)(2)(1)					<=	wavh_done;
regbank_in(4)(2)(0)					<=	wavs_done;

regbank_in(4)(3)(17 downto 10)	<=	(others	=>	'0');
regbank_in(4)(3)(9 downto 8)		<=	qstat;
regbank_in(4)(3)(7 downto 6)		<=	gmesstat;
regbank_in(4)(3)(5 downto 2)	<=	(others	=>	'0');
regbank_in(4)(3)(1)					<=	sft_flt_q(6);----gdcl fault
regbank_in(4)(3)(0)					<=	sft_flt_q(2);

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


regbank_in(4)(5)(17 downto 10)		<=	(others	=>	'0');
regbank_in(4)(5)(9)						<=	beam_fsd(1);-------fcc fsd out
regbank_in(4)(5)(8)						<=	not gmesstat_q(0);---------hpa fiber out is enabled all the time
regbank_in(4)(5)(7 downto 6)		<=	(others	=>	'0');
regbank_in(4)(5)(5 downto 4)		<=	fib_stat(3 downto 2);
regbank_in(4)(5)(3 downto 2)		<=	(others	=>	'0');
regbank_in(4)(5)(1 downto 0)		<=	fib_stat(1 downto 0);

regbank_in(4)(8)(17 downto 8)	<=	(others	=>	'0');
regbank_in(4)(8)(7 downto 0)	<=	cnfgr;


regbank_in(5)(2)	<=	deta2;
regbank_in(5)(3)	<=	"00"&fccid;-----fccid register
regbank_in(5)(4)	<=	prmp;








mpro			<= reg_rw_bank(0)(9);
mi				<= reg_rw_bank(0)(10);
mirate		<= reg_rw_bank(0)(11);
ppro			<= reg_rw_bank(0)(14);
pi				<= reg_rw_bank(0)(15);

pirate		<= reg_rw_bank(1)(0);

plson			<=	reg_rw_bank(1)(3)(15 downto 0);
plsoff		<=	reg_rw_bank(1)(4)(15 downto 0);


glos			<= reg_rw_bank(1)(7);
plos			<= reg_rw_bank(1)(8);
gdcl			<= reg_rw_bank(1)(9);
poff			<= reg_rw_bank(1)(11);
qrate			<=	reg_rw_bank(1)(14);
qslope		<=	reg_rw_bank(1)(15);

tdoff			<= reg_rw_bank(2)(0);


rmpctl(3)		<=	reg_rw_bank(3)(1)(15);
rmpctl(2)		<=	reg_rw_bank(3)(1)(13);
rmpctl(0)		<=	reg_rw_bank(3)(1)(12);
plsmode			<=	reg_rw_bank(3)(1)(10 downto 9);
rmpctl(1)		<=	reg_rw_bank(3)(1)(8);
kly_ch			<=	reg_rw_bank(3)(1)(2);
wavh_takei		<=	reg_rw_bank(3)(1)(1);
wavs_takei		<=	reg_rw_bank(3)(1)(0);

iqflt			<=	reg_rw_bank(3)(2)(6);


phslp_d		<=	"01" when (rfon_q(0) = '0' and rfon_q(1) = '1' and phslp_q = "10") or sft_flt_edge_q(3) = '1' or sft_flt_edge_q(2) = '1' or sft_flt_edge_q(0) = '1' else
					phslp when wrreg_en_out_buf(3)(2) = '1' else
					phslp_q;
				
maglp_d		<=	"00" when (sft_flt_edge_q(3) = '1') or (rfon_q(0) = '0' and rfon_q(1) = '1') else
					maglp when wrreg_en_out_buf(3)(2) = '1' else
					maglp_q;	
		
	
	
phslp			<=	reg_rw_bank(3)(2)(4 downto 3);
maglp			<= reg_rw_bank(3)(2)(2 downto 1);


lopwmsk				<=	reg_rw_bank(3)(3)(9);
qmsk				<=	reg_rw_bank(3)(3)(8);
gmesmsk			<=	reg_rw_bank(3)(3)(6);
sftmsk			<=	reg_rw_bank(3)(3)(5 downto 4) & reg_rw_bank(3)(4)(5 downto 4);




fault_clear_d		<=	'0' when flt_clr_cnt_q = 15 else
							reg_rw_bank(3)(3)(0) when wrreg_en_out_buf(3)(3) = '1' else
							fault_clear_q;
flt_clr_cnt_d	<=	0 when flt_clr_cnt_q = 15 else
						flt_clr_cnt_q + 1 when (wrreg_en_out_buf(3)(3) = '1' and reg_rw_bank(3)(3)(0) = '1' and flt_clr_cnt_q = 0) else
						flt_clr_cnt_q + 1 when flt_clr_cnt_q /= 0 else
						flt_clr_cnt_q;
fault_clear		<=	fault_clear_q;						

fib_msk_set					<=	reg_rw_bank(3)(9)(15 downto 0);	

cnfga(15 downto 0)		<=	reg_rw_bank(3)(11)(15 downto 0);
cnfga(31 downto 16)		<=	reg_rw_bank(3)(12)(15 downto 0);
cnfgd							<=	reg_rw_bank(3)(13)(7 downto 0);
cnfgc							<=	reg_rw_bank(3)(14)(3 downto 0);



harv_trig					<=	reg_rw_bank(4)(0)(15 downto 0);
trig_delay					<=	reg_rw_bank(4)(8)(15 downto 0);




rfon_int			<=	reg_rw_bank(5)(2)(0) and not rfprm and not kly_ch_done and not lopwstat(1);
rfon_en			<=	wrreg_en_out_buf(5)(2) or rfprm or kly_ch_done or lopwstat(1);

rfon_d			<=	rfon_int when rfon_en = '1' else
						rfon_q(0);






ratn			<=	reg_rw_bank(5)(3)(5 downto 0);
prmpr			<=	reg_rw_bank(5)(7);

xlimlo		<=	reg_rw_bank(5)(11);
xlimhi		<=	reg_rw_bank(5)(12);
ylimlo		<=	reg_rw_bank(5)(13);
ylimhi		<=	reg_rw_bank(5)(14);
xytmlim		<=	reg_rw_bank(5)(15);


stpena		<=	reg_rw_bank(6)(1)(0) and rfon_q(1) and glow_q;
gmeslvl		<=	reg_rw_bank(6)(2);
glow			<=	reg_rw_bank(6)(3);
wavstm		<=	reg_rw_bank(6)(9);
wavhtm		<=	reg_rw_bank(6)(10);

gdcltl		<=	reg_rw_bank(6)(13);
gldeth		<=	reg_rw_bank(6)(14);
gldetl		<=	reg_rw_bank(6)(15);

pldeth		<=	reg_rw_bank(7)(0);
pldetl		<=	reg_rw_bank(7)(1);
gmestmr		<=	reg_rw_bank(7)(2);
lopwtl		<=	reg_rw_bank(7)(3);	
lopwth		<=	reg_rw_bank(7)(4);


glow_d		<=	'1' when prob_mag > glow else '0';



	
regbank_mux_i_gen: for i in 0 to 15 generate
regbank0_mux_i:entity work.rdmux16to1
	port map(clock	=>	adc_pll_clk_data,
			reset		=>	reset_n,
			data_in	=>	regbank_in(i),
			addr_in	=>	reg_addr(3 downto 0),
			data_out	=>	regbank_rd_data(i)
			);
end generate;

--regbnk_rw_ro_gen_1: for i in 0 to 7 generate
--
--	regbank_in(i+8)(15 downto 0)		<=	reg_rw_bank(i)(15 downto 0);			
--end generate;

regbnk_rw_ro_gen_2: for i in 0 to 2 generate
	regbank_in(i+8)(15 downto 0)		<=	reg_rw_bank(i)(15 downto 0);			
end generate;

regbank_in(11)(0)			<=	reg_rw_bank(3)(0);
regbank_in(11)(1)			<=	reg_rw_bank(3)(1);
regbank_in(11)(2)			<=	reg_rw_bank(3)(2)(17 downto 5)&phslp_q&maglp_q&'0';
regbank_in(11)(3)			<=	reg_rw_bank(3)(3)(17 downto 1)&fault_clear_q;
regbank_in_gen_11_1: for i in 4 to 15 generate
	regbank_in(11)(i)			<=	reg_rw_bank(3)(i);
end generate;

regbank_in_gen_12: for i in 0 to 15 generate
	regbank_in(12)(i)			<=	reg_rw_bank(4)(i);
end generate;

regbank_in_gen_13_1: for i in 0 to 1 generate
	regbank_in(13)(i)			<=	reg_rw_bank(5)(i);
end generate;
regbank_in(13)(2)			<=	reg_rw_bank(5)(2)(17 downto 1) & rfon_q(1);
regbank_in_gen_13_2: for i in 3 to 15 generate
	regbank_in(13)(i)			<=	reg_rw_bank(5)(i);
end generate;


regbnk_rw_ro_gen_3: for i in 6 to 7 generate
	regbank_in(i+8)(15 downto 0)		<=	reg_rw_bank(i)(15 downto 0);			
end generate;






	
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
				wavh_data		=>	wavh_data_out,
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
			lb_addr			=>	lb_addr,
			lb_wdata			=>	lb_wdata,
			lb_renable		=>	lb_renable,
			lb_rdata			=>	lb_rdata,
			


			sfp_refclk_p	=>	sfp_refclk_p,
			sfp_rx_0_p		=>	sfp_rx_0_p,
			sfp_tx_0_p		=>	sfp_tx_0_p	
			);
			
			
			
-----------------pll lock and latch status---------------------
--lmk_lock_d	<=	'0' when fault_clear = '1' else
--					'1' when lmk_lock(0) = '1' else
--					lmk_lock(1);
--lmk_ref_d	<=	'0' when fault_clear = '1' else
--					'1' when lmk_ref(0) = '1' else
--					lmk_ref(1);					
			
-------------------------------------------configuring the clock to generate the clocks needed for adc, dac----			
lmk03328_i2c_config: entity work.lmk03328_i2c
port map(clock			=>	clock,
			reset			=>	lmk_reset_n,
			init_config	=> lmk_init_q,
			sda			=>	lmk03328_sda,
			scl			=>	lmk03328_scl,
			clk_done		=>	lmkconfig_done
--			pll_lock		=>	lmk_lock(0),
--			pll_ref		=>	lmk_ref(0)
--			pll_rd_valid	=>	pll_rd_valid
			);
			
--------------initializing dac (ad9781)
ad9781_inst: entity work.ad9781
port map(clock		=>	clock,
			reset		=>	reset_n,
		
			spi_init	=>	lmkconfig_done,
			sdo		=>	ad9781_sdo,		
			nCS		=>	ad9781_ncs,
			sclk		=>	ad9781_sclk,		
			sdio		=>	ad9781_sdi,		
			spi_done	=>	open
			);
--ad9781_seek_inst: entity work.ad9781_sample_seek
--port map(clock		=>	clock,
--			reset		=>	reset_n,
--		
--			spi_init	=>	lmkconfig_done,
--			sdi		=>	ad9781_sdo,
--			nCS		=>	ad9781_ncs,
--			sclk		=>	ad9781_sclk,
--			sdio		=>	ad9781_sdi,
--			spi_done	=>	open,
--			seek_out	=>	adc_seek_out
--			);			
			
			
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
			pdwn		=>	ad9653_pwdn,
			sdio		=>	ad9653_sdio,
			sdio_dir	=>	ad9653_sdio_dir,
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
--			strobe_in	=>	strobei_clkd4,
--			i_in			=>	i_out,
--			q_in			=>	q_out,
--			i_out			=>	dac2_i_d,
--			q_out			=>	dac2_q_d,
--			strobe_out	=>	open
--			);

cdc_count_d	<=	std_logic_vector(unsigned(cdc_count_q) + 1);
dac2_i_d			<=	i_out when cdc_count_q(0) = '0' else dac2_i_q;
dac2_q_d			<=	q_out when cdc_count_q(0) = '0' else dac2_q_q;
--dac3_i_d			<=	i_out when cdc_count_q(0) = '0' else dac3_i_q;
--dac3_q_d			<=	q_out when cdc_count_q(0) = '0' else dac3_q_q;

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
hb_isa_inst: entity work.hb_isa
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			
			hrtbt	=>	hb_isa
			);
hb_inst: entity work.heartbeat
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
	  	  	hb_dig	=>	hb_dig,
			hb_ioc	=>	hb_ioc
			);
led0_in(0)	<=	hb_ioc;
led0_in(1)	<=	hb_dig;
led0_in(2)	<=	rfon_q(1);
led0_in(3)	<=	lmk_lock(0) or lmk_ref(0);
led0_in(4)	<=	qstat(1);
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

rfsw			<=	rfon_q(1);
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
			deta2		=>	deta2,
			dtnerr	=>	deta_stp
			);
------------------epcs control for remote firmware and fcc id----------------
epcs_cntl_inst: entity work. epcs_cntl
port map(clock			=>	adc_pll_clk_data,
			reset			=>	reset_n,
			strobe		=>	'1',
			epcs_busy	=>	epcsb,
			address		=>	cnfga,
			data			=>	cnfgd,
			cntl			=>	cnfgc,	  
			result		=>	cnfgr,
			fccid			=>	fccid
			);			
---------------------quench detection------------------
quench_det_inst: entity work.quench_det
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			strobe	=>	strobei_clkd4,
			prbm		=>	prob_mag,
			qmsk		=>	qmsk,
			flt_clr	=>	fault_clear,
			qslope	=>	qslope,
			qrate		=>	qrate,
			qdiff		=>	qdiff,
			qstat		=>	qstat---------[0] present, [1] latched
			);
			
--qstat_d						<=	'0' when fault_clear = '1' else
--								'1' when qstat_rd(0) = '1' else
--								qstat_q;
					
--qstat_cdc					<=	qstat_q & qstat_rd(0);					
-------------------end of quench detection--------------	
--------------------frequency discriminator for SEL------------	
inst_freq_disc_phs: entity work.freq_disc_phs
port map(reset			=>	reset_n,
			clock			=>	adc_pll_clk_data,
			load			=>	'1',
			prbi			=>	iq(2),
			prbq			=>	iq(3),
			phs_sml		=>	phs_sml_disc,
			phs_med		=>	phs_med_disc,
			phs_lrg		=>	phs_lrg_disc,
			phs_xlrg		=>	phs_xlrg_disc
			);			
inst_freq_disc: entity work.freq_disc
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			load		=>	'1',
			phs_sml_in	=>	phs_sml_disc,
			phs_med_in	=>	phs_med_disc,
			phs_lrg_in	=>	phs_lrg_disc,
			phs_xlrg_in	=>	phs_xlrg_disc,
			disc_out	=>	disc_out,
			disc_stp	=>	disc_stp
			);
--disc_comm(71 downto 54)		<=	disc_out(3);			
--disc_comm(53 downto 36)		<=	disc_out(2);
--disc_comm(35 downto 18)		<=	disc_out(1);
--disc_comm(17 downto 0)		<=	disc_out(0);
--------------------end of frequency discriminator for SEL------------
---------------------waveform data------------------------------------
wav_data_in(0)	<=	fltrd(0);
wav_data_in(1)	<=	fltrd(1);
wav_data_in(2)	<=	fltrd(8);
wav_data_in(3)	<=	fltrd(9);
wav_data_in(4)	<=	fltrd(4);
wav_data_in(5)	<=	fltrd(5);
wav_data_in(6)	<=	i_out;
wav_data_in(7)	<=	q_out;
wav_data_in(8)	<=	disc_out(0);	
wav_data_in(9)	<=	deta2;
---------------------end of waveform data------------------------------
------------fiber interface with interlock and hpa
fib_ctl_inst: entity work.fib_ctl
port map(clock		=>	clock,
			reset		=>	reset_n,
			rfon		=>	beam_fsd_fib,
			gmesflt	=>	gmesflt,
			fibin		=>	fib_in(1 downto 0),
			fibmski	=>	fib_msk_set(1 downto 0),
			fibseto	=>	fib_msk_set(13 downto 12),
			fltclr	=>	fault_clear,
			rfprmt	=>	open,
			fibstat	=>	fib_stat,
			fibout	=>	fib_out(1 downto 0)
			
			);
			
--rfprm		<=	fib_stat(3) or fib_stat(2);


deta_disc_pzt(2)	<=	'1' when maglp_q = "10" and phslp_q = "10" else '0';----slow stepper mode


deta_disc_pzt(1 downto 0)		<=	"01" when (maglp_q = "00" or maglp_q = "10") and phslp_q = "01" else----disc for sel or sela
												"00" when (maglp_q = "10" and phslp_q = "10") else----deta for selap
												"11";
												
--stpena_d		<=	stpena when ((maglp_q = "00" or (maglp_q = "10" and xystat(1 downto 0) = "00")) and phslp_q = "01") or (maglp_q = "10" and phslp_q = "10" and xystat(1 downto 0) = "00") else '0';												
----------------------------end of fiber interface-------------------------------
---------------------beam permit generation-------------------------
--inst_beam_permit: entity work. beam_permit
--	port map(clock		=>	adc_pll_clk_data,
--				reset		=>	reset_n,
--				strobe	=>	strobei_clkd4,
--			
--				xystat	=>	xystat,
--				maglp		=>	maglp_q,
--				phslp		=>	phslp_q,
--				clmptm	=>	clmptm,
--				flt_clr	=>	fault_clear,
--			
--				beam_fsd	=>	beam_fsd-------[1]latched,[0]present
--				);


inst_beam_permit: entity work.beam_permit_magphs
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			strobe	=>	strobei_clkd4,
			
			gset		=>	gset,
			gmes		=>	prob_mag,
			gldeth	=>	gldeth,
			gldetl	=>	gldetl(15 downto 0),
				
			gask		=>	gask,
			gdcl		=>	gdcl,
			gdcltl	=>	gdcltl(15 downto 0),
			
			pset		=>	pset,
			pmes		=>	prob_phs,
			pldeth	=>	pldeth,
			pldetl	=>	pldetl(15 downto 0),
			xlimtm	=>	xytmlim(15 downto 0),
			xstathi	=>	xystat(1),
			sftmsk	=>	sftmsk,
			
			rfon		=>	rfon_q(1),					
			maglp		=>	maglp_q,
			phslp		=>	phslp_q,
			
			rmpstat	=>	rmpstat,
			
			flt_clr	=>	fault_clear,
			glde		=>	glde,
			plde		=>	plde,
			sft_flt	=>	sft_flt,
			beam_fsd	=>	beam_fsd
			);

																					
----------------------clock domain crossing from 93 MHz to 100 MHz for sending fiber data out--------------------------------
inst_clk_dom_xing: entity work.clk_dom_xing
port map(clk1		=>	adc_pll_clk_data,-----this is 93 MHz
			clk2		=>	clock,-----this is 125 MHz
			reset		=>	reset_n,
			init_data	=>	adc_lvds_lock_q,		
			ina		=>	deta_stp(17 downto 2),----detune angle
			inb		=>	disc_stp,----28 bit discriminator for stepper chassis
--			inc		=>	qdiff,
			ind		=>	deta_disc_pzt,----stepper select([1..0]:deta=0, disc=1, pzt=2), [2] slow step)
			ine		=>	stpena_q,
			inf		=>	beam_fsd(1),------beam permit signal
			ing		=>	gmesstat(1),
--			inh		=>	dac0_in,
--			ini		=>	dac1_in,
--			inj		=>	dac2_in,
--			ink		=>	dac3_in,
			inl		=>	ratn,
--			inm		=>	frrmp(1),
			
			outa		=>	deta_stp_fib,
			outb		=>	disc_stp_fib,
--			outc		=>	open,
			outd		=>	deta_disc_pzt_fib,
			oute		=>	stpena_fib,
			outf		=>	beam_fsd_fib,
			outg		=>	gmesflt,
--			outh		=>	open,
--			outi		=>	open,
--			outj		=>	open,
--			outk		=>	open,
			outl		=>	ratn_cdc
--			outm		=>	prbp_rd
			);
			

			

--track_en		<=	'1' when stpena_fib = '1' and xystat_rd(1 downto 0) = "00" else '0';
--------------------------stepper data for fiber control-------------------
stepper_data_inst: entity work.stepper_data
port map (clock 			=>	clock,
			reset 			=>	reset_n,		
			deta_in      	=>	deta_stp_fib,
			disc_in 			=>	disc_stp_fib,
			pzt_in 			=>	x"0000",
			deta_disc_pzt  =>	deta_disc_pzt_fib(1 downto 0),
			slow				=>	deta_disc_pzt_fib(2),
			track_en			=>	stpena_fib,
      	crc_done 		=>	crc_done_stp,
			data_out 		=>	crc_data_stp
			);
epoly_div_stp_inst: entity work. polynomial_division
port map(clock 			=>	clock,
			reset 			=>	reset_n,
			start_crc 		=>	start_crc_stp,
			data_in			=>	crc_data_stp,
--	  denom : in std_logic_vector(8 downto 0);-----x^8+x^2+x+1 ("100000111")
			crc				=>	open,
			data_out_crc	=>	crc_data_out_stp,
			crc_done			=>	crc_done_stp
			);
fcc_data_out_stp_inst: entity work.fcc_data_out
port map(reset			=>	reset_n,	
			clock 			=>	clock,
			data_out 		=>	crc_data_out_stp,
			fiber_data_out =>	fib_out(2),
			start_crc 		=>	start_crc_stp
			);

----------------------pulse mode for gradient calibration and Qext measurement------------
pulse_mode_inst: entity work.pulse_mode
port map(clock			=>	adc_pll_clk_data,
			reset			=>	reset_n,
			pls_on		=>	plson,
			pls_off		=>	plsoff,
			plsmode		=>	plsmode,
			plstrig_in	=>	dig_in(1),
			pls_out		=>	pulse_out
			);			
					
dig_out(1)		<=	pulse_out;
-----------------klystron characterization within 200 us-----------------------------------
kly_char_inst: entity work.kly_char
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			takei		=>	wavs_takei,
			mloop		=>	maglp_q,
			ploop		=>	phslp_q,
			strobe	=>	'1',
			kly_ch	=>	kly_ch,
			glos		=>	glos,
			glos_out	=>	glos_kly,
			kly_ch_done	=>	kly_ch_done
			);

------------------------diag dac test code-----------------

dac3_in	<=	prob_i_flt(17 downto 2);
dac2_in	<=	prob_q_flt(17 downto 2);
dac1_in	<=	disc_out(0)(17 downto 2);
dac0_in	<=	deta2(17 downto 2);


	

diagdac0_inst: entity work.dac8831
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			d_in	=>	dac0_in,
		
			ncs	=>	dac_ncs,--dig_a(7),
			sclk	=>	dac_sclk,--dig_a(8),
			sdi	=>	dac0_sdi--dig_a(6)
			);
diagdac1_inst: entity work.dac8831
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			d_in	=>	dac1_in,
		
			ncs	=>	open,
			sclk	=>	open,
			sdi	=>	dac1_sdi--dig_a(5)
			);
diagdac2_inst: entity work.dac8831
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			d_in	=>	dac2_in,
		
			ncs	=>	open,
			sclk	=>	open,
			sdi	=>	dac2_sdi--dig_a(4)
			);			
diagdac3_inst: entity work.dac8831
port map(clock	=>	adc_pll_clk_data,
			reset	=>	reset_n,
			d_in	=>	dac3_in,
		
			ncs	=>	open,
			sclk	=>	open,
			sdi	=>	dac3_sdi--dig_a(3)
			);
			
			
---------------------------------gmes fault------------------------
inst_gmesfault: entity work. gmesfault
	port map(clock		=>	adc_pll_clk_data,
				reset		=>	reset_n,
				strobe	=>	strobei_clkd4,
				rfsw		=>	rfon_q(1),
				gmes		=>	prob_mag,
				gmeslvl	=>	gmeslvl,
				gmestmr	=>	gmestmr(15 downto 0),
				fltclr	=>	fault_clear,
				gmesmsk	=>	gmesmsk,
				gmesstat	=>	gmesstat
				);


---------------------------lopw interlock to turn rf off if LO goes below a thershold------------------------

inst_lopwfault: entity work.lopwfault
port map(clock		=>	adc_pll_clk_data,
			reset		=>	reset_n,
			strobe	=>	'1',			
			lopw		=>	adc0_a,
			lopwth	=>	lopwth(15 downto 0),
			lopwtmr	=>	lopwtl(15 downto 0),
			fltclr	=>	fault_clear,
			lopwmsk	=>	lopwmsk,
			lopwstat	=>	lopwstat
			);				
	
	



end architecture behavioral;