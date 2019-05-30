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
    inout PS2_CLK, PS2_DAT;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_BLANK_N;
    output VGA_CLK;
    output VGA_HS;
    output VGA_SYNC_N;
    output VGA_VS;

    // Inter-module signals
    logic [COLOR_WIDTH-1:0] current_color;
    logic [2:0] current_layer;
    // VGA I/O
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

    // Filtered signals
    logic reset;
    logic canvas1_visible, canvas2_visible, canvas3_visible, canvas4_visible;
    logic cursor_visible;
    logic layer_toggle;

    // Metastability filters
    metastability_filter reset_filter(
        .clk(CLOCK_50), .reset(1'b0), .direct_in(~KEY[3]), .filtered_out(reset));
    metastability_filter layer_toggle_filter(
        .clk(CLOCK_50), .reset, .direct_in(~KEY[0]), .filtered_out(layer_toggle));
    metastability_filter cursor_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[0]), .filtered_out(cursor_visible));
    metastability_filter frame1_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[1]), .filtered_out(canvas1_visible));
    metastability_filter frame2_visible_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[2]), .filtered_out(canvas2_visible));

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
        .camera_r(8'h00), .camera_g(8'hAA), .camera_b(8'hAA),
        .cursor_color, .cursor_visible,
        .canvas1_color, .canvas1_visible,
        .canvas2_color, .canvas2_visible,
        .canvas3_color, .canvas3_visible,
        .canvas4_color, .canvas4_visible,
        .render_r(vga_r), .render_g(vga_g), .render_b(vga_b));

    // Peripheral attachments
    ps2 #(.WIDTH(WIDTH), .HEIGHT(HEIGHT), .HYSTERESIS(2), .BIN(5)) ps2_mouse(
        .CLOCK_50, .start(reset), .reset, .PS2_CLK, .PS2_DAT,
        .button_left(cursor_left), .button_middle(), .button_right(cursor_right),
        .bin_x(cursor_x), .bin_y(raw_cursor_y));
    // Invert y coordinates
    assign cursor_y = $clog2(HEIGHT)'(HEIGHT-1) - $clog2(HEIGHT)'(raw_cursor_y);
    // NOTE: VGA driver is hardcoded to 640x480. It will not function
    // correctly at other resolutions! (But for the sake of testbenching, it
    // will run)
    VGA_framebuffer #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) fb(
        .clk50(CLOCK_50), .reset, .request_x, .request_y,
        .r(vga_r), .g(vga_g), .b(vga_b),
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
        .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));

    // Misc board I/O attachments
    seg7 layer_display(
        .hex({1'b0, current_layer}), .out(HEX0));
endmodule

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
