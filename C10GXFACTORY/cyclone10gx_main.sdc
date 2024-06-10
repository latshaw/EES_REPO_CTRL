create_clock -name {clock_100} -period 10.000 -waveform { 0.000 5.000 } [get_ports {clock_100}]
create_clock -name {sfp_refclk_p} -period 8.000 -waveform { 0.000 4.000 } [get_ports {sfp_refclk_p}]
derive_pll_clocks
derive_clock_uncertainty