LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CU is 
  PORT (
    CLK, RST , INT: IN STD_LOGIC;
    OP_CODE: IN STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- # Decode Stage Signals
    RD_NXT_INST, RD_EN: OUT STD_LOGIC;

    -- # Execute Stage Signals
    ------------ ALU RELATED SIGNALS --------------
    ALU_SRC:  OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALU_OP: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

    ------------ Flags and branching signals--------------
    SET_CARRY, BRANCH: OUT STD_LOGIC;
    BRANCH_T: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    ------------ OTHER SIGNALS --------------
    PC_WE, OUT_EN, IMM_SIG: OUT STD_LOGIC;
    SP_OP: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- # Memory Stage Signals
    PC_SEL, MEM_WRT_EN: OUT STD_LOGIC;
    MEM_ADDR, MEM_WRT_DATA: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- # Write Back Stage Signals
    WB_DATA, WB_ADDR: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    REG_WRT_EN, SWAP_SIG: OUT STD_LOGIC
  ); 
END ENTITY CU;

ARCHITECTURE RTL OF CU IS
  -- Instruction Group Signals (Bit-based classification)
  SIGNAL is_group_00xxx   : STD_LOGIC; -- 00XXX: One operand/control instructions
  SIGNAL is_group_01xxx   : STD_LOGIC; -- 01XXX: Memory and Stack operations
  SIGNAL is_group_10xxx   : STD_LOGIC; -- 10XXX: Branch/Jump/Interrupt operations
  SIGNAL is_group_11xxx   : STD_LOGIC; -- 11XXX: Reserved/Branch operations
  
  -- Subgroup decoders
  SIGNAL is_alu_op        : STD_LOGIC; -- 00011 to 01000 (NOT, INC, MOV, ADD, SUB, AND)
  SIGNAL is_imm_op        : STD_LOGIC; -- 01001, 01010 (IADD, LDM)
  SIGNAL is_mem_op        : STD_LOGIC; -- 01011, 01100 (LDD, STD)
  SIGNAL is_stack_op      : STD_LOGIC; -- 01101, 01110 (PUSH, POP)
  SIGNAL is_branch_op     : STD_LOGIC; -- 01111 to 10001 (JZ, JN, JMP)
  SIGNAL is_call_ret      : STD_LOGIC; -- 10010 to 10100 (CALL, RET, RTI)
  
  -- Specific instruction decoders
  SIGNAL is_halt          : STD_LOGIC; -- 00001
  SIGNAL is_setc          : STD_LOGIC; -- 00010
  SIGNAL is_not           : STD_LOGIC; -- 00011
  SIGNAL is_inc           : STD_LOGIC; -- 00100
  SIGNAL is_mov           : STD_LOGIC; -- 00101
  SIGNAL is_iadd          : STD_LOGIC; -- 01001
  SIGNAL is_ldm           : STD_LOGIC; -- 01010
  SIGNAL is_ldd           : STD_LOGIC; -- 01011
  SIGNAL is_std           : STD_LOGIC; -- 01100
  SIGNAL is_push          : STD_LOGIC; -- 01101
  SIGNAL is_pop           : STD_LOGIC; -- 01110
  SIGNAL is_jz            : STD_LOGIC; -- 01111
  SIGNAL is_jn            : STD_LOGIC; -- 10000
  SIGNAL is_jmp           : STD_LOGIC; -- 10001
  SIGNAL is_call          : STD_LOGIC; -- 10010
  SIGNAL is_ret           : STD_LOGIC; -- 10011
  SIGNAL is_rti           : STD_LOGIC; -- 10100
  SIGNAL is_int           : STD_LOGIC; -- 10101

