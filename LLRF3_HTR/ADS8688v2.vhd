LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;


entity ADS8688v2 is
	port(	clock					: in std_logic;
			reset					: in std_logic;
			filter_control		: in std_logic_vector(15 downto 0);
			SDO					: in std_logic;
			
			SDI					: out std_logic;
			CS						: out std_logic;
			SCLK					: out std_logic;
			DATA_OUT 			: OUT REG16_ARRAY
			);
			
end entity ADS8688v2;

architecture behavior of ADS8688v2 is

	COMPONENT FILTERS IS
		PORT(	CLOCK 				: IN STD_LOGIC;
				STROBE				: IN STD_LOGIC;
				RESET 				: IN STD_LOGIC;
				FILTER_CONTROL		: IN STD_LOGIC_VECTOR(15 downto 0);
				DATA_IN 				: IN STD_LOGIC_VECTOR(15 downto 0);
				DATA_OUT 			: OUT STD_LOGIC_VECTOR(15 downto 0)
				);
	END COMPONENT;

--	component regne is
--		generic map(n => 16)
--		port( clock			: in std_logic;
--				reset			: in std_logic;
--				clear			: in std_logic;
--				en				: in std_logic;
--				input			: in std_logic_vector(15 downto 0);
--				output		: out std_logic_vector(15 downto 0)
--				);
--	end component;

	type	 state_type is (init, cs_low, cs_low_wait, load_cntrl_reg, sclk_low_cntrl, sclk_high_cntrl, cs_high, wait_cs_high, data_cs_low, data_cs_low_wait, sclk_data_high, sclk_data_low, data_cs_high, data_cs_high_wait, data_acquired);

	type	RegisterRecord is record
	sdo					: std_logic;
	sclk					: std_logic;
	cs						: std_logic;
	sdi					: std_logic;
	state 				: state_type;
	SPI_data				: std_logic_vector(31 downto 0);
	bit_count			: integer range 0 to 31;
	input_din_reg		: std_logic_vector(15 downto 0);
	sclkDivider			: integer range 0 to 7;
	cntrl_count			: integer range 0 to 8;
	ActiveChannel		: integer range 0 to 7;
	channel_enable		: std_logic_vector(7 downto 0);
	ADC_data				: REG16_ARRAY;
	end record RegisterRecord;
	
	signal d, q					: RegisterRecord;
	signal RangeSelect		: std_logic_vector(7 downto 0);
	
	signal InputShiftReg		: std_logic_vector(15 downto 0);

	
	begin
	
		sdi				<= q.sdi;
		cs					<= q.cs;
		sclk				<= q.sclk;
		d.sdo				<= sdo;
			
		--Filter selection for ADC data
		ADCDataFilter : for i in 0 to 7 generate
			ADC_Filter: FILTERS
				port map(	clock 			=>	clock,
								strobe			=>	q.channel_enable(i),
								reset				=>	reset,
								filter_control	=> filter_control,
								data_in			=>	q.ADC_data(i),
								data_out			=> DATA_OUT(i)
								);
			end generate;	
					
			
		-- 0x6 = 0-5.12V must be written for each channel
		RangeSelect	<= x"06";

		--Set command word for output
		InputShiftReg	<= x"05" & RangeSelect when d.cntrl_count = 0 else --Range select ch0
								x"06" & RangeSelect when d.cntrl_count = 1 else --Range select ch1
								x"07" & RangeSelect when d.cntrl_count = 2 else --Range select ch2
								x"08" & RangeSelect when d.cntrl_count = 3 else --Range select ch3
								x"09" & RangeSelect when d.cntrl_count = 4 else --Range select ch4
								x"0A" & RangeSelect when d.cntrl_count = 5 else --Range select ch5
								x"0B" & RangeSelect when d.cntrl_count = 6 else --Range select ch6
								x"0C" & RangeSelect when d.cntrl_count = 7 else --Range select ch7
								--Auto channel incrementing.
								x"A000" when d.cntrl_count = 8 else
								(others => '0');
		
		process(clock, reset)
		begin
			if(reset = '0') then
				q.state				<= init;
				q.sdo					<=	'0';
				q.sdi					<=	'0';
				q.cs					<=	'1';
				q.sclk				<= '0';
				q.SPI_data			<= (others => '0');
				q.bit_count			<= 0;
				q.input_din_reg	<= (others => '0');
				q.sclkDivider		<= 0;
				q.cntrl_count		<= 0;
				q.SPI_data			<= (others => '0');
				q.ActiveChannel	<= 0;
				q.channel_enable	<= x"00";
--				for i in 0 to 7 loop
--					q.ADC_data(i)	<= (others => '0');
--				end loop;
				q.ADC_data	<= (others => (others	=>	'0'));



			elsif(rising_edge(clock)) then
				q						<= d;
			end if;
		end process;
		
		process(q)
		begin
			d.state				<= q.state;
			d.sdi					<=	q.sdi;
			d.cs					<=	q.cs;
			d.sclk				<= q.sclk;
			d.SPI_data			<= q.SPI_data;
			d.bit_count			<= q.bit_count;
			d.input_din_reg	<= q.input_din_reg;
			d.sclkDivider		<= q.sclkDivider;
			d.cntrl_count		<= q.cntrl_count;
			d.SPI_data			<= q.SPI_data;
			d.ActiveChannel	<= q.ActiveChannel;
			d.channel_enable	<= q.channel_enable;
