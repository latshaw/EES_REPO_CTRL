--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


--Legal Notice: (C)2013 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ARC_FAULT_s1_arbitrator is 
        port (
              -- inputs:
                 signal ARC_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal ARC_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal ARC_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal ARC_FAULT_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_ARC_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_ARC_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_ARC_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_ARC_FAULT_s1 : OUT STD_LOGIC;
                 signal d1_ARC_FAULT_s1_end_xfer : OUT STD_LOGIC
              );
end entity ARC_FAULT_s1_arbitrator;


architecture europa of ARC_FAULT_s1_arbitrator is
                signal ARC_FAULT_s1_allgrants :  STD_LOGIC;
                signal ARC_FAULT_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal ARC_FAULT_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ARC_FAULT_s1_any_continuerequest :  STD_LOGIC;
                signal ARC_FAULT_s1_arb_counter_enable :  STD_LOGIC;
                signal ARC_FAULT_s1_arb_share_counter :  STD_LOGIC;
                signal ARC_FAULT_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal ARC_FAULT_s1_arb_share_set_values :  STD_LOGIC;
                signal ARC_FAULT_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal ARC_FAULT_s1_begins_xfer :  STD_LOGIC;
                signal ARC_FAULT_s1_end_xfer :  STD_LOGIC;
                signal ARC_FAULT_s1_firsttransfer :  STD_LOGIC;
                signal ARC_FAULT_s1_grant_vector :  STD_LOGIC;
                signal ARC_FAULT_s1_in_a_read_cycle :  STD_LOGIC;
                signal ARC_FAULT_s1_in_a_write_cycle :  STD_LOGIC;
                signal ARC_FAULT_s1_master_qreq_vector :  STD_LOGIC;
                signal ARC_FAULT_s1_non_bursting_master_requests :  STD_LOGIC;
                signal ARC_FAULT_s1_reg_firsttransfer :  STD_LOGIC;
                signal ARC_FAULT_s1_slavearbiterlockenable :  STD_LOGIC;
                signal ARC_FAULT_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal ARC_FAULT_s1_unreg_firsttransfer :  STD_LOGIC;
                signal ARC_FAULT_s1_waits_for_read :  STD_LOGIC;
                signal ARC_FAULT_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_ARC_FAULT_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ARC_FAULT_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_ARC_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_ARC_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_ARC_FAULT_s1 :  STD_LOGIC;
                signal shifted_address_to_ARC_FAULT_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_ARC_FAULT_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT ARC_FAULT_s1_end_xfer;
    end if;

  end process;

  ARC_FAULT_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_ARC_FAULT_s1);
  --assign ARC_FAULT_s1_readdata_from_sa = ARC_FAULT_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ARC_FAULT_s1_readdata_from_sa <= ARC_FAULT_s1_readdata;
  internal_cpu_0_data_master_requests_ARC_FAULT_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("1001000001000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --ARC_FAULT_s1_arb_share_counter set values, which is an e_mux
  ARC_FAULT_s1_arb_share_set_values <= std_logic'('1');
  --ARC_FAULT_s1_non_bursting_master_requests mux, which is an e_mux
  ARC_FAULT_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_ARC_FAULT_s1;
  --ARC_FAULT_s1_any_bursting_master_saved_grant mux, which is an e_mux
  ARC_FAULT_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --ARC_FAULT_s1_arb_share_counter_next_value assignment, which is an e_assign
  ARC_FAULT_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ARC_FAULT_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ARC_FAULT_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ARC_FAULT_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ARC_FAULT_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ARC_FAULT_s1_allgrants all slave grants, which is an e_mux
  ARC_FAULT_s1_allgrants <= ARC_FAULT_s1_grant_vector;
  --ARC_FAULT_s1_end_xfer assignment, which is an e_assign
  ARC_FAULT_s1_end_xfer <= NOT ((ARC_FAULT_s1_waits_for_read OR ARC_FAULT_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_ARC_FAULT_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ARC_FAULT_s1 <= ARC_FAULT_s1_end_xfer AND (((NOT ARC_FAULT_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ARC_FAULT_s1_arb_share_counter arbitration counter enable, which is an e_assign
  ARC_FAULT_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ARC_FAULT_s1 AND ARC_FAULT_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_ARC_FAULT_s1 AND NOT ARC_FAULT_s1_non_bursting_master_requests));
  --ARC_FAULT_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ARC_FAULT_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ARC_FAULT_s1_arb_counter_enable) = '1' then 
        ARC_FAULT_s1_arb_share_counter <= ARC_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ARC_FAULT_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ARC_FAULT_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((ARC_FAULT_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_ARC_FAULT_s1)) OR ((end_xfer_arb_share_counter_term_ARC_FAULT_s1 AND NOT ARC_FAULT_s1_non_bursting_master_requests)))) = '1' then 
        ARC_FAULT_s1_slavearbiterlockenable <= ARC_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master ARC_FAULT/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= ARC_FAULT_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --ARC_FAULT_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ARC_FAULT_s1_slavearbiterlockenable2 <= ARC_FAULT_s1_arb_share_counter_next_value;
  --cpu_0/data_master ARC_FAULT/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= ARC_FAULT_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --ARC_FAULT_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  ARC_FAULT_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_ARC_FAULT_s1 <= internal_cpu_0_data_master_requests_ARC_FAULT_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_ARC_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_ARC_FAULT_s1;
  --cpu_0/data_master saved-grant ARC_FAULT/s1, which is an e_assign
  cpu_0_data_master_saved_grant_ARC_FAULT_s1 <= internal_cpu_0_data_master_requests_ARC_FAULT_s1;
  --allow new arb cycle for ARC_FAULT/s1, which is an e_assign
  ARC_FAULT_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  ARC_FAULT_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  ARC_FAULT_s1_master_qreq_vector <= std_logic'('1');
  --ARC_FAULT_s1_reset_n assignment, which is an e_assign
  ARC_FAULT_s1_reset_n <= reset_n;
  --ARC_FAULT_s1_firsttransfer first transaction, which is an e_assign
  ARC_FAULT_s1_firsttransfer <= A_WE_StdLogic((std_logic'(ARC_FAULT_s1_begins_xfer) = '1'), ARC_FAULT_s1_unreg_firsttransfer, ARC_FAULT_s1_reg_firsttransfer);
  --ARC_FAULT_s1_unreg_firsttransfer first transaction, which is an e_assign
  ARC_FAULT_s1_unreg_firsttransfer <= NOT ((ARC_FAULT_s1_slavearbiterlockenable AND ARC_FAULT_s1_any_continuerequest));
  --ARC_FAULT_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ARC_FAULT_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ARC_FAULT_s1_begins_xfer) = '1' then 
        ARC_FAULT_s1_reg_firsttransfer <= ARC_FAULT_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ARC_FAULT_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ARC_FAULT_s1_beginbursttransfer_internal <= ARC_FAULT_s1_begins_xfer;
  shifted_address_to_ARC_FAULT_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --ARC_FAULT_s1_address mux, which is an e_mux
  ARC_FAULT_s1_address <= A_EXT (A_SRL(shifted_address_to_ARC_FAULT_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_ARC_FAULT_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ARC_FAULT_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_ARC_FAULT_s1_end_xfer <= ARC_FAULT_s1_end_xfer;
    end if;

  end process;

  --ARC_FAULT_s1_waits_for_read in a cycle, which is an e_mux
  ARC_FAULT_s1_waits_for_read <= ARC_FAULT_s1_in_a_read_cycle AND ARC_FAULT_s1_begins_xfer;
  --ARC_FAULT_s1_in_a_read_cycle assignment, which is an e_assign
  ARC_FAULT_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_ARC_FAULT_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ARC_FAULT_s1_in_a_read_cycle;
  --ARC_FAULT_s1_waits_for_write in a cycle, which is an e_mux
  ARC_FAULT_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ARC_FAULT_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --ARC_FAULT_s1_in_a_write_cycle assignment, which is an e_assign
  ARC_FAULT_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_ARC_FAULT_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ARC_FAULT_s1_in_a_write_cycle;
  wait_for_ARC_FAULT_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_ARC_FAULT_s1 <= internal_cpu_0_data_master_granted_ARC_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_ARC_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_ARC_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_ARC_FAULT_s1 <= internal_cpu_0_data_master_requests_ARC_FAULT_s1;
--synthesis translate_off
    --ARC_FAULT/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity COLD_WINDOW_FAULT_s1_arbitrator is 
        port (
              -- inputs:
                 signal COLD_WINDOW_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal COLD_WINDOW_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal COLD_WINDOW_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal COLD_WINDOW_FAULT_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal d1_COLD_WINDOW_FAULT_s1_end_xfer : OUT STD_LOGIC
              );
end entity COLD_WINDOW_FAULT_s1_arbitrator;


architecture europa of COLD_WINDOW_FAULT_s1_arbitrator is
                signal COLD_WINDOW_FAULT_s1_allgrants :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_any_continuerequest :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_arb_counter_enable :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_arb_share_counter :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_arb_share_set_values :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_begins_xfer :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_end_xfer :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_firsttransfer :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_grant_vector :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_in_a_read_cycle :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_in_a_write_cycle :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_master_qreq_vector :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_non_bursting_master_requests :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_reg_firsttransfer :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_slavearbiterlockenable :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_unreg_firsttransfer :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_waits_for_read :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal shifted_address_to_COLD_WINDOW_FAULT_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_COLD_WINDOW_FAULT_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT COLD_WINDOW_FAULT_s1_end_xfer;
    end if;

  end process;

  COLD_WINDOW_FAULT_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1);
  --assign COLD_WINDOW_FAULT_s1_readdata_from_sa = COLD_WINDOW_FAULT_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  COLD_WINDOW_FAULT_s1_readdata_from_sa <= COLD_WINDOW_FAULT_s1_readdata;
  internal_cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("1001000001010000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --COLD_WINDOW_FAULT_s1_arb_share_counter set values, which is an e_mux
  COLD_WINDOW_FAULT_s1_arb_share_set_values <= std_logic'('1');
  --COLD_WINDOW_FAULT_s1_non_bursting_master_requests mux, which is an e_mux
  COLD_WINDOW_FAULT_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1;
  --COLD_WINDOW_FAULT_s1_any_bursting_master_saved_grant mux, which is an e_mux
  COLD_WINDOW_FAULT_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --COLD_WINDOW_FAULT_s1_arb_share_counter_next_value assignment, which is an e_assign
  COLD_WINDOW_FAULT_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(COLD_WINDOW_FAULT_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(COLD_WINDOW_FAULT_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(COLD_WINDOW_FAULT_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(COLD_WINDOW_FAULT_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --COLD_WINDOW_FAULT_s1_allgrants all slave grants, which is an e_mux
  COLD_WINDOW_FAULT_s1_allgrants <= COLD_WINDOW_FAULT_s1_grant_vector;
  --COLD_WINDOW_FAULT_s1_end_xfer assignment, which is an e_assign
  COLD_WINDOW_FAULT_s1_end_xfer <= NOT ((COLD_WINDOW_FAULT_s1_waits_for_read OR COLD_WINDOW_FAULT_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1 <= COLD_WINDOW_FAULT_s1_end_xfer AND (((NOT COLD_WINDOW_FAULT_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --COLD_WINDOW_FAULT_s1_arb_share_counter arbitration counter enable, which is an e_assign
  COLD_WINDOW_FAULT_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1 AND COLD_WINDOW_FAULT_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1 AND NOT COLD_WINDOW_FAULT_s1_non_bursting_master_requests));
  --COLD_WINDOW_FAULT_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      COLD_WINDOW_FAULT_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(COLD_WINDOW_FAULT_s1_arb_counter_enable) = '1' then 
        COLD_WINDOW_FAULT_s1_arb_share_counter <= COLD_WINDOW_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --COLD_WINDOW_FAULT_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      COLD_WINDOW_FAULT_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((COLD_WINDOW_FAULT_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1)) OR ((end_xfer_arb_share_counter_term_COLD_WINDOW_FAULT_s1 AND NOT COLD_WINDOW_FAULT_s1_non_bursting_master_requests)))) = '1' then 
        COLD_WINDOW_FAULT_s1_slavearbiterlockenable <= COLD_WINDOW_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master COLD_WINDOW_FAULT/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= COLD_WINDOW_FAULT_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --COLD_WINDOW_FAULT_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  COLD_WINDOW_FAULT_s1_slavearbiterlockenable2 <= COLD_WINDOW_FAULT_s1_arb_share_counter_next_value;
  --cpu_0/data_master COLD_WINDOW_FAULT/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= COLD_WINDOW_FAULT_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --COLD_WINDOW_FAULT_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  COLD_WINDOW_FAULT_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1;
  --cpu_0/data_master saved-grant COLD_WINDOW_FAULT/s1, which is an e_assign
  cpu_0_data_master_saved_grant_COLD_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1;
  --allow new arb cycle for COLD_WINDOW_FAULT/s1, which is an e_assign
  COLD_WINDOW_FAULT_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  COLD_WINDOW_FAULT_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  COLD_WINDOW_FAULT_s1_master_qreq_vector <= std_logic'('1');
  --COLD_WINDOW_FAULT_s1_reset_n assignment, which is an e_assign
  COLD_WINDOW_FAULT_s1_reset_n <= reset_n;
  --COLD_WINDOW_FAULT_s1_firsttransfer first transaction, which is an e_assign
  COLD_WINDOW_FAULT_s1_firsttransfer <= A_WE_StdLogic((std_logic'(COLD_WINDOW_FAULT_s1_begins_xfer) = '1'), COLD_WINDOW_FAULT_s1_unreg_firsttransfer, COLD_WINDOW_FAULT_s1_reg_firsttransfer);
  --COLD_WINDOW_FAULT_s1_unreg_firsttransfer first transaction, which is an e_assign
  COLD_WINDOW_FAULT_s1_unreg_firsttransfer <= NOT ((COLD_WINDOW_FAULT_s1_slavearbiterlockenable AND COLD_WINDOW_FAULT_s1_any_continuerequest));
  --COLD_WINDOW_FAULT_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      COLD_WINDOW_FAULT_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(COLD_WINDOW_FAULT_s1_begins_xfer) = '1' then 
        COLD_WINDOW_FAULT_s1_reg_firsttransfer <= COLD_WINDOW_FAULT_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --COLD_WINDOW_FAULT_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  COLD_WINDOW_FAULT_s1_beginbursttransfer_internal <= COLD_WINDOW_FAULT_s1_begins_xfer;
  shifted_address_to_COLD_WINDOW_FAULT_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --COLD_WINDOW_FAULT_s1_address mux, which is an e_mux
  COLD_WINDOW_FAULT_s1_address <= A_EXT (A_SRL(shifted_address_to_COLD_WINDOW_FAULT_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_COLD_WINDOW_FAULT_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_COLD_WINDOW_FAULT_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_COLD_WINDOW_FAULT_s1_end_xfer <= COLD_WINDOW_FAULT_s1_end_xfer;
    end if;

  end process;

  --COLD_WINDOW_FAULT_s1_waits_for_read in a cycle, which is an e_mux
  COLD_WINDOW_FAULT_s1_waits_for_read <= COLD_WINDOW_FAULT_s1_in_a_read_cycle AND COLD_WINDOW_FAULT_s1_begins_xfer;
  --COLD_WINDOW_FAULT_s1_in_a_read_cycle assignment, which is an e_assign
  COLD_WINDOW_FAULT_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= COLD_WINDOW_FAULT_s1_in_a_read_cycle;
  --COLD_WINDOW_FAULT_s1_waits_for_write in a cycle, which is an e_mux
  COLD_WINDOW_FAULT_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(COLD_WINDOW_FAULT_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --COLD_WINDOW_FAULT_s1_in_a_write_cycle assignment, which is an e_assign
  COLD_WINDOW_FAULT_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= COLD_WINDOW_FAULT_s1_in_a_write_cycle;
  wait_for_COLD_WINDOW_FAULT_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1;
--synthesis translate_off
    --COLD_WINDOW_FAULT/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity FC_FSD_s1_arbitrator is 
        port (
              -- inputs:
                 signal FC_FSD_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal FC_FSD_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal FC_FSD_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal FC_FSD_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_FC_FSD_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_FC_FSD_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_FC_FSD_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_FC_FSD_s1 : OUT STD_LOGIC;
                 signal d1_FC_FSD_s1_end_xfer : OUT STD_LOGIC
              );
end entity FC_FSD_s1_arbitrator;


architecture europa of FC_FSD_s1_arbitrator is
                signal FC_FSD_s1_allgrants :  STD_LOGIC;
                signal FC_FSD_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal FC_FSD_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal FC_FSD_s1_any_continuerequest :  STD_LOGIC;
                signal FC_FSD_s1_arb_counter_enable :  STD_LOGIC;
                signal FC_FSD_s1_arb_share_counter :  STD_LOGIC;
                signal FC_FSD_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal FC_FSD_s1_arb_share_set_values :  STD_LOGIC;
                signal FC_FSD_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal FC_FSD_s1_begins_xfer :  STD_LOGIC;
                signal FC_FSD_s1_end_xfer :  STD_LOGIC;
                signal FC_FSD_s1_firsttransfer :  STD_LOGIC;
                signal FC_FSD_s1_grant_vector :  STD_LOGIC;
                signal FC_FSD_s1_in_a_read_cycle :  STD_LOGIC;
                signal FC_FSD_s1_in_a_write_cycle :  STD_LOGIC;
                signal FC_FSD_s1_master_qreq_vector :  STD_LOGIC;
                signal FC_FSD_s1_non_bursting_master_requests :  STD_LOGIC;
                signal FC_FSD_s1_reg_firsttransfer :  STD_LOGIC;
                signal FC_FSD_s1_slavearbiterlockenable :  STD_LOGIC;
                signal FC_FSD_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal FC_FSD_s1_unreg_firsttransfer :  STD_LOGIC;
                signal FC_FSD_s1_waits_for_read :  STD_LOGIC;
                signal FC_FSD_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_FC_FSD_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_FC_FSD_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_FC_FSD_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_FC_FSD_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_FC_FSD_s1 :  STD_LOGIC;
                signal shifted_address_to_FC_FSD_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_FC_FSD_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT FC_FSD_s1_end_xfer;
    end if;

  end process;

  FC_FSD_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_FC_FSD_s1);
  --assign FC_FSD_s1_readdata_from_sa = FC_FSD_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  FC_FSD_s1_readdata_from_sa <= FC_FSD_s1_readdata;
  internal_cpu_0_data_master_requests_FC_FSD_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("1001000010010000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --FC_FSD_s1_arb_share_counter set values, which is an e_mux
  FC_FSD_s1_arb_share_set_values <= std_logic'('1');
  --FC_FSD_s1_non_bursting_master_requests mux, which is an e_mux
  FC_FSD_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_FC_FSD_s1;
  --FC_FSD_s1_any_bursting_master_saved_grant mux, which is an e_mux
  FC_FSD_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --FC_FSD_s1_arb_share_counter_next_value assignment, which is an e_assign
  FC_FSD_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(FC_FSD_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(FC_FSD_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(FC_FSD_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(FC_FSD_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --FC_FSD_s1_allgrants all slave grants, which is an e_mux
  FC_FSD_s1_allgrants <= FC_FSD_s1_grant_vector;
  --FC_FSD_s1_end_xfer assignment, which is an e_assign
  FC_FSD_s1_end_xfer <= NOT ((FC_FSD_s1_waits_for_read OR FC_FSD_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_FC_FSD_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_FC_FSD_s1 <= FC_FSD_s1_end_xfer AND (((NOT FC_FSD_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --FC_FSD_s1_arb_share_counter arbitration counter enable, which is an e_assign
  FC_FSD_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_FC_FSD_s1 AND FC_FSD_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_FC_FSD_s1 AND NOT FC_FSD_s1_non_bursting_master_requests));
  --FC_FSD_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      FC_FSD_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(FC_FSD_s1_arb_counter_enable) = '1' then 
        FC_FSD_s1_arb_share_counter <= FC_FSD_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --FC_FSD_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      FC_FSD_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((FC_FSD_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_FC_FSD_s1)) OR ((end_xfer_arb_share_counter_term_FC_FSD_s1 AND NOT FC_FSD_s1_non_bursting_master_requests)))) = '1' then 
        FC_FSD_s1_slavearbiterlockenable <= FC_FSD_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master FC_FSD/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= FC_FSD_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --FC_FSD_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  FC_FSD_s1_slavearbiterlockenable2 <= FC_FSD_s1_arb_share_counter_next_value;
  --cpu_0/data_master FC_FSD/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= FC_FSD_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --FC_FSD_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  FC_FSD_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_FC_FSD_s1 <= internal_cpu_0_data_master_requests_FC_FSD_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_FC_FSD_s1 <= internal_cpu_0_data_master_qualified_request_FC_FSD_s1;
  --cpu_0/data_master saved-grant FC_FSD/s1, which is an e_assign
  cpu_0_data_master_saved_grant_FC_FSD_s1 <= internal_cpu_0_data_master_requests_FC_FSD_s1;
  --allow new arb cycle for FC_FSD/s1, which is an e_assign
  FC_FSD_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  FC_FSD_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  FC_FSD_s1_master_qreq_vector <= std_logic'('1');
  --FC_FSD_s1_reset_n assignment, which is an e_assign
  FC_FSD_s1_reset_n <= reset_n;
  --FC_FSD_s1_firsttransfer first transaction, which is an e_assign
  FC_FSD_s1_firsttransfer <= A_WE_StdLogic((std_logic'(FC_FSD_s1_begins_xfer) = '1'), FC_FSD_s1_unreg_firsttransfer, FC_FSD_s1_reg_firsttransfer);
  --FC_FSD_s1_unreg_firsttransfer first transaction, which is an e_assign
  FC_FSD_s1_unreg_firsttransfer <= NOT ((FC_FSD_s1_slavearbiterlockenable AND FC_FSD_s1_any_continuerequest));
  --FC_FSD_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      FC_FSD_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(FC_FSD_s1_begins_xfer) = '1' then 
        FC_FSD_s1_reg_firsttransfer <= FC_FSD_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --FC_FSD_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  FC_FSD_s1_beginbursttransfer_internal <= FC_FSD_s1_begins_xfer;
  shifted_address_to_FC_FSD_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --FC_FSD_s1_address mux, which is an e_mux
  FC_FSD_s1_address <= A_EXT (A_SRL(shifted_address_to_FC_FSD_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_FC_FSD_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_FC_FSD_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_FC_FSD_s1_end_xfer <= FC_FSD_s1_end_xfer;
    end if;

  end process;

  --FC_FSD_s1_waits_for_read in a cycle, which is an e_mux
  FC_FSD_s1_waits_for_read <= FC_FSD_s1_in_a_read_cycle AND FC_FSD_s1_begins_xfer;
  --FC_FSD_s1_in_a_read_cycle assignment, which is an e_assign
  FC_FSD_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_FC_FSD_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= FC_FSD_s1_in_a_read_cycle;
  --FC_FSD_s1_waits_for_write in a cycle, which is an e_mux
  FC_FSD_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(FC_FSD_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --FC_FSD_s1_in_a_write_cycle assignment, which is an e_assign
  FC_FSD_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_FC_FSD_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= FC_FSD_s1_in_a_write_cycle;
  wait_for_FC_FSD_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_FC_FSD_s1 <= internal_cpu_0_data_master_granted_FC_FSD_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_FC_FSD_s1 <= internal_cpu_0_data_master_qualified_request_FC_FSD_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_FC_FSD_s1 <= internal_cpu_0_data_master_requests_FC_FSD_s1;
--synthesis translate_off
    --FC_FSD/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity INTERLOCK_ENABLE_s1_arbitrator is 
        port (
              -- inputs:
                 signal INTERLOCK_ENABLE_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal INTERLOCK_ENABLE_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal INTERLOCK_ENABLE_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal INTERLOCK_ENABLE_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                 signal d1_INTERLOCK_ENABLE_s1_end_xfer : OUT STD_LOGIC
              );
end entity INTERLOCK_ENABLE_s1_arbitrator;


architecture europa of INTERLOCK_ENABLE_s1_arbitrator is
                signal INTERLOCK_ENABLE_s1_allgrants :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_any_continuerequest :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_arb_counter_enable :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_arb_share_counter :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_arb_share_set_values :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_begins_xfer :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_end_xfer :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_firsttransfer :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_grant_vector :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_in_a_read_cycle :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_in_a_write_cycle :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_master_qreq_vector :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_non_bursting_master_requests :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_reg_firsttransfer :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_slavearbiterlockenable :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_unreg_firsttransfer :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_waits_for_read :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal shifted_address_to_INTERLOCK_ENABLE_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_INTERLOCK_ENABLE_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT INTERLOCK_ENABLE_s1_end_xfer;
    end if;

  end process;

  INTERLOCK_ENABLE_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1);
  --assign INTERLOCK_ENABLE_s1_readdata_from_sa = INTERLOCK_ENABLE_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  INTERLOCK_ENABLE_s1_readdata_from_sa <= INTERLOCK_ENABLE_s1_readdata;
  internal_cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("1001000010000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --INTERLOCK_ENABLE_s1_arb_share_counter set values, which is an e_mux
  INTERLOCK_ENABLE_s1_arb_share_set_values <= std_logic'('1');
  --INTERLOCK_ENABLE_s1_non_bursting_master_requests mux, which is an e_mux
  INTERLOCK_ENABLE_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_INTERLOCK_ENABLE_s1;
  --INTERLOCK_ENABLE_s1_any_bursting_master_saved_grant mux, which is an e_mux
  INTERLOCK_ENABLE_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --INTERLOCK_ENABLE_s1_arb_share_counter_next_value assignment, which is an e_assign
  INTERLOCK_ENABLE_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(INTERLOCK_ENABLE_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(INTERLOCK_ENABLE_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(INTERLOCK_ENABLE_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(INTERLOCK_ENABLE_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --INTERLOCK_ENABLE_s1_allgrants all slave grants, which is an e_mux
  INTERLOCK_ENABLE_s1_allgrants <= INTERLOCK_ENABLE_s1_grant_vector;
  --INTERLOCK_ENABLE_s1_end_xfer assignment, which is an e_assign
  INTERLOCK_ENABLE_s1_end_xfer <= NOT ((INTERLOCK_ENABLE_s1_waits_for_read OR INTERLOCK_ENABLE_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1 <= INTERLOCK_ENABLE_s1_end_xfer AND (((NOT INTERLOCK_ENABLE_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --INTERLOCK_ENABLE_s1_arb_share_counter arbitration counter enable, which is an e_assign
  INTERLOCK_ENABLE_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1 AND INTERLOCK_ENABLE_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1 AND NOT INTERLOCK_ENABLE_s1_non_bursting_master_requests));
  --INTERLOCK_ENABLE_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      INTERLOCK_ENABLE_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(INTERLOCK_ENABLE_s1_arb_counter_enable) = '1' then 
        INTERLOCK_ENABLE_s1_arb_share_counter <= INTERLOCK_ENABLE_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --INTERLOCK_ENABLE_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      INTERLOCK_ENABLE_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((INTERLOCK_ENABLE_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1)) OR ((end_xfer_arb_share_counter_term_INTERLOCK_ENABLE_s1 AND NOT INTERLOCK_ENABLE_s1_non_bursting_master_requests)))) = '1' then 
        INTERLOCK_ENABLE_s1_slavearbiterlockenable <= INTERLOCK_ENABLE_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master INTERLOCK_ENABLE/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= INTERLOCK_ENABLE_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --INTERLOCK_ENABLE_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  INTERLOCK_ENABLE_s1_slavearbiterlockenable2 <= INTERLOCK_ENABLE_s1_arb_share_counter_next_value;
  --cpu_0/data_master INTERLOCK_ENABLE/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= INTERLOCK_ENABLE_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --INTERLOCK_ENABLE_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  INTERLOCK_ENABLE_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 <= internal_cpu_0_data_master_requests_INTERLOCK_ENABLE_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 <= internal_cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1;
  --cpu_0/data_master saved-grant INTERLOCK_ENABLE/s1, which is an e_assign
  cpu_0_data_master_saved_grant_INTERLOCK_ENABLE_s1 <= internal_cpu_0_data_master_requests_INTERLOCK_ENABLE_s1;
  --allow new arb cycle for INTERLOCK_ENABLE/s1, which is an e_assign
  INTERLOCK_ENABLE_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  INTERLOCK_ENABLE_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  INTERLOCK_ENABLE_s1_master_qreq_vector <= std_logic'('1');
  --INTERLOCK_ENABLE_s1_reset_n assignment, which is an e_assign
  INTERLOCK_ENABLE_s1_reset_n <= reset_n;
  --INTERLOCK_ENABLE_s1_firsttransfer first transaction, which is an e_assign
  INTERLOCK_ENABLE_s1_firsttransfer <= A_WE_StdLogic((std_logic'(INTERLOCK_ENABLE_s1_begins_xfer) = '1'), INTERLOCK_ENABLE_s1_unreg_firsttransfer, INTERLOCK_ENABLE_s1_reg_firsttransfer);
  --INTERLOCK_ENABLE_s1_unreg_firsttransfer first transaction, which is an e_assign
  INTERLOCK_ENABLE_s1_unreg_firsttransfer <= NOT ((INTERLOCK_ENABLE_s1_slavearbiterlockenable AND INTERLOCK_ENABLE_s1_any_continuerequest));
  --INTERLOCK_ENABLE_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      INTERLOCK_ENABLE_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(INTERLOCK_ENABLE_s1_begins_xfer) = '1' then 
        INTERLOCK_ENABLE_s1_reg_firsttransfer <= INTERLOCK_ENABLE_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --INTERLOCK_ENABLE_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  INTERLOCK_ENABLE_s1_beginbursttransfer_internal <= INTERLOCK_ENABLE_s1_begins_xfer;
  shifted_address_to_INTERLOCK_ENABLE_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --INTERLOCK_ENABLE_s1_address mux, which is an e_mux
  INTERLOCK_ENABLE_s1_address <= A_EXT (A_SRL(shifted_address_to_INTERLOCK_ENABLE_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_INTERLOCK_ENABLE_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_INTERLOCK_ENABLE_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_INTERLOCK_ENABLE_s1_end_xfer <= INTERLOCK_ENABLE_s1_end_xfer;
    end if;

  end process;

  --INTERLOCK_ENABLE_s1_waits_for_read in a cycle, which is an e_mux
  INTERLOCK_ENABLE_s1_waits_for_read <= INTERLOCK_ENABLE_s1_in_a_read_cycle AND INTERLOCK_ENABLE_s1_begins_xfer;
  --INTERLOCK_ENABLE_s1_in_a_read_cycle assignment, which is an e_assign
  INTERLOCK_ENABLE_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= INTERLOCK_ENABLE_s1_in_a_read_cycle;
  --INTERLOCK_ENABLE_s1_waits_for_write in a cycle, which is an e_mux
  INTERLOCK_ENABLE_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(INTERLOCK_ENABLE_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --INTERLOCK_ENABLE_s1_in_a_write_cycle assignment, which is an e_assign
  INTERLOCK_ENABLE_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= INTERLOCK_ENABLE_s1_in_a_write_cycle;
  wait_for_INTERLOCK_ENABLE_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 <= internal_cpu_0_data_master_granted_INTERLOCK_ENABLE_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 <= internal_cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 <= internal_cpu_0_data_master_requests_INTERLOCK_ENABLE_s1;
--synthesis translate_off
    --INTERLOCK_ENABLE/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity WARM_WINDOW_FAULT_s1_arbitrator is 
        port (
              -- inputs:
                 signal WARM_WINDOW_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal WARM_WINDOW_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal WARM_WINDOW_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal WARM_WINDOW_FAULT_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                 signal d1_WARM_WINDOW_FAULT_s1_end_xfer : OUT STD_LOGIC
              );
end entity WARM_WINDOW_FAULT_s1_arbitrator;


architecture europa of WARM_WINDOW_FAULT_s1_arbitrator is
                signal WARM_WINDOW_FAULT_s1_allgrants :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_any_continuerequest :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_arb_counter_enable :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_arb_share_counter :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_arb_share_set_values :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_begins_xfer :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_end_xfer :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_firsttransfer :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_grant_vector :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_in_a_read_cycle :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_in_a_write_cycle :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_master_qreq_vector :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_non_bursting_master_requests :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_reg_firsttransfer :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_slavearbiterlockenable :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_unreg_firsttransfer :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_waits_for_read :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal shifted_address_to_WARM_WINDOW_FAULT_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_WARM_WINDOW_FAULT_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT WARM_WINDOW_FAULT_s1_end_xfer;
    end if;

  end process;

  WARM_WINDOW_FAULT_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1);
  --assign WARM_WINDOW_FAULT_s1_readdata_from_sa = WARM_WINDOW_FAULT_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  WARM_WINDOW_FAULT_s1_readdata_from_sa <= WARM_WINDOW_FAULT_s1_readdata;
  internal_cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("1001000001100000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --WARM_WINDOW_FAULT_s1_arb_share_counter set values, which is an e_mux
  WARM_WINDOW_FAULT_s1_arb_share_set_values <= std_logic'('1');
  --WARM_WINDOW_FAULT_s1_non_bursting_master_requests mux, which is an e_mux
  WARM_WINDOW_FAULT_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1;
  --WARM_WINDOW_FAULT_s1_any_bursting_master_saved_grant mux, which is an e_mux
  WARM_WINDOW_FAULT_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --WARM_WINDOW_FAULT_s1_arb_share_counter_next_value assignment, which is an e_assign
  WARM_WINDOW_FAULT_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(WARM_WINDOW_FAULT_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(WARM_WINDOW_FAULT_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(WARM_WINDOW_FAULT_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(WARM_WINDOW_FAULT_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --WARM_WINDOW_FAULT_s1_allgrants all slave grants, which is an e_mux
  WARM_WINDOW_FAULT_s1_allgrants <= WARM_WINDOW_FAULT_s1_grant_vector;
  --WARM_WINDOW_FAULT_s1_end_xfer assignment, which is an e_assign
  WARM_WINDOW_FAULT_s1_end_xfer <= NOT ((WARM_WINDOW_FAULT_s1_waits_for_read OR WARM_WINDOW_FAULT_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1 <= WARM_WINDOW_FAULT_s1_end_xfer AND (((NOT WARM_WINDOW_FAULT_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --WARM_WINDOW_FAULT_s1_arb_share_counter arbitration counter enable, which is an e_assign
  WARM_WINDOW_FAULT_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1 AND WARM_WINDOW_FAULT_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1 AND NOT WARM_WINDOW_FAULT_s1_non_bursting_master_requests));
  --WARM_WINDOW_FAULT_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      WARM_WINDOW_FAULT_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(WARM_WINDOW_FAULT_s1_arb_counter_enable) = '1' then 
        WARM_WINDOW_FAULT_s1_arb_share_counter <= WARM_WINDOW_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --WARM_WINDOW_FAULT_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      WARM_WINDOW_FAULT_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((WARM_WINDOW_FAULT_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1)) OR ((end_xfer_arb_share_counter_term_WARM_WINDOW_FAULT_s1 AND NOT WARM_WINDOW_FAULT_s1_non_bursting_master_requests)))) = '1' then 
        WARM_WINDOW_FAULT_s1_slavearbiterlockenable <= WARM_WINDOW_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master WARM_WINDOW_FAULT/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= WARM_WINDOW_FAULT_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --WARM_WINDOW_FAULT_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  WARM_WINDOW_FAULT_s1_slavearbiterlockenable2 <= WARM_WINDOW_FAULT_s1_arb_share_counter_next_value;
  --cpu_0/data_master WARM_WINDOW_FAULT/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= WARM_WINDOW_FAULT_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --WARM_WINDOW_FAULT_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  WARM_WINDOW_FAULT_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1;
  --cpu_0/data_master saved-grant WARM_WINDOW_FAULT/s1, which is an e_assign
  cpu_0_data_master_saved_grant_WARM_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1;
  --allow new arb cycle for WARM_WINDOW_FAULT/s1, which is an e_assign
  WARM_WINDOW_FAULT_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  WARM_WINDOW_FAULT_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  WARM_WINDOW_FAULT_s1_master_qreq_vector <= std_logic'('1');
  --WARM_WINDOW_FAULT_s1_reset_n assignment, which is an e_assign
  WARM_WINDOW_FAULT_s1_reset_n <= reset_n;
  --WARM_WINDOW_FAULT_s1_firsttransfer first transaction, which is an e_assign
  WARM_WINDOW_FAULT_s1_firsttransfer <= A_WE_StdLogic((std_logic'(WARM_WINDOW_FAULT_s1_begins_xfer) = '1'), WARM_WINDOW_FAULT_s1_unreg_firsttransfer, WARM_WINDOW_FAULT_s1_reg_firsttransfer);
  --WARM_WINDOW_FAULT_s1_unreg_firsttransfer first transaction, which is an e_assign
  WARM_WINDOW_FAULT_s1_unreg_firsttransfer <= NOT ((WARM_WINDOW_FAULT_s1_slavearbiterlockenable AND WARM_WINDOW_FAULT_s1_any_continuerequest));
  --WARM_WINDOW_FAULT_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      WARM_WINDOW_FAULT_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(WARM_WINDOW_FAULT_s1_begins_xfer) = '1' then 
        WARM_WINDOW_FAULT_s1_reg_firsttransfer <= WARM_WINDOW_FAULT_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --WARM_WINDOW_FAULT_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  WARM_WINDOW_FAULT_s1_beginbursttransfer_internal <= WARM_WINDOW_FAULT_s1_begins_xfer;
  shifted_address_to_WARM_WINDOW_FAULT_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --WARM_WINDOW_FAULT_s1_address mux, which is an e_mux
  WARM_WINDOW_FAULT_s1_address <= A_EXT (A_SRL(shifted_address_to_WARM_WINDOW_FAULT_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_WARM_WINDOW_FAULT_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_WARM_WINDOW_FAULT_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_WARM_WINDOW_FAULT_s1_end_xfer <= WARM_WINDOW_FAULT_s1_end_xfer;
    end if;

  end process;

  --WARM_WINDOW_FAULT_s1_waits_for_read in a cycle, which is an e_mux
  WARM_WINDOW_FAULT_s1_waits_for_read <= WARM_WINDOW_FAULT_s1_in_a_read_cycle AND WARM_WINDOW_FAULT_s1_begins_xfer;
  --WARM_WINDOW_FAULT_s1_in_a_read_cycle assignment, which is an e_assign
  WARM_WINDOW_FAULT_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= WARM_WINDOW_FAULT_s1_in_a_read_cycle;
  --WARM_WINDOW_FAULT_s1_waits_for_write in a cycle, which is an e_mux
  WARM_WINDOW_FAULT_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(WARM_WINDOW_FAULT_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --WARM_WINDOW_FAULT_s1_in_a_write_cycle assignment, which is an e_assign
  WARM_WINDOW_FAULT_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= WARM_WINDOW_FAULT_s1_in_a_write_cycle;
  wait_for_WARM_WINDOW_FAULT_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 <= internal_cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1;
--synthesis translate_off
    --WARM_WINDOW_FAULT/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity WAVEGUIDE_VAC_FAULT_s1_arbitrator is 
        port (
              -- inputs:
                 signal WAVEGUIDE_VAC_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal WAVEGUIDE_VAC_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal WAVEGUIDE_VAC_FAULT_s1_reset_n : OUT STD_LOGIC;
                 signal cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                 signal d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer : OUT STD_LOGIC
              );
end entity WAVEGUIDE_VAC_FAULT_s1_arbitrator;


architecture europa of WAVEGUIDE_VAC_FAULT_s1_arbitrator is
                signal WAVEGUIDE_VAC_FAULT_s1_allgrants :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_any_continuerequest :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_arb_counter_enable :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_arb_share_counter :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_arb_share_set_values :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_begins_xfer :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_end_xfer :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_firsttransfer :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_grant_vector :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_in_a_read_cycle :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_in_a_write_cycle :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_master_qreq_vector :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_non_bursting_master_requests :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_reg_firsttransfer :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_unreg_firsttransfer :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_waits_for_read :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_waits_for_write :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal shifted_address_to_WAVEGUIDE_VAC_FAULT_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_WAVEGUIDE_VAC_FAULT_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT WAVEGUIDE_VAC_FAULT_s1_end_xfer;
    end if;

  end process;

  WAVEGUIDE_VAC_FAULT_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1);
  --assign WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa = WAVEGUIDE_VAC_FAULT_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa <= WAVEGUIDE_VAC_FAULT_s1_readdata;
  internal_cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("1001000001110000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write)))) AND cpu_0_data_master_read;
  --WAVEGUIDE_VAC_FAULT_s1_arb_share_counter set values, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_arb_share_set_values <= std_logic'('1');
  --WAVEGUIDE_VAC_FAULT_s1_non_bursting_master_requests mux, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1;
  --WAVEGUIDE_VAC_FAULT_s1_any_bursting_master_saved_grant mux, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --WAVEGUIDE_VAC_FAULT_s1_arb_share_counter_next_value assignment, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(WAVEGUIDE_VAC_FAULT_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(WAVEGUIDE_VAC_FAULT_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(WAVEGUIDE_VAC_FAULT_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(WAVEGUIDE_VAC_FAULT_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --WAVEGUIDE_VAC_FAULT_s1_allgrants all slave grants, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_allgrants <= WAVEGUIDE_VAC_FAULT_s1_grant_vector;
  --WAVEGUIDE_VAC_FAULT_s1_end_xfer assignment, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_end_xfer <= NOT ((WAVEGUIDE_VAC_FAULT_s1_waits_for_read OR WAVEGUIDE_VAC_FAULT_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1 <= WAVEGUIDE_VAC_FAULT_s1_end_xfer AND (((NOT WAVEGUIDE_VAC_FAULT_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --WAVEGUIDE_VAC_FAULT_s1_arb_share_counter arbitration counter enable, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1 AND WAVEGUIDE_VAC_FAULT_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1 AND NOT WAVEGUIDE_VAC_FAULT_s1_non_bursting_master_requests));
  --WAVEGUIDE_VAC_FAULT_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      WAVEGUIDE_VAC_FAULT_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(WAVEGUIDE_VAC_FAULT_s1_arb_counter_enable) = '1' then 
        WAVEGUIDE_VAC_FAULT_s1_arb_share_counter <= WAVEGUIDE_VAC_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((WAVEGUIDE_VAC_FAULT_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1)) OR ((end_xfer_arb_share_counter_term_WAVEGUIDE_VAC_FAULT_s1 AND NOT WAVEGUIDE_VAC_FAULT_s1_non_bursting_master_requests)))) = '1' then 
        WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable <= WAVEGUIDE_VAC_FAULT_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master WAVEGUIDE_VAC_FAULT/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable2 <= WAVEGUIDE_VAC_FAULT_s1_arb_share_counter_next_value;
  --cpu_0/data_master WAVEGUIDE_VAC_FAULT/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --WAVEGUIDE_VAC_FAULT_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 <= internal_cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1;
  --master is always granted when requested
  internal_cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1;
  --cpu_0/data_master saved-grant WAVEGUIDE_VAC_FAULT/s1, which is an e_assign
  cpu_0_data_master_saved_grant_WAVEGUIDE_VAC_FAULT_s1 <= internal_cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1;
  --allow new arb cycle for WAVEGUIDE_VAC_FAULT/s1, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  WAVEGUIDE_VAC_FAULT_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  WAVEGUIDE_VAC_FAULT_s1_master_qreq_vector <= std_logic'('1');
  --WAVEGUIDE_VAC_FAULT_s1_reset_n assignment, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_reset_n <= reset_n;
  --WAVEGUIDE_VAC_FAULT_s1_firsttransfer first transaction, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_firsttransfer <= A_WE_StdLogic((std_logic'(WAVEGUIDE_VAC_FAULT_s1_begins_xfer) = '1'), WAVEGUIDE_VAC_FAULT_s1_unreg_firsttransfer, WAVEGUIDE_VAC_FAULT_s1_reg_firsttransfer);
  --WAVEGUIDE_VAC_FAULT_s1_unreg_firsttransfer first transaction, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_unreg_firsttransfer <= NOT ((WAVEGUIDE_VAC_FAULT_s1_slavearbiterlockenable AND WAVEGUIDE_VAC_FAULT_s1_any_continuerequest));
  --WAVEGUIDE_VAC_FAULT_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      WAVEGUIDE_VAC_FAULT_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(WAVEGUIDE_VAC_FAULT_s1_begins_xfer) = '1' then 
        WAVEGUIDE_VAC_FAULT_s1_reg_firsttransfer <= WAVEGUIDE_VAC_FAULT_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --WAVEGUIDE_VAC_FAULT_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_beginbursttransfer_internal <= WAVEGUIDE_VAC_FAULT_s1_begins_xfer;
  shifted_address_to_WAVEGUIDE_VAC_FAULT_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --WAVEGUIDE_VAC_FAULT_s1_address mux, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_address <= A_EXT (A_SRL(shifted_address_to_WAVEGUIDE_VAC_FAULT_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer <= WAVEGUIDE_VAC_FAULT_s1_end_xfer;
    end if;

  end process;

  --WAVEGUIDE_VAC_FAULT_s1_waits_for_read in a cycle, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_waits_for_read <= WAVEGUIDE_VAC_FAULT_s1_in_a_read_cycle AND WAVEGUIDE_VAC_FAULT_s1_begins_xfer;
  --WAVEGUIDE_VAC_FAULT_s1_in_a_read_cycle assignment, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= WAVEGUIDE_VAC_FAULT_s1_in_a_read_cycle;
  --WAVEGUIDE_VAC_FAULT_s1_waits_for_write in a cycle, which is an e_mux
  WAVEGUIDE_VAC_FAULT_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(WAVEGUIDE_VAC_FAULT_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --WAVEGUIDE_VAC_FAULT_s1_in_a_write_cycle assignment, which is an e_assign
  WAVEGUIDE_VAC_FAULT_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= WAVEGUIDE_VAC_FAULT_s1_in_a_write_cycle;
  wait_for_WAVEGUIDE_VAC_FAULT_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 <= internal_cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 <= internal_cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 <= internal_cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1;
--synthesis translate_off
    --WAVEGUIDE_VAC_FAULT/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_0_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_debugaccess : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_write : OUT STD_LOGIC;
                 signal cpu_0_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_0_jtag_debug_module_end_xfer : OUT STD_LOGIC
              );
end entity cpu_0_jtag_debug_module_arbitrator;


architecture europa of cpu_0_jtag_debug_module_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_allgrants :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_share_counter :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_share_set_values :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_0_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_cpu_0_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT cpu_0_jtag_debug_module_end_xfer;
    end if;

  end process;

  cpu_0_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module));
  --assign cpu_0_jtag_debug_module_readdata_from_sa = cpu_0_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_0_jtag_debug_module_readdata_from_sa <= cpu_0_jtag_debug_module_readdata;
  internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("1000100000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --cpu_0_jtag_debug_module_arb_share_counter set values, which is an e_mux
  cpu_0_jtag_debug_module_arb_share_set_values <= std_logic'('1');
  --cpu_0_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  cpu_0_jtag_debug_module_non_bursting_master_requests <= ((internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module OR internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module) OR internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module) OR internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  --cpu_0_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  cpu_0_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --cpu_0_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  cpu_0_jtag_debug_module_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(cpu_0_jtag_debug_module_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --cpu_0_jtag_debug_module_allgrants all slave grants, which is an e_mux
  cpu_0_jtag_debug_module_allgrants <= (((or_reduce(cpu_0_jtag_debug_module_grant_vector)) OR (or_reduce(cpu_0_jtag_debug_module_grant_vector))) OR (or_reduce(cpu_0_jtag_debug_module_grant_vector))) OR (or_reduce(cpu_0_jtag_debug_module_grant_vector));
  --cpu_0_jtag_debug_module_end_xfer assignment, which is an e_assign
  cpu_0_jtag_debug_module_end_xfer <= NOT ((cpu_0_jtag_debug_module_waits_for_read OR cpu_0_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_end_xfer AND (((NOT cpu_0_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --cpu_0_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  cpu_0_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module AND cpu_0_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module AND NOT cpu_0_jtag_debug_module_non_bursting_master_requests));
  --cpu_0_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_0_jtag_debug_module_arb_counter_enable) = '1' then 
        cpu_0_jtag_debug_module_arb_share_counter <= cpu_0_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(cpu_0_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_cpu_0_jtag_debug_module AND NOT cpu_0_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        cpu_0_jtag_debug_module_slavearbiterlockenable <= cpu_0_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master cpu_0/jtag_debug_module arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= cpu_0_jtag_debug_module_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --cpu_0_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  cpu_0_jtag_debug_module_slavearbiterlockenable2 <= cpu_0_jtag_debug_module_arb_share_counter_next_value;
  --cpu_0/data_master cpu_0/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= cpu_0_jtag_debug_module_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --cpu_0/instruction_master cpu_0/jtag_debug_module arbiterlock, which is an e_assign
  cpu_0_instruction_master_arbiterlock <= cpu_0_jtag_debug_module_slavearbiterlockenable AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master cpu_0/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_0_instruction_master_arbiterlock2 <= cpu_0_jtag_debug_module_slavearbiterlockenable2 AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master granted cpu_0/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_0_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module))))));
    end if;

  end process;

  --cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  cpu_0_instruction_master_continuerequest <= last_cycle_cpu_0_instruction_master_granted_slave_cpu_0_jtag_debug_module AND internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  --cpu_0_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  cpu_0_jtag_debug_module_any_continuerequest <= cpu_0_instruction_master_continuerequest OR cpu_0_data_master_continuerequest;
  internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module AND NOT (((((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write)) OR cpu_0_instruction_master_arbiterlock));
  --cpu_0_jtag_debug_module_writedata mux, which is an e_mux
  cpu_0_jtag_debug_module_writedata <= cpu_0_data_master_writedata;
  internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_instruction_master_address_to_slave(15 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("1000100000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
  --cpu_0/data_master granted cpu_0/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_0_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module))))));
    end if;

  end process;

  --cpu_0_data_master_continuerequest continued request, which is an e_mux
  cpu_0_data_master_continuerequest <= last_cycle_cpu_0_data_master_granted_slave_cpu_0_jtag_debug_module AND internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module AND NOT (cpu_0_data_master_arbiterlock);
  --allow new arb cycle for cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_jtag_debug_module_allow_new_arb_cycle <= NOT cpu_0_data_master_arbiterlock AND NOT cpu_0_instruction_master_arbiterlock;
  --cpu_0/instruction_master assignment into master qualified-requests vector for cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_jtag_debug_module_master_qreq_vector(0) <= internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  --cpu_0/instruction_master grant cpu_0/jtag_debug_module, which is an e_assign
  internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_grant_vector(0);
  --cpu_0/instruction_master saved-grant cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_arb_winner(0) AND internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
  --cpu_0/data_master assignment into master qualified-requests vector for cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_jtag_debug_module_master_qreq_vector(1) <= internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  --cpu_0/data_master grant cpu_0/jtag_debug_module, which is an e_assign
  internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_grant_vector(1);
  --cpu_0/data_master saved-grant cpu_0/jtag_debug_module, which is an e_assign
  cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module <= cpu_0_jtag_debug_module_arb_winner(1) AND internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  --cpu_0/jtag_debug_module chosen-master double-vector, which is an e_assign
  cpu_0_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((cpu_0_jtag_debug_module_master_qreq_vector & cpu_0_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT cpu_0_jtag_debug_module_master_qreq_vector & NOT cpu_0_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (cpu_0_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  cpu_0_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((cpu_0_jtag_debug_module_allow_new_arb_cycle AND or_reduce(cpu_0_jtag_debug_module_grant_vector)))) = '1'), cpu_0_jtag_debug_module_grant_vector, cpu_0_jtag_debug_module_saved_chosen_master_vector);
  --saved cpu_0_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_0_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        cpu_0_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(cpu_0_jtag_debug_module_grant_vector)) = '1'), cpu_0_jtag_debug_module_grant_vector, cpu_0_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  cpu_0_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((cpu_0_jtag_debug_module_chosen_master_double_vector(1) OR cpu_0_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((cpu_0_jtag_debug_module_chosen_master_double_vector(0) OR cpu_0_jtag_debug_module_chosen_master_double_vector(2)))));
  --cpu_0/jtag_debug_module chosen master rotated left, which is an e_assign
  cpu_0_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(cpu_0_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(cpu_0_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --cpu_0/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(cpu_0_jtag_debug_module_grant_vector)) = '1' then 
        cpu_0_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(cpu_0_jtag_debug_module_end_xfer) = '1'), cpu_0_jtag_debug_module_chosen_master_rot_left, cpu_0_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  cpu_0_jtag_debug_module_begintransfer <= cpu_0_jtag_debug_module_begins_xfer;
  --cpu_0_jtag_debug_module_reset_n assignment, which is an e_assign
  cpu_0_jtag_debug_module_reset_n <= reset_n;
  --assign cpu_0_jtag_debug_module_resetrequest_from_sa = cpu_0_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_0_jtag_debug_module_resetrequest_from_sa <= cpu_0_jtag_debug_module_resetrequest;
  cpu_0_jtag_debug_module_chipselect <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module OR internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  --cpu_0_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  cpu_0_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(cpu_0_jtag_debug_module_begins_xfer) = '1'), cpu_0_jtag_debug_module_unreg_firsttransfer, cpu_0_jtag_debug_module_reg_firsttransfer);
  --cpu_0_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  cpu_0_jtag_debug_module_unreg_firsttransfer <= NOT ((cpu_0_jtag_debug_module_slavearbiterlockenable AND cpu_0_jtag_debug_module_any_continuerequest));
  --cpu_0_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_0_jtag_debug_module_begins_xfer) = '1' then 
        cpu_0_jtag_debug_module_reg_firsttransfer <= cpu_0_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --cpu_0_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  cpu_0_jtag_debug_module_beginbursttransfer_internal <= cpu_0_jtag_debug_module_begins_xfer;
  --cpu_0_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  cpu_0_jtag_debug_module_arbitration_holdoff_internal <= cpu_0_jtag_debug_module_begins_xfer AND cpu_0_jtag_debug_module_firsttransfer;
  --cpu_0_jtag_debug_module_write assignment, which is an e_mux
  cpu_0_jtag_debug_module_write <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_write;
  shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --cpu_0_jtag_debug_module_address mux, which is an e_mux
  cpu_0_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
  shifted_address_to_cpu_0_jtag_debug_module_from_cpu_0_instruction_master <= cpu_0_instruction_master_address_to_slave;
  --d1_cpu_0_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_cpu_0_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_cpu_0_jtag_debug_module_end_xfer <= cpu_0_jtag_debug_module_end_xfer;
    end if;

  end process;

  --cpu_0_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  cpu_0_jtag_debug_module_waits_for_read <= cpu_0_jtag_debug_module_in_a_read_cycle AND cpu_0_jtag_debug_module_begins_xfer;
  --cpu_0_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  cpu_0_jtag_debug_module_in_a_read_cycle <= ((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module AND cpu_0_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= cpu_0_jtag_debug_module_in_a_read_cycle;
  --cpu_0_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  cpu_0_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --cpu_0_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  cpu_0_jtag_debug_module_in_a_write_cycle <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= cpu_0_jtag_debug_module_in_a_write_cycle;
  wait_for_cpu_0_jtag_debug_module_counter <= std_logic'('0');
  --cpu_0_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  cpu_0_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  cpu_0_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_cpu_0_jtag_debug_module <= internal_cpu_0_data_master_requests_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_granted_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_requests_cpu_0_jtag_debug_module <= internal_cpu_0_instruction_master_requests_cpu_0_jtag_debug_module;
--synthesis translate_off
    --cpu_0/jtag_debug_module enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_cpu_0_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_cpu_0_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_cpu_0_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_cpu_0_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_0_data_master_arbitrator is 
        port (
              -- inputs:
                 signal ARC_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal COLD_WINDOW_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal FC_FSD_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal INTERLOCK_ENABLE_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal WARM_WINDOW_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_granted_ARC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_FC_FSD_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_granted_uart_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_ARC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_FC_FSD_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_uart_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_ARC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_FC_FSD_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_uart_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_ARC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_FC_FSD_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_requests_uart_0_s1 : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_ARC_FAULT_s1_end_xfer : IN STD_LOGIC;
                 signal d1_COLD_WINDOW_FAULT_s1_end_xfer : IN STD_LOGIC;
                 signal d1_FC_FSD_s1_end_xfer : IN STD_LOGIC;
                 signal d1_INTERLOCK_ENABLE_s1_end_xfer : IN STD_LOGIC;
                 signal d1_WARM_WINDOW_FAULT_s1_end_xfer : IN STD_LOGIC;
                 signal d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_timer_0_s1_end_xfer : IN STD_LOGIC;
                 signal d1_uart_0_s1_end_xfer : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal timer_0_s1_irq_from_sa : IN STD_LOGIC;
                 signal timer_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_0_s1_irq_from_sa : IN STD_LOGIC;
                 signal uart_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_data_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_0_data_master_arbitrator;


architecture europa of cpu_0_data_master_arbitrator is
                signal cpu_0_data_master_run :  STD_LOGIC;
                signal internal_cpu_0_data_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_cpu_0_data_master_waitrequest :  STD_LOGIC;
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_ARC_FAULT_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_ARC_FAULT_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_FC_FSD_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_FC_FSD_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_requests_cpu_0_jtag_debug_module)))))));
  --cascaded wait assignment, which is an e_assign
  cpu_0_data_master_run <= r_0 AND r_1;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1) OR NOT cpu_0_data_master_requests_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_granted_onchip_memory2_0_s1 OR NOT cpu_0_data_master_qualified_request_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR NOT cpu_0_data_master_read) OR ((registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 AND cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_requests_timer_0_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_timer_0_s1 OR NOT cpu_0_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_uart_0_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_data_master_qualified_request_uart_0_s1 OR NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_read OR cpu_0_data_master_write)))))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_0_data_master_address_to_slave <= cpu_0_data_master_address(15 DOWNTO 0);
  --cpu_0/data_master readdata mux, which is an e_mux
  cpu_0_data_master_readdata <= ((((((((((A_REP(NOT cpu_0_data_master_requests_ARC_FAULT_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (ARC_FAULT_s1_readdata_from_sa)))) AND ((A_REP(NOT cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (COLD_WINDOW_FAULT_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_FC_FSD_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (FC_FSD_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_INTERLOCK_ENABLE_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (INTERLOCK_ENABLE_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (WARM_WINDOW_FAULT_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_cpu_0_jtag_debug_module, 32) OR cpu_0_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_onchip_memory2_0_s1, 32) OR onchip_memory2_0_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_0_data_master_requests_timer_0_s1, 32) OR (std_logic_vector'("0000000000000000") & (timer_0_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_0_data_master_requests_uart_0_s1, 32) OR (std_logic_vector'("0000000000000000") & (uart_0_s1_readdata_from_sa))));
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_0_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      internal_cpu_0_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((cpu_0_data_master_read OR cpu_0_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_data_master_run AND internal_cpu_0_data_master_waitrequest))))))));
    end if;

  end process;

  --irq assign, which is an e_assign
  cpu_0_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(timer_0_s1_irq_from_sa) & A_ToStdLogicVector(uart_0_s1_irq_from_sa));
  --vhdl renameroo for output signals
  cpu_0_data_master_address_to_slave <= internal_cpu_0_data_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_0_data_master_waitrequest <= internal_cpu_0_data_master_waitrequest;

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_0_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_instruction_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                 signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_0_instruction_master_arbitrator;


architecture europa of cpu_0_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_0_instruction_master_address_last_time :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_instruction_master_read_last_time :  STD_LOGIC;
                signal cpu_0_instruction_master_run :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_cpu_0_instruction_master_waitrequest :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_requests_cpu_0_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module OR NOT cpu_0_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_0_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 OR cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1) OR NOT cpu_0_instruction_master_requests_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_0_instruction_master_granted_onchip_memory2_0_s1 OR NOT cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 OR NOT cpu_0_instruction_master_read) OR ((cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 AND cpu_0_instruction_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_0_instruction_master_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_0_instruction_master_address_to_slave <= cpu_0_instruction_master_address(15 DOWNTO 0);
  --cpu_0/instruction_master readdata mux, which is an e_mux
  cpu_0_instruction_master_readdata <= ((A_REP(NOT cpu_0_instruction_master_requests_cpu_0_jtag_debug_module, 32) OR cpu_0_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT cpu_0_instruction_master_requests_onchip_memory2_0_s1, 32) OR onchip_memory2_0_s1_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_cpu_0_instruction_master_waitrequest <= NOT cpu_0_instruction_master_run;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_address_to_slave <= internal_cpu_0_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_waitrequest <= internal_cpu_0_instruction_master_waitrequest;
--synthesis translate_off
    --cpu_0_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_instruction_master_address_last_time <= std_logic_vector'("0000000000000000");
      elsif clk'event and clk = '1' then
        cpu_0_instruction_master_address_last_time <= cpu_0_instruction_master_address;
      end if;

    end process;

    --cpu_0/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        active_and_waiting_last_time <= internal_cpu_0_instruction_master_waitrequest AND (cpu_0_instruction_master_read);
      end if;

    end process;

    --cpu_0_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_0_instruction_master_address /= cpu_0_instruction_master_address_last_time))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("cpu_0_instruction_master_address did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_0_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_0_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        cpu_0_instruction_master_read_last_time <= cpu_0_instruction_master_read;
      end if;

    end process;

    --cpu_0_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_0_instruction_master_read) /= std_logic'(cpu_0_instruction_master_read_last_time)))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("cpu_0_instruction_master_read did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity onchip_memory2_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_instruction_master_read : IN STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                 signal d1_onchip_memory2_0_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                 signal onchip_memory2_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_memory2_0_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_clken : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_memory2_0_s1_reset : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_write : OUT STD_LOGIC;
                 signal onchip_memory2_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC
              );
end entity onchip_memory2_0_s1_arbitrator;


architecture europa of onchip_memory2_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in :  STD_LOGIC;
                signal cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_memory2_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 :  STD_LOGIC;
                signal last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 :  STD_LOGIC;
                signal onchip_memory2_0_s1_allgrants :  STD_LOGIC;
                signal onchip_memory2_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_memory2_0_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_share_counter :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_share_set_values :  STD_LOGIC;
                signal onchip_memory2_0_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal onchip_memory2_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal onchip_memory2_0_s1_begins_xfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory2_0_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_end_xfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal onchip_memory2_0_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal onchip_memory2_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_memory2_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal onchip_memory2_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal onchip_memory2_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal onchip_memory2_0_s1_waits_for_read :  STD_LOGIC;
                signal onchip_memory2_0_s1_waits_for_write :  STD_LOGIC;
                signal p1_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal p1_cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_onchip_memory2_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal shifted_address_to_onchip_memory2_0_s1_from_cpu_0_instruction_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal wait_for_onchip_memory2_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT onchip_memory2_0_s1_end_xfer;
    end if;

  end process;

  onchip_memory2_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1 OR internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1));
  --assign onchip_memory2_0_s1_readdata_from_sa = onchip_memory2_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_memory2_0_s1_readdata_from_sa <= onchip_memory2_0_s1_readdata;
  internal_cpu_0_data_master_requests_onchip_memory2_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 14) & std_logic_vector'("00000000000000")) = std_logic_vector'("0100000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --registered rdv signal_name registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 assignment, which is an e_assign
  registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 <= cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in;
  --onchip_memory2_0_s1_arb_share_counter set values, which is an e_mux
  onchip_memory2_0_s1_arb_share_set_values <= std_logic'('1');
  --onchip_memory2_0_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_memory2_0_s1_non_bursting_master_requests <= ((internal_cpu_0_data_master_requests_onchip_memory2_0_s1 OR internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1) OR internal_cpu_0_data_master_requests_onchip_memory2_0_s1) OR internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_memory2_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_memory2_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_memory2_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --onchip_memory2_0_s1_allgrants all slave grants, which is an e_mux
  onchip_memory2_0_s1_allgrants <= (((or_reduce(onchip_memory2_0_s1_grant_vector)) OR (or_reduce(onchip_memory2_0_s1_grant_vector))) OR (or_reduce(onchip_memory2_0_s1_grant_vector))) OR (or_reduce(onchip_memory2_0_s1_grant_vector));
  --onchip_memory2_0_s1_end_xfer assignment, which is an e_assign
  onchip_memory2_0_s1_end_xfer <= NOT ((onchip_memory2_0_s1_waits_for_read OR onchip_memory2_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_onchip_memory2_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_onchip_memory2_0_s1 <= onchip_memory2_0_s1_end_xfer AND (((NOT onchip_memory2_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --onchip_memory2_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  onchip_memory2_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND onchip_memory2_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND NOT onchip_memory2_0_s1_non_bursting_master_requests));
  --onchip_memory2_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_arb_counter_enable) = '1' then 
        onchip_memory2_0_s1_arb_share_counter <= onchip_memory2_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --onchip_memory2_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(onchip_memory2_0_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_onchip_memory2_0_s1)) OR ((end_xfer_arb_share_counter_term_onchip_memory2_0_s1 AND NOT onchip_memory2_0_s1_non_bursting_master_requests)))) = '1' then 
        onchip_memory2_0_s1_slavearbiterlockenable <= onchip_memory2_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master onchip_memory2_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= onchip_memory2_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --onchip_memory2_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_memory2_0_s1_slavearbiterlockenable2 <= onchip_memory2_0_s1_arb_share_counter_next_value;
  --cpu_0/data_master onchip_memory2_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= onchip_memory2_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --cpu_0/instruction_master onchip_memory2_0/s1 arbiterlock, which is an e_assign
  cpu_0_instruction_master_arbiterlock <= onchip_memory2_0_s1_slavearbiterlockenable AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master onchip_memory2_0/s1 arbiterlock2, which is an e_assign
  cpu_0_instruction_master_arbiterlock2 <= onchip_memory2_0_s1_slavearbiterlockenable2 AND cpu_0_instruction_master_continuerequest;
  --cpu_0/instruction_master granted onchip_memory2_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1))))));
    end if;

  end process;

  --cpu_0_instruction_master_continuerequest continued request, which is an e_mux
  cpu_0_instruction_master_continuerequest <= last_cycle_cpu_0_instruction_master_granted_slave_onchip_memory2_0_s1 AND internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_memory2_0_s1_any_continuerequest <= cpu_0_instruction_master_continuerequest OR cpu_0_data_master_continuerequest;
  internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_data_master_requests_onchip_memory2_0_s1 AND NOT (((((cpu_0_data_master_read AND (cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register))) OR (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write))) OR cpu_0_instruction_master_arbiterlock));
  --cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in <= ((internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_read) AND NOT onchip_memory2_0_s1_waits_for_read) AND NOT (cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register);
  --shift register p1 cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register) & A_ToStdLogicVector(cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register_in)));
  --cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register <= p1_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_0_data_master_read_data_valid_onchip_memory2_0_s1, which is an e_mux
  cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 <= cpu_0_data_master_read_data_valid_onchip_memory2_0_s1_shift_register;
  --onchip_memory2_0_s1_writedata mux, which is an e_mux
  onchip_memory2_0_s1_writedata <= cpu_0_data_master_writedata;
  --mux onchip_memory2_0_s1_clken, which is an e_mux
  onchip_memory2_0_s1_clken <= std_logic'('1');
  internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_0_instruction_master_address_to_slave(15 DOWNTO 14) & std_logic_vector'("00000000000000")) = std_logic_vector'("0100000000000000")))) AND (cpu_0_instruction_master_read))) AND cpu_0_instruction_master_read;
  --cpu_0/data_master granted onchip_memory2_0/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_0_data_master_saved_grant_onchip_memory2_0_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_arbitration_holdoff_internal OR NOT internal_cpu_0_data_master_requests_onchip_memory2_0_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1))))));
    end if;

  end process;

  --cpu_0_data_master_continuerequest continued request, which is an e_mux
  cpu_0_data_master_continuerequest <= last_cycle_cpu_0_data_master_granted_slave_onchip_memory2_0_s1 AND internal_cpu_0_data_master_requests_onchip_memory2_0_s1;
  internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1 AND NOT ((((cpu_0_instruction_master_read AND (cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register))) OR cpu_0_data_master_arbiterlock));
  --cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in <= ((internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 AND cpu_0_instruction_master_read) AND NOT onchip_memory2_0_s1_waits_for_read) AND NOT (cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register);
  --shift register p1 cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register) & A_ToStdLogicVector(cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register_in)));
  --cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register <= p1_cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register;
    end if;

  end process;

  --local readdatavalid cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1, which is an e_mux
  cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 <= cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1_shift_register;
  --allow new arb cycle for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_allow_new_arb_cycle <= NOT cpu_0_data_master_arbiterlock AND NOT cpu_0_instruction_master_arbiterlock;
  --cpu_0/instruction_master assignment into master qualified-requests vector for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_master_qreq_vector(0) <= internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1;
  --cpu_0/instruction_master grant onchip_memory2_0/s1, which is an e_assign
  internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 <= onchip_memory2_0_s1_grant_vector(0);
  --cpu_0/instruction_master saved-grant onchip_memory2_0/s1, which is an e_assign
  cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1 <= onchip_memory2_0_s1_arb_winner(0) AND internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
  --cpu_0/data_master assignment into master qualified-requests vector for onchip_memory2_0/s1, which is an e_assign
  onchip_memory2_0_s1_master_qreq_vector(1) <= internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1;
  --cpu_0/data_master grant onchip_memory2_0/s1, which is an e_assign
  internal_cpu_0_data_master_granted_onchip_memory2_0_s1 <= onchip_memory2_0_s1_grant_vector(1);
  --cpu_0/data_master saved-grant onchip_memory2_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_onchip_memory2_0_s1 <= onchip_memory2_0_s1_arb_winner(1) AND internal_cpu_0_data_master_requests_onchip_memory2_0_s1;
  --onchip_memory2_0/s1 chosen-master double-vector, which is an e_assign
  onchip_memory2_0_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((onchip_memory2_0_s1_master_qreq_vector & onchip_memory2_0_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT onchip_memory2_0_s1_master_qreq_vector & NOT onchip_memory2_0_s1_master_qreq_vector))) + (std_logic_vector'("000") & (onchip_memory2_0_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  onchip_memory2_0_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((onchip_memory2_0_s1_allow_new_arb_cycle AND or_reduce(onchip_memory2_0_s1_grant_vector)))) = '1'), onchip_memory2_0_s1_grant_vector, onchip_memory2_0_s1_saved_chosen_master_vector);
  --saved onchip_memory2_0_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_allow_new_arb_cycle) = '1' then 
        onchip_memory2_0_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(onchip_memory2_0_s1_grant_vector)) = '1'), onchip_memory2_0_s1_grant_vector, onchip_memory2_0_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  onchip_memory2_0_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((onchip_memory2_0_s1_chosen_master_double_vector(1) OR onchip_memory2_0_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((onchip_memory2_0_s1_chosen_master_double_vector(0) OR onchip_memory2_0_s1_chosen_master_double_vector(2)))));
  --onchip_memory2_0/s1 chosen master rotated left, which is an e_assign
  onchip_memory2_0_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(onchip_memory2_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(onchip_memory2_0_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --onchip_memory2_0/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(onchip_memory2_0_s1_grant_vector)) = '1' then 
        onchip_memory2_0_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(onchip_memory2_0_s1_end_xfer) = '1'), onchip_memory2_0_s1_chosen_master_rot_left, onchip_memory2_0_s1_grant_vector);
      end if;
    end if;

  end process;

  --~onchip_memory2_0_s1_reset assignment, which is an e_assign
  onchip_memory2_0_s1_reset <= NOT reset_n;
  onchip_memory2_0_s1_chipselect <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1 OR internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1;
  --onchip_memory2_0_s1_firsttransfer first transaction, which is an e_assign
  onchip_memory2_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(onchip_memory2_0_s1_begins_xfer) = '1'), onchip_memory2_0_s1_unreg_firsttransfer, onchip_memory2_0_s1_reg_firsttransfer);
  --onchip_memory2_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  onchip_memory2_0_s1_unreg_firsttransfer <= NOT ((onchip_memory2_0_s1_slavearbiterlockenable AND onchip_memory2_0_s1_any_continuerequest));
  --onchip_memory2_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_memory2_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_memory2_0_s1_begins_xfer) = '1' then 
        onchip_memory2_0_s1_reg_firsttransfer <= onchip_memory2_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --onchip_memory2_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  onchip_memory2_0_s1_beginbursttransfer_internal <= onchip_memory2_0_s1_begins_xfer;
  --onchip_memory2_0_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  onchip_memory2_0_s1_arbitration_holdoff_internal <= onchip_memory2_0_s1_begins_xfer AND onchip_memory2_0_s1_firsttransfer;
  --onchip_memory2_0_s1_write assignment, which is an e_mux
  onchip_memory2_0_s1_write <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_write;
  shifted_address_to_onchip_memory2_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --onchip_memory2_0_s1_address mux, which is an e_mux
  onchip_memory2_0_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_onchip_memory2_0_s1)) = '1'), (A_SRL(shifted_address_to_onchip_memory2_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_onchip_memory2_0_s1_from_cpu_0_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 12);
  shifted_address_to_onchip_memory2_0_s1_from_cpu_0_instruction_master <= cpu_0_instruction_master_address_to_slave;
  --d1_onchip_memory2_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_onchip_memory2_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_onchip_memory2_0_s1_end_xfer <= onchip_memory2_0_s1_end_xfer;
    end if;

  end process;

  --onchip_memory2_0_s1_waits_for_read in a cycle, which is an e_mux
  onchip_memory2_0_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory2_0_s1_in_a_read_cycle assignment, which is an e_assign
  onchip_memory2_0_s1_in_a_read_cycle <= ((internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_read)) OR ((internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1 AND cpu_0_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_memory2_0_s1_in_a_read_cycle;
  --onchip_memory2_0_s1_waits_for_write in a cycle, which is an e_mux
  onchip_memory2_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_memory2_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_memory2_0_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_memory2_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_memory2_0_s1_in_a_write_cycle;
  wait_for_onchip_memory2_0_s1_counter <= std_logic'('0');
  --onchip_memory2_0_s1_byteenable byte enable port mux, which is an e_mux
  onchip_memory2_0_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_0_data_master_granted_onchip_memory2_0_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_0_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_onchip_memory2_0_s1 <= internal_cpu_0_data_master_granted_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_data_master_qualified_request_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_onchip_memory2_0_s1 <= internal_cpu_0_data_master_requests_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_granted_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1;
  --vhdl renameroo for output signals
  cpu_0_instruction_master_requests_onchip_memory2_0_s1 <= internal_cpu_0_instruction_master_requests_onchip_memory2_0_s1;
--synthesis translate_off
    --onchip_memory2_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_data_master_granted_onchip_memory2_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_0_instruction_master_granted_onchip_memory2_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_data_master_saved_grant_onchip_memory2_0_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_0_instruction_master_saved_grant_onchip_memory2_0_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity timer_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal timer_0_s1_irq : IN STD_LOGIC;
                 signal timer_0_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_0_data_master_granted_timer_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_timer_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_timer_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_timer_0_s1 : OUT STD_LOGIC;
                 signal d1_timer_0_s1_end_xfer : OUT STD_LOGIC;
                 signal timer_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal timer_0_s1_chipselect : OUT STD_LOGIC;
                 signal timer_0_s1_irq_from_sa : OUT STD_LOGIC;
                 signal timer_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal timer_0_s1_reset_n : OUT STD_LOGIC;
                 signal timer_0_s1_write_n : OUT STD_LOGIC;
                 signal timer_0_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity timer_0_s1_arbitrator;


architecture europa of timer_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_timer_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_timer_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_timer_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_timer_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_timer_0_s1 :  STD_LOGIC;
                signal shifted_address_to_timer_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_allgrants :  STD_LOGIC;
                signal timer_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal timer_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal timer_0_s1_any_continuerequest :  STD_LOGIC;
                signal timer_0_s1_arb_counter_enable :  STD_LOGIC;
                signal timer_0_s1_arb_share_counter :  STD_LOGIC;
                signal timer_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal timer_0_s1_arb_share_set_values :  STD_LOGIC;
                signal timer_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal timer_0_s1_begins_xfer :  STD_LOGIC;
                signal timer_0_s1_end_xfer :  STD_LOGIC;
                signal timer_0_s1_firsttransfer :  STD_LOGIC;
                signal timer_0_s1_grant_vector :  STD_LOGIC;
                signal timer_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal timer_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal timer_0_s1_master_qreq_vector :  STD_LOGIC;
                signal timer_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal timer_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal timer_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal timer_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal timer_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal timer_0_s1_waits_for_read :  STD_LOGIC;
                signal timer_0_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_timer_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT timer_0_s1_end_xfer;
    end if;

  end process;

  timer_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_timer_0_s1);
  --assign timer_0_s1_readdata_from_sa = timer_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_0_s1_readdata_from_sa <= timer_0_s1_readdata;
  internal_cpu_0_data_master_requests_timer_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("1001000000100000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --timer_0_s1_arb_share_counter set values, which is an e_mux
  timer_0_s1_arb_share_set_values <= std_logic'('1');
  --timer_0_s1_non_bursting_master_requests mux, which is an e_mux
  timer_0_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_timer_0_s1;
  --timer_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  timer_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --timer_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  timer_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(timer_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(timer_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --timer_0_s1_allgrants all slave grants, which is an e_mux
  timer_0_s1_allgrants <= timer_0_s1_grant_vector;
  --timer_0_s1_end_xfer assignment, which is an e_assign
  timer_0_s1_end_xfer <= NOT ((timer_0_s1_waits_for_read OR timer_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_timer_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_timer_0_s1 <= timer_0_s1_end_xfer AND (((NOT timer_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --timer_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  timer_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_timer_0_s1 AND timer_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_timer_0_s1 AND NOT timer_0_s1_non_bursting_master_requests));
  --timer_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_0_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_0_s1_arb_counter_enable) = '1' then 
        timer_0_s1_arb_share_counter <= timer_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --timer_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((timer_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_timer_0_s1)) OR ((end_xfer_arb_share_counter_term_timer_0_s1 AND NOT timer_0_s1_non_bursting_master_requests)))) = '1' then 
        timer_0_s1_slavearbiterlockenable <= timer_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master timer_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= timer_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --timer_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  timer_0_s1_slavearbiterlockenable2 <= timer_0_s1_arb_share_counter_next_value;
  --cpu_0/data_master timer_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= timer_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --timer_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  timer_0_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1 AND NOT (((NOT cpu_0_data_master_waitrequest) AND cpu_0_data_master_write));
  --timer_0_s1_writedata mux, which is an e_mux
  timer_0_s1_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_timer_0_s1 <= internal_cpu_0_data_master_qualified_request_timer_0_s1;
  --cpu_0/data_master saved-grant timer_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1;
  --allow new arb cycle for timer_0/s1, which is an e_assign
  timer_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  timer_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  timer_0_s1_master_qreq_vector <= std_logic'('1');
  --timer_0_s1_reset_n assignment, which is an e_assign
  timer_0_s1_reset_n <= reset_n;
  timer_0_s1_chipselect <= internal_cpu_0_data_master_granted_timer_0_s1;
  --timer_0_s1_firsttransfer first transaction, which is an e_assign
  timer_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(timer_0_s1_begins_xfer) = '1'), timer_0_s1_unreg_firsttransfer, timer_0_s1_reg_firsttransfer);
  --timer_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  timer_0_s1_unreg_firsttransfer <= NOT ((timer_0_s1_slavearbiterlockenable AND timer_0_s1_any_continuerequest));
  --timer_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      timer_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(timer_0_s1_begins_xfer) = '1' then 
        timer_0_s1_reg_firsttransfer <= timer_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --timer_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  timer_0_s1_beginbursttransfer_internal <= timer_0_s1_begins_xfer;
  --~timer_0_s1_write_n assignment, which is an e_mux
  timer_0_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_write));
  shifted_address_to_timer_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --timer_0_s1_address mux, which is an e_mux
  timer_0_s1_address <= A_EXT (A_SRL(shifted_address_to_timer_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_timer_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_timer_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_timer_0_s1_end_xfer <= timer_0_s1_end_xfer;
    end if;

  end process;

  --timer_0_s1_waits_for_read in a cycle, which is an e_mux
  timer_0_s1_waits_for_read <= timer_0_s1_in_a_read_cycle AND timer_0_s1_begins_xfer;
  --timer_0_s1_in_a_read_cycle assignment, which is an e_assign
  timer_0_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= timer_0_s1_in_a_read_cycle;
  --timer_0_s1_waits_for_write in a cycle, which is an e_mux
  timer_0_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(timer_0_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --timer_0_s1_in_a_write_cycle assignment, which is an e_assign
  timer_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_timer_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= timer_0_s1_in_a_write_cycle;
  wait_for_timer_0_s1_counter <= std_logic'('0');
  --assign timer_0_s1_irq_from_sa = timer_0_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  timer_0_s1_irq_from_sa <= timer_0_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_timer_0_s1 <= internal_cpu_0_data_master_granted_timer_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_timer_0_s1 <= internal_cpu_0_data_master_qualified_request_timer_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_timer_0_s1 <= internal_cpu_0_data_master_requests_timer_0_s1;
--synthesis translate_off
    --timer_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity uart_0_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_0_data_master_read : IN STD_LOGIC;
                 signal cpu_0_data_master_write : IN STD_LOGIC;
                 signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal uart_0_s1_dataavailable : IN STD_LOGIC;
                 signal uart_0_s1_irq : IN STD_LOGIC;
                 signal uart_0_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_0_s1_readyfordata : IN STD_LOGIC;

              -- outputs:
                 signal cpu_0_data_master_granted_uart_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_qualified_request_uart_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_read_data_valid_uart_0_s1 : OUT STD_LOGIC;
                 signal cpu_0_data_master_requests_uart_0_s1 : OUT STD_LOGIC;
                 signal d1_uart_0_s1_end_xfer : OUT STD_LOGIC;
                 signal uart_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal uart_0_s1_begintransfer : OUT STD_LOGIC;
                 signal uart_0_s1_chipselect : OUT STD_LOGIC;
                 signal uart_0_s1_dataavailable_from_sa : OUT STD_LOGIC;
                 signal uart_0_s1_irq_from_sa : OUT STD_LOGIC;
                 signal uart_0_s1_read_n : OUT STD_LOGIC;
                 signal uart_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal uart_0_s1_readyfordata_from_sa : OUT STD_LOGIC;
                 signal uart_0_s1_reset_n : OUT STD_LOGIC;
                 signal uart_0_s1_write_n : OUT STD_LOGIC;
                 signal uart_0_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity uart_0_s1_arbitrator;


architecture europa of uart_0_s1_arbitrator is
                signal cpu_0_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_0_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_0_data_master_continuerequest :  STD_LOGIC;
                signal cpu_0_data_master_saved_grant_uart_0_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_uart_0_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_0_data_master_granted_uart_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_qualified_request_uart_0_s1 :  STD_LOGIC;
                signal internal_cpu_0_data_master_requests_uart_0_s1 :  STD_LOGIC;
                signal shifted_address_to_uart_0_s1_from_cpu_0_data_master :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_0_s1_allgrants :  STD_LOGIC;
                signal uart_0_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal uart_0_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal uart_0_s1_any_continuerequest :  STD_LOGIC;
                signal uart_0_s1_arb_counter_enable :  STD_LOGIC;
                signal uart_0_s1_arb_share_counter :  STD_LOGIC;
                signal uart_0_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal uart_0_s1_arb_share_set_values :  STD_LOGIC;
                signal uart_0_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal uart_0_s1_begins_xfer :  STD_LOGIC;
                signal uart_0_s1_end_xfer :  STD_LOGIC;
                signal uart_0_s1_firsttransfer :  STD_LOGIC;
                signal uart_0_s1_grant_vector :  STD_LOGIC;
                signal uart_0_s1_in_a_read_cycle :  STD_LOGIC;
                signal uart_0_s1_in_a_write_cycle :  STD_LOGIC;
                signal uart_0_s1_master_qreq_vector :  STD_LOGIC;
                signal uart_0_s1_non_bursting_master_requests :  STD_LOGIC;
                signal uart_0_s1_reg_firsttransfer :  STD_LOGIC;
                signal uart_0_s1_slavearbiterlockenable :  STD_LOGIC;
                signal uart_0_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal uart_0_s1_unreg_firsttransfer :  STD_LOGIC;
                signal uart_0_s1_waits_for_read :  STD_LOGIC;
                signal uart_0_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_uart_0_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      d1_reasons_to_wait <= NOT uart_0_s1_end_xfer;
    end if;

  end process;

  uart_0_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_0_data_master_qualified_request_uart_0_s1);
  --assign uart_0_s1_readdata_from_sa = uart_0_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_0_s1_readdata_from_sa <= uart_0_s1_readdata;
  internal_cpu_0_data_master_requests_uart_0_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_0_data_master_address_to_slave(15 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("1001000000000000")))) AND ((cpu_0_data_master_read OR cpu_0_data_master_write));
  --assign uart_0_s1_dataavailable_from_sa = uart_0_s1_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_0_s1_dataavailable_from_sa <= uart_0_s1_dataavailable;
  --assign uart_0_s1_readyfordata_from_sa = uart_0_s1_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_0_s1_readyfordata_from_sa <= uart_0_s1_readyfordata;
  --uart_0_s1_arb_share_counter set values, which is an e_mux
  uart_0_s1_arb_share_set_values <= std_logic'('1');
  --uart_0_s1_non_bursting_master_requests mux, which is an e_mux
  uart_0_s1_non_bursting_master_requests <= internal_cpu_0_data_master_requests_uart_0_s1;
  --uart_0_s1_any_bursting_master_saved_grant mux, which is an e_mux
  uart_0_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --uart_0_s1_arb_share_counter_next_value assignment, which is an e_assign
  uart_0_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(uart_0_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(uart_0_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(uart_0_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(uart_0_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --uart_0_s1_allgrants all slave grants, which is an e_mux
  uart_0_s1_allgrants <= uart_0_s1_grant_vector;
  --uart_0_s1_end_xfer assignment, which is an e_assign
  uart_0_s1_end_xfer <= NOT ((uart_0_s1_waits_for_read OR uart_0_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_uart_0_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_uart_0_s1 <= uart_0_s1_end_xfer AND (((NOT uart_0_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --uart_0_s1_arb_share_counter arbitration counter enable, which is an e_assign
  uart_0_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_uart_0_s1 AND uart_0_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_uart_0_s1 AND NOT uart_0_s1_non_bursting_master_requests));
  --uart_0_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_0_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(uart_0_s1_arb_counter_enable) = '1' then 
        uart_0_s1_arb_share_counter <= uart_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --uart_0_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_0_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((uart_0_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_uart_0_s1)) OR ((end_xfer_arb_share_counter_term_uart_0_s1 AND NOT uart_0_s1_non_bursting_master_requests)))) = '1' then 
        uart_0_s1_slavearbiterlockenable <= uart_0_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_0/data_master uart_0/s1 arbiterlock, which is an e_assign
  cpu_0_data_master_arbiterlock <= uart_0_s1_slavearbiterlockenable AND cpu_0_data_master_continuerequest;
  --uart_0_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  uart_0_s1_slavearbiterlockenable2 <= uart_0_s1_arb_share_counter_next_value;
  --cpu_0/data_master uart_0/s1 arbiterlock2, which is an e_assign
  cpu_0_data_master_arbiterlock2 <= uart_0_s1_slavearbiterlockenable2 AND cpu_0_data_master_continuerequest;
  --uart_0_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  uart_0_s1_any_continuerequest <= std_logic'('1');
  --cpu_0_data_master_continuerequest continued request, which is an e_assign
  cpu_0_data_master_continuerequest <= std_logic'('1');
  internal_cpu_0_data_master_qualified_request_uart_0_s1 <= internal_cpu_0_data_master_requests_uart_0_s1;
  --uart_0_s1_writedata mux, which is an e_mux
  uart_0_s1_writedata <= cpu_0_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_0_data_master_granted_uart_0_s1 <= internal_cpu_0_data_master_qualified_request_uart_0_s1;
  --cpu_0/data_master saved-grant uart_0/s1, which is an e_assign
  cpu_0_data_master_saved_grant_uart_0_s1 <= internal_cpu_0_data_master_requests_uart_0_s1;
  --allow new arb cycle for uart_0/s1, which is an e_assign
  uart_0_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  uart_0_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  uart_0_s1_master_qreq_vector <= std_logic'('1');
  uart_0_s1_begintransfer <= uart_0_s1_begins_xfer;
  --uart_0_s1_reset_n assignment, which is an e_assign
  uart_0_s1_reset_n <= reset_n;
  uart_0_s1_chipselect <= internal_cpu_0_data_master_granted_uart_0_s1;
  --uart_0_s1_firsttransfer first transaction, which is an e_assign
  uart_0_s1_firsttransfer <= A_WE_StdLogic((std_logic'(uart_0_s1_begins_xfer) = '1'), uart_0_s1_unreg_firsttransfer, uart_0_s1_reg_firsttransfer);
  --uart_0_s1_unreg_firsttransfer first transaction, which is an e_assign
  uart_0_s1_unreg_firsttransfer <= NOT ((uart_0_s1_slavearbiterlockenable AND uart_0_s1_any_continuerequest));
  --uart_0_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      uart_0_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(uart_0_s1_begins_xfer) = '1' then 
        uart_0_s1_reg_firsttransfer <= uart_0_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --uart_0_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  uart_0_s1_beginbursttransfer_internal <= uart_0_s1_begins_xfer;
  --~uart_0_s1_read_n assignment, which is an e_mux
  uart_0_s1_read_n <= NOT ((internal_cpu_0_data_master_granted_uart_0_s1 AND cpu_0_data_master_read));
  --~uart_0_s1_write_n assignment, which is an e_mux
  uart_0_s1_write_n <= NOT ((internal_cpu_0_data_master_granted_uart_0_s1 AND cpu_0_data_master_write));
  shifted_address_to_uart_0_s1_from_cpu_0_data_master <= cpu_0_data_master_address_to_slave;
  --uart_0_s1_address mux, which is an e_mux
  uart_0_s1_address <= A_EXT (A_SRL(shifted_address_to_uart_0_s1_from_cpu_0_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_uart_0_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_uart_0_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      d1_uart_0_s1_end_xfer <= uart_0_s1_end_xfer;
    end if;

  end process;

  --uart_0_s1_waits_for_read in a cycle, which is an e_mux
  uart_0_s1_waits_for_read <= uart_0_s1_in_a_read_cycle AND uart_0_s1_begins_xfer;
  --uart_0_s1_in_a_read_cycle assignment, which is an e_assign
  uart_0_s1_in_a_read_cycle <= internal_cpu_0_data_master_granted_uart_0_s1 AND cpu_0_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= uart_0_s1_in_a_read_cycle;
  --uart_0_s1_waits_for_write in a cycle, which is an e_mux
  uart_0_s1_waits_for_write <= uart_0_s1_in_a_write_cycle AND uart_0_s1_begins_xfer;
  --uart_0_s1_in_a_write_cycle assignment, which is an e_assign
  uart_0_s1_in_a_write_cycle <= internal_cpu_0_data_master_granted_uart_0_s1 AND cpu_0_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= uart_0_s1_in_a_write_cycle;
  wait_for_uart_0_s1_counter <= std_logic'('0');
  --assign uart_0_s1_irq_from_sa = uart_0_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  uart_0_s1_irq_from_sa <= uart_0_s1_irq;
  --vhdl renameroo for output signals
  cpu_0_data_master_granted_uart_0_s1 <= internal_cpu_0_data_master_granted_uart_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_qualified_request_uart_0_s1 <= internal_cpu_0_data_master_qualified_request_uart_0_s1;
  --vhdl renameroo for output signals
  cpu_0_data_master_requests_uart_0_s1 <= internal_cpu_0_data_master_requests_uart_0_s1;
--synthesis translate_off
    --uart_0/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        enable_nonzero_assertions <= std_logic'('1');
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Interlock_LCD_reset_clk_0_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity Interlock_LCD_reset_clk_0_domain_synch_module;


architecture europa of Interlock_LCD_reset_clk_0_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_in_d1 <= data_in;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      data_out <= data_in_d1;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Interlock_LCD is 
        port (
              -- 1) global signals:
                 signal clk_0 : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_ARC_FAULT
                 signal in_port_to_the_ARC_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_COLD_WINDOW_FAULT
                 signal in_port_to_the_COLD_WINDOW_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_FC_FSD
                 signal in_port_to_the_FC_FSD : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_INTERLOCK_ENABLE
                 signal in_port_to_the_INTERLOCK_ENABLE : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_WARM_WINDOW_FAULT
                 signal in_port_to_the_WARM_WINDOW_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_WAVEGUIDE_VAC_FAULT
                 signal in_port_to_the_WAVEGUIDE_VAC_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_uart_0
                 signal rxd_to_the_uart_0 : IN STD_LOGIC;
                 signal txd_from_the_uart_0 : OUT STD_LOGIC
              );
end entity Interlock_LCD;


architecture europa of Interlock_LCD is
component ARC_FAULT_s1_arbitrator is 
           port (
                 -- inputs:
                    signal ARC_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal ARC_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal ARC_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal ARC_FAULT_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_ARC_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_ARC_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_ARC_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_ARC_FAULT_s1 : OUT STD_LOGIC;
                    signal d1_ARC_FAULT_s1_end_xfer : OUT STD_LOGIC
                 );
end component ARC_FAULT_s1_arbitrator;

component ARC_FAULT is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component ARC_FAULT;

component COLD_WINDOW_FAULT_s1_arbitrator is 
           port (
                 -- inputs:
                    signal COLD_WINDOW_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal COLD_WINDOW_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal COLD_WINDOW_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal COLD_WINDOW_FAULT_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal d1_COLD_WINDOW_FAULT_s1_end_xfer : OUT STD_LOGIC
                 );
end component COLD_WINDOW_FAULT_s1_arbitrator;

component COLD_WINDOW_FAULT is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component COLD_WINDOW_FAULT;

component FC_FSD_s1_arbitrator is 
           port (
                 -- inputs:
                    signal FC_FSD_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal FC_FSD_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal FC_FSD_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal FC_FSD_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_FC_FSD_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_FC_FSD_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_FC_FSD_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_FC_FSD_s1 : OUT STD_LOGIC;
                    signal d1_FC_FSD_s1_end_xfer : OUT STD_LOGIC
                 );
end component FC_FSD_s1_arbitrator;

component FC_FSD is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component FC_FSD;

component INTERLOCK_ENABLE_s1_arbitrator is 
           port (
                 -- inputs:
                    signal INTERLOCK_ENABLE_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal INTERLOCK_ENABLE_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal INTERLOCK_ENABLE_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal INTERLOCK_ENABLE_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 : OUT STD_LOGIC;
                    signal d1_INTERLOCK_ENABLE_s1_end_xfer : OUT STD_LOGIC
                 );
end component INTERLOCK_ENABLE_s1_arbitrator;

component INTERLOCK_ENABLE is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component INTERLOCK_ENABLE;

component WARM_WINDOW_FAULT_s1_arbitrator is 
           port (
                 -- inputs:
                    signal WARM_WINDOW_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal WARM_WINDOW_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal WARM_WINDOW_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal WARM_WINDOW_FAULT_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 : OUT STD_LOGIC;
                    signal d1_WARM_WINDOW_FAULT_s1_end_xfer : OUT STD_LOGIC
                 );
end component WARM_WINDOW_FAULT_s1_arbitrator;

component WARM_WINDOW_FAULT is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component WARM_WINDOW_FAULT;

component WAVEGUIDE_VAC_FAULT_s1_arbitrator is 
           port (
                 -- inputs:
                    signal WAVEGUIDE_VAC_FAULT_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal WAVEGUIDE_VAC_FAULT_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal WAVEGUIDE_VAC_FAULT_s1_reset_n : OUT STD_LOGIC;
                    signal cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 : OUT STD_LOGIC;
                    signal d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer : OUT STD_LOGIC
                 );
end component WAVEGUIDE_VAC_FAULT_s1_arbitrator;

component WAVEGUIDE_VAC_FAULT is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component WAVEGUIDE_VAC_FAULT;

component cpu_0_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_debugaccess : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_write : OUT STD_LOGIC;
                    signal cpu_0_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_0_jtag_debug_module_end_xfer : OUT STD_LOGIC
                 );
end component cpu_0_jtag_debug_module_arbitrator;

component cpu_0_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal ARC_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal COLD_WINDOW_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal FC_FSD_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal INTERLOCK_ENABLE_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal WARM_WINDOW_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_granted_ARC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_FC_FSD_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_granted_uart_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_ARC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_FC_FSD_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_uart_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_ARC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_FC_FSD_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_uart_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_ARC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_FC_FSD_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_requests_uart_0_s1 : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_ARC_FAULT_s1_end_xfer : IN STD_LOGIC;
                    signal d1_COLD_WINDOW_FAULT_s1_end_xfer : IN STD_LOGIC;
                    signal d1_FC_FSD_s1_end_xfer : IN STD_LOGIC;
                    signal d1_INTERLOCK_ENABLE_s1_end_xfer : IN STD_LOGIC;
                    signal d1_WARM_WINDOW_FAULT_s1_end_xfer : IN STD_LOGIC;
                    signal d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_timer_0_s1_end_xfer : IN STD_LOGIC;
                    signal d1_uart_0_s1_end_xfer : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal timer_0_s1_irq_from_sa : IN STD_LOGIC;
                    signal timer_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_0_s1_irq_from_sa : IN STD_LOGIC;
                    signal uart_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_data_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_0_data_master_arbitrator;

component cpu_0_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_instruction_master_address : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : IN STD_LOGIC;
                    signal cpu_0_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_0_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_0_instruction_master_arbitrator;

component cpu_0 is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d_irq : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_waitrequest : IN STD_LOGIC;
                    signal i_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_waitrequest : IN STD_LOGIC;
                    signal jtag_debug_module_address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal jtag_debug_module_begintransfer : IN STD_LOGIC;
                    signal jtag_debug_module_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal jtag_debug_module_debugaccess : IN STD_LOGIC;
                    signal jtag_debug_module_select : IN STD_LOGIC;
                    signal jtag_debug_module_write : IN STD_LOGIC;
                    signal jtag_debug_module_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component cpu_0;

component onchip_memory2_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_0_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_instruction_master_read : IN STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 : OUT STD_LOGIC;
                    signal d1_onchip_memory2_0_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_address : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal onchip_memory2_0_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_memory2_0_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_clken : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_memory2_0_s1_reset : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_write : OUT STD_LOGIC;
                    signal onchip_memory2_0_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 : OUT STD_LOGIC
                 );
end component onchip_memory2_0_s1_arbitrator;

component onchip_memory2_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal clken : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_memory2_0;

component timer_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal timer_0_s1_irq : IN STD_LOGIC;
                    signal timer_0_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_0_data_master_granted_timer_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_timer_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_timer_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_timer_0_s1 : OUT STD_LOGIC;
                    signal d1_timer_0_s1_end_xfer : OUT STD_LOGIC;
                    signal timer_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal timer_0_s1_chipselect : OUT STD_LOGIC;
                    signal timer_0_s1_irq_from_sa : OUT STD_LOGIC;
                    signal timer_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal timer_0_s1_reset_n : OUT STD_LOGIC;
                    signal timer_0_s1_write_n : OUT STD_LOGIC;
                    signal timer_0_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_0_s1_arbitrator;

component timer_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component timer_0;

component uart_0_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_0_data_master_address_to_slave : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_0_data_master_read : IN STD_LOGIC;
                    signal cpu_0_data_master_write : IN STD_LOGIC;
                    signal cpu_0_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal uart_0_s1_dataavailable : IN STD_LOGIC;
                    signal uart_0_s1_irq : IN STD_LOGIC;
                    signal uart_0_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_0_s1_readyfordata : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_0_data_master_granted_uart_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_qualified_request_uart_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_read_data_valid_uart_0_s1 : OUT STD_LOGIC;
                    signal cpu_0_data_master_requests_uart_0_s1 : OUT STD_LOGIC;
                    signal d1_uart_0_s1_end_xfer : OUT STD_LOGIC;
                    signal uart_0_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal uart_0_s1_begintransfer : OUT STD_LOGIC;
                    signal uart_0_s1_chipselect : OUT STD_LOGIC;
                    signal uart_0_s1_dataavailable_from_sa : OUT STD_LOGIC;
                    signal uart_0_s1_irq_from_sa : OUT STD_LOGIC;
                    signal uart_0_s1_read_n : OUT STD_LOGIC;
                    signal uart_0_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal uart_0_s1_readyfordata_from_sa : OUT STD_LOGIC;
                    signal uart_0_s1_reset_n : OUT STD_LOGIC;
                    signal uart_0_s1_write_n : OUT STD_LOGIC;
                    signal uart_0_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component uart_0_s1_arbitrator;

component uart_0 is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal begintransfer : IN STD_LOGIC;
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read_n : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal rxd : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal dataavailable : OUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal readyfordata : OUT STD_LOGIC;
                    signal txd : OUT STD_LOGIC
                 );
end component uart_0;

component Interlock_LCD_reset_clk_0_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component Interlock_LCD_reset_clk_0_domain_synch_module;

                signal ARC_FAULT_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal ARC_FAULT_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal ARC_FAULT_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal ARC_FAULT_s1_reset_n :  STD_LOGIC;
                signal COLD_WINDOW_FAULT_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal COLD_WINDOW_FAULT_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal COLD_WINDOW_FAULT_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal COLD_WINDOW_FAULT_s1_reset_n :  STD_LOGIC;
                signal FC_FSD_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal FC_FSD_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal FC_FSD_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal FC_FSD_s1_reset_n :  STD_LOGIC;
                signal INTERLOCK_ENABLE_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal INTERLOCK_ENABLE_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal INTERLOCK_ENABLE_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal INTERLOCK_ENABLE_s1_reset_n :  STD_LOGIC;
                signal WARM_WINDOW_FAULT_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal WARM_WINDOW_FAULT_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal WARM_WINDOW_FAULT_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal WARM_WINDOW_FAULT_s1_reset_n :  STD_LOGIC;
                signal WAVEGUIDE_VAC_FAULT_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal WAVEGUIDE_VAC_FAULT_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal WAVEGUIDE_VAC_FAULT_s1_reset_n :  STD_LOGIC;
                signal clk_0_reset_n :  STD_LOGIC;
                signal cpu_0_data_master_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_data_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_data_master_debugaccess :  STD_LOGIC;
                signal cpu_0_data_master_granted_ARC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_FC_FSD_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_granted_uart_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_qualified_request_ARC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_FC_FSD_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_qualified_request_uart_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_ARC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_FC_FSD_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_read_data_valid_uart_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_data_master_requests_ARC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_FC_FSD_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_data_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_timer_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_requests_uart_0_s1 :  STD_LOGIC;
                signal cpu_0_data_master_waitrequest :  STD_LOGIC;
                signal cpu_0_data_master_write :  STD_LOGIC;
                signal cpu_0_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_address :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal cpu_0_instruction_master_granted_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_granted_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_read :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_instruction_master_requests_cpu_0_jtag_debug_module :  STD_LOGIC;
                signal cpu_0_instruction_master_requests_onchip_memory2_0_s1 :  STD_LOGIC;
                signal cpu_0_instruction_master_waitrequest :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal cpu_0_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_0_jtag_debug_module_chipselect :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_0_jtag_debug_module_reset_n :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_write :  STD_LOGIC;
                signal cpu_0_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_ARC_FAULT_s1_end_xfer :  STD_LOGIC;
                signal d1_COLD_WINDOW_FAULT_s1_end_xfer :  STD_LOGIC;
                signal d1_FC_FSD_s1_end_xfer :  STD_LOGIC;
                signal d1_INTERLOCK_ENABLE_s1_end_xfer :  STD_LOGIC;
                signal d1_WARM_WINDOW_FAULT_s1_end_xfer :  STD_LOGIC;
                signal d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer :  STD_LOGIC;
                signal d1_cpu_0_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_onchip_memory2_0_s1_end_xfer :  STD_LOGIC;
                signal d1_timer_0_s1_end_xfer :  STD_LOGIC;
                signal d1_uart_0_s1_end_xfer :  STD_LOGIC;
                signal internal_txd_from_the_uart_0 :  STD_LOGIC;
                signal module_input :  STD_LOGIC;
                signal onchip_memory2_0_s1_address :  STD_LOGIC_VECTOR (11 DOWNTO 0);
                signal onchip_memory2_0_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_memory2_0_s1_chipselect :  STD_LOGIC;
                signal onchip_memory2_0_s1_clken :  STD_LOGIC;
                signal onchip_memory2_0_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_memory2_0_s1_reset :  STD_LOGIC;
                signal onchip_memory2_0_s1_write :  STD_LOGIC;
                signal onchip_memory2_0_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal timer_0_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal timer_0_s1_chipselect :  STD_LOGIC;
                signal timer_0_s1_irq :  STD_LOGIC;
                signal timer_0_s1_irq_from_sa :  STD_LOGIC;
                signal timer_0_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal timer_0_s1_reset_n :  STD_LOGIC;
                signal timer_0_s1_write_n :  STD_LOGIC;
                signal timer_0_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_0_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal uart_0_s1_begintransfer :  STD_LOGIC;
                signal uart_0_s1_chipselect :  STD_LOGIC;
                signal uart_0_s1_dataavailable :  STD_LOGIC;
                signal uart_0_s1_dataavailable_from_sa :  STD_LOGIC;
                signal uart_0_s1_irq :  STD_LOGIC;
                signal uart_0_s1_irq_from_sa :  STD_LOGIC;
                signal uart_0_s1_read_n :  STD_LOGIC;
                signal uart_0_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_0_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal uart_0_s1_readyfordata :  STD_LOGIC;
                signal uart_0_s1_readyfordata_from_sa :  STD_LOGIC;
                signal uart_0_s1_reset_n :  STD_LOGIC;
                signal uart_0_s1_write_n :  STD_LOGIC;
                signal uart_0_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);

begin

  --the_ARC_FAULT_s1, which is an e_instance
  the_ARC_FAULT_s1 : ARC_FAULT_s1_arbitrator
    port map(
      ARC_FAULT_s1_address => ARC_FAULT_s1_address,
      ARC_FAULT_s1_readdata_from_sa => ARC_FAULT_s1_readdata_from_sa,
      ARC_FAULT_s1_reset_n => ARC_FAULT_s1_reset_n,
      cpu_0_data_master_granted_ARC_FAULT_s1 => cpu_0_data_master_granted_ARC_FAULT_s1,
      cpu_0_data_master_qualified_request_ARC_FAULT_s1 => cpu_0_data_master_qualified_request_ARC_FAULT_s1,
      cpu_0_data_master_read_data_valid_ARC_FAULT_s1 => cpu_0_data_master_read_data_valid_ARC_FAULT_s1,
      cpu_0_data_master_requests_ARC_FAULT_s1 => cpu_0_data_master_requests_ARC_FAULT_s1,
      d1_ARC_FAULT_s1_end_xfer => d1_ARC_FAULT_s1_end_xfer,
      ARC_FAULT_s1_readdata => ARC_FAULT_s1_readdata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_0_reset_n
    );


  --the_ARC_FAULT, which is an e_ptf_instance
  the_ARC_FAULT : ARC_FAULT
    port map(
      readdata => ARC_FAULT_s1_readdata,
      address => ARC_FAULT_s1_address,
      clk => clk_0,
      in_port => in_port_to_the_ARC_FAULT,
      reset_n => ARC_FAULT_s1_reset_n
    );


  --the_COLD_WINDOW_FAULT_s1, which is an e_instance
  the_COLD_WINDOW_FAULT_s1 : COLD_WINDOW_FAULT_s1_arbitrator
    port map(
      COLD_WINDOW_FAULT_s1_address => COLD_WINDOW_FAULT_s1_address,
      COLD_WINDOW_FAULT_s1_readdata_from_sa => COLD_WINDOW_FAULT_s1_readdata_from_sa,
      COLD_WINDOW_FAULT_s1_reset_n => COLD_WINDOW_FAULT_s1_reset_n,
      cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1,
      d1_COLD_WINDOW_FAULT_s1_end_xfer => d1_COLD_WINDOW_FAULT_s1_end_xfer,
      COLD_WINDOW_FAULT_s1_readdata => COLD_WINDOW_FAULT_s1_readdata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_0_reset_n
    );


  --the_COLD_WINDOW_FAULT, which is an e_ptf_instance
  the_COLD_WINDOW_FAULT : COLD_WINDOW_FAULT
    port map(
      readdata => COLD_WINDOW_FAULT_s1_readdata,
      address => COLD_WINDOW_FAULT_s1_address,
      clk => clk_0,
      in_port => in_port_to_the_COLD_WINDOW_FAULT,
      reset_n => COLD_WINDOW_FAULT_s1_reset_n
    );


  --the_FC_FSD_s1, which is an e_instance
  the_FC_FSD_s1 : FC_FSD_s1_arbitrator
    port map(
      FC_FSD_s1_address => FC_FSD_s1_address,
      FC_FSD_s1_readdata_from_sa => FC_FSD_s1_readdata_from_sa,
      FC_FSD_s1_reset_n => FC_FSD_s1_reset_n,
      cpu_0_data_master_granted_FC_FSD_s1 => cpu_0_data_master_granted_FC_FSD_s1,
      cpu_0_data_master_qualified_request_FC_FSD_s1 => cpu_0_data_master_qualified_request_FC_FSD_s1,
      cpu_0_data_master_read_data_valid_FC_FSD_s1 => cpu_0_data_master_read_data_valid_FC_FSD_s1,
      cpu_0_data_master_requests_FC_FSD_s1 => cpu_0_data_master_requests_FC_FSD_s1,
      d1_FC_FSD_s1_end_xfer => d1_FC_FSD_s1_end_xfer,
      FC_FSD_s1_readdata => FC_FSD_s1_readdata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_0_reset_n
    );


  --the_FC_FSD, which is an e_ptf_instance
  the_FC_FSD : FC_FSD
    port map(
      readdata => FC_FSD_s1_readdata,
      address => FC_FSD_s1_address,
      clk => clk_0,
      in_port => in_port_to_the_FC_FSD,
      reset_n => FC_FSD_s1_reset_n
    );


  --the_INTERLOCK_ENABLE_s1, which is an e_instance
  the_INTERLOCK_ENABLE_s1 : INTERLOCK_ENABLE_s1_arbitrator
    port map(
      INTERLOCK_ENABLE_s1_address => INTERLOCK_ENABLE_s1_address,
      INTERLOCK_ENABLE_s1_readdata_from_sa => INTERLOCK_ENABLE_s1_readdata_from_sa,
      INTERLOCK_ENABLE_s1_reset_n => INTERLOCK_ENABLE_s1_reset_n,
      cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 => cpu_0_data_master_granted_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 => cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 => cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 => cpu_0_data_master_requests_INTERLOCK_ENABLE_s1,
      d1_INTERLOCK_ENABLE_s1_end_xfer => d1_INTERLOCK_ENABLE_s1_end_xfer,
      INTERLOCK_ENABLE_s1_readdata => INTERLOCK_ENABLE_s1_readdata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_0_reset_n
    );


  --the_INTERLOCK_ENABLE, which is an e_ptf_instance
  the_INTERLOCK_ENABLE : INTERLOCK_ENABLE
    port map(
      readdata => INTERLOCK_ENABLE_s1_readdata,
      address => INTERLOCK_ENABLE_s1_address,
      clk => clk_0,
      in_port => in_port_to_the_INTERLOCK_ENABLE,
      reset_n => INTERLOCK_ENABLE_s1_reset_n
    );


  --the_WARM_WINDOW_FAULT_s1, which is an e_instance
  the_WARM_WINDOW_FAULT_s1 : WARM_WINDOW_FAULT_s1_arbitrator
    port map(
      WARM_WINDOW_FAULT_s1_address => WARM_WINDOW_FAULT_s1_address,
      WARM_WINDOW_FAULT_s1_readdata_from_sa => WARM_WINDOW_FAULT_s1_readdata_from_sa,
      WARM_WINDOW_FAULT_s1_reset_n => WARM_WINDOW_FAULT_s1_reset_n,
      cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1,
      d1_WARM_WINDOW_FAULT_s1_end_xfer => d1_WARM_WINDOW_FAULT_s1_end_xfer,
      WARM_WINDOW_FAULT_s1_readdata => WARM_WINDOW_FAULT_s1_readdata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_0_reset_n
    );


  --the_WARM_WINDOW_FAULT, which is an e_ptf_instance
  the_WARM_WINDOW_FAULT : WARM_WINDOW_FAULT
    port map(
      readdata => WARM_WINDOW_FAULT_s1_readdata,
      address => WARM_WINDOW_FAULT_s1_address,
      clk => clk_0,
      in_port => in_port_to_the_WARM_WINDOW_FAULT,
      reset_n => WARM_WINDOW_FAULT_s1_reset_n
    );


  --the_WAVEGUIDE_VAC_FAULT_s1, which is an e_instance
  the_WAVEGUIDE_VAC_FAULT_s1 : WAVEGUIDE_VAC_FAULT_s1_arbitrator
    port map(
      WAVEGUIDE_VAC_FAULT_s1_address => WAVEGUIDE_VAC_FAULT_s1_address,
      WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa => WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa,
      WAVEGUIDE_VAC_FAULT_s1_reset_n => WAVEGUIDE_VAC_FAULT_s1_reset_n,
      cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1,
      d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer => d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer,
      WAVEGUIDE_VAC_FAULT_s1_readdata => WAVEGUIDE_VAC_FAULT_s1_readdata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      reset_n => clk_0_reset_n
    );


  --the_WAVEGUIDE_VAC_FAULT, which is an e_ptf_instance
  the_WAVEGUIDE_VAC_FAULT : WAVEGUIDE_VAC_FAULT
    port map(
      readdata => WAVEGUIDE_VAC_FAULT_s1_readdata,
      address => WAVEGUIDE_VAC_FAULT_s1_address,
      clk => clk_0,
      in_port => in_port_to_the_WAVEGUIDE_VAC_FAULT,
      reset_n => WAVEGUIDE_VAC_FAULT_s1_reset_n
    );


  --the_cpu_0_jtag_debug_module, which is an e_instance
  the_cpu_0_jtag_debug_module : cpu_0_jtag_debug_module_arbitrator
    port map(
      cpu_0_data_master_granted_cpu_0_jtag_debug_module => cpu_0_data_master_granted_cpu_0_jtag_debug_module,
      cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_data_master_requests_cpu_0_jtag_debug_module => cpu_0_data_master_requests_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_granted_cpu_0_jtag_debug_module => cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_requests_cpu_0_jtag_debug_module => cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
      cpu_0_jtag_debug_module_address => cpu_0_jtag_debug_module_address,
      cpu_0_jtag_debug_module_begintransfer => cpu_0_jtag_debug_module_begintransfer,
      cpu_0_jtag_debug_module_byteenable => cpu_0_jtag_debug_module_byteenable,
      cpu_0_jtag_debug_module_chipselect => cpu_0_jtag_debug_module_chipselect,
      cpu_0_jtag_debug_module_debugaccess => cpu_0_jtag_debug_module_debugaccess,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      cpu_0_jtag_debug_module_reset_n => cpu_0_jtag_debug_module_reset_n,
      cpu_0_jtag_debug_module_resetrequest_from_sa => cpu_0_jtag_debug_module_resetrequest_from_sa,
      cpu_0_jtag_debug_module_write => cpu_0_jtag_debug_module_write,
      cpu_0_jtag_debug_module_writedata => cpu_0_jtag_debug_module_writedata,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_debugaccess => cpu_0_data_master_debugaccess,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_jtag_debug_module_readdata => cpu_0_jtag_debug_module_readdata,
      cpu_0_jtag_debug_module_resetrequest => cpu_0_jtag_debug_module_resetrequest,
      reset_n => clk_0_reset_n
    );


  --the_cpu_0_data_master, which is an e_instance
  the_cpu_0_data_master : cpu_0_data_master_arbitrator
    port map(
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_irq => cpu_0_data_master_irq,
      cpu_0_data_master_readdata => cpu_0_data_master_readdata,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      ARC_FAULT_s1_readdata_from_sa => ARC_FAULT_s1_readdata_from_sa,
      COLD_WINDOW_FAULT_s1_readdata_from_sa => COLD_WINDOW_FAULT_s1_readdata_from_sa,
      FC_FSD_s1_readdata_from_sa => FC_FSD_s1_readdata_from_sa,
      INTERLOCK_ENABLE_s1_readdata_from_sa => INTERLOCK_ENABLE_s1_readdata_from_sa,
      WARM_WINDOW_FAULT_s1_readdata_from_sa => WARM_WINDOW_FAULT_s1_readdata_from_sa,
      WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa => WAVEGUIDE_VAC_FAULT_s1_readdata_from_sa,
      clk => clk_0,
      cpu_0_data_master_address => cpu_0_data_master_address,
      cpu_0_data_master_granted_ARC_FAULT_s1 => cpu_0_data_master_granted_ARC_FAULT_s1,
      cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_granted_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_granted_FC_FSD_s1 => cpu_0_data_master_granted_FC_FSD_s1,
      cpu_0_data_master_granted_INTERLOCK_ENABLE_s1 => cpu_0_data_master_granted_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_granted_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_granted_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_granted_cpu_0_jtag_debug_module => cpu_0_data_master_granted_cpu_0_jtag_debug_module,
      cpu_0_data_master_granted_onchip_memory2_0_s1 => cpu_0_data_master_granted_onchip_memory2_0_s1,
      cpu_0_data_master_granted_timer_0_s1 => cpu_0_data_master_granted_timer_0_s1,
      cpu_0_data_master_granted_uart_0_s1 => cpu_0_data_master_granted_uart_0_s1,
      cpu_0_data_master_qualified_request_ARC_FAULT_s1 => cpu_0_data_master_qualified_request_ARC_FAULT_s1,
      cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_qualified_request_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_qualified_request_FC_FSD_s1 => cpu_0_data_master_qualified_request_FC_FSD_s1,
      cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1 => cpu_0_data_master_qualified_request_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_qualified_request_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_qualified_request_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_data_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_data_master_qualified_request_onchip_memory2_0_s1 => cpu_0_data_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_data_master_qualified_request_timer_0_s1 => cpu_0_data_master_qualified_request_timer_0_s1,
      cpu_0_data_master_qualified_request_uart_0_s1 => cpu_0_data_master_qualified_request_uart_0_s1,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_read_data_valid_ARC_FAULT_s1 => cpu_0_data_master_read_data_valid_ARC_FAULT_s1,
      cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_read_data_valid_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_read_data_valid_FC_FSD_s1 => cpu_0_data_master_read_data_valid_FC_FSD_s1,
      cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1 => cpu_0_data_master_read_data_valid_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_read_data_valid_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_read_data_valid_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_data_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_data_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_data_master_read_data_valid_timer_0_s1 => cpu_0_data_master_read_data_valid_timer_0_s1,
      cpu_0_data_master_read_data_valid_uart_0_s1 => cpu_0_data_master_read_data_valid_uart_0_s1,
      cpu_0_data_master_requests_ARC_FAULT_s1 => cpu_0_data_master_requests_ARC_FAULT_s1,
      cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1 => cpu_0_data_master_requests_COLD_WINDOW_FAULT_s1,
      cpu_0_data_master_requests_FC_FSD_s1 => cpu_0_data_master_requests_FC_FSD_s1,
      cpu_0_data_master_requests_INTERLOCK_ENABLE_s1 => cpu_0_data_master_requests_INTERLOCK_ENABLE_s1,
      cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1 => cpu_0_data_master_requests_WARM_WINDOW_FAULT_s1,
      cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1 => cpu_0_data_master_requests_WAVEGUIDE_VAC_FAULT_s1,
      cpu_0_data_master_requests_cpu_0_jtag_debug_module => cpu_0_data_master_requests_cpu_0_jtag_debug_module,
      cpu_0_data_master_requests_onchip_memory2_0_s1 => cpu_0_data_master_requests_onchip_memory2_0_s1,
      cpu_0_data_master_requests_timer_0_s1 => cpu_0_data_master_requests_timer_0_s1,
      cpu_0_data_master_requests_uart_0_s1 => cpu_0_data_master_requests_uart_0_s1,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      d1_ARC_FAULT_s1_end_xfer => d1_ARC_FAULT_s1_end_xfer,
      d1_COLD_WINDOW_FAULT_s1_end_xfer => d1_COLD_WINDOW_FAULT_s1_end_xfer,
      d1_FC_FSD_s1_end_xfer => d1_FC_FSD_s1_end_xfer,
      d1_INTERLOCK_ENABLE_s1_end_xfer => d1_INTERLOCK_ENABLE_s1_end_xfer,
      d1_WARM_WINDOW_FAULT_s1_end_xfer => d1_WARM_WINDOW_FAULT_s1_end_xfer,
      d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer => d1_WAVEGUIDE_VAC_FAULT_s1_end_xfer,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      d1_timer_0_s1_end_xfer => d1_timer_0_s1_end_xfer,
      d1_uart_0_s1_end_xfer => d1_uart_0_s1_end_xfer,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 => registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1,
      reset_n => clk_0_reset_n,
      timer_0_s1_irq_from_sa => timer_0_s1_irq_from_sa,
      timer_0_s1_readdata_from_sa => timer_0_s1_readdata_from_sa,
      uart_0_s1_irq_from_sa => uart_0_s1_irq_from_sa,
      uart_0_s1_readdata_from_sa => uart_0_s1_readdata_from_sa
    );


  --the_cpu_0_instruction_master, which is an e_instance
  the_cpu_0_instruction_master : cpu_0_instruction_master_arbitrator
    port map(
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_readdata => cpu_0_instruction_master_readdata,
      cpu_0_instruction_master_waitrequest => cpu_0_instruction_master_waitrequest,
      clk => clk_0,
      cpu_0_instruction_master_address => cpu_0_instruction_master_address,
      cpu_0_instruction_master_granted_cpu_0_jtag_debug_module => cpu_0_instruction_master_granted_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_granted_onchip_memory2_0_s1 => cpu_0_instruction_master_granted_onchip_memory2_0_s1,
      cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module => cpu_0_instruction_master_qualified_request_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 => cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module => cpu_0_instruction_master_read_data_valid_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_instruction_master_requests_cpu_0_jtag_debug_module => cpu_0_instruction_master_requests_cpu_0_jtag_debug_module,
      cpu_0_instruction_master_requests_onchip_memory2_0_s1 => cpu_0_instruction_master_requests_onchip_memory2_0_s1,
      cpu_0_jtag_debug_module_readdata_from_sa => cpu_0_jtag_debug_module_readdata_from_sa,
      d1_cpu_0_jtag_debug_module_end_xfer => d1_cpu_0_jtag_debug_module_end_xfer,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      reset_n => clk_0_reset_n
    );


  --the_cpu_0, which is an e_ptf_instance
  the_cpu_0 : cpu_0
    port map(
      d_address => cpu_0_data_master_address,
      d_byteenable => cpu_0_data_master_byteenable,
      d_read => cpu_0_data_master_read,
      d_write => cpu_0_data_master_write,
      d_writedata => cpu_0_data_master_writedata,
      i_address => cpu_0_instruction_master_address,
      i_read => cpu_0_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => cpu_0_data_master_debugaccess,
      jtag_debug_module_readdata => cpu_0_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => cpu_0_jtag_debug_module_resetrequest,
      clk => clk_0,
      d_irq => cpu_0_data_master_irq,
      d_readdata => cpu_0_data_master_readdata,
      d_waitrequest => cpu_0_data_master_waitrequest,
      i_readdata => cpu_0_instruction_master_readdata,
      i_waitrequest => cpu_0_instruction_master_waitrequest,
      jtag_debug_module_address => cpu_0_jtag_debug_module_address,
      jtag_debug_module_begintransfer => cpu_0_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => cpu_0_jtag_debug_module_byteenable,
      jtag_debug_module_debugaccess => cpu_0_jtag_debug_module_debugaccess,
      jtag_debug_module_select => cpu_0_jtag_debug_module_chipselect,
      jtag_debug_module_write => cpu_0_jtag_debug_module_write,
      jtag_debug_module_writedata => cpu_0_jtag_debug_module_writedata,
      reset_n => cpu_0_jtag_debug_module_reset_n
    );


  --the_onchip_memory2_0_s1, which is an e_instance
  the_onchip_memory2_0_s1 : onchip_memory2_0_s1_arbitrator
    port map(
      cpu_0_data_master_granted_onchip_memory2_0_s1 => cpu_0_data_master_granted_onchip_memory2_0_s1,
      cpu_0_data_master_qualified_request_onchip_memory2_0_s1 => cpu_0_data_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_data_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_data_master_requests_onchip_memory2_0_s1 => cpu_0_data_master_requests_onchip_memory2_0_s1,
      cpu_0_instruction_master_granted_onchip_memory2_0_s1 => cpu_0_instruction_master_granted_onchip_memory2_0_s1,
      cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1 => cpu_0_instruction_master_qualified_request_onchip_memory2_0_s1,
      cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1 => cpu_0_instruction_master_read_data_valid_onchip_memory2_0_s1,
      cpu_0_instruction_master_requests_onchip_memory2_0_s1 => cpu_0_instruction_master_requests_onchip_memory2_0_s1,
      d1_onchip_memory2_0_s1_end_xfer => d1_onchip_memory2_0_s1_end_xfer,
      onchip_memory2_0_s1_address => onchip_memory2_0_s1_address,
      onchip_memory2_0_s1_byteenable => onchip_memory2_0_s1_byteenable,
      onchip_memory2_0_s1_chipselect => onchip_memory2_0_s1_chipselect,
      onchip_memory2_0_s1_clken => onchip_memory2_0_s1_clken,
      onchip_memory2_0_s1_readdata_from_sa => onchip_memory2_0_s1_readdata_from_sa,
      onchip_memory2_0_s1_reset => onchip_memory2_0_s1_reset,
      onchip_memory2_0_s1_write => onchip_memory2_0_s1_write,
      onchip_memory2_0_s1_writedata => onchip_memory2_0_s1_writedata,
      registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1 => registered_cpu_0_data_master_read_data_valid_onchip_memory2_0_s1,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_byteenable => cpu_0_data_master_byteenable,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      cpu_0_instruction_master_address_to_slave => cpu_0_instruction_master_address_to_slave,
      cpu_0_instruction_master_read => cpu_0_instruction_master_read,
      onchip_memory2_0_s1_readdata => onchip_memory2_0_s1_readdata,
      reset_n => clk_0_reset_n
    );


  --the_onchip_memory2_0, which is an e_ptf_instance
  the_onchip_memory2_0 : onchip_memory2_0
    port map(
      readdata => onchip_memory2_0_s1_readdata,
      address => onchip_memory2_0_s1_address,
      byteenable => onchip_memory2_0_s1_byteenable,
      chipselect => onchip_memory2_0_s1_chipselect,
      clk => clk_0,
      clken => onchip_memory2_0_s1_clken,
      reset => onchip_memory2_0_s1_reset,
      write => onchip_memory2_0_s1_write,
      writedata => onchip_memory2_0_s1_writedata
    );


  --the_timer_0_s1, which is an e_instance
  the_timer_0_s1 : timer_0_s1_arbitrator
    port map(
      cpu_0_data_master_granted_timer_0_s1 => cpu_0_data_master_granted_timer_0_s1,
      cpu_0_data_master_qualified_request_timer_0_s1 => cpu_0_data_master_qualified_request_timer_0_s1,
      cpu_0_data_master_read_data_valid_timer_0_s1 => cpu_0_data_master_read_data_valid_timer_0_s1,
      cpu_0_data_master_requests_timer_0_s1 => cpu_0_data_master_requests_timer_0_s1,
      d1_timer_0_s1_end_xfer => d1_timer_0_s1_end_xfer,
      timer_0_s1_address => timer_0_s1_address,
      timer_0_s1_chipselect => timer_0_s1_chipselect,
      timer_0_s1_irq_from_sa => timer_0_s1_irq_from_sa,
      timer_0_s1_readdata_from_sa => timer_0_s1_readdata_from_sa,
      timer_0_s1_reset_n => timer_0_s1_reset_n,
      timer_0_s1_write_n => timer_0_s1_write_n,
      timer_0_s1_writedata => timer_0_s1_writedata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_waitrequest => cpu_0_data_master_waitrequest,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => clk_0_reset_n,
      timer_0_s1_irq => timer_0_s1_irq,
      timer_0_s1_readdata => timer_0_s1_readdata
    );


  --the_timer_0, which is an e_ptf_instance
  the_timer_0 : timer_0
    port map(
      irq => timer_0_s1_irq,
      readdata => timer_0_s1_readdata,
      address => timer_0_s1_address,
      chipselect => timer_0_s1_chipselect,
      clk => clk_0,
      reset_n => timer_0_s1_reset_n,
      write_n => timer_0_s1_write_n,
      writedata => timer_0_s1_writedata
    );


  --the_uart_0_s1, which is an e_instance
  the_uart_0_s1 : uart_0_s1_arbitrator
    port map(
      cpu_0_data_master_granted_uart_0_s1 => cpu_0_data_master_granted_uart_0_s1,
      cpu_0_data_master_qualified_request_uart_0_s1 => cpu_0_data_master_qualified_request_uart_0_s1,
      cpu_0_data_master_read_data_valid_uart_0_s1 => cpu_0_data_master_read_data_valid_uart_0_s1,
      cpu_0_data_master_requests_uart_0_s1 => cpu_0_data_master_requests_uart_0_s1,
      d1_uart_0_s1_end_xfer => d1_uart_0_s1_end_xfer,
      uart_0_s1_address => uart_0_s1_address,
      uart_0_s1_begintransfer => uart_0_s1_begintransfer,
      uart_0_s1_chipselect => uart_0_s1_chipselect,
      uart_0_s1_dataavailable_from_sa => uart_0_s1_dataavailable_from_sa,
      uart_0_s1_irq_from_sa => uart_0_s1_irq_from_sa,
      uart_0_s1_read_n => uart_0_s1_read_n,
      uart_0_s1_readdata_from_sa => uart_0_s1_readdata_from_sa,
      uart_0_s1_readyfordata_from_sa => uart_0_s1_readyfordata_from_sa,
      uart_0_s1_reset_n => uart_0_s1_reset_n,
      uart_0_s1_write_n => uart_0_s1_write_n,
      uart_0_s1_writedata => uart_0_s1_writedata,
      clk => clk_0,
      cpu_0_data_master_address_to_slave => cpu_0_data_master_address_to_slave,
      cpu_0_data_master_read => cpu_0_data_master_read,
      cpu_0_data_master_write => cpu_0_data_master_write,
      cpu_0_data_master_writedata => cpu_0_data_master_writedata,
      reset_n => clk_0_reset_n,
      uart_0_s1_dataavailable => uart_0_s1_dataavailable,
      uart_0_s1_irq => uart_0_s1_irq,
      uart_0_s1_readdata => uart_0_s1_readdata,
      uart_0_s1_readyfordata => uart_0_s1_readyfordata
    );


  --the_uart_0, which is an e_ptf_instance
  the_uart_0 : uart_0
    port map(
      dataavailable => uart_0_s1_dataavailable,
      irq => uart_0_s1_irq,
      readdata => uart_0_s1_readdata,
      readyfordata => uart_0_s1_readyfordata,
      txd => internal_txd_from_the_uart_0,
      address => uart_0_s1_address,
      begintransfer => uart_0_s1_begintransfer,
      chipselect => uart_0_s1_chipselect,
      clk => clk_0,
      read_n => uart_0_s1_read_n,
      reset_n => uart_0_s1_reset_n,
      rxd => rxd_to_the_uart_0,
      write_n => uart_0_s1_write_n,
      writedata => uart_0_s1_writedata
    );


  --reset is asserted asynchronously and deasserted synchronously
  Interlock_LCD_reset_clk_0_domain_synch : Interlock_LCD_reset_clk_0_domain_synch_module
    port map(
      data_out => clk_0_reset_n,
      clk => clk_0,
      data_in => module_input,
      reset_n => reset_n_sources
    );

  module_input <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_0_jtag_debug_module_resetrequest_from_sa))))));
  --vhdl renameroo for output signals
  txd_from_the_uart_0 <= internal_txd_from_the_uart_0;

