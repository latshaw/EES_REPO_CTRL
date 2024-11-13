#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -from {b2v_inst16|CYCLONE_inst|cdc_*|data_latch[*]} -to {b2v_inst16|CYCLONE_inst|cdc_4|data_pipe[*]} -setup -end 8
set_multicycle_path -from {b2v_inst16|CYCLONE_inst|cdc_*|data_latch[*]} -to {b2v_inst16|CYCLONE_inst|cdc_4|data_pipe[*]} -hold -end 8
set_multicycle_path -from [get_clocks {b2v_inst16|CYCLONE_inst|pll20_inst|iopll_0|clk20}] -to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -setup -end 8
set_multicycle_path -from [get_clocks {b2v_inst16|CYCLONE_inst|pll20_inst|iopll_0|clk20}] -to [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -hold -end 8
set_multicycle_path -from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -to [get_clocks {b2v_inst16|CYCLONE_inst|pll20_inst|iopll_0|clk20}] -setup -end 8
set_multicycle_path -from [get_clocks {inst_comms_top|u0|xcvr_native_a10_0|tx_pma_clk}] -to [get_clocks {b2v_inst16|CYCLONE_inst|pll20_inst|iopll_0|clk20}] -hold -end 8