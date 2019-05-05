onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /binary_search_ctrl_testbench/clk
add wave -noupdate /binary_search_ctrl_testbench/reset
add wave -noupdate /binary_search_ctrl_testbench/start
add wave -noupdate /binary_search_ctrl_testbench/l_leq_r
add wave -noupdate /binary_search_ctrl_testbench/data_out_lt_a
add wave -noupdate /binary_search_ctrl_testbench/data_out_gt_a
add wave -noupdate /binary_search_ctrl_testbench/r_eq_min
add wave -noupdate /binary_search_ctrl_testbench/l_eq_max
add wave -noupdate /binary_search_ctrl_testbench/init_regs
add wave -noupdate /binary_search_ctrl_testbench/set_found
add wave -noupdate /binary_search_ctrl_testbench/set_not_found
add wave -noupdate /binary_search_ctrl_testbench/update_index
add wave -noupdate /binary_search_ctrl_testbench/update_l
add wave -noupdate /binary_search_ctrl_testbench/update_r
add wave -noupdate /binary_search_ctrl_testbench/dut/ps
add wave -noupdate /binary_search_ctrl_testbench/dut/ns
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
