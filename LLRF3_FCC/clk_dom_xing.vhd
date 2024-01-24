library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clk_dom_xing is
port (	clk1		: 	in std_logic;
		clk2		: 	in std_logic;
		reset		: 	in std_logic;
		init_data	:	in std_logic;	
		ina			:	in std_logic_vector(15 downto 0);
		inb			:	in std_logic_vector(27 downto 0);
--		inc			:	in std_logic_vector(17 downto 0);
		ind			:	in std_logic_vector(2 downto 0);
		ine			:	in std_logic;
		inf			:	in std_logic;
		ing			:	in std_logic;
--		inh			:	in std_logic_vector(15 downto 0);
--		ini			:	in std_logic_vector(15 downto 0);
--		inj			:	in std_logic_vector(15 downto 0);
--		ink			:	in std_logic_vector(15 downto 0);
		inl			:	in std_logic_vector(5 downto 0);
--		inm			:	in std_logic_vector(17 downto 0);
		
		outa		:	out std_logic_vector(15 downto 0);
		outb		:	out std_logic_vector(27 downto 0);
--		outc		:	out std_logic_vector(17 downto 0);
		outd		:	out std_logic_vector(2 downto 0);
		oute		:	out std_logic;
		outf		:	out std_logic;
		outg		:	out std_logic;
--		outh		:	out std_logic_vector(15 downto 0);
--		outi		:	out std_logic_vector(15 downto 0);
--		outj		:	out std_logic_vector(15 downto 0);
--		outk		:	out std_logic_vector(15 downto 0);
		outl		:	out std_logic_vector(5 downto 0)
--		outm		:	out std_logic_vector(17 downto 0)
		);		
end entity clk_dom_xing;
architecture behavior of clk_dom_xing is
signal d_en_reg_clk1, q_en_reg_clk1			: std_logic;
signal d_en_reg_clk2, q_en_reg_clk2			: std_logic;
signal data_rdy_clk1			: std_logic;
signal data_ready_clk2		: std_logic;
signal data_ack_clk2			: std_logic;
signal data_ackldg_clk1		: std_logic;

type reg_record is record
	siga			:	std_logic_vector(15 downto 0);
	sigb			:	std_logic_vector(27 downto 0);
--	sigc			:	std_logic_vector(17 downto 0);
	sigd			:	std_logic_vector(2 downto 0);
	sige			:	std_logic;
	sigf			:	std_logic;
	sigg			:	std_logic;
--	sigh			:	std_logic_vector(15 downto 0);
--	sigi			:	std_logic_vector(15 downto 0);
--	sigj			:	std_logic_vector(15 downto 0);
--	sigk			:	std_logic_vector(15 downto 0);
	sigl			:	std_logic_vector(5 downto 0);
--	sigm			:	std_logic_vector(17 downto 0);
	en_reg		:	std_logic;
end record reg_record;

signal dclk1, qclk1							:	reg_record;
signal dclk2, qclk2							:	reg_record;
signal din										:	reg_record;
signal dclk1_data_rdy, qclk1_data_rdy	:	std_logic;
signal dclk1_data_ack, qclk1_data_ack	:	std_logic_vector(2 downto 0);
signal dclk2_data_rdy, qclk2_data_rdy	:	std_logic_vector(2 downto 0);
signal dclk2_data_ack, qclk2_data_ack	:	std_logic;

type state_type1 is (init_data_send, data_load, data_ready, data_ack_wait);
signal state1						: state_type1;
type state_type2 is (init_data_acq, data_acq, data_ack, data_ready_wait);
signal state2						: state_type2;

begin
din.siga			<=	ina;
din.sigb			<=	inb;
--din.sigc			<=	inc;
din.sigd			<=	ind;
din.sige			<=	ine;
din.sigf			<=	inf;
din.sigg			<=	ing;
--din.sigh			<=	inh;
--din.sigi			<=	ini;
--din.sigj			<=	inj;
--din.sigk			<=	ink;
din.sigl			<=	inl;
--din.sigm			<=	inm;
dclk1			<=	din when q_en_reg_clk1 = '1' else qclk1;	
	
outa			<=	qclk2.siga;
outb			<=	qclk2.sigb;
--outc			<=	qclk2.sigc;
outd			<=	qclk2.sigd;
oute			<=	qclk2.sige;
outf			<=	qclk2.sigf;
outg			<=	qclk2.sigg;
--outh			<=	qclk2.sigh;
--outi			<=	qclk2.sigi;
--outj			<=	qclk2.sigj;
--outk			<=	qclk2.sigk;
outl			<=	qclk2.sigl;
--outm			<=	qclk2.sigm;

