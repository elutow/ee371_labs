onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /cursor_renderer_testbench/clk
add wave -noupdate /cursor_renderer_testbench/reset
add wave -noupdate -radix unsigned /cursor_renderer_testbench/cursor_x
add wave -noupdate -radix unsigned /cursor_renderer_testbench/cursor_y
add wave -noupdate /cursor_renderer_testbench/current_color
add wave -noupdate -radix unsigned /cursor_renderer_testbench/request_x
add wave -noupdate -radix unsigned /cursor_renderer_testbench/request_y
add wave -noupdate -radix unsigned /cursor_renderer_testbench/render_color
add wave -noupdate /cursor_renderer_testbench/dut/ps
add wave -noupdate /cursor_renderer_testbench/dut/ns
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[0]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[1]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[2]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[3]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[4]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[5]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[6]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[7]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[8]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[9]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[10]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[11]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[12]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[13]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[14]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[15]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[16]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[17]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[18]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[19]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[20]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[21]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[22]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[23]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[24]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[25]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[26]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[27]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[28]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[29]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[30]}
add wave -noupdate -radix unsigned {/cursor_renderer_testbench/dut/cursor_frame[31]}
add wave -noupdate -radix unsigned /cursor_renderer_testbench/dut/step
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7977 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 155
configure wave -valuecolwidth 400
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
WaveRestoreZoom {0 ps} {60052 ps}
