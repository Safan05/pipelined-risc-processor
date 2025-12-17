LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY decode_stage_tb IS
END decode_stage_tb;

ARCHITECTURE behavior OF decode_stage_tb IS
    -- Component Declaration
    COMPONENT decode_stage
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

    -- Input signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL instruction : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL next_pc : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sp : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_addr : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wr_data : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL wb_en : STD_LOGIC := '0';
    SIGNAL reset_sig : STD_LOGIC := '0';
    SIGNAL int_sig : STD_LOGIC := '0';

    -- Output signals
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
    -- Instantiate DUT
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

    -- Clock generation
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
        instruction <= "00000000000000000000000000000000";
        
        -- Reset
        reset_sig <= '1';
        WAIT FOR clk_period * 2;
        reset_sig <= '0';
        WAIT FOR clk_period;

        -- Test 1: Write to registers
        REPORT "Test 1: Writing to register file";
        wb_en <= '1';
        wr_addr <= "001"; -- R1
        wr_data <= X"0000_00AA";
        WAIT FOR clk_period;

        wr_addr <= "010"; -- R2
        wr_data <= X"0000_00BB";
        WAIT FOR clk_period;

        wr_addr <= "011"; -- R3
        wr_data <= X"0000_00CC";
        WAIT FOR clk_period;
        wb_en <= '0';

        -- Test 2: ALU instruction (ADD) - OpCode 01010
        REPORT "Test 2: ADD instruction (Group 01, sub 010)";
        instruction <= "01010" & "001" & "010" & "011" & "000000000000000000";
        -- OpCode=01010, R_src1=R1, R_src2=R2, R_dst=R3
        next_pc <= X"0000_0100";
        sp <= X"0000_FFF0";
        WAIT FOR clk_period * 2;

        -- Test 3: Immediate instruction (IADD) - OpCode 01101
        REPORT "Test 3: IADD instruction";
        instruction <= "01101" & "001" & "000" & "100" & "000000000000001111";
        -- OpCode=01101, immediate value
        WAIT FOR clk_period * 2;

        -- Test 4: NOP instruction - OpCode 00001
        REPORT "Test 4: NOP instruction";
        instruction <= "00001" & "000" & "000" & "000" & "000000000000000000";
        WAIT FOR clk_period * 2;

        -- Test 5: SWAP instruction - OpCode 01001
        REPORT "Test 5: SWAP instruction";
        instruction <= "01001" & "001" & "010" & "000" & "000000000000000000";
        WAIT FOR clk_period * 3; -- SWAP takes 2 cycles

        -- Test 6: PUSH instruction - OpCode 10000
        REPORT "Test 6: PUSH instruction";
        instruction <= "10000" & "001" & "000" & "000" & "000000000000000000";
        WAIT FOR clk_period * 2;

        -- Test 7: POP instruction - OpCode 10001
        REPORT "Test 7: POP instruction";
        instruction <= "10001" & "000" & "000" & "011" & "000000000000000000";
        WAIT FOR clk_period * 2;

        -- Test 8: Branch instruction - OpCode 11000
        REPORT "Test 8: Branch instruction";
        instruction <= "11000" & "000" & "000" & "000" & "000000000000000000";
        WAIT FOR clk_period * 2;

        -- Test 9: IN instruction - OpCode 00110
        REPORT "Test 9: IN instruction";
        instruction <= "00110" & "000" & "000" & "001" & "000000000000000000";
        WAIT FOR clk_period * 2;

        -- Test 10: OUT instruction - OpCode 00101
        REPORT "Test 10: OUT instruction";
        instruction <= "00101" & "001" & "000" & "000" & "000000000000000000";
        WAIT FOR clk_period * 2;

        -- Test 11: Immediate data (OpCode 00000)
        REPORT "Test 11: Immediate data";
        instruction <= "00000" & "000" & "000" & "000" & "000000011111111111";
        WAIT FOR clk_period * 2;

        -- Test 12: INT instruction - OpCode 11010
        REPORT "Test 12: INT instruction";
        instruction <= "11010" & "000" & "000" & "000" & "000000000000000000";
        WAIT FOR clk_period * 3; -- INT takes 2 cycles

        -- Test 13: RTI instruction - OpCode 11011
        REPORT "Test 13: RTI instruction";
        instruction <= "11011" & "000" & "000" & "000" & "000000000000000000";
        WAIT FOR clk_period * 3; -- RTI takes 2 cycles

        REPORT "Testbench completed successfully";
        WAIT;
    END PROCESS;

END behavior;