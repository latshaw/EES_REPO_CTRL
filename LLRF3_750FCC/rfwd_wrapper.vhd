-- JAL 5/9/2024
-- 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity rfwd_wrapper is
	port( lb_clk			  :	in  std_logic;
			adc_pll_clk_data :	in  std_logic;
			reset_n			  :	in  std_logic;
			lb_valid         :	in  std_logic;
			fccid            :   out std_logic_vector(15 downto 0);
			c_bus_ctl        :   out std_logic_vector(31 downto 0);
			lb_addr          :   in  std_logic_vector(23 downto 0);
			lb_wdata         :   in  std_logic_vector(31 downto 0);
			lb_rdata_rfwd    :   out std_logic_vector(31 downto 0);
			lb_rnw           :	in  std_logic
			);
end entity rfwd_wrapper;



architecture behavioral of rfwd_wrapper is
 
-- remote firmware download singals
signal en_c_addr, en_c_cntl, en_c_data, en_c_bus_ctl : std_logic;
signal rfwd_buf32, lb_rdata_mux, c10_status, c10_datar, c_status  : std_logic_vector(31 downto 0);
signal fcc_id_state, fcc_id_state_p                  : std_logic_vector(3 downto 0);
signal addr_cnt_d, addr_cnt_q                        : unsigned(15 downto 0);
signal fccid_d, fccid_q                              : std_logic_vector(15 downto 0);
signal en_fcc_id                                     : std_logic;
signal c_addr_mux, c_addr_mux2, c_addr_fccid_d, c_addr_fccid_q    : std_logic_vector(31 downto 0);
signal c_cntlr_mux, c_cntlr_fccid_d, c_cntlr_fccid_q, c_data_mux, c_addr, c_addr_slow, c_cntlr, c_data : std_logic_vector(31 downto 0);
signal lb_addr_r :  std_logic_vector(23 downto 0);
signal lb_strb   : std_logic;

signal fcc_id_state_save_en, fcc_id_state_save : std_logic;


attribute noprune: boolean;
-- cyclone.v neded no prune signals
attribute noprune of c_cntlr : signal is true;--
attribute noprune of c_data : signal is true;--
attribute noprune of c_status : signal is true;--
--attribute noprune of c_datar : signal is true;-- not used
attribute noprune of c_addr, c_addr_slow : signal is true;--
attribute noprune of lb_strb : signal is true;--
-- end cyclone.v needed no prune signals
--
-- regbank no prunes
attribute noprune of rfwd_buf32 : signal is true;
--attribute noprune of lb_rdata_mux : signal is true;
attribute noprune of lb_rdata_rfwd : signal is true;

-- JAL 5/9/24
--attribute keep: boolean;
attribute noprune of c_addr_mux, c_addr_mux2, c_data_mux, c_cntlr_mux, c10_status, c10_datar : signal is true;
-- end noprune attibutes

type STATES is (INIT, WAKE, SHIFT, WATCH, DELAY, SHIFT_DATA, COUNT, SAVE, DONE, CHECK, SETUp, READS);

signal state      : STATES;

signal instr_q, instr_d : std_logic_vector(19 downto 0);
signal wake_cnt_q, wake_cnt_d : UNSIGNED(15 downto 0);
signal instr_cnt_q, instr_cnt_d : UNSIGNED(3 downto 0);
signal cmd_q, cmd_d : std_logic_vector(3 downto 0);
signal reader_cnt_q, reader_cnt_d : UNSIGNED(3 downto 0);
begin
--
--========================================================
--	FCC ID read upon reset / power on
--========================================================
-- load fccid upon initial wakeup after a short delay
	process (lb_clk, reset_n)
	begin
		if reset_n = '0' then
				state           <= INIT;
				wake_cnt_q      <= x"0000";
				instr_q         <= x"EBE9E"; -- CLEAR/EXT-ADDR/CLEAR/READ/CLEAR/READ/CLEAR
				cmd_q           <= x"E";
				instr_cnt_q     <= x"0";
				fccid_q         <= x"0000";
				c_addr_fccid_q  <= x"00AF0000";
				c_cntlr_fccid_q <= x"0000000E";
				reader_cnt_q    <= x"0";
		elsif lb_clk'event and lb_clk = '1' then
				--
				wake_cnt_q      <= wake_cnt_d;
				instr_q         <= instr_d;
				cmd_q           <= cmd_d;
				instr_cnt_q     <= instr_cnt_d;
				fccid_q         <= fccid_d;
				c_addr_fccid_q  <= c_addr_fccid_d;
				c_cntlr_fccid_q <= c_cntlr_fccid_d;
				reader_cnt_q    <= reader_cnt_d;
				--
				case state is
					when INIT   => state <= WAKE;
					when WAKE   => if wake_cnt_q >= x"00F0" then state <= SHIFT;
										else 	                        state <= WAKE; 
										end if;
					when SHIFT  => state <= WATCH;
					when WATCH  => if cmd_q = x"E" or cmd_q = x"0" then 
											if c10_status(4) = '0' and c10_status(5) = '0' then -- watch for RE/FE check to be LOW for CLEAR commands
												state <= DELAY;
											else
												state <= WATCH;
											end if;
					               else                 
											if c10_status(4) = '1' and c10_status(5) = '1' then -- watch for RE/FE to go HI for READ/ EXT-ADDR commands
												state <= DELAY;
											else
												state <= WATCH;
											end if;
										end if;
					when DELAY  => if wake_cnt_q >= x"00F0" then  state <= COUNT;
										else 	                         state <= DELAY; 
										end if;
