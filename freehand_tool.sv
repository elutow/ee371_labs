// Freehand drawing/erasing tool

`include "common.sv"

module freehand_tool
    #(parameter WIDTH=640, HEIGHT=480)
    (
        input logic clk, reset, enable,
        input logic [$clog2(WIDTH)-1:0] cursor_x,
        input logic [$clog2(HEIGHT)-1:0] cursor_y,
        input logic [COLOR_WIDTH-1:0] input_color,
        output logic [$clog2(WIDTH)-1:0] pixel_x,
        output logic [$clog2(HEIGHT)-1:0] pixel_y,
        output logic [COLOR_WIDTH-1:0] pixel_color
    );

    logic [$clog2(WIDTH)-1:0] next_x;
    logic [$clog2(HEIGHT)-1:0] next_y;
    logic [COLOR_WIDTH-1:0] next_color;
    // Animation step
    logic [3:0] step, next_step;

    enum {STATE_INIT, STATE_DRAW} ps, ns;

    always_comb begin
        unique case (ps)
            STATE_INIT: begin
                ns = STATE_DRAW;
                next_x = cursor_x;
                next_y = cursor_y;
                next_color = input_color;
                next_step = 0;
            end
            STATE_DRAW: begin
                ns = STATE_DRAW;
                next_color = pixel_color;
                unique case (step)
                    0: begin
                        next_x = pixel_x;
                        next_y = pixel_y;
                        next_step = 4'd1;
                    end
                    1: begin
                        next_x = pixel_x + $clog2(WIDTH)'(1);
                        next_y = pixel_y;
                        next_step = 4'd2;
                    end
                    2: begin
                        next_x = pixel_x;
                        next_y = pixel_y + $clog2(HEIGHT)'(1);
                        next_step = 4'd3;
                    end
                    3: begin
                        next_x = pixel_x - $clog2(WIDTH)'(1);
                        next_y = pixel_y;
                        next_step = 4'd4;
                    end
                    4: begin
                        next_x = pixel_x;
                        next_y = pixel_y - $clog2(HEIGHT)'(1);
                        next_step = 4'd5;
                    end
                    5: begin
                        next_x = pixel_x;
                        next_y = pixel_y;
                        next_step = step;
                        if (enable) begin
                            ns = STATE_INIT;
                        end
                    end
                    default: begin
                        next_x = 'x;
                        next_y = 'x;
                        next_step = 'x;
                        $error("Default of STATE_DRAW reached!");
                    end
                endcase
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ps <= STATE_INIT;
            pixel_x <= cursor_x;
            pixel_y <= cursor_y;
            pixel_color <= COLOR_NONE;
            step <= 0;
        end
        else begin
            ps <= ns;
            pixel_x <= next_x;
            pixel_y <= next_y;
            pixel_color <= next_color;
            step <= next_step;
        end
    end
endmodule

module freehand_tool_testbench();
    parameter WIDTH=8, HEIGHT=8;
    logic clk, reset, enable;
    logic [$clog2(WIDTH)-1:0] cursor_x;
    logic [$clog2(HEIGHT)-1:0] cursor_y;
    logic [COLOR_WIDTH-1:0] input_color;
    logic [$clog2(WIDTH)-1:0] pixel_x;
    logic [$clog2(HEIGHT)-1:0] pixel_y;
    logic [COLOR_WIDTH-1:0] pixel_color;

    freehand_tool #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .clk, .reset, .enable, .cursor_x, .cursor_y, .input_color, .pixel_x, .pixel_y, .pixel_color);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    int i;
    initial begin
        cursor_x <= 0; cursor_y <= 0; input_color <= COLOR_BLUE; enable <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        // Test drawing in one location
        for (i=0; i<7; i++) begin
            @(posedge clk);
        end
        enable <= 1; input_color <= COLOR_GREEN;
        cursor_x <= 1; cursor_y <= 1; @(posedge clk);
        // Test drawing in new location with new color
        for (i=0; i<6; i++) begin
            @(posedge clk);
        end
        enable <= 0; @(posedge clk);
        // Test re-disabling
        for (i=0; i<7; i++) begin
            @(posedge clk);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
