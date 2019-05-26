// Module to store drawing commands and produces frame buffers for the
// compositor

`include "common.sv"

module drawing_canvas
    #(parameter WIDTH=640, HEIGHT=480)
    (
        input logic clk, enable,
        input logic [$clog2(WIDTH)-1:0] tool_x,
        input logic [$clog2(HEIGHT)-1:0] tool_y,
        input logic [COLOR_WIDTH-1:0] tool_color,
        input logic [$clog2(WIDTH)-1:0] pixel_x,
        input logic [$clog2(HEIGHT)-1:0] pixel_y,
        output logic [COLOR_WIDTH-1:0] pixel_color
    );
    logic [COLOR_WIDTH-1:0] frame [WIDTH-1:0][HEIGHT-1:0] = '{default:COLOR_NONE};

    always_ff @(posedge clk) begin
        if (enable) frame[tool_x][tool_y] <= tool_color;
        pixel_color <= frame[pixel_x][pixel_y];
    end
endmodule

module drawing_canvas_testbench();
    parameter WIDTH=8, HEIGHT=8;
    logic clk, enable;
    logic [$clog2(WIDTH)-1:0] tool_x;
    logic [$clog2(HEIGHT)-1:0] tool_y;
    logic [COLOR_WIDTH-1:0] tool_color;
    logic [$clog2(WIDTH)-1:0] pixel_x;
    logic [$clog2(HEIGHT)-1:0] pixel_y;
    logic [COLOR_WIDTH-1:0] pixel_color;

    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .clk, .enable, .tool_x, .tool_y, .tool_color, .pixel_x, .pixel_y, .pixel_color);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        enable <= 0; tool_x <= 0; tool_y <= 0; tool_color <= COLOR_BLUE;
        pixel_x <= 0; pixel_y <= 0;
        @(posedge clk);
        assert(dut.frame[0][0] == COLOR_NONE);
        enable <= 1; @(posedge clk);
        @(posedge clk);
        assert(dut.frame[0][0] == COLOR_BLUE);
        @(posedge clk);
        assert(pixel_color == COLOR_BLUE);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
