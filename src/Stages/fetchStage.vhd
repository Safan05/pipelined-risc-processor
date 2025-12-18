LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY fetch_stage IS
    PORT (
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        mem_rdata : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF fetch_stage IS
BEGIN
    instr_out <= mem_rdata;
END ARCHITECTURE;

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY if_id_reg IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        en : IN STD_LOGIC;

        -- signal from Hazard Unit 
        flush : IN STD_LOGIC;

        instr_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_in : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        instr_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF if_id_reg IS
BEGIN
    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' OR flush = '1' THEN
            instr_out <= (OTHERS => '0'); -- NOP
            pc_out <= (OTHERS => '0');
        ELSIF RISING_EDGE(clk) THEN
            IF en = '1' THEN
                instr_out <= instr_in;
                pc_out <= pc_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;