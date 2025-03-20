-- Assignment for filament control modules.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
use work.HPA.all;

entity fil_ramp is
generic( BASE_ADDR :unsigned(23 downto 0) := x"00005B");
 port
     (
       reset_n    : in std_logic;
       clock      : in std_logic;

       -- local bus inputs
       lb_valid   : in std_logic;
       lb_rnw     : in std_logic;                     --
       lb_addr    : in std_logic_vector(23 downto 0); --
       lb_renable : in std_logic;
       lb_wdata   : in std_logic_vector(15 downto 0); --

       filon      : in std_logic;
       hvon       : in std_logic;
       bypass     : in std_logic_vector(7 downto 0);

       sck        : out std_logic;
       cs         : out std_logic;
       sdi        : out std_logic;

	   -- Local bus output
       lb_rdata   : out std_logic_vector(15 downto 0)
     );
end fil_ramp;

architecture struct of fil_ramp is
--Behaviour in fil_dac.vhd
component fil_dac
 port(
       reset_n  : in std_logic;
       clock    : in std_logic;
       load     : in std_logic;
       data     : in std_logic_vector(15 downto 0);
       addr     : in std_logic_vector(2 downto 0);
       sck      : out std_logic;
       cs_n     : out std_logic;
       sdi      : out std_logic
     );
end component;
--Behaviour in fil_ctrl.vhd
component fil_ctrl
 port(
       reset_n   : in std_logic;
       clock     : in std_logic;
       filon     : in std_logic;
       hvon      : in std_logic;
       filsetin  : in std_logic_vector(15 downto 0);
       bypass    : in std_logic;
       update    : out std_logic;
       filsetout : out std_logic_vector(15 downto 0)
     );
end component;
--Behaviour in fil_mux.vhd
component fil_mux
 port(
       reset_n    : in std_logic;
       clock      : in std_logic;
       update     : in std_logic;
       filsetout1 : in std_logic_vector(15 downto 0);
       filsetout2 : in std_logic_vector(15 downto 0);
       filsetout3 : in std_logic_vector(15 downto 0);
       filsetout4 : in std_logic_vector(15 downto 0);
       filsetout5 : in std_logic_vector(15 downto 0);
       filsetout6 : in std_logic_vector(15 downto 0);
       filsetout7 : in std_logic_vector(15 downto 0);
       filsetout8 : in std_logic_vector(15 downto 0);
       load_dac   : out std_logic;
       addr       : out std_logic_vector(2 downto 0);
       data       : out std_logic_vector(15 downto 0)
     );
end component;
--Behaviour in fil_regs.vhd
component fil_regs
generic (BASE_ADDR : unsigned(23 downto 0));
 port(
       reset_n    : in std_logic;
       clock      : in std_logic;
       lb_valid   : in std_logic;
       lb_rnw     : in std_logic;
       lb_addr    : in std_logic_vector(23 downto 0);
       lb_renable : in std_logic;
       lb_wdata   : in std_logic_vector(15 downto 0);
       lb_rdata   : out std_logic_vector(15 downto 0);
       fil_set    : out std_logic_vector_array16(0 to 7)
     );
end component;

signal fil_set    : std_logic_vector_array16(0 to 7);
signal load_dac   : std_logic;
signal data       : std_logic_vector(15 downto 0);
signal addr       : std_logic_vector(2 downto 0);
signal filsetout1 : std_logic_vector(15 downto 0);
signal filsetout2 : std_logic_vector(15 downto 0);
signal filsetout3 : std_logic_vector(15 downto 0);
signal filsetout4 : std_logic_vector(15 downto 0);
signal filsetout5 : std_logic_vector(15 downto 0);
signal filsetout6 : std_logic_vector(15 downto 0);
signal filsetout7 : std_logic_vector(15 downto 0);
signal filsetout8 : std_logic_vector(15 downto 0);
signal update_sum : std_logic;
signal update_vec : std_logic_vector(7 downto 0);

--=====================================================================================--
begin

update_sum <= update_vec(0);--'1' when update_vec > 0 else '0';

fil_dac_inst : fil_dac
port map(
           reset_n => reset_n,
           clock => clock,
           load => load_dac,
           data => data,
           addr => addr,
           sck => sck,
           cs_n => cs,
           sdi => sdi
        );


fil_mux_inst : fil_mux
port map(
           reset_n => reset_n,
           clock => clock,
           update => update_sum,
           filsetout1 => filsetout1,
           filsetout2 => filsetout2,
           filsetout3 => filsetout3,
           filsetout4 => filsetout4,
           filsetout5 => filsetout5,
           filsetout6 => filsetout6,
           filsetout7 => filsetout7,
           filsetout8 => filsetout8,
           load_dac => load_dac,
           addr => addr,
           data => data
        );


fil_regs_inst : fil_regs
generic map(BASE_ADDR => BASE_ADDR)
port map(
           reset_n => reset_n,
           clock => clock,
           lb_valid => lb_valid,
           lb_rnw => lb_rnw,
           lb_addr => lb_addr,
           lb_renable => lb_renable,
           lb_wdata => lb_wdata,
           lb_rdata => lb_rdata,
           fil_set => fil_set
        );


-- cavity 1
fil_ctrl_inst1 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(0) ,
           bypass => bypass(0),
           update => update_vec(0),
           filsetout => filsetout1
        );


-- cavity 2
fil_ctrl_inst2 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(1) ,
           bypass => bypass(1),
           update => update_vec(1),
           filsetout => filsetout2
        );

-- cavity 3
fil_ctrl_inst3 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(2) ,
           bypass => bypass(2),
           update => update_vec(2),
           filsetout => filsetout3
        );

-- cavity 4
fil_ctrl_inst4 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(3) ,
           bypass => bypass(3),
           update => update_vec(3),
           filsetout => filsetout4
        );

-- cavity 5
fil_ctrl_inst5 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(4) ,
           bypass => bypass(4),
           update => update_vec(4),
           filsetout => filsetout5
        );

-- cavity 6
fil_ctrl_inst6 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(5) ,
           bypass => bypass(5),
           update => update_vec(5),
           filsetout => filsetout6
        );

-- cavity 7
fil_ctrl_inst7 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(6) ,
           bypass => bypass(6),
           update => update_vec(6),
           filsetout => filsetout7
        );

-- cavity 8
fil_ctrl_inst8 : fil_ctrl
port map(
           reset_n => reset_n,
           clock => clock,
           filon => filon,
           hvon => hvon,
           filsetin => fil_set(7) ,
           bypass => bypass(7),
           update => update_vec(7),
           filsetout => filsetout8
        );

end struct;