LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mem_addr_handler IS
    PORT (
        sel : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        pc_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        alu_addr : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        sp_buffer : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        mem_addr : OUT STD_LOGIC_VECTOR(19 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF mem_addr_handler IS
BEGIN

    WITH sel SELECT
        mem_addr <=
        pc_addr(19 DOWNTO 0) WHEN "000", -- Instruction fetch
        sp_buffer(19 DOWNTO 0) WHEN "001", -- Stack buffer
        sp(19 DOWNTO 0) WHEN "010", -- Stack
        alu_addr(19 DOWNTO 0) WHEN "011", -- Load/Store
        STD_LOGIC_VECTOR(to_unsigned(0, 19)) WHEN "100", -- RESET
        STD_LOGIC_VECTOR(to_unsigned(1, 19)) WHEN "101", -- INT SIGNAL
        STD_LOGIC_VECTOR(to_unsigned(2, 19)) WHEN "110", -- INT INSTRUCTION
        STD_LOGIC_VECTOR(to_unsigned(3, 19)) WHEN OTHERS; -- default

END ARCHITECTURE;