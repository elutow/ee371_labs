// Animates a line via line_drawer
// The animation follows the given sequence:
// 1. Draw diagonal line starting at (0, 0)
// 2. Translate it by vector (1, 1) for 128 update events
//    a. For steps 1-32, the line will be shallow with a positive slope
//    (relative to VGA coordinates)
//    b. For steps 33-64, the line will be steep with a positive slope
//    c. For steps 65-96, the line will be steep with a negative slope
//    d. For steps 97-128, the line will be shallow with a negative slope
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
    logic [7:0] step, next_step;
    // States for drawing FSM
    enum { STATE_INIT, STATE_DRAW, STATE_ERASE, STATE_PREDRAW } ps, ns;

    line_drawer drawer(
        .clk, .reset(drawer_reset),
        .x0, .y0, .x1, .y1, .x, .y,
        .finished(draw_done));

    // Define line coordinates
    always_comb begin
        case (step[7:6]) // Choose two MSB for direction
            2'b00: begin // !is_steep, positive slope (relative to screen)
                x0 = step;
                y0 = step;
                x1 = step + 11'd30;
                y1 = step + 11'd10;
            end
            2'b01: begin // is_steep, positive slope
                x0 = step;
                y0 = step;
                x1 = step + 11'd10;
                y1 = step + 11'd30;
            end
            2'b10: begin // is_steep, negative slope
                x0 = step;
                y0 = step;
                x1 = step - 11'd10;
                y1 = step + 11'd30;
            end
            2'b11: begin // !is_steep, negative slope
                x0 = step;
                y0 = step;
                x1 = step - 11'd30;
                y1 = step + 11'd10;
            end
        endcase
    end

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
                    next_step = step + 8'b1;
                    ns = STATE_PREDRAW;
                end
                else begin
                    ns = STATE_ERASE;
                end
            end
            STATE_PREDRAW: begin
                // This state is needed to let step update
                // so that the correct starting coordinate is passed into
                // line_drawer
                drawer_reset = 1;
                pixel_color = 0;
                ns = STATE_DRAW;
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
        for (i=0; i<35; i++) begin
            @(posedge clk);
        end
        // Trigger update_event for erasing
        update_event <= 1; @(posedge clk);
        update_event <= 0; @(posedge clk);
        for (i=0; i<35; i++) begin
            @(posedge clk);
        end
        // Ensure transition into next line is correct
        update_event <= 1; @(posedge clk);
        update_event <= 0; @(posedge clk);
        for (i=0; i<5; i++) begin
            @(posedge clk);
        end
        // For the remaining behaviors, it would be more convoluted to test
        // them via testbench versus testing by inspecting the VGA output.
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
