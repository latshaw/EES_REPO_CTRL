library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.components.all;

entity comms_regbank is
--	generic(LB_AWI			:	integer := 24;
--			LB_DWI			:	integer	:=	32
--		);
	port(reset				:	in std_logic;
			lb_clk			:	in std_logic;
			lb_valid			:	in std_logic;
			lb_rnw			:	in std_logic;
			lb_addr			:	in std_logic_vector(23 downto 0);
			lb_wdata			:	in std_logic_vector(31 downto 0);
			lb_renable		:	in std_logic;-- Ignored in this module
			lb_rdata			:	out std_logic_vector(31 downto 0);
			wav_data			:	in	reg18_10;
			reg_data			:	in std_logic_vector(17 downto 0)
			

			);
end entity comms_regbank;
architecture behavior of comms_regbank is


type reg_record  is record


	lb_addr_r	:	std_logic_vector(23 downto 0);
	regbank_mux	:	signed(31 downto 0);
end record reg_record;
signal lb_wr_valid	:	std_logic;
signal lb_rd_valid	:	std_logic;
signal d,q	:	reg_record;

signal lb_din			:	signed(31 downto 0);

signal lb_addr_int		:	integer;
signal lb_addr_low_int	:	integer;
signal lb_addr_high_int	:	integer;
signal lb_addr_reg_int	:	integer;
signal lb_addr_r_high_int	:	integer; 
signal lb_addr_r			:	std_logic_vector(23 downto 0);







begin



lb_wr_valid		<=	lb_valid and not lb_rnw;
lb_rd_valid		<=	lb_valid and lb_rnw;

lb_addr_int		<=	to_integer(unsigned(lb_addr));
lb_addr_low_int	<=	to_integer(unsigned(lb_addr(7 downto 0)));
lb_addr_high_int	<=	to_integer(unsigned(lb_addr(23 downto 12)));

--lb_addr_reg_int	<=	to_integer(unsigned(lb_addr(23 downto 4)));

--lb_addr_r_high_int	<=	to_integer(unsigned(lb_addr_r(23 downto 12)));
--frmv					<=	x"0064";
--c10gx_tmp_sgn		<=	'0' & c10gx_tmp;

d.lb_addr_r			<=	lb_addr when lb_rd_valid = '1' else q.lb_addr_r;

process(lb_clk, reset)
begin
	if(reset = '0') then
		q.lb_addr_r	<=	(others	=>	'0');
		q.regbank_mux	<=	(others	=>	'0');
		lb_rdata		<=	(others	=>	'0');
	elsif(rising_edge(lb_clk)) then
		lb_rdata		<=	std_logic_vector(lb_din);
		q	<=	d;
	end if;
end process;



--with lb_addr_low_int select
--d.reg_bank(0)		<=	resize(signed(regbank_0(0)),32) when 0,
--							resize(signed(regbank_0(1)),32) when 1,
--							resize(signed(regbank_0(2)),32) when 2,
--							resize(signed(regbank_0(3)),32) when 3,	
--							resize(signed(regbank_0(4)),32) when 4,---rfl i
--							resize(signed(regbank_0(5)),32) when 5,---rfl q
--							resize(signed(regbank_0(6)),32) when 6,---rfl m
--							resize(signed(regbank_0(7)),32) when 7,---rfl p
--							resize(signed(regbank_0(8)),32) when 8,---fwd i
--							resize(signed(regbank_0(9)),32) when 9,---fwd q
--							resize(signed(regbank_0(10)),32) when 10,---fwd m
--							resize(signed(regbank_0(11)),32) when 11,---fwd p
--							resize(signed(regbank_0(12)),32) when 12,---rfr i
--							resize(signed(regbank_0(13)),32) when 13,---rfr q
--							resize(signed(regbank_0(14)),32) when 14,---rfr m
--							resize(signed(regbank_0(15)),32) when 15,---rfr p
--							x"faceface" when others;
							
