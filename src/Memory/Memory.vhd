LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY MEMORY IS
    GENERIC (
        ADDR_WIDTH: INTEGER := 20;
        DATA_WIDTH: INTEGER := 32;
        -- Memory initialization file (hex format, one value per line)
        INIT_FILE: STRING := ""
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
    -- Reduced memory size for simulation (1024 words instead of 2^20)
    CONSTANT MEM_SIZE : INTEGER := 262144;
    TYPE MEM_ARRAY IS ARRAY (0 TO MEM_SIZE-1) OF STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
    
    -- Function to convert hex character to 4-bit value
    FUNCTION hex_to_slv(c : CHARACTER) RETURN STD_LOGIC_VECTOR IS
        VARIABLE result : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
        CASE c IS
            WHEN '0' => result := "0000";
            WHEN '1' => result := "0001";
            WHEN '2' => result := "0010";
            WHEN '3' => result := "0011";
            WHEN '4' => result := "0100";
            WHEN '5' => result := "0101";
            WHEN '6' => result := "0110";
            WHEN '7' => result := "0111";
            WHEN '8' => result := "1000";
            WHEN '9' => result := "1001";
            WHEN 'A' | 'a' => result := "1010";
            WHEN 'B' | 'b' => result := "1011";
            WHEN 'C' | 'c' => result := "1100";
            WHEN 'D' | 'd' => result := "1101";
            WHEN 'E' | 'e' => result := "1110";
            WHEN 'F' | 'f' => result := "1111";
            WHEN OTHERS => result := "0000";
        END CASE;
        RETURN result;
    END FUNCTION;
    
    -- Function to load memory from file
    IMPURE FUNCTION init_memory RETURN MEM_ARRAY IS
        FILE mem_file : TEXT;
        VARIABLE mem_line : LINE;
        VARIABLE mem_value : STD_LOGIC_VECTOR(DATA_WIDTH-1 DOWNTO 0);
        VARIABLE mem : MEM_ARRAY := (OTHERS => (OTHERS => '0'));
        VARIABLE i : INTEGER := 0;
        VARIABLE char : CHARACTER;
        VARIABLE j : INTEGER;
        VARIABLE file_status : FILE_OPEN_STATUS;
    BEGIN
        IF INIT_FILE /= "" THEN
            FILE_OPEN(file_status, mem_file, INIT_FILE, READ_MODE);
            IF file_status = OPEN_OK THEN
                REPORT "Loading memory from file: " & INIT_FILE SEVERITY NOTE;
                WHILE NOT ENDFILE(mem_file) AND i < MEM_SIZE LOOP
                    READLINE(mem_file, mem_line);
                    mem_value := (OTHERS => '0');
                    j := DATA_WIDTH - 4;
                    -- Read up to 8 hex characters (32 bits)
                    WHILE mem_line'LENGTH > 0 AND j >= 0 LOOP
                        READ(mem_line, char);
                        IF char /= ' ' AND char /= CR AND char /= LF THEN
                            mem_value(j+3 DOWNTO j) := hex_to_slv(char);
                            j := j - 4;
                        END IF;
                    END LOOP;
                    mem(i) := mem_value;
                    i := i + 1;
                END LOOP;
                REPORT "Loaded " & INTEGER'IMAGE(i) & " words from memory file." SEVERITY NOTE;
                FILE_CLOSE(mem_file);
            ELSE
                REPORT "Failed to open memory file: " & INIT_FILE & " Status: " & FILE_OPEN_STATUS'IMAGE(file_status) SEVERITY WARNING;
            END IF;
        ELSE
             REPORT "No init file specified for memory." SEVERITY NOTE;
        END IF;
        RETURN mem;
    END FUNCTION;
    
    SIGNAL MEMORY_BLOCK: MEM_ARRAY := init_memory;
    
BEGIN
    -- Synchronous write, asynchronous read
    MEMORY_WRITE: PROCESS(CLK)
        VARIABLE addr_int : INTEGER;
    BEGIN
        IF RISING_EDGE(CLK) THEN
            addr_int := TO_INTEGER(UNSIGNED(ADDRESS));
            IF addr_int < MEM_SIZE THEN
                IF WR_EN = '1' THEN
                    MEMORY_BLOCK(addr_int) <= WRITE_DATA;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    -- Asynchronous read (combinational) for faster instruction fetch
    MEMORY_READ: PROCESS(ADDRESS, MEMORY_BLOCK)
        VARIABLE addr_int : INTEGER;
    BEGIN
        addr_int := TO_INTEGER(UNSIGNED(ADDRESS));
        IF addr_int < MEM_SIZE THEN
            READ_DATA <= MEMORY_BLOCK(addr_int);
        ELSE
            READ_DATA <= (OTHERS => '0');
        END IF;
    END PROCESS;

END ARCHITECTURE BEHAVIORAL;
