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
        PC_INC_IN           : in  std_logic_vector(31 downto 0);
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

        -- Control Signals (Output Pass-through)
        PC_SEL_SIG_OUT      : OUT STD_LOGIC;
        MEM_WRT_EN_SIG_OUT  : OUT STD_LOGIC;
        MEM_ADDR_SIG_OUT    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        MEM_WRT_DATA_SIG_OUT: OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        WB_DATA_SIG_OUT     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_WRT_EN_OUT      : OUT STD_LOGIC;
        SWAP_SIG_OUT        : OUT STD_LOGIC;

        -- Forwarding Unit Inputs
        WB_ADDR_MEM_STAGE   : in  std_logic_vector(2 downto 0);
        WB_ADDR_WB_STAGE    : in  std_logic_vector(2 downto 0);
        WB_EN_MEM_STAGE     : in  std_logic;
        WB_EN_WB_STAGE      : in  std_logic;
        ALU_OUT_MEM_STAGE   : in  std_logic_vector(31 downto 0);
        ALU_OUT_WB_STAGE    : in  std_logic_vector(31 downto 0)
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

    component Forwarding_Unit is
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

    PORT MAP_FwdUnit: Forwarding_Unit
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

    -- 2. Sequential Process (Clocked Logic)
    process(clk, rst)
    begin
        if rst = '1' then
            ALU_OUT <= (others => '0');
            OUT_PORT <= (others => '0');
            FLAG_REGISTER <= (others => '0');
            
        elsif rising_edge(clk) then

            -- ==========================================================
            -- A. INPUT MUXES (Latched Muxes per your request)
            -- ==========================================================
            -- SRC 1 Selection
            if (SP_OR_R1 = '1') then
                SRC_SEL1_OUT <= SP_VALUE;
            else
                SRC_SEL1_OUT <= REG_DATA1;
            end if;

            -- SRC 2 Selection
            if (ALU_SRC_SIG = "00") then
                SRC_SEL2_OUT <= X"00000001"; -- Constant 1
            elsif (ALU_SRC_SIG = "01") then
                SRC_SEL2_OUT <= REG_DATA2;   -- Register
            else
                SRC_SEL2_OUT <= IMM_DATA;    -- Immediate
            end if;

            -- Forwarding Mux 1 (Registers the chosen input into ALU_IN1)
            if (Forward_mux_0 = "00") then
                ALU_IN1 <= SRC_SEL1_OUT; -- Use current Mux choice
            elsif (Forward_mux_0 = "01") then
                ALU_IN1 <= ALU_OUT_WB_STAGE;
            else
                ALU_IN1 <= ALU_OUT_MEM_STAGE;
            end if;

            -- Forwarding Mux 2 (Registers the chosen input into ALU_IN2)
            if (Forward_mux_1 = "00") then
                ALU_IN2 <= SRC_SEL2_OUT; -- Use current Mux choice
            elsif (Forward_mux_1 = "01") then
                ALU_IN2 <= ALU_OUT_WB_STAGE;
            else
                ALU_IN2 <= ALU_OUT_MEM_STAGE;
            end if;


            -- ==========================================================
            -- B. OUTPUT CAPTURE
            -- ==========================================================
            -- Capture ALU Result (Logic result from inputs set in previous cycle)
            ALU_OUT <= ALU_RESULT_WIRE;

            -- Pass-through Control Signals
            PC_SEL_SIG_OUT      <= PC_SEL_SIG;
            MEM_WRT_EN_SIG_OUT  <= MEM_WRT_EN_SIG;
            MEM_ADDR_SIG_OUT    <= MEM_ADDR_SIG;
            MEM_WRT_DATA_SIG_OUT<= MEM_WRT_DATA_SIG;
            WB_DATA_SIG_OUT     <= WB_DATA_SIG;
            REG_WRT_EN_OUT      <= REG_WRT_EN;
            SWAP_SIG_OUT        <= SWAP_SIG;

            SP_OUT      <= SP_VALUE;
            PC_INC_OUT  <= PC_INC_IN;
            
            -- Branch Calculation
            

            -- ==========================================================
            -- C. FLAG LOGIC (Read Old -> Write New)
            -- ==========================================================
            
            -- 1. Output the OLD flags (Available for Control Unit/Branching NOW)
            FLAGS_OUT <= FLAG_REGISTER; 

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
            -- D. MISC OUTPUTS
            -- ==========================================================
            -- Write Back Address Mux
            if (WB_ADDR_SIG = "00") then
                WB_ADDR <= R_SRC1_ADDR;
            elsif (WB_ADDR_SIG = "01") then
                WB_ADDR <= R_SRC2_ADDR;
            else
                WB_ADDR <= R_DST_ADDR;
            end if;

            -- Output Port
            if (OUT_EN_SIG = '1') then
                OUT_PORT <= REG_DATA1;
            end if;

        end if;
    end process;

end Behavioral;