end europa;


--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is
component Interlock_LCD is 
           port (
                 -- 1) global signals:
                    signal clk_0 : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_ARC_FAULT
                    signal in_port_to_the_ARC_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_COLD_WINDOW_FAULT
                    signal in_port_to_the_COLD_WINDOW_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_FC_FSD
                    signal in_port_to_the_FC_FSD : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_INTERLOCK_ENABLE
                    signal in_port_to_the_INTERLOCK_ENABLE : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_WARM_WINDOW_FAULT
                    signal in_port_to_the_WARM_WINDOW_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_WAVEGUIDE_VAC_FAULT
                    signal in_port_to_the_WAVEGUIDE_VAC_FAULT : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_uart_0
                    signal rxd_to_the_uart_0 : IN STD_LOGIC;
                    signal txd_from_the_uart_0 : OUT STD_LOGIC
                 );
end component Interlock_LCD;

                signal clk :  STD_LOGIC;
                signal clk_0 :  STD_LOGIC;
                signal in_port_to_the_ARC_FAULT :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_COLD_WINDOW_FAULT :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_FC_FSD :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_INTERLOCK_ENABLE :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_WARM_WINDOW_FAULT :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_WAVEGUIDE_VAC_FAULT :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal reset_n :  STD_LOGIC;
                signal rxd_to_the_uart_0 :  STD_LOGIC;
                signal txd_from_the_uart_0 :  STD_LOGIC;
                signal uart_0_s1_dataavailable_from_sa :  STD_LOGIC;
                signal uart_0_s1_readyfordata_from_sa :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : Interlock_LCD
    port map(
      txd_from_the_uart_0 => txd_from_the_uart_0,
      clk_0 => clk_0,
      in_port_to_the_ARC_FAULT => in_port_to_the_ARC_FAULT,
      in_port_to_the_COLD_WINDOW_FAULT => in_port_to_the_COLD_WINDOW_FAULT,
      in_port_to_the_FC_FSD => in_port_to_the_FC_FSD,
      in_port_to_the_INTERLOCK_ENABLE => in_port_to_the_INTERLOCK_ENABLE,
      in_port_to_the_WARM_WINDOW_FAULT => in_port_to_the_WARM_WINDOW_FAULT,
      in_port_to_the_WAVEGUIDE_VAC_FAULT => in_port_to_the_WAVEGUIDE_VAC_FAULT,
      reset_n => reset_n,
      rxd_to_the_uart_0 => rxd_to_the_uart_0
    );


  process
  begin
    clk_0 <= '0';
    loop
       if (clk_0 = '1') then
          wait for 6 ns;
          clk_0 <= not clk_0;
       else
          wait for 7 ns;
          clk_0 <= not clk_0;
       end if;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 125 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
