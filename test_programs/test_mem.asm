# Memory Test Program (TA Format)
# Tests: PUSH, POP, LDD, STD with offset(Rx) syntax
# All numbers in hex format

.ORG 0  # Reset address
100

.ORG 100
# Load initial values
LDM R1, 10FE19        # R1 = 0x10FE19
LDM R2, 21FFFF        # R2 = 0x21FFFF
LDM R3, E5F320        # R3 = 0xE5F320

OUT R1
OUT R2

# Test PUSH/POP
IN  R0                # R0 = input port value
PUSH R1               # SP=3FFFE, M[3FFFF] = 10FE19
PUSH R2               # SP=3FFFD, M[3FFFE] = 21FFFF

OUT R0

POP R4                # SP=3FFFE, R4 = 21FFFF
POP R5                # SP=3FFFF, R5 = 10FE19

NOP
NOP

OUT R4                # Expected: 0x0021FFFF (popped R2)
OUT R5                # Expected: 0x0010FE19 (popped R1)

# Test STD/LDD with offset(Rx) syntax
LDM R0, 200           # R0 = 0x200 (base address)
STD R1, 0(R0)         # M[200] = 10FE19
STD R2, 1(R0)         # M[201] = 21FFFF
STD R3, 2(R0)         # M[202] = E5F320

NOP
NOP

LDD R6, 0(R0)         # R6 = M[200] = 10FE19
LDD R7, 1(R0)         # R7 = M[201] = 21FFFF

NOP
NOP

OUT R6                # Expected: 0x0010FE19
OUT R7                # Expected: 0x0021FFFF

# Advanced: Use loaded value as address
LDD R4, 2(R0)         # R4 = M[202] = E5F320
STD R6, 0(R4)         # M[E5F320] = 10FE19

NOP
NOP

LDD R5, 0(R4)         # R5 = M[E5F320] = 10FE19

NOP
NOP

OUT R5                # Expected: 0x0010FE19

HLT