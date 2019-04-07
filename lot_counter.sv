// Counter for number of filled spots in the parking lot
// - inc and dec increment and decrement the counter, respectively.
//   They change the counter once every clock cycle they are 1.
//   If both inc and dec are enabled, the counter will decrement.
// - bcd is a big-endian binary-coded decimal of the count
//   Each digit is encoded with 4 bits.
// NOTE: The counter can under- and over-flow.
//
// Modular dependencies: N/A

module lot_counter(clk, reset, inc, dec, bcd);
    input logic clk, reset, inc, dec;
    output logic [7:0] bcd;
    logic [4:0] last_count, count;

    // Convert binary to BCD format
    assign bcd[7:4] = count / 10;
    assign bcd[3:0] = count % 10;

    // Compute new counter value
    always_comb begin
        count = last_count;
        if (inc) count = last_count + 1;
        if (dec) count = last_count - 1;
    end

    // DFFs for counter state
    always_ff @(posedge clk) begin
        if (reset) begin
            last_count <= 0;
        end
        else begin
            last_count <= count;
        end
    end
endmodule

module lot_counter_testbench();
    logic clk, reset, inc, dec;
    logic [7:0] bcd;

    lot_counter dut(.clk, .reset, .inc, .dec, .bcd);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    int i;
    initial begin
        inc <= 0; dec <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        // Count up to double decimal digits and verify BCD
        for (i=1; i<=11; i++) begin
            inc <= 1; @(posedge clk);
            inc <= 0; @(posedge clk);
            assert(bcd[3:0] == i % 10);
            assert(bcd[7:4] == i / 10);
        end
        // Decrement to single decimal digit and verify BCD
        dec <= 1; @(posedge clk);
                  @(posedge clk);
        dec <= 0; @(posedge clk);
        assert(bcd[3:0] == 9);
        assert(bcd[7:4] == 0);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
