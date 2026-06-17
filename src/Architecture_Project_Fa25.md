## Page 1

Cairo University
Faculty of Engineering
Computer Engineering Department

CMP 3010
Fall 2025
&lt;img&gt;Cairo University Logo&lt;/img&gt;

# Architecture Project

## Objective
To design and implement a simple 5-stage pipelined processor, **Von-neumann (One memory for program and data)**.
The design should conform to the ISA specification described in the following sections.

## Introduction
The processor in this project has a RISC-like instruction set architecture. There are eight 4-byte general purpose registers; R0, till R7. Another two special purpose registers, one works as a program counter (PC). The second is stack pointer (SP); and hence; points to the top of the stack. The initial value of SP is (2^20-1). The memory address space is 1 MB of 32-bit width. The data bus is 32 bits.

When an interrupt occurs, the processor finishes the currently fetched instructions (instructions that have already entered the pipeline), then the address of the next instruction (in PC) is saved on top of the stack, and PC is loaded from address 1 of the memory. To return from an interrupt, an RTI instruction loads the PC from the top of stack, and the flow of the program resumes from the instruction after the interrupted instruction. Take care of corner cases like Branching.

## ISA Specifications
### A) Registers
<table>
  <tr>
    <td>R[0:7]&lt;31:0&gt;</td>
    <td>; Eight 32-bit general purpose registers</td>
  </tr>
  <tr>
    <td>PC&lt;31:0&gt;</td>
    <td>; 32-bit program counter</td>
  </tr>
  <tr>
    <td>SP&lt;31:0&gt;</td>
    <td>; 32-bit stack pointer</td>
  </tr>
  <tr>
    <td>CCR&lt;3:0&gt;</td>
    <td>; condition code register</td>
  </tr>
  <tr>
    <td>Z&lt;0&gt;:=CCR&lt;0&gt;</td>
    <td>; zero flag, change after arithmetic, logical, or shift operations</td>
  </tr>
  <tr>
    <td>N&lt;0&gt;:=CCR&lt;1&gt;</td>
    <td>; negative flag, change after arithmetic, logical, or shift operations</td>
  </tr>
  <tr>
    <td>C&lt;0&gt;:=CCR&lt;2&gt;</td>
    <td>; carry flag, change after arithmetic or shift operations.</td>
  </tr>
</table>

### A) Input-Output
<table>
  <tr>
    <td>IN.PORT&lt;31:0&gt;</td>
    <td>; 32-bit data input port</td>
  </tr>
  <tr>
    <td>OUT.PORT&lt;31:0&gt;</td>
    <td>; 32-bit data output port</td>
  </tr>
  <tr>
    <td>INTR.IN&lt;0&gt;</td>
    <td>; a single, non-maskable interrupt</td>
  </tr>
  <tr>
    <td>RESET.IN&lt;0&gt;</td>
    <td>; reset signal</td>
  </tr>
</table>

&lt;page_number&gt;1&lt;/page_number&gt;

---


## Page 2

Rsrc ; 1st operand register
Rdst ; 2nd operand register and result register field
Offset ; Address offset (16 bit)
Imm ; Immediate Value 16 bits

**Take Care that Some instructions will Occupy more than one memory location**