--			for i in 0 to 7 loop
--				d.ADC_data(i)	<= q.ADC_data(i);
--			end loop;

			d.ADC_data	<= q.ADC_data;



			case q.state is
				--Start
				when init 						=> 
					d.sdi 						<= '0';
					d.sclk						<= '1';
					d.cs							<= '1';
					d.state						<= cs_low;
				--Programming ADC registers
				when cs_low						=> 
					d.cs							<= '0';
					d.state						<= cs_low_wait;
				when cs_low_wait				=>
					d.state <= load_cntrl_reg;
				when load_cntrl_reg			=> 
					d.sdi							<= q.input_din_reg(15);
					d.input_din_reg			<= InputShiftReg;
					d.state						<= sclk_high_cntrl;
				when sclk_high_cntrl 		=>
					d.sclk						<= '1';
					d.sdi							<= q.input_din_reg(15);
					d.sclkDivider				<= q.sclkDivider + 1;
					if(q.sclkDivider = 3) then 
						d.state					<= sclk_low_cntrl;
					end if;
				when sclk_low_cntrl 			=>
					d.sclk						<= '0';
					d.sdi							<= q.input_din_reg(15);
					if(q.sclkDivider = 7) then
						--Shift next bit into the output.
						d.input_din_reg		<= q.input_din_reg(14 downto 0) & '0';
						d.sclkDivider 			<= 0;
						if(q.bit_count = 23) then
							d.bit_count 		<= 0;
							d.state 				<= cs_high;
						else
							d.bit_count 		<= q.bit_count + 1;
							d.state 				<= sclk_high_cntrl;
						end if;
					else
						d.sclkDivider			<= q.sclkDivider + 1;
					end if;
				--End of register programming
				when cs_high 					=>
					d.cs							<= '1';
					d.sclk						<= '1';
					d.sdi							<= q.input_din_reg(15);
					d.state						<= wait_cs_high;
				when wait_cs_high				=> 
					d.sdi							<= q.input_din_reg(15);
					if(q.cntrl_count = 8) then
						d.state					<= data_cs_low;
						d.cntrl_count			<= 0;
					else
						d.state					<= cs_low;
						d.cntrl_count			<= q.cntrl_count + 1;
					end if;
				when data_cs_low 				=>
					d.cs							<= '0';
					d.sdi							<= '0';
					d.state						<= data_cs_low_wait;
				when data_cs_low_wait		=>
					d.state						<= sclk_data_high;
				when sclk_data_high 			=>
					d.sclkDivider				<= q.sclkDivider + 1;
					d.sclk						<= '1';
					if(q.sclkDivider = 3) then 
						d.SPI_data				<= q.SPI_data(30 downto 0) & q.sdo;
						d.state 					<= sclk_data_low;
					end if;
				when sclk_data_low 			=>
					d.sclk						<= '0';
					if(q.sclkDivider = 7) then
						d.sclkDivider			<= 0;
						if(q.bit_count = 31) then 
							d.bit_count			<= 0;
							d.state 				<= data_cs_high;
						else
							d.bit_count			<= q.bit_count + 1;
							d.state <= sclk_data_high;
						end if;
					else
						d.sclkDivider			<= q.sclkDivider + 1;
					end if;
				when data_cs_high				=>
					d.cs							<= '1';
					d.sclk						<= '1';
					d.state 						<= data_cs_high_wait;
				when data_cs_high_wait		=>
					d.state						<= data_acquired;
				when data_acquired			=>
					if(q.ActiveChannel = 0) then
						d.ADC_data(0)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 1;
						d.channel_enable		<= x"01";
					elsif(q.ActiveChannel = 1) then
						d.ADC_data(1)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 2;
						d.channel_enable		<= x"02";
					elsif(q.ActiveChannel = 2) then
						d.ADC_data(2)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 3;
						d.channel_enable		<= x"04";
					elsif(q.ActiveChannel = 3) then
						d.ADC_data(3)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 4;
						d.channel_enable		<= x"08";
					elsif(q.ActiveChannel = 4) then
						d.ADC_data(4)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 5;
						d.channel_enable		<= x"10";
					elsif(q.ActiveChannel = 5) then
						d.ADC_data(5)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 6;
						d.channel_enable		<= x"20";
					elsif(q.ActiveChannel = 6) then
						d.ADC_data(6)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 7;
						d.channel_enable		<= x"40";
					elsif(q.ActiveChannel = 7) then
						d.ADC_data(7)			<= q.SPI_data(15 downto 0);
						d.ActiveChannel		<= 0;
						d.channel_enable		<= x"80";
					end if;
					d.state						<= data_cs_low;
					
				when others 					=> 
					d.state <= init;
			end case;
	end process;		
end architecture behavior;