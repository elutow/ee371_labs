// Top-level module for binary search implementation
// - SW[9] is the start signal
// - SW[7:0] specifies the value to search for in binary
// - KEY[0] resets the system, synchronous to the clock
// - LEDR[9] indicates if the desired number was found
// Modular dependencies:
// - binary_search
// - metastability_filter
// - ram32x8
// - seg7
module DE1_SoC
   (
      input logic CLOCK_50,
      input logic [9:0] SW,
      input logic [3:0] KEY,
      output logic [9:0] LEDR,
      output logic [6:0] HEX0, HEX1
   );

   // Filtered inputs
   logic reset, start;

   // Binary search I/O
   logic [4:0] I;
   logic [7:0] A, ram_out;

   // Filter metastability
   metastability_filter reset_filter(.clk(CLOCK_50), .reset(1'b0), .direct_in(~KEY[0]), .filtered_out(reset));
   metastability_filter start_filter(.clk(CLOCK_50), .reset, .direct_in(SW[9]), .filtered_out(start));
   metastability_filter #(.WIDTH(8)) a_filter(.clk(CLOCK_50), .reset, .direct_in(SW[7:0]), .filtered_out(A));

   // Core modules
   ram32x8 ram(.address(I), .clock(CLOCK_50), .data(8'b0), .wren(1'b0), .q(ram_out));
   binary_search search_impl(.clk(CLOCK_50), .reset, .start, .ram_out, .A, .found(LEDR[9]), .I);

   // Output I to HEX1 and HEX0
   seg7 i_hex1(.hex({3'b0, I[4]}), .out(HEX1));
   seg7 i_hex0(.hex(I[3:0]), .out(HEX0));
endmodule

`timescale 1 ps / 1 ps
module DE1_SoC_testbench();
   logic CLOCK_50;
   logic [9:0] SW;
   logic [9:0] LEDR;
   logic [3:0] KEY;
   logic [6:0] HEX0, HEX1;

   DE1_SoC dut(.CLOCK_50, .SW, .LEDR, .KEY, .HEX0, .HEX1);

   // Clock
   parameter CLOCK_PERIOD=100;
   initial begin
      CLOCK_50 <= 0;
      forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
   end

   logic reset;
   assign KEY[0] = ~reset;
   logic start;
   assign SW[9] = start;
   logic [7:0] A;
   assign SW[7:0] = A;

   initial begin
      A <= 8'd49; start <= 1;
      reset <= 1; @(posedge CLOCK_50);
      reset <= 0; @(posedge CLOCK_50);
      #(CLOCK_PERIOD*20);
      $stop;
   end
endmodule

// vim: set expandtab shiftwidth=3 softtabstop=3:
