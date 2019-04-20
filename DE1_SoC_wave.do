onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/CLOCK_50
add wave -noupdate /DE1_SoC_testbench/SW
add wave -noupdate /DE1_SoC_testbench/dut/x
add wave -noupdate /DE1_SoC_testbench/dut/y
add wave -noupdate /DE1_SoC_testbench/dut/VGA_R
add wave -noupdate /DE1_SoC_testbench/dut/VGA_G
add wave -noupdate /DE1_SoC_testbench/dut/VGA_B
add wave -noupdate /DE1_SoC_testbench/dut/VGA_BLANK_N
add wave -noupdate /DE1_SoC_testbench/dut/VGA_CLK
add wave -noupdate /DE1_SoC_testbench/dut/VGA_HS
add wave -noupdate /DE1_SoC_testbench/dut/VGA_SYNC_N
add wave -noupdate /DE1_SoC_testbench/dut/VGA_VS
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {223 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 50
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {0 ps}
