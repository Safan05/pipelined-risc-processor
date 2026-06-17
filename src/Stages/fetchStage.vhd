-- Fetch Stage
-- Contains PC Handler, PC+1 Adder, and instruction fetch logic
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY fetch_stage IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        
        -- Control inputs
        pc_en : IN STD_LOGIC;                                -- PC write enable (from HDU)
        pc_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);           -- PC source select
        
        -- PC source inputs
        pc_from_stack : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- For RET/RTI
        jump_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);         -- For branches/jumps
        int_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);          -- Interrupt vector
        
        -- Memory interface
        mem_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);   -- Instruction from memory
        mem_address : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);    -- Address to memory
        
        -- Outputs to IF/ID Register
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);         -- Current PC
        pc_plus_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- PC + 1 (for IF/ID)
        instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)       -- Fetched instruction
    );
END ENTITY fetch_stage;

ARCHITECTURE Behavioral OF fetch_stage IS
    -- Internal PC register
    SIGNAL pc_current : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_plus_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    -- =============================================================
    -- PC + 1 Adder (COMBINATIONAL)
    -- =============================================================
    pc_plus_1 <= STD_LOGIC_VECTOR(UNSIGNED(pc_current) + 1);

    -- =============================================================
    -- PC Next MUX (COMBINATIONAL)
    -- =============================================================
    -- 00: From stack (RET/RTI)
    -- 01: PC + 1 (Normal)
    -- 10: Jump/Branch target
    -- 11: Interrupt vector
    pc_next <= pc_from_stack WHEN pc_sel = "00" ELSE
               pc_plus_1     WHEN pc_sel = "01" ELSE
               jump_pc       WHEN pc_sel = "10" ELSE
               int_pc;       -- "11" = Interrupt

    -- =============================================================
    -- PC Register (SEQUENTIAL)
    -- =============================================================
    PC_REG: PROCESS(clk, rst)
    BEGIN
        IF rst = '1' THEN
            pc_current <= (OTHERS => '0');
        ELSIF RISING_EDGE(clk) THEN
            IF pc_en = '1' THEN
                pc_current <= pc_next;
            END IF;
        END IF;
    END PROCESS;

    -- =============================================================
    -- Outputs (COMBINATIONAL)
    -- =============================================================
    -- Memory address is lower 20 bits of PC
    mem_address <= pc_current(19 DOWNTO 0);
    
    -- Output current PC and PC+1 to IF/ID register
    pc_out <= pc_current;
    pc_plus_1_out <= pc_plus_1;
    
    -- Instruction is directly from memory (combinational read)
    instr_out <= mem_read_data;

END ARCHITECTURE Behavioral;