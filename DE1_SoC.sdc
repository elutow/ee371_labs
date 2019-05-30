#**************************************************************
# Altera DE1-SoC SDC settings
# Users are recommended to modify this file to match users logic.
#**************************************************************

#**************************************************************
# Create Clock
#**************************************************************
create_clock -period 20 [get_ports CLOCK_50]
create_clock -period 20 [get_ports CLOCK2_50]
create_clock -period 20 [get_ports CLOCK3_50]
create_clock -period 20 [get_ports CLOCK4_50]

create_clock -period "27 MHz"  -name tv_27m [get_ports TD_CLK27]
# AUDIO : 48kHz 384fs 32-bit data
#create_clock -period "18.432 MHz" -name clk_audxck [get_ports AUD_XCK]
#create_clock -period "1.536 MHz" -name clk_audbck [get_ports AUD_BCLK]
# VGA : 640x480@60Hz
create_clock -period "25 MHz" -name clk_vga [get_ports VGA_CLK]
# VGA : 800x600@60Hz
#create_clock -period "40.0 MHz" -name clk_vga [get_ports VGA_CLK]
# VGA : 1024x768@60Hz
#create_clock -period "65.0 MHz" -name clk_vga [get_ports VGA_CLK]
# VGA : 1280x1024@60Hz
#create_clock -period "108.0 MHz" -name clk_vga [get_ports VGA_CLK]

create_clock -period "25.0 MHz"  -name MIPI_PIXEL_CLK [get_ports MIPI_PIXEL_CLK]
create_clock -period "25.0 MHz" -name MIPI_PIXEL_CLK_ext

# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck 3 [get_ports altera_reserved_tdo]

#SDRAM CLK
create_generated_clock -source [get_pins {u0|pll_sys|altera_pll_i|general[1].gpll~PLL_OUTPUT_COUNTER|divclk}] \
                      -name clk_dram_ext [get_ports {DRAM_CLK}]

#**************************************************************
# Create Generated Clock
#**************************************************************
derive_pll_clocks



#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************
derive_clock_uncertainty



#**************************************************************
# Set Input Delay
#**************************************************************
set_input_delay -max -clock tv_27m 3.692 [get_ports TD_DATA*]
set_input_delay -min -clock tv_27m 2.492 [get_ports TD_DATA*]
set_input_delay -max -clock tv_27m 3.654 [get_ports TD_HS]
set_input_delay -min -clock tv_27m 2.454 [get_ports TD_HS]
set_input_delay -max -clock tv_27m 3.656 [get_ports TD_VS]
set_input_delay -min -clock tv_27m 2.456 [get_ports TD_VS]

# tpd  min 1ns ,max 6ns
# suppose +- 100 ps skew
# Board Delay (Data) + Propagation Delay - Board Delay (Clock)

# D8M
# tpd  min 1ns ,max 6ns
set_input_delay -max 6.1 -clock  MIPI_PIXEL_CLK_ext  [get_ports {MIPI_PIXEL_VS MIPI_PIXEL_HS MIPI_PIXEL_D[*]}]
set_input_delay -min 0.9 -clock  MIPI_PIXEL_CLK_ext  [get_ports {MIPI_PIXEL_VS MIPI_PIXEL_HS MIPI_PIXEL_D[*]}]

# SDRAM
# max 5.4(max) +0.4(trace delay) +0.1  = 5.9
# min 2.7(min) +0.4(trace delay) -0.1  = 3.0
set_input_delay -max -clock clk_dram_ext 5.9 [get_ports DRAM_DQ*]
set_input_delay -min -clock clk_dram_ext 3.0 [get_ports DRAM_DQ*]
#shift-window
set_multicycle_path -from [get_clocks {clk_dram_ext}] \
                    -to [get_clocks {u0|pll_sys|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] \
						  -setup 2

#**************************************************************
# Set Output Delay
#**************************************************************
# max : Board Delay (Data) - Board Delay (Clock) + tsu (External Device)
# min : Board Delay (Data) - Board Delay (Clock) - th (External Device)

set_output_delay -max -clock clk_vga 0.220 [get_ports VGA_R*]
set_output_delay -min -clock clk_vga -1.506 [get_ports VGA_R*]
set_output_delay -max -clock clk_vga 0.212 [get_ports VGA_G*]
set_output_delay -min -clock clk_vga -1.519 [get_ports VGA_G*]
set_output_delay -max -clock clk_vga 0.264 [get_ports VGA_B*]
set_output_delay -min -clock clk_vga -1.519 [get_ports VGA_B*]
set_output_delay -max -clock clk_vga 0.215 [get_ports VGA_BLANK]
set_output_delay -min -clock clk_vga -1.485 [get_ports VGA_BLANK]

#SDRAM
# max  1.5+0.1 =  1.6
# min -0.8-0.1 = -0.9
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_DQ* DRAM_*DQM}]
set_output_delay -max -clock clk_dram_ext 1.6  [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]
set_output_delay -min -clock clk_dram_ext -0.9 [get_ports {DRAM_ADDR* DRAM_BA* DRAM_RAS_N DRAM_CAS_N DRAM_WE_N DRAM_CKE DRAM_CS_N}]


#**************************************************************
# Set Clock Groups
#**************************************************************
set_clock_groups -asynchronous -group [get_clocks {u0|pll_sys|altera_pll_i|general[2].gpll~PLL_OUTPUT_COUNTER|divclk}] \
                               -group [get_clocks {MIPI_PIXEL_CLK}]


#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************



#**************************************************************
# Set Load
#**************************************************************

