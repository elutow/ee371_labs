onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /DE1_SoC_testbench/CLOCK_50
add wave -noupdate /DE1_SoC_testbench/HEX0
add wave -noupdate /DE1_SoC_testbench/HEX1
add wave -noupdate /DE1_SoC_testbench/HEX2
add wave -noupdate /DE1_SoC_testbench/HEX3
add wave -noupdate /DE1_SoC_testbench/HEX4
add wave -noupdate /DE1_SoC_testbench/HEX5
add wave -noupdate /DE1_SoC_testbench/KEY
add wave -noupdate /DE1_SoC_testbench/LEDR
add wave -noupdate /DE1_SoC_testbench/SW
add wave -noupdate /DE1_SoC_testbench/PS2_CLK
add wave -noupdate /DE1_SoC_testbench/PS2_DAT
add wave -noupdate /DE1_SoC_testbench/VGA_R
add wave -noupdate /DE1_SoC_testbench/VGA_G
add wave -noupdate /DE1_SoC_testbench/VGA_B
add wave -noupdate /DE1_SoC_testbench/VGA_BLANK_N
add wave -noupdate /DE1_SoC_testbench/VGA_CLK
add wave -noupdate /DE1_SoC_testbench/VGA_HS
add wave -noupdate /DE1_SoC_testbench/VGA_SYNC_N
add wave -noupdate /DE1_SoC_testbench/VGA_VS
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/request_x
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/request_y
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/cursor_color
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/canvas4_color
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/canvas3_color
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/canvas2_color
add wave -radix unsigned -noupdate /DE1_SoC_testbench/dut/canvas1_color
add wave -radix hex -noupdate /DE1_SoC_testbench/dut/vga_r
add wave -radix hex -noupdate /DE1_SoC_testbench/dut/vga_g
add wave -radix hex -noupdate /DE1_SoC_testbench/dut/vga_b
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
