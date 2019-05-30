# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "CLOCK25_PLL.v"
vlog "CLOCK25_PLL/CLOCK25_PLL_0002.v"
vlog "DE1_SoC.sv"
vlog "altera_up_avalon_video_vga_timing.v"
vlog "color_index_to_rgb.sv"
vlog "color_selector.sv"
vlog "common.sv"
vlog "compositor.sv"
vlog "cursor_renderer.sv"
vlog "drawing_canvas.sv"
vlog "freehand_tool.sv"
vlog "layer_selector.sv"
vlog "metastability_filter.sv"
vlog "ps2.sv"
vlog "seg7.sv"
vlog "terasic_camera.sv"
vlog "video_driver.sv"
vlog "V/CLOCKMEM.v"
vlog "V/CLOCK_DELAY.v"
vlog "V/I2C_READ_DATA.v"
vlog "V/I2C_RESET_DELAY.v"
vlog "V/I2C_WRITE_PTR.v"
vlog "V/I2C_WRITE_WDATA.v"
vlog "V/RESET_DELAY.v"
vlog "V/pll_test.v"
vlog "V/sdram_pll.v"
vlog "V_Auto/AUTO_FOCUS_ON.v"
vlog "V_Auto/AUTO_SYNC_MODIFY.v"
vlog "V_Auto/FOCUS_ADJ.v"
vlog "V_Auto/F_VCM.v"
vlog "V_Auto/I2C_DELAY.v"
vlog "V_Auto/LCD_COUNTER.v"
vlog "V_Auto/MODIFY_SYNC.v"
vlog "V_Auto/VCM_CTRL_P.v"
vlog "V_Auto/VCM_I2C.v"
vlog "V_D8M/Line_Buffer_J.v"
vlog "V_D8M/MIPI_BRIDGE_CAMERA_Config.v"
vlog "V_D8M/MIPI_BRIDGE_CONFIG.v"
vlog "V_D8M/MIPI_CAMERA_CONFIG.v"
vlog "V_D8M/RAW2RGB_J.v"
vlog "V_D8M/RAW_RGB_BIN.v"
vlog "V_D8M/VGA_RD_COUNTER.v"
vlog "V_D8M/int_line.v"
vlog "V_Sdram_Control/Sdram_Control.v"
vlog "V_Sdram_Control/Sdram_RD_FIFO.v"
vlog "V_Sdram_Control/Sdram_WR_FIFO.v"
vlog "V_Sdram_Control/command.v"
vlog "V_Sdram_Control/control_interface.v"
vlog "V_Sdram_Control/sdr_data_path.v"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -Lf altera_lnsim -Lf altera_mf_ver -lib work DE1_SoC_testbench

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
