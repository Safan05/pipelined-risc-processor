LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY MEMORY_TB IS
END ENTITY MEMORY_TB;

ARCHITECTURE BEHAVIORAL OF MEMORY_TB IS
    -- Component Declaration
    COMPONENT MEMORY IS
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
    END COMPONENT;
    
    -- Test signals
    SIGNAL CLK_TB: STD_LOGIC := '0';
    SIGNAL WR_EN_TB: STD_LOGIC := '0';
    SIGNAL ADDRESS_TB: STD_LOGIC_VECTOR(19 DOWNTO 0) := (OTHERS => '0');
    SIGNAL WRITE_DATA_TB: STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL READ_DATA_TB: STD_LOGIC_VECTOR(15 DOWNTO 0);
    
    -- Clock period
    CONSTANT CLK_PERIOD: TIME := 10 ns;
    
    -- Decimal representation signals for easier viewing
    SIGNAL ADDRESS_DECIMAL: INTEGER;
    SIGNAL WRITE_DATA_DECIMAL: INTEGER;
    SIGNAL READ_DATA_DECIMAL: INTEGER;
    
BEGIN
    -- Unit Under Test
    UUT: MEMORY PORT MAP (
        CLK => CLK_TB,
        WR_EN => WR_EN_TB,
        ADDRESS => ADDRESS_TB,
        WRITE_DATA => WRITE_DATA_TB,
        READ_DATA => READ_DATA_TB
    );
    
    -- Clock generation
    CLK_PROCESS: PROCESS
    BEGIN
        CLK_TB <= '0';
        WAIT FOR CLK_PERIOD/2;
        CLK_TB <= '1';
        WAIT FOR CLK_PERIOD/2;
    END PROCESS;
    
    -- Convert to decimal for easier viewing
    ADDRESS_DECIMAL <= TO_INTEGER(UNSIGNED(ADDRESS_TB));
    WRITE_DATA_DECIMAL <= TO_INTEGER(UNSIGNED(WRITE_DATA_TB));
    READ_DATA_DECIMAL <= TO_INTEGER(UNSIGNED(READ_DATA_TB));
    
    -- Test stimulus
    STIMULUS: PROCESS
    BEGIN
        -- Wait for initial setup
        WAIT FOR CLK_PERIOD;
        
        -- ========================================
        -- Test 1: Write and Read from Instruction Memory (Address 0x00000)
        -- ========================================
        REPORT "Test 1: Write/Read from Instruction Memory (0x00000)";
        ADDRESS_TB <= X"00000";
        WRITE_DATA_TB <= X"1234";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"1234" REPORT "Test 1 Failed: Expected 0x1234" SEVERITY ERROR;
        
        -- ========================================
        -- Test 2: Write and Read from middle of Instruction Memory (0x20000)
        -- ========================================
        REPORT "Test 2: Write/Read from Instruction Memory (0x20000)";
        ADDRESS_TB <= X"20000";
        WRITE_DATA_TB <= X"ABCD";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"ABCD" REPORT "Test 2 Failed: Expected 0xABCD" SEVERITY ERROR;
        
        -- ========================================
        -- Test 3: Write and Read from Data Segment Start (0x40000)
        -- ========================================
        REPORT "Test 3: Write/Read from Data Segment (0x40000)";
        ADDRESS_TB <= X"40000";
        WRITE_DATA_TB <= X"5678";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"5678" REPORT "Test 3 Failed: Expected 0x5678" SEVERITY ERROR;
        
        -- ========================================
        -- Test 4: Write and Read from Data Segment (0x50000)
        -- ========================================
        REPORT "Test 4: Write/Read from Data Segment (0x50000)";
        ADDRESS_TB <= X"50000";
        WRITE_DATA_TB <= X"CAFE";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"CAFE" REPORT "Test 4 Failed: Expected 0xCAFE" SEVERITY ERROR;
        
        -- ========================================
        -- Test 5: Write and Read from Stack (Top - 0xFFFFF)
        -- ========================================
        REPORT "Test 5: Write/Read from Stack Top (0xFFFFF)";
        ADDRESS_TB <= X"FFFFF";
        WRITE_DATA_TB <= X"BEEF";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"BEEF" REPORT "Test 5 Failed: Expected 0xBEEF" SEVERITY ERROR;
        
        -- ========================================
        -- Test 6: Write and Read from Stack (0xFFFF0)
        -- ========================================
        REPORT "Test 6: Write/Read from Stack (0xFFFF0)";
        ADDRESS_TB <= X"FFFF0";
        WRITE_DATA_TB <= X"DEAD";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"DEAD" REPORT "Test 6 Failed: Expected 0xDEAD" SEVERITY ERROR;
        
        -- ========================================
        -- Test 7: Sequential Writes to Multiple Addresses
        -- ========================================
        REPORT "Test 7: Sequential Writes";
        WR_EN_TB <= '1';
        
        ADDRESS_TB <= X"00100";
        WRITE_DATA_TB <= X"0001";
        WAIT FOR CLK_PERIOD;
        
        ADDRESS_TB <= X"00101";
        WRITE_DATA_TB <= X"0002";
        WAIT FOR CLK_PERIOD;
        
        ADDRESS_TB <= X"00102";
        WRITE_DATA_TB <= X"0003";
        WAIT FOR CLK_PERIOD;
        
        ADDRESS_TB <= X"00103";
        WRITE_DATA_TB <= X"0004";
        WAIT FOR CLK_PERIOD;
        
        -- Read back sequential addresses
        WR_EN_TB <= '0';
        ADDRESS_TB <= X"00100";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0001" REPORT "Test 7a Failed" SEVERITY ERROR;
        
        ADDRESS_TB <= X"00101";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0002" REPORT "Test 7b Failed" SEVERITY ERROR;
        
        ADDRESS_TB <= X"00102";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0003" REPORT "Test 7c Failed" SEVERITY ERROR;
        
        ADDRESS_TB <= X"00103";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0004" REPORT "Test 7d Failed" SEVERITY ERROR;
        
        -- ========================================
        -- Test 8: Overwrite Existing Data
        -- ========================================
        REPORT "Test 8: Overwrite Existing Data";
        ADDRESS_TB <= X"00000";
        WR_EN_TB <= '1';
        WRITE_DATA_TB <= X"FFFF";
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"FFFF" REPORT "Test 8 Failed: Expected 0xFFFF" SEVERITY ERROR;
        
        -- ========================================
        -- Test 9: Read from Uninitialized Memory (should be 0x0000)
        -- ========================================
        REPORT "Test 9: Read Uninitialized Memory";
        ADDRESS_TB <= X"7FFFF";
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0000" REPORT "Test 9 Failed: Expected 0x0000" SEVERITY ERROR;
        
        -- ========================================
        -- Test 10: Write All Zeros
        -- ========================================
        REPORT "Test 10: Write All Zeros";
        ADDRESS_TB <= X"60000";
        WRITE_DATA_TB <= X"0000";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0000" REPORT "Test 10 Failed" SEVERITY ERROR;
        
        -- ========================================
        -- Test 11: Write All Ones
        -- ========================================
        REPORT "Test 11: Write All Ones";
        ADDRESS_TB <= X"60001";
        WRITE_DATA_TB <= X"FFFF";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"FFFF" REPORT "Test 11 Failed" SEVERITY ERROR;
        
        -- ========================================
        -- Test 12: Alternating Bit Pattern
        -- ========================================
        REPORT "Test 12: Alternating Bit Pattern";
        ADDRESS_TB <= X"60002";
        WRITE_DATA_TB <= X"5555";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"5555" REPORT "Test 12 Failed" SEVERITY ERROR;
        
        ADDRESS_TB <= X"60003";
        WRITE_DATA_TB <= X"AAAA";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"AAAA" REPORT "Test 12b Failed" SEVERITY ERROR;
        
        -- ========================================
        -- Test 13: Verify Previous Data Not Corrupted
        -- ========================================
        REPORT "Test 13: Verify Data Integrity";
        ADDRESS_TB <= X"20000";
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"ABCD" REPORT "Test 13a Failed: Data corrupted at 0x20000" SEVERITY ERROR;
        
        ADDRESS_TB <= X"40000";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"5678" REPORT "Test 13b Failed: Data corrupted at 0x40000" SEVERITY ERROR;
        
        ADDRESS_TB <= X"FFFFF";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"BEEF" REPORT "Test 13c Failed: Data corrupted at 0xFFFFF" SEVERITY ERROR;
        
        -- ========================================
        -- Test 14: Stack Operation Simulation (Push/Pop)
        -- ========================================
        REPORT "Test 14: Stack Operation Simulation";
        -- Push values onto stack (growing downward)
        WR_EN_TB <= '1';
        
        ADDRESS_TB <= X"FFFFE";  -- SP = 0xFFFFE
        WRITE_DATA_TB <= X"1111";
        WAIT FOR CLK_PERIOD;
        
        ADDRESS_TB <= X"FFFFD";  -- SP = 0xFFFFD
        WRITE_DATA_TB <= X"2222";
        WAIT FOR CLK_PERIOD;
        
        ADDRESS_TB <= X"FFFFC";  -- SP = 0xFFFFC
        WRITE_DATA_TB <= X"3333";
        WAIT FOR CLK_PERIOD;
        
        -- Pop values (read in reverse order)
        WR_EN_TB <= '0';
        
        ADDRESS_TB <= X"FFFFC";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"3333" REPORT "Test 14a Failed: Stack Pop" SEVERITY ERROR;
        
        ADDRESS_TB <= X"FFFFD";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"2222" REPORT "Test 14b Failed: Stack Pop" SEVERITY ERROR;
        
        ADDRESS_TB <= X"FFFFE";
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"1111" REPORT "Test 14c Failed: Stack Pop" SEVERITY ERROR;
        
        -- ========================================
        -- Test 15: Rapid Write/Read Cycles
        -- ========================================
        REPORT "Test 15: Rapid Write/Read Cycles";
        FOR i IN 0 TO 9 LOOP
            ADDRESS_TB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#70000# + i, 20));
            WRITE_DATA_TB <= STD_LOGIC_VECTOR(TO_UNSIGNED(i * 100, 16));
            WR_EN_TB <= '1';
            WAIT FOR CLK_PERIOD;
        END LOOP;
        
        WR_EN_TB <= '0';
        FOR i IN 0 TO 9 LOOP
            ADDRESS_TB <= STD_LOGIC_VECTOR(TO_UNSIGNED(16#70000# + i, 20));
            WAIT FOR CLK_PERIOD;
            ASSERT READ_DATA_TB = STD_LOGIC_VECTOR(TO_UNSIGNED(i * 100, 16)) 
                REPORT "Test 15 Failed at iteration " & INTEGER'IMAGE(i) SEVERITY ERROR;
        END LOOP;
        
        -- ========================================
        -- Test 16: Boundary Address Testing
        -- ========================================
        REPORT "Test 16: Boundary Address Testing";
        
        -- First address
        ADDRESS_TB <= X"00000";
        WRITE_DATA_TB <= X"0A0A";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"0A0A" REPORT "Test 16a Failed: First address" SEVERITY ERROR;
        
        -- Last address
        ADDRESS_TB <= X"FFFFF";
        WRITE_DATA_TB <= X"F0F0";
        WR_EN_TB <= '1';
        WAIT FOR CLK_PERIOD;
        
        WR_EN_TB <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT READ_DATA_TB = X"F0F0" REPORT "Test 16b Failed: Last address" SEVERITY ERROR;
        
        REPORT "========================================";
        REPORT "All Memory Tests Completed Successfully!";
        REPORT "========================================";
        
        WAIT;
    END PROCESS;
    
END ARCHITECTURE BEHAVIORAL;
