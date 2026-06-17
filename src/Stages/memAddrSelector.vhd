LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mem_addr_handler IS
    PORT (
        addr_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_buffer : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        mem_addr : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF mem_addr_handler IS
    -- For POP: compute sp + 1 (old SP + 1 = address to read from after increment)
    SIGNAL sp_plus_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN
    sp_plus_1 <= STD_LOGIC_VECTOR(UNSIGNED(sp) + 1);
    
    WITH addr_sel SELECT
        mem_addr <= pc_addr(20 DOWNTO 0) WHEN "00",     -- Instruction fetch
                    sp_buffer(20 DOWNTO 0) WHEN "01",   -- PUSH: write to old SP
                    sp_plus_1(20 DOWNTO 0) WHEN "10",   -- POP: read from old SP + 1
                    alu_addr(20 DOWNTO 0) WHEN "11",    -- Load/Store
                    (OTHERS => '0') WHEN OTHERS;
END ARCHITECTURE;