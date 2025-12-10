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
  -- Instruction opcodes
  CONSTANT NOP    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
  CONSTANT HLT    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00001";
  CONSTANT SETC   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00010";
  CONSTANT NOT_OP : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00011";
  CONSTANT INC_OP : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00100";
  CONSTANT MOV    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00101";
  CONSTANT ADD    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00110";
  CONSTANT SUB    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00111";
  CONSTANT AND_OP : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01000";
  CONSTANT IADD   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01001";
  CONSTANT LDM    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01010";
  CONSTANT LDD    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01011";
  CONSTANT STD    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01100";
  CONSTANT PUSH   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01101";
  CONSTANT POP    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01110";
  CONSTANT JZ     : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01111";
  CONSTANT JN     : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10000";
  CONSTANT JMP    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10001";
  CONSTANT CALL   : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10010";
  CONSTANT RET    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10011";
  CONSTANT RTI    : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10100";
  CONSTANT INT_OP : STD_LOGIC_VECTOR(4 DOWNTO 0) := "10101";

BEGIN

  -- Combinational Control Logic
  PROCESS (OP_CODE, INT)
  BEGIN
    -- Default values (prevent latches)
    RD_NXT_INST <= '1';
    RD_EN <= '1';
    ALU_SRC <= "00";
    ALU_OP <= "000";
    SET_CARRY <= '0';
    BRANCH <= '0';
    BRANCH_T <= "00";
    PC_WE <= '0';
    OUT_EN <= '0';
    IMM_SIG <= '0';
    SP_OP <= "00";
    PC_SEL <= '0';
    MEM_WRT_EN <= '0';
    MEM_ADDR <= "00";
    MEM_WRT_DATA <= "00";
    WB_DATA <= "00";
    WB_ADDR <= "00";
    REG_WRT_EN <= '0';
    SWAP_SIG <= '0';

    CASE OP_CODE IS
      -- NOP: No Operation
      WHEN NOP =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';

      -- HLT: Halt
      WHEN HLT =>
        RD_NXT_INST <= '0';
        RD_EN <= '0';

      -- SETC: Set Carry
      WHEN SETC =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        SET_CARRY <= '1';

      -- NOT: Bitwise NOT
      WHEN NOT_OP =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        ALU_SRC <= "00";
        ALU_OP <= "001";
        REG_WRT_EN <= '1';
        WB_DATA <= "01";

      -- INC: Increment
      WHEN INC_OP =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        ALU_SRC <= "00";
        ALU_OP <= "010";
        REG_WRT_EN <= '1';
        WB_DATA <= "01";

      -- MOV: Move Register
      WHEN MOV =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        WB_DATA <= "11";
        REG_WRT_EN <= '1';

      -- ADD: Addition
      WHEN ADD =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        ALU_SRC <= "00";
        ALU_OP <= "011";
        REG_WRT_EN <= '1';
        WB_DATA <= "01";

      -- SUB: Subtraction
      WHEN SUB =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        ALU_SRC <= "00";
        ALU_OP <= "100";
        REG_WRT_EN <= '1';
        WB_DATA <= "01";

      -- AND: Bitwise AND
      WHEN AND_OP =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        ALU_SRC <= "00";
        ALU_OP <= "101";
        REG_WRT_EN <= '1';
        WB_DATA <= "01";

      -- IADD: Immediate Add
      WHEN IADD =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        ALU_SRC <= "01";
        ALU_OP <= "011";
        IMM_SIG <= '1';
        REG_WRT_EN <= '1';
        WB_DATA <= "01";

      -- LDM: Load Immediate
      WHEN LDM =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        IMM_SIG <= '1';
        REG_WRT_EN <= '1';
        WB_DATA <= "10";

      -- LDD: Load from Memory
      WHEN LDD =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        MEM_ADDR <= "01";
        REG_WRT_EN <= '1';
        WB_DATA <= "00";

      -- STD: Store to Memory
      WHEN STD =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        MEM_WRT_EN <= '1';
        MEM_ADDR <= "01";
        MEM_WRT_DATA <= "01";

      -- PUSH: Push to Stack
      WHEN PUSH =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        SP_OP <= "01";
        MEM_WRT_EN <= '1';
        MEM_ADDR <= "10";
        MEM_WRT_DATA <= "01";

      -- POP: Pop from Stack
      WHEN POP =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';
        SP_OP <= "10";
        MEM_ADDR <= "10";
        REG_WRT_EN <= '1';
        WB_DATA <= "00";

      -- JZ: Jump if Zero
      WHEN JZ =>
        RD_NXT_INST <= '0';
        RD_EN <= '1';
        BRANCH <= '1';
        BRANCH_T <= "01";

      -- JN: Jump if Negative
      WHEN JN =>
        RD_NXT_INST <= '0';
        RD_EN <= '1';
        BRANCH <= '1';
        BRANCH_T <= "10";

      -- JMP: Unconditional Jump
      WHEN JMP =>
        RD_NXT_INST <= '0';
        RD_EN <= '1';
        BRANCH <= '1';
        BRANCH_T <= "00";

      -- CALL: Call Subroutine
      WHEN CALL =>
        RD_NXT_INST <= '0';
        RD_EN <= '1';
        BRANCH <= '1';
        BRANCH_T <= "00";
        SP_OP <= "01";
        MEM_WRT_EN <= '1';
        MEM_ADDR <= "10";
        MEM_WRT_DATA <= "00";

      -- RET: Return from Subroutine
      WHEN RET =>
        RD_NXT_INST <= '0';
        RD_EN <= '1';
        BRANCH <= '1';
        BRANCH_T <= "11";
        SP_OP <= "10";
        PC_SEL <= '1';
        MEM_ADDR <= "10";

      -- RTI: Return from Interrupt
      WHEN RTI =>
        RD_NXT_INST <= '0';
        RD_EN <= '1';
        BRANCH <= '1';
        BRANCH_T <= "11";
        SP_OP <= "11";
        PC_SEL <= '1';
        MEM_ADDR <= "10";

      -- INT: Software Interrupt
      WHEN INT_OP =>
        RD_NXT_INST <= '1';
        RD_EN <= '0';
        SP_OP <= "01";
        MEM_WRT_EN <= '1';
        MEM_ADDR <= "10";
        MEM_WRT_DATA <= "10";

      -- Default case
      WHEN OTHERS =>
        RD_NXT_INST <= '1';
        RD_EN <= '1';

    END CASE;
  END PROCESS;

END ARCHITECTURE;