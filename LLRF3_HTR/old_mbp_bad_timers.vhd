--Notes: I had to shuffle around the RAM addressing and add wait states due to
--the extra clock cycles the RAM requires
--Not the most intelligent way of fixing the problem, but if it works, send it.
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
--
package mbp_lib is
	--
	type byte_array is array(natural range <>) of std_logic_vector(7 downto 0);
	--
end mbp_lib;
--
library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.mbp_lib.all;
--
entity mbp is
	generic(
		--CLK_FREQ	:	natural := 80000000; --defines clock rate of system clock
		CLK_FREQ	:	integer := 80000000;
		BAUD_RATE	:	natural := 921600;
		DEVICEADDR	:	natural := 0;
		HRTREGS	: natural := 106
		);
	port(
		CLK		:	in std_logic; --system clock input
		RESET	:	in std_logic; --active low
		--Serial UART Connections
		UART_DOUT_VLD	:	in std_logic;
		UART_DOUT	:	in std_logic_vector(7 downto 0);
		UART_DIN_RDY	:	in std_logic;
		OP_2_UART	: out std_logic_vector(7 downto 0);
		OP_VLD_2_UART	: out std_logic;
		--Reg Block Interface
		REGS_DIN	: in std_logic_vector(15 downto 0);
		REGS_LD		: out std_logic;
		REGS_ADDR	: out std_logic_vector(15 downto 0);
		REGS_DOUT	: out std_logic_vector(15 downto 0);
		ISA_ADDR_OUT	: out std_logic_vector(7 downto 0)
		);
end mbp;
architecture mixed of mbp is
--Input Port signals
	signal UART_DIN_RDY_d, UART_DIN_RDY_q : std_logic_vector(1 downto 0) := "00";
--Output Port signals
	signal OP_2_UART_d, OP_2_UART_q	: std_logic_vector(7 downto 0) := x"00"; 
	signal OP_VLD_2_UART_d, OP_VLD_2_UART_q	: std_logic := '0';
	signal ov_delay_d, ov_delay_q : std_logic_vector(1 downto 0) := "00"; --delay the output valid trig a couple clock cycles
	signal REGS_LD_d, REGS_LD_q	: std_logic := '0';
	signal REGS_ADDR_d, REGS_ADDR_q	: std_logic_vector(15 downto 0) := x"0000";
	signal REGS_DOUT_d, REGS_DOUT_q	: std_logic_vector(15 downto 0) := x"0000";
	signal MISC_OP_d, MISC_OP_q	: std_logic := '0';
	
--Define buffer
	--Modbus frames are limited to 256 bytes in size, which for TCP/IP
	--Allows for 248 bytes of non-header data
	constant buf_max : natural := 255;--max size of input buffer
	signal rx_trig_d, rx_trig_q :	std_logic_vector(1 downto 0) := "00"; --double buffer UART DVLD signal
	signal rx_buf_d, rx_buf_q	:	byte_array(0 to 12) := (others => x"00"); --input buffer
	signal buf_cnt_d, buf_cnt_q	:	natural range 0 to buf_max := 0; --counter to keep track of buffer location
	signal ram_block : byte_array(13 to buf_max); --unitialized RAM block
	signal ram_addr_d, ram_addr_q : natural range 13 to buf_max;
	signal ram_we_d, ram_we_q : std_logic; --RAM write enable signal
	signal ram_in_d, ram_in_q : std_logic_vector(7 downto 0);
	signal ram_out_d, ram_out_q : std_logic_vector(7 downto 0);
--Timout watchdog counters, with enable and reset
	-- constant wd1pt5 : natural := 60000;--750us / 12.5ns = 60000
	-- constant wd3pt5 : natural := 140000;--1.75ms / 12.5ns = 140000
	-- constant wd2pt0 : natural := 80000;--1ms / 12.5ns = 80000
