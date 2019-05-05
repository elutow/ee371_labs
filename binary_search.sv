// Overall implementation of FIFO
// - clk is the base clock
// - reset will reset the controller
// - start indicates whether the binary search should finish. In order to
//   start a new binary search, start should be toggled to 0 then 1.
// - ram_out is the output from the RAM module for the given address
// - Signal A is the value to find in the RAM
// - Signal I indicates the address of the target value and/or the value
//   to probe from RAM.
// - found is 1 when I is an address of the target value A, otherwise it is
//   zero.
//
// Modular dependencies:
// - binary_search_ctrl
// - binary_search_dp
module binary_search(
      input logic clk, reset, start,
      input logic [7:0] ram_out, A,
      output logic found,
      output logic [4:0] I
   );

   // Status signals
   logic continue_search, data_out_gt_a, data_out_lt_a;

   // Control signals
   logic init_regs, set_found, set_not_found, update_index, update_l, update_r;

   binary_search_ctrl search_ctrl(
      .clk, .reset, .start,
      .continue_search, .data_out_gt_a, .data_out_lt_a,
      .init_regs, .set_found, .set_not_found, .update_index, .update_l, .update_r);
   binary_search_dp search_dp(
      .clk, .init_regs, .set_found, .set_not_found, .update_index, .update_l, .update_r,
      .ram_out, .A,
      .continue_search, .data_out_gt_a, .data_out_lt_a, .found, .I);
endmodule

