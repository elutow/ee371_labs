// Converts an input signal to a one-cycle pulse (of clk)
// Usually used for creating a pulse from a divided clock
// - clk is the reference clock for the pulse
// - divided_clock is the clock to create a pulse on a posedge
// - clock_event outputs the pulses
//
// Modular dependencies: N/A

module clock_pulser(clk, reset, divided_clock, clock_event);
    input logic clk, reset, divided_clock;
    output logic clock_event;
    logic present_state;

    // Clock posedge event
    assign clock_event = divided_clock & ~present_state;
    always_ff @(posedge clk) begin
        if (reset) begin
            present_state <= 0;
        end
        else begin
            present_state <= divided_clock;
        end
    end
endmodule

module clock_pulser_testbench();
    logic clk, reset, clock_event;
    logic [31:0] divided_clocks;

    clock_divider clockDivider(.input_clock(clk), .reset, .divided_clocks);
    clock_pulser dut(.clk, .reset, .divided_clock(divided_clocks[2]), .clock_event);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        #(CLOCK_PERIOD*10);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
