LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY Reg IS 
    PORT (
        d   : IN  std_logic_vector(7 downto 0); -- Data Input
        q   : OUT std_logic_vector(7 downto 0); -- Data Output
        rst : IN  std_logic;                    -- Reset (Asynchronous)
        we  : IN  std_logic;                    -- Write Enable
        clk : IN  std_logic                     -- Clock
    ); 
END Reg;

ARCHITECTURE behavioral OF Reg IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        -- Asynchronous Reset (Active High)
        IF rst = '1' THEN
            q <= (others => '0'); -- Clear all 8 bits to 0
            
        -- Rising Edge of Clock
        ELSIF rising_edge(clk) THEN
            -- Only write data if Write Enable is '1'
            IF we = '1' THEN
                q <= d;
            END IF;
        END IF;
    END PROCESS;
END behavioral;