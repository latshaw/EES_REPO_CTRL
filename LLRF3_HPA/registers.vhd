
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.HPA.all;


entity registers is
generic(
    BASE_ADDR :unsigned(23 downto 0) := x"000000";
    NUM_REGS  :integer := 28);
port(
    reset_n    : in std_logic;                        -- System reset (active low)
    clock      : in std_logic;                        -- System clock (125MHz)

    -- local bus inputs
    lb_valid   : in std_logic;
    lb_rnw     : in std_logic;                     
    lb_addr    : in std_logic_vector(23 downto 0);
    lb_renable : in std_logic;
    lb_wdata   : in std_logic_vector(15 downto 0);

    hv_permit  : in std_logic_vector(7 downto 0);     -- High voltage permits from FCC Chassis
    din        : in std_logic_vector(7 downto 0);     -- Digital in
    faults_in  : in std_logic_vector_array16(0 to 6); -- Analog inputs faults

    -- outputs
    lb_rdata   : out std_logic_vector(15 downto 0);   -- data output    
    rf_permit  : buffer std_logic_vector(7 downto 0); -- RF permits to FCC's
    dout       : out std_logic_vector(7 downto 0);    -- Digital out
    fil_on     : out std_logic;                       -- Filament on
    hv_on      : out std_logic;                       -- HV on
    bypass     : out std_logic_vector(7 downto 0);    -- Cavity bypass
    ioc_ok     : out std_logic;
    fault      : out std_logic
);
end registers;

architecture rtl of registers is

constant HRT_VERSION  :std_logic_vector(15 downto 0) := x"0001";--x"0001"; -- Hardware Register Table Version
constant FIRM_VERSION :std_logic_vector(15 downto 0) := x"0004";--x"0001"; -- Firmware Version
constant CLK_FREQ     :integer := 125000000;


type reg_type is record

    -- UDP registers (see HRT spreadsheet for detail)
    reg          :std_logic_vector_array16(0 to NUM_REGS-1);
    
    -- Internal registers
    cnt          :unsigned(28 downto 0);         -- heartbeat counter
    fil_timer    :unsigned(27 downto 0);         -- filament timer
    KERR_cnt     :unsigned(27 downto 0);         -- fault reset counter
    --fault_buf    :std_logic_vector(47 downto 0); -- fault status buffer register (used for capturing first fault)
    fault_timer   :unsigned(26 downto 0);
    load         :std_logic;                     -- load buffer
    renable      :std_logic;                     -- read enable
    heart        :std_logic;                     -- heartbeat edge detect register
    fil          :std_logic;                     -- buffered filaments on bit
    reset        :std_logic;                     -- reset buffer
    KRRP_timer   :unsigned_array27(0 to 7);      -- 1 sec fault timers for klystron reflected power
    KBCU_timer   :unsigned_array27(0 to 7);      -- 1 sec fault timers for klystron body current
    hvon_timer   :unsigned(26 downto 0);         -- 1 sec timeout after hv on
    rdata_buffer :std_logic_vector(15 downto 0); -- read data output buffer
    ioc_counter  :unsigned(31 downto 0);         -- ioc activity counter
    
end record reg_type;


signal D,Q          :reg_type; -- register inputs/outputs
signal fil_edge     :std_logic;
--signal fault_edge   :std_logic;
signal faults       :std_logic_vector_array16(0 to 7);
signal heartbeat    :std_logic;
signal address      :integer range 0 to NUM_REGS-1; -- calculated address
--signal addr_temp    :unsigned(23 downto 0); -- intermediate calculated address
signal fil_ready    :std_logic;
signal hv_ready     :std_logic;
signal KRRP_timeout :std_logic;
signal KBCU_timeout :std_logic;
signal cav1_ok      :std_logic;
signal cav2_ok      :std_logic;
signal cav3_ok      :std_logic;
signal cav4_ok      :std_logic;
signal cav5_ok      :std_logic;
signal cav6_ok      :std_logic;
signal cav7_ok      :std_logic;
signal cav8_ok      :std_logic;
signal KRRP_ok      :std_logic;
signal KBCU_ok      :std_logic;
signal write_edge   :std_logic;
signal read_edge    :std_logic;
signal addr_valid   :std_logic;


