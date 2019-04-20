onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /line_animator_testbench/clk
add wave -noupdate /line_animator_testbench/reset
add wave -noupdate /line_animator_testbench/update_event
add wave -noupdate /line_animator_testbench/x
add wave -noupdate /line_animator_testbench/y
add wave -noupdate /line_animator_testbench/pixel_color
add wave -noupdate /line_animator_testbench/dut/x0
add wave -noupdate /line_animator_testbench/dut/y0
add wave -noupdate /line_animator_testbench/dut/x1
add wave -noupdate /line_animator_testbench/dut/y1
add wave -noupdate /line_animator_testbench/dut/drawer_reset
add wave -noupdate /line_animator_testbench/dut/draw_done
add wave -noupdate /line_animator_testbench/dut/step
add wave -noupdate /line_animator_testbench/dut/next_step
add wave -noupdate /line_animator_testbench/dut/ps
add wave -noupdate /line_animator_testbench/dut/ns
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
