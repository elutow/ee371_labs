// Simple clock divider
// 50 MHz: divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ... [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
//
// Modular dependencies: N/A

module clock_divider(input_clock, reset, divided_clocks);
    input logic reset, input_clock;
    output logic [31:0] divided_clocks;

    always_ff @(posedge input_clock) begin
        if (reset) begin
            divided_clocks <= 0;
        end
        else begin
            divided_clocks <= divided_clocks + 1;
        end
    end
endmodule

module clock_divider_testbench();
    logic input_clock, reset;
    logic [31:0] divided_clocks;

    clock_divider dut(.input_clock, .reset, .divided_clocks);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        input_clock <= 0;
        forever #(CLOCK_PERIOD/2) input_clock <= ~input_clock;
    end

    int i;
    initial begin
        reset <= 1; @(posedge input_clock);
        reset <= 0; @(posedge input_clock);
        // Observe counting
        for (i=0; i<20; i++) begin
            @(posedge input_clock);
        end
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
