LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memoryStage IS
    PORT (
        -- Inputs from EX/MEM Buffer
        -- =========================
        ALU_OUT_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        REG_DATA1_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- For PUSH (Rsrc1 data)
        REG_DATA2_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_INC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        WB_ADDR_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals from EX/MEM Buffer
        MEM_WRT_EN_SIG_IN : IN STD_LOGIC;
        MEM_ADDR_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEM_WRT_DATA_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_DATA_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRT_EN_IN : IN STD_LOGIC;

        -- =========================
        -- Data Memory Interface
        -- =========================
        MEM_READ_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_ADDRESS : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
        MEM_WRITE_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_WRITE_ENABLE : OUT STD_LOGIC;

        -- =========================
        -- Outputs to MEM/WB Buffer
        -- =========================
        ALU_OUT_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_OUT_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        READ_DATA_1_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        WB_ADDR_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals to MEM/WB Buffer
        WB_DATA_SIG_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRT_EN_OUT : OUT STD_LOGIC
    );
END memoryStage;

ARCHITECTURE Behavioral OF memoryStage IS

BEGIN

    -- =========================
    -- Memory Address Handling
    -- (Delegated to Address Handler)
    -- =========================
    addr_handler_inst : ENTITY work.mem_addr_handler
        PORT MAP(
            addr_sel => MEM_ADDR_SIG_IN,
            pc_addr => PC_IN,
            alu_addr => ALU_OUT_IN,
            sp => SP_IN,              -- Current SP (for reference)
            sp_buffer => SP_IN,       -- OLD SP value for PUSH/POP (from EX/MEM register)
            mem_addr => MEM_ADDRESS
        );

    -- =========================
    -- Memory Write Enable
    -- =========================
    MEM_WRITE_ENABLE <= MEM_WRT_EN_SIG_IN;

    -- =========================
    -- Memory Write Data MUX
    -- =========================
    -- 00=PC_IN, 01=PC_INC_IN, 10=SP_IN, 11=REG_DATA1_IN (for PUSH)
    MEM_WRITE_DATA <= PC_IN WHEN MEM_WRT_DATA_SIG_IN = "00" ELSE
        PC_INC_IN WHEN MEM_WRT_DATA_SIG_IN = "01" ELSE
        SP_IN WHEN MEM_WRT_DATA_SIG_IN = "10" ELSE
        REG_DATA1_IN;  -- For PUSH (uses Rsrc1 = R1)

    -- =========================
    -- Outputs to MEM/WB Buffer (Combinational)
    -- =========================
    ALU_OUT_OUT <= ALU_OUT_IN;
    MEM_OUT_OUT <= MEM_READ_DATA;
    READ_DATA_1_OUT <= REG_DATA1_IN;  -- Pass-through for SWAP (original Rsrc1 value)
    WB_ADDR_OUT <= WB_ADDR_IN;
    
    -- Pass-through control signals
    WB_DATA_SIG_OUT <= WB_DATA_SIG_IN;
    REG_WRT_EN_OUT <= REG_WRT_EN_IN;

END Behavioral;