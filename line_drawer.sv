// This module draws a line using Bressenham's algorithm
// - reset causes the line drawer to prepare rendering a new line. The values
//   of the inputs during the reset must already be for the new line.
// - x0, y0, x1, y1 are the source and destination coordinates of the lines.
//   These should not be changed until the line is fully drawn.
// - x and y are the pixels to draw on the screen for the line. When the line
//   is finished drawing, these coordinates will remain at (x1, y1) until
//   reset.
//
// Modular dependencies: N/A

`define abs_diff(X, Y) X>Y ? X-Y : Y-X

module line_drawer(
    input logic clk, reset,
    input logic [10:0] x0, y0, x1, y1, //the end points of the line
    output logic [10:0] x, y //outputs corresponding to the pair (x, y)
    );

    // Compute is_steep
    logic is_steep;
    assign is_steep = (`abs_diff(y1, y0)) > (`abs_diff(x1, x0));

    // Swap variables
    logic [10:0] x0_swp, y0_swp, x1_swp, y1_swp;
    always_comb begin
        if (is_steep) begin
            // swap(x0, y0)
            x0_swp = y0;
            y0_swp = x0;
            // swap(x1, y1)
            x1_swp = y1;
            y1_swp = x1;
            if (x0_swp > x1_swp) begin
                // swap(x0, x1)
                x0_swp = y1;
                x1_swp = y0;
                // swap(y0, y1)
                y0_swp = x1;
                y1_swp = x0;
            end
        end
        else begin
            x0_swp = x0;
            y0_swp = y0;
            x1_swp = x1;
            y1_swp = y1;
            if (x0_swp > x1_swp) begin
                // swap(x0, x1)
                x0_swp = x1;
                x1_swp = x0;
                // swap(y0, y1)
                y0_swp = y1;
                y1_swp = y0;
            end
        end
    end

    // Compute deltas
    logic signed [11:0] deltax;
    logic [10:0] deltay;
    assign deltax = x1_swp - x0_swp;
    assign deltay = `abs_diff(y1_swp, y0_swp);

    // Compute y_step
    logic signed [1:0] y_step;
    assign y_step = y0_swp < y1_swp ? 1 : -1;

    // Define error registers
    logic signed [11:0] error, next_error;

    // Define internal x and y coordinates
    logic [10:0] x_int, y_int, next_x_int, next_y_int;
    // Indicates when drawing is completed
    logic finished;

    // Compute next drawing state values
    always_comb begin
        next_y_int = y_int;
        next_error = error;
        next_x_int = x_int;
        if (!finished && (x_int < x1_swp)) begin
            next_error = error + deltay;
            if (deltay >= -error) begin
                next_y_int = y_int + y_step;
                next_error = next_error - deltax;
            end
            next_x_int = x_int + 1;
        end
    end

    // Transition to next drawing state
    always_ff @(posedge clk) begin
        if (reset) begin
            x_int <= x0_swp;
            y_int <= y0_swp;
            error <= -(deltax / 2);
            finished <= 0;
        end
        else begin
            x_int <= next_x_int;
            y_int <= next_y_int;
            error <= next_error;
            if (x_int == next_x_int && y_int == next_y_int) begin
                finished <= 1;
            end
        end
    end

    // draw_pixel() logic
    always_comb begin
        x = x_int;
        y = y_int;
        if (is_steep) begin
            x = y_int;
            y = x_int;
        end
    end
endmodule

module line_drawer_testbench();
    logic clk, reset;
    logic [10:0] x0, y0, x1, y1, x, y;

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    line_drawer dut(.clk, .reset, .x0, .y0, .x1, .y1, .x, .y);

    initial begin
        // Horizontal line
        x0 <= 0; y0 <= 0; x1 <= 3; y1 <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
            assert(x == 0);
            assert(y == 0);
        @(posedge clk); assert(x == 1);
        @(posedge clk); assert(x == 2);
        @(posedge clk); assert(x == 3);
        // Should stay at endpoint
        @(posedge clk);
            assert(x == 3);
            assert(y == 0);
        @(posedge clk);
            assert(x == 3);
            assert(y == 0);
        // Vertical line
        x0 <= 0; y0 <= 3; x1 <= 0; y1 <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
            assert(x == 0);
            assert(y == 0);
        @(posedge clk); assert(y == 1);
        @(posedge clk); assert(y == 2);
        @(posedge clk); assert(y == 3);
        // Should stay at endpoint
        @(posedge clk);
            assert(x == 0);
            assert(y == 3);
        @(posedge clk);
            assert(x == 0);
            assert(y == 3);
        // 45 degree diagonal line
        x0 <= 3; y0 <= 3; x1 <= 0; y1 <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
            assert(x == 0);
            assert(y == 0);
        @(posedge clk);
            assert(x == 1);
            assert(y == 1);
        @(posedge clk);
            assert(x == 2);
            assert(y == 2);
        @(posedge clk);
            assert(x == 3);
            assert(y == 3);
        // Should stay at endpoint
        @(posedge clk);
            assert(x == 3);
            assert(y == 3);
        // Test finished state
        x0 <= 6; y0 <= 6; x1 <= 0; y1 <= 0;
        @(posedge clk);
            assert(x == 3);
            assert(y == 3);
        @(posedge clk);
            assert(x == 3);
            assert(y == 3);
        // Irregular angled line
        x0 <= 0; y0 <= 0; x1 <= 2; y1 <= 5;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
            assert(x == 0);
            assert(y == 0);
        @(posedge clk);
            assert(x == 1);
            assert(y == 1);
        @(posedge clk);
            assert(x == 1);
            assert(y == 2);
        @(posedge clk);
            assert(x == 1);
            assert(y == 3);
        @(posedge clk);
            assert(x == 2);
            assert(y == 4);
        @(posedge clk);
            assert(x == 2);
            assert(y == 5);
        // Should stay at endpoint
        @(posedge clk);
            assert(x == 2);
            assert(y == 5);
        @(posedge clk);
            assert(x == 2);
            assert(y == 5);
        // Try non-origin coordinates
        x0 <= 6; y0 <= 6; x1 <= 3; y1 <= 3;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
            assert(x == 3);
            assert(y == 3);
        @(posedge clk);
            assert(x == 4);
            assert(y == 4);
        @(posedge clk);
            assert(x == 5);
            assert(y == 5);
        @(posedge clk);
            assert(x == 6);
            assert(y == 6);
        // Should stay at endpoint
        @(posedge clk);
            assert(x == 6);
            assert(y == 6);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