--	constant wd1pt5 : natural := ((CLK_FREQ / 1000000) * 750);
--	constant wd3pt5 : natural := ((CLK_FREQ / 1000000) * 1750);
--	constant wd2pt0 : natural := ((CLK_FREQ / 1000000) * 1000);
	constant wd1pt5 : natural := ((CLK_FREQ / 1000000) * 7);
	constant wd3pt5 : natural := ((CLK_FREQ / 1000000) * 17);
	constant wd2pt0 : natural := ((CLK_FREQ / 1000000) * 10);
	signal wdTimer_d, wdTimer_q : natural range 0 to wd3pt5 := 0;
	signal wdMAX_d, wdMAX_q : natural range 0 to wd3pt5 := 0;
--Define state type
	type stType is (
					cnt_st,--Generic timer state, eliminates pre_idle,tmout_wd, and short_idle states
					idle,--waiting for beginning of packet
					get_data,--read incoming data from UART
					ltch_data, --calc data from rx_buf
					calc_exc, --calculate mbp exception
					ltch_op, --latch output hdr data
					print_hdr, --print header to UART
					--write_data, --write data to regs
					ltch_ram_addr,
					write_data_upper, --write data to regs
					write_data_lower, --write data to regs
					read_data, --read data from regs
					ld_hi, --switch regs ld signal high
					ltch_upr_byte, --latch upper byte of reg to UART op
					ld_low, --switch regs ld signal low
					ram_wait1, --first wait state after latching upper byte from ram (to allow ram set up)
					ram_wait2 --second wait state after latching lower byte from ram (to allow ram set up)
					);
--Instantiate the state machine
	signal state_q,state_d : stType := cnt_st;
--Calculated value (from rx_buf) signals
	signal frame_length_d, frame_length_q : unsigned(15 downto 0) := x"0000";
	signal start_addr_d, start_addr_q :	unsigned(15 downto 0) := x"0000";
	signal numregs_d, numregs_q : unsigned(15 downto 0) := x"0000";
	signal hrtregs_us_d, hrtregs_us_q : unsigned(15 downto 0) := x"0000";
	signal wm_cnt_d, wm_cnt_q	:	natural range 0 to buf_max := 0;
	signal exc_d, exc_q : std_logic_vector(7 downto 0) := x"00";
--OP logic signals
	signal op_hdr_d, op_hdr_q : byte_array(0 to 11) := (others => x"00");
	signal hdr_bc_d, hdr_bc_q : unsigned(31 downto 0) := (others => '0');
	signal hdr_lngth_d, hdr_lngth_q : unsigned(31 downto 0) := (others => '0');
	signal addr_cnt_d, addr_cnt_q : unsigned(15 downto 0) := x"0000";
	signal op_int_d, op_int_q : natural range 0 to buf_max := 0; --number of bytes to be clocked out
	signal op_cnt_d, op_cnt_q : natural range 0 to buf_max := 0; --output counter
	signal read_bc_d, read_bc_q : natural range 0 to 1 := 0; 
