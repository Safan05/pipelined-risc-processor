LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY hazard_detection_unit IS
  PORT (
    r_src_1, r_src_2, r_dst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    read_mem, wb : IN STD_LOGIC;
    pc_en, if_id_en, id_ex_en : OUT STD_LOGIC
  );
END hazard_detection_unit;

ARCHITECTURE hazard_detection_logic OF hazard_detection_unit IS
BEGIN
  PROCESS (r_src_1, r_src_2, r_dst, read_mem, wb)
  BEGIN
    IF (read_mem = '1') THEN
      pc_en <= '0';
      if_id_en <= '0';
    ELSE
      pc_en <= '1';
      if_id_en <= '1';
    END IF;

    IF (read_mem = '1' AND wb = '1' AND (r_src_1 = r_dst OR r_src_2 = r_dst)) THEN
      id_ex_en <= '0';
    ELSE
      id_ex_en <= '1';
    END IF;

  END PROCESS;
END hazard_detection_logic;