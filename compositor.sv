// Module for composing multiple frames together and driving a VGA driver

`include "common.sv"

module compositor
    #(parameter WIDTH=640, HEIGHT=480)
    (
        input logic clk, reset,
        // TODO: Change to correct type for camera_color to accomodate camera
        // driver
        input logic [COLOR_WIDTH-1:0] camera_color,
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
        output logic [$clog2(WIDTH)-1:0] request_x,
        output logic [$clog2(HEIGHT)-1:0] request_y,
        output logic [$clog2(WIDTH)-1:0] render_x,
        output logic [$clog2(HEIGHT)-1:0] render_y,
        output logic [COLOR_WIDTH-1:0] render_color
    );

    logic [$clog2(WIDTH)-1:0] x, next_x;
    logic [$clog2(HEIGHT)-1:0] y, next_y;

    enum {STATE_INCR, STATE_HOLD} ps, ns;

    // Aliases for signals
    assign request_x = next_x;
    assign request_y = next_y;
    assign render_x = x;
    assign render_y = y;

    // Cycle through all coordinates
    always_ff @(posedge clk) begin
        if (reset) begin
            ps <= STATE_INCR;
            x <= 0;
            y <= 0;
        end
        else begin
            ps <= ns;
            x <= next_x;
            y <= next_y;
        end
    end
    always_comb begin
        case (ps)
            STATE_INCR: begin
                ns = STATE_HOLD;
                next_x = x + $clog2(WIDTH)'(1);
                next_y = y;
                if (next_x == WIDTH) begin
                    next_x = 0;
                    next_y = y + $clog2(HEIGHT)'(1);
                end
                if (next_y == HEIGHT) next_y = 0;
            end
            STATE_HOLD: begin
                // This state is to allow for the frame reading to occur
                ns = STATE_INCR;
                next_x = x;
                next_y = y;
            end
        endcase
    end

    // Determine pixel color for location
    always_comb begin
        if (cursor_visible && cursor_color != COLOR_NONE) render_color = cursor_color;
        else if (canvas4_visible && canvas4_color != COLOR_NONE) render_color = canvas4_color;
        else if (canvas3_visible && canvas3_color != COLOR_NONE) render_color = canvas3_color;
        else if (canvas2_visible && canvas2_color != COLOR_NONE) render_color = canvas2_color;
        else if (canvas1_visible && canvas1_color != COLOR_NONE) render_color = canvas1_color;
        else render_color = camera_color;
    end
endmodule

module compositor_testbench();
    parameter WIDTH=8, HEIGHT=8;
    logic clk, reset;
    logic [COLOR_WIDTH-1:0] camera_color;
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
    logic [$clog2(WIDTH)-1:0] request_x;
    logic [$clog2(HEIGHT)-1:0] request_y;
    logic [$clog2(WIDTH)-1:0] render_x;
    logic [$clog2(HEIGHT)-1:0] render_y;
    logic [COLOR_WIDTH-1:0] render_color;

    compositor #(.WIDTH(WIDTH), .HEIGHT(HEIGHT)) dut(
        .clk, .reset, .camera_color, .cursor_color, .cursor_visible,
        .canvas1_color, .canvas1_visible, .canvas2_color, .canvas2_visible,
        .canvas3_color, .canvas3_visible, .canvas4_color, .canvas4_visible,
        .request_x, .request_y, .render_x, .render_y, .render_color);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    // Simulate frame
    logic [COLOR_WIDTH-1:0] camera_frame [WIDTH-1:0][HEIGHT-1:0] = '{default:COLOR_NONE};
    always_ff @(posedge clk) begin
        camera_color <= camera_frame[request_x][request_y];
    end

    initial begin
        camera_frame[1][0] = COLOR_BLACK;
        camera_frame[2][0] = COLOR_WHITE;
        camera_frame[3][0] = COLOR_RED;
        #1;
        cursor_color <= COLOR_NONE;
        cursor_visible <= 1;
        canvas4_color <= COLOR_NONE;
        canvas4_visible <= 1;
        canvas3_color <= COLOR_NONE;
        canvas3_visible <= 1;
        canvas2_color <= COLOR_NONE;
        canvas2_visible <= 1;
        canvas1_color <= COLOR_NONE;
        canvas1_visible <= 1;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
            assert(render_x == 0);
            assert(render_y == 0);
            assert(render_color === 'x);
        @(posedge clk);
        @(posedge clk);
            assert(render_x == 1);
            assert(render_y == 0);
            assert(render_color == COLOR_BLACK);
        @(posedge clk);
        @(posedge clk);
            assert(render_x == 2);
            assert(render_y == 0);
            assert(render_color == COLOR_WHITE);
        @(posedge clk);
        @(posedge clk);
            assert(render_x == 3);
            assert(render_y == 0);
            assert(render_color == COLOR_RED);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