-- HPA Bit Mnemonics
alias KFAO is Q.reg(XKDIN)(0);  -- filament ac on/off status
alias KAXM is Q.reg(XKDIN)(1);  -- aux ac on/off status
alias KHVO is Q.reg(XKDIN)(2);  -- high voltage on/off status
alias KEIL is Q.reg(XKDIN)(3);  -- external interlocks
alias KEOL is Q.reg(XKDIN)(4);  -- hpa dc overload
alias KECO is Q.reg(XKDIN)(5);  -- hpa coolant/temperature fault
alias KFON is Q.reg(XKDOUT)(0); -- filaments on bit
alias KAXS is Q.reg(XKDOUT)(1); -- aux ac on bit
alias KERR is Q.reg(XKDOUT)(2); -- HPA fault reset
alias KHVS is Q.reg(XKDOUT)(3); -- high voltage on bit

----------------------------------------------------------------------------------------
begin
----------------------------------------------------------------------------------------

D.ioc_counter <= (others => '0') when read_edge = '1'
                 else Q.ioc_counter + 1 when Q.ioc_counter < CLK_FREQ
                 else Q.ioc_counter;

ioc_ok <= '1' when Q.ioc_counter < CLK_FREQ else '0';

-- Fault LED
fault <= '0' when (Q.reg(KFLT1)(7 downto 0) = x"FF" or Q.reg(XKBYP)(0) = '1')
                  and (Q.reg(KFLT2)(7 downto 0) = x"FF" or Q.reg(XKBYP)(1) = '1')
                  and (Q.reg(KFLT3)(7 downto 0) = x"FF" or Q.reg(XKBYP)(2) = '1')
                  and (Q.reg(KFLT4)(7 downto 0) = x"FF" or Q.reg(XKBYP)(3) = '1')
                  and (Q.reg(KFLT5)(7 downto 0) = x"FF" or Q.reg(XKBYP)(4) = '1')
                  and (Q.reg(KFLT6)(7 downto 0) = x"FF" or Q.reg(XKBYP)(5) = '1')
                  and (Q.reg(KFLT7)(7 downto 0) = x"FF" or Q.reg(XKBYP)(6) = '1')
                  and (Q.reg(KFLT8)(7 downto 0) = x"FF" or Q.reg(XKBYP)(7) = '1')
                  else '1';

-- calculate address
address <= to_integer( (unsigned(lb_addr) - BASE_ADDR) );

-- check for valid address
addr_valid <= '1' when (unsigned(lb_addr) >= BASE_ADDR and unsigned(lb_addr) < BASE_ADDR+NUM_REGS)
              else '0';

-- local bus read/write (read = 1)
D.load <= lb_valid and not lb_rnw;
write_edge <= '1' when lb_valid = '1' and lb_rnw = '0' and addr_valid = '1' else '0';--write_edge <= Q.load and addr_valid;--(Q.load and not D.load) and addr_valid;

-- local bus read enable
D.renable <= lb_renable;
read_edge <= Q.renable and not D.renable;



-- High voltage permit (bit 7 of klystron fault status registers 1-8)
g2: for i in 0 to 7 generate
        D.reg(i+KFLT1)(7) <= ( hv_permit(i) or Q.reg(XKBYP)(i) ) and ( KERR or Q.reg(i+KFLT1)(7) );
    end generate g2;

-- RF permit 1-8
g9: for i in 0 to 7 generate
        rf_permit(i) <= '1' when (KHVS = '1' and Q.reg(i+KFLT1)(4) = '1') 
		                   or Q.reg(XKDAQ)(i) = '1'
                         else '0';
    end generate g9;
--rf_permit <= Q.reg(XKDAQ)(7 downto 0);

-- rf permit status readback
D.reg(XKRFP) <= x"00" & rf_permit;

