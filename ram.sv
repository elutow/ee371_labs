// This module is a wrapper around ram32x4
// - clk is the clock signal
// - write is the write enable signal
// - addr is the address port
// - data_in and data_out are the data I/O ports
//
// Modular dependencies: ram32x4 (from IP Catalog)

module ram(clk, addr, data_in, write, data_out);
    input logic clk, write;
    input logic [4:0] addr;
    input logic [3:0] data_in;
    output logic [3:0] data_out;

    ram32x4 ram_inst(.address(addr), .clock(clk), .data(data_in), .wren(write), .q(data_out));
endmodule

`timescale 1 ps / 1 ps
module ram_testbench();
    logic clk, write;
    logic [4:0] addr;
    logic [3:0] data_in;
    logic [3:0] data_out;

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    ram dut(.clk, .addr, .data_in, .write, .data_out);

    initial begin
        // Write values to two addresses
        addr <= 5'h2A; write <= 1; data_in <= 4'b1010; @(posedge clk);
        addr <= 5'h42; write <= 1; data_in <= 4'b0101; @(posedge clk);
        // Verify values written to two addresses
        // It takes two clock cycles for the output to update
        addr <= 5'h2A; write <= 0; data_in <= 4'bX; @(posedge clk);
        @(posedge clk);
        assert(data_out == 4'b1010);
        addr <= 5'h42; @(posedge clk);
        @(posedge clk);
        assert(data_out == 4'b0101);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
