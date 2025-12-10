-- LIBRARY IEEE;
-- USE IEEE.STD_LOGIC_1164.ALL;

-- ENTITY CU is 
--   PORT (
--     CLK, RST , INT: IN STD_LOGIC;
--     OP_CODE: IN STD_LOGIC_VECTOR(4 DOWNTO 0);

--     -- # Decode Stage Signals
--     RD_NXT_INST, RD_EN: OUT STD_LOGIC;

--     -- # Execute Stage Signals
--     ALU_SRC:  OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--     ALU_OP:   OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
--     SET_CARRY, BRANCH: OUT STD_LOGIC;
--     BRANCH_T: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--     PC_WE, OUT_EN, IMM_SIG: OUT STD_LOGIC;
--     SP_OP:    OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

--     -- # Memory Stage Signals
--     PC_SEL, MEM_WRT_EN: OUT STD_LOGIC;
--     MEM_ADDR, MEM_WRT_DATA: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

--     -- # Write Back Stage Signals
--     WB_DATA, WB_ADDR: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
--     REG_WRT_EN, SWAP_SIG: OUT STD_LOGIC
--   ); 
-- END ENTITY CU;

-- ARCHITECTURE RTL OF CU IS
--   -- Aliases for cleaner pattern matching
--   ALIAS group_bits : STD_LOGIC_VECTOR(1 DOWNTO 0) IS OP_CODE(4 DOWNTO 3);
--   ALIAS sub_bits   : STD_LOGIC_VECTOR(2 DOWNTO 0) IS OP_CODE(2 DOWNTO 0);

--   -- Decoded Groups
--   SIGNAL is_group_00 : BOOLEAN; -- Misc / Control
--   SIGNAL is_group_01 : BOOLEAN; -- ALU / Register
--   SIGNAL is_group_10 : BOOLEAN; -- Stack / Memory
--   SIGNAL is_group_11 : BOOLEAN; -- Branch / Interrupts

--   -- Specific helpers for exceptions
--   SIGNAL is_iadd     : BOOLEAN;
--   SIGNAL is_ret_rti  : BOOLEAN;

-- BEGIN
--   -- Group Decoding
--   is_group_00 <= (group_bits = "00");
--   is_group_01 <= (group_bits = "01");
--   is_group_10 <= (group_bits = "10");
--   is_group_11 <= (group_bits = "11");

--   -- Helpers
--   is_iadd    <= (OP_CODE = "01101"); -- IADD is the only Immediate ALU op
--   is_ret_rti <= (group_bits = "11") AND (sub_bits(1) = '0') AND (sub_bits(0) = '1'); -- RET(11001), RTI(11011)

--   -----------------------------------------------------------------------------
--   -- CONTROL SIGNALS
--   -----------------------------------------------------------------------------

--  if OP_CODE = "00000" then
--     -- immediate, leave the signals as it was
--     RD_NXT_INST <= '1';
--     RD_EN <= '0';
--     IMM_SIG <= '0';
-- else
    
--   -- # Decode Stage
--   -- Read Next Instruction:
--   -- Stop for: IADD (wait for imm), LDM/LDD/STD (mem access), Branch/Jumps/CALL (control hazard)
--   -- Allow for: Group 00, Group 01 (except IADD), PUSH/POP, RET/RTI/INT
--   RD_NXT_INST <= '0' WHEN is_iadd OR 
--                           (is_group_10 AND sub_bits(2) = '1') OR -- LDM, LDD, STD
--                           (is_group_11 AND NOT (sub_bits = "001" OR sub_bits = "010" OR sub_bits = "011")) -- JMP, CALL, Branches
--                      ELSE '1';
-- --//////////////////////////////////////////////////////
--   -- // TODO: immediate instruction handling RD_EN <= 0
-- --//////////////////////////////////////////////////////
--   RD_EN <= '1'; -- Always 1 in CSV (even for HLT)

--   -- # Execute Stage
--   -- ALU Source: IADD (10 - Reg/Imm) vs ADD/Others (01 - Reg/Reg) vs INC (00)
--   ALU_SRC <= "10" WHEN  is_iadd OR (is_group_10 AND sub_bits(2) = '1') ELSE -- LDM, LDD, STD m IADD 
--              "00" WHEN (is_group_00 AND sub_bits = "100") ELSE -- INC
--              "01"; -- Default (ADD, SUB, AND, SWAP)
  
