-- MEM/WB Pipeline Register
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY MEM_WB_Reg IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        en : IN STD_LOGIC;

        -- Data Inputs from Memory Stage
        alu_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_out_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        read_data_1_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        wb_addr_in : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        -- Control Signals from Memory (Write Back Stage)
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
END ENTITY;

ARCHITECTURE rtl OF MEM_WB_Reg IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            -- Data
            alu_out_out <= (OTHERS => '0');
            mem_out_out <= (OTHERS => '0');
            read_data_1_out <= (OTHERS => '0');
            wb_addr_out <= (OTHERS => '0');
            -- Control
            wb_data_sig_out <= (OTHERS => '0');
            reg_wrt_en_out <= '0';

        ELSIF RISING_EDGE(clk) THEN
            IF en = '1' THEN
                -- Data
                alu_out_out <= alu_out_in;
                mem_out_out <= mem_out_in;
                read_data_1_out <= read_data_1_in;
                wb_addr_out <= wb_addr_in;
                -- Control
                wb_data_sig_out <= wb_data_sig_in;
                reg_wrt_en_out <= reg_wrt_en_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;
