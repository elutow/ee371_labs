// Module to store drawing commands and produces frame buffers for the
// compositor

`include "common.sv"

module drawing_canvas
    #(parameter WIDTH=640, HEIGHT=480)
    (
        input logic clk, enable,
        input logic [$clog2(WIDTH)-1:0] x,
        input logic [$clog2(HEIGHT)-1:0] y,
        input logic [COLOR_WIDTH-1:0] color,
        output logic [COLOR_WIDTH-1:0] frame [WIDTH-1:0][HEIGHT-1:0] = '{default:COLOR_NONE}
    );

    always_ff @(posedge clk) begin
        if (enable) frame[x][y] <= color;
    end
endmodule

module drawing_canvas_testbench();
    parameter WIDTH=8, HEIGHT=8;
    logic clk, enable;
    logic [$clog2(WIDTH)-1:0] x;
    logic [$clog2(HEIGHT)-1:0] y;
    logic [COLOR_WIDTH-1:0] color;
    logic [COLOR_WIDTH-1:0] frame [WIDTH-1:0][HEIGHT-1:0];

    drawing_canvas #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .clk, .enable, .x, .y, .color, .frame);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        enable <= 0; x <= 0; y <= 0; color <= COLOR_BLUE;
        @(posedge clk);
        assert(frame[0][0] == COLOR_NONE);
        enable <= 1; @(posedge clk);
        @(posedge clk);
        assert(frame[0][0] == COLOR_BLUE);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
