LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY memoryStage IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;

        -- =========================
        -- Inputs from Execute Stage
        -- =========================
        ALU_OUT_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        REG_DATA2_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        SP_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        PC_INC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        WB_ADDR_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals from EX
        MEM_WRT_EN_SIG_IN : IN STD_LOGIC;
        MEM_ADDR_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEM_WRT_DATA_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_DATA_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRT_EN_IN : IN STD_LOGIC;
        SWAP_SIG_IN : IN STD_LOGIC;

        -- =========================
        -- Data Memory Interface
        -- =========================
        MEM_READ_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_ADDRESS : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
        MEM_WRITE_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_WRITE_ENABLE : OUT STD_LOGIC;

        -- =========================
        -- Outputs to Write Back
        -- =========================
        ALU_OUT_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_OUT_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        READ_DATA_1_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        WB_ADDR_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        WB_DATA_SIG_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRT_EN_OUT : OUT STD_LOGIC
    );
END memoryStage;

ARCHITECTURE Behavioral OF memoryStage IS

    -- =========================
    -- EX/MEM Pipeline Registers
    -- =========================
    SIGNAL alu_out_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_data2_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sp_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_inc_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wb_addr_reg : STD_LOGIC_VECTOR(2 DOWNTO 0);

    SIGNAL mem_wrt_en_reg : STD_LOGIC;
    SIGNAL mem_addr_sig_reg : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL mem_wrt_data_sig_reg : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL wb_data_sig_reg : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL reg_wrt_en_reg : STD_LOGIC;
    SIGNAL swap_sig_reg : STD_LOGIC;

BEGIN

    -- =========================
    -- EX/MEM Pipeline Register
    -- =========================
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            alu_out_reg <= (OTHERS => '0');
            reg_data2_reg <= (OTHERS => '0');
            sp_reg <= (OTHERS => '0');
            pc_reg <= (OTHERS => '0');
            pc_inc_reg <= (OTHERS => '0');
            wb_addr_reg <= (OTHERS => '0');

            mem_wrt_en_reg <= '0';
            mem_addr_sig_reg <= (OTHERS => '0');
            mem_wrt_data_sig_reg <= (OTHERS => '0');
            wb_data_sig_reg <= (OTHERS => '0');
            reg_wrt_en_reg <= '0';
            swap_sig_reg <= '0';

        ELSIF rising_edge(clk) THEN
            alu_out_reg <= ALU_OUT_IN;
            reg_data2_reg <= REG_DATA2_IN;
            sp_reg <= SP_IN;
            pc_reg <= PC_IN;
            pc_inc_reg <= PC_INC_IN;
            wb_addr_reg <= WB_ADDR_IN;

            mem_wrt_en_reg <= MEM_WRT_EN_SIG_IN;
            mem_addr_sig_reg <= MEM_ADDR_SIG_IN;
            mem_wrt_data_sig_reg <= MEM_WRT_DATA_SIG_IN;
            wb_data_sig_reg <= WB_DATA_SIG_IN;
            reg_wrt_en_reg <= REG_WRT_EN_IN;
            swap_sig_reg <= SWAP_SIG_IN;
        END IF;
    END PROCESS;

    -- =========================
    -- Memory Address Handling
    -- (Delegated to Address Handler)
    -- =========================
    addr_handler_inst : ENTITY work.mem_addr_handler
        PORT MAP(
            sel => mem_addr_sig_reg,
            pc_addr => pc_reg,
            alu_addr => alu_out_reg,
            sp => sp_reg,
            sp_buffer => pc_inc_reg,
            mem_addr => MEM_ADDRESS
        );

    -- =========================
    -- Memory Write Enable
    -- =========================
    MEM_WRITE_ENABLE <= mem_wrt_en_reg;

    -- =========================
    -- Memory Write Data MUX
    -- =========================
    MEM_WRITE_DATA <= pc_reg WHEN mem_wrt_data_sig_reg = "00" ELSE
        pc_inc_reg WHEN mem_wrt_data_sig_reg = "01" ELSE
        sp_reg WHEN mem_wrt_data_sig_reg = "10" ELSE
        reg_data2_reg;

    -- =========================
    -- Outputs to Write Back
    -- =========================
    ALU_OUT_OUT <= alu_out_reg;
    MEM_OUT_OUT <= MEM_READ_DATA;
    READ_DATA_1_OUT <= reg_data2_reg;

    WB_ADDR_OUT <= wb_addr_reg;
    WB_DATA_SIG_OUT <= wb_data_sig_reg;
    REG_WRT_EN_OUT <= reg_wrt_en_reg;

END Behavioral;