-- ignore fil high faults until filaments or hv state + delay time
faults(0) <= faults_in(0) when (KFON = '1' or KHVS = '1') and Q.fault_timer = (2**27-1)
            else (others => '0');

-- pass other faults through
g6: for i in 1 to 6 generate
        faults(i) <= faults_in(i);
    end generate g6;

-- timer used to delay fault latching until valid data is present
D.fault_timer <= (others => '0') when KFON = '0' else Q.fault_timer + 1
                when (KFON = '1' and Q.fault_timer < 2**27-1)
                else Q.fault_timer;

-- HV on timeout (1 sec)
D.hvon_timer <= (others => '0') when KHVS = '0'
                    else Q.hvon_timer + 1 when Q.hvon_timer < CLK_FREQ
                    else Q.hvon_timer;

-- Hearbeat Counter
D.cnt <= Q.cnt + 1 when (Q.cnt < 4*CLK_FREQ) -- 500e+6 * 8e-9 sec = 4 sec
            else (others => '0');
heartbeat <= '0' when Q.cnt < 2*CLK_FREQ else '1'; -- toggle heartbeat bit every 2 sec
D.heart <= heartbeat;

---------------------------------------------------------------------------------------------------------------
-- Filament Timer
---------------------------------------------------------------------------------------------------------------

D.fil <= KFON; -- filaments on

fil_edge <= '1' when (Q.fil xor D.fil) = '1' else '0'; -- detect edge of "filaments on" bit

D.fil_timer <= (others => '0') when fil_edge = '1' -- reset if filament on/off state changes
                else Q.fil_timer + 1
                when (Q.fil_timer < CLK_FREQ)
                else (others => '0');

-- Filament Warm Up Timer (counts up @1hz when filaments are turned on / counts down @2hz when turned off)
D.reg(XKFWT) <= lb_wdata when (write_edge = '1' and address = XKFWT and unsigned(lb_wdata) <= 600 and KHVS = '0')
    else std_logic_vector(unsigned(Q.reg(XKFWT)) + 1) 
    when Q.fil_timer = CLK_FREQ and Q.fil = '1' and (unsigned(Q.reg(XKFWT)) /= 600)											-- Count up.
    else std_logic_vector(unsigned(Q.reg(XKFWT)) - 1) 
    when (Q.fil_timer = CLK_FREQ/2 or Q.fil_timer = CLK_FREQ) and Q.fil = '0' and (unsigned(Q.reg(XKFWT)) /= 0)	-- Count down.
    else Q.reg(XKFWT); --hold

---------------------------------------------------------------------------------------------------------------
-- Registers
---------------------------------------------------------------------------------------------------------------

-- Heartbeat register
D.reg(XKHRTB)(15 downto 1) <= (others => '0');
D.reg(XKHRTB)(0) <= heartbeat;

-- HPA Restore Status Register
D.reg(HPARSTR) <= lb_wdata when (write_edge = '1' and address = HPARSTR) else Q.reg(HPARSTR);

D.reg(XKHRTV)  <= HRT_VERSION;  -- Hardware Register Table File Version
D.reg(XKFIRMV) <= FIRM_VERSION; -- Firmware Version

-- Digital inputs
D.reg(XKDIN)(3) <= '0' when din(3) = '0' else '1' when (din(3) = '1' and KERR = '1') else Q.reg(XKDIN)(3); -- latched interlocks fault
D.reg(XKDIN)(4) <= '0' when din(4) = '0' else '1' when (din(4) = '1' and KERR = '1') else Q.reg(XKDIN)(4); -- latched DC overload fault
D.reg(XKDIN)(5) <= '0' when din(5) = '0' else '1' when (din(5) = '1' and KERR = '1') else Q.reg(XKDIN)(5); -- latched overtemp fault
D.reg(XKDIN)(2 downto 0) <= din(2 downto 0); -- HV status/AC status/Filament status
D.reg(XKDIN)(7 downto 6) <= din(7 downto 6); -- Spare
D.reg(XKDIN)(15 downto 8) <= (others =>'0');

