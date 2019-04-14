// This module is a wrapper around the ram32x4 for testing on the DE1 board
// It automatically scrolls through the read addresses at 0.75 Hz
// - SW[8:4] are for specifying the write address
// - SW[3:0] provide data input
// - KEY[3] is a write enable that is activated when pressed
// - KEY[0] is a reset that is activated when pressed
// - HEX5-4 show the write address in hex
// - HEX3-2 show the read address in hex
// - HEX1 shows the RAM's input data in hex
// - HEX0 shows the RAM's output data in hex
//
// Modular dependencies:
// - clock_divider
// - metastability_filter
// - ram32x4 (from IP Catalog)
// - seg7

module DE1_SoC(CLOCK_50, SW, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    input logic CLOCK_50;
    input logic [9:0] SW;
    input logic [3:0] KEY;
    output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic reset, write_enable;
    logic [4:0] r_address, w_address;
    logic [3:0] data_in, data_out;
    logic [31:0] divided_clocks;

    // Filter metastability
    metastability_filter write_enable_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(~KEY[3]),
        .filtered_out(write_enable));
    metastability_filter reset_filter(
        .clk(CLOCK_50),
        // No reset needed; module will auto-initialize after two clock cycles
        // from power-on.
        .reset(1'b0),
        .direct_in(~KEY[0]),
        .filtered_out(reset));
    metastability_filter #(.WIDTH(5)) w_address_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(SW[8:4]),
        .filtered_out(w_address));
    metastability_filter #(.WIDTH(4)) data_in_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(SW[3:0]),
        .filtered_out(data_in));

    // HEX display outputs in descending order
    seg7 w_addr1_seg7(.hex({3'b0, w_address[4]}), .out(HEX5));
    seg7 w_addr0_seg7(.hex(w_address[3:0]), .out(HEX4));
    seg7 r_addr1_seg7(.hex({3'b0, r_address[4]}), .out(HEX3));
    seg7 r_addr0_seg7(.hex(r_address[3:0]), .out(HEX2));
    seg7 data_in_seg7(.hex(data_in), .out(HEX1));
    seg7 data_out_seg7(.hex(data_out), .out(HEX0));

    // Counter for r_address
    clock_divider r_address_counter(
        .input_clock(CLOCK_50),
        .reset,
        .divided_clocks);
    // Address changes at 0.75 Hz
    assign r_address = divided_clocks[29:25];

    // RAM module implementation
    ram32x4 ram_inst(
        .clock(CLOCK_50),
        .data(data_in),
        .rdaddress(r_address),
        .wraddress(w_address),
        .wren(write_enable),
        .q(data_out));
endmodule

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
    logic CLOCK_50;
    logic [9:0] SW;
    logic [3:0] KEY;
    logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    // Aliases for I/O
    logic reset, write_enable;
    logic [4:0] w_addr;
    logic [3:0] data_in;
    logic [7:0] data_out_seg7;

    assign KEY[0] = ~reset;
    assign KEY[3] = ~write_enable;
    assign SW[8:4] = w_addr;
    assign SW[3:0] = data_in;
    assign data_out_seg7 = HEX0;

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    DE1_SoC dut(.CLOCK_50, .SW, .KEY, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    // Read address change is not tested here since it would take many clock
    // cycles to occur.
    initial begin
        w_addr <= 0; write_enable <= 0; data_in <= 0; reset <= 0;
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        // Write values to address 0000
        w_addr <= 0; write_enable <= 1; data_in <= 4'b1111; @(posedge CLOCK_50);
        // Wait for delay of input + delay of RAM
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        assert(data_out_seg7 == 7'b0001110); // 4'b0101;
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
