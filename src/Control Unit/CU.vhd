LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CU is 
  PORT (
    CLK, RST , INT: IN STD_LOGIC;
    OP_CODE: IN STD_LOGIC_VECTOR(4 DOWNTO 0);

    -- # Decode Stage Signals
    RD_NXT_INST, RD_EN: OUT STD_LOGIC;

    -- # Execute Stage Signals
    ALU_SRC:  OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    ALU_OP:   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    SET_CARRY, BRANCH: OUT STD_LOGIC;
    BRANCH_T: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    PC_WE, OUT_EN, IMM_SIG: OUT STD_LOGIC;
    SP_OP:    OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- # Memory Stage Signals
    PC_SEL, MEM_WRT_EN: OUT STD_LOGIC;
    MEM_ADDR, MEM_WRT_DATA: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- # Write Back Stage Signals
    WB_DATA, WB_ADDR: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
    REG_WRT_EN, SWAP_SIG: OUT STD_LOGIC
  ); 
END ENTITY CU;

ARCHITECTURE RTL OF CU IS

BEGIN

  -- Combinational Control Logic Process
  PROCESS (OP_CODE, INT)
    -- Local variables for instruction grouping
    VARIABLE group_bits : STD_LOGIC_VECTOR(1 DOWNTO 0);
    VARIABLE sub_bits   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    VARIABLE is_group_00 : BOOLEAN;
    VARIABLE is_group_01 : BOOLEAN;
    VARIABLE is_group_10 : BOOLEAN;
    VARIABLE is_group_11 : BOOLEAN;
    VARIABLE is_iadd     : BOOLEAN;
  BEGIN
    -- Extract bit groups
    group_bits := OP_CODE(4 DOWNTO 3);
    sub_bits   := OP_CODE(2 DOWNTO 0);
    
    -- Decode instruction groups
    is_group_00 := (group_bits = "00");
    is_group_01 := (group_bits = "01");
    is_group_10 := (group_bits = "10");
    is_group_11 := (group_bits = "11");
    is_iadd     := (OP_CODE = "01101");

    -- Default values to prevent latches
    RD_NXT_INST <= '1';
    RD_EN       <= '1';
    ALU_SRC     <= "01";
    ALU_OP      <= "000";
    SET_CARRY   <= '0';
    BRANCH      <= '0';
    BRANCH_T    <= "00";
    PC_WE       <= '1';
    OUT_EN      <= '0';
    IMM_SIG     <= '0';
    SP_OP       <= "00";
    PC_SEL      <= '0';
    MEM_WRT_EN  <= '0';
    MEM_ADDR    <= "00";
    MEM_WRT_DATA<= "00";
    WB_DATA     <= "00";
    WB_ADDR     <= "00";
    REG_WRT_EN  <= '0';
    SWAP_SIG    <= '0';

    -- Handle NOP separately
    IF OP_CODE = "00000" THEN
      RD_NXT_INST <= '1';
      RD_EN <= '0';
      IMM_SIG <= '0';
    ELSE
      -- Decode Stage Signals
      IF is_iadd OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) OR 
         (is_group_11 AND NOT (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
        RD_NXT_INST <= '0';
        IMM_SIG <= '1';
      ELSE
        RD_NXT_INST <= '1';
        IMM_SIG <= '0';
      END IF;
      
    --//////////////////////////////////////////////////////
    -- // TODO: immediate instruction handling RD_EN <= 0
    --//////////////////////////////////////////////////////
      
      RD_EN <= '1';

      -- Execute Stage: ALU Source
      IF is_iadd OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) THEN
        ALU_SRC <= "10";
      ELSIF is_group_00 AND sub_bits = "100" THEN
        ALU_SRC <= "00";
      ELSE
        ALU_SRC <= "01";
      END IF;
      
      -- ALU Operation
      IF is_group_00 AND sub_bits = "011" THEN
        ALU_OP <= "101"; -- NOT
      ELSIF (is_group_01 AND sub_bits = "000") OR (OP_CODE = "10000") OR (OP_CODE = "10010") THEN
        ALU_OP <= "110"; -- MOV or PUSH
      ELSIF is_group_01 AND sub_bits = "001" THEN
        ALU_OP <= "111"; -- SWAP
      ELSIF is_group_01 AND sub_bits = "011" THEN
        ALU_OP <= "010"; -- SUB
      ELSIF is_group_01 AND sub_bits = "100" THEN
        ALU_OP <= "100"; -- AND
      ELSIF (is_group_01 AND sub_bits = "010") OR is_iadd OR (OP_CODE = "00100") OR (is_group_10 AND (sub_bits = "011" OR sub_bits = "100")) THEN
        ALU_OP <= "001"; -- ADD, IADD, INC
      ELSE
        ALU_OP <= "000";
      END IF;

      -- Set Carry
      IF OP_CODE = "00010" THEN
        SET_CARRY <= '1';
      ELSE
        SET_CARRY <= '0';
      END IF;
      
      -- Branch signals
      IF is_group_11 THEN
        BRANCH <= '1';
      ELSE
        BRANCH <= '0';
      END IF;

      -- Branch Type
      IF OP_CODE = "11101" THEN
        BRANCH_T <= "11"; -- JN
      ELSIF OP_CODE = "11110" THEN
        BRANCH_T <= "10"; -- JC
      ELSIF OP_CODE = "11100" THEN
        BRANCH_T <= "01"; -- JZ
      ELSE
        BRANCH_T <= "00";
      END IF;

      -- PC Write Enable
      IF OP_CODE = "00001" THEN
        PC_WE <= '0'; -- HLT
      ELSE
        PC_WE <= '1';
      END IF;
      
      -- Output Enable
      IF OP_CODE = "00101" THEN
        OUT_EN <= '1';
      ELSE
        OUT_EN <= '0';
      END IF;

      -- Stack Pointer Operation
      IF OP_CODE = "11011" OR OP_CODE = "11001" OR OP_CODE = "10001" THEN
        SP_OP <= "01"; -- RTI, RET, POP
      ELSIF OP_CODE = "10000" OR OP_CODE = "11000" OR OP_CODE = "11010" THEN
        SP_OP <= "11"; -- PUSH, CALL, INT
      ELSE
        SP_OP <= "00";
      END IF;

      -- Memory Stage: PC Select
      IF OP_CODE = "11010" THEN
        PC_SEL <= '1'; -- INT
      ELSE
        PC_SEL <= '0';
      END IF;

      -- Memory Write Enable
      IF OP_CODE = "10000" OR OP_CODE = "10100" OR OP_CODE = "11000" OR OP_CODE = "11010" THEN
        MEM_WRT_EN <= '1';
      ELSE
        MEM_WRT_EN <= '0';
      END IF;

      -- Memory Address
      IF OP_CODE = "10000" OR OP_CODE = "11000" OR OP_CODE = "11010" THEN
        MEM_ADDR <= "01"; -- CALL, INT, PUSH
      ELSIF OP_CODE = "10011" OR OP_CODE = "10100" THEN
        MEM_ADDR <= "11"; -- LDD, STD
      ELSE
        MEM_ADDR <= "10";
      END IF;

      -- Memory Write Data
      IF OP_CODE = "10000" OR OP_CODE = "10100" THEN
        MEM_WRT_DATA <= "10";
      ELSE
        MEM_WRT_DATA <= "00";
      END IF;

      -- Write Back Stage: Data Source
      IF OP_CODE = "00110" THEN
        WB_DATA <= "01"; -- IN
      ELSIF is_group_10 AND (sub_bits = "001" OR sub_bits = "011") THEN
        WB_DATA <= "10";
      ELSE
        WB_DATA <= "00";
      END IF;

      -- Write Back Address
      IF OP_CODE = "10011" OR (is_group_01 AND (sub_bits = "000" OR sub_bits = "001" OR sub_bits = "101")) THEN
        WB_ADDR <= "01";
      ELSIF is_group_01 AND (sub_bits = "010" OR sub_bits = "011" OR sub_bits = "100") THEN
        WB_ADDR <= "10";
      ELSE
        WB_ADDR <= "00";
      END IF;
      
      -- Register Write Enable
      IF is_group_01 OR 
         (is_group_00 AND (sub_bits = "011" OR sub_bits = "100" OR sub_bits = "110")) OR
         (is_group_10 AND (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
        REG_WRT_EN <= '1';
      ELSE
        REG_WRT_EN <= '0';
      END IF;

      -- Swap Signal
      IF OP_CODE = "01001" THEN
        SWAP_SIG <= '1';
      ELSE
        SWAP_SIG <= '0';
      END IF;
    END IF;
  END PROCESS;

END ARCHITECTURE;