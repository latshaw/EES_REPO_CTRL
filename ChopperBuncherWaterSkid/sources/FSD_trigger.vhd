-- JAL 1/20/2022
-- FSD_trigger module specific for ML DAQ chassis
--
--
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
USE WORK.COMPONENTS.ALL;

ENTITY FSD_trigger IS 
		generic(trip_window : UNSIGNED(7 downto 0) := x"32"); -- how many clock ticks to register a fault
		PORT(
		clock 	 : IN  STD_LOGIC; -- input clock
		reset_n   : IN  STD_LOGIC; -- active low reset
		FSD_IN	 : IN  STD_LOGIC; -- fast shutdown input (assumed 5 MHz)
		FSD_MASK  : IN  STD_LOGIC; -- MASK for fault output (set HI to mask)
		FSD_CLEAR : IN  STD_LOGIC; -- clear registered fault (set HI to clear)
		FSD_FORCE : IN  STD_LOGIC; -- force fault condition, software trigger (set HI to force)
		FSD_STAT	 : OUT STD_LOGIC; -- active status (HI means FSD is currently lost)
		FSD_FAULT : OUT STD_LOGIC -- registered fault, use this to trigger buffers (HI means that a fault has occured)
	);
END FSD_trigger;

ARCHITECTURE FSD_trigger OF FSD_trigger IS 
--
signal fault_detect, wd_clear, FSD_IN_Buffer, FSD_RE, FSD_FE, fsd_fault_b : STD_LOGIC;
signal FSD_state : STD_LOGIC_VECTOR(1 downto 0);

--
BEGIN 
--===================================================
-- Fast Shutdown Trigger Module
--===================================================
-- Goal of this module is to monitor the FSD and issue a fault
-- when the FSD is lost. a watchdog process will monitor the
-- FSD input. Anytime a falling edge and rising edge pair occurs
-- on the FSD input, the watchdog will be reset. If the wathdog
-- exceeds the value set by trip_window, a fault will be issued.
-- this fault can be ignored with the mask bit or forced with the
-- force bit. The status bit is not a 'latched value' and will be
-- useful for determining if the FSD signal is restored.
--
-- The force bit supersedes the mask bit.
--
-- This module assumes that only one FSD input is given. Use a mux to select between the notional 4 FSD inputs.
--
--===================================================
-- watchdog counter
--===================================================
-- simple counter which will issue a fault if trip_window is
-- exceeded.
--
	process (clock, reset_n, wd_clear)
			variable wd_count    : UNSIGNED(15 downto 0)  := (others => '0'); -- main counter
		begin
			if ((reset_n = '0') or (wd_clear='1')) then
				wd_count        := (others => '0');
				fault_detect <= '0';	
				--
			elsif clock'event and clock = '1' then		
					IF    (wd_count >= trip_window) THEN	
						wd_count    := x"1FFF"; -- some value that will always be higher then trip_window
						fault_detect <= '1';	-- pulse high
					ELSE
						wd_count := wd_count + 1;
						fault_detect <= '0';
					END IF;
			end if; -- end rising edge
	end process;
	--
	FSD_STAT   <= fault_detect;
--
--
--===================================================
-- Buffer FSD IN
--===================================================
-- double buffer slow input fsd signal
--
	process (clock, reset_n)
		variable FSD_B1, FSD_B2 : STD_LOGIC;
		begin
			if (reset_n = '0') then
				FSD_B1 := '0';
				FSD_B2 := '0';
				FSD_IN_Buffer <= '0';
				--
			elsif clock'event and clock = '1' then		
				FSD_IN_Buffer <= FSD_B2;
				FSD_B2 := FSD_B1;
				FSD_B1 := FSD_IN;
			end if; -- end rising edge
	end process;
--
--
--===================================================
-- FSD_IN_Buffer edge detection
--===================================================
-- detect the rising edge (RE) and falling edge (FE)
--
	process (clock, reset_n)
		variable FSD_last : STD_LOGIC;
		begin
			if (reset_n = '0') then
				FSD_last := '0';
				FSD_FE   <= '0';
				FSD_RE   <= '0';
				--
			elsif clock'event and clock = '1' then		
				FSD_FE <= FSD_last AND NOT(FSD_IN_Buffer);
				FSD_RE <= NOT(FSD_IN_Buffer) AND FSD_last;
				FSD_last := FSD_IN_Buffer;
			end if; -- end rising edge
	end process;
--
--
--===================================================
-- watchdog reset state machine
--===================================================
-- watchdog state machine will only strobe wd_clear
-- whenever a falling edge and rising edge occur.
--
	process (clock, reset_n)
		begin
			if (reset_n = '0') then
				FSD_state   <= "00";
				wd_clear <= '0';
				--
			elsif clock'event and clock = '1' then		
				case FSD_state is
					when "00"   => -- Watch for falling edge of FSD input
						IF FSD_FE  = '1' THEN
							FSD_state <= "01";
						ELSE
							FSD_state <= "00";
						END IF;
						wd_clear <= '0';
					when "01"   => -- watch for rising edge of FSD input
						IF FSD_RE  = '1' THEN
							FSD_state <= "10";
						ELSE
							FSD_state <= "01";
						END IF;
						wd_clear <= '0';
					when others => -- reset watch dog timer
						wd_clear <= '1';
						FSD_state   <= "00";
				end case;
			end if; -- end rising edge
	end process;
--
--
--===================================================
-- fault handler
--===================================================
-- detect fault and register it. Keep this fault
-- registered until cleared. FSD_CLEAR must be strobed
-- to clear the fault.
--
-- 1/5/23, faults are now register at the rising edge of the fault_detect bit. They can only be cleared by strobing FSD_CLEAR
	process (clock, reset_n)
	   variable fsd_fault_last : STD_LOGIC;
		begin
			if (reset_n = '0' or FSD_CLEAR='1') then
				fsd_fault_b <= '0';
				fsd_fault_last := '0';
				--
			elsif clock'event and clock = '1' then		
				if    (fault_detect = '1' and fsd_fault_last = '0') then -- detect new fault and register it
					fsd_fault_b <= '1';
				end if;	
				fsd_fault_last := fault_detect;
			end if; -- end rising edge
	end process;
--
-- if masked, the fault will be ignored, but FSD_stat will still show the realtime fault.
-- to mask, set FSD_MASK HI, to unmask, set LOW
--
-- FSD_FORCE set HI will force a fault, keep low to not force the fault.
-- FSD_FORCE can be thought of as a soft trigger
FSD_FAULT <= (fsd_fault_b AND NOT(FSD_MASK)) OR (FSD_FORCE);
--
--
---
----
-------
END FSD_trigger;