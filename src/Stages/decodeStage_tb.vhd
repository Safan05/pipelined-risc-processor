LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY decode_stage_tb IS
END decode_stage_tb;

ARCHITECTURE behavior OF decode_stage_tb IS
    -- Component Declaration
    COMPONENT decode_stage IS
        PORT (
            clk : IN STD_LOGIC;
            instruction : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            next_pc, sp : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wr_addr : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            wr_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wb_en : IN STD_LOGIC;
            reset_sig, int_sig : IN STD_LOGIC;
            read_data_1, read_data_2, imm : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            r_src_1, r_src_2, r_dst : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            next_pc_out, sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            alu_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            set_carry, branch : OUT STD_LOGIC;
            branch_t : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_we, out_en, imm_sig : OUT STD_LOGIC;
            sp_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_sel, mem_wrt_en : OUT STD_LOGIC;
            mem_addr, mem_wrt_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            wb_data, wb_addr : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en, swap_sig : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Test Signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL instruction : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL next_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sp : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_addr : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wb_en : STD_LOGIC := '0';
    SIGNAL reset_sig : STD_LOGIC := '0';
    SIGNAL int_sig : STD_LOGIC := '0';

    -- Output Signals
    SIGNAL read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL r_src_1 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL r_src_2 : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL r_dst : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL next_pc_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sp_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL alu_src : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL alu_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL set_carry : STD_LOGIC;
    SIGNAL branch : STD_LOGIC;
    SIGNAL branch_t : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pc_we : STD_LOGIC;
    SIGNAL out_en : STD_LOGIC;
    SIGNAL imm_sig : STD_LOGIC;
    SIGNAL sp_op : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pc_sel : STD_LOGIC;
    SIGNAL mem_wrt_en : STD_LOGIC;
    SIGNAL mem_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL mem_wrt_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL wb_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL wb_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL reg_wrt_en : STD_LOGIC;
    SIGNAL swap_sig : STD_LOGIC;

    -- Clock period
    CONSTANT clk_period : TIME := 10 ns;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut : decode_stage
    PORT MAP(
        clk => clk,
        instruction => instruction,
        next_pc => next_pc,
        sp => sp,
        wr_addr => wr_addr,
        wr_data => wr_data,
        wb_en => wb_en,
        reset_sig => reset_sig,
        int_sig => int_sig,
        read_data_1 => read_data_1,
        read_data_2 => read_data_2,
        imm => imm,
        r_src_1 => r_src_1,
        r_src_2 => r_src_2,
        r_dst => r_dst,
        next_pc_out => next_pc_out,
        sp_out => sp_out,
        alu_src => alu_src,
        alu_op => alu_op,
        set_carry => set_carry,
        branch => branch,
        branch_t => branch_t,
        pc_we => pc_we,
        out_en => out_en,
        imm_sig => imm_sig,
        sp_op => sp_op,
        pc_sel => pc_sel,
        mem_wrt_en => mem_wrt_en,
        mem_addr => mem_addr,
        mem_wrt_data => mem_wrt_data,
        wb_data => wb_data,
        wb_addr => wb_addr,
        reg_wrt_en => reg_wrt_en,
        swap_sig => swap_sig
    );

    -- Clock process
    clk_process : PROCESS
    BEGIN
        clk <= '0';
        WAIT FOR clk_period/2;
        clk <= '1';
        WAIT FOR clk_period/2;
    END PROCESS;

    -- Stimulus process
    stim_proc : PROCESS
    BEGIN
        -- Initialize
        REPORT "Starting Decode Stage Testbench";
        
        -- Reset
        reset_sig <= '1';
        WAIT FOR clk_period * 2;
        reset_sig <= '0';
        WAIT FOR clk_period;

        -- Test Case 1: Basic instruction decode
        -- instruction[31:27] = 5'b10101, [26:24] = 3'b011, [23:21] = 3'b100, [20:18] = 3'b101
        REPORT "Test Case 1: Basic instruction decode";
        instruction <= "10101" & "011" & "100" & "101" & "000000000000000000";
        next_pc <= X"00000100";
        sp <= X"00001000";
        WAIT FOR clk_period;
        
        ASSERT r_src_1 = "011" REPORT "r_src_1 should be 011" SEVERITY ERROR;
        ASSERT r_src_2 = "100" REPORT "r_src_2 should be 100" SEVERITY ERROR;
        ASSERT r_dst = "101" REPORT "r_dst should be 101" SEVERITY ERROR;
        ASSERT next_pc_out = X"00000100" REPORT "next_pc_out mismatch" SEVERITY ERROR;
        ASSERT sp_out = X"00001000" REPORT "sp_out mismatch" SEVERITY ERROR;

        -- Test Case 2: Write to register file
        REPORT "Test Case 2: Write to register file";
        wr_addr <= "011";  -- Write to register 3
        wr_data <= X"DEADBEEF";
        wb_en <= '1';
        WAIT FOR clk_period;
        wb_en <= '0';
        WAIT FOR clk_period;

        -- Test Case 3: Read from register file
        REPORT "Test Case 3: Read from written register";
        instruction <= "00000" & "011" & "100" & "101" & "000000000000000000";
        WAIT FOR clk_period;
        -- read_data_1 should now contain the written data

        -- Test Case 4: Test immediate value extraction
        REPORT "Test Case 4: Immediate value extraction";
        instruction <= X"F5A4ABCD";  -- Lower 16 bits: 0xABCD
        WAIT FOR clk_period;
        ASSERT imm = X"F5A4ABCD" REPORT "imm mismatch" SEVERITY ERROR;

        -- Test Case 5: Different register addresses
        REPORT "Test Case 5: Different register addresses";
        instruction <= "11111" & "111" & "000" & "001" & "000000000000000000";
        WAIT FOR clk_period;
        
        ASSERT r_src_1 = "111" REPORT "r_src_1 should be 111" SEVERITY ERROR;
        ASSERT r_src_2 = "000" REPORT "r_src_2 should be 000" SEVERITY ERROR;
        ASSERT r_dst = "001" REPORT "r_dst should be 001" SEVERITY ERROR;

        -- Test Case 6: Write multiple registers
        REPORT "Test Case 6: Write to multiple registers";
        FOR i IN 0 TO 7 LOOP
            wr_addr <= STD_LOGIC_VECTOR(to_unsigned(i, 3));
            wr_data <= STD_LOGIC_VECTOR(to_unsigned(i * 100, 32));
            wb_en <= '1';
            WAIT FOR clk_period;
        END LOOP;
        wb_en <= '0';

        -- Test Case 7: Read from multiple registers
        REPORT "Test Case 7: Read from multiple registers";
        FOR i IN 0 TO 6 LOOP
            instruction <= "00000" & 
                          STD_LOGIC_VECTOR(to_unsigned(i, 3)) & 
                          STD_LOGIC_VECTOR(to_unsigned(i + 1, 3)) & 
                          "000" & "000000000000000000";
            WAIT FOR clk_period;
        END LOOP;

        -- Test Case 8: Test interrupt signal
        REPORT "Test Case 8: Interrupt signal";
        int_sig <= '1';
        instruction <= X"12345678";
        WAIT FOR clk_period * 2;
        int_sig <= '0';
        WAIT FOR clk_period;

        -- Test Case 9: Reset during operation
        REPORT "Test Case 9: Reset during operation";
        instruction <= X"FFFFFFFF";
        WAIT FOR clk_period;
        reset_sig <= '1';
        WAIT FOR clk_period * 2;
        reset_sig <= '0';
        WAIT FOR clk_period;

        -- Test Case 10: Edge case - all zeros
        REPORT "Test Case 10: All zeros instruction";
        instruction <= X"00000000";
        next_pc <= X"00000000";
        sp <= X"00000000";
        WAIT FOR clk_period;

        -- End simulation
        REPORT "Testbench completed successfully";
        WAIT;
    END PROCESS;

END behavior;