-- Pipelined Processor Top-Level Entity
-- 5-Stage Pipeline: Fetch, Decode, Execute, Memory, WriteBack
-- Quartus synthesizable for DE1-SoC

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY cpu IS
    PORT (
        clk : IN STD_LOGIC;
        reset_sig : IN STD_LOGIC;
        int_sig : IN STD_LOGIC;
        in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        out_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY cpu;

ARCHITECTURE rtl OF cpu IS

    -- ============================================================
    -- COMPONENT DECLARATIONS
    -- ============================================================

    -- Fetch Stage (includes PC, PC+1 adder, instruction fetch)
    COMPONENT fetch_stage IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            pc_en : IN STD_LOGIC;
            pc_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            pc_from_stack : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            jump_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            int_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            mem_read_data : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            mem_address : OUT STD_LOGIC_VECTOR(19 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_plus_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- Memory
    COMPONENT MEMORY IS
        GENERIC (
            ADDR_WIDTH : INTEGER := 20;
            DATA_WIDTH : INTEGER := 32;
            INIT_FILE : STRING := ""
        );
        PORT (
            CLK : IN STD_LOGIC;
            WR_EN : IN STD_LOGIC;
            ADDRESS : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
            WRITE_DATA : IN STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0);
            READ_DATA : OUT STD_LOGIC_VECTOR(DATA_WIDTH - 1 DOWNTO 0)
        );
    END COMPONENT;

    -- IF/ID Pipeline Register
    COMPONENT if_id_reg IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            en : IN STD_LOGIC;
            instr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- Decode Stage
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
            sp_or_r1 : OUT STD_LOGIC;
            sp_wrt_en : OUT STD_LOGIC;
            pc_sel, mem_wrt_en : OUT STD_LOGIC;
            mem_addr, mem_wrt_data : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            wb_data, wb_addr : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en, swap_sig : OUT STD_LOGIC
        );
    END COMPONENT;

    -- ID/EX Pipeline Register
    COMPONENT ID_EX_Reg IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            en : IN STD_LOGIC;
            flush : IN STD_LOGIC;
            read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            imm_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            r_src_1_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            r_src_2_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            r_dst_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
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
            imm_sig_in : IN STD_LOGIC;
            pc_sel_in : IN STD_LOGIC;
            mem_wrt_en_in : IN STD_LOGIC;
            mem_addr_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_wrt_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            wb_data_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            wb_addr_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en_in : IN STD_LOGIC;
            swap_sig_in : IN STD_LOGIC;
            read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            imm_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            r_src_1_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            r_src_2_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            r_dst_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
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
            pc_sel_out : OUT STD_LOGIC;
            mem_wrt_en_out : OUT STD_LOGIC;
            mem_addr_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_wrt_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            wb_data_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            wb_addr_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en_out : OUT STD_LOGIC;
            swap_sig_out : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Execute Stage
    COMPONENT executeStage IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            REG_DATA1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            REG_DATA2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            IMM_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            IMM_BYPASS : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Direct from IF/ID
            PC_INC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            PC_STACK_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            R_SRC1_ADDR : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            R_SRC2_ADDR : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            R_DST_ADDR : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            SP_VALUE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_ADDR : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            PC_INC_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            FLAGS_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            PC_BRANCH_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            SP_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            OUT_PORT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_SRC_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            ALU_OP_SIG : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            SET_CARRY_SIG : IN STD_LOGIC;
            BRANCH_SIG : IN STD_LOGIC;
            BRANCH_T_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            PC_WE_SIG : IN STD_LOGIC;
            OUT_EN_SIG : IN STD_LOGIC;
            IMM_SIG : IN STD_LOGIC;
            SP_OR_R1 : IN STD_LOGIC;
            PC_SEL_SIG : IN STD_LOGIC;
            MEM_WRT_EN_SIG : IN STD_LOGIC;
            MEM_ADDR_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            MEM_WRT_DATA_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            WB_DATA_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            WB_ADDR_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            REG_WRT_EN : IN STD_LOGIC;
            SWAP_SIG : IN STD_LOGIC;
            WB_ADDR_MEM_STAGE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            WB_ADDR_WB_STAGE : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            WB_EN_MEM_STAGE : IN STD_LOGIC;
            WB_EN_WB_STAGE : IN STD_LOGIC;
            ALU_OUT_MEM_STAGE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            ALU_OUT_WB_STAGE : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- Control Signal Outputs (pass-through)
            PC_SEL_SIG_OUT : OUT STD_LOGIC;
            MEM_WRT_EN_SIG_OUT : OUT STD_LOGIC;
            MEM_ADDR_SIG_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            MEM_WRT_DATA_SIG_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            WB_DATA_SIG_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            REG_WRT_EN_OUT : OUT STD_LOGIC;
            SWAP_SIG_OUT : OUT STD_LOGIC;
            FLUSH_OUT : OUT STD_LOGIC
        );
    END COMPONENT;


    component EX_MEM_Reg IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            en : IN STD_LOGIC;

            -- Data Inputs from Execute Stage
            alu_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- For PUSH
            read_data_2_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_inc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wb_addr_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Control Signals from Execute (Memory Stage)
            mem_wrt_en_in : IN STD_LOGIC;
            mem_addr_sig_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_wrt_data_sig_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

            -- Control Signals (Write Back Stage)
            wb_data_sig_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en_in : IN STD_LOGIC;

            -- Data Outputs to Memory Stage
            alu_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);  -- For PUSH
            read_data_2_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            pc_inc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            wb_addr_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Control Signals to Memory Stage
            mem_wrt_en_out : OUT STD_LOGIC;
            mem_addr_sig_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            mem_wrt_data_sig_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);

            -- Control Signals to Write Back Stage (pass-through)
            wb_data_sig_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en_out : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Memory Stage
    COMPONENT memoryStage IS
        PORT (
            ALU_OUT_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            REG_DATA1_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);  -- For PUSH
            REG_DATA2_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            SP_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            PC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            PC_INC_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_ADDR_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            MEM_WRT_EN_SIG_IN : IN STD_LOGIC;
            MEM_ADDR_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            MEM_WRT_DATA_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            WB_DATA_SIG_IN : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            REG_WRT_EN_IN : IN STD_LOGIC;
            MEM_READ_DATA : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_ADDRESS : OUT STD_LOGIC_VECTOR(20 DOWNTO 0);
            MEM_WRITE_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_WRITE_ENABLE : OUT STD_LOGIC;
            ALU_OUT_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_OUT_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            READ_DATA_1_OUT : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_ADDR_OUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            WB_DATA_SIG_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            REG_WRT_EN_OUT : OUT STD_LOGIC
        );
    END COMPONENT;

    component MEM_WB_Reg IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            en : IN STD_LOGIC;

            -- Data Inputs from Memory Stage
            alu_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            mem_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            wb_addr_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Control Signals from Memory Stage
            wb_data_sig_in : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en_in : IN STD_LOGIC;

            -- Data Outputs to Write Back Stage
            alu_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            mem_out_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            read_data_1_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            wb_addr_out : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);

            -- Control Signals to Write Back Stage
            wb_data_sig_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            reg_wrt_en_out : OUT STD_LOGIC
        );
    END COMPONENT;

    -- WriteBack Stage
    COMPONENT writeBackStage IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            ALU_OUT_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            MEM_OUT_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            READ_DATA_1_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            IN_PORT_IN : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            WB_ADDR_IN : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            WB_EN_IN : IN STD_LOGIC;
            WB_DATA_SIG : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            REG_WRITE_EN : OUT STD_LOGIC;
            REG_WRITE_ADDR : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            REG_WRITE_DATA : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- Hazard Detection Unit
    COMPONENT hazard_detection_unit IS
        PORT (
            id_ex_r_dst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            if_id_r_src_1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            if_id_r_src_2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            id_ex_mem_read : IN STD_LOGIC;
            pc_en : OUT STD_LOGIC;
            if_id_en : OUT STD_LOGIC;
            id_ex_flush : OUT STD_LOGIC
        );
    END COMPONENT;

    -- Stack Pointer Register
    COMPONENT SP_Reg IS
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            we : IN STD_LOGIC;
            sp_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            sp_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- ============================================================
    -- SIGNAL DECLARATIONS
    -- ============================================================

    -- PC Signals
    SIGNAL pc_current : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_plus_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL pc_sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL pc_en : STD_LOGIC;

    -- Memory Signals
    SIGNAL mem_address : STD_LOGIC_VECTOR(19 DOWNTO 0);
    SIGNAL mem_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_read_data : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_write_enable : STD_LOGIC;
    SIGNAL mem_addr_21bit : STD_LOGIC_VECTOR(20 DOWNTO 0);

    -- IF/ID Signals
    
    SIGNAL if_id_instr_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL if_id_pc_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL if_id_en : STD_LOGIC;
    SIGNAL if_id_rst : STD_LOGIC;

    -- Decode Stage Output Signals
    SIGNAL dec_read_data_1, dec_read_data_2, dec_imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dec_r_src_1, dec_r_src_2, dec_r_dst : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL dec_next_pc, dec_sp_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL dec_alu_src : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dec_alu_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL dec_set_carry, dec_branch : STD_LOGIC;
    SIGNAL dec_branch_t : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dec_pc_we, dec_out_en, dec_imm_sig : STD_LOGIC;
    SIGNAL dec_sp_op : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dec_sp_or_r1, dec_sp_wrt_en : STD_LOGIC;
    SIGNAL dec_pc_sel, dec_mem_wrt_en : STD_LOGIC;
    SIGNAL dec_mem_addr, dec_mem_wrt_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dec_wb_data, dec_wb_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL dec_reg_wrt_en, dec_swap_sig : STD_LOGIC;

    -- ID/EX Output Signals
    SIGNAL id_ex_read_data_1, id_ex_read_data_2, id_ex_imm : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL id_ex_pc, id_ex_sp : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL id_ex_r_src_1, id_ex_r_src_2, id_ex_r_dst : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL id_ex_alu_src : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL id_ex_alu_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL id_ex_set_carry, id_ex_branch : STD_LOGIC;
    SIGNAL id_ex_branch_t : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL id_ex_pc_we, id_ex_out_en : STD_LOGIC;
    SIGNAL id_ex_sp_op : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL id_ex_sp_or_r1, id_ex_sp_wrt_en : STD_LOGIC;
    SIGNAL id_ex_pc_sel, id_ex_mem_wrt_en : STD_LOGIC;
    SIGNAL id_ex_mem_addr, id_ex_mem_wrt_data : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL id_ex_wb_data, id_ex_wb_addr : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL id_ex_reg_wrt_en, id_ex_swap_sig : STD_LOGIC;
    SIGNAL id_ex_imm_sig : STD_LOGIC;  -- IMM_SIG for Execute stage bypass
    SIGNAL id_ex_flush : STD_LOGIC;

    -- Execute Stage Output Signals
    SIGNAL ex_alu_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_wb_addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ex_pc_inc_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_flags : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ex_pc_branch : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_sp_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_out_port : STD_LOGIC_VECTOR(31 DOWNTO 0);
    -- Execute Stage Control Outputs (pass-through)
    SIGNAL ex_pc_sel_out : STD_LOGIC;
    SIGNAL ex_mem_wrt_en_out : STD_LOGIC;
    SIGNAL ex_mem_addr_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ex_mem_wrt_data_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ex_wb_data_out : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ex_reg_wrt_en_out : STD_LOGIC;
    SIGNAL ex_swap_sig_out : STD_LOGIC;
    SIGNAL ex_flush_out : STD_LOGIC;  -- Flush output from Execute stage
    SIGNAL ex_flush_delayed : STD_LOGIC;  -- Delayed flush (one cycle later)

    -- EX/MEM Pipeline Buffer Output Signals
    SIGNAL ex_mem_alu_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_mem_read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- For PUSH
    SIGNAL ex_mem_read_data_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_mem_sp : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_mem_pc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_mem_pc_inc : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ex_mem_wb_addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL ex_mem_mem_wrt_en : STD_LOGIC;
    SIGNAL ex_mem_mem_addr_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ex_mem_mem_wrt_data_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ex_mem_wb_data_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL ex_mem_reg_wrt_en : STD_LOGIC;

    -- Memory Stage Output Signals
    SIGNAL mem_alu_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_mem_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_wb_addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mem_wb_data_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL mem_reg_wrt_en : STD_LOGIC;

    -- MEM/WB Pipeline Buffer Output Signals
    SIGNAL mem_wb_alu_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_wb_mem_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_wb_read_data_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_wb_wb_addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL mem_wb_wb_data_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL mem_wb_reg_wrt_en : STD_LOGIC;

    -- WriteBack Stage Output Signals
    SIGNAL wb_reg_write_en : STD_LOGIC;
    SIGNAL wb_reg_write_addr : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL wb_reg_write_data : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Stack Pointer Signals
    SIGNAL sp_current : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sp_next : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL sp_write_en : STD_LOGIC;

    -- Hazard Detection Signals
    SIGNAL hdu_pc_en, hdu_if_id_en : STD_LOGIC;
    SIGNAL hdu_id_ex_flush : STD_LOGIC;
    SIGNAL id_ex_mem_read : STD_LOGIC;
    SIGNAL mem_stall : STD_LOGIC;  -- Stall during memory operations (PUSH/POP/LDD/STD)
    SIGNAL sp_forwarded : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Forwarded SP for back-to-back stack ops

