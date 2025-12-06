# Start simulation
vsim -voptargs=+acc work.MEMORY_TB

# Add waves with appropriate formats
add wave -divider "Clock and Control"
add wave -radix binary /MEMORY_TB/CLK_TB
add wave -radix binary /MEMORY_TB/WR_EN_TB

add wave -divider "Address (Decimal and Hex)"
add wave -radix decimal /MEMORY_TB/ADDRESS_DECIMAL
add wave -radix hexadecimal /MEMORY_TB/ADDRESS_TB

add wave -divider "Data (Decimal and Hex)"
add wave -radix decimal /MEMORY_TB/WRITE_DATA_DECIMAL
add wave -radix hexadecimal /MEMORY_TB/WRITE_DATA_TB
add wave -radix decimal /MEMORY_TB/READ_DATA_DECIMAL
add wave -radix hexadecimal /MEMORY_TB/READ_DATA_TB

add wave -divider "Memory Segments Info"
add wave -radix ascii -label "Current_Segment" /MEMORY_TB/ADDRESS_TB

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -timeline 0

# Run simulation for specific time (all tests complete within 3us)
run 3 us

# Zoom to fit
wave zoom full

# Export memory to CSV file for Excel
echo "Exporting memory contents to CSV for Excel..."

# Open CSV file for writing
set fp [open "memory_export.csv" w]

# Write CSV header
puts $fp "Address (Dec),Address (Hex),Data (Dec),Data (Hex)"

# Get memory array path
set mem_path "/MEMORY_TB/UUT/MEMORY_BLOCK"

# Export only addresses that were written during tests
set addresses [list 0x00000 0x00100 0x00101 0x00102 0x00103 0x20000 0x40000 0x50000 0x60000 0x60001 0x60002 0x60003 0x70000 0x70001 0x70002 0x70003 0x70004 0x70005 0x70006 0x70007 0x70008 0x70009 0xFFFFC 0xFFFFD 0xFFFFE 0xFFFFF]

foreach addr_hex $addresses {
    set addr_dec [expr $addr_hex]
    set data [examine -radix hex ${mem_path}($addr_dec)]
    set data_clean [string map {"16#" "" "#" ""} $data]
    set data_dec [expr 0x$data_clean]
    
    # Write to CSV
    puts $fp "$addr_dec,0x[format %05X $addr_dec],$data_dec,0x$data_clean"
}

close $fp
echo "Memory exported to memory_export.csv - Open it in Excel!"

# Print completion message
echo "=================================="
echo "Memory Simulation Completed!"
echo "=================================="
echo "Address ranges tested:"
echo "  - Instruction Memory: 0x00000 - 0x3FFFF"
echo "  - Data Segment: 0x40000 - 0x7FFFF"
echo "  - Stack Segment: 0xFFFFF - 0xFFFC0"
echo "=================================="
echo "Memory file saved:"
echo "  - memory_export.csv (Open directly in Excel!)"
echo "=================================="
