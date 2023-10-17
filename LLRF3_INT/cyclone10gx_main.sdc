create_clock -period 8.0 [get_ports sfp_refclk_p]

derive_pll_clocks
derive_clock_uncertainty