LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU_TB IS
END ENTITY ALU_TB;

ARCHITECTURE BEHAVIORAL OF ALU_TB IS
    -- Component Declaration
    COMPONENT ALU IS
        PORT (
            A, B: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            OP: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            RESULT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            COUT, ZERO, NEGATIVE: OUT STD_LOGIC
        );
    END COMPONENT;
    
    -- Test Signals
    SIGNAL A_TB, B_TB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL OP_TB: STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL RESULT_TB: STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL COUT_TB, ZERO_TB, NEGATIVE_TB: STD_LOGIC;
    
    -- Signals for decimal representation
    SIGNAL A_DECIMAL: INTEGER;
    SIGNAL B_DECIMAL: INTEGER;
    SIGNAL RESULT_DECIMAL: INTEGER;
    
BEGIN
    -- Unit Under Test instantiation
    UUT: ALU PORT MAP (
        A => A_TB,
        B => B_TB,
        OP => OP_TB,
        RESULT => RESULT_TB,
        COUT => COUT_TB,
        ZERO => ZERO_TB,
        NEGATIVE => NEGATIVE_TB
    );
    
    -- Convert to decimal for easier viewing
    A_DECIMAL <= TO_INTEGER(SIGNED(A_TB));
    B_DECIMAL <= TO_INTEGER(SIGNED(B_TB));
    RESULT_DECIMAL <= TO_INTEGER(SIGNED(RESULT_TB));
    
    -- Test Process
    STIMULUS: PROCESS
    BEGIN
        -- Test 1: No Operation (000)
        REPORT "Test 1: No Operation";
        A_TB <= X"00000005";  -- 5
        B_TB <= X"00000003";  -- 3
        OP_TB <= "000";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000000" REPORT "No Operation Failed" SEVERITY ERROR;
        ASSERT ZERO_TB = '1' REPORT "Zero flag should be set" SEVERITY ERROR;
        
        -- Test 2: Addition - Positive Numbers
        REPORT "Test 2: Addition - Positive Numbers";
        A_TB <= X"00000000";  -- 10
        B_TB <= X"00000001";  -- 20
        OP_TB <= "001";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000002" REPORT "Addition Failed: 0 + 1 should be 2" SEVERITY ERROR;
        ASSERT ZERO_TB = '0' REPORT "Zero flag should be clear" SEVERITY ERROR;
        ASSERT NEGATIVE_TB = '0' REPORT "Negative flag should be clear" SEVERITY ERROR;
        
        -- Test 3: Addition - Negative Numbers
        REPORT "Test 3: Addition - Negative Numbers";
        A_TB <= X"FFFFFFF6";  -- -10
        B_TB <= X"FFFFFFEC";  -- -20
        OP_TB <= "001";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"FFFFFFE2" REPORT "Addition Failed: -10 + -20 should be -30" SEVERITY ERROR;
        ASSERT NEGATIVE_TB = '1' REPORT "Negative flag should be set" SEVERITY ERROR;
        
        -- Test 4: Addition - Mixed Signs
        REPORT "Test 4: Addition - Mixed Signs";
        A_TB <= X"00000032";  -- 50
        B_TB <= X"FFFFFFCE";  -- -50
        OP_TB <= "001";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000000" REPORT "Addition Failed: 50 + -50 should be 0" SEVERITY ERROR;
        ASSERT ZERO_TB = '1' REPORT "Zero flag should be set" SEVERITY ERROR;
        
        -- Test 5: Subtraction - Positive Result
        REPORT "Test 5: Subtraction - Positive Result";
        A_TB <= X"00000032";  -- 50
        B_TB <= X"0000001E";  -- 30
        OP_TB <= "010";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000014" REPORT "Subtraction Failed: 50 - 30 should be 20" SEVERITY ERROR;
        ASSERT NEGATIVE_TB = '0' REPORT "Negative flag should be clear" SEVERITY ERROR;
        
        -- Test 6: Subtraction - Negative Result
        REPORT "Test 6: Subtraction - Negative Result";
        A_TB <= X"0000000A";  -- 10
        B_TB <= X"00000014";  -- 20
        OP_TB <= "010";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"FFFFFFF6" REPORT "Subtraction Failed: 10 - 20 should be -10" SEVERITY ERROR;
        ASSERT NEGATIVE_TB = '1' REPORT "Negative flag should be set" SEVERITY ERROR;
        
        -- Test 7: Subtraction - Zero Result
        REPORT "Test 7: Subtraction - Zero Result";
        A_TB <= X"0000000F";  -- 15
        B_TB <= X"0000000F";  -- 15
        OP_TB <= "010";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000000" REPORT "Subtraction Failed: 15 - 15 should be 0" SEVERITY ERROR;
        ASSERT ZERO_TB = '1' REPORT "Zero flag should be set" SEVERITY ERROR;
        
        -- Test 8: Multiplication - Positive Numbers
        REPORT "Test 8: Multiplication - Positive Numbers";
        A_TB <= X"00000006";  -- 6
        B_TB <= X"00000007";  -- 7
        OP_TB <= "011";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"0000002A" REPORT "Multiplication Failed: 6 * 7 should be 42" SEVERITY ERROR;
        
        -- Test 9: Multiplication - Negative Numbers
        REPORT "Test 9: Multiplication - Negative Numbers";
        A_TB <= X"FFFFFFFA";  -- -6
        B_TB <= X"FFFFFFF9";  -- -7
        OP_TB <= "011";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"0000002A" REPORT "Multiplication Failed: -6 * -7 should be 42" SEVERITY ERROR;
        
        -- Test 10: Multiplication - Mixed Signs
        REPORT "Test 10: Multiplication - Mixed Signs";
        A_TB <= X"00000005";  -- 5
        B_TB <= X"FFFFFFFD";  -- -3
        OP_TB <= "011";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"FFFFFFF1" REPORT "Multiplication Failed: 5 * -3 should be -15" SEVERITY ERROR;
        ASSERT NEGATIVE_TB = '1' REPORT "Negative flag should be set" SEVERITY ERROR;
        
        -- Test 11: Multiplication - By Zero
        REPORT "Test 11: Multiplication - By Zero";
        A_TB <= X"0000000A";  -- 10
        B_TB <= X"00000000";  -- 0
        OP_TB <= "011";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000000" REPORT "Multiplication Failed: 10 * 0 should be 0" SEVERITY ERROR;
        ASSERT ZERO_TB = '1' REPORT "Zero flag should be set" SEVERITY ERROR;
        
        -- Test 12: AND Operation
        REPORT "Test 12: AND Operation";
        A_TB <= X"0000FF0F";  -- 65295
        B_TB <= X"00000F0F";  -- 3855
        OP_TB <= "100";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000F0F" REPORT "AND Operation Failed" SEVERITY ERROR;
        
        -- Test 13: AND - Result Zero
        REPORT "Test 13: AND - Result Zero";
        A_TB <= X"0000FF00";
        B_TB <= X"000000FF";
        OP_TB <= "100";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000000" REPORT "AND Operation Failed" SEVERITY ERROR;
        ASSERT ZERO_TB = '1' REPORT "Zero flag should be set" SEVERITY ERROR;
        
        -- Test 14: NOT First Operand
        REPORT "Test 14: NOT First Operand";
        A_TB <= X"0000FFFF";
        B_TB <= X"00000000";
        OP_TB <= "101";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"FFFF0000" REPORT "NOT Operation Failed" SEVERITY ERROR;
        
        -- Test 15: NOT - All Ones
        REPORT "Test 15: NOT - All Ones";
        A_TB <= X"FFFFFFFF";
        B_TB <= X"00000000";
        OP_TB <= "101";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"00000000" REPORT "NOT Operation Failed" SEVERITY ERROR;
        ASSERT ZERO_TB = '1' REPORT "Zero flag should be set" SEVERITY ERROR;
        
        -- Test 16: First Operand Pass-through
        REPORT "Test 16: First Operand Pass-through";
        A_TB <= X"12345678";
        B_TB <= X"ABCDEF00";
        OP_TB <= "110";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"12345678" REPORT "First Operand Pass Failed" SEVERITY ERROR;
        
        -- Test 17: Second Operand Pass-through
        REPORT "Test 17: Second Operand Pass-through";
        A_TB <= X"12345678";
        B_TB <= X"ABCDEF00";
        OP_TB <= "111";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"ABCDEF00" REPORT "Second Operand Pass Failed" SEVERITY ERROR;
        
        -- Test 18: Large Numbers Addition
        REPORT "Test 18: Large Numbers Addition";
        A_TB <= X"7FFFFFFF";  -- Max positive
        B_TB <= X"00000001";  -- 1
        OP_TB <= "001";
        WAIT FOR 10 ns;
        ASSERT COUT_TB = '0' REPORT "Carry should indicate overflow" SEVERITY WARNING;
        
        -- Test 19: Large Numbers Subtraction
        REPORT "Test 19: Large Numbers Subtraction";
        A_TB <= X"80000000";  -- Min negative
        B_TB <= X"00000001";  -- 1
        OP_TB <= "010";
        WAIT FOR 10 ns;
        ASSERT RESULT_TB = X"7FFFFFFF" REPORT "Subtraction overflow test" SEVERITY WARNING;
        
        REPORT "All Tests Completed!";
        WAIT;
    END PROCESS;
    
END ARCHITECTURE BEHAVIORAL;