-- CPU Testbench
-- Tests the pipelined processor with a simple program

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;

ENTITY cpu_tb IS
END ENTITY cpu_tb;

ARCHITECTURE behavioral OF cpu_tb IS

    -- Component Declaration
    COMPONENT cpu IS
        PORT (
            clk : IN STD_LOGIC;
            reset_sig : IN STD_LOGIC;
            int_sig : IN STD_LOGIC;
            in_port : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            out_port : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    -- Testbench Signals
    SIGNAL clk : STD_LOGIC := '0';
    SIGNAL reset_sig : STD_LOGIC := '0';
    SIGNAL int_sig : STD_LOGIC := '0';
    SIGNAL in_port : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL out_port : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Clock period (50 MHz)
    CONSTANT CLK_PERIOD : TIME := 20 ns;

    -- Simulation control
    SIGNAL sim_done : BOOLEAN := FALSE;

BEGIN

    -- Clock generation
    clk_process : PROCESS
    BEGIN
        WHILE NOT sim_done LOOP
            clk <= '0';
            WAIT FOR CLK_PERIOD / 2;
            clk <= '1';
            WAIT FOR CLK_PERIOD / 2;
        END LOOP;
        WAIT;
    END PROCESS;

    -- DUT instantiation
    dut : cpu
    PORT MAP(
        clk => clk,
        reset_sig => reset_sig,
        int_sig => int_sig,
        in_port => in_port,
        out_port => out_port
    );

    -- Stimulus process
    stimulus : PROCESS
    BEGIN
        -- Reset sequence
        REPORT "Starting CPU testbench..." SEVERITY NOTE;
        reset_sig <= '1';
        WAIT FOR CLK_PERIOD * 5;
        reset_sig <= '0';
        REPORT "Reset released." SEVERITY NOTE;

        -- Let the processor run for some cycles
        -- The memory should be pre-loaded with test program
        WAIT FOR CLK_PERIOD * 500;

        -- Test IN instruction
        REPORT "Testing IN port with value 0x12345678" SEVERITY NOTE;
        in_port <= X"12345678";
        WAIT FOR CLK_PERIOD * 10;

        -- Wait for more cycles
        WAIT FOR CLK_PERIOD * 500;

        -- Check output
        REPORT "Output port value: " & INTEGER'IMAGE(TO_INTEGER(UNSIGNED(out_port))) SEVERITY NOTE;

        -- End simulation
        REPORT "Testbench completed successfully." SEVERITY NOTE;
        sim_done <= TRUE;
        WAIT;
    END PROCESS;

    -- Monitor process
    monitor : PROCESS
    BEGIN
        WAIT UNTIL reset_sig = '0';
        WHILE NOT sim_done LOOP
            WAIT UNTIL RISING_EDGE(clk);
            -- Optional: Add signal monitoring here
        END LOOP;
        WAIT;
    END PROCESS;

END ARCHITECTURE behavioral;
