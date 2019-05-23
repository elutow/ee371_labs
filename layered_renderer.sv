// Module for layered rendering

`include "common.sv"

module #(parameter WIDTH=640, HEIGHT=480) layered_renderer(
        input logic clk, reset,
        // TODO: Change to correct type for camera_frame to accomodate camera
        // driver
        input logic [`COLOR_WIDTH-1:0] camera_frame [$clog2(WIDTH)-1:0][$clog2(HEIGHT)-1:0],
        input logic [`COLOR_WIDTH-1:0] cursor_frame [$clog2(WIDTH)-1:0][$clog2(HEIGHT)-1:0],
        input logic cursor_frame_visible,
        input logic [`COLOR_WIDTH-1:0] draw_frame1 [$clog2(WIDTH)-1:0][$clog2(HEIGHT)-1:0],
        input logic draw_frame1_visible,
        input logic [`COLOR_WIDTH-1:0] draw_frame2 [$clog2(WIDTH)-1:0][$clog2(HEIGHT)-1:0],
        input logic draw_frame2_visible,
        input logic [`COLOR_WIDTH-1:0] draw_frame3 [$clog2(WIDTH)-1:0][$clog2(HEIGHT)-1:0],
        input logic draw_frame3_visible,
        input logic [`COLOR_WIDTH-1:0] draw_frame4 [$clog2(WIDTH)-1:0][$clog2(HEIGHT)-1:0],
        input logic draw_frame4_visible,
        output logic [$clog2(WIDTH)-1:0] x,
        output logic [$clog2(HEIGHT)-1:0] y,
        output logic [`COLOR_WIDTH-1:0] pixel_color
    );

    logic [$clog2(WIDTH)-1:0] next_x;
    logic [$clog2(HEIGHT)-1:0] next_y;

    // Cycle through all coordinates
    always_ff @(posedge clk) begin
        if (reset) begin
            x <= 0;
            y <= 0;
        end
        else begin
            x <= next_x;
            y <= next_y;
        end
    end
    always_comb begin
        next_x = x + $clog2(WIDTH)'(1);
        next_y = y + $clog2(HEIGHT)'(1);
        if (next_x == WIDTH) next_x = 0;
        if (next_y == HEIGHT) next_y = 0;
    end

    // Determine pixel color for location
    always_comb begin
        if (cursor_frame_visible && cursor_frame[x][y] != `COLOR_NONE) pixel_color = cursor_frame[x][y];
        else if (draw_frame4_visible && draw_frame4[x][y] != `COLOR_NONE) pixel_color = draw_frame4[x][y];
        else if (draw_frame3_visible && draw_frame3[x][y] != `COLOR_NONE) pixel_color = draw_frame3[x][y];
        else if (draw_frame2_visible && draw_frame2[x][y] != `COLOR_NONE) pixel_color = draw_frame2[x][y];
        else if (draw_frame1_visible && draw_frame1[x][y] != `COLOR_NONE) pixel_color = draw_frame1[x][y];
        else pixel_color = camera_frame[x][y];
    end
endmodule

module layered_renderer_testbench();
    // TODO
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
