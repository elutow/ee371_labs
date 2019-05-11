# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "averaging_filter.sv"
vlog "DE1_SoC.sv"
vlog "fifo_ctrl.sv"
vlog "fifo.sv"
vlog "reg_file.sv"
vlog "Altera_UP_Audio_Bit_Counter.v"
vlog "Altera_UP_Audio_In_Deserializer.v"
vlog "Altera_UP_Audio_Out_Serializer.v"
vlog "Altera_UP_Clock_Edge.v"
vlog "Altera_UP_I2C_AV_Auto_Initialize.v"
vlog "Altera_UP_I2C_DC_Auto_Initialize.v"
vlog "Altera_UP_I2C_LCM_Auto_Initialize.v"
vlog "Altera_UP_I2C.v"
vlog "Altera_UP_Slow_Clock_Generator.v"
vlog "Altera_UP_SYNC_FIFO.v"
vlog "audio_and_video_config.v"
vlog "audio_codec.v"
vlog "clock_generator.v"
vlog "DE1_SOC_golden_top.v"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -Lf altera_mf_ver -lib work DE1_SoC_testbench

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
