	component epcs is
		port (
			clkin         : in  std_logic                     := 'X';             -- clk
			read          : in  std_logic                     := 'X';             -- read
			rden          : in  std_logic                     := 'X';             -- rden
			addr          : in  std_logic_vector(31 downto 0) := (others => 'X'); -- addr
			write         : in  std_logic                     := 'X';             -- write
			datain        : in  std_logic_vector(7 downto 0)  := (others => 'X'); -- datain
			sector_erase  : in  std_logic                     := 'X';             -- sector_erase
			wren          : in  std_logic                     := 'X';             -- wren
			en4b_addr     : in  std_logic                     := 'X';             -- en4b_addr
			reset         : in  std_logic                     := 'X';             -- reset
			sce           : in  std_logic_vector(2 downto 0)  := (others => 'X'); -- sce
			dataout       : out std_logic_vector(7 downto 0);                     -- dataout
			busy          : out std_logic;                                        -- busy
			data_valid    : out std_logic;                                        -- data_valid
			illegal_write : out std_logic;                                        -- illegal_write
			illegal_erase : out std_logic                                         -- illegal_erase
		);
	end component epcs;

	u0 : component epcs
		port map (
			clkin         => CONNECTED_TO_clkin,         --         clkin.clk
			read          => CONNECTED_TO_read,          --          read.read
			rden          => CONNECTED_TO_rden,          --          rden.rden
			addr          => CONNECTED_TO_addr,          --          addr.addr
			write         => CONNECTED_TO_write,         --         write.write
			datain        => CONNECTED_TO_datain,        --        datain.datain
			sector_erase  => CONNECTED_TO_sector_erase,  --  sector_erase.sector_erase
			wren          => CONNECTED_TO_wren,          --          wren.wren
			en4b_addr     => CONNECTED_TO_en4b_addr,     --     en4b_addr.en4b_addr
			reset         => CONNECTED_TO_reset,         --         reset.reset
			sce           => CONNECTED_TO_sce,           --           sce.sce
			dataout       => CONNECTED_TO_dataout,       --       dataout.dataout
			busy          => CONNECTED_TO_busy,          --          busy.busy
			data_valid    => CONNECTED_TO_data_valid,    --    data_valid.data_valid
			illegal_write => CONNECTED_TO_illegal_write, -- illegal_write.illegal_write
			illegal_erase => CONNECTED_TO_illegal_erase  -- illegal_erase.illegal_erase
		);

