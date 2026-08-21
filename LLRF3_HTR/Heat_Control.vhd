LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.COMPONENTS.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity HEAT_CONTROL is
	port(	clock					: in std_logic;
			reset					: in std_logic;
			requested_watts	: in unsigned(15 downto 0);
			current_readback	: in signed(15 downto 0);
			voltage_readback	: in signed(15 downto 0);
			DAC_setpoint		: in std_logic_vector(15 downto 0);
			p_gain				: in unsigned(15 downto 0);
			i_gain				: in unsigned(15 downto 0);
			d_gain				: in unsigned(15 downto 0);
			new_DAC_setpoint	: out std_logic_vector(15 downto 0)
			);
end entity HEAT_CONTROL;
	
architecture behavior of HEAT_CONTROL is
	
	type reg is record
		computed_watts	: unsigned(15 downto 0);
		integral			: unsigned(31 downto 0);
		derivative		: unsigned(15 downto 0);
		proportional	: unsigned(15 downto 0);
		prior_error		: unsigned(15 downto 0);
	end record reg;
	signal d,q : reg;
	
	
	begin
	d.computed_watts <= unsigned(current_readback * voltage_readback);
	d.integral <= q.integral + i_gain * (requested_watts - q.computed_watts);
	d.derivative <= d_gain * (requested_watts - q.computed_watts) - q.prior_error;
	d.proportional <= p_gain * (requested_watts - q.computed_watts);
	d.prior_error <= (requested_watts - q.computed_watts);
	
	new_DAC_setpoint <= std_logic_vector(q.proportional + q.integral + q.derivative);
	
	
	
	
	process(clock, reset)
	begin
		if(reset = '0') then
			q.computed_watts	<= (others => '0');
			q.integral			<= (others => '0');
			q.derivative		<= (others => '0');
			q.proportional		<= (others => '0');
			q.prior_error		<= (others => '0');
		elsif rising_edge(clock) then
			q <= d;
		end if;
	end process;
end architecture behavior;