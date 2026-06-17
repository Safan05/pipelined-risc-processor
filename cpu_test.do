# cpu_test.do - ModelSim simulation script for CPU testbench
# Run with: do cpu_test.do

# Quit any existing simulation
quit -sim

# Create work library
vlib work

# Project base path
set BASE_PATH "D:/CMP/Third Year/pipelined-processor"

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

# Forwarding Unit
vcom -93 -work work "$BASE_PATH/src/ForwardingUnit/ForwardUnit.vhd"

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

# Load simulation
vsim -t ns work.cpu_tb

# Add waves
add wave -divider "Clock & Reset"
add wave sim:/cpu_tb/clk
add wave sim:/cpu_tb/reset_sig
add wave sim:/cpu_tb/int_sig

add wave -divider "I/O Ports"
add wave -hex sim:/cpu_tb/in_port
add wave -hex sim:/cpu_tb/out_port

add wave -divider "PC Signals"
add wave -hex sim:/cpu_tb/dut/pc_current
add wave -hex sim:/cpu_tb/dut/pc_plus_1
add wave sim:/cpu_tb/dut/pc_en
add wave sim:/cpu_tb/dut/pc_sel

add wave -divider "IF/ID Stage"
add wave -hex sim:/cpu_tb/dut/if_id_instr_out
add wave -hex sim:/cpu_tb/dut/if_id_pc_out

add wave -divider "Fetch Stage"
add wave -hex sim:/cpu_tb/dut/fetch_stage_inst/pc_current
add wave -hex sim:/cpu_tb/dut/fetch_stage_inst/pc_plus_1
add wave -hex sim:/cpu_tb/dut/fetch_stage_inst/pc_sel
add wave -hex sim:/cpu_tb/dut/fetch_stage_inst/pc_from_stack
add wave -hex sim:/cpu_tb/dut/fetch_stage_inst/jump_pc
add wave -hex sim:/cpu_tb/dut/pc_current
add wave -hex sim:/cpu_tb/dut/mem_read_data

add wave -divider "Decode Stage"
add wave -hex sim:/cpu_tb/dut/dec_read_data_1
add wave -hex sim:/cpu_tb/dut/dec_read_data_2
add wave sim:/cpu_tb/dut/dec_r_src_1
add wave sim:/cpu_tb/dut/dec_r_src_2
add wave sim:/cpu_tb/dut/dec_r_dst
add wave sim:/cpu_tb/dut/hdu_if_id_en
add wave sim:/cpu_tb/dut/hdu_pc_en
add wave sim:/cpu_tb/dut/dec_branch

add wave -divider "Execute Stage"
add wave -hex sim:/cpu_tb/dut/ex_alu_out
add wave sim:/cpu_tb/dut/ex_wb_addr
add wave sim:/cpu_tb/dut/ex_flags
add wave sim:/cpu_tb/dut/id_ex_imm_sig
add wave sim:/cpu_tb/dut/ex_wb_data_out
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/IMM_BYPASS
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/PC_SEL_SIG
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/BRANCH_SIG
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/BRANCH_T_SIG
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/PC_BRANCH_OUT
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/PC_SEL_SIG_OUT
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/PC_BRANCH_OUT
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/IMM_DATA
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/SRC_SEL2_OUT
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/ALU_IN2
add wave -hex sim:/cpu_tb/dut/execute_stage_inst/ALU_IN1
add wave sim:/cpu_tb/dut/execute_stage_inst/Forward_mux_0
add wave sim:/cpu_tb/dut/execute_stage_inst/Forward_mux_1
add wave sim:/cpu_tb/dut/execute_stage_inst/ALU_SRC_SIG
add wave sim:/cpu_tb/dut/execute_stage_inst/ALU_OP_SIG


add wave -divider "Memory Stage"
add wave -hex sim:/cpu_tb/dut/mem_alu_out
add wave sim:/cpu_tb/dut/mem_wb_data_sig

add wave -divider "WriteBack Stage"
add wave sim:/cpu_tb/dut/wb_reg_write_en
add wave sim:/cpu_tb/dut/wb_reg_write_addr
add wave -hex sim:/cpu_tb/dut/wb_reg_write_data
add wave sim:/cpu_tb/dut/mem_wb_wb_data_sig
# WriteBack stage is now combinational - signals come directly from MEM/WB register
add wave -hex sim:/cpu_tb/dut/mem_wb_alu_out
add wave -hex sim:/cpu_tb/dut/mem_wb_mem_out


