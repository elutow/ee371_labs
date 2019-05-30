// Module for rendering the cursor

`include "common.sv"

module cursor_renderer
    #(parameter WIDTH=640, HEIGHT=480)
    (
        input logic clk, reset,
        input logic [$clog2(WIDTH)-1:0] cursor_x,
        input logic [$clog2(HEIGHT)-1:0] cursor_y,
        input logic [COLOR_WIDTH-1:0] current_color,
        input logic [$clog2(WIDTH)-1:0] request_x,
        input logic [$clog2(HEIGHT)-1:0] request_y,
        output logic [COLOR_WIDTH-1:0] render_color 
    );
    logic [COLOR_WIDTH-1:0] cursor_frame [WIDTH-1:0][HEIGHT-1:0] = '{default:COLOR_NONE};

    logic [$clog2(WIDTH)-1:0] x, next_x;
    logic [$clog2(HEIGHT)-1:0] y, next_y;
    logic [COLOR_WIDTH-1:0] color, next_color;
    // Animation step
    logic [$clog2(140):0] step, next_step;

    enum {STATE_INIT, STATE_DRAW, STATE_ERASE} ps, ns;

    always_comb begin
        unique case (ps)
            STATE_INIT: begin
                ns = STATE_DRAW;
                next_x = cursor_x;
                next_y = cursor_y;
                next_color = current_color;
                next_step = 0;
            end
            STATE_DRAW: begin
                ns = STATE_DRAW;
                next_color = color;
                next_step = step + 'd1;
                unique case (step)
                    `include "cursor_renderer_draw_steps.sv"
                endcase
            end
            STATE_ERASE: begin
                ns = STATE_ERASE;
                next_color = COLOR_NONE;
                next_step = step + 'd1;
                unique case (step)
                    `include "cursor_renderer_erase_steps.sv"
                endcase
            end
        endcase
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            ps <= STATE_INIT;
            x <= cursor_x;
            y <= cursor_y;
            color <= COLOR_NONE;
            step <= 0;
        end
        else begin
            ps <= ns;
            x <= next_x;
            y <= next_y;
            color <= next_color;
            step <= next_step;
        end
        cursor_frame[x][y] <= color;
        render_color <= cursor_frame[request_x][request_y];
    end
endmodule

module cursor_renderer_testbench();
    parameter WIDTH=32, HEIGHT=32;
    logic clk, reset;
    logic [$clog2(WIDTH)-1:0] cursor_x;
    logic [$clog2(HEIGHT)-1:0] cursor_y;
    logic [COLOR_WIDTH-1:0] current_color;
    logic [$clog2(WIDTH)-1:0] request_x;
    logic [$clog2(HEIGHT)-1:0] request_y;
    logic [COLOR_WIDTH-1:0] render_color;

    cursor_renderer #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .clk, .reset, .cursor_x, .cursor_y, .current_color,
        .request_x, .request_y, .render_color);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    int i;
    initial begin
        cursor_x <= 0; cursor_y <= 0; current_color <= COLOR_BLUE;
        request_x <= 1; request_y <= 1;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        // Test drawing in one location
        for (i=0; i<142; i++) begin
            @(posedge clk);
        end
        // Test erasing and drawing in new location
        cursor_x <= 5; cursor_y <= 5; @(posedge clk);
        for (i=0; i<142; i++) begin
            @(posedge clk);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