----Digital outputs
D.reg(XKDOUT)(15 downto 4) <= lb_wdata(15 downto 4) when (write_edge = '1' and address = XKDOUT) else Q.reg(XKDOUT)(15 downto 4); -- spare relay outputs
D.reg(XKDOUT)(3) <= '0' when hv_ready = '0' else lb_wdata(3) when (write_edge = '1'and address = XKDOUT) else Q.reg(XKDOUT)(3);   -- hv on/off bit
D.reg(XKDOUT)(1) <= lb_wdata(1) when (write_edge = '1'and address = XKDOUT) else Q.reg(XKDOUT)(1);                                -- aux ac on/off bit
D.reg(XKDOUT)(0) <= '0' when fil_ready = '0' else lb_wdata(0) when (write_edge = '1'and address = XKDOUT) else Q.reg(XKDOUT)(0);  -- fil on/off bit
fil_on <= KFON;
hv_on <= KHVS;

D.reset <= '1' when (write_edge = '1' and address = XKDOUT and lb_wdata(2) = '1') else '0';
-- fault reset bit (KERR)
D.reg(XKDOUT)(2) <= '1' when (Q.reset = '0' and D.reset = '1') else '0' when (D.KERR_cnt = CLK_FREQ) else Q.reg(XKDOUT)(2);

dout <= Q.reg(XKDOUT)(7 downto 0);
--dout(3 downto 0) <= Q.reg(XKDAQ)(1) & Q.reg(XKDOUT)(2) & Q.reg(XKDOUT)(1) & Q.reg(XKDAQ)(0);

-- fault reset counter ( generates a 1 second pulse )
D.KERR_cnt <= Q.KERR_cnt + 1 when (Q.reg(XKDOUT)(2) = '1' and Q.KERR_cnt < CLK_FREQ) else (others => '0');

-- cavity bypass 1-8
D.reg(XKBYP) <= lb_wdata when (write_edge = '1' and address = XKBYP) else Q.reg(XKBYP);
bypass <= Q.reg(XKBYP)(7 downto 0);

-- DAQ control register
D.reg(XKDAQ) <= lb_wdata when (write_edge = '1' and address = XKDAQ) else Q.reg(XKDAQ);


---------------------------------------------------------------------------------------------------------------
-- fault latch registers
---------------------------------------------------------------------------------------------------------------

D.reg(KFLT1)(15 downto 8) <= (others => '0');
D.reg(KFLT2)(15 downto 8) <= (others => '0');
D.reg(KFLT3)(15 downto 8) <= (others => '0');
D.reg(KFLT4)(15 downto 8) <= (others => '0');
D.reg(KFLT5)(15 downto 8) <= (others => '0');
D.reg(KFLT6)(15 downto 8) <= (others => '0');
D.reg(KFLT7)(15 downto 8) <= (others => '0');
D.reg(KFLT8)(15 downto 8) <= (others => '0');

-- latched faults (grouped by cavity)
g3: for i in 0 to 7 generate
        g4: for j in 0 to 6 generate
                D.reg(i+KFLT1)(j) <= '0' when faults(j)(i) = '1'
                else '1' when (faults(j)(i) = '0' and Q.reg(XKDOUT)(2) = '1')
                else Q.reg(i+KFLT1)(j);
            end generate g4;
    end generate g3;

    
---------------------------------------------------------------------------------------------------------------
-- Fault Logic
---------------------------------------------------------------------------------------------------------------

-- Filaments ready
fil_ready <= '1' when KAXM = '1' and KAXS = '1'
                -- fil V high fault bits (1=good)
                and Q.reg(KFLT1)(0) = '1' and Q.reg(KFLT2)(0) = '1' and Q.reg(KFLT3)(0) = '1' and Q.reg(KFLT4)(0) = '1'
                and Q.reg(KFLT5)(0) = '1' and Q.reg(KFLT6)(0) = '1' and Q.reg(KFLT7)(0) = '1' and Q.reg(KFLT8)(0) = '1'
            else '0';

