-- writeBack Stage
-- Takes data from MEM/WB Register, selects write-back data (1 clock cycle)
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity writeBackStage is
    Port ( clk             : in  std_logic;
           rst             : in  std_logic;
           
           -- Inputs from MEM/WB Register (already registered)
           ALU_OUT_IN      : in  std_logic_vector(31 downto 0);
           MEM_OUT_IN      : in  std_logic_vector(31 downto 0);
           READ_DATA_1_IN  : in  std_logic_vector(31 downto 0);
           IN_PORT_IN      : in  std_logic_vector(31 downto 0);
           WB_ADDR_IN      : in  std_logic_vector(2 downto 0);
           
           -- Control Signals from MEM/WB Register
           WB_EN_IN        : in  std_logic;
           WB_DATA_SIG     : in  std_logic_vector(1 downto 0);
           
           -- Outputs to Register File
           REG_WRITE_EN    : out std_logic;
           REG_WRITE_ADDR  : out std_logic_vector(2 downto 0);
           REG_WRITE_DATA  : out std_logic_vector(31 downto 0)
         );
end writeBackStage;

architecture Behavioral of writeBackStage is
begin

    -- =============================================================
    -- Write Back MUX (COMBINATIONAL - executes in same cycle)
    -- Data is ALREADY registered in MEM/WB Register
    -- This stage is purely a MUX selection
    -- =============================================================
    -- 00: ALU Out (Used for ALU Ops, MOV, LDM - Imm passes through ALU)
    -- 01: IN Port
    -- 10: Memory Out (Used for LDD, POP)
    -- 11: Read Data 1 (Used for SWAP)
    
    REG_WRITE_DATA <= MEM_OUT_IN     when WB_DATA_SIG = "10" else
                      IN_PORT_IN     when WB_DATA_SIG = "01" else
                      READ_DATA_1_IN when WB_DATA_SIG = "11" else
                      ALU_OUT_IN;  -- Default "00"

    -- Pass-through signals to Register File
    REG_WRITE_EN   <= WB_EN_IN;
    REG_WRITE_ADDR <= WB_ADDR_IN;

end Behavioral;