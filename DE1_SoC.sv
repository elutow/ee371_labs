// Top-level module to test line_drawer via VGA output
// - SW[9] is reset for line_drawer
// - SW[4:0] is x-coordinate in tens of pixels
// - SW[8:5] is y-coordinate in tens of pixels
//
// Modular dependencies:
// - line_drawer
// - VGA_framebuffer

module DE1_SoC(HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50,
    VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);

    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    output logic [9:0] LEDR;
    input logic [3:0] KEY;
    input logic [9:0] SW;

    input CLOCK_50;
    output [7:0] VGA_R;
    output [7:0] VGA_G;
    output [7:0] VGA_B;
    output VGA_BLANK_N;
    output VGA_CLK;
    output VGA_HS;
    output VGA_SYNC_N;
    output VGA_VS;

    assign HEX0 = '1;
    assign HEX1 = '1;
    assign HEX2 = '1;
    assign HEX3 = '1;
    assign HEX4 = '1;
    assign HEX5 = '1;
    assign LEDR = SW;

    logic [10:0] x0, y0, x1, y1, x, y;

    // reset for circuit
    logic reset;
    metastability_filter reset_filter(
        .clk(CLOCK_50), .reset(1'b0), .direct_in(SW[9]), .filtered_out(reset));

    VGA_framebuffer fb(.clk50(CLOCK_50), .reset, .x, .y,
                .pixel_color(1'b1), .pixel_write(1'b1),
                .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
                .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));

    line_drawer lines (.clk(CLOCK_50), .reset,
                .x0, .y0, .x1, .y1, .x, .y);

    // Assign line target coordinates
    // x coordinate
    logic [4:0] x_in;
    metastability_filter #(.WIDTH(5)) x_in_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[4:0]), .filtered_out(x_in));
    assign x0 = x_in * 5'd10;
    // y coordinate
    logic [3:0] y_in;
    metastability_filter #(.WIDTH(4)) y_in_filter(
        .clk(CLOCK_50), .reset, .direct_in(SW[8:5]), .filtered_out(y_in));
    assign y0 = y_in * 4'd10;
    // Hardcode endpoints for simplicity
    assign x1 = 240;
    assign y1 = 240;
endmodule

module DE1_SoC_testbench();
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [9:0] LEDR;
    logic [3:0] KEY;
    logic [9:0] SW;

    logic CLOCK_50, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS;
    logic [7:0] VGA_R, VGA_G, VGA_B;

    logic reset;
    assign SW[9] = reset;
    logic [4:0] x_in;
    assign SW[4:0] = x_in;
    logic [3:0] y_in;
    assign SW[8:5] = y_in;

    DE1_SoC dut(.HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW, .CLOCK_50,
    .VGA_R, .VGA_G, .VGA_B, .VGA_BLANK_N, .VGA_CLK, .VGA_HS, .VGA_SYNC_N, .VGA_VS);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    int i;
    initial begin
        x_in <= 0; y_in <= 0;
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        @(posedge CLOCK_50); // Wait for metastability_filter
        // Check if line draws
        for (i=0; i<40; i++) begin
            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
