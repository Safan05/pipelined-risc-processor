LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CU IS
  PORT (
    CLK, RST, INT_SIG : IN STD_LOGIC;
    OP_CODE_IN : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- # Decode Stage Signals
    RD_EN : OUT STD_LOGIC;

    -- # Execute Stage Signals
    ALU_SRC : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALU_OP : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    SET_CARRY, BRANCH : OUT STD_LOGIC;
    BRANCH_T : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    PC_WE, OUT_EN, IMM_SIG : OUT STD_LOGIC;
    SP_OP : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    SP_OR_R1 : OUT STD_LOGIC;           -- 1 = use SP as ALU src1, 0 = use R1
    SP_WRT_EN : OUT STD_LOGIC;          -- SP register write enable

    -- # Memory Stage Signals
    PC_SEL, MEM_WRT_EN : OUT STD_LOGIC;
    MEM_ADDR, MEM_WRT_DATA : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- # Write Back Stage Signals
    WB_DATA, WB_ADDR : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    REG_WRT_EN, SWAP_SIG : OUT STD_LOGIC
  );
END ENTITY CU;

ARCHITECTURE RTL OF CU IS
  TYPE cu_state_type IS (IDLE, SWAP_CYCLE_2, INT_CYCLE_2, RTI_CYCLE_2, IMM_FETCH, HLT);
  SIGNAL state, next_state : cu_state_type := IDLE;
  -- Internal signal for RD_NXT_INST tracking
  SIGNAL RD_NXT_INST_INT : STD_LOGIC;

  -- Alias OP_CODE to OP_CODE_IN to break combinational loop
  SIGNAL OP_CODE : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN
  OP_CODE <= OP_CODE_IN;
  
  -- RD_NXT_INST_INT is internal only, not exposed as output

  PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      state <= IDLE;
    ELSIF RISING_EDGE(CLK) THEN
      state <= next_state;
    END IF;
  END PROCESS;

  PROCESS (OP_CODE_IN, INT_SIG, state)
    VARIABLE group_bits : STD_LOGIC_VECTOR(1 DOWNTO 0);
    VARIABLE sub_bits : STD_LOGIC_VECTOR(2 DOWNTO 0);
    VARIABLE is_group_00, is_group_01, is_group_10, is_group_11, is_iadd : BOOLEAN;
  BEGIN
    group_bits := OP_CODE_IN(4 DOWNTO 3);
    sub_bits := OP_CODE_IN(2 DOWNTO 0);

    is_group_00 := (group_bits = "00");
    is_group_01 := (group_bits = "01");
    is_group_10 := (group_bits = "10");
    is_group_11 := (group_bits = "11");
    is_iadd := (OP_CODE_IN = "01101");

    -- Default values for next_state
    next_state <= state;

    CASE state IS

          -- # CYCLE 2: SWAP #
          -- In cycle 1, Rsrc2 (R5) value was written to Rsrc1 (R6) via ALU pass-through
          -- In cycle 2, original Rsrc1 (R6) value (READ_DATA_1) should be written to Rsrc2 (R5)
          -- The instruction is still in decode (PC was stalled in cycle 1)
        WHEN SWAP_CYCLE_2 =>
          -- Data selection: "11" = READ_DATA_1 (the original Rsrc1 value read in cycle 1)
          WB_DATA <= "00";
          -- Address selection: "01" = Rsrc2 address (write original Rsrc1 to Rsrc2)
          WB_ADDR <= "00";
          REG_WRT_EN <= '1';
          SWAP_SIG <= '0';
          -- ALU control (not really used since WB_DATA selects READ_DATA_1)
          ALU_SRC <= "01";   -- REG_DATA2
          ALU_OP <= "111";   -- Pass B
          -- Allow pipeline to continue
          RD_NXT_INST_INT <= '1';
          PC_WE <= '1';
          -- Disable other operations
          RD_EN <= '1';  -- Keep reading registers (READ_DATA_1 will flow through)
          IMM_SIG <= '0';
          SET_CARRY <= '0';
          BRANCH <= '0';
          BRANCH_T <= "00";
          OUT_EN <= '0';
          PC_SEL <= '0';
          MEM_WRT_EN <= '0';
          MEM_ADDR <= "00";
          MEM_WRT_DATA <= "00";
          SP_OP <= "00";
          SP_OR_R1 <= '0';
          SP_WRT_EN <= '0';
          next_state <= IDLE;

          -- # CYCLE 2: INT (PUSH FLAGS) #
        WHEN INT_CYCLE_2 =>
          SP_OP <= "10"; -- PUSH (Decrement) [Matches Excel '10']
          MEM_WRT_EN <= '1';
          MEM_ADDR <= "01"; -- SP Address
          MEM_WRT_DATA <= "11"; -- Select FLAGS [Matches Excel Encoding '11']
          PC_WE <= '0';
          SWAP_SIG <= '0';
          next_state <= IDLE;

          -- # CYCLE 2: RTI (POP PC) #
        WHEN RTI_CYCLE_2 =>
          SP_OP <= "01"; -- POP (Increment) [Matches Excel '01']
          -- Note: Data read from memory goes to PC automatically via datapath wiring for RET/RTI
          SWAP_SIG <= '0';
          next_state <= IDLE;

          -- # IMM_FETCH: Immediate word is in IF/ID #
          -- Output complete NOP control signals for the immediate word
        WHEN IMM_FETCH =>
          RD_NXT_INST_INT <= '1';
          RD_EN <= '0';  -- Don't read from register file
          IMM_SIG <= '0';
          BRANCH <= '0';
          next_state <= IDLE;

          -- # HLT: Halt execution #
          -- Freeze PC and pipeline until reset
        WHEN HLT =>
          PC_WE <= '0';
          RD_EN <= '0';
          IMM_SIG <= '0';
          BRANCH <= '0';
          REG_WRT_EN <= '0';
          MEM_WRT_EN <= '0';
          OUT_EN <= '0';
          -- Keep all other signals at safe defaults
          ALU_SRC <= "00";
          ALU_OP <= "000";
          SET_CARRY <= '0';
          BRANCH_T <= "00";
          OUT_EN <= '0';
          PC_SEL <= '0';
          MEM_ADDR <= "00";
          MEM_WRT_DATA <= "00";
          WB_DATA <= "00";
          WB_ADDR <= "00";
          SWAP_SIG <= '0';
          SP_OP <= "00";
          SP_OR_R1 <= '0';
          SP_WRT_EN <= '0';
          next_state <= HLT;  -- Stay in HLT until reset

          -- # CYCLE 1 / NORMAL INSTRUCTIONS #
        WHEN OTHERS =>
        -- default signal values
          RD_NXT_INST_INT <= '1';
          IMM_SIG <= '0';
          SET_CARRY <= '0';
          BRANCH <= '0';
          PC_WE <= '1';
          OUT_EN <= '0';
          PC_SEL <= '0';
          MEM_WRT_EN <= '0';
          SWAP_SIG <= '0';
          REG_WRT_EN <= '0';
          WB_DATA <= (OTHERS => '0');
          WB_ADDR <= (OTHERS => '0');
          SP_OP <= "00";
          SP_OR_R1 <= '0';   -- Default: use R1 as ALU src1
          SP_WRT_EN <= '0';  -- Default: don't write to SP

          -- RD_NXT_INST Logic - 2-word instructions (state transition handled later)
          IF is_iadd OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) OR
            (is_group_11 AND NOT (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
            RD_NXT_INST_INT <= '0'; -- 2-word instruction
            IMM_SIG <= '1';
          ELSE
            RD_NXT_INST_INT <= '1';
            IMM_SIG <= '0';
          END IF;

          RD_EN <= '1';

          -- Execute Stage
          IF OP_CODE_IN = "00110" THEN
            ALU_SRC <= "11"; -- IN Instruction
          ELSIF is_iadd OR OP_CODE_IN = "10010" OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) THEN
            ALU_SRC <= "10"; -- Immediate (LDM, IADD, LDD, STD)
          ELSIF is_group_00 AND sub_bits = "100" THEN
            ALU_SRC <= "00";
          ELSE
            ALU_SRC <= "01";
          END IF;

          -- ALU Op
          IF is_group_00 AND sub_bits = "011" THEN
            ALU_OP <= "101";
          ELSIF (is_group_01 AND sub_bits = "000") OR (OP_CODE_IN = "10000") OR (OP_CODE_IN = "00101") THEN
            ALU_OP <= "110"; -- Pass A
          ELSIF OP_CODE_IN = "10010" OR (is_group_01 AND sub_bits = "001") THEN
             ALU_OP <= "111"; 
          ELSIF is_group_01 AND sub_bits = "011" THEN
            ALU_OP <= "010";
          ELSIF is_group_01 AND sub_bits = "100" THEN
            ALU_OP <= "100";
          ELSIF (is_group_01 AND sub_bits = "010") OR is_iadd OR (OP_CODE_IN = "00100") OR (is_group_10 AND (sub_bits = "011" OR sub_bits = "100")) THEN
            ALU_OP <= "001";
          ELSE
            ALU_OP <= "000";
          END IF;

          IF OP_CODE_IN = "00010" THEN
            SET_CARRY <= '1';
          ELSE
            SET_CARRY <= '0';
          END IF;
          IF is_group_11 THEN
            BRANCH <= '1';
          ELSE
            BRANCH <= '0';
          END IF;

          -- Branch Type
          IF OP_CODE_IN = "11101" THEN
            BRANCH_T <= "11";
          ELSIF OP_CODE_IN = "11110" THEN
            BRANCH_T <= "10";
          ELSIF OP_CODE_IN = "11100" THEN
            BRANCH_T <= "01";
          ELSE
            BRANCH_T <= "00";
          END IF;

          IF OP_CODE_IN = "00001" THEN
            PC_WE <= '0';
          ELSE
            PC_WE <= '1';
          END IF;
          IF OP_CODE_IN = "00101" THEN
            OUT_EN <= '1';
          ELSE
            OUT_EN <= '0';
          END IF;

          -- Stack Pointer Ops (UPDATED TO MATCH EXCEL)
          -- POP (01), PUSH (10)
          IF OP_CODE_IN = "11011" OR OP_CODE_IN = "11001" OR OP_CODE_IN = "10001" THEN
            SP_OP <= "01"; -- POP (increment)
          ELSIF OP_CODE_IN = "10000" OR OP_CODE_IN = "11000" OR OP_CODE_IN = "11010" THEN
            SP_OP <= "10"; -- PUSH (decrement)
          ELSE
            SP_OP <= "00";
          END IF;

          -- SP_OR_R1: Use SP as ALU first operand for stack operations
          -- PUSH=10000, POP=10001, CALL=11000, RET=11001, INT=11010, RTI=11011
          IF OP_CODE_IN = "10000" OR OP_CODE_IN = "10001" OR OP_CODE_IN = "11000" OR 
             OP_CODE_IN = "11001" OR OP_CODE_IN = "11010" OR OP_CODE_IN = "11011" THEN
            SP_OR_R1 <= '1';  -- Use SP as ALU src1
          ELSE
            SP_OR_R1 <= '0';  -- Use R1 as ALU src1
          END IF;

          -- SP_WRT_EN: Enable SP write for stack operations
          IF OP_CODE_IN = "10000" OR OP_CODE_IN = "10001" OR OP_CODE_IN = "11000" OR 
             OP_CODE_IN = "11001" OR OP_CODE_IN = "11010" OR OP_CODE_IN = "11011" THEN
            SP_WRT_EN <= '1';  -- Write new SP value
          ELSE
            SP_WRT_EN <= '0';
          END IF;

          -- Memory Stage
          -- PC_SEL: Set for ALL branch/jump instructions (group 11)
          -- JMP=11111, JZ=11100, JN=11101, JC=11110, etc.
          IF is_group_11 THEN
            PC_SEL <= '1';
          ELSE
            PC_SEL <= '0';
          END IF;

          IF OP_CODE_IN = "10000" OR OP_CODE_IN = "10100" OR OP_CODE_IN = "11000" OR OP_CODE_IN = "11010" THEN
            MEM_WRT_EN <= '1';
          ELSE
            MEM_WRT_EN <= '0';
          END IF;

          -- MEM_ADDR encoding in memAddrSelector:
          -- "00" = pc_addr, "01" = sp_buffer (OLD SP), "10" = sp+1 (for POP), "11" = alu_addr
          IF OP_CODE_IN = "10000" OR OP_CODE_IN = "11000" OR OP_CODE_IN = "11010" THEN
            MEM_ADDR <= "01"; -- PUSH/CALL/INT: write to OLD SP
          ELSIF OP_CODE_IN = "10001" THEN
            MEM_ADDR <= "10"; -- POP: read from OLD SP + 1 (after increment)
          ELSIF OP_CODE_IN = "10011" OR OP_CODE_IN = "10100" THEN
            MEM_ADDR <= "11"; -- LDD/STD: use ALU address
          ELSE
            MEM_ADDR <= "00";
          END IF;

          -- Memory Write Data (MATCHES memoryStage MUX)
          -- 00=PC_IN, 01=PC_INC_IN, 10=SP_IN, 11=REG_DATA2_IN
          IF OP_CODE_IN = "10000" OR OP_CODE_IN = "10100" THEN
            MEM_WRT_DATA <= "11"; -- REG_DATA2 (PUSH, STD)
          ELSE
            MEM_WRT_DATA <= "00";
          END IF;


          -- R1,R2   
          --first  cycle:     1) R2->alu     2) R1->R2
          --second cycle:     3) alu -> R1

          -- Write Back Stage
          IF OP_CODE_IN = "00110" THEN
            WB_DATA <= "01"; -- IN
          ELSIF OP_CODE_IN = "10010" THEN
            WB_DATA <= "00"; -- ALU (LDM - Immediate goes through ALU Pass B)
           ELSIF is_group_10 AND (sub_bits = "001" OR sub_bits = "011") THEN
            WB_DATA <= "10"; -- MEM (LDD, POP) [Matches Excel '10']
          ELSIF OP_CODE_IN = "11011" THEN
            WB_DATA <= "10"; -- MEM (RTI - Pop Flags)
          ELSIF OP_CODE_IN = "01001" THEN
            WB_DATA <= "11"; -- SWAP
          ELSE
            WB_DATA <= "00";
          END IF;

          -- WB_ADDR: 00=Rsrc1, 01=Rsrc2, 10=Rdst
          -- SWAP cycle 1 uses "00" (Rsrc1), cycle 2 uses "01" (Rsrc2) - see SWAP_CYCLE_2
          IF OP_CODE_IN = "10011" OR (is_group_01 AND (sub_bits = "000" OR sub_bits = "101")) THEN
            WB_ADDR <= "01";  -- LDD/POP/MOV/NOT: write to Rsrc2
          ELSIF OP_CODE_IN = "01001" THEN
            WB_ADDR <= "01";  -- SWAP cycle 1: write to Rsrc1 (R6)
          ELSIF is_group_01 AND (sub_bits = "010" OR sub_bits = "011" OR sub_bits = "100") THEN
            WB_ADDR <= "10";  -- SUB/AND/ADD: write to Rdst
          ELSE
            WB_ADDR <= "00";  -- Default: Rsrc1
          END IF;

          IF is_group_01 OR (is_group_00 AND (sub_bits = "011" OR sub_bits = "100" OR sub_bits = "110")) OR
            (is_group_10 AND (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
            REG_WRT_EN <= '1';
          ELSE
            REG_WRT_EN <= '0';
          END IF;

          -- State Triggers
          IF OP_CODE_IN = "00001" THEN -- HLT
            next_state <= HLT;

          ELSIF OP_CODE_IN = "01001" THEN -- SWAP
            SWAP_SIG <= '1';
            PC_WE <= '0';  -- Stall PC so instruction stays in decode for cycle 2
            next_state <= SWAP_CYCLE_2;

          ELSIF OP_CODE_IN = "11010" THEN -- INT
            SWAP_SIG <= '1';
            next_state <= INT_CYCLE_2;

          ELSIF OP_CODE_IN = "11011" THEN -- RTI
            SWAP_SIG <= '1';
            next_state <= RTI_CYCLE_2;

          -- 2-word instructions (LDM, IADD, etc.) - transition to IMM_FETCH
          ELSIF is_iadd OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) OR
            (is_group_11 AND NOT (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
            SWAP_SIG <= '0';
            next_state <= IMM_FETCH;

          ELSE
            SWAP_SIG <= '0';
            next_state <= IDLE;
          END IF;

      END CASE;
  END PROCESS;

END ARCHITECTURE;