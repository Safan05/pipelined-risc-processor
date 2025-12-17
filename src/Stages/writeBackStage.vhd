-- writeBack

entity writeBackStage is
    Port ( clk             : in  std_logic;
           rst             : in  std_logic;
           
           -- Inputs from Memory Stage (to be registered in MEM/WB)
           ALU_OUT_IN      : in  std_logic_vector(31 downto 0);
           MEM_OUT_IN      : in  std_logic_vector(31 downto 0);
           READ_DATA_1_IN  : in  std_logic_vector(31 downto 0);
           IN_PORT_IN      : in  std_logic_vector(31 downto 0);
           WB_ADDR_IN      : in  std_logic_vector(2 downto 0);
           
           -- Control Signals
           WB_EN_IN        : in  std_logic;
           WB_DATA_SIG     : in  std_logic_vector(1 downto 0);
           
           -- Outputs to Register File
           REG_WRITE_EN    : out std_logic;
           REG_WRITE_ADDR  : out std_logic_vector(2 downto 0);
           REG_WRITE_DATA  : out std_logic_vector(31 downto 0)
         );
end writeBackStage;

architecture Behavioral of writeBackStage is
    -- MEM/WB Pipeline Register Signals
    signal alu_out_reg      : std_logic_vector(31 downto 0);
    signal mem_out_reg      : std_logic_vector(31 downto 0);
    signal read_data_1_reg  : std_logic_vector(31 downto 0);
    signal in_port_reg      : std_logic_vector(31 downto 0);
    signal wb_addr_reg      : std_logic_vector(2 downto 0);
    signal wb_en_reg        : std_logic;
    signal wb_data_sig_reg  : std_logic_vector(1 downto 0);
begin

    -- MEM/WB Pipeline Register
    process(clk, rst)
    begin
        if rst = '1' then
            alu_out_reg     <= (others => '0');
            mem_out_reg     <= (others => '0');
            read_data_1_reg <= (others => '0');
            in_port_reg     <= (others => '0');
            wb_addr_reg     <= (others => '0');
            wb_en_reg       <= '0';
            wb_data_sig_reg <= (others => '0');
        elsif rising_edge(clk) then
            alu_out_reg     <= ALU_OUT_IN;
            mem_out_reg     <= MEM_OUT_IN;
            read_data_1_reg <= READ_DATA_1_IN;
            in_port_reg     <= IN_PORT_IN;
            wb_addr_reg     <= WB_ADDR_IN;
            wb_en_reg       <= WB_EN_IN;
            wb_data_sig_reg <= WB_DATA_SIG;
        end if;
    end process;

    -- Write Back MUX
    -- 00: ALU Out
    -- 01: Read Data 1 (Used for SWAP, etc.)
    -- 10: Memory Out (Used for LDD, POP)
    REG_WRITE_DATA <= mem_out_reg     when wb_data_sig_reg = "10" else
                      read_data_1_reg when wb_data_sig_reg = "01" else
                      alu_out_reg; -- Default "00"

    -- Pass-through registered signals to Register File
    REG_WRITE_EN   <= wb_en_reg;
    REG_WRITE_ADDR <= wb_addr_reg;

end Behavioral;