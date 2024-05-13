	component dpram_ram_2port_0 is
		port (
			data_a    : in  std_logic_vector(17 downto 0) := (others => 'X'); -- datain_a
			q_a       : out std_logic_vector(17 downto 0);                    -- dataout_a
			data_b    : in  std_logic_vector(17 downto 0) := (others => 'X'); -- datain_b
			q_b       : out std_logic_vector(17 downto 0);                    -- dataout_b
			address_a : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address_a
			address_b : in  std_logic_vector(11 downto 0) := (others => 'X'); -- address_b
			wren_a    : in  std_logic                     := 'X';             -- wren_a
			wren_b    : in  std_logic                     := 'X';             -- wren_b
			clock_a   : in  std_logic                     := 'X';             -- clk
			clock_b   : in  std_logic                     := 'X'              -- clk
		);
	end component dpram_ram_2port_0;

	u0 : component dpram_ram_2port_0
		port map (
			data_a    => CONNECTED_TO_data_a,    --    data_a.datain_a
			q_a       => CONNECTED_TO_q_a,       --       q_a.dataout_a
			data_b    => CONNECTED_TO_data_b,    --    data_b.datain_b
			q_b       => CONNECTED_TO_q_b,       --       q_b.dataout_b
			address_a => CONNECTED_TO_address_a, -- address_a.address_a
			address_b => CONNECTED_TO_address_b, -- address_b.address_b
			wren_a    => CONNECTED_TO_wren_a,    --    wren_a.wren_a
			wren_b    => CONNECTED_TO_wren_b,    --    wren_b.wren_b
			clock_a   => CONNECTED_TO_clock_a,   --   clock_a.clk
			clock_b   => CONNECTED_TO_clock_b    --   clock_b.clk
		);

