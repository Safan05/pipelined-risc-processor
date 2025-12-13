LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Pipeline_Register IS
    GENERIC (
        WIDTH : integer := 32 -- Default width
    );
    PORT (
        CLK    : IN std_logic;
        RST    : IN std_logic; -- 1. Reset Signal: Sets value to 0
        EN     : IN std_logic; -- 2. Enable Signal: '1' writes, '0' holds
        Input  : IN std_logic_vector(WIDTH-1 DOWNTO 0);
        Output : OUT std_logic_vector(WIDTH-1 DOWNTO 0)
    );
END ENTITY Pipeline_Register;

ARCHITECTURE Behavioral OF Pipeline_Register IS
BEGIN
    PROCESS (CLK, RST)
    BEGIN
        -- Asynchronous Reset
        IF RST = '1' THEN
            Output <= (others => '0');
            
        -- Synchronous Write on Rising Edge
        ELSIF RISING_EDGE(CLK) THEN
            IF EN = '1' THEN
                Output <= Input;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE Behavioral;