--   -- ALU Opcode Mapping (Bit 2,1,0 patterns)
--   -- NOT(101), MOV/PUSH(110), SWAP(111), ADD/IADD/INC(001), SUB(010), AND(100)
--   ALU_OP <= "101" WHEN (is_group_00 AND sub_bits = "011") ELSE -- NOT
--             "110" WHEN (is_group_01 AND sub_bits = "000") OR (OP_CODE="10000") ELSE -- MOV or PUSH
--             "111" WHEN (is_group_01 AND sub_bits = "001") ELSE -- SWAP
--             "010" WHEN (is_group_01 AND sub_bits = "011") ELSE -- SUB
--             "100" WHEN (is_group_01 AND sub_bits = "100") ELSE -- AND
--             "001" WHEN (is_group_01 AND sub_bits = "010") OR is_iadd OR (OP_CODE="00100") ELSE -- ADD, IADD, INC
--             "000";

--   SET_CARRY <= '1' WHEN OP_CODE = "00010" ELSE '0'; -- SETC
  
--   -- Branch: Entire Group 11 is branches/jumps/interrupts
--   BRANCH    <= '1' WHEN is_group_11 ELSE '0';

--   -- Branch Type: JZ(01), JC(10), JN(11), Others(00)
--   BRANCH_T  <= "11" WHEN OP_CODE = "11101" ELSE -- JN
--                "10" WHEN OP_CODE = "11110" ELSE -- JC
--                "01" WHEN OP_CODE = "11100" ELSE -- JZ
--                "00";

--   PC_WE     <= '0' WHEN OP_CODE = "00001" ELSE '1'; -- HLT
--   OUT_EN    <= '1' WHEN OP_CODE = "00101" ELSE '0'; -- OUT
-- --   IMM_SIG   <= '1' WHEN is_iadd OR OP_CODE = "10010" ELSE '0'; -- IADD or LDM

--   SP_OP     <= "01" WHEN OP_CODE = "11011" OR OP_CODE = "11001" OR OP_CODE = "10001" ELSE -- RTI , RET , POP
--                "11" WHEN OP_CODE = "10000" OR OP_CODE = "11000" OR OP_CODE = "11010" ELSE -- PUSH, CALL, INT
--                "00";

--   -- # Memory Stage
--   PC_SEL      <= '1' WHEN OP_CODE = "11010" ELSE '0'; -- INT

--   -- Write Enable: PUSH, STD, CALL, INT
--   MEM_WRT_EN  <= '1' WHEN OP_CODE="10000" OR OP_CODE="10100" OR OP_CODE="11000" OR OP_CODE="11010" ELSE '0';

--   -- Address: SP(10) for Stack ops/Int/Call, Data(01) for LDD/STD
--   MEM_ADDR    <= "01" WHEN OP_CODE = "10000" OR OP_CODE = "11000" OR OP_CODE = "11010" ELSE -- call , int , push
--                  "11" WHEN OP_CODE = "10011" OR OP_CODE = "10100" ELSE -- LDD , STD
--                  "10";


--   -- ////////////////////////////////////////////////////////
--   -- TODO: handle push flags 
--   -- ////////////////////////////////////////////////////////
--   -- Write Data: INT(10), PUSH/STD(01), CALL(00)
--   MEM_WRT_DATA <= "10" WHEN OP_CODE = "10000" OR OP_CODE = "10100" ELSE
--                   "00";

--   -- # Write Back Stage
--   -- Data: MOV/SWAP(11), LDM(10), ALU/IN(01), LDD/POP(00)
--   -- ////////////////////////////////////////////////////////
--   -- TODO: handle swap instruction WB_DATA
--   -- ////////////////////////////////////////////////////////
--   WB_DATA     <= "01" WHEN OP_CODE = "00110" ELSE -- IN
--                  "10" WHEN is_group_10 AND (sub_bits = "001" or sub_bits = "011") ELSE
--                  "00"; 

--   WB_ADDR     <= "01" WHEN OP_CODE = "10011" OR (is_group_10 AND (sub_bits="000" OR sub_bits="001" OR sub_bits="101")) ELSE 
--                  "10" WHEN is_group_10 AND (sub_bits="010" OR sub_bits="011" OR sub_bits="100") ELSE
--                  "00"; -- Fixed
  
--   -- Reg Write: Group 01 (All), Group 00 (NOT, INC, IN), Group 10 (POP, LDM, LDD)
--   REG_WRT_EN  <= '1' WHEN is_group_01 OR 
--                           (is_group_00 AND (sub_bits="011" OR sub_bits="100" OR sub_bits="110")) OR
--                           (is_group_10 AND (sub_bits="001" OR sub_bits="010" OR sub_bits="011"))
--                      ELSE '0';

--   SWAP_SIG    <= '1' WHEN OP_CODE = "01001" ELSE '0'; -- SWAP
-- END IF;
-- END ARCHITECTURE;