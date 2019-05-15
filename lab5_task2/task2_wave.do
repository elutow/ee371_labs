onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /task2_testbench/dut/DATA_WIDTH
add wave -noupdate /task2_testbench/dut/clk
add wave -noupdate /task2_testbench/dut/reset
add wave -noupdate -radix binary /task2_testbench/dut/dataIn
add wave -noupdate -radix binary /task2_testbench/dut/dataOut
add wave -noupdate /task2_testbench/dut/i
add wave -noupdate -radix decimal -childformat {{{/task2_testbench/dut/fifo[7]} -radix decimal} {{/task2_testbench/dut/fifo[6]} -radix decimal} {{/task2_testbench/dut/fifo[5]} -radix decimal} {{/task2_testbench/dut/fifo[4]} -radix decimal} {{/task2_testbench/dut/fifo[3]} -radix decimal} {{/task2_testbench/dut/fifo[2]} -radix decimal} {{/task2_testbench/dut/fifo[1]} -radix decimal} {{/task2_testbench/dut/fifo[0]} -radix decimal}} -subitemconfig {{/task2_testbench/dut/fifo[7]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[6]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[5]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[4]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[3]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[2]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[1]} {-height 15 -radix decimal} {/task2_testbench/dut/fifo[0]} {-height 15 -radix decimal}} /task2_testbench/dut/fifo
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {561 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 129
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {1049 ps}
