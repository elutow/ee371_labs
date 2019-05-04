onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /binary_search_dp_testbench/clk
add wave -noupdate /binary_search_dp_testbench/init_regs
add wave -noupdate /binary_search_dp_testbench/set_found
add wave -noupdate /binary_search_dp_testbench/set_not_found
add wave -noupdate /binary_search_dp_testbench/update_index
add wave -noupdate /binary_search_dp_testbench/update_l
add wave -noupdate /binary_search_dp_testbench/update_r
add wave -noupdate /binary_search_dp_testbench/ram_out
add wave -noupdate /binary_search_dp_testbench/A
add wave -noupdate /binary_search_dp_testbench/l_leq_r
add wave -noupdate /binary_search_dp_testbench/data_out_lt_a
add wave -noupdate /binary_search_dp_testbench/data_out_gt_a
add wave -noupdate /binary_search_dp_testbench/found
add wave -noupdate /binary_search_dp_testbench/I
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
