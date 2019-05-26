onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /color_selector_testbench/clk
add wave -noupdate /color_selector_testbench/reset
add wave -noupdate /color_selector_testbench/toggle
add wave -radix unsigned -noupdate /color_selector_testbench/color
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