LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity executeStage is
    Port (
        clk                 : in  std_logic;
        rst                 : in  std_logic;
        
        -- Data Inputs
        REG_DATA1           : in  std_logic_vector(31 downto 0);
        REG_DATA2           : in  std_logic_vector(31 downto 0);
        IMM_DATA            : in  std_logic_vector(31 downto 0);
        IMM_BYPASS          : in  std_logic_vector(31 downto 0); -- Direct from IF/ID for 2-word instr
        PC_INC_IN           : in  std_logic_vector(31 downto 0);
        PC_STACK_IN         : in  std_logic_vector(31 downto 0);
        R_SRC1_ADDR         : in  std_logic_vector(2 downto 0);
        R_SRC2_ADDR         : in  std_logic_vector(2 downto 0);
        R_DST_ADDR          : in  std_logic_vector(2 downto 0);
        SP_VALUE            : in  std_logic_vector(31 downto 0);
        
        -- Data Outputs
        ALU_OUT             : out std_logic_vector(31 downto 0);
        WB_ADDR             : out std_logic_vector(2 downto 0);
        PC_INC_OUT          : out std_logic_vector(31 downto 0);
        FLAGS_OUT           : out std_logic_vector(2 downto 0); -- Z, C, N (Sent to CU/Decode)
        PC_BRANCH_OUT       : out std_logic_vector(31 downto 0);
        SP_OUT              : out std_logic_vector(31 downto 0);
        OUT_PORT            : out std_logic_vector(31 downto 0);

        -- Control Signals (Input)
        ALU_SRC_SIG         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_OP_SIG          : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        SET_CARRY_SIG       : IN STD_LOGIC;
        BRANCH_SIG          : IN STD_LOGIC;
        BRANCH_T_SIG        : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        PC_WE_SIG           : IN STD_LOGIC;
        OUT_EN_SIG          : IN STD_LOGIC;
        IMM_SIG             : IN STD_LOGIC;
        SP_OR_R1            : IN STD_LOGIC;
        PC_SEL_SIG          : IN STD_LOGIC;
        MEM_WRT_EN_SIG      : IN STD_LOGIC;
        MEM_ADDR_SIG        : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEM_WRT_DATA_SIG    : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_DATA_SIG         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_ADDR_SIG         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRT_EN          : IN STD_LOGIC;
        SWAP_SIG            : IN STD_LOGIC;

        -- Forwarding Unit Inputs
        WB_ADDR_MEM_STAGE   : in  std_logic_vector(2 downto 0);
        WB_ADDR_WB_STAGE    : in  std_logic_vector(2 downto 0);
        WB_EN_MEM_STAGE     : in  std_logic;
        WB_EN_WB_STAGE      : in  std_logic;
        ALU_OUT_MEM_STAGE   : in  std_logic_vector(31 downto 0);
        ALU_OUT_WB_STAGE    : in  std_logic_vector(31 downto 0);

        -- Control Signal Outputs (pass-through to EX/MEM)
        PC_SEL_SIG_OUT      : out std_logic;
        MEM_WRT_EN_SIG_OUT  : out std_logic;
        MEM_ADDR_SIG_OUT    : out std_logic_vector(1 downto 0);
        MEM_WRT_DATA_SIG_OUT: out std_logic_vector(1 downto 0);
        WB_DATA_SIG_OUT     : out std_logic_vector(1 downto 0);
        REG_WRT_EN_OUT      : out std_logic;
        SWAP_SIG_OUT        : out std_logic;
        
        -- Flush output (to flush IF/ID and ID/EX when branch taken)
        FLUSH_OUT           : out std_logic
    );
end executeStage;

architecture Behavioral of executeStage is
    
    -- Component Declarations
    component ALU is
    PORT (
        A, B: IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        OP: IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        RESULT: OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        COUT, ZERO, NEGATIVE: OUT STD_LOGIC
    );
    end component;

    component ForwardUnit is
    PORT (
        Rsrc1, Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_MEM_Rdst, MEM_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_MEM_WB_Enable, MEM_WB_WB_Enable : IN STD_LOGIC;
        out0_mux1, out1_mux1, out0_mux2, out1_mux2 : OUT STD_LOGIC
    );
    end component;

    -- Internal Signals
    SIGNAL Forward_mux_0, Forward_mux_1 : STD_LOGIC_VECTOR(1 DOWNTO 0);
    
    -- Registers for ALU Inputs (Because Muxes are Sequential)
    SIGNAL ALU_IN1, ALU_IN2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    -- Wires from ALU (Combinational)
    SIGNAL ALU_RESULT_WIRE : STD_LOGIC_VECTOR(31 downto 0);
    SIGNAL ZERO_WIRE, CARRY_WIRE, NEG_WIRE : STD_LOGIC;
    
    -- Branch taken signal (combinational)
    SIGNAL branch_taken : STD_LOGIC;
    
    -- Mux Output Holders
    SIGNAL SRC_SEL1_OUT, SRC_SEL2_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    -- Flag Register (Stores flags from PREVIOUS instruction)
    -- Bit 0: Zero, Bit 1: Carry, Bit 2: Negative
    SIGNAL FLAG_REGISTER : STD_LOGIC_VECTOR(2 downto 0) := (others => '0'); 