D.reg(XKCSR)(0) <= fil_ready;

-- HV ready
D.reg(XKCSR)(1) <= '0' when KRRP_timeout = '1'
                    or KBCU_timeout = '1'
                    or (cav1_ok and cav2_ok and cav3_ok and cav4_ok and cav5_ok and cav6_ok and cav7_ok and cav8_ok) = '0'
                    or (fil_ready and KEIL and KEOL and KFAO and KFON and KECO) = '0'
                    or unsigned(Q.reg(XKFWT)) /= 600
                    or (KRRP_ok = '0' and KHVS = '0')
                    or (KBCU_ok = '0' and KHVS = '0')
                    or (Q.hvon_timer = CLK_FREQ and KHVO = '0')
                else '1' when KRRP_ok = '1' and KBCU_ok = '1' and KHVS = '0'
                else Q.reg(XKCSR)(1);

D.reg(XKCSR)(15 downto 2) <= lb_wdata(15 downto 2) when (write_edge = '1' and address = XKCSR) 
                             else Q.reg(XKCSR)(15 downto 2);

KRRP_ok <= '1' when (Q.reg(KFLT1)(4) and Q.reg(KFLT2)(4) and Q.reg(KFLT3)(4) and Q.reg(KFLT4)(4) and
            Q.reg(KFLT5)(4) and Q.reg(KFLT6)(4) and Q.reg(KFLT7)(4) and Q.reg(KFLT8)(4)) = '1' else '0';

KBCU_ok <= '1' when (Q.reg(KFLT1)(2) and Q.reg(KFLT2)(2) and Q.reg(KFLT3)(2) and Q.reg(KFLT4)(2) and
            Q.reg(KFLT5)(2) and Q.reg(KFLT6)(2) and Q.reg(KFLT7)(2) and Q.reg(KFLT8)(2)) = '1' else '0';

hv_ready <= Q.reg(XKCSR)(1);

-- 1 second fault window for KRRP/KBCU ( drops HV when KRRP/KBCU persists 1 sec after RF off )
g10: for i in 0 to 7 generate
        D.KRRP_timer(i) <= (others => '0') when faults(4)(i) = '0'
                        else Q.KRRP_timer(i) when Q.KRRP_timer(i) = CLK_FREQ
                        else Q.KRRP_timer(i) + 1;

        D.KBCU_timer(i) <= (others => '0') when faults(2)(i) = '0'
                        else Q.KBCU_timer(i) when Q.KBCU_timer(i) = CLK_FREQ
                        else Q.KBCU_timer(i) + 1;
    end generate g10;

KRRP_timeout <= '1' when Q.KRRP_timer(0) = CLK_FREQ
                    or Q.KRRP_timer(1) = CLK_FREQ
                    or Q.KRRP_timer(2) = CLK_FREQ
                    or Q.KRRP_timer(3) = CLK_FREQ
                    or Q.KRRP_timer(4) = CLK_FREQ
                    or Q.KRRP_timer(5) = CLK_FREQ
                    or Q.KRRP_timer(6) = CLK_FREQ
                    or Q.KRRP_timer(7) = CLK_FREQ
                    else '0';

KBCU_timeout <= '1' when Q.KBCU_timer(0) = CLK_FREQ
                    or Q.KBCU_timer(1) = CLK_FREQ
                    or Q.KBCU_timer(2) = CLK_FREQ
                    or Q.KBCU_timer(3) = CLK_FREQ
                    or Q.KBCU_timer(4) = CLK_FREQ
                    or Q.KBCU_timer(5) = CLK_FREQ
                    or Q.KBCU_timer(6) = CLK_FREQ
                    or Q.KBCU_timer(7) = CLK_FREQ
                    else '0';