BEGIN

  -- =================== INSTRUCTION GROUPING ===================
  -- Group by upper bits for efficient decoding
  is_group_00xxx <= NOT OP_CODE(4) AND NOT OP_CODE(3);
  is_group_01xxx <= NOT OP_CODE(4) AND OP_CODE(3);
  is_group_10xxx <= OP_CODE(4) AND NOT OP_CODE(3);
  is_group_11xxx <= OP_CODE(4) AND OP_CODE(3);

  -- Subgroup classifications
  is_alu_op     <= is_group_00xxx AND (OP_CODE(2) OR OP_CODE(1) OR OP_CODE(0)); -- 00011-00111 + 01000
  is_imm_op     <= (OP_CODE = "01001") OR (OP_CODE = "01010");
  is_mem_op     <= (OP_CODE = "01011") OR (OP_CODE = "01100");
  is_stack_op   <= (OP_CODE = "01101") OR (OP_CODE = "01110");
  is_branch_op  <= (OP_CODE = "01111") OR (OP_CODE = "10000") OR (OP_CODE = "10001");
  is_call_ret   <= (OP_CODE = "10010") OR (OP_CODE = "10011") OR (OP_CODE = "10100");

  -- Specific instruction identification
  is_halt  <= '1' WHEN OP_CODE = "00001" ELSE '0';
  is_setc  <= '1' WHEN OP_CODE = "00010" ELSE '0';
  is_not   <= '1' WHEN OP_CODE = "00011" ELSE '0';
  is_inc   <= '1' WHEN OP_CODE = "00100" ELSE '0';
  is_mov   <= '1' WHEN OP_CODE = "00101" ELSE '0';
  is_iadd  <= '1' WHEN OP_CODE = "01001" ELSE '0';
  is_ldm   <= '1' WHEN OP_CODE = "01010" ELSE '0';
  is_ldd   <= '1' WHEN OP_CODE = "01011" ELSE '0';
  is_std   <= '1' WHEN OP_CODE = "01100" ELSE '0';
  is_push  <= '1' WHEN OP_CODE = "01101" ELSE '0';
  is_pop   <= '1' WHEN OP_CODE = "01110" ELSE '0';
  is_jz    <= '1' WHEN OP_CODE = "01111" ELSE '0';
  is_jn    <= '1' WHEN OP_CODE = "10000" ELSE '0';
  is_jmp   <= '1' WHEN OP_CODE = "10001" ELSE '0';
  is_call  <= '1' WHEN OP_CODE = "10010" ELSE '0';
  is_ret   <= '1' WHEN OP_CODE = "10011" ELSE '0';
  is_rti   <= '1' WHEN OP_CODE = "10100" ELSE '0';
  is_int   <= '1' WHEN OP_CODE = "10101" ELSE '0';

  -- =================== OPTIMIZED SIGNAL GENERATION ===================
  
  -- Decode Stage Signals
  RD_NXT_INST <= NOT (is_halt OR is_branch_op OR is_call_ret);
  RD_EN       <= NOT (is_halt OR is_int);

  -- Execute Stage: ALU Control
  ALU_SRC <= "01" WHEN is_iadd = '1' ELSE "00";
  
  -- ALU_OP: Direct mapping from lower bits for ALU instructions
  -- NOT=001, INC=010, ADD/IADD=011, SUB=100, AND=101
  ALU_OP(2) <= (OP_CODE(2) AND (is_not OR is_inc)) OR (OP_CODE(2) AND NOT OP_CODE(1) AND (OP_CODE(0) OR is_iadd));
  ALU_OP(1) <= OP_CODE(1) AND (is_alu_op OR is_iadd);
  ALU_OP(0) <= (OP_CODE(0) AND (is_alu_op OR is_iadd)) OR is_not;

  -- Flags and Branching
  SET_CARRY <= is_setc;
  BRANCH    <= is_branch_op OR is_call_ret;
  BRANCH_T  <= "11" WHEN (is_ret OR is_rti) = '1' ELSE
               "10" WHEN is_jn = '1' ELSE
               "01" WHEN is_jz = '1' ELSE
               "00"; -- JMP, CALL

  -- PC and other Execute signals
  PC_WE   <= '0';
  OUT_EN  <= '0';
  IMM_SIG <= is_iadd OR is_ldm;

  -- Stack Pointer Operations
  SP_OP <= "11" WHEN is_rti = '1' ELSE
           "10" WHEN (is_pop OR is_ret) = '1' ELSE
           "01" WHEN (is_push OR is_call OR is_int) = '1' ELSE
           "00";

  -- Memory Stage Signals
  PC_SEL      <= is_ret OR is_rti;
  MEM_WRT_EN  <= is_std OR is_push OR is_call OR is_int;
  
  MEM_ADDR    <= "10" WHEN (is_stack_op OR is_call_ret OR is_int) = '1' ELSE
                 "01" WHEN is_mem_op = '1' ELSE
                 "00";
  
  MEM_WRT_DATA <= "10" WHEN is_int = '1' ELSE
                  "01" WHEN (is_std OR is_push) = '1' ELSE
                  "00"; -- PC for CALL

  -- Write Back Stage Signals
  WB_DATA <= "11" WHEN is_mov = '1' ELSE
             "10" WHEN is_ldm = '1' ELSE
             "01" WHEN (is_alu_op OR is_iadd) = '1' ELSE
             "00"; -- Memory data for LDD, POP

  WB_ADDR     <= "00";
  REG_WRT_EN  <= is_alu_op OR is_mov OR is_iadd OR is_ldm OR is_ldd OR is_pop;
  SWAP_SIG    <= '0';

END ARCHITECTURE;