// Module to select a color to draw

`include "common.sv"

module color_selector
    (
        input logic clk, reset, toggle,
        output logic [COLOR_WIDTH-1:0] color
    );

    logic [COLOR_WIDTH-1:0] next_color;
    logic changed, next_changed;

    always_comb begin
        next_color = color;
        next_changed = changed;
        if (toggle) begin
            if (!changed) begin
                next_changed = 1;
                case (color)
                    COLOR_BLACK: next_color = COLOR_WHITE;
                    COLOR_WHITE: next_color = COLOR_RED;
                    COLOR_RED: next_color = COLOR_GREEN;
                    COLOR_GREEN: next_color = COLOR_BLUE;
                    COLOR_BLUE: next_color = COLOR_NONE;
                    COLOR_NONE: next_color = COLOR_BLACK;
                    default: next_color = 'x;
                endcase
            end
        end
        else begin
            next_changed = 0;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            color <= COLOR_BLUE;
            changed <= 0;
        end
        else begin
            color <= next_color;
            changed <= next_changed;
        end
    end
endmodule

module color_selector_testbench();
    logic clk, reset, toggle;
    logic [COLOR_WIDTH-1:0] color;

    color_selector dut(.clk, .reset, .toggle, .color);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        toggle <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        assert(color == COLOR_BLUE);
        // Toggle color
        toggle <= 1; @(posedge clk);
        @(posedge clk);
        assert(color == COLOR_BLACK);
        // Ensure color doesn't change while toggle is still 1
        @(posedge clk);
        assert(color == COLOR_BLACK);
        // Toggle off and see if color changes
        toggle <= 0; @(posedge clk);
        assert(color == COLOR_BLACK);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
