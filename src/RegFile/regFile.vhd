LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Register File Entity
ENTITY Reg_File IS
    GENERIC (
        NUM_REGS : INTEGER := 8;
        REG_WIDTH : INTEGER := 32;
        ADDR_WIDTH : INTEGER := 3
    );
    PORT (
        clk, rst : IN STD_LOGIC;
        re : IN STD_LOGIC;
        we : IN STD_LOGIC;
        r_addr1 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        r_addr2 : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        w_addr : IN STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0);
        w_data : IN STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0);
        r_data1 : OUT STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0);
        r_data2 : OUT STD_LOGIC_VECTOR(REG_WIDTH - 1 DOWNTO 0)
    );
END ENTITY Reg_File;

ARCHITECTURE structural OF Reg_File IS

    COMPONENT Reg IS
        GENERIC (
            REG_WIDTH : INTEGER := 32  -- Add generic here
        );
        PORT (
            d   : IN STD_LOGIC_VECTOR(REG_WIDTH-1 DOWNTO 0); 
            q   : OUT STD_LOGIC_VECTOR(REG_WIDTH-1 DOWNTO 0); 
            rst : IN STD_LOGIC;
            we  : IN STD_LOGIC;
            clk : IN STD_LOGIC
        ); 
    END COMPONENT;

    TYPE reg_array_type IS ARRAY (0 TO NUM_REGS-1) OF std_logic_vector(REG_WIDTH-1 downto 0);
    SIGNAL reg_outputs : reg_array_type;
    SIGNAL reg_enable : std_logic_vector(NUM_REGS-1 downto 0);

BEGIN

    Generate_Registers: FOR i IN 0 TO NUM_REGS-1 GENERATE
        -- Decoder Logic
        reg_enable(i) <= '1' WHEN (we = '1' AND to_integer(unsigned(w_addr)) = i) ELSE '0';
        
        reg_inst: Reg 
        GENERIC MAP(
            REG_WIDTH => REG_WIDTH
        )
        PORT MAP(
            d   => w_data,
            q   => reg_outputs(i),
            rst => rst,
            we  => reg_enable(i),
            clk => clk
        );
    END GENERATE;

    -- Read Logic with WRITE-THROUGH BYPASS
    -- If reading the same register being written, output write data directly
    PROCESS (re, r_addr1, r_addr2, reg_outputs, we, w_addr, w_data)
    BEGIN
        IF re = '1' THEN
            -- Read port 1 with write-through
            IF we = '1' AND w_addr = r_addr1 THEN
                r_data1 <= w_data;  -- Bypass: use write data directly
            ELSE
                r_data1 <= reg_outputs(to_integer(unsigned(r_addr1)));
            END IF;
            
            -- Read port 2 with write-through
            IF we = '1' AND w_addr = r_addr2 THEN
                r_data2 <= w_data;  -- Bypass: use write data directly
            ELSE
                r_data2 <= reg_outputs(to_integer(unsigned(r_addr2)));
            END IF;
        ELSE
            r_data1 <= (others => '0');
            r_data2 <= (others => '0');
        END IF;
    END PROCESS;

END structural;