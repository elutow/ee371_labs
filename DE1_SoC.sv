`include "common.sv"

module DE1_SoC
    #(parameter WIDTH=640, HEIGHT=480)
    (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, PS2_CLK, PS2_DAT,
    VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS,
    CLOCK2_50, CLOCK3_50, DRAM_ADDR, DRAM_BA, DRAM_CAS_N, DRAM_CKE, DRAM_CLK,
    DRAM_CS_N, DRAM_DQ, DRAM_RAS_N, DRAM_WE_N, CAMERA_I2C_SCL, CAMERA_I2C_SDA,
    CAMERA_PWDN_n, MIPI_CS_n, MIPI_I2C_SCL, MIPI_I2C_SDA, MIPI_MCLK, MIPI_PIXEL_CLK,
    MIPI_PIXEL_D, MIPI_PIXEL_HS, MIPI_PIXEL_VS, MIPI_REFCLK, MIPI_RESET_n);

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input logic [3:0] KEY;
    input logic [9:0] SW;

    input logic CLOCK_50, CLOCK2_50, CLOCK3_50;
    inout PS2_CLK, PS2_DAT;
    output logic [7:0] VGA_R;
    output logic [7:0] VGA_G;
    output logic [7:0] VGA_B;
    output logic VGA_BLANK_N;
    output logic VGA_CLK;
    output logic VGA_HS;
    output logic VGA_SYNC_N;
    output logic VGA_VS;

    inout [15:0] DRAM_DQ;
    output logic [12:0] DRAM_ADDR;
    output logic [1:0] DRAM_BA;
    output logic DRAM_CAS_N;
    output logic DRAM_CKE;
    output logic DRAM_CLK;
    output logic DRAM_CS_N;
    output logic DRAM_RAS_N;
    output logic DRAM_WE_N;

    inout CAMERA_I2C_SDA;
    inout MIPI_I2C_SCL;
    inout MIPI_I2C_SDA;
    input logic MIPI_PIXEL_CLK;
    input logic MIPI_PIXEL_HS;
    input logic MIPI_PIXEL_VS;
    input logic [9:0] MIPI_PIXEL_D;
    output logic CAMERA_I2C_SCL;
    output logic CAMERA_PWDN_n;
    output logic MIPI_CS_n;
    output logic MIPI_MCLK;
    output logic MIPI_REFCLK;
    output logic MIPI_RESET_n;

    // Inter-module signals
    logic [COLOR_WIDTH-1:0] current_color;
    logic [2:0] current_layer;
    // VGA I/O
    logic vga_read_enable;
    logic [7:0] vga_r, vga_g, vga_b;
    logic [$clog2(WIDTH)-1:0] request_x;
    logic [$clog2(HEIGHT)-1:0] request_y;
    // Cursor renderer I/O
    logic cursor_left, cursor_right;
    logic [$clog2(WIDTH)-1:0] cursor_x;
    logic [$clog2(HEIGHT)-1:0] raw_cursor_y, cursor_y;
    logic [COLOR_WIDTH-1:0] cursor_color;
    // Freehand tool I/O
    logic [$clog2(WIDTH)-1:0] tool_x;
    logic [$clog2(HEIGHT)-1:0] tool_y;
    logic [COLOR_WIDTH-1:0] tool_color;
    // Drawing canvas I/O
    logic [COLOR_WIDTH-1:0] canvas1_color, canvas2_color, canvas3_color, canvas4_color;
    // Terasic camera I/O
    logic [7:0] camera_r, camera_g, camera_b;

    // Filtered signals
    logic reset;
    logic canvas1_visible, canvas2_visible, canvas3_visible, canvas4_visible;
    logic cursor_visible;
    logic layer_toggle;
    logic take_picture;
    logic ps2_start;

    // Turn off unwanted hex displays
    assign HEX1 = 7'hFF;
    assign HEX2 = 7'hFF;
    assign HEX3 = 7'hFF;
    assign HEX4 = 7'hFF;
    assign HEX5 = 7'hFF;

    // Metastability filters
    metastability_filter reset_filter(
        .clk(CLOCK_50), .reset(1'b0), .direct_in(~KEY[3]), .filtered_out(reset));
    metastability_filter ps2_start_filter(
        .clk(CLOCK_50), .reset, .direct_in(~KEY[2]), .filtered_out(ps2_start));
    metastability_filter layer_toggle_filter(
        .clk(CLOCK_50), .reset, .direct_in(~KEY[0]), .filtered_out(layer_toggle));
    metastability_filter cursor_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[0]), .filtered_out(cursor_visible));
    metastability_filter frame1_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[1]), .filtered_out(canvas1_visible));
    metastability_filter frame2_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[2]), .filtered_out(canvas2_visible));
    metastability_filter take_picture_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[9]), .filtered_out(take_picture));

    // Cursor logic attachments
    color_selector select_color(
        .clk(CLOCK_50), .reset, .toggle(cursor_right), .color(current_color));
    layer_selector select_layer(
        .clk(CLOCK_50), .reset, .toggle(layer_toggle), .layer(current_layer));
    freehand_tool #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) tool_freehand(
        .clk(CLOCK_50), .reset, .enable(cursor_left), .cursor_x, .cursor_y, .input_color(current_color),
        .pixel_x(tool_x), .pixel_y(tool_y), .pixel_color(tool_color));
    cursor_renderer #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) cursor_drawer(
        .clk(CLOCK_50), .reset, .cursor_x, .cursor_y, .current_color,
        .request_x, .request_y, .render_color(cursor_color));

    // Drawing canvases
    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) canvas1(
        .clk(CLOCK_50), .enable(current_layer == 1 && canvas1_visible),
        .tool_x, .tool_y, .tool_color,
        .pixel_x(request_x), .pixel_y(request_y), .pixel_color(canvas1_color));
    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) canvas2(
        .clk(CLOCK_50), .enable(current_layer == 2 && canvas2_visible),
        .tool_x, .tool_y, .tool_color,
        .pixel_x(request_x), .pixel_y(request_y), .pixel_color(canvas2_color));
    assign canvas3_color = COLOR_NONE;
    assign canvas3_visible = 0;
    assign canvas4_color = COLOR_NONE;
    assign canvas4_visible = 0;

    // Drawing I/O to VGA I/O
    compositor #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) composer(
        .camera_r, .camera_g, .camera_b,
        .cursor_color, .cursor_visible,
        .canvas1_color, .canvas1_visible,
        .canvas2_color, .canvas2_visible,
        .canvas3_color, .canvas3_visible,
        .canvas4_color, .canvas4_visible,
        .render_r(vga_r), .render_g(vga_g), .render_b(vga_b));

    // Peripheral attachments
    ps2 #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .HYSTERESIS(2), .BIN(5)) ps2_mouse(
        .CLOCK_50, .start(ps2_start), .reset, .PS2_CLK, .PS2_DAT,
        .button_left(cursor_left), .button_middle(), .button_right(cursor_right),
        .bin_x(cursor_x), .bin_y(raw_cursor_y));

    // For ensuring mouse enables
    assign LEDR[9] = cursor_left;
    assign LEDR[8] = cursor_right;

    // Invert y coordinates
    assign cursor_y = $clog2(HEIGHT)'(HEIGHT-1) - $clog2(HEIGHT)'(raw_cursor_y);
    video_driver #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) vga_driver(
        .CLOCK_50, .reset, .x(request_x), .y(request_y),
        .r(vga_r), .g(vga_g), .b(vga_b), .read_enable(vga_read_enable),
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
        .VGA_BLANK_N, .VGA_SYNC_N);
    terasic_camera gpio_camera(
        .reset, .take_picture, .READ_Request(vga_read_enable),
        .out_r(camera_r), .out_g(camera_g), .out_b(camera_b),
        .DRAM_ADDR, .DRAM_BA, .DRAM_CAS_N, .DRAM_CKE, .DRAM_CLK, .DRAM_CS_N, .DRAM_DQ,
        .DRAM_RAS_N, .DRAM_WE_N, .CLOCK2_50, .CLOCK3_50, .CLOCK_50, .VGA_HS, .VGA_VS, .VGA_CLK,
        .CAMERA_I2C_SCL, .CAMERA_I2C_SDA, .CAMERA_PWDN_n, .MIPI_CS_n, .MIPI_I2C_SCL,
        .MIPI_I2C_SDA, .MIPI_MCLK, .MIPI_PIXEL_CLK, .MIPI_PIXEL_D, .MIPI_PIXEL_HS, .MIPI_PIXEL_VS,
        .MIPI_REFCLK, .MIPI_RESET_n);

    // Misc board I/O attachments
    seg7 layer_display(
        .hex({1'b0, current_layer}), .out(HEX0));
endmodule

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;

    logic CLOCK_50;
    wire PS2_CLK, PS2_DAT;
    logic [7:0] VGA_R;
    logic [7:0] VGA_G;
    logic [7:0] VGA_B;
    logic VGA_BLANK_N;
    logic VGA_CLK;
    logic VGA_HS;
    logic VGA_SYNC_N;
    logic VGA_VS;

    DE1_SoC #(.WIDTH(8), .HEIGHT(8)) dut(
        .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .CLOCK_50, .PS2_CLK, .PS2_DAT,
        .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    int i;
    initial begin
        SW[0] <= 1;
        SW[1] <= 1;
        SW[2] <= 1;
        KEY[3] <= 0; @(posedge CLOCK_50);
        KEY[3] <= 1; @(posedge CLOCK_50);
        for (i=0; i<20; i++) begin
            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
