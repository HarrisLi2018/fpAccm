create_clock -name "iCLK_50" -period 20.000ns [get_ports {iCLK_50}]
derive_pll_clocks
derive_clock_uncertainty