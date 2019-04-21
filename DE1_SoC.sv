// Top-level module for animating a translating line
// - SW[9] will set the screen to black when flipped on.
//   Once it is flipped off, the drawing will start again.
//   The switch should be left on until the entire screen is black.
//
// Modular dependencies:
// - VGA_framebuffer
// - clock_divider
// - clock_pulser
// - line_animator
// - metastability_filter

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

    // From line_animator
    logic [10:0] x_anim, y_anim;
    logic pixel_color;
    // For blacking out the VGA
    logic [10:0] x_clear = 0, y_clear = 0;
    // To pass into VGA
    logic [10:0] x_vga, y_vga;
    // From clock_divider
    logic [31:0] divided_clocks;
    // For triggering line animation step
    logic update_event;
    // Alias for reset
    logic reset;

    // Filter reset metastability
    metastability_filter reset_filter(
        .clk(CLOCK_50), .reset(1'b0), .direct_in(SW[9]), .filtered_out(reset));

    // VGA framebuffer
    VGA_framebuffer fb(
        .clk50(CLOCK_50), .reset(1'b0), .x(x_vga), .y(y_vga),
        .pixel_color, .pixel_write(1'b1),
        .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
        .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));

    // For update event
    clock_divider clocks(.input_clock(CLOCK_50), .reset, .divided_clocks);
    clock_pulser event_pulser(
        .clk(CLOCK_50), .reset,
        .divided_clock(divided_clocks[19]), // 48 Hz
        .clock_event(update_event));

    // Line animator
    // NOTE: drawing is not synchronized with VGA clock; this may cause
    // tearing since the VGA only has a single frame buffer
    line_animator animator(
        .clk(CLOCK_50), .reset, .update_event,
        .x(x_anim), .y(y_anim), .pixel_color);

    // Combinational logic for screen blacking FSM
    always_comb begin
        if (reset) begin
            // NOTE: During reset, pixel_color will always be 0 from
            // line_animator
            // NOTE: x_vga and y_vga must be bounded by 640 x 480 resolution;
            // otherwise, the write address will go out of range in the
            // framebuffer (resulting in undefined behavior)
            x_vga = x_clear + 11'b1;
            y_vga = y_clear;
            if (x_vga == 640) begin
                x_vga = 0;
                y_vga = y_clear + 11'b1;
                if (y_vga == 480) begin
                    y_vga = 0;
                end
            end
        end
        else begin
            x_vga = x_anim;
            y_vga = y_anim;
        end
    end

    // DFFs for screen blacking FSM
    always_ff @(posedge CLOCK_50) begin
        if (reset) begin
            x_clear <= x_vga;
            y_clear <= y_vga;
        end
    end
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
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        @(posedge CLOCK_50); // Wait for metastability_filter
        // Check if line draws
        for (i=0; i<40; i++) begin
            @(posedge CLOCK_50);
        end
        // Check screen blacking
        reset <= 1; @(posedge CLOCK_50);
        @(posedge CLOCK_50); // Wait for metastability_filter
        for (i=0; i<642; i++) begin
            @(posedge CLOCK_50);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
