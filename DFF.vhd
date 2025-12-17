LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY DFF IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        enable : IN STD_LOGIC;
        d : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END DFF;

ARCHITECTURE DFF_arch OF DFF IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            q <= (OTHERS => '0');

        ELSIF rising_edge(clk) THEN
            IF (enable = '1') THEN
                q <= d;
            END IF;
        END IF;
    END PROCESS;
END DFF_arch;