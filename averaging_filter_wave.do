onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /averaging_filter_testbench/clk
add wave -noupdate /averaging_filter_testbench/reset
add wave -noupdate /averaging_filter_testbench/enable
add wave -noupdate /averaging_filter_testbench/data_in
add wave -noupdate /averaging_filter_testbench/data_out
add wave -noupdate /averaging_filter_testbench/dut/ps
add wave -noupdate /averaging_filter_testbench/dut/ns
add wave -noupdate /averaging_filter_testbench/dut/sum
add wave -noupdate /averaging_filter_testbench/dut/next_sum
add wave -noupdate /averaging_filter_testbench/dut/sample
add wave -noupdate /averaging_filter_testbench/dut/fifo_rd
add wave -noupdate /averaging_filter_testbench/dut/fifo_wr
add wave -noupdate /averaging_filter_testbench/dut/fifo_full
add wave -noupdate /averaging_filter_testbench/dut/fifo_out
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
