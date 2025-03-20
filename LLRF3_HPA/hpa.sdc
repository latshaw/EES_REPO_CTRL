create_clock clock -period 10.0
derive_clock_uncertainty
create_clock sfp_refclk_p -period 8.0
derive_clock_uncertainty
create_clock scl_cnt_q[7] -period 2560.0
derive_clock_uncertainty
derive_pll_clocks
derive_clock_uncertainty