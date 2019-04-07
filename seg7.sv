// Displays a hexadecimal digit on a 7-segment display
// - hex is the hex digit to display
// - out is the HEX display output
//
// Modular dependencies: N/A

module seg7(hex, out);
    input logic [3:0] hex;
    output logic [6:0] out;

    always_comb begin
        case (hex)
            4'h0: out = 7'b1000000;
            4'h1: out = 7'b1111001;
            4'h2: out = 7'b0100100;
            4'h3: out = 7'b0110000;
            4'h4: out = 7'b0011001;
            4'h5: out = 7'b0010010;
            4'h6: out = 7'b0000010;
            4'h7: out = 7'b1111000;
            4'h8: out = 7'b0000000;
            4'h9: out = 7'b0010000;
            4'hA: out = 7'b0001000;
            4'hB: out = 7'b0000011;
            4'hC: out = 7'b1000110;
            4'hD: out = 7'b0100001;
            4'hE: out = 7'b0000110;
            4'hF: out = 7'b0001110;
            default: out = 7'bX;
        endcase
    end
endmodule

module seg7_testbench();
    logic [3:0] hex;
    logic [6:0] out;

    seg7 dut(.hex, .out);

    int i;
    initial begin
        #50;
        for (i=0; i<16; i++) begin
            hex = i; #100;
        end
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
