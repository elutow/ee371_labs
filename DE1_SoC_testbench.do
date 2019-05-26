# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "color_index_to_rgb.sv"
vlog "color_selector.sv"
vlog "common.sv"
vlog "compositor.sv"
vlog "cursor_renderer.sv"
vlog "DE1_SoC.sv"
vlog "drawing_canvas.sv"
vlog "Filter.sv"
vlog "freehand_tool.sv"
vlog "layer_selector.sv"
vlog "metastability_filter.sv"
vlog "seg7.sv"
vlog "VGA_framebuffer.sv"
vlog "ps2.v"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps  -lib work DE1_SoC_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do DE1_SoC_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
