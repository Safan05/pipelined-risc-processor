-- Forwarding Unit for Data Hazard Resolution
-- Detects data hazards and enables forwarding from EX/MEM and MEM/WB stages
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Forwarding_Unit IS
    PORT (
        Rsrc1, Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);          -- Source register addresses from ID/EX
        EX_MEM_Rdst, MEM_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);  -- Destination register addresses
        EX_MEM_WB_Enable, MEM_WB_WB_Enable : IN STD_LOGIC;          -- Write-back enable signals
        out0_mux1, out1_mux1 : OUT STD_LOGIC;                       -- Forward mux control for ALU input 1
        out0_mux2, out1_mux2 : OUT STD_LOGIC                        -- Forward mux control for ALU input 2
    );
END ENTITY Forwarding_Unit;

ARCHITECTURE rtl OF Forwarding_Unit IS
    SIGNAL forward_a, forward_b : STD_LOGIC_VECTOR(1 DOWNTO 0);
BEGIN

    -- =============================================================
    -- Forward A (ALU Input 1 - Rsrc1)
    -- =============================================================
    -- Priority: EX/MEM forwarding has higher priority than MEM/WB
    PROCESS(Rsrc1, EX_MEM_Rdst, MEM_WB_Rdst, EX_MEM_WB_Enable, MEM_WB_WB_Enable)
    BEGIN
        IF EX_MEM_WB_Enable = '1' AND EX_MEM_Rdst = Rsrc1 AND EX_MEM_Rdst /= "000" THEN
            -- Forward from EX/MEM stage
            forward_a <= "10";
        ELSIF MEM_WB_WB_Enable = '1' AND MEM_WB_Rdst = Rsrc1 AND MEM_WB_Rdst /= "000" THEN
            -- Forward from MEM/WB stage
            forward_a <= "01";
        ELSE
            -- No forwarding needed
            forward_a <= "00";
        END IF;
    END PROCESS;

    -- =============================================================
    -- Forward B (ALU Input 2 - Rsrc2)
    -- =============================================================
    PROCESS(Rsrc2, EX_MEM_Rdst, MEM_WB_Rdst, EX_MEM_WB_Enable, MEM_WB_WB_Enable)
    BEGIN
        IF EX_MEM_WB_Enable = '1' AND EX_MEM_Rdst = Rsrc2 AND EX_MEM_Rdst /= "000" THEN
            -- Forward from EX/MEM stage
            forward_b <= "10";
        ELSIF MEM_WB_WB_Enable = '1' AND MEM_WB_Rdst = Rsrc2 AND MEM_WB_Rdst /= "000" THEN
            -- Forward from MEM/WB stage
            forward_b <= "01";
        ELSE
            -- No forwarding needed
            forward_b <= "00";
        END IF;
    END PROCESS;

    -- Output the individual bits for the mux control
    out0_mux1 <= forward_a(0);
    out1_mux1 <= forward_a(1);
    out0_mux2 <= forward_b(0);
    out1_mux2 <= forward_b(1);

END ARCHITECTURE rtl;
