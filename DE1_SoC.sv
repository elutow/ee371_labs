// This module is a wrapper around ram32x4 for testing on the DE1 board
// - SW[8:4] are for the address
// - SW[3:0] provide data input
// - KEY[0] acts as the clock (pressed for 0, unpressed for 1)
// - KEY[3] is a reset key activated when pressed
// - HEX5-4 show the current address in hex
// - HEX2 shows the RAM's input data in hex
// - HEX0 shows the RAM's output data in hex
//
// Modular dependencies:
// - metastability_filter
// - ram32x4 (from IP Catalog)
// - seg7

module DE1_SoC(CLOCK_50, SW, KEY, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);
    input logic CLOCK_50;
    input logic [9:0] SW;
    input logic [3:0] KEY;
    output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    logic reset, ram_clock, write_enable;
    logic [4:0] address;
    logic [3:0] data_in, data_out;

    // Reset alias for metastability_filter
    assign reset = ~KEY[3];

    // Filter metastability
    metastability_filter #(.WIDTH(5)) address_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(SW[8:4]),
        .filtered_out(address));
    metastability_filter ram_clock_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(KEY[0]),
        .filtered_out(ram_clock));
    metastability_filter #(.WIDTH(4)) data_in_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(SW[3:0]),
        .filtered_out(data_in));
    metastability_filter write_enable_filter(
        .clk(CLOCK_50),
        .reset,
        .direct_in(SW[9]),
        .filtered_out(write_enable));

    // HEX display outputs in descending order
    seg7 addr1_seg7(.hex({3'b0, address[4]}), .out(HEX5));
    seg7 addr0_seg7(.hex(address[3:0]), .out(HEX4));
    assign HEX3 = 7'b1111111;
    seg7 data_in_seg7(.hex(data_in), .out(HEX2));
    assign HEX1 = 7'b1111111;
    seg7 data_out_seg7(.hex(data_out), .out(HEX0));

    // RAM module implementation
    ram32x4 ram_inst(
        .address,
        .clock(ram_clock),
        .data(data_in),
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
    logic reset, write_enable, ram_clock;
    logic [4:0] addr;
    logic [3:0] data_in;
    logic [7:0] data_out_seg7;

    assign KEY[0] = ram_clock;
    assign KEY[3] = ~reset;
    assign SW[9] = write_enable;
    assign SW[8:4] = addr;
    assign SW[3:0] = data_in;
    assign data_out_seg7 = HEX0;

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    DE1_SoC dut(.CLOCK_50, .SW, .KEY, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);

    initial begin
        addr <= 0; write_enable <= 0; data_in <= 0; ram_clock <= 1;
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        // Write values to two addresses
        addr <= 5'h15; write_enable <= 1; data_in <= 4'b1010; @(posedge CLOCK_50);
        // Trigger RAM clock
        ram_clock <= 0; @(posedge CLOCK_50);
        ram_clock <= 1; @(posedge CLOCK_50);
        addr <= 5'h0A; write_enable <= 1; data_in <= 4'b0101; @(posedge CLOCK_50);
        // Trigger RAM clock
        ram_clock <= 0; @(posedge CLOCK_50);
        ram_clock <= 1; @(posedge CLOCK_50);
        // Verify values written to two addresses
        // It takes two RAM clock cycles for the output to update
        addr <= 5'h15; write_enable <= 0; data_in <= 4'bX; @(posedge CLOCK_50);
        // Trigger RAM clock
        ram_clock <= 0; @(posedge CLOCK_50);
        ram_clock <= 1; @(posedge CLOCK_50);
        ram_clock <= 0; @(posedge CLOCK_50);
        ram_clock <= 1; @(posedge CLOCK_50);
        @(posedge CLOCK_50); // Wait for metastability_filter
        assert(data_out_seg7 == 7'b0001000); // 4'b1010
        addr <= 5'h0A; @(posedge CLOCK_50);
        // Trigger RAM clock
        ram_clock <= 0; @(posedge CLOCK_50);
        ram_clock <= 1; @(posedge CLOCK_50);
        ram_clock <= 0; @(posedge CLOCK_50);
        ram_clock <= 1; @(posedge CLOCK_50);
        @(posedge CLOCK_50); // Wait for metastability_filter
        assert(data_out_seg7 == 7'b0010010); // 4'b0101;
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
