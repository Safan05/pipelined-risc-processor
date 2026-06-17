#!/usr/bin/env python3
"""
Pipelined Processor Assembler
Converts assembly programs to machine code (.mem file)

Usage: python assembler.py input.asm output.mem

Instruction Set:
- One Operand: NOP, HLT, SETC, NOT, INC, OUT, IN
- Two Operand: MOV, SWAP, ADD, SUB, AND, IADD
- Memory: PUSH, POP, LDM, LDD, STD
- Branch: JZ, JN, JC, JMP, CALL, RET, INT, RTI
"""

import sys
import re

# Opcode mapping (5-bit opcodes based on CU.vhd)
OPCODES = {
    # One Operand (Group 00)
    'NOP':  '00111',  # 00111
    'HLT':  '00001',  # 00001
    'SETC': '00010',  # 00010
    'NOT':  '00011',  # 00011
    'INC':  '00100',  # 00100
    'OUT':  '00101',  # 00101
    'IN':   '00110',  # 00110
    
    # Two Operand (Group 01)
    'MOV':  '01000',  # 01000
    'SWAP': '01001',  # 01001
    'ADD':  '01010',  # 01010
    'SUB':  '01011',  # 01011
    'AND':  '01100',  # 01100
    'IADD': '01101',  # 01101
    
    # Memory Operations (Group 10)
    'PUSH': '10000',  # 10000
    'POP':  '10001',  # 10001
    'LDM':  '10010',  # 10010
    'LDD':  '10011',  # 10011
    'STD':  '10100',  # 10100
    
    # Branch/Control (Group 11)
    'CALL': '11000',  # 11000
    'RET':  '11001',  # 11001
    'INT':  '11010',  # 11010
    'RTI':  '11011',  # 11011
    'JZ':   '11100',  # 11100
    'JN':   '11101',  # 11101
    'JC':   '11110',  # 11110
    'JMP':  '11111',  # 11111
}

# Instructions that have immediate value in next word
IMM_INSTRUCTIONS = ['IADD', 'LDM', 'LDD', 'STD', 'JZ', 'JN', 'JC', 'JMP', 'CALL']

def parse_register(reg):
    """Parse register string (R0-R7) to 3-bit binary"""
    reg = reg.upper().strip().replace(',', '')
    if reg.startswith('R'):
        num = int(reg[1])
        if 0 <= num <= 7:
            return format(num, '03b')
    raise ValueError(f"Invalid register: {reg}")

def parse_immediate(imm, bits=16):
    """Parse immediate value as HEXADECIMAL (all values treated as hex per TA format)"""
    imm = imm.strip().replace(',', '')
    # Remove 0x prefix if present, then parse as hex
    if imm.startswith('0X') or imm.startswith('0x'):
        imm = imm[2:]
    # All values are hex
    value = int(imm, 16)
    # Handle negative numbers (2's complement)
    if value < 0:
        value = (1 << bits) + value
    mask = (1 << bits) - 1
    return format(value & mask, f'0{bits}b')

