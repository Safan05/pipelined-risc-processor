LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MEMORY IS
    GENERIC (
        ADDR_WIDTH: INTEGER := 20;
        DATA_WIDTH: INTEGER := 16
    );
    PORT (
        CLK: IN STD_LOGIC;
        WR_EN: IN STD_LOGIC;
        ADDRESS: IN STD_LOGIC_VECTOR(ADDR_WIDTH-1 DOWNTO 0);
        WRITE_DATA: IN STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        READ_DATA: OUT STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0)
    );
END ENTITY MEMORY;

ARCHITECTURE BEHAVIORAL OF MEMORY IS
    TYPE MEM_ARRAY IS ARRAY (0 TO (2**ADDR_WIDTH)-1) OF STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    SIGNAL MEMORY_BLOCK: MEM_ARRAY := (OTHERS => (OTHERS => '0'));
    
    -- Memory organization constants (addresses in words)
    -- Instruction Memory: 0x00000 to 0x3FFFF (256K words)
    -- Data Segment: 0x40000 growing upward
    -- Stack Segment: 0xFFFFF growing downward
    
BEGIN
    MEMORY_PROCESS: PROCESS(CLK)
    BEGIN
        IF RISING_EDGE(CLK) THEN
            IF WR_EN = '1' THEN
                MEMORY_BLOCK(TO_INTEGER(UNSIGNED(ADDRESS))) <= WRITE_DATA;
            END IF;
            
            READ_DATA <= MEMORY_BLOCK(TO_INTEGER(UNSIGNED(ADDRESS)));
        END IF;
    END PROCESS;


    -- Another process for stack pointer handler should be implemented.
    
END ARCHITECTURE BEHAVIORAL;
