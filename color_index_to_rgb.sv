// Module that converts a color index to a 

`include "common.sv"

module color_index_to_rgb(
        input logic [COLOR_WIDTH-1:0] index,
        output logic [7:0] r, g, b
    );

    always_comb begin
        assert(index != COLOR_NONE);
        case (index)
            COLOR_BLACK: {r, g, b} = 24'h0;
            COLOR_WHITE: {r, g, b} = 24'hFF_FF_FF;
            COLOR_RED: {r, g, b} = 24'hFF_00_00;
            COLOR_GREEN: {r, g, b} = 24'h00_FF_00;
            COLOR_BLUE: {r, g, b} = 24'h00_00_FF;
            default: {r, g, b} = 'x;
        endcase
    end
endmodule

module color_index_to_rgb_testbench();
    logic [COLOR_WIDTH-1:0] index;
    logic [7:0] r, g, b;

    color_index_to_rgb dut(.index, .r, .g, .b);

    initial begin
        index = COLOR_BLACK; #10;
        index = COLOR_WHITE; #10;
        index = COLOR_RED; #10;
        index = COLOR_GREEN; #10;
        index = COLOR_BLUE; #10;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
