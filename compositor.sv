// Module for composing multiple frames together and driving a VGA driver

`include "common.sv"

module compositor
    #(parameter WIDTH=640, HEIGHT=480)
    (
        input logic [7:0] camera_r, camera_g, camera_b,
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
        output logic [7:0] render_r, render_g, render_b
    );

    // Composed color other than the camera layer
    logic [COLOR_WIDTH-1:0] other_color;
    logic [7:0] other_r, other_g, other_b;

    color_index_to_rgb index_to_rgb(
        .index(other_color), .r(other_r), .g(other_g), .b(other_b));

    // Determine pixel color for location
    always_comb begin
        render_r = other_r;
        render_g = other_g;
        render_b = other_b;
        other_color = COLOR_NONE;
        if (cursor_visible && cursor_color != COLOR_NONE) other_color = cursor_color;
        else if (canvas4_visible && canvas4_color != COLOR_NONE) other_color = canvas4_color;
        else if (canvas3_visible && canvas3_color != COLOR_NONE) other_color = canvas3_color;
        else if (canvas2_visible && canvas2_color != COLOR_NONE) other_color = canvas2_color;
        else if (canvas1_visible && canvas1_color != COLOR_NONE) other_color = canvas1_color;
        else begin
            render_r = camera_r;
            render_g = camera_g;
            render_b = camera_b;
        end
    end
endmodule

module compositor_testbench();
    parameter WIDTH=8, HEIGHT=8;
    logic clk, reset;
    logic [7:0] camera_r, camera_g, camera_b;
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
    logic [7:0] render_r, render_g, render_b;

    compositor #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .camera_r, .camera_g, .camera_b,
        .cursor_color, .cursor_visible,
        .canvas1_color, .canvas1_visible, .canvas2_color, .canvas2_visible,
        .canvas3_color, .canvas3_visible, .canvas4_color, .canvas4_visible,
        .render_r, .render_g, .render_b);

    logic [23:0] rgb_out;
    assign rgb_out = {render_r, render_g, render_b};

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
        {camera_r, camera_g, camera_b} = 24'h12_34_56;
        #10;
        assert(rgb_out == 24'h0); // Black
        #1; cursor_visible = 0; #9;
        assert(rgb_out == 24'hFF_FF_FF); // White
        #1; canvas4_visible = 0; #9;
        assert(rgb_out == 24'hFF_00_00); // Red
        #1; canvas3_visible = 0; #9;
        assert(rgb_out == 24'h00_FF_00); // Green
        #1; canvas2_visible = 0; #9;
        assert(rgb_out == 24'h00_00_FF); // Blue
        #1; canvas1_visible = 0; #9;
        assert(rgb_out == 24'h12_34_56); // Camera color
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
