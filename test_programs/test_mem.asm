# Test Program 2: Stack Operations
# Tests: PUSH, POP, MOV
# Uses stack to store and retrieve values

LDM R1, 0xABCD  # R1 = 0xABCD
LDM R2, 0x1234  # R2 = 0x1234

OUT R1          # Output: 0xABCD
OUT R2          # Output: 0x1234

PUSH R1         # Push R1 to stack
PUSH R2         # Push R2 to stack

LDM R1, 0       # Clear R1
LDM R2, 0       # Clear R2

POP R3          # R3 = popped value (0x1234)
POP R4          # R4 = popped value (0xABCD)

OUT R3          # Expected: 0x1234
OUT R4          # Expected: 0xABCD

HLT