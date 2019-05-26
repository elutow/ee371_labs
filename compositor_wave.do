onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /compositor_testbench/cursor_visible
add wave -radix unsigned -noupdate /compositor_testbench/cursor_color
add wave -noupdate /compositor_testbench/canvas1_visible
add wave -radix unsigned -noupdate /compositor_testbench/canvas1_color
add wave -noupdate /compositor_testbench/canvas2_visible
add wave -radix unsigned -noupdate /compositor_testbench/canvas2_color
add wave -noupdate /compositor_testbench/canvas3_visible
add wave -radix unsigned -noupdate /compositor_testbench/canvas3_color
add wave -noupdate /compositor_testbench/canvas4_visible
add wave -radix unsigned -noupdate /compositor_testbench/canvas4_color
add wave -radix unsigned -noupdate /compositor_testbench/camera_color
add wave -radix unsigned -noupdate /compositor_testbench/render_color
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
