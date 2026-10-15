create_clock -period 10 -name clk_sys [get_ports SYSCLOCK]
derive_pll_clocks
derive_clock_uncertainty