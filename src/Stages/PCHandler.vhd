

ENTITY pc_handler IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        pc_en : IN STD_LOGIC;

        pc_from_stack : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        pc_plus_1 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        jump_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        int_pc : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        pc_sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);

        pc_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rtl OF pc_handler IS
    SIGNAL pc_reg : STD_LOGIC_VECTOR(31 DOWNTO 0);
BEGIN

    PROCESS (clk, rst)
    BEGIN
        IF rst = '1' THEN
            pc_reg <= (OTHERS => '0'); -- current PC?? or reset value
        ELSIF RISING_EDGE(clk) THEN
            IF pc_en = '1' THEN
                CASE pc_sel IS
                    WHEN "00" => pc_reg <= pc_from_stack;
                    WHEN "01" => pc_reg <= pc_plus_1;
                    WHEN "10" => pc_reg <= jump_pc;
                    WHEN "11" => pc_reg <= int_pc;
                    WHEN OTHERS => pc_reg <= pc_plus_1;
                END CASE;
            END IF;
        END IF;
    END PROCESS;

    pc_out <= pc_reg;

END ARCHITECTURE;