BEGIN

    -- ============================================================
    -- PC+1 CALCULATION
    -- ============================================================
    pc_plus_1 <= STD_LOGIC_VECTOR(UNSIGNED(pc_current) + 1);

    -- PC selection logic
    pc_sel <= "11" WHEN int_sig = '1' ELSE  -- Interrupt
              "10" WHEN ex_pc_sel_out = '1' ELSE  -- Branch/Jump
              "01";  -- Normal PC+1

    -- NOTE: mem_stall removed - was causing infinite stall on memory operations
    -- Memory has async read, so fetch can happen in parallel with memory stage write
    mem_stall <= '0';  -- Disabled

    -- PC enable from hazard detection
    pc_en <= hdu_pc_en AND dec_pc_we;

    -- Flush delay register: delay flush by one cycle so immediate value can be used
    process(clk, reset_sig)
    begin
        if reset_sig = '1' then
            ex_flush_delayed <= '0';
        elsif rising_edge(clk) then
            ex_flush_delayed <= ex_flush_out;
        end if;
    end process;

    -- IF/ID enable and reset
    -- Stall IF/ID when PC is stalled (SWAP, 2-word instructions, etc)
    if_id_en <= hdu_if_id_en AND dec_pc_we;
    if_id_rst <= reset_sig OR ex_flush_delayed; -- Flush on reset OR branch taken (delayed)

    -- ============================================================
    -- FETCH STAGE
    -- ============================================================
    fetch_stage_inst : fetch_stage
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        pc_en => pc_en,
        pc_sel => pc_sel,
        pc_from_stack => mem_mem_out,  -- PC from stack (RET/RTI)
        jump_pc => ex_pc_branch,
        int_pc => X"00000002",  -- Interrupt vector address
        mem_read_data => mem_read_data,  -- Instruction from memory
        mem_address => open,  -- Will use existing mem_address logic for now
        pc_out => pc_current,
        pc_plus_1_out => pc_plus_1,
        instr_out => open  -- IF/ID uses mem_read_data directly
    );

    -- ============================================================
    -- STACK POINTER REGISTER
    -- ============================================================
    -- Calculate new SP value based on SP_OP
    sp_next <= STD_LOGIC_VECTOR(UNSIGNED(sp_current) - 1) WHEN id_ex_sp_op = "10" ELSE  -- PUSH: decrement
               STD_LOGIC_VECTOR(UNSIGNED(sp_current) + 1) WHEN id_ex_sp_op = "01" ELSE  -- POP: increment
               sp_current;

    -- Forward SP to Decode stage: if Execute has PUSH/POP, use sp_next (updated value)
    sp_forwarded <= sp_next WHEN (id_ex_sp_op /= "00") ELSE sp_current;

    sp_write_en <= id_ex_sp_wrt_en;

    sp_reg_inst : SP_Reg
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        we => sp_write_en,
        sp_in => sp_next,
        sp_out => sp_current
    );

    -- ============================================================
    -- MEMORY
    -- ============================================================
    -- Memory address selection:
    -- - For memory stage operations (PUSH write OR POP/LDD read): use mem_addr_21bit
    -- - For instruction fetch only: use pc_current
    mem_address <= mem_addr_21bit(19 DOWNTO 0) WHEN (mem_write_enable = '1' OR ex_mem_mem_addr_sig /= "00") ELSE
                   pc_current(19 DOWNTO 0);

    memory_inst : MEMORY
    GENERIC MAP(
        ADDR_WIDTH => 20,
        DATA_WIDTH => 32,
        INIT_FILE => "D:/CMP/Third Year/pipelined-processor/test_program.mem"
    )
    PORT MAP(
        CLK => clk,
        WR_EN => mem_write_enable,
        ADDRESS => mem_address,
        WRITE_DATA => mem_write_data,
        READ_DATA => mem_read_data
    );

    -- ============================================================
    -- IF/ID PIPELINE REGISTER
    -- ============================================================
    if_id_reg_inst : if_id_reg
    PORT MAP(
        clk => clk,
        rst => if_id_rst,
        en => if_id_en,
        instr_in => mem_read_data,
        pc_in => pc_plus_1,
        instr_out => if_id_instr_out,
        pc_out => if_id_pc_out
    );

    -- ============================================================
    -- DECODE STAGE
    -- ============================================================
    decode_stage_inst : decode_stage
    PORT MAP(
        clk => clk,
        instruction => if_id_instr_out,
        next_pc => if_id_pc_out,
        sp => sp_current,
        wr_addr => wb_reg_write_addr,
        wr_data => wb_reg_write_data,
        wb_en => wb_reg_write_en,
        reset_sig => reset_sig,
        int_sig => int_sig,
        read_data_1 => dec_read_data_1,
        read_data_2 => dec_read_data_2,
        imm => dec_imm,
        r_src_1 => dec_r_src_1,
        r_src_2 => dec_r_src_2,
        r_dst => dec_r_dst,
        next_pc_out => dec_next_pc,
        sp_out => dec_sp_out,
        alu_src => dec_alu_src,
        alu_op => dec_alu_op,
        set_carry => dec_set_carry,
        branch => dec_branch,
        branch_t => dec_branch_t,
        pc_we => dec_pc_we,
        out_en => dec_out_en,
        imm_sig => dec_imm_sig,
        sp_op => dec_sp_op,
        sp_or_r1 => dec_sp_or_r1,
        sp_wrt_en => dec_sp_wrt_en,
        pc_sel => dec_pc_sel,
        mem_wrt_en => dec_mem_wrt_en,
        mem_addr => dec_mem_addr,
        mem_wrt_data => dec_mem_wrt_data,
        wb_data => dec_wb_data,
        wb_addr => dec_wb_addr,
        reg_wrt_en => dec_reg_wrt_en,
        swap_sig => dec_swap_sig
    );

    -- ============================================================
    -- HAZARD DETECTION UNIT
    -- ============================================================
    -- Memory read signal for load-use detection
    id_ex_mem_read <= '1' WHEN id_ex_wb_data = "10" ELSE '0';  -- WB from memory

    hazard_detection_inst : hazard_detection_unit
    PORT MAP(
        id_ex_r_dst => id_ex_r_dst,
        if_id_r_src_1 => dec_r_src_1,
        if_id_r_src_2 => dec_r_src_2,
        id_ex_mem_read => id_ex_mem_read,
        pc_en => hdu_pc_en,
        if_id_en => hdu_if_id_en,
        id_ex_flush => hdu_id_ex_flush
    );

    id_ex_flush <= hdu_id_ex_flush OR ex_flush_delayed;  -- Flush on hazard OR branch taken (delayed)

    -- ============================================================
    -- ID/EX PIPELINE REGISTER
    -- ============================================================
    id_ex_reg_inst : ID_EX_Reg
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        en => '1',
        flush => id_ex_flush,
        read_data_1_in => dec_read_data_1,
        read_data_2_in => dec_read_data_2,
        imm_in => dec_imm,  -- Normal ID/EX path (bypass is handled in Execute stage)
        pc_in => dec_next_pc,
        sp_in => sp_forwarded,  -- Use forwarded SP for back-to-back stack operations
        r_src_1_in => dec_r_src_1,
        r_src_2_in => dec_r_src_2,
        r_dst_in => dec_r_dst,
        alu_src_in => dec_alu_src,
        alu_op_in => dec_alu_op,
        set_carry_in => dec_set_carry,
        branch_in => dec_branch,
        branch_t_in => dec_branch_t,
        pc_we_in => dec_pc_we,
        out_en_in => dec_out_en,
        sp_op_in => dec_sp_op,
        sp_or_r1_in => dec_sp_or_r1,
        sp_wrt_en_in => dec_sp_wrt_en,
        imm_sig_in => dec_imm_sig,
        pc_sel_in => dec_pc_sel,
        mem_wrt_en_in => dec_mem_wrt_en,
        mem_addr_in => dec_mem_addr,
        mem_wrt_data_in => dec_mem_wrt_data,
        wb_data_in => dec_wb_data,
        wb_addr_in => dec_wb_addr,
        reg_wrt_en_in => dec_reg_wrt_en,
        swap_sig_in => dec_swap_sig,
        read_data_1_out => id_ex_read_data_1,
        read_data_2_out => id_ex_read_data_2,
        imm_out => id_ex_imm,
        pc_out => id_ex_pc,
        sp_out => id_ex_sp,
        r_src_1_out => id_ex_r_src_1,
        r_src_2_out => id_ex_r_src_2,
        r_dst_out => id_ex_r_dst,
        alu_src_out => id_ex_alu_src,
        alu_op_out => id_ex_alu_op,
        set_carry_out => id_ex_set_carry,
        branch_out => id_ex_branch,
        branch_t_out => id_ex_branch_t,
        pc_we_out => id_ex_pc_we,
        out_en_out => id_ex_out_en,
        sp_op_out => id_ex_sp_op,
        sp_or_r1_out => id_ex_sp_or_r1,
        sp_wrt_en_out => id_ex_sp_wrt_en,
        pc_sel_out => id_ex_pc_sel,
        mem_wrt_en_out => id_ex_mem_wrt_en,
        mem_addr_out => id_ex_mem_addr,
        mem_wrt_data_out => id_ex_mem_wrt_data,
        wb_data_out => id_ex_wb_data,
        wb_addr_out => id_ex_wb_addr,
        reg_wrt_en_out => id_ex_reg_wrt_en,
        swap_sig_out => id_ex_swap_sig,
        imm_sig_out => id_ex_imm_sig
    );

    -- ============================================================
    -- EXECUTE STAGE
    -- ============================================================
    execute_stage_inst : executeStage
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        REG_DATA1 => id_ex_read_data_1,
        REG_DATA2 => id_ex_read_data_2,
        IMM_DATA => id_ex_imm,
        IMM_BYPASS => if_id_instr_out,  -- Direct IF/ID to EX for 2-word instructions
        PC_INC_IN => id_ex_pc,
        PC_STACK_IN => if_id_instr_out,  -- PC from stack
        R_SRC1_ADDR => id_ex_r_src_1,
        R_SRC2_ADDR => id_ex_r_src_2,
        R_DST_ADDR => id_ex_r_dst,
        SP_VALUE => id_ex_sp,
        ALU_OUT => ex_alu_out,
        WB_ADDR => ex_wb_addr,
        PC_INC_OUT => ex_pc_inc_out,
        FLAGS_OUT => ex_flags,
        PC_BRANCH_OUT => ex_pc_branch,
        SP_OUT => ex_sp_out,
        OUT_PORT => ex_out_port,
        ALU_SRC_SIG => id_ex_alu_src,
        ALU_OP_SIG => id_ex_alu_op,
        SET_CARRY_SIG => id_ex_set_carry,
        BRANCH_SIG => id_ex_branch,
        BRANCH_T_SIG => id_ex_branch_t,
        PC_WE_SIG => id_ex_pc_we,
        OUT_EN_SIG => id_ex_out_en,
        IMM_SIG => id_ex_imm_sig,  -- From ID/EX for 2-word instruction bypass
        SP_OR_R1 => id_ex_sp_or_r1,
        PC_SEL_SIG => id_ex_pc_sel,
        MEM_WRT_EN_SIG => id_ex_mem_wrt_en,
        MEM_ADDR_SIG => id_ex_mem_addr,
        MEM_WRT_DATA_SIG => id_ex_mem_wrt_data,
        WB_DATA_SIG => id_ex_wb_data,
        WB_ADDR_SIG => id_ex_wb_addr,
        REG_WRT_EN => id_ex_reg_wrt_en,
        SWAP_SIG => id_ex_swap_sig,
        WB_ADDR_MEM_STAGE => ex_mem_wb_addr,
        WB_ADDR_WB_STAGE => mem_wb_wb_addr,
        WB_EN_MEM_STAGE => ex_mem_reg_wrt_en,
        WB_EN_WB_STAGE => mem_wb_reg_wrt_en,
        ALU_OUT_MEM_STAGE => ex_mem_alu_out,
        ALU_OUT_WB_STAGE => mem_wb_alu_out,
        -- Control Signal Outputs
        PC_SEL_SIG_OUT => ex_pc_sel_out,
        MEM_WRT_EN_SIG_OUT => ex_mem_wrt_en_out,
        MEM_ADDR_SIG_OUT => ex_mem_addr_out,
        MEM_WRT_DATA_SIG_OUT => ex_mem_wrt_data_out,
        WB_DATA_SIG_OUT => ex_wb_data_out,
        REG_WRT_EN_OUT => ex_reg_wrt_en_out,
        SWAP_SIG_OUT => ex_swap_sig_out,
        FLUSH_OUT => ex_flush_out
    );

    -- ============================================================
    -- EX/MEM PIPELINE REGISTER
    -- ============================================================
    ex_mem_reg_inst : EX_MEM_Reg
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        en => '1',
        alu_out_in => ex_alu_out,
        read_data_1_in => id_ex_read_data_1,  -- For PUSH
        read_data_2_in => id_ex_read_data_2,
        sp_in => ex_sp_out,
        pc_in => ex_pc_branch,
        pc_inc_in => ex_pc_inc_out,
        wb_addr_in => ex_wb_addr,
        mem_wrt_en_in => ex_mem_wrt_en_out,
        mem_addr_sig_in => ex_mem_addr_out,
        mem_wrt_data_sig_in => ex_mem_wrt_data_out,
        wb_data_sig_in => ex_wb_data_out,
        reg_wrt_en_in => ex_reg_wrt_en_out,
        alu_out_out => ex_mem_alu_out,
        read_data_1_out => ex_mem_read_data_1,  -- For PUSH
        read_data_2_out => ex_mem_read_data_2,
        sp_out => ex_mem_sp,
        pc_out => ex_mem_pc,
        pc_inc_out => ex_mem_pc_inc,
        wb_addr_out => ex_mem_wb_addr,
        mem_wrt_en_out => ex_mem_mem_wrt_en,
        mem_addr_sig_out => ex_mem_mem_addr_sig,
        mem_wrt_data_sig_out => ex_mem_mem_wrt_data_sig,
        wb_data_sig_out => ex_mem_wb_data_sig,
        reg_wrt_en_out => ex_mem_reg_wrt_en
    );

    -- ============================================================
    -- MEMORY STAGE
    -- ============================================================
    memory_stage_inst : memoryStage
    PORT MAP(
        ALU_OUT_IN => ex_mem_alu_out,
        REG_DATA1_IN => ex_mem_read_data_1,  -- For PUSH
        REG_DATA2_IN => ex_mem_read_data_2,
        SP_IN => ex_mem_sp,
        PC_IN => ex_mem_pc,
        PC_INC_IN => ex_mem_pc_inc,
        WB_ADDR_IN => ex_mem_wb_addr,
        MEM_WRT_EN_SIG_IN => ex_mem_mem_wrt_en,
        MEM_ADDR_SIG_IN => ex_mem_mem_addr_sig,
        MEM_WRT_DATA_SIG_IN => ex_mem_mem_wrt_data_sig,
        WB_DATA_SIG_IN => ex_mem_wb_data_sig,
        REG_WRT_EN_IN => ex_mem_reg_wrt_en,
        MEM_READ_DATA => mem_read_data,
        MEM_ADDRESS => mem_addr_21bit,
        MEM_WRITE_DATA => mem_write_data,
        MEM_WRITE_ENABLE => mem_write_enable,
        ALU_OUT_OUT => mem_alu_out,
        MEM_OUT_OUT => mem_mem_out,
        READ_DATA_1_OUT => mem_read_data_1,
        WB_ADDR_OUT => mem_wb_addr,
        WB_DATA_SIG_OUT => mem_wb_data_sig,
        REG_WRT_EN_OUT => mem_reg_wrt_en
    );

    -- ============================================================
    -- MEM/WB PIPELINE REGISTER
    -- ============================================================
    mem_wb_reg_inst : MEM_WB_Reg
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        en => '1',
        alu_out_in => mem_alu_out,
        mem_out_in => mem_mem_out,
        read_data_1_in => mem_read_data_1,
        wb_addr_in => mem_wb_addr,
        wb_data_sig_in => mem_wb_data_sig,
        reg_wrt_en_in => mem_reg_wrt_en,
        alu_out_out => mem_wb_alu_out,
        mem_out_out => mem_wb_mem_out,
        read_data_1_out => mem_wb_read_data_1,
        wb_addr_out => mem_wb_wb_addr,
        wb_data_sig_out => mem_wb_wb_data_sig,
        reg_wrt_en_out => mem_wb_reg_wrt_en
    );


    -- ============================================================
    -- WRITEBACK STAGE
    -- ============================================================
    wb_stage_inst : writeBackStage
    PORT MAP(
        clk => clk,
        rst => reset_sig,
        ALU_OUT_IN => mem_wb_alu_out,
        MEM_OUT_IN => mem_wb_mem_out,
        READ_DATA_1_IN => mem_wb_read_data_1,
        IN_PORT_IN => in_port,
        WB_ADDR_IN => mem_wb_wb_addr,
        WB_EN_IN => mem_wb_reg_wrt_en,
        WB_DATA_SIG => mem_wb_wb_data_sig,
        REG_WRITE_EN => wb_reg_write_en,
        REG_WRITE_ADDR => wb_reg_write_addr,
        REG_WRITE_DATA => wb_reg_write_data
    );

    -- ============================================================
    -- OUTPUT PORT
    -- ============================================================
    out_port <= ex_out_port;

END ARCHITECTURE rtl;