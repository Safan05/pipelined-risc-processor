LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY CU_TB IS
END ENTITY CU_TB;

ARCHITECTURE TB OF CU_TB IS
  -- Component Declaration
  COMPONENT CU
    PORT (
      CLK, RST, INT_SIG : IN STD_LOGIC;
      OP_CODE : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
      RD_NXT_INST, RD_EN : OUT STD_LOGIC;
      ALU_SRC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      SET_CARRY, BRANCH : OUT STD_LOGIC;
      BRANCH_T : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      PC_WE, OUT_EN, IMM_SIG : OUT STD_LOGIC;
      SP_OP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      PC_SEL, MEM_WRT_EN : OUT STD_LOGIC;
      MEM_ADDR, MEM_WRT_DATA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      WB_DATA, WB_ADDR : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      REG_WRT_EN, SWAP_SIG : OUT STD_LOGIC
    );
  END COMPONENT;

  -- Test Signals
  SIGNAL CLK : STD_LOGIC := '0';
  SIGNAL RST : STD_LOGIC := '1';
  SIGNAL INT_SIG : STD_LOGIC := '0';
  SIGNAL OP_CODE : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
  
  -- Output Signals
  SIGNAL RD_NXT_INST, RD_EN : STD_LOGIC;
  SIGNAL ALU_SRC : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL ALU_OP : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL SET_CARRY, BRANCH : STD_LOGIC;
  SIGNAL BRANCH_T : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL PC_WE, OUT_EN, IMM_SIG : STD_LOGIC;
  SIGNAL SP_OP : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL PC_SEL, MEM_WRT_EN : STD_LOGIC;
  SIGNAL MEM_ADDR, MEM_WRT_DATA : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL WB_DATA, WB_ADDR : STD_LOGIC_VECTOR(1 DOWNTO 0);
  SIGNAL REG_WRT_EN, SWAP_SIG : STD_LOGIC;

  -- Clock period
  CONSTANT CLK_PERIOD : TIME := 10 ns;
  
  -- Test counter
  SIGNAL test_count : INTEGER := 0;
  SIGNAL errors : INTEGER := 0;

