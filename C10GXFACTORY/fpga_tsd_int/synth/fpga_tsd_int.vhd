-- fpga_tsd_int.vhd

-- Generated using ACDS version 18.1 222

library IEEE;
library altera_temp_sense_181;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fpga_tsd_int is
	port (
		corectl : in  std_logic                    := '0'; -- corectl.corectl
		reset   : in  std_logic                    := '0'; --   reset.reset
		tempout : out std_logic_vector(9 downto 0);        -- tempout.tempout
		eoc     : out std_logic                            --     eoc.eoc
	);
end entity fpga_tsd_int;

architecture rtl of fpga_tsd_int is
	component altera_temp_sense_cmp is
		generic (
			DEVICE_FAMILY : string := ""
		);
		port (
			corectl : in  std_logic                    := 'X'; -- corectl
			reset   : in  std_logic                    := 'X'; -- reset
			tempout : out std_logic_vector(9 downto 0);        -- tempout
			eoc     : out std_logic                            -- eoc
		);
	end component altera_temp_sense_cmp;

	for temp_sense_0 : altera_temp_sense_cmp
		use entity altera_temp_sense_181.altera_temp_sense;
begin

	temp_sense_0 : component altera_temp_sense_cmp
		generic map (
			DEVICE_FAMILY => "Cyclone 10 GX"
		)
		port map (
			corectl => corectl, -- corectl.corectl
			reset   => reset,   --   reset.reset
			tempout => tempout, -- tempout.tempout
			eoc     => eoc      --     eoc.eoc
		);

end architecture rtl; -- of fpga_tsd_int
