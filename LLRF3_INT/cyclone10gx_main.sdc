create_clock -period 8.0 [get_ports sfp_refclk_p]
create_clock -period 10.0 [get_ports clocK_100]

derive_pll_clocks
derive_clock_uncertainty