--					when CHECK => if cmd_q = x"9" then 
--												state <= SHIFT_DATA; -- for read cmds only, shift in datar byteÃ¢â„¢Â 
--									   else
--												state <= COUNT;
--										end if;
					
				   when COUNT  => if instr_cnt_q < x"4" then     state <= SHIFT; 
									   else                           state <= SETUP; 
										end if;
					when SETUP  => state <= READS;
				   when READS  => state <= SHIFT_DATA;
				   when SHIFT_DATA => 
					               if reader_cnt_q >= x"3" then   state <= SAVE; 
									   else                           state <= SETUP; 
										end if; 	
					when SAVE   => state <= DONE;
					when DONE   => state <= DONE; -- TEMP
					when others => state <= INIT;
				end case;
		end if;
	end process;
	
	wake_cnt_d <= wake_cnt_q + 1 when STATE = WAKE or STATE = DELAY   else -- increment counter when in WAKE or DELAY state
					  x"0000"        when STATE /= WAKE or STATE /= DELAY else -- reset counter when not in these states
					  wake_cnt_q;															  -- otherwise hold last value
	
	instr_cnt_d <= instr_cnt_q + 1 when STATE = COUNT else 
						"0000"          when state = INIT  else instr_cnt_q; -- increment instruction counter
	
	instr_d         <= x"EBE9E"                    when STATE = INIT  else 
							 instr_q(15 downto 0) & x"E" when STATE = SHIFT else instr_q; -- shift out 4 bits
							 
	reader_cnt_d   <= x"0"             when STATE = INIT  else
							reader_cnt_q + 1 when STATE = SETUP else reader_cnt_q;
							 
	cmd_d           <= instr_q(19 downto 16) when STATE = SHIFT else cmd_q; -- grab new command for control register
	fccid_d         <= fccid_q(7 downto 0) & c10_datar(7 downto 0) when state = SHIFT_DATA else fccid_q; -- shift in read data from EPCQ after read
	en_fcc_id       <= '1' when state = SAVE else '0'; -- write enable to save fcc id to dpram contents for clock docmain crossing
	--
	c_addr_fccid_d  <= x"00AF0000" when instr_cnt_q < x"4" and reader_cnt_q = x"0" else
	                   x"00000000" when reader_cnt_q = x"1" else -- byte 0
							 x"00000001" when reader_cnt_q = x"2" else -- byte 1
							 x"00000002"; -- byte 2, not used
   --
	c_cntlr_fccid_d <= x"0000000" & cmd_q;
	
	-- mux for selecting between fcc_id reader (after reset) or normal r/w controls
	c_addr_mux  <=  c_addr when state = DONE else c_addr_fccid_q; 
	c_addr_mux2 <=  c_addr_slow when state = DONE else c_addr_fccid_q; 
	c_data_mux  <=  c_data when state = DONE else x"00000080";             -- set default to 128 byte reads
	c_cntlr_mux <=  c_cntlr when state = DONE else c_cntlr_fccid_q;
	
	-------------				  
	

	-- fcc id reader, had to look at multiple regisers to infer dpram which is needed for clock domain crossing
	 dpram_lbnl_inst : entity work.dpram_lbnl
	 GENERIC MAP(
				dw		=> 16, -- 16 bits data
				aw		=>	4   -- address
				)
	 PORT MAP(
				clka  => lb_clk,           -- read clock
				clkb  => adc_pll_clk_data, -- write clock
				addra => instr_cnt_q,      -- fixed address
				dina  => fccid_q,          -- lb_clk domain register
				wena  => en_fcc_id,        -- lb_clk domain write enable
				addrb => "0101",           -- fixed address
				doutb => fccid);           -- output register to adc_pll_clk_data clock domain
	
--	-- watch for the fcc_id_state to go to "1111" state and then set fcc_id_state_save HI which
--	-- will keep the <...>_mux set to skip the fcc_id wakeup.
--	process (lb_clk)
--	begin
--		if lb_clk'event and lb_clk = '1' then
--			if reset_n = '0' then
--				fcc_id_state_save <= '0';
--			else
--				if fcc_id_state_save = '0' then
--					if fcc_id_state_save_en = '1' then
--						fcc_id_state_save <= '1'; 
--					else
--						fcc_id_state_save <= '0';
--					end if;
--				else
--					fcc_id_state_save <= '1';
--				end if;
--			end if;
--		end if;
--	end process;
--	-- once in done state, enable face_id_save
--	fcc_id_state_save_en <= '1' when fcc_id_state = "1111" else '0';
--	
--	-- mux for selecting between fcc_id reader (after reset) or normal r/w controls
--	c_addr_mux  <= c_addr_fccid_q  when fcc_id_state_save = '0' else c_addr;
--	c_data_mux  <= x"00000080"     when fcc_id_state_save = '0' else c_data; -- set default to 128 byte reads
--	c_cntlr_mux <= c_cntlr_fccid_q when fcc_id_state_save = '0' else c_cntlr;
	
