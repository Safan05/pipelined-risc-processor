# OneOperand Test Case - ModelSim Script
# Tests: NOT, NOP, INC, IN, LDM, SUB, OUT
# Input port values are set at specific times

# Quit any existing simulation
quit -sim

# Create work library
vlib work

# Project base path
set BASE_PATH "d:/CMP/Third Year/pipelined-processor"

# Compile all VHDL files in dependency order
puts "Compiling VHDL files..."

# Basic components
vcom -93 -work work "$BASE_PATH/src/RegFile/Reg.vhd"
vcom -93 -work work "$BASE_PATH/src/RegFile/regFile.vhd"
vcom -93 -work work "$BASE_PATH/src/RegFile/SP_Reg.vhd"
vcom -93 -work work "$BASE_PATH/src/Memory/Memory.vhd"
vcom -93 -work work "$BASE_PATH/src/ALU/ALU.vhd"
vcom -93 -work work "$BASE_PATH/src/ForwardingUnit/ForwardUnit.vhd"

# Control Unit
vcom -93 -work work "$BASE_PATH/src/Control Unit/CU.vhd"

# Hazard Detection
vcom -93 -work work "$BASE_PATH/src/HazardDetectionUnit/hazard_detection_unit.vhd"

# Pipeline Registers
vcom -93 -work work "$BASE_PATH/src/PipelineBuffer/if_id.vhd"
vcom -93 -work work "$BASE_PATH/src/PipelineBuffer/ID_EX_Reg.vhd"
vcom -93 -work work "$BASE_PATH/src/PipelineBuffer/EX_MEM_Reg.vhd"
vcom -93 -work work "$BASE_PATH/src/PipelineBuffer/MEM_WB_Reg.vhd"

# Stages
vcom -93 -work work "$BASE_PATH/src/Stages/PCHandler.vhd"
vcom -93 -work work "$BASE_PATH/src/Stages/fetchStage.vhd"
vcom -93 -work work "$BASE_PATH/src/Stages/memAddrSelector.vhd"
vcom -93 -work work "$BASE_PATH/src/Stages/decodeStage.vhd"
vcom -93 -work work "$BASE_PATH/src/Stages/executeStatge.vhd"
vcom -93 -work work "$BASE_PATH/src/Stages/memoryStage.vhd"
vcom -93 -work work "$BASE_PATH/src/Stages/writeBackStage.vhd"

# Top-level CPU
vcom -93 -work work "$BASE_PATH/cpu.vhd"

# Testbench
vcom -93 -work work "$BASE_PATH/cpu_tb.vhd"

puts "Compilation complete."

# Load testbench
vsim work.cpu_tb

# Add waves (using same signals as cpu_test.do)
add wave -divider "Clock & Reset"
add wave sim:/cpu_tb/clk
add wave sim:/cpu_tb/reset_sig

add wave -divider "I/O Ports"
add wave -hex sim:/cpu_tb/in_port
add wave -hex sim:/cpu_tb/out_port

add wave -divider "PC Signals"
add wave -hex sim:/cpu_tb/dut/pc_current
add wave -hex sim:/cpu_tb/dut/pc_plus_1
add wave sim:/cpu_tb/dut/pc_en

add wave -divider "IF/ID Stage"
add wave -hex sim:/cpu_tb/dut/if_id_instr_out
add wave -hex sim:/cpu_tb/dut/if_id_pc_out

add wave -divider "Memory"
add wave -hex sim:/cpu_tb/dut/mem_address
add wave sim:/cpu_tb/dut/mem_write_enable
add wave -hex sim:/cpu_tb/dut/mem_read_data

# Reset sequence
force sim:/cpu_tb/reset_sig 1
force sim:/cpu_tb/in_port 16#0000000E
run 100 ns

# Release reset
force sim:/cpu_tb/reset_sig 0
run 50 ns

# Input port sequence:
# IN R1 (4th instruction after reset) needs 0x000E
# IN R2 (5th instruction) needs 0x0010

# Wait for IN R1 to execute, then change to value for IN R2
run 400 ns

# Change input for IN R2
force sim:/cpu_tb/in_port 16#00000010
run 200 ns

# Continue simulation
run 2000 ns

# Expected results:
# R1 = 0x000F (after IN with 0xE, then INC)
# R2 = 0xFFEA (after IN with 0x10, NOT, then SUB 5)
# OUT R1 should output 0x000F
# OUT R2 should output 0xFFEA

echo "=== OneOperand Test Complete ==="
echo "Expected OUT R1: 0x0000000F"
echo "Expected OUT R2: 0x0000FFEA"
