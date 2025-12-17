LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY hazard_detection_unit_tb IS
END hazard_detection_unit_tb;

ARCHITECTURE test OF hazard_detection_unit_tb IS

    -- DUT port signals
    SIGNAL r_src_1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL r_src_2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL r_dst : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL read_mem : STD_LOGIC := '0';
    SIGNAL wb : STD_LOGIC := '0';

    SIGNAL pc_en : STD_LOGIC;
    SIGNAL if_id_en : STD_LOGIC;
    SIGNAL id_ex_en : STD_LOGIC;

BEGIN

    -- Instantiate the DUT
    DUT : ENTITY work.hazard_detection_unit
        PORT MAP(
            r_src_1 => r_src_1,
            r_src_2 => r_src_2,
            r_dst => r_dst,
            read_mem => read_mem,
            wb => wb,
            pc_en => pc_en,
            if_id_en => if_id_en,
            id_ex_en => id_ex_en
        );

    --------------------------------------------------------------------
    -- Stimulus process
    --------------------------------------------------------------------
    stim_proc : PROCESS
    BEGIN

        ----------------------------------------------------------------
        -- Test 1: No Hazard
        ----------------------------------------------------------------
        r_src_1 <= x"00000001";
        r_src_2 <= x"00000002";
        r_dst <= x"00000005";
        read_mem <= '0';
        wb <= '0';
        WAIT FOR 20 ns;

        ----------------------------------------------------------------
        -- Test 2: Load-use hazard on r_src_1 (stall expected)
        ----------------------------------------------------------------
        r_src_1 <= x"000000AA";
        r_src_2 <= x"000000BB";
        r_dst <= x"000000AA"; -- dependency
        read_mem <= '1';
        wb <= '1';
        WAIT FOR 20 ns;

        ----------------------------------------------------------------
        -- Test 3: Load but no dependency
        ----------------------------------------------------------------
        r_src_1 <= x"00000001";
        r_src_2 <= x"00000002";
        r_dst <= x"000000AA";
        read_mem <= '1';
        wb <= '1';
        WAIT FOR 20 ns;

        ----------------------------------------------------------------
        -- Test 4: Dependency but not a load (no stall)
        ----------------------------------------------------------------
        r_src_1 <= x"000000AA";
        r_src_2 <= x"000000BB";
        r_dst <= x"000000AA";
        read_mem <= '0';
        wb <= '1';
        WAIT FOR 20 ns;

        ----------------------------------------------------------------
        -- Test 5: Hazard on r_src_2
        ----------------------------------------------------------------
        r_src_1 <= x"11111111";
        r_src_2 <= x"22222222";
        r_dst <= x"22222222";
        read_mem <= '1';
        wb <= '1';
        WAIT FOR 20 ns;

        ----------------------------------------------------------------
        -- Test 6: Hazard on memory
        ----------------------------------------------------------------
        r_src_1 <= x"00000001";
        r_src_2 <= x"00000002";
        r_dst <= x"000000AA";
        read_mem <= '1';
        wb <= '0';
        WAIT FOR 20 ns;

        ----------------------------------------------------------------
        -- End simulation
        ----------------------------------------------------------------
        WAIT;
    END PROCESS;

END ARCHITECTURE;