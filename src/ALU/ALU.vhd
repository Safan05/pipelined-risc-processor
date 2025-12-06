LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY ALU IS 
    PORT (
        A, B: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        OP: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        RESULT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        COUT, ZERO, NEGATIVE: OUT STD_LOGIC
    );
END ENTITY ALU;


ARCHITECTURE BEHAVIORAL OF ALU IS
    SIGNAL TEMP_RESULT: STD_LOGIC_VECTOR(63 DOWNTO 0);
    SIGNAL CARRY_OUT: STD_LOGIC;
BEGIN
    PROCESS(A, B, OP)
        VARIABLE TEMP_ADD: SIGNED(32 DOWNTO 0);
        VARIABLE TEMP_SUB: SIGNED(32 DOWNTO 0);
        VARIABLE TEMP_MUL: STD_LOGIC_VECTOR(63 DOWNTO 0);
    BEGIN
        CARRY_OUT <= '0';
        TEMP_RESULT <= (OTHERS => '0');
        
        CASE OP IS
            -- 000: No operation
            WHEN "000" =>
                TEMP_RESULT(31 DOWNTO 0) <= (OTHERS => '0');
                CARRY_OUT <= '0';
            
            -- 001: Add
            WHEN "001" =>
                TEMP_ADD := (A(31) & SIGNED(A)) + (B(31) & SIGNED(B));
                TEMP_RESULT(31 DOWNTO 0) <= STD_LOGIC_VECTOR(TEMP_ADD(31 DOWNTO 0));
                CARRY_OUT <= TEMP_ADD(32);
            
            -- 010: Sub
            WHEN "010" =>
                TEMP_SUB := (A(31) & SIGNED(A)) - (B(31) & SIGNED(B));
                TEMP_RESULT(31 DOWNTO 0) <= STD_LOGIC_VECTOR(TEMP_SUB(31 DOWNTO 0));
                CARRY_OUT <= TEMP_SUB(32);
            
            -- 011: Mul
            WHEN "011" =>
                TEMP_MUL := STD_LOGIC_VECTOR(SIGNED(A) * SIGNED(B));
                TEMP_RESULT <= TEMP_MUL;
                CARRY_OUT <= '0';
            
            -- 100: And
            WHEN "100" =>
                TEMP_RESULT(31 DOWNTO 0) <= A AND B;
                CARRY_OUT <= '0';
            
            -- 101: Not first
            WHEN "101" =>
                TEMP_RESULT(31 DOWNTO 0) <= NOT A;
                CARRY_OUT <= '0';
            
            -- 110: First op
            WHEN "110" =>
                TEMP_RESULT(31 DOWNTO 0) <= A;
                CARRY_OUT <= '0';
            
            -- 111: Second op
            WHEN "111" =>
                TEMP_RESULT(31 DOWNTO 0) <= B;
                CARRY_OUT <= '0';
            
            WHEN OTHERS =>
                TEMP_RESULT(31 DOWNTO 0) <= (OTHERS => '0');
                CARRY_OUT <= '0';
        END CASE;
    END PROCESS;
    
    -- Output
    RESULT <= TEMP_RESULT(31 DOWNTO 0);

    -- Flags
    COUT <= CARRY_OUT;
    ZERO <= '1' WHEN TEMP_RESULT(31 DOWNTO 0) = X"00000000" ELSE '0';
    NEGATIVE <= TEMP_RESULT(31);

END ARCHITECTURE BEHAVIORAL;