-- All faults Ok excluding KRRP & KBCU
cav1_ok <= '1' when unsigned(Q.reg(KFLT1)(7 downto 5)) = "111" and Q.reg(KFLT1)(3) = '1' and unsigned(Q.reg(KFLT1)(1 downto 0)) = "11" else '0';
cav2_ok <= '1' when unsigned(Q.reg(KFLT2)(7 downto 5)) = "111" and Q.reg(KFLT2)(3) = '1' and unsigned(Q.reg(KFLT2)(1 downto 0)) = "11" else '0';
cav3_ok <= '1' when unsigned(Q.reg(KFLT3)(7 downto 5)) = "111" and Q.reg(KFLT3)(3) = '1' and unsigned(Q.reg(KFLT3)(1 downto 0)) = "11" else '0';
cav4_ok <= '1' when unsigned(Q.reg(KFLT4)(7 downto 5)) = "111" and Q.reg(KFLT4)(3) = '1' and unsigned(Q.reg(KFLT4)(1 downto 0)) = "11" else '0';
cav5_ok <= '1' when unsigned(Q.reg(KFLT5)(7 downto 5)) = "111" and Q.reg(KFLT5)(3) = '1' and unsigned(Q.reg(KFLT5)(1 downto 0)) = "11" else '0';
cav6_ok <= '1' when unsigned(Q.reg(KFLT6)(7 downto 5)) = "111" and Q.reg(KFLT6)(3) = '1' and unsigned(Q.reg(KFLT6)(1 downto 0)) = "11" else '0';
cav7_ok <= '1' when unsigned(Q.reg(KFLT7)(7 downto 5)) = "111" and Q.reg(KFLT7)(3) = '1' and unsigned(Q.reg(KFLT7)(1 downto 0)) = "11" else '0';
cav8_ok <= '1' when unsigned(Q.reg(KFLT8)(7 downto 5)) = "111" and Q.reg(KFLT8)(3) = '1' and unsigned(Q.reg(KFLT8)(1 downto 0)) = "11" else '0';


-- latch fault status upon HV off (grouped by cavity)
g5: for i in 0 to 7 generate
        g7: for j in 0 to 6 generate
                D.reg(i+KFLTC1)(j) <= not faults(j)(i) when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(i+KFLTC1)(j);
        end generate g7;
        D.reg(i+KFLTC1)(7) <= ( hv_permit(i) or Q.reg(XKBYP)(i) ) when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(i+KFLTC1)(7);
    end generate g5;
-- Klystron PS fault status capture.
D.reg(XKFLTC)(0) <= KFON when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(XKFLTC)(0);
D.reg(XKFLTC)(1) <= KAXS when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(XKFLTC)(1);
D.reg(XKFLTC)(2) <= '0' when (Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0') and (write_edge = '1'and address = XKDOUT and lb_wdata(3) = '0')
                        else '1' when (Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0')
                        else Q.reg(XKFLTC)(2); -- HV off req
D.reg(XKFLTC)(3) <= KEIL when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(XKFLTC)(3);
D.reg(XKFLTC)(4) <= KEOL when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(XKFLTC)(4);
D.reg(XKFLTC)(5) <= KECO when Q.reg(XKDOUT)(3) = '1' and D.reg(XKDOUT)(3) = '0' else Q.reg(XKFLTC)(5);

-- local bus data output
D.rdata_buffer <= Q.reg(address);
lb_rdata <= Q.rdata_buffer;

reg: process(clock,reset_n)
begin
    if (reset_n = '0') then
        Q.reg          <= (others => (others => '0'));
        Q.cnt          <= (others => '0');
        Q.fil_timer    <= (others => '0');
        Q.KERR_cnt     <= (others => '0');
        --Q.fault_buf    <= (others => '0');
        Q.fault_timer   <= (others => '0');
        Q.KRRP_timer   <= (others => (others => '0'));
        Q.KBCU_timer   <= (others => (others => '0'));
        Q.hvon_timer   <= (others => '0');
        Q.rdata_buffer <= (others => '0');
        Q.ioc_counter  <= (others => '0');
        Q.load         <= '0';
        Q.renable      <= '0';
        Q.heart        <= '0';
        Q.fil          <= '0';
        Q.reset        <= '0';
    elsif rising_edge(clock) then
        Q <= D;
    end if;
end process reg;

end rtl;
