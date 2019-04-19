onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /line_drawer_testbench/clk
add wave -noupdate /line_drawer_testbench/reset
add wave -noupdate /line_drawer_testbench/x0
add wave -noupdate /line_drawer_testbench/y0
add wave -noupdate /line_drawer_testbench/x1
add wave -noupdate /line_drawer_testbench/y1
add wave -noupdate /line_drawer_testbench/x
add wave -noupdate /line_drawer_testbench/y
add wave -noupdate /line_drawer_testbench/dut/x_int
add wave -noupdate /line_drawer_testbench/dut/y_int
add wave -noupdate /line_drawer_testbench/dut/x0_swp
add wave -noupdate /line_drawer_testbench/dut/x1_swp
add wave -noupdate /line_drawer_testbench/dut/y0_swp
add wave -noupdate /line_drawer_testbench/dut/y1_swp
add wave -noupdate /line_drawer_testbench/dut/is_steep
add wave -noupdate /line_drawer_testbench/dut/error
add wave -noupdate /line_drawer_testbench/dut/deltax
add wave -noupdate /line_drawer_testbench/dut/deltay
add wave -noupdate /line_drawer_testbench/dut/y_step
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
