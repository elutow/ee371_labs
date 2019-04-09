// Top-level module for parking lot counter
// - KEY[0] and KEY[1] are used to mock sensors a and b. They are active when
//   pressed.
// - HEX{0-5} are used for displaying parking lot counter and state
// - GPIO_0[0] is 1 when sensor a is triggered
// - GPIO_0[9] is 1 when sensor b is triggered
//
// Modular dependencies:
// - car_detector
// - counter_display
// - lot_counter
// - metastability_filter

module DE1_SoC(CLOCK_50, KEY, SW, GPIO_0, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input logic CLOCK_50;
    input logic [3:0] KEY;
    input logic [9:0] SW;
    output logic [35:0] GPIO_0;
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    // Signal aliases
    logic clk, reset;
    // Module interconnections
    // key_a and key_b are the stable versions of KEY
    logic key_a, key_b, enter, exit;
    logic [7:0] bcd;

    // Hookup aliases
    assign clk = CLOCK_50;
    assign reset = SW[9];

    // Hookup modules
    metastability_filter filter_a(.clk, .reset, .direct_in(KEY[0]), .filtered_out(key_a));
    metastability_filter filter_b(.clk, .reset, .direct_in(KEY[1]), .filtered_out(key_b));
    car_detector detector(.clk, .reset, .a(~key_a), .b(~key_b), .enter, .exit);
    lot_counter counter(.clk, .reset, .inc(enter), .dec(exit), .bcd);
    counter_display lot_display(.bcd, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5);

    // Hookup off-board LEDs via GPIO
    assign GPIO_0[0] = ~key_a;
    assign GPIO_0[9] = ~key_b;
endmodule

module DE1_SoC_testbench();
    logic CLOCK_50;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [35:0] GPIO_0;

    // Input aliases
    logic a, b, reset;
    assign KEY[0] = ~a;
    assign KEY[1] = ~b;
    assign SW[9] = reset;

    DE1_SoC dut(
        .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .SW, .CLOCK_50, .GPIO_0);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        CLOCK_50 <= 0;
        forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
    end

    initial begin
        a <= 0; b <= 0;
        reset <= 1; @(posedge CLOCK_50);
        reset <= 0; @(posedge CLOCK_50);
        // Test enter
        {a, b} <= 2'b10; @(posedge CLOCK_50);
        {a, b} <= 2'b11; @(posedge CLOCK_50);
        {a, b} <= 2'b01; @(posedge CLOCK_50);
        {a, b} <= 2'b00; @(posedge CLOCK_50);
        // Metastable filters delay inputs by two clock cycles
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        // Test exit
        {a, b} <= 2'b01; @(posedge CLOCK_50);
        {a, b} <= 2'b11; @(posedge CLOCK_50);
        {a, b} <= 2'b10; @(posedge CLOCK_50);
        {a, b} <= 2'b00; @(posedge CLOCK_50);
        // Metastable filters delay inputs by two clock cycles
        @(posedge CLOCK_50);
        @(posedge CLOCK_50);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
