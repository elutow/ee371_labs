// Module for composing multiple frames together and driving a VGA driver

`include "common.sv"

module compositor
    #(parameter WIDTH=640, HEIGHT=480)
    (
        // TODO: Change to correct type for camera_color to accomodate camera
        // driver
        input logic [COLOR_WIDTH-1:0] camera_color,
        input logic [COLOR_WIDTH-1:0] cursor_color,
        input logic cursor_visible,
        input logic [COLOR_WIDTH-1:0] canvas1_color,
        input logic canvas1_visible,
        input logic [COLOR_WIDTH-1:0] canvas2_color,
        input logic canvas2_visible,
        input logic [COLOR_WIDTH-1:0] canvas3_color,
        input logic canvas3_visible,
        input logic [COLOR_WIDTH-1:0] canvas4_color,
        input logic canvas4_visible,
        output logic [COLOR_WIDTH-1:0] render_color
    );

    // Determine pixel color for location
    always_comb begin
        if (cursor_visible && cursor_color != COLOR_NONE) render_color = cursor_color;
        else if (canvas4_visible && canvas4_color != COLOR_NONE) render_color = canvas4_color;
        else if (canvas3_visible && canvas3_color != COLOR_NONE) render_color = canvas3_color;
        else if (canvas2_visible && canvas2_color != COLOR_NONE) render_color = canvas2_color;
        else if (canvas1_visible && canvas1_color != COLOR_NONE) render_color = canvas1_color;
        else render_color = camera_color;
    end
endmodule

module compositor_testbench();
    parameter WIDTH=8, HEIGHT=8;
    logic clk, reset;
    logic [COLOR_WIDTH-1:0] camera_color;
    logic [COLOR_WIDTH-1:0] cursor_color;
    logic cursor_visible;
    logic [COLOR_WIDTH-1:0] canvas1_color;
    logic canvas1_visible;
    logic [COLOR_WIDTH-1:0] canvas2_color;
    logic canvas2_visible;
    logic [COLOR_WIDTH-1:0] canvas3_color;
    logic canvas3_visible;
    logic [COLOR_WIDTH-1:0] canvas4_color;
    logic canvas4_visible;
    logic [COLOR_WIDTH-1:0] render_color;

    compositor #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .camera_color, .cursor_color, .cursor_visible,
        .canvas1_color, .canvas1_visible, .canvas2_color, .canvas2_visible,
        .canvas3_color, .canvas3_visible, .canvas4_color, .canvas4_visible,
        .render_color);

    initial begin
        cursor_color = COLOR_BLACK;
        cursor_visible = 1;
        canvas4_color = COLOR_WHITE;
        canvas4_visible = 1;
        canvas3_color = COLOR_RED;
        canvas3_visible = 1;
        canvas2_color = COLOR_GREEN;
        canvas2_visible = 1;
        canvas1_color = COLOR_BLUE;
        canvas1_visible = 1;
        camera_color = COLOR_NONE;
        #10;
        assert(render_color == COLOR_BLACK);
        #1; cursor_visible = 0; #9;
        assert(render_color == COLOR_WHITE);
        #1; canvas4_visible = 0; #9;
        assert(render_color == COLOR_RED);
        #1; canvas3_visible = 0; #9;
        assert(render_color == COLOR_GREEN);
        #1; canvas2_visible = 0; #9;
        assert(render_color == COLOR_BLUE);
        #1; canvas1_visible = 0; #9;
        assert(render_color == COLOR_NONE);
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