<table>
<thead>
<tr>
<th>Mnemonic</th>
<th>Function</th>
<th>Grade</th>
</tr>
</thead>
<tbody>
<tr>
<td colspan="3"><strong>One Operand</strong></td>
</tr>
<tr>
<td>NOP</td>
<td>PC ← PC + 1</td>
<td rowspan="8">3 Marks</td>
</tr>
<tr>
<td>HLT</td>
<td>Freezes PC until a reset</td>
</tr>
<tr>
<td>SETC</td>
<td>C ←1</td>
</tr>
<tr>
<td>NOT Rdst</td>
<td>NOT value stored in register Rdst<br>R[ Rdst ] ← 1's Complement(R[ Rdst ]);<br>If(1's Complement(R[ Rdst ]) = 0): Z ←1; else: Z ←0;<br>If(1's Complement(R[ Rdst ]) < 0): N ←1; else: N ←0</td>
</tr>
<tr>
<td>INC Rdst</td>
<td>Increment value stored in Rdst<br>R[ Rdst ] ←R[ Rdst ] + 1;<br>If((R[ Rdst ] + 1) = 0): Z ←1; else: Z ←0;<br>If((R[ Rdst ] + 1) < 0): N ←1; else: N ←0<br>Updates carry</td>
</tr>
<tr>
<td>OUT Rdst</td>
<td>OUT.PORT ← R[ Rdst ]</td>
</tr>
<tr>
<td>IN Rdst</td>
<td>R[ Rdst ] ← IN.PORT</td>
</tr>
<tr>
<td colspan="3"><strong>Two Operands</strong></td>
</tr>
<tr>
<td>MOV Rsrc, Rdst</td>
<td>Move value from register Rsrc to register Rdst</td>
<td rowspan="7">3.5 Marks</td>
</tr>
<tr>
<td>SWAP Rsrc, Rdst</td>
<td>Exchange the values between 2 registers</td>
</tr>
<tr>
<td>ADD Rdst,<br>Rsrc1, Rsrc2</td>
<td>Add the values stored in registers Rsrc1, Rsrc2<br>and store the result in Rdst and updates carry<br>If the result =0 then Z ←1; else: Z ←0;<br>If the result <0 then N ←1; else: N ←0</td>
</tr>
<tr>
<td>SUB Rdst,<br>Rsrc1, Rsrc2</td>
<td>Subtract the values stored in registers Rsrc1, Rsrc2<br>and store the result in Rdst and updates carry<br>If the result =0 then Z ←1; else: Z ←0;<br>If the result <0 then N ←1; else: N ←0</td>
</tr>
<tr>
<td>AND Rdst,<br>Rsrc1, Rsrc2</td>
<td>AND the values stored in registers Rsrc1, Rsrc2<br>and store the result in Rdst<br>If the result =0 then Z ←1; else: Z ←0;<br>If the result <0 then N ←1; else: N ←0</td>
</tr>
<tr>
<td>IADD Rdst, Rsrc ,Imm</td>
<td>Add the values stored in registers Rsrc to Immediate Value<br>and store the result in Rdst and updates carry<br>If the result =0 then Z ←1; else: Z ←0;<br>If the result <0 then N ←1; else: N ←0</td>
</tr>
<tr>
<td colspan="3"><strong>Memory Operations</strong></td>
</tr>
<tr>
<td>PUSH Rdst</td>
<td>X[SP] ← R[ Rdst ]; SP-=1</td>
<td rowspan="4">3.5 Marks</td>
</tr>
<tr>
<td>POP Rdst</td>
<td>SP+=1; R[ Rdst ] ← X[SP];</td>
</tr>
<tr>
<td>LDM Rdst, Imm</td>
<td>Load immediate value (16 bit) to register Rdst<br>R[ Rdst ] ← Imm<15:0></td>
</tr>
<tr>
<td>LDD Rdst,<br>offset(Rsrc)</td>
<td>Load value from memory address Rsrc + offset to register<br>Rdst</td>
</tr>
</tbody>
</table>

&lt;page_number&gt;2&lt;/page_number&gt;

---


## Page 3

<table>
  <tr>
    <td></td>
    <td>R[Rdst] ← M[R[Rsrc] + offset];<br>Store value that is in register Rsrc1 to memory location Rsrc2 + offset<br>M[R[Rsrc2] + offset] ← R[Rsrc1];</td>
    <td></td>
  </tr>
  <tr>
    <td colspan="3"><b>Branch and Change of Control Operations</b></td>
  </tr>
  <tr>
    <td>JZ Imm</td>
    <td>Jump if zero<br>If (Z=1): PC ←Imm; (Z=0)</td>
    <td rowspan="8">3.5 Marks</td>
  </tr>
  <tr>
    <td>JN Imm</td>
    <td>Jump if negative<br>If (N=1): PC ←Imm; (N=0)</td>
  </tr>
  <tr>
    <td>JC Imm</td>
    <td>Jump if negative<br>If (C=1): PC ←Imm; (C=0)</td>
  </tr>
  <tr>
    <td>JMP Imm</td>
    <td>Jump<br>PC ←Imm]</td>
  </tr>
  <tr>
    <td>CALL Imm</td>
    <td>(X[SP] ← PC + 1; sp-=1; PC ← Imm)</td>
  </tr>
  <tr>
    <td>RET</td>
    <td>sp+=1, PC ←X[SP]</td>
  </tr>
  <tr>
    <td>INT index</td>
    <td>X[SP] ← PC + 1; sp-=1;Flags reserved;<br>PC ← M[index + 2]<br>index is either 0 or 1.</td>
  </tr>
  <tr>
    <td>RTI</td>
    <td>sp+=1; PC ← X[SP]; Flags restored</td>
  </tr>
</table>

<table>
  <tr>
    <td><b>Input Signals</b></td>
    <td></td>
    <td><b>Grade</b></td>
  </tr>
  <tr>
    <td>Reset</td>
    <td>PC ← M[0] //memory location of zero</td>
    <td>0.5 Mark</td>
  </tr>
  <tr>
    <td>Interrupt</td>
    <td>X[Sp]←PC; sp-=1;PC ← M[1]; Flags preserved</td>
    <td>1 Mark</td>
  </tr>
