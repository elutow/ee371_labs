// Animates a line via line_drawer
// The animation follows the given sequence:
// 1. Draw diagonal line starting at (0, 0)
// 2. Translate it by vector (1, 1) for 128 update events
// 3. On the last event, go back to (0, 0) and repeat
// Signals:
// - clk is the clock the update_event is synchronized to
// - reset resets the drawer to the first step, regardless of its current
//   state
// - update_event triggers the next animation step and redraw, synchronized to
//   clk
// - x and y are the coordinates to draw a pixel for the line
// - pixel_color indicates if a black (0) or white (1) pixel should be drawn
//   at the coordinates (x, y)
//
// Modular dependencies:
// - line_drawer

module line_animator(clk, reset, update_event, x, y, pixel_color);
    input logic clk, reset, update_event;
    output logic [10:0] x, y;
    output logic pixel_color;

    // Resets drawer
    logic drawer_reset;
    // Indicates if line is drawn
    logic draw_done;
    // Target line coordinates for line_drawer
    logic [10:0] x0, y0, x1, y1;
    // Animation step
    logic [5:0] step, next_step;
    // States for drawing FSM
    enum { STATE_INIT, STATE_DRAW, STATE_ERASE } ps, ns;

    line_drawer drawer(
        .clk, .reset(drawer_reset), .x0, .y0, .x1, .y1, .x, .y);

    // Drawing is done when last pixel is reached.
    assign draw_done = (x == x1) && (y == y1);

    // Define line coordinates
    assign x0 = step;
    assign y0 = step;
    assign x1 = step + 10;
    assign y1 = step + 15;

    // Combinational logic for drawing FSM
    always_comb begin
        drawer_reset = 0;
        next_step = step;
        case (ps)
            STATE_INIT: begin
                pixel_color = 0;
                drawer_reset = 1;
                ns = STATE_DRAW;
            end
            STATE_DRAW: begin
                pixel_color = 1;
                if (draw_done && update_event) begin
                    drawer_reset = 1;
                    ns = STATE_ERASE;
                end
                else begin
                    ns = STATE_DRAW;
                end
            end
            STATE_ERASE: begin
                pixel_color = 0;
                if (draw_done) begin
                    drawer_reset = 1;
                    next_step = step + 6'b1;
                    ns = STATE_DRAW;
                end
                else begin
                    ns = STATE_ERASE;
                end
            end
        endcase
    end

    // DFFs for drawing FSM
    always_ff @(posedge clk) begin
        if (reset) begin
            step <= 0;
            ps <= STATE_INIT;
        end
        else begin
            step <= next_step;
            ps <= ns;
        end
    end
endmodule

module line_animator_testbench();
    logic clk, reset, update_event;
    logic [10:0] x, y;
    logic pixel_color;

    line_animator dut(.clk, .reset, .update_event, .x, .y, .pixel_color);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    int i;
    initial begin
        update_event <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        for (i=0; i<20; i++) begin
            @(posedge clk);
        end
        // Trigger update_event for erasing
        update_event <= 1; @(posedge clk);
        update_event <= 0; @(posedge clk);
        for (i=0; i<40; i++) begin
            @(posedge clk);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