begin

    -- 1. Hardware Instantiation (Must be outside process)
    -- The ALU continuously computes based on whatever is currently in ALU_IN1/ALU_IN2
    ALU_INST: ALU
    PORT MAP (
        A => ALU_IN1,
        B => ALU_IN2,
        OP => ALU_OP_SIG,
        RESULT => ALU_RESULT_WIRE,
        COUT => CARRY_WIRE,
        ZERO => ZERO_WIRE,
        NEGATIVE => NEG_WIRE
    );

    MAP_FwdUnit: ForwardUnit
    PORT MAP (
        Rsrc1 => R_SRC1_ADDR,
        Rsrc2 => R_SRC2_ADDR,
        EX_MEM_Rdst => WB_ADDR_MEM_STAGE,
        MEM_WB_Rdst => WB_ADDR_WB_STAGE,
        EX_MEM_WB_Enable => WB_EN_MEM_STAGE,
        MEM_WB_WB_Enable => WB_EN_WB_STAGE,
        out0_mux1 => Forward_mux_0(0),
        out1_mux1 => Forward_mux_0(1),
        out0_mux2 => Forward_mux_1(0),
        out1_mux2 => Forward_mux_1(1)
    );

    -- ============================================================
    -- COMBINATIONAL PROCESS: ALU Input Selection (No clock delay)
    -- ============================================================
    ALU_INPUT_MUX: process(Forward_mux_0, Forward_mux_1, SP_OR_R1, SP_VALUE, REG_DATA1, REG_DATA2,
                           ALU_SRC_SIG, IMM_SIG, IMM_BYPASS, IMM_DATA,
                           ALU_OUT_MEM_STAGE, ALU_OUT_WB_STAGE)
    begin
        -- ALU Input 1 Selection (with forwarding)
        if Forward_mux_0 = "10" then
            ALU_IN1 <= ALU_OUT_MEM_STAGE;  -- Forward from EX/MEM
        elsif Forward_mux_0 = "01" then
            ALU_IN1 <= ALU_OUT_WB_STAGE;   -- Forward from MEM/WB
        else
            -- Default: Normal input (no forwarding, or undefined)
            if SP_OR_R1 = '1' then
                ALU_IN1 <= SP_VALUE;
            else
                ALU_IN1 <= REG_DATA1;
            end if;
        end if;

        -- ALU Input 2 Selection (with forwarding)
        if Forward_mux_1 = "10" then
            ALU_IN2 <= ALU_OUT_MEM_STAGE;  -- Forward from EX/MEM
        elsif Forward_mux_1 = "01" then
            ALU_IN2 <= ALU_OUT_WB_STAGE;   -- Forward from MEM/WB
        else
            -- Default: Normal input (no forwarding, or undefined)
            if ALU_SRC_SIG = "00" then
                ALU_IN2 <= X"00000001";    -- Constant 1 (for INC)
            elsif ALU_SRC_SIG = "01" then
                ALU_IN2 <= REG_DATA2;      -- Register
            else
                -- Immediate mode (ALU_SRC_SIG = "10" or "11")
                if IMM_SIG = '1' then
                    -- Full 32-bit immediate from 2-word instruction
                    ALU_IN2 <= IMM_BYPASS;
                else
                    ALU_IN2 <= IMM_DATA;   -- From ID/EX buffer
                end if;
            end if;
        end if;

        -- SRC_SEL outputs (for debugging/visibility)
        if SP_OR_R1 = '1' then
            SRC_SEL1_OUT <= SP_VALUE;
        else
            SRC_SEL1_OUT <= REG_DATA1;
        end if;

        if ALU_SRC_SIG = "00" then
            SRC_SEL2_OUT <= X"00000001";
        elsif ALU_SRC_SIG = "01" then
            SRC_SEL2_OUT <= REG_DATA2;
        else
            if IMM_SIG = '1' then
                SRC_SEL2_OUT <= X"0000" & IMM_BYPASS(31 downto 16);
            else
                SRC_SEL2_OUT <= IMM_DATA;
            end if;
        end if;
    end process ALU_INPUT_MUX;

    -- ============================================================
    -- SEQUENTIAL PROCESS: Output Capture Only
    -- ============================================================
    process(clk, rst)
    variable BRANCH_T_COND : std_logic;
    begin
        if rst = '1' then
            -- Only reset REGISTERED signals (combinational ones don't need reset)
            OUT_PORT <= (others => '0');
            FLAG_REGISTER <= (others => '0');
            
        elsif rising_edge(clk) then

            -- ==========================================================
            -- BRANCH CALCULATION (needs FLAG_REGISTER which is clocked)
            -- ==========================================================
            -- Branch Calculation
            
            if (BRANCH_T_SIG = "00") then
                BRANCH_T_COND := '1'; -- Unconditional
            elsif (BRANCH_T_SIG = "01") then
                BRANCH_T_COND := FLAG_REGISTER(0); -- Zero
            elsif (BRANCH_T_SIG = "10") then
                BRANCH_T_COND := FLAG_REGISTER(1); -- Carry
            else
                BRANCH_T_COND := FLAG_REGISTER(2); -- Negative
            end if;
            
            -- Branch condition check (used for flag updates, not for PC_BRANCH_OUT)
            -- PC_BRANCH_OUT is now calculated combinationally outside this process
            -- ==========================================================
            -- C. FLAG LOGIC (Read Old -> Write New)
            -- ==========================================================
            -- FLAGS_OUT is now combinational (outputs FLAG_REGISTER directly) 

            -- 2. Update to NEW flags (Will be available NEXT cycle)
            -- Note: We generally don't update flags on Branch instructions
            if (SET_CARRY_SIG = '1') then
                FLAG_REGISTER(1) <= '1';
            elsif (BRANCH_SIG = '0') then 
                FLAG_REGISTER(0) <= ZERO_WIRE;
                FLAG_REGISTER(1) <= CARRY_WIRE;
                FLAG_REGISTER(2) <= NEG_WIRE;
            end if;


            -- ==========================================================
            -- D. OUTPUT PORT (Registered)
            -- ==========================================================
            if (OUT_EN_SIG = '1') then
                OUT_PORT <= ALU_RESULT_WIRE;
            end if;

        end if;
    end process;

    -- =============================================================
    -- COMBINATIONAL OUTPUTS (No clock delay - EX/MEM register latches these)
    -- =============================================================
    
    -- Branch condition based on type (COMBINATIONAL)
    -- BRANCH_T_SIG: 00=Unconditional, 01=Zero, 10=Carry, 11=Negative
    WITH BRANCH_T_SIG SELECT
        branch_taken <= BRANCH_SIG AND PC_SEL_SIG AND '1' WHEN "00",  -- JMP (unconditional)
                        BRANCH_SIG AND PC_SEL_SIG AND FLAG_REGISTER(0) WHEN "01",  -- JZ
                        BRANCH_SIG AND PC_SEL_SIG AND FLAG_REGISTER(1) WHEN "10",  -- JC
                        BRANCH_SIG AND PC_SEL_SIG AND FLAG_REGISTER(2) WHEN OTHERS;  -- JN
    
    -- ALU Output (directly from ALU, no internal register)
    ALU_OUT <= ALU_RESULT_WIRE;
    
    -- Control Signal Pass-through (combinational)
    -- PC_SEL_SIG_OUT is set only when branch is ACTUALLY taken
    PC_SEL_SIG_OUT <= branch_taken;
    MEM_WRT_EN_SIG_OUT <= MEM_WRT_EN_SIG;
    MEM_ADDR_SIG_OUT <= MEM_ADDR_SIG;
    MEM_WRT_DATA_SIG_OUT <= MEM_WRT_DATA_SIG;
    WB_DATA_SIG_OUT <= WB_DATA_SIG;
    REG_WRT_EN_OUT <= REG_WRT_EN;
    SWAP_SIG_OUT <= SWAP_SIG;
    
    -- Flush output: when branch is taken, flush IF/ID and ID/EX
    FLUSH_OUT <= branch_taken;
    
    -- Data pass-through (combinational)
    SP_OUT <= SP_VALUE;
    PC_INC_OUT <= PC_INC_IN;
    
    -- Flags output (combinational from registered FLAG_REGISTER)
    FLAGS_OUT <= FLAG_REGISTER;
    
    -- Write-back Address MUX (combinational)
    WB_ADDR <= R_SRC1_ADDR WHEN WB_ADDR_SIG = "00" ELSE
               R_SRC2_ADDR WHEN WB_ADDR_SIG = "01" ELSE
               R_DST_ADDR;

    -- Branch target (combinational) - goes to Fetch stage via cpu.vhd
    -- For JMP/JZ/JC/JN: target is full 32-bit immediate from 2-word instruction
    -- For RET/RTI: target is PC_STACK_IN (from memory)
    PC_BRANCH_OUT <= IMM_BYPASS WHEN branch_taken = '1' ELSE
                     PC_STACK_IN WHEN PC_SEL_SIG = '0' ELSE
                     PC_INC_IN;

end Behavioral;