BEGIN
  -- Instantiate the Unit Under Test (UUT)
  UUT: CU PORT MAP (
    CLK => CLK,
    RST => RST,
    INT_SIG => INT_SIG,
    OP_CODE => OP_CODE,
    RD_NXT_INST => RD_NXT_INST,
    RD_EN => RD_EN,
    ALU_SRC => ALU_SRC,
    ALU_OP => ALU_OP,
    SET_CARRY => SET_CARRY,
    BRANCH => BRANCH,
    BRANCH_T => BRANCH_T,
    PC_WE => PC_WE,
    OUT_EN => OUT_EN,
    IMM_SIG => IMM_SIG,
    SP_OP => SP_OP,
    PC_SEL => PC_SEL,
    MEM_WRT_EN => MEM_WRT_EN,
    MEM_ADDR => MEM_ADDR,
    MEM_WRT_DATA => MEM_WRT_DATA,
    WB_DATA => WB_DATA,
    WB_ADDR => WB_ADDR,
    REG_WRT_EN => REG_WRT_EN,
    SWAP_SIG => SWAP_SIG
  );

  -- Clock generation
  CLK_PROCESS: PROCESS
  BEGIN
    CLK <= '0';
    WAIT FOR CLK_PERIOD/2;
    CLK <= '1';
    WAIT FOR CLK_PERIOD/2;
  END PROCESS;

  -- Test procedure
  TEST_PROC: PROCESS
    VARIABLE L : LINE;
    
    -- Helper procedure to check signals
    PROCEDURE check_signals(
      inst_name : STRING;
      exp_rd_nxt : STD_LOGIC;
      exp_rd_en : STD_LOGIC;
      exp_imm_sig : STD_LOGIC;
      exp_alu_src : STD_LOGIC_VECTOR(1 DOWNTO 0);
      exp_alu_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
      exp_set_carry : STD_LOGIC;
      exp_branch : STD_LOGIC;
      exp_branch_t : STD_LOGIC_VECTOR(1 DOWNTO 0);
      exp_pc_we : STD_LOGIC;
      exp_out_en : STD_LOGIC;
      exp_sp_op : STD_LOGIC_VECTOR(1 DOWNTO 0);
      exp_pc_sel : STD_LOGIC;
      exp_mem_addr : STD_LOGIC_VECTOR(1 DOWNTO 0); 
      exp_mem_wrt_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
      exp_mem_wrt : STD_LOGIC;
      exp_wb_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
      exp_wb_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
      exp_reg_wrt : STD_LOGIC;
      exp_swap : STD_LOGIC
    ) IS
    BEGIN
      test_count <= test_count + 1;
      WAIT FOR 2 ns; -- Allow signals to settle
      
      WRITE(L, STRING'("Testing "));
      WRITE(L, inst_name);
      WRITE(L, STRING'(" (OpCode: "));
      WRITE(L, OP_CODE);
      WRITE(L, STRING'(")"));
      WRITELINE(OUTPUT, L);
      
      -- Check each signal
      IF RD_NXT_INST /= exp_rd_nxt THEN
        WRITE(L, STRING'("  ERROR: RD_NXT_INST = "));
        WRITE(L, RD_NXT_INST);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_rd_nxt);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF RD_EN /= exp_rd_en THEN
        WRITE(L, STRING'("  ERROR: RD_EN = "));
        WRITE(L, RD_EN);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_rd_en);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF ALU_SRC /= exp_alu_src THEN
        WRITE(L, STRING'("  ERROR: ALU_SRC = "));
        WRITE(L, ALU_SRC);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_alu_src);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF ALU_OP /= exp_alu_op THEN
        WRITE(L, STRING'("  ERROR: ALU_OP = "));
        WRITE(L, ALU_OP);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_alu_op);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF SET_CARRY /= exp_set_carry THEN
        WRITE(L, STRING'("  ERROR: SET_CARRY = "));
        WRITE(L, SET_CARRY);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_set_carry);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF BRANCH /= exp_branch THEN
        WRITE(L, STRING'("  ERROR: BRANCH = "));
        WRITE(L, BRANCH);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_branch);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF BRANCH_T /= exp_branch_t THEN
        WRITE(L, STRING'("  ERROR: BRANCH_T = "));
        WRITE(L, BRANCH_T);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_branch_t);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF PC_WE /= exp_pc_we THEN
        WRITE(L, STRING'("  ERROR: PC_WE = "));
        WRITE(L, PC_WE);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_pc_we);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF OUT_EN /= exp_out_en THEN
        WRITE(L, STRING'("  ERROR: OUT_EN = "));
        WRITE(L, OUT_EN);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_out_en);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF IMM_SIG /= exp_imm_sig THEN
        WRITE(L, STRING'("  ERROR: IMM_SIG = "));
        WRITE(L, IMM_SIG);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_imm_sig);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF SP_OP /= exp_sp_op THEN
        WRITE(L, STRING'("  ERROR: SP_OP = "));
        WRITE(L, SP_OP);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_sp_op);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF PC_SEL /= exp_pc_sel THEN
        WRITE(L, STRING'("  ERROR: PC_SEL = "));
        WRITE(L, PC_SEL);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_pc_sel);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF MEM_WRT_EN /= exp_mem_wrt THEN
        WRITE(L, STRING'("  ERROR: MEM_WRT_EN = "));
        WRITE(L, MEM_WRT_EN);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_mem_wrt);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF MEM_ADDR /= exp_mem_addr THEN
        WRITE(L, STRING'("  ERROR: MEM_ADDR = "));
        WRITE(L, MEM_ADDR);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_mem_addr);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF MEM_WRT_DATA /= exp_mem_wrt_data THEN
        WRITE(L, STRING'("  ERROR: MEM_WRT_DATA = "));
        WRITE(L, MEM_WRT_DATA);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_mem_wrt_data);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF WB_DATA /= exp_wb_data THEN
        WRITE(L, STRING'("  ERROR: WB_DATA = "));
        WRITE(L, WB_DATA);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_wb_data);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF WB_ADDR /= exp_wb_addr THEN
        WRITE(L, STRING'("  ERROR: WB_ADDR = "));
        WRITE(L, WB_ADDR);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_wb_addr);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF REG_WRT_EN /= exp_reg_wrt THEN
        WRITE(L, STRING'("  ERROR: REG_WRT_EN = "));
        WRITE(L, REG_WRT_EN);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_reg_wrt);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      IF SWAP_SIG /= exp_swap THEN
        WRITE(L, STRING'("  ERROR: SWAP_SIG = "));
        WRITE(L, SWAP_SIG);
        WRITE(L, STRING'(", expected = "));
        WRITE(L, exp_swap);
        WRITELINE(OUTPUT, L);
        errors <= errors + 1;
      END IF;
      
      WAIT FOR CLK_PERIOD;
    END PROCEDURE;

  BEGIN
    -- Reset
    RST <= '1';
    INT_SIG <= '0';
    WAIT FOR CLK_PERIOD * 2;
    
    WRITE(L, STRING'("========================================"));
    WRITELINE(OUTPUT, L);
    WRITE(L, STRING'("  Control Unit Testbench Started"));
    WRITELINE(OUTPUT, L);
    WRITE(L, STRING'("========================================"));
    WRITELINE(OUTPUT, L);

    -- Parameters: inst_name, rd_nxt, rd_en, imm_sig, alu_src, alu_op, set_carry, branch, branch_t, pc_we, out_en, sp_op, pc_sel, mem_addr, mem_wrt_data, mem_wrt, wb_data, wb_addr, reg_wrt, swap
    
    -- Test NOP (00000)
    OP_CODE <= "00111";
    check_signals("NOP", '1', '1', '0', "01", "000", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test HLT (00001)
    OP_CODE <= "00001";
    check_signals("HLT", '1', '1', '0', "01", "000", '0', '0', "00", '0', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test SETC (00010)
    OP_CODE <= "00010";
    check_signals("SETC", '1', '1', '0', "01", "000", '1', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test NOT (00011)
    OP_CODE <= "00011";
    check_signals("NOT", '1', '1', '0', "01", "101", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "00", '1', '0');

    -- Test INC (00100)
    OP_CODE <= "00100";
    check_signals("INC", '1', '1', '0', "00", "001", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "00", '1', '0');

    -- Test OUT (00101)
    OP_CODE <= "00101";
    check_signals("OUT", '1', '1', '0', "01", "000", '0', '0', "00", '1', '1', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test IN (00110)
    OP_CODE <= "00110";
    check_signals("IN", '1', '1', '0', "01", "000", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "01", "00", '1', '0');

    -- Test MOV (01000)
    OP_CODE <= "01000";
    check_signals("MOV", '1', '1', '0', "01", "110", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "01", '1', '0');

    -- Test SWAP (01001)
    OP_CODE <= "01001";
    check_signals("SWAP", '1', '1', '0', "01", "111", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "01", '1', '1');

    -- Test ADD (01010)
    OP_CODE <= "01010";
    check_signals("ADD", '1', '1', '0', "01", "001", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "10", '1', '0');

    -- Test SUB (01011)
    OP_CODE <= "01011";
    check_signals("SUB", '1', '1', '0', "01", "010", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "10", '1', '0');

    -- Test AND (01100)
    OP_CODE <= "01100";
    check_signals("AND", '1', '1', '0', "01", "100", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "10", '1', '0');

    -- Test IADD (01101)
    OP_CODE <= "01101";
    check_signals("IADD", '0', '1', '1', "10", "001", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "01", '1', '0');

    -- Test PUSH (10000)
    OP_CODE <= "10000";
    check_signals("PUSH", '1', '1', '0', "01", "110", '0', '0', "00", '1', '0', "10", '0', "01", "10", '1', "00", "00", '0', '0');

    -- Test POP (10001)
    OP_CODE <= "10001";
    check_signals("POP", '1', '1', '0', "01", "000", '0', '0', "00", '1', '0', "01", '0', "10", "00", '0', "10", "00", '1', '0');

    -- Test LDM (10010)
    OP_CODE <= "10010";
    check_signals("LDM", '0', '1', '1', "10", "110", '0', '0', "00", '1', '0', "00", '0', "10", "00", '0', "00", "00", '1', '0');

    -- Test LDD (10011)
    OP_CODE <= "10011";
    check_signals("LDD", '0', '1', '1', "10", "001", '0', '0', "00", '1', '0', "00", '0', "11", "00", '0', "10", "01", '1', '0');

    -- Test STD (10100)
    OP_CODE <= "10100";
    check_signals("STD", '0', '1', '1', "10", "001", '0', '0', "00", '1', '0', "00", '0', "11", "10", '1', "00", "00", '0', '0');

    -- Test CALL (11000)
    OP_CODE <= "11000";
    check_signals("CALL", '0', '1', '1', "01", "000", '0', '1', "00", '1', '0', "10", '0', "01", "00", '1', "00", "00", '0', '0');

    -- Test RET (11001)
    OP_CODE <= "11001";
    check_signals("RET", '1', '1', '0', "01", "000", '0', '1', "00", '1', '0', "01", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test INT (11010)
    OP_CODE <= "11010";
    check_signals("INT", '1', '1', '0', "01", "000", '0', '1', "00", '1', '0', "10", '1', "01", "00", '1', "00", "00", '0', '1');

    -- Test RTI (11011)
    OP_CODE <= "11011";
    check_signals("RTI", '1', '1', '0', "01", "000", '0', '1', "00", '1', '0', "01", '0', "10", "00", '0', "10", "00", '0', '1');

    -- Test JZ (11100)
    OP_CODE <= "11100";
    check_signals("JZ", '0', '1', '1', "01", "000", '0', '1', "01", '1', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test JN (11101)
    OP_CODE <= "11101";
    check_signals("JN", '0', '1', '1', "01", "000", '0', '1', "11", '1', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test JC (11110)
    OP_CODE <= "11110";
    check_signals("JC", '0', '1', '1', "01", "000", '0', '1', "10", '1', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Test JMP (11111)
    OP_CODE <= "11111";
    check_signals("JMP", '0', '1', '1', "01", "000", '0', '1', "00", '1', '0', "00", '0', "10", "00", '0', "00", "00", '0', '0');

    -- Summary
    WAIT FOR CLK_PERIOD * 2;
    WRITE(L, STRING'("========================================"));
    WRITELINE(OUTPUT, L);
    WRITE(L, STRING'("  Test Summary"));
    WRITELINE(OUTPUT, L);
    WRITE(L, STRING'("========================================"));
    WRITELINE(OUTPUT, L);
    WRITE(L, STRING'("  Total Tests: "));
    WRITE(L, test_count);
    WRITELINE(OUTPUT, L);
    WRITE(L, STRING'("  Total Errors: "));
    WRITE(L, errors);
    WRITELINE(OUTPUT, L);
    
    IF errors = 0 THEN
      WRITE(L, STRING'("  >>> ALL TESTS PASSED! <<<"));
      WRITELINE(OUTPUT, L);
    ELSE
      WRITE(L, STRING'("  >>> SOME TESTS FAILED <<<"));
      WRITELINE(OUTPUT, L);
    END IF;
    
    WRITE(L, STRING'("========================================"));
    WRITELINE(OUTPUT, L);
    
    WAIT;
  END PROCESS;

END ARCHITECTURE TB;
