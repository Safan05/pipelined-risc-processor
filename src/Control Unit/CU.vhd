LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY CU is 
  PORT (
    CLK, RST , INT_SIG: IN STD_LOGIC; 
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
    REG_WRT_EN, STALL_SIG: OUT STD_LOGIC
  ); 
END ENTITY CU;

ARCHITECTURE RTL OF CU IS
  TYPE cu_state_type IS (IDLE, SWAP_CYCLE_2, INT_CYCLE_2, RTI_CYCLE_2);
  SIGNAL state, next_state : cu_state_type;
BEGIN

  PROCESS (CLK, RST)
  BEGIN
    IF RST = '1' THEN
      state <= IDLE;
    ELSIF RISING_EDGE(CLK) THEN
      state <= next_state;
    END IF;
  END PROCESS;

  PROCESS (OP_CODE, INT_SIG, state)
    VARIABLE group_bits : STD_LOGIC_VECTOR(1 DOWNTO 0);
    VARIABLE sub_bits   : STD_LOGIC_VECTOR(2 DOWNTO 0);
    VARIABLE is_group_00, is_group_01, is_group_10, is_group_11, is_iadd : BOOLEAN;
  BEGIN
    group_bits := OP_CODE(4 DOWNTO 3);
    sub_bits   := OP_CODE(2 DOWNTO 0);
    
    is_group_00 := (group_bits = "00");
    is_group_01 := (group_bits = "01");
    is_group_10 := (group_bits = "10");
    is_group_11 := (group_bits = "11");
    is_iadd     := (OP_CODE = "01101");

    IF OP_CODE = "00000" THEN -- Immediate data
      RD_NXT_INST <= '1'; RD_EN <= '0'; IMM_SIG <= '0';
    ELSE
      
      CASE state IS
        
        -- # CYCLE 2: SWAP #
        WHEN SWAP_CYCLE_2 =>
            WB_DATA     <= "01"; 
            WB_ADDR     <= "00"; 
            REG_WRT_EN  <= '1';
            STALL_SIG    <= '0'; 
            next_state  <= IDLE;

        -- # CYCLE 2: INT (PUSH FLAGS) #
        WHEN INT_CYCLE_2 =>
            SP_OP       <= "10"; -- PUSH (Decrement) [Matches Excel '10']
            MEM_WRT_EN  <= '1';  
            MEM_ADDR    <= "01"; -- SP Address
            MEM_WRT_DATA<= "11"; -- Select FLAGS [Matches Excel Encoding '11']
            PC_WE       <= '0';  
            STALL_SIG    <= '0';  
            next_state  <= IDLE;

        -- # CYCLE 2: RTI (POP PC) #
        WHEN RTI_CYCLE_2 =>
            SP_OP       <= "01"; -- POP (Increment) [Matches Excel '01']
            -- Note: Data read from memory goes to PC automatically via datapath wiring for RET/RTI
            STALL_SIG    <= '0';  
            next_state  <= IDLE;

        -- # CYCLE 1 / NORMAL INSTRUCTIONS #
        WHEN OTHERS =>
            
            -- Defaults
            next_state  <= IDLE; 
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
            STALL_SIG   <= '0';


            -- RD_NXT_INST Logic
            IF is_iadd OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) OR 
               (is_group_11 AND NOT (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
              RD_NXT_INST <= '0'; -- Immediate
              IMM_SIG     <= '1';
            ELSE
              RD_NXT_INST <= '1';
              IMM_SIG     <= '0';
            END IF;
            
            RD_EN <= '1';

            -- Execute Stage
            IF OP_CODE = "00110" THEN
              ALU_SRC <= "11"; -- IN Instruction
            ELSIF is_iadd OR (is_group_10 AND (sub_bits(2) = '1' OR sub_bits = "010" OR sub_bits = "011")) THEN
              ALU_SRC <= "10";
            ELSIF is_group_00 AND sub_bits = "100" THEN
              ALU_SRC <= "00";
            ELSE
              ALU_SRC <= "01";
            END IF;
            
            -- ALU Op
            IF is_group_00 AND sub_bits = "011" THEN ALU_OP <= "101";
            ELSIF (is_group_01 AND sub_bits = "000") OR (OP_CODE = "10000") OR (OP_CODE = "10010") THEN ALU_OP <= "110";
            ELSIF is_group_01 AND sub_bits = "001" THEN ALU_OP <= "111"; 
            ELSIF is_group_01 AND sub_bits = "011" THEN ALU_OP <= "010";
            ELSIF is_group_01 AND sub_bits = "100" THEN ALU_OP <= "100";
            ELSIF (is_group_01 AND sub_bits = "010") OR is_iadd OR (OP_CODE = "00100") OR (is_group_10 AND (sub_bits = "011" OR sub_bits = "100")) THEN ALU_OP <= "001";
            ELSE ALU_OP <= "000"; END IF;

            IF OP_CODE = "00010" THEN SET_CARRY <= '1'; ELSE SET_CARRY <= '0'; END IF;
            IF is_group_11 THEN BRANCH <= '1'; ELSE BRANCH <= '0'; END IF;

            -- Branch Type
            IF OP_CODE = "11101" THEN BRANCH_T <= "11";
            ELSIF OP_CODE = "11110" THEN BRANCH_T <= "10";
            ELSIF OP_CODE = "11100" THEN BRANCH_T <= "01";
            ELSE BRANCH_T <= "00"; END IF;

            IF OP_CODE = "00001" THEN PC_WE <= '0'; ELSE PC_WE <= '1'; END IF;
            IF OP_CODE = "00101" THEN OUT_EN <= '1'; ELSE OUT_EN <= '0'; END IF;

            -- Stack Pointer Ops (UPDATED TO MATCH EXCEL)
            -- POP (01), PUSH (10)
            IF OP_CODE = "11011" OR OP_CODE = "11001" OR OP_CODE = "10001" THEN SP_OP <= "01"; -- POP
            ELSIF OP_CODE = "10000" OR OP_CODE = "11000" OR OP_CODE = "11010" THEN SP_OP <= "10"; -- PUSH
            ELSE SP_OP <= "00"; END IF;

            -- Memory Stage
            IF OP_CODE = "11010" THEN PC_SEL <= '1'; ELSE PC_SEL <= '0'; END IF;

            IF OP_CODE = "10000" OR OP_CODE = "10100" OR OP_CODE = "11000" OR OP_CODE = "11010" THEN MEM_WRT_EN <= '1';
            ELSE MEM_WRT_EN <= '0'; END IF;

            IF OP_CODE = "10000" OR OP_CODE = "11000" OR OP_CODE = "11010" THEN MEM_ADDR <= "01"; -- SP
            ELSIF OP_CODE = "10011" OR OP_CODE = "10100" THEN MEM_ADDR <= "11"; -- Imm
            ELSE MEM_ADDR <= "10"; END IF;

            -- Memory Write Data (UPDATED TO MATCH EXCEL)
            IF OP_CODE = "10000" OR OP_CODE = "10100" THEN 
               MEM_WRT_DATA <= "10"; -- Rd1 (PUSH, STD) [Matches Excel '10']
            ELSE 
               MEM_WRT_DATA <= "00"; 
            END IF;

            -- Write Back Stage
            IF OP_CODE = "00110" THEN WB_DATA <= "01"; -- IN
            ELSIF is_group_10 AND (sub_bits = "001" OR sub_bits = "011") THEN WB_DATA <= "10"; -- MEM (LDD, POP) [Matches Excel '10']
            ELSIF OP_CODE = "11011" THEN WB_DATA <= "10"; -- MEM (RTI - Pop Flags)
            ELSE WB_DATA <= "00"; END IF;

            IF OP_CODE = "10011" OR (is_group_01 AND (sub_bits = "000" OR sub_bits = "001" OR sub_bits = "101")) THEN WB_ADDR <= "01";
            ELSIF is_group_01 AND (sub_bits = "010" OR sub_bits = "011" OR sub_bits = "100") THEN WB_ADDR <= "10";
            ELSE WB_ADDR <= "00"; END IF;
            
            IF is_group_01 OR (is_group_00 AND (sub_bits = "011" OR sub_bits = "100" OR sub_bits = "110")) OR
               (is_group_10 AND (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) THEN
              REG_WRT_EN <= '1';
            ELSE
              REG_WRT_EN <= '0';
            END IF;

            -- State Triggers
            IF OP_CODE = "01001" THEN -- SWAP
               STALL_SIG    <= '1';
               next_state  <= SWAP_CYCLE_2;
            
            ELSIF OP_CODE = "11010" THEN -- INT
               STALL_SIG    <= '1';
               next_state  <= INT_CYCLE_2;

            ELSIF OP_CODE = "11011" THEN -- RTI
               STALL_SIG    <= '1';
               next_state  <= RTI_CYCLE_2;

            ELSE
               STALL_SIG    <= '0';
               next_state  <= IDLE;
            END IF;

      END CASE;
    END IF; 
  END PROCESS;

END ARCHITECTURE;