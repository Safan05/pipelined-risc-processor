# Start simulation
vsim -voptargs=+acc work.ALU_TB

# Add waves with decimal radix
add wave -divider "Inputs"
add wave -radix decimal /ALU_TB/A_DECIMAL
add wave -radix decimal /ALU_TB/B_DECIMAL
add wave -radix binary /ALU_TB/OP_TB
add wave -divider "Internal Signals (Raw)"
add wave -radix hexadecimal /ALU_TB/A_TB
add wave -radix hexadecimal /ALU_TB/B_TB
add wave -radix hexadecimal /ALU_TB/RESULT_TB
add wave -divider "Outputs"
add wave -radix decimal /ALU_TB/RESULT_DECIMAL
add wave -radix binary /ALU_TB/COUT_TB
add wave -radix binary /ALU_TB/ZERO_TB
add wave -radix binary /ALU_TB/NEGATIVE_TB

# Configure wave window
configure wave -namecolwidth 200
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Run simulation
run -all

# Zoom to fit all signals
wave zoom full

# Print message
echo "Simulation completed. Check the waveform viewer for decimal results."
echo "A_DECIMAL, B_DECIMAL, and RESULT_DECIMAL are displayed in decimal format."
