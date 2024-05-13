library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--USE WORK.COMPONENTS.ALL;

entity grad_phs_rmp is

port(clock		: in std_logic;
	reset		: in std_logic;
	strobe		: in std_logic;
	dmes		: in std_logic_vector(17 downto 0);
	pmes		: in std_logic_vector(17 downto 0);
	dset		: in std_logic_vector(17 downto 0);
	pset		: in std_logic_vector(17 downto 0);
	drmpr		: in std_logic_vector(15 downto 0);---DEFLECTION RAMP RATE
	prmpr		: in std_logic_vector(15 downto 0);---PHASE RAMP RATE
	rfon		:	in	std_logic;
	gdr			: in std_logic;
	rmpctl		: in std_logic_vector(3 downto 0);---[0]--DRMP PAUSE, [1]--DRMP FORCE, [2]--PRMP PAUSE, [3]--PRMP FORCE		
	drmp		: out std_logic_vector(17 downto 0);
	prmp		: out std_logic_vector(17 downto 0);
	tone2iqgo		: out std_logic
	);
		
end entity grad_phs_rmp;

architecture behavior of grad_phs_rmp is

signal clr_drmp_count			: std_logic;
signal en_drmp_count			: std_logic;
signal drmp_count				: integer range 0 to 2**19-1;
signal drmp_count_d				:	integer range 0 to 2**19-1;

signal drmp_in					: integer range 0 to 2**18-1;
signal drmp_temp				: integer range 0 to 2**18-1;
signal drmp_out					: integer range 0 to 2**18-1;

signal drmpr_temp				: integer range 0 to 2**19-1;
signal drmpr_compare			: integer range 0 to 2**19-1;

signal prmpr_temp				: integer range 0 to 2**19-1;
signal prmpr_compare			: integer range 0 to 2**19-1;

signal clr_prmp_count			: std_logic;
signal en_prmp_count			: std_logic;
signal prmp_count_d				: integer range 0 to 2**19-1;
signal prmp_count				: integer range 0 to 2**19-1;

signal prmp_in					: signed(17 downto 0);
signal prmp_temp				: signed(17 downto 0);
signal prmp_out					: signed(17 downto 0);
	

--signal GDR_INT0				: std_logic;
--signal GDR_INT1				: std_logic;
signal gdr_int					:	std_logic_vector(1 downto 0);

signal gdr_rising				: std_logic;
signal gdr_rising_d				: std_logic;
signal gdr_rising_tmp			: std_logic;
--signal clr_gdr_rising			: std_logic;

--signal clr_gdr_count			: std_logic;
signal gdr_count_d				:	integer range 0 to 31;
signal gdr_count				: integer range 0 to 31;
--signal en_gdr_count				: std_logic;

signal drmpr_calc				: integer range 0 to 2**19-1;
signal prmpr_calc				: integer range 0 to 2**19-1; 
signal dset_int					:	integer range 0 to 2**18-1;
signal pset_int					:integer range 0 to 2**18-1;

signal rfoff_on				:	std_logic;
signal rfon_q					:	std_logic_vector(1 downto 0);
--signal tone2iqgo				:	std_logic;
signal tone2iqgo_in			:	std_logic;

BEGIN


gdr_rising		<= gdr_int(0) and (not gdr_int(1));
rfoff_on			<=	not rfon_q(0) and rfon_q(1);
tone2iqgo_in	<=	'1' when (gdr_count > 27 and gdr_count < 31) and rfoff_on = '0' else '0';

