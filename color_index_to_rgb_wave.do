onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -radix unsigned -noupdate /color_index_to_rgb_testbench/index
add wave -radix hex -noupdate /color_index_to_rgb_testbench/r
add wave -radix hex -noupdate /color_index_to_rgb_testbench/g
add wave -radix hex -noupdate /color_index_to_rgb_testbench/b
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
