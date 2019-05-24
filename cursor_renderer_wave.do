onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cursor_renderer_testbench/clk
add wave -noupdate /cursor_renderer_testbench/reset
add wave -radix unsigned -noupdate /cursor_renderer_testbench/cursor_x
add wave -radix unsigned -noupdate /cursor_renderer_testbench/cursor_y
add wave -noupdate /cursor_renderer_testbench/current_color
add wave -radix unsigned -noupdate /cursor_renderer_testbench/cursor_frame
add wave -noupdate /cursor_renderer_testbench/dut/ps
add wave -noupdate /cursor_renderer_testbench/dut/ns
add wave -radix unsigned -noupdate /cursor_renderer_testbench/dut/step
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
