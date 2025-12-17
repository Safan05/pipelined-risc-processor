LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
use IEEE.math_real.all; -- Optional: Useful if you want to calculate log2 for address width automatically

ENTITY Reg_File IS
    GENERIC (
        NUM_REGS  : integer := 8;   -- 8 Registers
        REG_WIDTH : integer := 32;  -- 32 Bits wide
        ADDR_WIDTH: integer := 3    -- 3 bits needed to address 8 registers (2^3 = 8)
    );
    PORT (
        clk, rst : IN std_logic;
        re       : IN std_logic;
        we       : IN std_logic;
        
        -- Addresses: Changed to use ADDR_WIDTH generic (3 bits: 2 downto 0)
        r_addr1  : IN std_logic_vector(ADDR_WIDTH-1 downto 0);
        r_addr2  : IN std_logic_vector(ADDR_WIDTH-1 downto 0);
        w_addr   : IN std_logic_vector(ADDR_WIDTH-1 downto 0);
        
        -- Data: Changed to use REG_WIDTH generic (32 bits: 31 downto 0)
        w_data   : IN std_logic_vector(REG_WIDTH-1 downto 0);
        r_data1  : OUT std_logic_vector(REG_WIDTH-1 downto 0);
        r_data2  : OUT std_logic_vector(REG_WIDTH-1 downto 0)
    );
END Reg_File;

ARCHITECTURE structural OF Reg_File IS

    COMPONENT Reg IS 
        PORT (
            d   : IN STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); 
            q   : OUT STD_LOGIC_VECTOR (REG_WIDTH-1 downto 0); 
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
        
        reg_inst: Reg PORT MAP(
            d   => w_data,
            q   => reg_outputs(i),
            rst => rst,
            we  => reg_enable(i),
            clk => clk
        );
    END GENERATE;

    -- Read Logic
    PROCESS (re, r_addr1, r_addr2, reg_outputs)
    BEGIN
        IF re = '1' THEN
            -- Now safe because r_addr cannot exceed array bounds
            r_data1 <= reg_outputs(to_integer(unsigned(r_addr1)));
            r_data2 <= reg_outputs(to_integer(unsigned(r_addr2)));
        ELSE
            r_data1 <= (others => '0');
            r_data2 <= (others => '0');
        END IF;
    END PROCESS;

END structural;

-- Fetch Decode Execute Memory Writeback