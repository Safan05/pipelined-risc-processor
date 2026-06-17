-- decode

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY decode_stage IS
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

        -- # Execute Stage Signals
        alu_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        set_carry, branch : OUT STD_LOGIC;
        branch_t : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_we, out_en, imm_sig : OUT STD_LOGIC;
        sp_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        sp_or_r1 : OUT STD_LOGIC;           -- 1 = use SP as ALU src1
        sp_wrt_en : OUT STD_LOGIC;          -- SP register write enable

        -- # Memory Stage Signals
        pc_sel, mem_wrt_en : OUT STD_LOGIC;
        mem_addr, mem_wrt_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- # Write Back Stage Signals
        wb_data, wb_addr : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_wrt_en, swap_sig : OUT STD_LOGIC
    );
END decode_stage;

ARCHITECTURE decode_stage_logic OF decode_stage IS
    COMPONENT CU IS
        PORT (
            clk, rst, int_sig : IN STD_LOGIC;
            op_code_in : IN STD_LOGIC_VECTOR(4 DOWNTO 0);

            rd_en : OUT STD_LOGIC;

            -- # Execute Stage Signals
            alu_src : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            set_carry, branch : OUT STD_LOGIC;
            branch_t : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_we, out_en, imm_sig : OUT STD_LOGIC;
            sp_op : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            sp_or_r1 : OUT STD_LOGIC;
            sp_wrt_en : OUT STD_LOGIC;

            -- # Memory Stage Signals
            pc_sel, mem_wrt_en : OUT STD_LOGIC;
            mem_addr, mem_wrt_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

            -- # Write Back Stage Signals
            wb_data, wb_addr : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en, swap_sig : OUT STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT Reg_File IS
        GENERIC (
            NUM_REGS : INTEGER := 8;
            REG_WIDTH : INTEGER := 32;
            ADDR_WIDTH : INTEGER := 3
        );
        PORT (
            clk, rst : IN STD_LOGIC;
            re : IN STD_LOGIC;
            we : IN STD_LOGIC;

            r_addr1 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            r_addr2 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            w_addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);

            w_data : IN STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0);
            r_data1 : OUT STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0);
            r_data2 : OUT STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL rd_en : STD_LOGIC;
    SIGNAL r_addr1_sig, r_addr2_sig, r_dst_sig : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL op_code_sig : STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN

    cu_inst : CU
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        int_sig => int_sig,
        op_code_in => op_code_sig,
        rd_en => rd_en,
        alu_src => alu_src,
        alu_op => alu_op,
        set_carry => set_carry,
        branch => branch,
        branch_t => branch_t,
        pc_we => pc_we,
        out_en => out_en,
        imm_sig => imm_sig,
        sp_op => sp_op,
        sp_or_r1 => sp_or_r1,
        sp_wrt_en => sp_wrt_en,
        pc_sel => pc_sel,
        mem_wrt_en => mem_wrt_en,
        mem_addr => mem_addr,
        mem_wrt_data => mem_wrt_data,
        wb_data => wb_data,
        wb_addr => wb_addr,
        reg_wrt_en => reg_wrt_en,
        swap_sig => swap_sig
    );

    reg_file_inst : Reg_File
    GENERIC MAP(
        NUM_REGS => 8,
        REG_WIDTH => 32
    --    ADDR_WIDTH => 3
    )
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        re => rd_en,
        we => wb_en,
        r_addr1 => r_addr1_sig,
        r_addr2 => r_addr2_sig,
        w_addr => wr_addr,
        w_data => wr_data,
        r_data1 => read_data_1,
        r_data2 => read_data_2
    );

    -- =============================================================
    -- Decode Logic (COMBINATIONAL - concurrent assignments)
    -- =============================================================
    -- Extract register addresses from instruction
    r_addr1_sig <= instruction(26 DOWNTO 24);
    r_addr2_sig <= instruction(23 DOWNTO 21);
    r_dst_sig <= instruction(20 DOWNTO 18);
    op_code_sig <= instruction(31 DOWNTO 27);
    
    -- Output source register addresses to ID/EX
    r_src_1 <= r_addr1_sig;
    r_src_2 <= r_addr2_sig;
    r_dst <= r_dst_sig;
    
    -- Pass-through data
    imm <= instruction;
    next_pc_out <= next_pc;
    sp_out <= sp;

END decode_stage_logic;