def assemble_line(line, line_num):
    """Assemble a single line of assembly code"""
    # Remove comments
    line = line.split('#')[0].split(';')[0].strip()
    if not line:
        return []
    
    # Parse instruction and operands
    parts = re.split(r'[\s,]+', line)
    parts = [p for p in parts if p]  # Remove empty strings
    
    if not parts:
        return []
    
    mnemonic = parts[0].upper()
    
    if mnemonic not in OPCODES:
        raise ValueError(f"Line {line_num}: Unknown instruction '{mnemonic}'")
    
    opcode = OPCODES[mnemonic]
    words = []
    
    # Build instruction word based on instruction type
    if mnemonic in ['NOP', 'HLT', 'SETC', 'RET', 'RTI']:
        # No operands
        instr = opcode + '0' * 27
        words.append(instr)
        
    elif mnemonic in ['NOT', 'INC', 'OUT', 'PUSH', 'POP']:
        # One register operand (Rdst)
        rdst = parse_register(parts[1]) if len(parts) > 1 else '000'
        instr = opcode + rdst + '0' * 24
        words.append(instr)
        
    elif mnemonic == 'IN':
        # IN Rdst
        rdst = parse_register(parts[1]) if len(parts) > 1 else '000'
        instr = opcode + rdst + '0' * 24
        words.append(instr)
        
    elif mnemonic == 'MOV':
        # MOV Rsrc, Rdst
        rsrc = parse_register(parts[1])
        rdst = parse_register(parts[2])
        instr = opcode + rsrc + rdst + '0' * 21
        words.append(instr)
        
    elif mnemonic == 'SWAP':
        # SWAP Rsrc, Rdst
        rsrc = parse_register(parts[1])
        rdst = parse_register(parts[2])
        instr = opcode + rsrc + rdst + '0' * 21
        words.append(instr)
        
    elif mnemonic in ['ADD', 'SUB', 'AND']:
        # ADD Rdst, Rsrc1, Rsrc2
        rdst = parse_register(parts[1])
        rsrc1 = parse_register(parts[2])
        rsrc2 = parse_register(parts[3])
        instr = opcode + rsrc1 + rsrc2 + rdst + '0' * 18
        words.append(instr)
        
    elif mnemonic == 'IADD':
        # IADD Rdst, Rsrc, Imm (full 32-bit immediate)
        rdst = parse_register(parts[1])
        rsrc = parse_register(parts[2])
        imm = parse_immediate(parts[3], bits=32)  # 32-bit immediate
        instr = opcode + rsrc + rdst + '0' * 21
        words.append(instr)
        words.append(imm)  # Full 32-bit immediate
        
    elif mnemonic == 'LDM':
        # LDM Rdst, Imm (full 32-bit immediate)
        rdst = parse_register(parts[1])
        imm = parse_immediate(parts[2], bits=32)  # 32-bit immediate
        instr = opcode + rdst + '0' * 24
        words.append(instr)
        # Store full 32-bit immediate as-is
        words.append(imm)
        
    elif mnemonic in ['LDD', 'STD']:
        # LDD Rdst, offset(Rsrc)  or  STD Rsrc, offset(Rdst)
        reg1 = parse_register(parts[1])
        # Parse offset(Rx) format
        match = re.match(r'([0-9A-Fa-f]+)\s*\(\s*(R\d)\s*\)', parts[2], re.IGNORECASE)
        if match:
            offset = parse_immediate(match.group(1), bits=32)  # 32-bit offset
            reg2 = parse_register(match.group(2))
        else:
            offset = '0' * 32
            reg2 = parse_register(parts[2])
        instr = opcode + reg1 + reg2 + '0' * 21
        words.append(instr)
        words.append(offset)  # Full 32-bit offset
        
    elif mnemonic in ['JZ', 'JN', 'JC', 'JMP', 'CALL']:
        # Branch/Call with full 32-bit address
        imm = parse_immediate(parts[1], bits=32)  # 32-bit address
        instr = opcode + '0' * 27
        words.append(instr)
        words.append(imm)  # Full 32-bit address
        
    elif mnemonic == 'INT':
        # INT index (0 or 1)
        idx = int(parts[1]) if len(parts) > 1 else 0
        instr = opcode + format(idx, '03b') + '0' * 24
        words.append(instr)
        
    return words

def assemble(input_file, output_file):
    """Assemble entire file with .ORG directive support"""
    with open(input_file, 'r') as f:
        lines = f.readlines()
    
    machine_code = {}  # Use dict for sparse addressing with .ORG
    address = 0
    
    for line_num, line in enumerate(lines, 1):
        try:
            # Remove comments
            clean_line = line.split('#')[0].split(';')[0].strip()
            if not clean_line:
                continue
            
            # Handle .ORG directive
            if clean_line.upper().startswith('.ORG'):
                parts = clean_line.split()
                if len(parts) >= 2:
                    org_addr = parts[1].strip()
                    if org_addr.startswith('0X') or org_addr.startswith('0x'):
                        address = int(org_addr, 16)
                    elif any(c in org_addr.upper() for c in 'ABCDEF'):
                        address = int(org_addr, 16)
                    else:
                        address = int(org_addr)
                continue
            
            # Check if line is just a raw hex value (for .ORG data)
            if re.match(r'^[0-9A-Fa-f]+$', clean_line):
                value = int(clean_line, 16)
                word = format(value, '032b')
                machine_code[address] = word
                address += 1
                continue
            
            # Normal instruction
            words = assemble_line(line, line_num)
            for word in words:
                machine_code[address] = word
                address += 1
        except Exception as e:
            print(f"Error on line {line_num}: {e}")
            return False
    
    # Find max address
    if not machine_code:
        print("No instructions assembled")
        return False
    
    max_addr = max(machine_code.keys())
    
    # Write output in hex format for memory initialization
    with open(output_file, 'w') as f:
        for addr in range(max_addr + 1):
            if addr in machine_code:
                hex_val = format(int(machine_code[addr], 2), '08X')
            else:
                hex_val = '00000000'  # Fill gaps with zeros
            f.write(f"{hex_val}\n")
    
    print(f"Assembled {len(machine_code)} words to {output_file} (max addr: {max_addr})")
    return True

def main():
    if len(sys.argv) < 3:
        print("Usage: python assembler.py input.asm output.mem")
        print("\nExample program (test.asm):")
        print("  LDM R1, 5      # R1 = 5")
        print("  LDM R2, 10     # R2 = 10")
        print("  ADD R3, R1, R2 # R3 = R1 + R2 = 15")
        print("  OUT R3         # Output R3")
        print("  HLT            # Halt")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    if assemble(input_file, output_file):
        print("Assembly successful!")
    else:
        print("Assembly failed!")
        sys.exit(1)

if __name__ == '__main__':
    main()