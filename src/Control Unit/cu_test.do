# Start simulation
vsim -gui work.CU_TB

# Add waves
# Note: changing INT to INT_SIG to match the updated testbench signal name
add wave -position insertpoint sim:/CU_TB/*

# Add dividers for better organization
add wave -divider "Inputs"
add wave -position insertpoint \
sim:/CU_TB/CLK \
sim:/CU_TB/RST \
sim:/CU_TB/INT_SIG \
sim:/CU_TB/OP_CODE

add wave -divider "Decode Stage"
add wave -position insertpoint \
sim:/CU_TB/RD_NXT_INST \
sim:/CU_TB/RD_EN

add wave -divider "Execute Stage"
add wave -position insertpoint \
sim:/CU_TB/ALU_SRC \
sim:/CU_TB/ALU_OP \
sim:/CU_TB/SET_CARRY \
sim:/CU_TB/BRANCH \
sim:/CU_TB/BRANCH_T \
sim:/CU_TB/PC_WE \
sim:/CU_TB/OUT_EN \
sim:/CU_TB/IMM_SIG \
sim:/CU_TB/SP_OP

add wave -divider "Memory Stage"
add wave -position insertpoint \
sim:/CU_TB/PC_SEL \
sim:/CU_TB/MEM_WRT_EN \
sim:/CU_TB/MEM_ADDR \
sim:/CU_TB/MEM_WRT_DATA

add wave -divider "Write Back Stage"
add wave -position insertpoint \
sim:/CU_TB/WB_DATA \
sim:/CU_TB/WB_ADDR \
sim:/CU_TB/REG_WRT_EN \
sim:/CU_TB/SWAP_SIG

add wave -divider "Test Status"
add wave -position insertpoint \
sim:/CU_TB/test_count \
sim:/CU_TB/errors

# Run simulation
run 1200 ns

# Zoom to fit
wave zoom full