--with lb_addr_low_int select
--d.reg_bank(1)		<=	resize(signed(fltrd(17 downto 0)),32) when 0,---imes
--							resize(signed(fltrd(35 downto 18)),32) when 1,---pmes
--							resize(signed(frrmp(17 downto 0)),32) when 2,---gmes
--							resize(signed(frrmp(35 downto 18)),32) when 3,---pmes										
--							
--							q.rw_reg(0) when 7,--gset
--							q.rw_reg(1) when 8,--pset
--							
--							resize(signed(gerror),32) when 13,
--							resize(signed(perror),32) when 14,
--							x"faceface" when others;
--							
----with lb_addr_low_int select
--d.reg_bank(2)		<=	x"faceface" ;
--
--with lb_addr_low_int select
--d.reg_bank(3)		<=	q.rw_reg(2) when 0,--mpro
--							q.rw_reg(3) when 1,--mi
--							q.rw_reg(4) when 2,--mirate
--							
--							q.rw_reg(5) when 5,--ppro
--							q.rw_reg(6) when 6,--pi
--							q.rw_reg(7) when 7,--pirate
--							x"faceface" when others; 
--							
--with lb_addr_low_int select
--d.reg_bank(4)		<=	q.rw_reg(8) when 2,--glos							
--							q.rw_reg(9) when 3,--plos	
--							q.rw_reg(10) when 6,--poff
--							resize(signed(iask),32) when 9,
--							resize(signed(qask),32) when 10,
--							resize(signed(gask),32) when 11,
--							resize(signed(pask),32) when 12,
--							x"faceface" when others;
--
--with lb_addr_low_int select
--d.reg_bank(5)		<=	q.rw_reg(11) when 0,--tdoff						
--							resize(signed(cfqea),32) when 1,
--							resize(signed(deta),32) when 2,
--							resize(signed(disc(71 downto 54)),32) when 3,--xlrg
--							resize(signed(disc(53 downto 36)),32) when 4,--lrg
--							resize(signed(disc(35 downto 18)),32) when 5,--med
--							resize(signed(disc(17 downto 0)),32) when 6,--sml
--							--disc(89 downto 72) when 7,--result
--							x"faceface" when others;
--							
----with lb_addr_low_int select
--d.reg_bank(6)		<=	x"faceface";						
--
--with lb_addr_low_int select
--d.reg_bank(7)		<=	resize(signed(c10gx_tmp_sgn),32) when 2,
--							resize(signed(frmv),32) when 3,
--							resize(signed(stat1),32) when 4,
--							resize(signed(stat2),32) when 5,
--							resize(signed(stat3),32) when 6,
--							q.rw_reg(12) when 7,--cntl1
--							q.rw_reg(13) when 8,--cntl2
--							q.rw_reg(14) when 9,--cntl3
--							q.rw_reg(15) when 10,--cntl4
--							x"faceface" when others;
--							
--with lb_addr_low_int select
--d.reg_bank(8)		<=	resize(signed(fib_stat_r),32) when 4,
--							q.rw_reg(16) when 5,
--							x"faceface" when others;
--							
--
--d.reg_bank(9)		<=	x"faceface";
--
--with lb_addr_low_int select
--d.reg_bank(10)		<=	signed(rfon_reg) when 15,--q.rw_reg(17) when 15,--rfon							
--							x"faceface" when others;
--							
--with lb_addr_low_int select
--d.reg_bank(11)		<=	q.rw_reg(18) when 0,--ratn							
--							q.rw_reg(19) when 8,--xlimlo
--							q.rw_reg(20) when 9,--xlimhi
--							q.rw_reg(21) when 10,--ylimlo
--							q.rw_reg(22) when 11,--ylimhi
--							x"faceface" when others;
--
--with lb_addr_low_int select
--d.reg_bank(12)		<=	q.rw_reg(23) when 0,--stpena
--							q.rw_reg(24) when 8,--wavstm,cir buffer rate
--							q.rw_reg(25) when 9,--wavhtm,flt/harvester buffer rate
--							x"faceface" when others;
							
--with lb_addr_high_int select
--d.regbank_mux			<=	resize(signed(reg_data),32) when 0,
--							x"0000ffff" when 1,
--							x"0000eeee" when 2,
							
--							resize(signed(reg_data(1)),32) when 1,
--							resize(signed(reg_data(2)),32) when 2,
--							resize(signed(reg_data(3)),32) when 3,
--							resize(signed(reg_data(4)),32) when 4,
--							resize(signed(reg_data(5)),32) when 5,
--							resize(signed(reg_data(6)),32) when 6,
--							resize(signed(reg_data(7)),32) when 7,
--							resize(signed(reg_data(8)),32) when 8,
--							resize(signed(reg_data(9)),32) when 9,
--							resize(signed(reg_data(10)),32) when 10,
--							resize(signed(reg_data(11)),32) when 11,
--							resize(signed(reg_data(12)),32) when 12,
--							resize(signed(reg_data(13)),32) when 13,
--							resize(signed(reg_data(14)),32) when 14,
--							resize(signed(reg_data(15)),32) when 15,
--							resize(signed(reg_data(0)),32) when 16,
--							resize(signed(reg_data(1)),32) when 17,
--							resize(signed(reg_data(2)),32) when 18,
--							resize(signed(reg_data(3)),32) when 19,
							
							
--							x"faceface" when others;
							
with lb_addr_high_int select
lb_din				<=	resize(signed(reg_data),32) when 0,
							resize(signed(wav_data(0)),32) when 1,
							resize(signed(wav_data(1)),32) when 2,
							resize(signed(wav_data(2)),32) when 3,
							resize(signed(wav_data(3)),32) when 4,
							resize(signed(wav_data(4)),32) when 5,
							resize(signed(wav_data(5)),32) when 6,
							resize(signed(wav_data(6)),32) when 7,
							resize(signed(wav_data(7)),32) when 8,
							resize(signed(wav_data(8)),32) when 9,
							resize(signed(wav_data(9)),32) when 10,
							x"faceface" when others;
							

--lb_din				<=	resize(signed(reg_data),32) when q.lb_addr_r(23 downto 7) = '0'&x"0000" else
--							x"faceface";


							
							
end architecture behavior;			

			
