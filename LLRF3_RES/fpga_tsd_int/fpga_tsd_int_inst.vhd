	component fpga_tsd_int is
		port (
			corectl : in  std_logic                    := 'X'; -- corectl
			reset   : in  std_logic                    := 'X'; -- reset
			tempout : out std_logic_vector(9 downto 0);        -- tempout
			eoc     : out std_logic                            -- eoc
		);
	end component fpga_tsd_int;

	u0 : component fpga_tsd_int
		port map (
			corectl => CONNECTED_TO_corectl, -- corectl.corectl
			reset   => CONNECTED_TO_reset,   --   reset.reset
			tempout => CONNECTED_TO_tempout, -- tempout.tempout
			eoc     => CONNECTED_TO_eoc      --     eoc.eoc
		);

