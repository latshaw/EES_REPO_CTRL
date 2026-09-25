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
		 y       :OUT STD_LOGIC_VECTOR(15 downto 0)  -- 16 but filtered output
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
	
	SIGNAL IData, OData			: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL CIC_OUT					: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL BUFFER_OUT				: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL FULL_IIR_OUT			: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL SIMPLE_IIR_OUT		: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL FULL_IIR_CHAIN_OUT	: STD_LOGIC_VECTOR(15 downto 0);
	SIGNAL IStrobe, OStrobe		: STD_LOGIC;
	SIGNAL CIC_STROBE				: STD_LOGIC;
	
	BEGIN
		
		IData			<= DATA_IN;
		IStrobe		<= STROBE;
		
		DATA_BUF: REGNE
						GENERIC MAP(N => 16) 
						PORT MAP(CLOCK	=> CLOCK,
							RESET	=> RESET,
							CLEAR	=> '1',
							EN		=> '1',
							INPUT	=> OData,
							OUTPUT	=> BUFFER_OUT
						);
						
		CIC: cic_8
					PORT MAP(clk 	=> CLOCK,
						reset_n 		=> RESET,
						strobein		=> OStrobe,
						xin      	=> OData,
						yout     	=> CIC_OUT,
						triggerout 	=> CIC_STROBE
					);			
		
		FULLIIR: iir_lpf
						PORT MAP(lb_clk  => CLOCK,
							reset_n => RESET,
							strobe  => OStrobe,
							x       => OData,
							y       => FULL_IIR_OUT
						);
		
		SIMPLEIIR: IIR_SIMPLE
						PORT MAP(CLOCK  	=> CLOCK,
							RESET 	=> RESET,
							LOAD  	=> OStrobe,
							I       	=> OData,
							O       	=> SIMPLE_IIR_OUT
						);
						
		FULLIIR_CHAIN: iir_lpf
						PORT MAP(lb_clk  => CLOCK,
							reset_n => RESET,
							strobe  => CIC_STROBE,
							x       => CIC_OUT,
							y       => FULL_IIR_CHAIN_OUT
						);			
	
		PROCESS(CLOCK, RESET)
		BEGIN
				IF RESET = '0' then	
					OData			<= (others => '0');
					OStrobe		<= '0';
				ELSIF CLOCK'event and CLOCK = '1' then
					OData			<= IData;
					OStrobe		<= IStrobe;
					IF (FILTER_CONTROL(2 downto 0) = "000") then
						DATA_OUT <= BUFFER_OUT;
					ELSIF (FILTER_CONTROL(2 downto 0) = "001") then
						DATA_OUT <= CIC_OUT;
					ELSIF (FILTER_CONTROL(2 downto 0) = "010") then
						DATA_OUT <= FULL_IIR_OUT;
					ELSIF (FILTER_CONTROL(2 downto 0) = "011") then
						DATA_OUT <= SIMPLE_IIR_OUT;
					ELSIF (FILTER_CONTROL(2 downto 0) = "100") then
						DATA_OUT <= FULL_IIR_CHAIN_OUT;
					END IF;
				END IF;
			END PROCESS;
		END ARCHITECTURE BEHAVIOR;