dclk1_data_rdy			<=	data_rdy_clk1;
dclk1_data_ack			<=	qclk1_data_ack(1 downto 0)&qclk2_data_ack;
process(clk1, reset)
begin
	if(reset = '0') then
		qclk1.siga			<=	(others	=>	'0');
		qclk1.sigb			<=	(others	=>	'0');
--		qclk1.sigc			<=	(others	=>	'0');
		qclk1.sigd			<=	(others	=>	'0');
		qclk1.sige			<=	'0';
		qclk1.sigf			<=	'0';
		qclk1.sigg			<=	'0';
--		qclk1.sigh			<=	(others	=>	'0');
--		qclk1.sigi			<=	(others	=>	'0');
--		qclk1.sigj			<=	(others	=>	'0');
--		qclk1.sigk			<=	(others	=>	'0');
		qclk1.sigl			<=	(others	=>	'0');
--		qclk1.sigm			<=	(others	=>	'0');
		qclk1_data_rdy		<=	'0';
		qclk1_data_ack		<=	(others	=>	'0');
		q_en_reg_clk1		<=	'0';
	elsif(rising_edge(clk1)) then
		qclk1				<=	dclk1;
		qclk1_data_rdy		<=	dclk1_data_rdy;
		qclk1_data_ack		<=	dclk1_data_ack;
		q_en_reg_clk1		<=	d_en_reg_clk1;
	end if;
end process;

dclk2_data_rdy			<=	qclk2_data_rdy(1 downto 0)&qclk1_data_rdy;
dclk2_data_ack			<=	data_ack_clk2;
process(clk2, reset)
begin
	if(reset = '0') then		
		qclk2.siga			<=	(others	=>	'0');
		qclk2.sigb			<=	(others	=>	'0');
--		qclk2.sigc			<=	(others	=>	'0');
		qclk2.sigd			<=	(others	=>	'0');
		qclk2.sige			<=	'0';
		qclk2.sigf			<=	'0';
		qclk2.sigg			<=	'0';
--		qclk2.sigh			<=	(others	=>	'0');
--		qclk2.sigi			<=	(others	=>	'0');
--		qclk2.sigj			<=	(others	=>	'0');
--		qclk2.sigk			<=	(others	=>	'0');
		qclk2.sigl			<=	(others	=>	'0');
--		qclk2.sigm			<=	(others	=>	'0');
		qclk2_data_rdy		<=	(others	=>	'0');
		qclk2_data_ack		<=	'0';
		q_en_reg_clk2		<=	'0';
	elsif(rising_edge(clk2)) then		
		qclk2				<=	dclk2;
		qclk2_data_rdy		<=	dclk2_data_rdy;
		qclk2_data_ack		<=	dclk2_data_ack;
		q_en_reg_clk2		<=	d_en_reg_clk2;
	end if;
end process;				
data_ready_clk2		<= (not qclk2_data_rdy(2)) and qclk2_data_rdy(1);				
data_ackldg_clk1	<= (not qclk1_data_ack(2)) and qclk1_data_ack(1);
dclk2							<=	qclk1 when q_en_reg_clk2 = '1' else qclk2;

process(clk1, reset)
begin
	if (reset = '0') then
		state1	<= init_data_send;
	elsif (rising_edge(clk1)) then	
		case state1 is	
			when init_data_send	=> 	if init_data = '1' then state1 <= data_load;		
												else state1 <= init_data_send;
												end if;
			when data_load		=> 	state1 <= data_ready;			
			when data_ready		=> 	state1	<=	data_ack_wait;									
			when data_ack_wait	=> 	if data_ackldg_clk1 = '1' then state1 <= data_load;
									else state1	<= data_ack_wait;
									end if;										
			when others			=> state1 <= init_data_send;		
		end case;	
	end if;	
end process;
d_en_reg_clk1		<= '1' when state1 = data_load else '0';
data_rdy_clk1	<= '1' when state1 = data_ack_wait else '0';

process(clk2, reset)
begin
	if (reset = '0') then
		state2	<= init_data_acq;
	elsif (rising_edge(clk2)) then	
		case state2 is	
			when init_data_acq		=>	if data_ready_clk2 = '1' then state2 <= data_acq;
										else state2 <= init_data_acq;
										end if;		
			when data_acq			=> 	state2 <= data_ack;			
			when data_ack			=> 	state2	<=	data_ready_wait;										
			when data_ready_wait	=> 	if data_ready_clk2 = '1' then state2 <= data_acq;
										else state2	<= data_ready_wait;
										end if;										
			when others				=>	state2 <= init_data_acq;		
		end case;	
	end if;	
end process;
d_en_reg_clk2		<= '1' when state2 = data_acq else '0';
data_ack_clk2	<= '1' when state2 = data_ready_wait else '0';
end architecture behavior;