process(clock, reset)
begin
	if(reset = '0') then
		gdr_rising_tmp	<=	'0';
		prmpr_temp		<=	0;
		gdr_count		<=	0;
		drmpr_temp		<=	0;
		gdr_int			<=	"00";
		prmp_count		<=	0;
		drmp_count		<=	0;
		pset_int		<=	0;
		prmp_out		<=	(others	=>	'0');
		drmp_out		<=	0;
		dset_int		<=	0;
		rfon_q		<=	"00";
		tone2iqgo	<=	'0';
	elsif(rising_edge(clock)) then
		gdr_rising_tmp	<=	gdr_rising_d;
		prmp_count		<=	prmp_count_d;
		drmp_count		<=	drmp_count_d;
		rfon_q			<=	rfon_q(0)&rfon;
		tone2iqgo		<=	tone2iqgo_in;
		if(strobe = '1') then
			prmpr_temp		<=	prmpr_calc;
			gdr_count		<=	gdr_count_d;
			drmpr_temp		<=	drmpr_calc;
			gdr_int			<=	gdr_int(0)&gdr;	
			pset_int		<=	to_integer(unsigned(pset));
			dset_int		<=	to_integer(unsigned(dset));
			prmp_out		<=	prmp_in;
			drmp_out		<=	drmp_in;
		end if;		
	end if;
end process;

gdr_rising_d	<=	'0' when gdr_count = 31 else
					'1' when gdr_rising = '1' else
					gdr_rising_tmp;


--GDR_RISING_FF: FLIP_FLOP
--	PORT MAP(CLOCK		=> CLOCK, 	
--				RESET		=> RESET,
--				CLEAR		=> CLR_GDR_RISING,
--				EN			=> GDR_RISING,
--				INP		=> '1',
--				OUP 		=> GDR_RISING_TMP
--				);
				
--clr_gdr_rising		<= '0' when gdr_count = 31 else '1';
gdr_count_d			<=	0 when gdr_count = 31 else
						gdr_count + 1 when gdr_rising_tmp = '1' and gdr_count /= 31 else
						gdr_count;
						
						
				
--GDR_COUNTER: COUNTER
--		GENERIC MAP(N => 5)
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR  	=> CLR_GDR_COUNT,
--					ENABLE	=> EN_GDR_COUNT,
--					COUNT		=> GDR_COUNT
--					); 					
--EN_GDR_COUNT	<= '1' when LOAD = '1' and GDR_RISING_TMP = '1' and GDR_COUNT /= "10001" else '0';
--CLR_GDR_COUNT	<= '0' when GDR_COUNT = "10001" else '1';

--iqsel				<= '0' when gdr_count /= 0 else '1';
	
--PRMPR_REG: REGNE
--		GENERIC MAP(N => 19) 
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR		=> '1',
--					EN			=> LOAD,
--					INPUT		=> prmpr_calc,
--					OUTPUT	=> PRMPR_TEMP
--					);
					
prmpr_calc <= to_integer(unsigned(prmpr & "000"));
					
prmpr_compare	<= 20 when prmpr_temp < 20 else prmpr_temp;
					
--DRMPR_REG: REGNE
--		GENERIC MAP(N => 19) 
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR		=> '1',
--					EN			=> LOAD,
--					INPUT		=> drmpr_calc,
--					OUTPUT	=> DRMPR_TEMP
--					);
					
drmpr_calc <= to_integer(unsigned(drmpr & "000"));
					
drmpr_compare	<= 20 when drmpr_temp < 20 else drmpr_temp;

--GDR_FF0: FLIP_FLOP
--	PORT MAP(CLOCK		=> CLOCK, 	
--				RESET		=> RESET,
--				CLEAR		=> '1',
--				EN			=> LOAD,
--				INP		=> GDR,
--				OUP 		=> GDR_INT0
--				);
--				
--GDR_FF1: FLIP_FLOP
--	PORT MAP(CLOCK		=> CLOCK, 	
--				RESET		=> RESET,
--				CLEAR		=> '1',
--				EN			=> LOAD,
--				INP		=> GDR_INT0,
--				OUP 		=> GDR_INT1
--				);


--PRMPR_COUNTER: COUNTER
--		GENERIC MAP(N => 19)
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR  	=> CLR_prmp_count,
--					ENABLE	=> EN_prmp_count,
--					COUNT		=> prmp_count
--					);
					
