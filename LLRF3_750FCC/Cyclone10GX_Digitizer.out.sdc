create_clock -period 10.0 [get_ports clock]
create_clock -period 8.0 [get_ports sfp_refclk_p]
create_clock -period 2.5 [get_ports adc_dclk_p]
create_clock -period 5.0 [get_ports dac_dco_p]

derive_pll_clocks
derive_clock_uncertainty