--
--
begin
-- --RAM process
	ram_proc : process(clk)
	begin
		if(clk'event and clk = '1') then
			if(ram_we_q = '1') then
				ram_block(ram_addr_q) <= ram_in_q;
			end if;
			ram_out_d <= ram_block(ram_addr_q);
		end if;
	end process;
--Synchronous process
	process(CLK,RESET)
	begin
		if(RESET = '0') then
			ram_addr_q <= 13;
			ram_we_q <= '0'; 
			ram_in_q <= (others => '0');
			ram_out_q <= (others => '0');
			rx_buf_q <= (others => x"00");
			UART_DIN_RDY_q <= "00";
			OP_2_UART_q <= x"00";
			OP_VLD_2_UART_q <= '0';
			ov_delay_q <= "00";
			REGS_LD_q <= '0';
			REGS_ADDR_q <= x"0000";
			REGS_DOUT_q <= x"0000";
			rx_trig_q <= "00";
			buf_cnt_q <= 0;
			wdTimer_q <= 0;
			wdMAX_q <= wd3pt5;
			state_q <= cnt_st;
			frame_length_q <= x"0000";
			start_addr_q <= x"0000";
			numregs_q <= x"0000";
			hrtregs_us_q <= x"0000";
			wm_cnt_q <= 0;
			exc_q <= x"00";
			op_hdr_q <= (others => x"00");
			hdr_bc_q <= (others => '0');
			hdr_lngth_q <= (others => '0');
			addr_cnt_q <= x"0000";
			op_int_q <= 0;
			op_cnt_q <= 0;
			read_bc_q <= 0;
		elsif(CLK'event and CLK = '1') then
			ram_addr_q <= ram_addr_d;
			ram_we_q <= ram_we_d; 
			ram_in_q <= ram_in_d;
			ram_out_q <= ram_out_d;
			rx_buf_q <= rx_buf_d;
			UART_DIN_RDY_q <= UART_DIN_RDY_d;
			OP_2_UART_q <= OP_2_UART_d;
			OP_VLD_2_UART_q <= OP_VLD_2_UART_d;
			ov_delay_q <= ov_delay_d;
			REGS_LD_q <= REGS_LD_d;
			REGS_ADDR_q <= REGS_ADDR_d;
			REGS_DOUT_q <= REGS_DOUT_d;
			rx_trig_q <= rx_trig_d;
			buf_cnt_q <= buf_cnt_d;
			wdTimer_q <= wdTimer_d;
			wdMAX_q <= wdMAX_d;
			state_q <= state_d;
			frame_length_q <= frame_length_d;
			start_addr_q <= start_addr_d;
			numregs_q <= numregs_d;
			hrtregs_us_q <= hrtregs_us_d;
			wm_cnt_q <= wm_cnt_d;
			exc_q <= exc_d;
			op_hdr_q <= op_hdr_d;
			hdr_bc_q <= hdr_bc_d;
			hdr_lngth_q <= hdr_lngth_d;
			addr_cnt_q <= addr_cnt_d;
			op_int_q <= op_int_d;
			op_cnt_q <= op_cnt_d;
			read_bc_q <= read_bc_d;
		end if;
	end process;
--Next State Logic
	--Default FF statements
	--
	Next_State_Logic: process(state_q,UART_DOUT_VLD,rx_trig_q,UART_DIN_RDY,wdTimer_q,buf_cnt_q,exc_q,rx_buf_q,frame_length_q,start_addr_q,hrtregs_us_q,numregs_q, op_cnt_q,UART_DIN_RDY_q,read_bc_q,addr_cnt_q,OP_2_UART_q,OP_VLD_2_UART_q,REGS_LD_q,REGS_ADDR_q,REGS_DOUT_q,wm_cnt_q,op_hdr_q,hdr_bc_q,hdr_lngth_q,UART_DOUT,op_int_q,REGS_DIN,wdMAX_q, ram_out_q,ov_delay_q)
	begin
		--Double buffer input signals
		UART_DIN_RDY_d(0) <= UART_DIN_RDY;
		UART_DIN_RDY_d(1) <= UART_DIN_RDY_q(0);
		rx_trig_d(0) <= UART_DOUT_VLD;
		rx_trig_d(1) <= rx_trig_q(0);
		--Default FF statements
		ram_addr_d <= ram_addr_q;
		ram_we_d <= ram_we_q; 
		ram_in_d <= ram_in_q;
		--ram_out_d <= ram_out_q;
		OP_2_UART_d <= OP_2_UART_q;
		OP_VLD_2_UART_d <= OP_VLD_2_UART_q;
		--ov_delay_d <= ov_delay_q;
		ov_delay_d(0) <= OP_VLD_2_UART_q;
		ov_delay_d(1) <= ov_delay_q(0);
		REGS_LD_d <= REGS_LD_q;
		REGS_ADDR_d <= REGS_ADDR_q;
		REGS_DOUT_d <= REGS_DOUT_q;
		rx_buf_d <= rx_buf_q;
		buf_cnt_d <= buf_cnt_q;
		wdTimer_d <= wdTimer_q;
		wdMAX_d <= wdMAX_q;
		state_d <= state_q;
		frame_length_d <= frame_length_q;
		start_addr_d <= start_addr_q;
		numregs_d <= numregs_q;
		hrtregs_us_d <= hrtregs_us_q;
		wm_cnt_d <= wm_cnt_q;
		exc_d <= exc_q;
		op_hdr_d <= op_hdr_q;
		hdr_bc_d <= hdr_bc_q;
		hdr_lngth_d <= hdr_lngth_q;
		addr_cnt_d <= addr_cnt_q;
		op_int_d <= op_int_q;
		op_cnt_d <= op_cnt_q;
		read_bc_d <= read_bc_q;
		--
		case(state_q) is
			--
			when cnt_st => 
				ram_we_d <= '0';
				if(rx_trig_q = "01") then --another incoming byte
					if(wdMAX_q = wd1pt5) then
						wdTimer_d <= 0;
						state_d <= get_data;
					elsif(wdMAX_q = wd2pt0) then
						wdTimer_d <= 0;
						wdMAX_d <= wd3pt5;
						state_d <= cnt_st;
					elsif(wdMAX_q = wd3pt5) then
						buf_cnt_d <= 0;
						wdTimer_d <= 0;
						state_d <= cnt_st;
					else
						wdMAX_d <= wd3pt5;
						state_d <= cnt_st;
					end if;
				elsif(wdTimer_q = wdMAX_q) then --timeout occurs
					if(wdMAX_q = wd1pt5) then
						wdTimer_d <= 0;
						if(buf_cnt_q > 11) then --command has been received
							wdMAX_d <= wd2pt0;
							state_d <= cnt_st;
						else --timeout occured and no valid cmd
							wdMAX_d <= wd3pt5;
							state_d <= cnt_st;
						end if;
					elsif(wdMAX_q = wd2pt0) then
						wdTimer_d <= 0;
						state_d <= ltch_data;
					elsif(wdMAX_q = wd3pt5) then
						wdTimer_d <= 0;
						state_d <= idle;
					else
						wdMAX_d <= wd3pt5;
						state_d <= cnt_st;
					end if;
				else
					wdTimer_d <= wdTimer_q + 1;
					state_d <= cnt_st;
				end if;
			--
			when idle =>
				buf_cnt_d <= 0;
				if(rx_trig_q = "01") then --byte available from UART
					state_d <= get_data;
				else 
					state_d <= idle;
				end if;
			--
			when get_data => --latching available data
					if(buf_cnt_q = buf_max) then --buffer is full, must complete short idle
						buf_cnt_d <= 0;
						wdMAX_d <= wd2pt0;
						state_d <= cnt_st;
					else --store data beyond the header in ram
						if(buf_cnt_q < 13) then
							rx_buf_d(buf_cnt_q) <= UART_DOUT;
						else
							ram_addr_d <= buf_cnt_q;
							ram_we_d <= '1';
							ram_in_d <= UART_DOUT;
						end if;
						buf_cnt_d <= buf_cnt_q +1;
						wdMAX_d <= wd1pt5;
						state_d <= cnt_st;
					end if;
			--
			when ltch_data => --latch data from input buffer, convert from slv
				frame_length_d <= unsigned(rx_buf_q(4)) & unsigned(rx_buf_q(5));
				start_addr_d <= unsigned(rx_buf_q(8)) & unsigned(rx_buf_q(9));
				if(rx_buf_q(7) = x"06") then
					numregs_d <= x"0001";
				else
					numregs_d <= unsigned(rx_buf_q(10)) & unsigned(rx_buf_q(11));
				end if;
				hrtregs_us_d <= to_unsigned(HRTREGS,16);
				state_d <= calc_exc;
			--
			when calc_exc => --calculate exception from latched data
				hdr_bc_d <= (numregs_q * x"0002"); --reg quantity byte cnt
				hdr_lngth_d <= (numregs_q * x"0002") + x"0003"; --add hdr regs to bytecnt for lngth
				--Exception x03 must also cover incorrect byte cnt for write multiple command
				if((buf_cnt_q /= (frame_length_q + x"0006")) or ((buf_cnt_q /= (unsigned(rx_buf_q(12)) + x"000D")) and (rx_buf_q(7) = x"10"))) then 
					exc_d <= x"03";-- x"03": Illegal data value
				elsif((rx_buf_q(7) /= x"03") AND (rx_buf_q(7) /= x"06") AND (rx_buf_q(7) /= x"10")) then  
					exc_d <= x"01";-- x"01": Unsupported function
				elsif((start_addr_q >= hrtregs_us_q) OR (numregs_q = x"0000") OR ((hrtregs_us_q <= (start_addr_q + (numregs_q - 1))) AND (rx_buf_q(7) /= x"06"))) then
					exc_d <= x"02";-- x"02": Illegal address value
				else exc_d <= x"00";--No exception found
				end if;
				state_d <= ltch_op;
			--
			when ltch_op => --latch output (to UART) reg data
				op_hdr_d(0 to 3) <= rx_buf_q(0 to 3);--Copy TID & PID
				op_hdr_d(6) <= rx_buf_q(6);--Copy UID
				if(exc_q /= x"00") then --If there is an exception
					op_hdr_d(4 to 5) <= x"00" & x"03";--Set length to 3 bytes
					op_hdr_d(7) <= '1' & rx_buf_q(7)(6 downto 0);--Modify original function code for exception
					op_hdr_d(8) <= exc_q;--Set the exception value
					op_int_d <= 9;
					state_d <= print_hdr;
				else --No exception found
					op_hdr_d(7) <= rx_buf_q(7); --Copy function code
					if(rx_buf_q(7) = x"03") then --If read cmd, set length and byte cnt
						op_hdr_d(4) <= std_logic_vector(hdr_lngth_q(15 downto 8));
						op_hdr_d(5) <= std_logic_vector(hdr_lngth_q(7 downto 0));
						op_hdr_d(8) <= std_logic_vector(hdr_bc_q(7 downto 0));
						op_int_d <= 9;
						state_d <= print_hdr;
					elsif((rx_buf_q(7) = x"06") OR (rx_buf_q(7) = x"10")) then --Write cmd
						--Set response length to 6, Copy echo data
						op_hdr_d(4) <= x"00";
						op_hdr_d(5) <= x"06";
						op_hdr_d(8) <= rx_buf_q(8);
						op_hdr_d(9) <= rx_buf_q(9);
						op_hdr_d(10) <= rx_buf_q(10);
						op_hdr_d(11) <= rx_buf_q(11);
						op_int_d <= 12;
						ram_addr_d <= (wm_cnt_q +13);
						state_d <= ltch_ram_addr;
					end if;
				end if;
			--
			when print_hdr => --print output reg to UART
			--*** want to switch this so that the data sets up at least one clock cycle advanced from the vld trigger
				if(op_cnt_q < op_int_q) then
					if(((op_cnt_q = 0) and (UART_DIN_RDY_q = "11")) or
						((op_cnt_q > 0) and (UART_DIN_RDY_q = "01"))) then
						OP_2_UART_d <= op_hdr_q(op_cnt_q);
						OP_VLD_2_UART_d <= '1';
						op_cnt_d <= op_cnt_q + 1;
					else 
						OP_VLD_2_UART_d <= '0';
					end if;
					state_d <= print_hdr;
				else 
					op_cnt_d <= 0;
					OP_VLD_2_UART_d <= '0';
					if(exc_q /= x"00") then
						wdMAX_d <= wd3pt5;
						state_d <= cnt_st;
					elsif(rx_buf_q(7) = x"03") then
						state_d <= read_data;
					else
						wdMAX_d <= wd3pt5;
						state_d <= cnt_st;
					end if;
				end if;
			--
			when read_data => --read data from regs
				REGS_ADDR_d <= std_logic_vector(start_addr_q + addr_cnt_q);-- latch address
				state_d <= ld_hi;
			--
			when ltch_ram_addr =>
				--ram_addr_d <= (wm_cnt_q +13);
				--state_d <= write_data_upper;
				state_d <= ram_wait1;
			--
			when ram_wait1 => --wait 1 clock cycle to allow ram to latch
				ram_addr_d <= (wm_cnt_q +14);
				state_d <= write_data_upper;
			--
			when write_data_upper => --write data to regs
				REGS_ADDR_d <= std_logic_vector(start_addr_q + addr_cnt_q); --latch address
				if(rx_buf_q(7) = x"06") then --Cmd is write single
					REGS_DOUT_d(15 downto 8) <= rx_buf_q(10);
				else 
					REGS_DOUT_d(15 downto 8) <= ram_out_q;
					--ram_addr_d <= (wm_cnt_q +14);
				end if;
				--state_d <= write_data_lower;
				state_d <= ram_wait2;
			--
			when ram_wait2 => 
				state_d <= write_data_lower;
			--
			when write_data_lower => --write data to regs
				if(rx_buf_q(7) = x"06") then --Cmd is write single
					REGS_DOUT_d(7 downto 0) <= rx_buf_q(11);
				else 
					REGS_DOUT_d(7 downto 0) <= ram_out_q;
				end if;
				state_d <= ld_hi;
			--
			when ld_hi => --load high signal to regs block
				if(rx_buf_q(7) = x"03") then
					if(UART_DIN_RDY_q = "01") then
						if(read_bc_q = 0) then
							OP_2_UART_d <= REGS_DIN(15 downto 8); --latch upper byte of data from regs to print to uart
							state_d <= ltch_upr_byte;
						else
							OP_2_UART_d <= REGS_DIN(7 downto 0); --latch lower byte of data from regs to print to uart
							read_bc_d <= 0;
							addr_cnt_d <= addr_cnt_q + x"0001";
							state_d <= ld_low;
						end if;
						OP_VLD_2_UART_d <= '1';
					else
						state_d <= ld_hi;
					end if;
				else
					addr_cnt_d <= addr_cnt_q + x"0001";
					wm_cnt_d <= wm_cnt_q + 2;
					REGS_LD_d <= '1';
					state_d <= ld_low;
				end if;
			--
			when ltch_upr_byte => --latch upper byte of data from regs to print to uart
				read_bc_d <= 1;
				OP_VLD_2_UART_d <= '0';
				state_d <= ld_hi;
			--
			when ld_low => --load low signal to regs block
				REGS_LD_d <= '0';
				if(rx_buf_q(7) = x"03") then
					OP_VLD_2_UART_d <= '0';
					if(addr_cnt_q < numregs_q) then
						state_d <= read_data;
					else
						addr_cnt_d <= x"0000";
						wm_cnt_d <= 0;
						wdMAX_d <= wd3pt5;
						state_d <= cnt_st;
					end if;
				else
					if(addr_cnt_q < numregs_q) then
						ram_addr_d <= (wm_cnt_q +13);
						state_d <= ltch_ram_addr;
					else
						addr_cnt_d <= x"0000";
						wm_cnt_d <= 0;
						state_d <= print_hdr;
					end if;
				end if;
			--
			when others =>
				wdMAX_d <= wd3pt5;
				state_d <= cnt_st;
		end case;
	end process;
--Output Port Assignments
	--Outputs to Reg Block
	REGS_LD <= REGS_LD_q;
	REGS_ADDR <= REGS_ADDR_q;
	--
	ISA_ADDR_OUT <= REGS_ADDR_q(6 downto 0) & '0';
	--
	REGS_DOUT <= REGS_DOUT_q;
	--Outputs to UART
	OP_2_UART <= OP_2_UART_q;
	--OP_VLD_2_UART <= OP_VLD_2_UART_q;
	OP_VLD_2_UART <= ov_delay_q(1); --delayed ov by two clock cycles for stability
	--
end mixed;