</table>

**Phase1 Requirement: Report Containing:**
* Instruction format of your design
    * Opcode of each instruction
    * Instruction bits details
* Schematic diagram of the processor with data flow details.
    * ALU / Registers / Memory Blocks
    * Dataflow Interconnections between Blocks & its sizes
    * Control Unit detailed design
* Pipeline stages design
    * Pipeline registers details (Size, Input, Connection, ...)
    * Pipeline hazards and your solution including
        i. Data Forwarding
        ii. Static Branch Prediction

**Phase2 Requirement**
* Implement and integrate your architecture
    * VHDL Implementation of each component of the processor
    * VHDL file that integrates the different components in a single module
* Simulation Test code that reads a program file and executes it on the processor.
    * Setup the simulation wave
    * Load Memory File & Run the test program

&lt;page_number&gt;3&lt;/page_number&gt;

---


## Page 4

*   Assembler code that converts assembly program (Text File) into machine code according to your design (Memory File)
*   Report that contains any design changes after phase 1
*   Report that contains pipeline hazards considered and how your design solves it.

**Project Testing**
*   You will be given different test programs. You are required to compile and load it onto the RAM and **reset** your processor to start executing from the memory location written in address 0000h (PC = M[0]). Each program would test some instructions (you should notify the TA if you haven’t implemented or have logical errors concerning some of the instruction set).
*   You MUST prepare a waveform using do files with the main signals showing that your processor is working correctly (R0-R7,PC,SP,Flags,CLK,Reset, Interrupt,IN.port,Out.port). Show main signals and only main signals please, try to keep wave clean
*   You need to make sure that your program can generate the programming file. [2 marks]

**Evaluation Criteria**
*   Each project will be evaluated according to the number of instructions that are implemented, and Pipelining hazards handled in the design. Table 2 shows the evaluation criteria in detail.
*   Failing to implement a working processor will nullify your project grade. **No credits will be given to individual modules or a non-working processor.**
*   Unnecessary latching or very poor understanding of underlying hardware will be penalized.
*   Individual Members of the same team can have different grades, you can get a zero grade if you didn’t work while the rest of the team can get fullmark, Make sure you balance your Work distribution.

Table 2: Evaluation Criteria

<table>
<thead>
<tr>
<th>Marks Distribution</th>
<th>Instructions</th>
<th>Stated above 17 marks</th>
</tr>
</thead>
<tbody>
<tr>
<td></td>
<td>Data Hazards</td>
<td>1 marks</td>
</tr>
<tr>
<td></td>
<td>Struct Hazards</td>
<td>1 mark</td>
</tr>
<tr>
<td></td>
<td>Control Hazards</td>
<td>1 marks</td>
</tr>
<tr>
<td>Bonus Marks</td>
<td>2-bit dynamic branch prediction with address calculation in fetch</td>
<td>2 marks bonus</td>
</tr>
</tbody>
</table>

**Team Members**
*   Each team shall consist of a **maximum of four members**

**Phase 1 Due Date**
*   Delivery a softcopy on google classroom.
*   Week 10, The discussion will be during the regular lab session.

**Project Due Date**
*   Delivery a softcopy on google classroom.
*   Week 13, The demo will be during the regular lab session.

**General Advice**
1. Compile your design on regular bases (after each modification) so that you can figure out new errors early. Accumulated errors are harder to track.

&lt;page_number&gt;4&lt;/page_number&gt;

---


## Page 5

2. Start by finishing a working processor that does all one operands only. Integrating early will help you find a lot of errors. You can then add each type of instructions and integrate them into the working processor.
3. Use the engineering sense to back trace the error source.
4. As much as you can, don’t ignore warnings.
5. Read the transcript window messages in Modelsim carefully.
6. After each major step, and if you have a working processor, save the design before you modify it (use a versioning tool if you can as git & svn).
7. Always save the ram files to easily export and import them.
8. Start early and give yourself enough time for testing.
9. Integrate your components incrementally (i.e: Integrate the RAM with the Registers, then integrate with them the ALU ...).
10. Use coding conventions to know each signal functionality easily.
11. Try to simulate your control signals sequence for an instruction (i.e: Add) to know if your timing design is correct.
12. There is no problem in changing the design after phase1, but justify your changes.
13. Always reset all components at the start of the simulation.
14. Don’t leave any input signal float “U”, set it with 0 or 1.
15. Remember that your VHDL code is a HW system (logic gates, Flipflops and wires).
16. Use Do files instead of re-forcing all inputs each time.

&lt;page_number&gt;5&lt;/page_number&gt;

