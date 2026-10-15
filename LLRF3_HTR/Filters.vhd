LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;

ENTITY FILTERS IS
	PORT(	CLOCK 				: IN STD_LOGIC;
			STROBE				: IN STD_LOGIC;
			RESET 				: IN STD_LOGIC;
			FILTER_CONTROL		: IN STD_LOGIC_VECTOR(15 downto 0);
			DATA_IN 				: IN STD_LOGIC_VECTOR(15 downto 0);
			DATA_OUT 			: OUT STD_LOGIC_VECTOR(15 downto 0)
			);
END ENTITY FILTERS;

ARCHITECTURE BEHAVIOR OF FILTERS IS

	COMPONENT iir_lpf
	PORT(lb_clk : IN STD_LOGIC;
		 reset_n : IN STD_LOGIC;
		 strobe  : IN STD_LOGIC; -- strobe, sample ready
		 x       : IN STD_LOGIC_VECTOR(15 downto 0); -- 16 bit input
		 y       : OUT STD_LOGIC_VECTOR(15 downto 0)  -- 16 but filtered output
		);
	END COMPONENT;
	
	COMPONENT cic_8
	PORT(clk 	: IN STD_LOGIC;
		 reset_n 	: IN STD_LOGIC;
		 strobein  	: IN STD_LOGIC; -- strobe, sample ready
		 xin       	: IN STD_LOGIC_VECTOR(15 downto 0); -- 16 bit input
		 yout       : OUT STD_LOGIC_VECTOR(15 downto 0);  -- 16 but filtered output
		 triggerout : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT IIR_SIMPLE
	PORT(CLOCK 	: IN STD_LOGIC;
		  RESET 	: IN STD_LOGIC;
		  LOAD	: IN STD_LOGIC;
		  I		: IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		  O		: OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
		  );
	  
	END COMPONENT;
	
	type	RegisterRecord is record
	Data						: STD_LOGIC_VECTOR(15 downto 0);
	CIC_OUT					: STD_LOGIC_VECTOR(15 downto 0);
	BUFFER_OUT				: STD_LOGIC_VECTOR(15 downto 0);
	FULL_IIR_OUT			: STD_LOGIC_VECTOR(15 downto 0);
	SIMPLE_IIR_OUT			: STD_LOGIC_VECTOR(15 downto 0);
	FULL_IIR_CHAIN_OUT	: STD_LOGIC_VECTOR(15 downto 0);
	SIMPLE_IIR_CHAIN_OUT	: STD_LOGIC_VECTOR(15 downto 0);
	Strobe					: STD_LOGIC;
	CIC_STROBE				: STD_LOGIC;
	end record RegisterRecord;
	
	signal d, q					: RegisterRecord;
	
	BEGIN
		
		d.Data			<= DATA_IN;
		d.Strobe			<= STROBE;
		
		DATA_OUT			<= q.Data			 			when FILTER_CONTROL(2 downto 0) ="000" else
								q.CIC_OUT	 				when FILTER_CONTROL(2 downto 0) ="001" else
								q.FULL_IIR_OUT	 			when FILTER_CONTROL(2 downto 0) ="010" else
								q.SIMPLE_IIR_OUT			when FILTER_CONTROL(2 downto 0) ="011" else
								q.FULL_IIR_CHAIN_OUT		when FILTER_CONTROL(2 downto 0) ="100" else
								q.SIMPLE_IIR_CHAIN_OUT	when FILTER_CONTROL(2 downto 0) ="101" else
								(others => '0');
								
		
--		DATA_BUF: REGNE
--						GENERIC MAP(N => 16) 
--						PORT MAP(CLOCK	=> CLOCK,
--							RESET	=> RESET,
--							CLEAR	=> '1',
--							EN		=> q.Strobe,
--							INPUT	=> q.Data,
--							OUTPUT	=> d.BUFFER_OUT
--						);
						
		CIC: cic_8
					PORT MAP(clk 	=> CLOCK,
						reset_n 		=> RESET,
						strobein		=> q.Strobe,
						xin      	=> q.Data,
						yout     	=> d.CIC_OUT,
						triggerout 	=> d.CIC_STROBE
					);			
		
		FULLIIR: iir_lpf
						PORT MAP(lb_clk  => CLOCK,
							reset_n => RESET,
							strobe  => q.Strobe,
							x       => q.Data,
							y       => d.FULL_IIR_OUT
						);
		
		SIMPLEIIR: IIR_SIMPLE
						PORT MAP(CLOCK  	=> CLOCK,
							RESET 	=> RESET,
							LOAD  	=> q.Strobe,
							I       	=> q.Data,
							O       	=> d.SIMPLE_IIR_OUT
						);
						
		FULLIIR_CHAIN: iir_lpf
						PORT MAP(lb_clk  => CLOCK,
							reset_n => RESET,
							strobe  => q.CIC_STROBE,
							x       => q.CIC_OUT,
							y       => d.FULL_IIR_CHAIN_OUT
						);
		
		FULLSIMPLEIIR_CHAIN: IIR_SIMPLE
						PORT MAP(CLOCK  	=> CLOCK,
							RESET 	=> RESET,
							LOAD  	=> q.CIC_STROBE,
							I       	=> q.CIC_OUT,
							O       	=> d.SIMPLE_IIR_CHAIN_OUT
						);
	
		PROCESS(CLOCK, RESET)
		BEGIN
				IF RESET = '0' then	
					q.Data						<= (others => '0');
					q.CIC_OUT					<= (others => '0');
					q.BUFFER_OUT				<= (others => '0');
					q.FULL_IIR_OUT				<= (others => '0');
					q.SIMPLE_IIR_OUT			<= (others => '0');
					q.FULL_IIR_CHAIN_OUT		<= (others => '0');
					q.SIMPLE_IIR_CHAIN_OUT	<= (others => '0');
					q.Strobe						<= '0';
					q.CIC_STROBE				<= '0';
				ELSIF CLOCK'event and CLOCK = '1' then
					q								<= d;
				END IF;
			END PROCESS;
		END ARCHITECTURE BEHAVIOR;