--========================================================
--	Cyclone EPCQ interface
--========================================================
--
-- instantiate the cyclone module, this is used for remote firmware download
CYCLONE_inst : entity work.cyclone
	PORT MAP(
			 lb_clk 		 => lb_clk,      -- 125 MHz clock
			 c10_addr 	 => c_addr_mux,
			 c_addr_slow => c_addr_mux2, -- will be clocked by slower clock in cyclone.v
			 c10_data 	 => c_data_mux,
			 c10_cntlr 	 => c_cntlr_mux,
			 c10_status  => c10_status,
			 c10_datar   => c10_datar,
			 we_cyclone_inst_c10_data => lb_strb);	
	-- strobe indiacting a new 'write register' write, needed by cyclone.v module
	lb_strb <= lb_valid AND en_c_data;
	-- used to mux remote firmware download registers and normal HRT/waveform registers
	-- this process registers the lb_addr to help with fan out
	process (lb_clk)
	begin
		if lb_clk'event and lb_clk = '1' then
			if lb_valid = '1' then
				lb_addr_r(23 downto 0) <= lb_addr;
			end if;
		end if;
	end process;
	--
	process (lb_clk)  
	begin
		if lb_clk'event and lb_clk = '1' then
			if lb_valid = '1' then 
				case lb_addr(7 downto 0) is -- note this is lb_addr  for ranges, 0xXFXXXX
					when x"D5" =>  rfwd_buf32 <= c_addr		   ;--x"D5"
					when x"D6" =>  rfwd_buf32 <= c_cntlr	   ;--x"D6"
					when x"D7" =>  rfwd_buf32 <= c10_status   ;--x"D7"
					when x"D8" =>  rfwd_buf32 <= c10_datar    ;--x"D8"
					when x"D9" =>  rfwd_buf32 <= c_data		   ;--x"D9"
					when x"DA" =>  rfwd_buf32 <= c_bus_ctl	   ;--x"DA"
					when others => rfwd_buf32 <= x"C001FACE"	;-- default case
				end case;
			end if; -- lb_valid check
			
			-- outside of lb_valid check
			-- this might not be needed since Remote FW downlaod register list is so small.
			case lb_addr_r(23 downto 20) is -- note this is lb_addr_r, one additional flop from lb_addr
				--when x"0"   => lb_rdata_rfwd <= lb_rdata;   
				when x"F"   => lb_rdata_rfwd <= rfwd_buf32; -- this is read data coming from the rfwd registers
				when others => lb_rdata_rfwd <= x"FFFFFFFF"; -- default all F's
				--             lb_rdata_rfwd
			end case;	
		end if; -- end rising edge
	end process;
	
	-- enables for RW registers 
	-- added c_addr_slow to reduce fanout, JAL 5/10/24
	en_c_addr <= '1' when lb_rnw = '0' and lb_addr(23 downto 0) = x"F000D5" else '0';
	PROCESS(lb_clk,reset_n) begin 
	  IF(reset_n='0') THEN 
		  c_addr      <= (others => '0'); 
		  c_addr_slow <= (others => '0');
	  ELSIF (lb_clk'event AND lb_clk='1' AND en_c_addr='1') THEN 
		  c_addr      <= lb_wdata(31 downto 0); 
		  c_addr_slow <= lb_wdata(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_cntl <= '1' when lb_rnw = '0' and lb_addr(23 downto 0) = x"F000D6" else '0';
	PROCESS(lb_clk,reset_n) begin 
	  IF(reset_n='0') THEN 
		  c_cntlr<=(others => '0'); 
	  ELSIF (lb_clk'event AND lb_clk='1' AND en_c_cntl='1') THEN 
		  c_cntlr<=lb_wdata(31 downto 0); 
	  END IF; 
	END PROCESS; 
	
	en_c_data <= '1' when lb_rnw = '0' and lb_addr(23 downto 0) = x"F000D9" else '0';
	PROCESS(lb_clk,reset_n) begin 
	  IF(reset_n='0') THEN 
		  c_data<=(others => '0'); 
	  ELSIF (lb_clk'event AND lb_clk='1' AND en_c_data='1') THEN 
		  c_data<=lb_wdata(31 downto 0); 
	  END IF; 
	END PROCESS;

	en_c_bus_ctl <= '1' when lb_rnw = '0' and lb_addr(23 downto 0) = x"F000DA" else '0';
	PROCESS(lb_clk,reset_n) begin 
	  IF(reset_n='0') THEN 
		  c_bus_ctl<=(others => '0'); 
	  ELSIF (lb_clk'event AND lb_clk='1' AND en_c_bus_ctl='1') THEN 
		  c_bus_ctl<=lb_wdata(31 downto 0); 
	  END IF; 
	END PROCESS;
	
end architecture behavioral;