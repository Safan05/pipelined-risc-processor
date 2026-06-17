-- Stack Pointer Register
-- 32-bit register with write enable for stack operations
-- Quartus-compatible, synthesizable for DE1-SoC

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY SP_Reg IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        we : IN STD_LOGIC;              -- Write enable
        sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- New SP value
        sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)  -- Current SP value
    );
END ENTITY SP_Reg;

ARCHITECTURE rtl OF SP_Reg IS
    -- Initial SP value: top of stack segment (0xFFFFF in 20-bit address space)
    SIGNAL sp_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Initialize SP to top of memory (stack grows downward)
            -- MEM_SIZE = 262144 (2^18), so max address = 0x3FFFF
            sp_reg <= X"0003FFFF";  -- 18-bit max address
        ELSIF RISING_EDGE(clk) THEN
            IF we = '1' THEN
                sp_reg <= sp_in;
            END IF;
        END IF;
    END PROCESS;

    sp_out <= sp_reg;

END ARCHITECTURE rtl;
