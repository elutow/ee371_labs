module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50,
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

    VGA_framebuffer fb(.clk50(CLOCK_50), .reset(1'b0), .x, .y,
                .pixel_color(1'b1), .pixel_write(1'b1),
                .VGA_R, .VGA_G, .VGA_B, .VGA_CLK, .VGA_HS, .VGA_VS,
                .VGA_BLANK_n(VGA_BLANK_N), .VGA_SYNC_n(VGA_SYNC_N));

    line_drawer lines (.clk(CLOCK_50), .reset(1'b0),
                .x0, .y0, .x1, .y1, .x, .y);

    assign x0 = 0;
    assign y0 = 0;
    assign x1 = 240;
    assign y1 = 240;
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
