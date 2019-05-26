`include "common.sv"

module DE1_SoC
    #(parameter WIDTH=640, HEIGHT=480)
    (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, PS2_CLK, PS2_DAT,
    VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input logic [3:0] KEY;
    input logic [9:0] SW;

    input CLOCK_50;
    input PS2_CLK, PS2_DAT;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_BLANK_N;
    output VGA_CLK;
    output VGA_HS;
    output VGA_SYNC_N;
    output VGA_VS;

    // Inter-module signals
    logic [COLOR_WIDTH-1:0] current_color, rendered_color;
    logic [2:0] current_layer;
    // VGA I/O
    logic [$clog2(WIDTH)-1:0] vga_x;
    logic [$clog2(HEIGHT)-1:0] vga_y;
    logic [7:0] vga_r, vga_g, vga_b;
    // Cursor I/O
    logic cursor_left, cursor_middle, cursor_right;
    logic [$clog2(WIDTH)-1:0] cursor_x;
    logic [$clog2(HEIGHT)-1:0] cursor_y;
    logic [COLOR_WIDTH-1:0] cursor_frame [WIDTH-1:0][HEIGHT-1:0];
    // Freehand tool I/O
    logic [$clog2(WIDTH)-1:0] tool_x;
    logic [$clog2(HEIGHT)-1:0] tool_y;
    logic [COLOR_WIDTH-1:0] tool_color;
    // Drawing canvas I/O
    logic [COLOR_WIDTH-1:0] draw_frame1 [WIDTH-1:0][HEIGHT-1:0];
    logic [COLOR_WIDTH-1:0] draw_frame2 [WIDTH-1:0][HEIGHT-1:0];
    logic [COLOR_WIDTH-1:0] draw_frame3 [WIDTH-1:0][HEIGHT-1:0];
    logic [COLOR_WIDTH-1:0] draw_frame4 [WIDTH-1:0][HEIGHT-1:0];

    // Filtered signals
    logic reset;
    logic frame1_visible, frame2_visible, frame3_visible, frame4_visible;
    logic cursor_visible;

    metastability_filter reset_filter(
        .clk(CLOCK_50), .reset(1'b0), .direct_in(~KEY[2]), .filtered_out(reset));
    metastability_filter cursor_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[0]), .filtered_out(cursor_visible));
    metastability_filter frame1_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[1]), .filtered_out(frame1_visible));
    metastability_filter frame2_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[2]), .filtered_out(frame2_visible));
    metastability_filter frame3_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[3]), .filtered_out(frame3_visible));
    metastability_filter frame4_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[4]), .filtered_out(frame4_visible));

    ps2 #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) ps2_mouse(
        .CLOCK_50, .start(reset), .reset, .PS2_CLK, .PS2_DAT,
        .button_left(cursor_left), .button_middle(cursor_middle), .button_right(cursor_right),
        .bin_x(cursor_x), .bin_y(cursor_y));
    color_selector select_color(
        .clk(CLOCK_50), .reset, .toggle(cursor_right), .color(current_color));
    layer_selector select_layer(
        .clk(CLOCK_50), .reset, .toggle(cursor_middle), .layer(current_layer));
    seg7 layer_display(
        .hex({1'b0, current_layer}), .out(HEX0));
    cursor_renderer #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) cursor_drawer(
        .clk(CLOCK_50), .reset, .cursor_x, .cursor_y, .current_color, .cursor_frame);
    freehand_tool #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) tool_freehand(
        .clk(CLOCK_50), .reset, .enable(cursor_left), .cursor_x, .cursor_y, .input_color(current_color),
        .pixel_x(tool_x), .pixel_y(tool_y), .pixel_color(tool_color));
    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) canvas1(
        .clk(CLOCK_50), .enable(current_layer == 1 && frame1_visible),
        .x(tool_x), .y(tool_y), .color(tool_color), .frame(draw_frame1));
    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) canvas2(
        .clk(CLOCK_50), .enable(current_layer == 2 && frame2_visible),
        .x(tool_x), .y(tool_y), .color(tool_color), .frame(draw_frame2));
    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) canvas3(
        .clk(CLOCK_50), .enable(current_layer == 3 && frame3_visible),
        .x(tool_x), .y(tool_y), .color(tool_color), .frame(draw_frame3));
    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) canvas4(
        .clk(CLOCK_50), .enable(current_layer == 4 && frame4_visible),
        .x(tool_x), .y(tool_y), .color(tool_color), .frame(draw_frame4));
    compositor #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) composer(
        .clk(CLOCK_50), .reset, .camera_frame('{default:COLOR_BLACK}), .cursor_frame,
        .cursor_frame_visible(cursor_visible),
        .draw_frame1, .draw_frame1_visible(frame1_visible),
        .draw_frame2, .draw_frame2_visible(frame2_visible),
        .draw_frame3, .draw_frame3_visible(frame3_visible),
        .draw_frame4, .draw_frame4_visible(frame4_visible),
        .x(vga_x), .y(vga_y), .pixel_color(rendered_color));
    color_index_to_rgb index_to_rgb(
        .index(rendered_color), .r(vga_r), .g(vga_g), .b(vga_b));
    VGA_framebuffer fb(
        .clk50(CLOCK_50), .reset, .x({1'b0, vga_x}), .y({2'b0, vga_y}),
        .r(vga_r), .g(vga_g), .b(vga_b), .pixel_write(1'b1),
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
        .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));
endmodule

module DE1_SoC_testbench();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;

    logic CLOCK_50;
    logic PS2_CLK, PS2_DAT;
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
        KEY[2] <= 0; @(posedge CLOCK_50);
        KEY[2] <= 1; @(posedge CLOCK_50);
        for (i=0; i<20; i++) begin
            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