add wave -divider "═══════════ CU SIGNALS - DECODE STAGE ═══════════"
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/state
add wave -hex sim:/cpu_tb/dut/decode_stage_inst/cu_inst/OP_CODE
# No specific decode-only signals (RD_EN not used directly in this design)

add wave -divider "═══════════ CU SIGNALS - EXECUTE STAGE ═══════════"
add wave sim:/cpu_tb/dut/dec_alu_op
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/ALU_SRC
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/SET_CARRY
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/BRANCH
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/BRANCH_T
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/PC_WE
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/OUT_EN
add wave sim:/cpu_tb/dut/dec_imm_sig
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/SP_OP
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/SP_OR_R1
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/SP_WRT_EN

add wave -divider "═══════════ CU SIGNALS - MEMORY STAGE ═══════════"
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/PC_SEL
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/MEM_WRT_EN
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/MEM_ADDR
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/MEM_WRT_DATA

add wave -divider "═══════════ CU SIGNALS - WRITEBACK STAGE ═══════════"
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/WB_DATA
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/WB_ADDR
add wave sim:/cpu_tb/dut/dec_reg_wrt_en
add wave sim:/cpu_tb/dut/decode_stage_inst/cu_inst/SWAP_SIG


add wave -divider "ID/EX Stage"
add wave -hex sim:/cpu_tb/dut/id_ex_read_data_1
add wave -hex sim:/cpu_tb/dut/id_ex_read_data_2
add wave sim:/cpu_tb/dut/id_ex_alu_op
add wave sim:/cpu_tb/dut/id_ex_sp_or_r1
add wave sim:/cpu_tb/dut/id_ex_sp_wrt_en
add wave sim:/cpu_tb/dut/id_ex_branch

add wave -divider "═══════════ CU SIGNALS IN ID/EX BUFFER ═══════════"
add wave sim:/cpu_tb/dut/id_ex_reg_inst/alu_src_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/alu_op_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/set_carry_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/branch_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/branch_t_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/pc_we_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/out_en_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/sp_op_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/sp_or_r1_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/sp_wrt_en_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/imm_sig_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/pc_sel_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/mem_wrt_en_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/mem_addr_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/mem_wrt_data_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/wb_data_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/wb_addr_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/reg_wrt_en_out
add wave sim:/cpu_tb/dut/id_ex_reg_inst/swap_sig_out

add wave -divider "═══════════ CU SIGNALS - EX STAGE OUTPUT ═══════════"
add wave sim:/cpu_tb/dut/ex_mem_mem_wrt_en
add wave sim:/cpu_tb/dut/ex_mem_mem_addr_sig
add wave sim:/cpu_tb/dut/ex_mem_mem_wrt_data_sig
add wave sim:/cpu_tb/dut/ex_mem_wb_data_sig
add wave sim:/cpu_tb/dut/ex_mem_reg_wrt_en
add wave sim:/cpu_tb/dut/ex_mem_wb_addr


add wave -divider "═══════════ CU SIGNALS - MEM STAGE OUTPUT ═══════════"
add wave sim:/cpu_tb/dut/mem_wb_wb_data_sig
add wave sim:/cpu_tb/dut/mem_wb_reg_wrt_en
add wave sim:/cpu_tb/dut/mem_wb_wb_addr


add wave -divider "Memory Debug"
add wave -hex sim:/cpu_tb/dut/mem_address
add wave sim:/cpu_tb/dut/mem_write_enable
add wave -hex sim:/cpu_tb/dut/mem_write_data
add wave -hex sim:/cpu_tb/dut/mem_read_data
add wave -hex sim:/cpu_tb/dut/memory_inst/MEMORY_BLOCK(0)
add wave -hex sim:/cpu_tb/dut/memory_inst/MEMORY_BLOCK(1)
add wave -hex sim:/cpu_tb/dut/memory_inst/MEMORY_BLOCK(2)
add wave -hex sim:/cpu_tb/dut/memory_inst/MEMORY_BLOCK(3)
add wave -hex sim:/cpu_tb/dut/memory_inst/ADDRESS

add wave -divider "Stack Pointer"
add wave -hex sim:/cpu_tb/dut/sp_current
add wave sim:/cpu_tb/dut/sp_write_en

# Configure wave window
configure wave -namecolwidth 200
configure wave -valuecolwidth 100

# Run simulation
puts "Running simulation..."
run 5000 ns

# Zoom to fit
wave zoom full

puts "Simulation complete. Check waveforms for results."
