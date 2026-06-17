-- EX/MEM Pipeline Register
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY EX_MEM_Reg IS
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
END ENTITY;

ARCHITECTURE rtl OF EX_MEM_Reg IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Data
            alu_out_out <= (OTHERS => '0');
            read_data_1_out <= (OTHERS => '0');
            read_data_2_out <= (OTHERS => '0');
            sp_out <= (OTHERS => '0');
            pc_out <= (OTHERS => '0');
            pc_inc_out <= (OTHERS => '0');
            wb_addr_out <= (OTHERS => '0');
            -- Memory control
            mem_wrt_en_out <= '0';
            mem_addr_sig_out <= (OTHERS => '0');
            mem_wrt_data_sig_out <= (OTHERS => '0');
            -- WB control
            wb_data_sig_out <= (OTHERS => '0');
            reg_wrt_en_out <= '0';

        ELSIF RISING_EDGE(clk) THEN
            IF en = '1' THEN
                -- Data
                alu_out_out <= alu_out_in;
                read_data_1_out <= read_data_1_in;
                read_data_2_out <= read_data_2_in;
                sp_out <= sp_in;
                pc_out <= pc_in;
                pc_inc_out <= pc_inc_in;
                wb_addr_out <= wb_addr_in;
                -- Memory control
                mem_wrt_en_out <= mem_wrt_en_in;
                mem_addr_sig_out <= mem_addr_sig_in;
                mem_wrt_data_sig_out <= mem_wrt_data_sig_in;
                -- WB control
                wb_data_sig_out <= wb_data_sig_in;
                reg_wrt_en_out <= reg_wrt_en_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