prmp_count_d	<=	0 when clr_prmp_count = '0' else
					prmp_count + 1 when en_prmp_count = '1' else
					prmp_count;
					
en_prmp_count	<= '1' when prmp_count /= prmpr_compare and strobe = '1' and rmpctl(2) = '0' and prmp_out /= pset_int else '0';
clr_prmp_count	<= '0' when (prmp_count = prmpr_compare and strobe = '1') or (gdr_int(0) = '1' and gdr_int(1) = '0') else '1';
					
--DRMPR_COUNTER: COUNTER
--		GENERIC MAP(N => 19)
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR  	=> CLR_DRMP_COUNT,
--					ENABLE	=> EN_DRMP_COUNT,
--					COUNT		=> DRMP_COUNT
--					);
drmp_count_d	<=	0 when clr_drmp_count = '0' else
					drmp_count + 1 when en_drmp_count = '1' else
					drmp_count;
					
en_drmp_count	<= '1' when drmp_count /= drmpr_compare and strobe = '1' and rmpctl(0) = '0' and drmp_out /= dset_int else '0';
clr_drmp_count	<= '0' when (drmp_count = drmpr_compare and strobe = '1') or (gdr_int(0) = '1' and gdr_int(1) = '0') else '1';

--DRMP_REG: REGNE
--		GENERIC MAP(N => 16) 
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR		=> '1',
--					EN			=> LOAD,
--					INPUT		=> DRMP_IN,
--					OUTPUT	=> DRMP_OUT
--					);
					
drmp_in		<= to_integer(unsigned(dmes)) when gdr_int(1) = '0' and gdr_int(0) = '1' else drmp_temp;

drmp_temp	<= dset_int when rmpctl(1) = '1' else
			   	drmp_out + 1 when (drmp_out < dset_int and rmpctl(0) = '0' and rmpctl(1) = '0' and drmp_count = drmpr_compare) else
				drmp_out - 1 when (drmp_out > dset_int and rmpctl(0) = '0' and rmpctl(1) = '0' and drmp_count = drmpr_compare) else					
				drmp_out;
					
drmp			<= std_logic_vector(to_unsigned(drmp_out,18));

--PRMP_REG: REGNE
--		GENERIC MAP(N => 16) 
--		PORT MAP(CLOCK		=> CLOCK,
--					RESET		=> RESET,
--					CLEAR		=> '1',
--					EN			=> LOAD,
--					INPUT		=> PRMP_IN,
--					OUTPUT	=> PRMP_OUT
--					);
					
prmp_in		<= signed(pmes) when gdr_int(1) = '0' and gdr_int(0) = '1' else prmp_temp;

prmp_temp	<= 	signed(pset) when rmpctl(3) = '1' else
				prmp_out + 1 when ((prmp_out(17) = pset(17)) and (prmp_out < signed(pset)) and rmpctl(2) = '0' and rmpctl(3) = '0' and prmp_count = prmpr_compare) else
				prmp_out - 1 when ((prmp_out(17) = pset(17)) and (prmp_out > signed(pset)) and rmpctl(2) = '0' and rmpctl(3) = '0' and prmp_count = prmpr_compare) else
				prmp_out - 1 when ((prmp_out(17) /= pset(17)) and (prmp_out < signed(not pset(17) & pset(16 downto 0))) and rmpctl(2) = '0' and rmpctl(3) = '0' and prmp_count = prmpr_compare) else
				prmp_out + 1 when ((prmp_out(17) /= pset(17)) and (prmp_out >= signed(not pset(17) & pset(16 downto 0))) and rmpctl(2) = '0' and rmpctl(3) = '0' and prmp_count = prmpr_compare) else
				prmp_out;
					
prmp			<= std_logic_vector(prmp_out);


end architecture behavior;