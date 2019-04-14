// 32 x 4 single-port synchronous RAM implementation
// - clk is the clock input, triggered at the positive edge
// - reset sets all RAM values to zero
// - address is the address for read/write_enable
// - data_in is the data to write_enable
// - write_enable indicates whether data should be written (1) or not (0)
// - data_out is the data at the address. While writing, it will take two
//   clock cycles to output here.
//
// Modular dependencies: N/A

module ram32x4(clk, reset, address, data_in, write_enable, data_out);
    input logic clk, reset, write_enable;
    input logic [4:0] address;
    input logic [3:0] data_in;
    output logic [3:0] data_out;
    logic [3:0] memory_array [0:31];

    // Array I/O logic
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset all values to zero
            memory_array <= '{default:'0};
        end
        else if (write_enable) begin
            memory_array[address] <= data_in;
        end
        data_out <= memory_array[address];
    end
endmodule

module ram32x4_testbench();
    logic clk, reset, write_enable;
    logic [4:0] address;
    logic [3:0] data_in;
    logic [3:0] data_out;

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    ram32x4 dut(.clk, .reset, .address, .data_in, .write_enable, .data_out);

    initial begin
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        // Write values to two addresses
        address <= 5'h2A; write_enable <= 1; data_in <= 4'b1010; @(posedge clk);
        address <= 5'h42; write_enable <= 1; data_in <= 4'b0101; @(posedge clk);
        // Verify values written to two addresses
        // It takes two clock cycles for the output to update
        address <= 5'h2A; write_enable <= 0; data_in <= 4'bX; @(posedge clk);
        @(posedge clk);
        assert(data_out == 4'b1010);
        address <= 5'h42; @(posedge clk);
        @(posedge clk);
        assert(data_out == 4'b0101);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
