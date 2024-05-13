--------------beam permit signal--------------------------------------
--------------beam should only be permitted in SELAP(maglp = "10" and phslp = "10" when amplitude and phase are stable------
--------------if |GSET-GMES|>GLDE or |PSET-PMES|>PLDE for clmptm, then beam permit will be pulled low and latched----------
-- 4/17/24, JAL, added beams fsd will be pulled low if gask >= gdcl
--			   added fault clear to reset counters
-- 4/19/24 allowed faults to be masked
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity beam_permit_magphs is
	port(clock		:	in	std_logic;
			reset		:	in	std_logic;
			strobe	:	in	std_logic;
			
			gset		:	in	std_logic_vector(17 downto 0);
			gmes		:	in	std_logic_vector(17 downto 0);
			gldeth	:	in	std_logic_vector(17 downto 0);  -------gradient loop error threshold in counts
			gldetl	:	in	std_logic_vector(15 downto 0);  -------gradient loop error time limit in msec
				
			gask		:	in std_logic_vector(17 downto 0);
			gdcl		:	in std_logic_vector(17 downto 0);
			gdcltl	:	in std_logic_vector(15 downto 0);			
			
			pset		:	in	std_logic_vector(17 downto 0);
			pmes		:	in	std_logic_vector(17 downto 0);			
			pldeth	:	in	std_logic_vector(17 downto 0);  -------phase loop error in degrees 
			pldetl	:	in	std_logic_vector(15 downto 0);  -------phase loop error time limit in msec
			xlimtm	:	in	std_logic_vector(15 downto 0);
			xstathi	:	in std_logic;
			sftmsk	:	in std_logic_vector(3 downto 0);   ----xlimtm, gdcl,plde,glde	  NOTE only bit 3 is implemented
								
			rfon		:	in std_logic;
			maglp		:	in	std_logic_vector(1 downto 0);
			phslp		:	in	std_logic_vector(1 downto 0);
				
			rmpstat	:	in std_logic_vector(1 downto 0);    -----[1]phs_rmp, [0]grad_rmp
			flt_clr	:	in	std_logic;
			glde		:	out std_logic_vector(17 downto 0);
			plde		:	out std_logic_vector(17 downto 0);
			sft_flt	:	out std_logic_vector(7 downto 0);------xlimhi_flt,gdcl_flt , plde_flt,glde_flt 7..4 latched, 3..0 present
			beam_fsd	:	out std_logic_vector(1 downto 0)    -------[1]latched,[0]present
			);
end entity beam_permit_magphs;
architecture behavior of beam_permit_magphs is
type reg_record is record


gmes			:	signed(17 downto 0);
gset			:	signed(17 downto 0);
glde			:	signed(17 downto 0);
gask			:	unsigned(17 downto 0);
gdcl			:	unsigned(17 downto 0);
gask_mul		:	unsigned(33 downto 0);
gask_cmp		:	unsigned(17 downto 0);	
pmes			:	signed(17 downto 0);
pset			:	signed(17 downto 0);
plde			:	signed(17 downto 0);
plde_int		:	signed(17 downto 0);
gldeth		:	signed(17 downto 0);
gldetl		:	integer range 0 to 2**26-1;
pldeth		:	signed(17 downto 0);
pldetl		:	integer range 0 to 2**26-1;
gdcltl		:	integer range 0 to 2**26-1;
xlimtm		:	integer range 0 to 2**26-1;
xstathi		:	std_logic;
sftmsk		:	std_logic_vector(3 downto 0);
glde_cnt		:	integer range 0 to 2**26-1;
plde_cnt		:	integer range 0 to 2**26-1;
gdcl_cnt		:	integer range 0 to 2**26-1;
xlim_cnt		:	integer range 0 to 2**26-1;
maglp			:	std_logic_vector(1 downto 0);
phslp			:	std_logic_vector(1 downto 0);
glde_out		:	std_logic_vector(17 downto 0);
plde_out		:	std_logic_vector(17 downto 0);
rmpstat		:	std_logic_vector(1 downto 0);
flt_clr		:	std_logic;
sft_flt		:	std_logic_vector(7 downto 0);	
rfon			:	std_logic;
beam_fsd		:	std_logic_vector(3 downto 0);
end record reg_record;
signal d,q	:	reg_record;

constant cordic_gain	:	unsigned(15 downto 0)	:=	x"4dba"; -----19898/32768 is cordic multiplication factor 0.607239

begin

d.gmes		<=	signed(gmes);
d.gset		<=	signed(gset);
d.pmes		<=	signed(pmes);
d.pset		<=	signed(pset);

d.gask		<=	unsigned(gask);
d.gdcl		<=	unsigned(gdcl);

d.gldeth	<=	signed(gldeth);
d.pldeth	<=	signed(pldeth);

d.gask_mul	<=	q.gask * cordic_gain;
d.gask_cmp	<=	"01"&x"ffff" when q.gask_mul(33) = '0' and q.gask_mul(32) /= '0' else
					q.gask_mul(32 downto 15);
	
d.glde		<=	q.gset - q.gmes when (q.gset > q.gmes) else q.gmes - q.gset;


d.plde_int	<=	q.pset - q.pmes;
d.plde		<=	q.plde_int when q.plde_int(17) = '0' else not q.plde_int;
	
d.glde_out	<=	std_logic_vector(q.gset - q.gmes);
d.plde_out	<=	std_logic_vector(q.pset - q.pmes);

glde		<=	q.glde_out;
plde		<=	q.plde_out;



d.maglp		<=	maglp;
d.phslp		<=	phslp;
d.rmpstat	<=	rmpstat;
d.flt_clr	<=	flt_clr;

d.rfon		<=	rfon;
d.xstathi	<=	xstathi;
d.sftmsk		<=	sftmsk;


d.gldetl	<=	to_integer(unsigned(gldetl&x"00"&"00"));	
d.pldetl	<=	to_integer(unsigned(pldetl&x"00"&"00"));
d.gdcltl	<=	to_integer(unsigned(gdcltl&x"00"&"00"));
d.xlimtm	<=	to_integer(unsigned(xlimtm&x"00"&"00"));
	
d.beam_fsd(0)	<=	'1' when q.glde > q.gldeth and q.rmpstat(0) = '0' else '0'; -- the difference between gmes and gset is above the threshold
	
d.beam_fsd(1)	<=	'1' when q.plde > q.pldeth and q.rmpstat = "00" else '0';   -- the difference between pmes and pset is above the threshold
	
--d.beam_fsd(2)	<=	'0' when q.gask_cmp < q.gdcl else '1';
d.beam_fsd(2)	<=	'0' when q.gask < q.gdcl else '1'; -- high when gask is above the gradiant clamp

d.glde_cnt		<=	0              when q.rfon = '0' or (q.maglp /= "10" or q.phslp /= "10") or q.beam_fsd(0) = '0' or q.flt_clr = '1' else
						q.glde_cnt + 1 when q.rfon = '1' and (q.maglp = "10" and q.phslp = "10") and q.beam_fsd(0) = '1' and q.glde_cnt /= q.gldetl else -- glde increments when above threshold
						q.glde_cnt;

d.plde_cnt		<=	0              when q.rfon = '0' or q.beam_fsd(1) = '0' or q.flt_clr = '1' else
						q.plde_cnt + 1 when q.rfon = '1' and q.maglp = "10" and q.phslp = "10" and q.beam_fsd(1) = '1' and q.plde_cnt /= q.pldetl else -- plde increments when above threshold
						q.plde_cnt;
						
d.gdcl_cnt		<=	0              when q.rfon = '0' or q.beam_fsd(2) = '0' or q.flt_clr = '1' else
						q.gdcl_cnt + 1 when q.rfon = '1' and q.maglp = "10" and q.phslp = "10" and q.beam_fsd(2) = '1' and q.gdcl_cnt /= q.gdcltl else -- gldcl incrments during overdrive (gask >= gdcl)
						q.gdcl_cnt;
					
d.xlim_cnt		<=	0              when q.rfon = '0' or q.beam_fsd(0) = '0' or q.maglp /= "10" or q.flt_clr = '1' else
						q.xlim_cnt + 1 when q.rfon = '1' and q.maglp = "10" and q.phslp = "01" and q.beam_fsd(0) = '1' and q.xlim_cnt /= q.xlimtm else----------checking for glde in SELA
						q.xlim_cnt;
						
d.sft_flt(7)	<=	'1' when q.xlim_cnt = q.xlimtm else
						'0' when q.flt_clr = '1' else
						q.sft_flt(7);	
-- over drive fault						
d.sft_flt(6)	<=	'1' when q.gdcl_cnt = q.gdcltl else
					'0' when q.flt_clr = '1' else
					q.sft_flt(6);
-- plde fault					
d.sft_flt(5)	<=	'1' when q.plde_cnt = q.pldetl else
					'0' when q.flt_clr = '1' else
					 q.sft_flt(5);	
-- glde fault				 
d.sft_flt(4)	<=	'1' when q.glde_cnt = q.gldetl else
					'0' when q.flt_clr = '1' else
					 q.sft_flt(4);
					 
					 
d.sft_flt(3)	<=	'1' when q.xlim_cnt = q.xlimtm and q.sftmsk(3) = '0' else '0';	
d.sft_flt(2)	<=	'1' when q.gdcl_cnt = q.gdcltl and q.sftmsk(2) = '0' else '0';
d.sft_flt(1)	<=	'1' when q.plde_cnt = q.pldetl and q.sftmsk(1) = '0' else '0';
d.sft_flt(0)	<=	'1' when q.glde_cnt = q.gldetl and q.sftmsk(0) = '0' else '0';

-- this is the main FSD fault indication. If any unmasked faults exist, beam_fsd(3)	will go low indicating a FSD should be issued from the FCC	
d.beam_fsd(3)	<=	'0' when q.sft_flt(3) = '1' or q.sft_flt(2) = '1' or q.sft_flt(1) = '1' or q.sft_flt(0) = '1' or (q.maglp /= "10") or (q.phslp /= "10") else
					   '1' when q.flt_clr = '1' else
					    q.beam_fsd(3);

					
beam_fsd		<=	q.beam_fsd(3)&d.beam_fsd(3);
sft_flt			<=	q.sft_flt;
process(clock, reset)
begin
	if(reset = '0') then		
		q.gmes		<=	(others	=>	'0');
		q.gset		<=	(others	=>	'0');
		q.glde		<=	(others	=>	'0');
		q.gask		<=	(others	=>	'0');
		q.gdcl		<=	(others	=>	'0');
		q.pmes		<=	(others	=>	'0');
		q.gmes		<=	(others	=>	'0');
		q.gask		<=	(others	=>	'0');
		q.gask_mul	<=	(others	=>	'0'); 
		q.gask_cmp	<=	(others	=>	'0');
		q.plde		<=	(others	=>	'0');
		q.plde_int	<=	(others	=>	'0');
		q.gldeth	<=	(others	=>	'0');
		q.gldetl	<=	0;
		q.pldeth	<=	(others	=>	'0');
		q.pldetl	<=	0;
		q.gdcltl	<=	0;
		q.xlimtm	<=	0;
		q.glde_cnt	<=	0;
		q.plde_cnt	<=	0;	
		q.gdcl_cnt	<=	0;
		q.xlim_cnt	<=	0;
		q.maglp		<=	(others	=>	'0');
		q.phslp		<=	(others	=>	'0');
		q.rmpstat	<=	(others	=>	'0');
		q.flt_clr	<=	'0';
		q.glde_out	<=	(others	=>	'0');
		q.plde_out	<=	(others	=>	'0');
		q.sft_flt	<=	(others	=>	'0');
		q.rfon		<=	'0';
		q.xstathi	<=	'0';
		q.sftmsk		<=	(others	=>	'0');	
		q.beam_fsd	<=	(others	=>	'0');		
	elsif(rising_edge(clock)) then
		if(strobe = '1') then
			q			<=	d;
		end if;
	end if;
end process;

end architecture behavior;			