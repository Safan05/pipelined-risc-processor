LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY ForwardUnit IS

    PORT (
        Rsrc1 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Rsrc2 : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_MEM_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        MEM_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);

        EX_MEM_WB_Enable : IN STD_LOGIC;
        MEM_WB_WB_Enable : IN STD_LOGIC;

        out0_mux1 : OUT STD_LOGIC;
        out1_mux1 : OUT STD_LOGIC;
        out0_mux2 : OUT STD_LOGIC;
        out1_mux2 : OUT STD_LOGIC

    );

END ForwardUnit;
ARCHITECTURE ForwardUnit_arch OF ForwardUnit IS

BEGIN

    PROCESS (Rsrc1, Rsrc2, EX_MEM_Rdst, MEM_WB_Rdst, EX_MEM_WB_Enable, MEM_WB_WB_Enable)
    BEGIN
        -- default (no forwarding)
        out0_mux1 <= '0';
        out1_mux1 <= '0';
        out0_mux2 <= '0';
        out1_mux2 <= '0';
        -- RSRC1 HAZARD

        IF (EX_MEM_WB_Enable = '1' AND EX_MEM_Rdst = Rsrc1 AND EX_MEM_Rdst /= "000") THEN
            out0_mux1 <= '0';
            out1_mux1 <= '1';

        ELSIF (MEM_WB_WB_Enable = '1' AND MEM_WB_Rdst = Rsrc1 AND MEM_WB_Rdst /= "000" AND NOT(EX_MEM_WB_Enable = '1' AND EX_MEM_Rdst = Rsrc1)) THEN
            out0_mux1 <= '1';
            out1_mux1 <= '0';
        END IF;
        -- RSRC2 HAZARD 
        IF (EX_MEM_WB_Enable = '1' AND EX_MEM_Rdst = Rsrc2 AND EX_MEM_Rdst /= "000") THEN
            out0_mux2 <= '0';
            out1_mux2 <= '1';

        ELSIF (MEM_WB_WB_Enable = '1' AND MEM_WB_Rdst = Rsrc2 AND MEM_WB_Rdst /= "000" AND NOT(EX_MEM_WB_Enable = '1' AND EX_MEM_Rdst = Rsrc2)) THEN
            out0_mux2 <= '1';
            out1_mux2 <= '0';
        END IF;
    END PROCESS;

END ForwardUnit_arch;