-- ID/EX Pipeline Register
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ID_EX_Reg IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        en : IN STD_LOGIC;
        flush : IN STD_LOGIC;

        -- Data Inputs from Decode Stage
        read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        r_src_1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        r_src_2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        r_dst_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals from Decode (Execute Stage)
        alu_src_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_op_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        set_carry_in : IN STD_LOGIC;
        branch_in : IN STD_LOGIC;
        branch_t_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_we_in : IN STD_LOGIC;
        out_en_in : IN STD_LOGIC;
        sp_op_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        sp_or_r1_in : IN STD_LOGIC;
        sp_wrt_en_in : IN STD_LOGIC;
        imm_sig_in : IN STD_LOGIC;  -- IMM_SIG for Execute stage bypass

        -- Control Signals (Memory Stage)
        pc_sel_in : IN STD_LOGIC;
        mem_wrt_en_in : IN STD_LOGIC;
        mem_addr_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_wrt_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- Control Signals (Write Back Stage)
        wb_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        wb_addr_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_wrt_en_in : IN STD_LOGIC;
        swap_sig_in : IN STD_LOGIC;

        -- Data Outputs to Execute Stage
        read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        imm_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        r_src_1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        r_src_2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        r_dst_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals to Execute Stage
        alu_src_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        alu_op_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        set_carry_out : OUT STD_LOGIC;
        branch_out : OUT STD_LOGIC;
        branch_t_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_we_out : OUT STD_LOGIC;
        out_en_out : OUT STD_LOGIC;
        sp_op_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        sp_or_r1_out : OUT STD_LOGIC;
        sp_wrt_en_out : OUT STD_LOGIC;
        imm_sig_out : OUT STD_LOGIC;

        -- Control Signals to Memory Stage (pass-through)
        pc_sel_out : OUT STD_LOGIC;
        mem_wrt_en_out : OUT STD_LOGIC;
        mem_addr_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        mem_wrt_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

        -- Control Signals to Write Back Stage (pass-through)
        wb_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        wb_addr_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        reg_wrt_en_out : OUT STD_LOGIC;
        swap_sig_out : OUT STD_LOGIC
    );
END ENTITY;

ARCHITECTURE rtl OF ID_EX_Reg IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Data
            read_data_1_out <= (OTHERS => '0');
            read_data_2_out <= (OTHERS => '0');
            imm_out <= (OTHERS => '0');
            pc_out <= (OTHERS => '0');
            sp_out <= (OTHERS => '0');
            r_src_1_out <= (OTHERS => '0');
            r_src_2_out <= (OTHERS => '0');
            r_dst_out <= (OTHERS => '0');
            -- Execute control
            alu_src_out <= (OTHERS => '0');
            alu_op_out <= (OTHERS => '0');
            set_carry_out <= '0';
            branch_out <= '0';
            branch_t_out <= (OTHERS => '0');
            pc_we_out <= '0';
            out_en_out <= '0';
            sp_op_out <= (OTHERS => '0');
            sp_or_r1_out <= '0';
            sp_wrt_en_out <= '0';
            imm_sig_out <= '0';
            -- Memory control
            pc_sel_out <= '0';
            mem_wrt_en_out <= '0';
            mem_addr_out <= (OTHERS => '0');
            mem_wrt_data_out <= (OTHERS => '0');
            -- WB control
            wb_data_out <= (OTHERS => '0');
            wb_addr_out <= (OTHERS => '0');
            reg_wrt_en_out <= '0';
            swap_sig_out <= '0';

        ELSIF RISING_EDGE(clk) THEN
            IF flush = '1' THEN
                -- Insert bubble (NOP)
                alu_src_out <= (OTHERS => '0');
                alu_op_out <= (OTHERS => '0');
                set_carry_out <= '0';
                branch_out <= '0';
                branch_t_out <= (OTHERS => '0');
                pc_we_out <= '0';
                out_en_out <= '0';
                sp_op_out <= (OTHERS => '0');
                sp_or_r1_out <= '0';
                sp_wrt_en_out <= '0';
                imm_sig_out <= '0';
                pc_sel_out <= '0';
                mem_wrt_en_out <= '0';
                mem_addr_out <= (OTHERS => '0');
                mem_wrt_data_out <= (OTHERS => '0');
                wb_data_out <= (OTHERS => '0');
                wb_addr_out <= (OTHERS => '0');
                reg_wrt_en_out <= '0';
                swap_sig_out <= '0';
            ELSIF en = '1' THEN
                -- Data
                read_data_1_out <= read_data_1_in;
                read_data_2_out <= read_data_2_in;
                imm_out <= imm_in;
                pc_out <= pc_in;
                sp_out <= sp_in;
                r_src_1_out <= r_src_1_in;
                r_src_2_out <= r_src_2_in;
                r_dst_out <= r_dst_in;
                -- Execute control
                alu_src_out <= alu_src_in;
                alu_op_out <= alu_op_in;
                set_carry_out <= set_carry_in;
                branch_out <= branch_in;
                branch_t_out <= branch_t_in;
                pc_we_out <= pc_we_in;
                out_en_out <= out_en_in;
                sp_op_out <= sp_op_in;
                sp_or_r1_out <= sp_or_r1_in;
                sp_wrt_en_out <= sp_wrt_en_in;
                imm_sig_out <= imm_sig_in;
                -- Memory control
                pc_sel_out <= pc_sel_in;
                mem_wrt_en_out <= mem_wrt_en_in;
                mem_addr_out <= mem_addr_in;
                mem_wrt_data_out <= mem_wrt_data_in;
                -- WB control
                wb_data_out <= wb_data_in;
                wb_addr_out <= wb_addr_in;
                reg_wrt_en_out <= reg_wrt_en_in;
                swap_sig_out <= swap_sig_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
