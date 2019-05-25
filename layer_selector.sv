// Module to select a layer to draw on

module layer_selector
    (
        input logic clk, reset, toggle,
        output logic [2:0] layer
    );

    logic [2:0] next_layer;
    logic changed, next_changed;

    always_comb begin
        next_layer = layer;
        next_changed = changed;
        if (toggle) begin
            if (!changed) begin
                next_changed = 1;
				next_layer = layer + 1;
            end
        end
        else begin
            next_changed = 0;
        end
    end

    always_ff @(posedge clk) begin
        if (reset) begin
            layer <= 0;
            changed <= 0;
        end
        else begin
            layer <= next_layer;
            changed <= next_changed;
        end
    end
endmodule

module layer_selector_testbench();
    logic clk, reset, toggle;
    logic [2:0] layer;

    layer_selector dut(.clk, .reset, .toggle, .layer);

    // Clock
    parameter CLOCK_PERIOD=100;
    initial begin
        clk <= 0;
        forever #(CLOCK_PERIOD/2) clk <= ~clk;
    end

    initial begin
        toggle <= 0;
        reset <= 1; @(posedge clk);
        reset <= 0; @(posedge clk);
        assert(layer == 0);
        // Toggle layer
        toggle <= 1; @(posedge clk);
        @(posedge clk);
        assert(layer == 1);
        // Ensure layer doesn't change while toggle is still 1
        @(posedge clk);
        assert(layer == 1);
        // Toggle off and see if layer changes
        toggle <= 0; @(posedge clk);
        assert(layer == 1);
        $stop;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
