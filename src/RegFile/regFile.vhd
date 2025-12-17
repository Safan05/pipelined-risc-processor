ARCHITECTURE structural OF Reg_File IS

    COMPONENT Reg IS
        GENERIC (
            REG_WIDTH : INTEGER := 32  -- Add generic here
        );
        PORT (
            d   : IN STD_LOGIC_VECTOR(REG_WIDTH-1 DOWNTO 0); 
            q   : OUT STD_LOGIC_VECTOR(REG_WIDTH-1 DOWNTO 0); 
            rst : IN STD_LOGIC;
            we  : IN STD_LOGIC;
            clk : IN STD_LOGIC
        ); 
    END COMPONENT;

    TYPE reg_array_type IS ARRAY (0 TO NUM_REGS-1) OF std_logic_vector(REG_WIDTH-1 downto 0);
    SIGNAL reg_outputs : reg_array_type;
    SIGNAL reg_enable : std_logic_vector(NUM_REGS-1 downto 0);

BEGIN

    Generate_Registers: FOR i IN 0 TO NUM_REGS-1 GENERATE
        -- Decoder Logic
        reg_enable(i) <= '1' WHEN (we = '1' AND to_integer(unsigned(w_addr)) = i) ELSE '0';
        
        reg_inst: Reg 
        GENERIC MAP(
            REG_WIDTH => REG_WIDTH
        )
        PORT MAP(
            d   => w_data,
            q   => reg_outputs(i),
            rst => rst,
            we  => reg_enable(i),
            clk => clk
        );
    END GENERATE;

    -- Read Logic (rest remains the same)
    PROCESS (re, r_addr1, r_addr2, reg_outputs)
    BEGIN
        IF re = '1' THEN
            r_data1 <= reg_outputs(to_integer(unsigned(r_addr1)));
            r_data2 <= reg_outputs(to_integer(unsigned(r_addr2)));
        ELSE
            r_data1 <= (others => '0');
            r_data2 <= (others => '0');
        END IF;
    END PROCESS;

END structural;