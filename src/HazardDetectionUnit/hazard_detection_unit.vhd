-- Hazard Detection Unit
-- Detects load-use hazards and generates stall signals
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY hazard_detection_unit IS
    PORT (
        -- Register addresses from ID/EX stage
        id_ex_r_dst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        -- Register addresses from IF/ID stage (current decode)
        if_id_r_src_1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        if_id_r_src_2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        
        -- Control signals
        id_ex_mem_read : IN STD_LOGIC;  -- Memory read in EX stage
        
        -- Stall/Enable signals
        pc_en : OUT STD_LOGIC;          -- PC enable (0 = stall)
        if_id_en : OUT STD_LOGIC;       -- IF/ID register enable (0 = stall)
        id_ex_flush : OUT STD_LOGIC     -- Insert bubble in ID/EX
    );
END hazard_detection_unit;

ARCHITECTURE rtl OF hazard_detection_unit IS
    SIGNAL stall : STD_LOGIC;
BEGIN
    -- Detect load-use hazard:
    -- If EX stage is doing a memory read AND
    -- The destination register matches one of the source registers in decode
    stall <= '1' WHEN (id_ex_mem_read = '1' AND 
                       id_ex_r_dst /= "000" AND  -- Not R0
                       (id_ex_r_dst = if_id_r_src_1 OR id_ex_r_dst = if_id_r_src_2))
             ELSE '0';
    
    -- Output signals
    pc_en <= NOT stall;
    if_id_en <= NOT stall;
    id_ex_flush <= stall;  -- Insert NOP when stalling

END rtl;