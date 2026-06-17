# Pipelined Processor

VHDL implementation of a simple 32-bit, 5-stage pipelined processor. The design follows the following ISA : eight general-purpose registers, a program counter, stack pointer, condition flags, a unified Von Neumann memory, memory-mapped program/data loading, and interrupt/reset support.

## Features

- 5-stage pipeline: Fetch, Decode, Execute, Memory, Write Back.
- Unified 32-bit instruction/data memory with 20-bit addressing.
- Eight 32-bit general-purpose registers: `R0` through `R7`.
- Special registers/signals: `PC`, `SP`, `CCR` flags, `in_port`, `out_port`, `reset_sig`, and `int_sig`.
- ALU operations for pass-through, add, subtract, multiply, AND, NOT, and increment-by-one paths.
- Stack operations through `SP`, initialized by the stack pointer register.
- Register forwarding from EX/MEM and MEM/WB into the execute stage.
- Load-use hazard detection with PC/IF-ID stall and ID/EX bubble insertion.
- Branch/control flushing when a branch is resolved as taken.
- Python assembler that emits `.mem` files accepted by the VHDL memory initializer.
- ModelSim `.do` scripts for full CPU and focused instruction simulations.

## Processor Architecture

The top-level entity is `cpu` in [cpu.vhd](cpu.vhd). Its external interface is:

```vhdl
clk       : in  std_logic;
reset_sig : in  std_logic;
int_sig   : in  std_logic;
in_port   : in  std_logic_vector(31 downto 0);
out_port  : out std_logic_vector(31 downto 0);
```

Pipeline stages:

| Stage      | Main Files                                        | Responsibility                                                             |
| ---------- | ------------------------------------------------- | -------------------------------------------------------------------------- |
| Fetch      | `fetchStage.vhd`, `PCHandler.vhd`                 | Selects next PC, fetches instruction word from unified memory.             |
| Decode     | `decodeStage.vhd`, `CU.vhd`, `regFile.vhd`        | Decodes opcode/register fields, reads registers, emits control signals.    |
| Execute    | `executeStatge.vhd`, `ALU.vhd`, `ForwardUnit.vhd` | Runs ALU, evaluates branches, updates flags, handles forwarding.           |
| Memory     | `memoryStage.vhd`, `Memory.vhd`                   | Selects memory address/data for stack, load, store, call, interrupt paths. |
| Write Back | `writeBackStage.vhd`                              | Selects ALU, memory, input-port, or swap data for register writeback.      |

The pipeline buffers are implemented in `src/PipelineBuffer/` and carry both datapath values and stage-specific control signals.

## ISA Summary

The assembler and control unit use 5-bit opcodes in instruction bits `[31:27]`. Register fields are 3 bits wide.

| Class                             | Instructions                                         |
| --------------------------------- | ---------------------------------------------------- |
| One operand / I/O                 | `NOP`, `HLT`, `SETC`, `NOT`, `INC`, `OUT`, `IN`      |
| Register-register / immediate ALU | `MOV`, `SWAP`, `ADD`, `SUB`, `AND`, `IADD`           |
| Memory                            | `PUSH`, `POP`, `LDM`, `LDD`, `STD`                   |
| Control flow                      | `JZ`, `JN`, `JC`, `JMP`, `CALL`, `RET`, `INT`, `RTI` |

Two-word instructions store the immediate/address/offset in the following memory word:

- `IADD Rdst, Rsrc, Imm`
- `LDM Rdst, Imm`
- `LDD Rdst, offset(Rsrc)`
- `STD Rsrc, offset(Rdst)`
- `JZ Imm`, `JN Imm`, `JC Imm`, `JMP Imm`, `CALL Imm`

The assembler treats immediates as hexadecimal values. Prefixes like `0x` are accepted but not required.

## Assembler Usage

Convert assembly text into a hex memory initialization file:

```bash
python3 assembler.py input.asm output.mem
```

Example assembly:

```asm
.ORG 0
00000200

.ORG 200
LDM R1, 5
LDM R2, A
ADD R3, R1, R2
OUT R3
HLT
```

The `.ORG` directive places subsequent words/instructions at a memory address. Raw hex words can be used to initialize reset or interrupt vectors. Empty memory gaps are emitted as `00000000`.

## Simulation

The provided scripts are written for ModelSim/Questa.

```tcl
do cpu_test.do
```

or:

```tcl
do OneOperand_test.do
```

The scripts compile the VHDL files in dependency order, load `work.cpu_tb`, add useful waveform signals, and run the simulation.

## Reset, Interrupts, and Memory

- On reset, the processor starts from the reset vector stored in memory location `0`.
- Interrupt handling uses `int_sig` and the interrupt vector path described in the project document.
- The memory component accepts one 32-bit hex word per line.
- The memory is modeled with synchronous write and asynchronous read for simulation.

## Hazards

- Data hazards are handled with a forwarding unit that selects EX/MEM or MEM/WB results for execute-stage operands.
- Load-use hazards are detected by `hazard_detection_unit.vhd`; the PC and IF/ID register stall while ID/EX is flushed with a bubble.
- Taken branches generate a flush from the execute stage to clear younger instructions.
- Stack pointer forwarding is used for back-to-back stack operations.

## Contributors <img src="https://i.imgur.com/SfBB4jV.png" width="28" />

| <a href="https://avatars.githubusercontent.com/u/149877108?s=400&v=4"><img src="https://avatars.githubusercontent.com/u/149877108?s=400&v=4" alt="Amira" width="150"></a> | <a href="https://avatars.githubusercontent.com/u/69475479?v=4"><img src="https://avatars.githubusercontent.com/u/69475479?v=4" alt="Alyaa" width="150"></a> | <a href="https://avatars.githubusercontent.com/u/153025116?v=4"><img src="https://avatars.githubusercontent.com/u/153025116?v=4" alt="Ahmed" width="150"></a> | <a href="https://avatars.githubusercontent.com/u/149018230?v=4"><img src="https://avatars.githubusercontent.com/u/149018230?v=4" alt="Safan" width="150"></a> |
| :-----------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :---------------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------------: |
|                                                             [Amira Khalid](https://github.com/AmiraKhalid04)                                                              |                                                          [Alyaa Ali](https://github.com/Alyaa242)                                                           |                                                        [Ahmed Kamal](https://github.com/ahmedkamal14)                                                         |                                                         [Abdullah Safan](https://github.com/Safan05)                                                          |
