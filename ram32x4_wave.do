onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ram32x4_testbench/clk
add wave -noupdate /ram32x4_testbench/address
add wave -noupdate /ram32x4_testbench/data_in
add wave -noupdate /ram32x4_testbench/write_enable
add wave -noupdate /ram32x4_testbench/data_out
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
