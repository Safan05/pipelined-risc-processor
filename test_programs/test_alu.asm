# Test Program 1: Basic ALU Operations
# Tests: LDM, ADD, SUB, AND, INC, OUT
# Expected outputs: 15, 5, 10, 6, 16

# Load immediate values
LDM R1, 5       # R1 = 5
LDM R2, 10      # R2 = 10

# ADD test: R3 = R1 + R2 = 15
ADD R3, R1, R2
OUT R3          # Expected: 15 (0x0000000F)

# SUB test: R4 = R2 - R1 = 5
SUB R4, R2, R1
OUT R4          # Expected: 5 (0x00000005)

# AND test: R5 = R1 AND R2 = 0 (5 AND 10 = 0000 AND 1010 = 0)
AND R5, R1, R2
OUT R5          # Expected: 0 (0x00000000)

# INC test: R1 = R1 + 1 = 6
INC R1
OUT R1          # Expected: 6 (0x00000006)

# IADD test: R6 = R2 + 10 = 20
IADD R6, R2, 10
OUT R6          # Expected: 20 (0x00000014)

HLT