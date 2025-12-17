LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Reg IS
    GENERIC (
        REG_WIDTH : INTEGER := 32  -- Add generic parameter
    );
    PORT (
        d   : IN STD_LOGIC_VECTOR(REG_WIDTH-1 DOWNTO 0); 
        q   : OUT STD_LOGIC_VECTOR(REG_WIDTH-1 DOWNTO 0); 
        rst : IN STD_LOGIC;
        we  : IN STD_LOGIC;
        clk : IN STD_LOGIC
    ); 
END Reg;

ARCHITECTURE behavioral OF Reg IS
BEGIN
    PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            q <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF we = '1' THEN
                q <= d;
            END IF;
        END IF;
    END PROCESS;
END behavioral;