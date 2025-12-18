library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
ENTITY mem_addr_handler IS
    PORT (
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        pc_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_buffer : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        mem_addr : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF mem_addr_handler IS
BEGIN
    WITH sel SELECT
        mem_addr <= pc_addr WHEN "00", -- Instruction fetch
        sp_buffer WHEN "01", -- Stack buffer
        sp WHEN "10", -- Stack
        alu_addr WHEN "11", -- Load/Store
        (OTHERS => '0') WHEN OTHERS;
END ARCHITECTURE;