`timescale 1 ps / 1 ps
module binary_search_testbench();
   logic clk, reset, start;
   logic [7:0] ram_out, A;
   logic found;
   logic [4:0] I;

   binary_search dut(.clk, .reset, .start, .ram_out, .A, .found, .I);

   // Test with RAM module
   ram32x8 ram(.address(I), .clock(clk), .data(8'b0), .wren(1'b0), .q(ram_out));

   // Clock
   parameter CLOCK_PERIOD=100;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end

   int i;
   initial begin
      A <= 8'd41; start <= 1;
      reset <= 1; @(posedge clk);
      reset <= 0; @(posedge clk);
      #(CLOCK_PERIOD*16);
      @(posedge clk);
      start <= 0; @(posedge clk);
      A <= 8'd0; start <= 1; @(posedge clk);
      #(CLOCK_PERIOD*14);
      @(posedge clk);
      start <= 0; @(posedge clk);
      A <= 8'd63; start <= 1; @(posedge clk);
      #(CLOCK_PERIOD*20);
      @(posedge clk);
      $stop;
   end
endmodule

// Controller for binary search implementation
//
// Modular dependencies: N/A
module binary_search_ctrl(
      input logic clk, reset, start, continue_search, data_out_lt_a, data_out_gt_a,
      output logic init_regs, set_found, set_not_found, update_index, update_l, update_r
   );

   enum {STATE_INIT, STATE_SEARCH, STATE_WAIT1, STATE_WAIT2, STATE_DONE} ps, ns;

   // FSM combinational logic
   always_comb begin
      // Default values of control signals
      init_regs = 0;
      set_found = 0;
      set_not_found = 0;
      update_index = 0;
      update_l = 0;
      update_r = 0;
      case (ps)
         STATE_INIT: begin
            if (start) begin
               init_regs = 1;
               set_not_found = 1;
               ns = STATE_SEARCH;
            end
            else begin
               ns = STATE_INIT;
            end
         end
         STATE_SEARCH: begin
            update_index = 1;
            if (continue_search) begin
               ns = STATE_WAIT1;
            end
            else begin
               set_not_found = 1;
               ns = STATE_DONE;
            end
         end
         STATE_WAIT1: begin
            ns = STATE_WAIT2;
         end
         STATE_WAIT2: begin
            if (data_out_lt_a) begin
               update_l = 1;
               ns = STATE_SEARCH;
            end
            else if (data_out_gt_a) begin
               update_r = 1;
               ns = STATE_SEARCH;
            end
            else begin
               set_found = 1;
               ns = STATE_DONE;
            end
         end
         STATE_DONE: begin
            if (start) ns = STATE_DONE;
            else ns = STATE_INIT;
         end
      endcase
   end

   // FSM registers
   always_ff @(posedge clk) begin
      if (reset) begin
         ps <= STATE_INIT;
      end
      else begin
         ps <= ns;
      end
   end
endmodule

module binary_search_ctrl_testbench();
   logic clk, reset, start, continue_search, data_out_lt_a, data_out_gt_a;
   logic init_regs, set_found, set_not_found, update_index, update_l, update_r;

   enum {STATE_INIT, STATE_SEARCH, STATE_WAIT1, STATE_WAIT2, STATE_DONE} ps, ns;

   binary_search_ctrl dut(
      .clk, .reset, .start, .continue_search, .data_out_lt_a, .data_out_gt_a,
      .init_regs, .set_found, .set_not_found, .update_index, .update_l, .update_r);

   // Clock
   parameter CLOCK_PERIOD=100;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end

   initial begin
      start <= 0; continue_search <= 0; data_out_lt_a <= 0; data_out_gt_a <= 0;
      reset <= 1; @(posedge clk);
      reset <= 0; @(posedge clk);
      // Test start branch
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_INIT);
         assert(dut.ns == STATE_INIT);
      @(posedge clk);
      // To SEARCH state
      start <= 1;
      @(posedge clk);
         assert(init_regs == 1);
         assert(set_found == 0);
         assert(set_not_found == 1);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_INIT);
         assert(dut.ns == STATE_SEARCH);
      // Test DONE state with found = 0
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 1);
         assert(update_index == 1);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_SEARCH);
         assert(dut.ns == STATE_DONE);
      // Test DONE state with start = 1
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_DONE);
         assert(dut.ns == STATE_DONE);
      // Go back to INIT
      start <= 0;
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_DONE);
         assert(dut.ns == STATE_INIT);
      // To SEARCH state
      start <= 1;
      @(posedge clk);
         assert(init_regs == 1);
         assert(set_found == 0);
         assert(set_not_found == 1);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_INIT);
         assert(dut.ns == STATE_SEARCH);
      // Test other branches from SEARCH
      continue_search <= 1;
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 1);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_SEARCH);
         assert(dut.ns == STATE_WAIT1);
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_WAIT1);
         assert(dut.ns == STATE_WAIT2);
      // Test DONE with found = 1
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 1);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_WAIT2);
         assert(dut.ns == STATE_DONE);
      start <= 0;
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_DONE);
         assert(dut.ns == STATE_INIT);
      // Test update_l
      start <= 1;
      @(posedge clk);
         assert(init_regs == 1);
         assert(set_found == 0);
         assert(set_not_found == 1);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_INIT);
         assert(dut.ns == STATE_SEARCH);
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 1);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_SEARCH);
         assert(dut.ns == STATE_WAIT1);
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_WAIT1);
         assert(dut.ns == STATE_WAIT2);
      data_out_lt_a <= 1;
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 1);
         assert(update_r == 0);
         assert(dut.ps == STATE_WAIT2);
         assert(dut.ns == STATE_SEARCH);
      data_out_lt_a <= 0;
      // Test update_r
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 1);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_SEARCH);
         assert(dut.ns == STATE_WAIT1);
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 0);
         assert(dut.ps == STATE_WAIT1);
         assert(dut.ns == STATE_WAIT2);
      data_out_gt_a <= 1;
      @(posedge clk);
         assert(init_regs == 0);
         assert(set_found == 0);
         assert(set_not_found == 0);
         assert(update_index == 0);
         assert(update_l == 0);
         assert(update_r == 1);
         assert(dut.ps == STATE_WAIT2);
         assert(dut.ns == STATE_SEARCH);
      $stop;
   end
endmodule

// Datapath for binary search implementation
//
// Modular dependencies: N/A
module binary_search_dp(
      input logic clk, init_regs, set_found, set_not_found, update_index, update_l, update_r,
      input logic [7:0] ram_out, A,
      output logic continue_search, data_out_lt_a, data_out_gt_a, found,
      output logic [4:0] I
   );

   // Internal registers for binary search
   logic [4:0] L, R;

   // Process control signals
   always_ff @(posedge clk) begin
      if (init_regs) begin
         L = 5'd0;
         R = 5'd31;
      end
      if (set_found) found <= 1;
      if (set_not_found) found <= 0;
      if (update_index) I <= (6'(L)+6'(R)) >> 1;
      if (update_l) L <= ((6'(L)+6'(R)) >> 1) + 1;
      if (update_r) R <= ((6'(L)+6'(R)) >> 1) - 1;
      
      // Check invariants
      assert(!(set_found && set_not_found));
   end

   // Output status signals
   always_comb begin
      // Original algorithm assumes negative values can occur for the case
      // when R == 0, but this will underflow in our implementation. So, it is
      // excluded
      continue_search = L <= R && !(R == 5'd0);
      data_out_lt_a = ram_out < A;
      data_out_gt_a = ram_out > A;
   end
endmodule

module binary_search_dp_testbench();
   logic clk, init_regs, set_found, set_not_found, update_index, update_l, update_r;
   logic [7:0] ram_out, A;
   logic continue_search, data_out_lt_a, data_out_gt_a, found;
   logic [4:0] I;

   binary_search_dp dut(
      .clk, .init_regs, .set_found, .set_not_found, .update_index, .update_l, .update_r,
      .ram_out, .A, .continue_search, .data_out_lt_a, .data_out_gt_a, .found, .I);

   // Clock
   parameter CLOCK_PERIOD=100;
   initial begin
      clk <= 0;
      forever #(CLOCK_PERIOD/2) clk <= ~clk;
   end

   initial begin
      set_found <= 0; set_not_found <= 0; update_index <= 0;
      update_l <= 0; update_r <= 0;
      // Test control signals
      init_regs <= 1; @(posedge clk);
      init_regs <= 0; @(posedge clk);
         assert(dut.L == 0);
         assert(dut.R == 31);
      set_found <= 1; @(posedge clk);
      set_found <= 0; @(posedge clk);
         assert(found == 1);
      set_not_found <= 1; @(posedge clk);
      set_not_found <= 0; @(posedge clk);
         assert(found == 0);
      update_index <= 1; @(posedge clk);
      update_index <= 0; @(posedge clk);
         assert(I == 15);
      update_l <= 1; @(posedge clk);
      update_l <= 0; @(posedge clk);
         assert(dut.L == 16);
         assert(dut.R == 31);
      update_r <= 1; @(posedge clk);
      update_r <= 0; @(posedge clk);
         assert(dut.L == 16);
         assert(dut.R == 22);
      // Test overflow calculations for L, R, and I
      init_regs <= 1; @(posedge clk);
      init_regs <= 0; @(posedge clk);
      update_l <= 1; @(posedge clk);
      update_l <= 0; @(posedge clk);
         assert(dut.L == 16);
         assert(dut.R == 31);
      update_l <= 1; @(posedge clk);
      update_l <= 0; @(posedge clk);
         assert(dut.L == 24);
         assert(dut.R == 31);
      update_l <= 1; @(posedge clk);
      update_l <= 0; @(posedge clk);
         assert(dut.L == 28);
         assert(dut.R == 31);
      update_l <= 1; @(posedge clk);
      update_l <= 0; @(posedge clk);
         assert(dut.L == 30);
         assert(dut.R == 31);
      update_l <= 1; @(posedge clk);
      update_l <= 0; @(posedge clk);
         assert(dut.L == 31);
         assert(dut.R == 31);
      update_index <= 1; @(posedge clk);
      update_index <= 0; @(posedge clk);
         assert(I == 31);
      // Test underflow for R
      init_regs <= 1; @(posedge clk);
      init_regs <= 0; @(posedge clk);
      update_r <= 1; @(posedge clk);
      update_r <= 0; @(posedge clk);
         assert(dut.L == 0);
         assert(dut.R == 14);
      update_r <= 1; @(posedge clk);
      update_r <= 0; @(posedge clk);
         assert(dut.L == 0);
         assert(dut.R == 6);
      update_r <= 1; @(posedge clk);
      update_r <= 0; @(posedge clk);
         assert(dut.L == 0);
         assert(dut.R == 2);
         assert(continue_search == 1);
      update_r <= 1; @(posedge clk);
      update_r <= 0; @(posedge clk);
         assert(dut.L == 0);
         assert(dut.R == 0);
         assert(continue_search == 0);
      // Test status signals
      A <= 8'd15;
      ram_out <= 8'd7;
      @(posedge clk);
         assert(data_out_gt_a == 0);
         assert(data_out_lt_a == 1);
      ram_out <= 8'd20;
      @(posedge clk);
         assert(data_out_gt_a == 1);
         assert(data_out_lt_a == 0);
      $stop;
   end
endmodule

// vim: set expandtab shiftwidth=3 softtabstop=3:
