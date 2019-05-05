onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /binary_search_testbench/clk
add wave -noupdate /binary_search_testbench/reset
add wave -noupdate /binary_search_testbench/start
add wave -noupdate -radix unsigned /binary_search_testbench/ram_out
add wave -noupdate -radix unsigned /binary_search_testbench/A
add wave -noupdate /binary_search_testbench/found
add wave -noupdate -radix hexadecimal /binary_search_testbench/I
add wave -noupdate /binary_search_testbench/dut/l_leq_r
add wave -noupdate /binary_search_testbench/dut/data_out_lt_a
add wave -noupdate /binary_search_testbench/dut/data_out_gt_a
add wave -noupdate /binary_search_testbench/dut/search_ctrl/ps
add wave -noupdate /binary_search_testbench/dut/search_ctrl/ns
add wave -noupdate -radix unsigned /binary_search_testbench/dut/search_dp/L
add wave -noupdate -radix unsigned /binary_search_testbench/dut/search_dp/R
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {2175 ps}
