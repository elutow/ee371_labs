// Displays the parking lot counter on the HEX displays
// - bcd is a big-endian binary-coded decimal of the count
// - HEX* are the 7-segment display outputs
//
// Modular dependencies: seg7

module counter_display(bcd, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
    input logic [7:0] bcd;
    output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    // For HEX1 logic
    logic [6:0] hex1_buf; 

    // HEX0 is always displaying count
    seg7 seg7_hex0(.bcd(bcd[3:0]), .out(HEX0));

    // HEX1 output is conditionally dependent; so buffer bcd
    seg7 seg7_hex1(.bcd(bcd[7:4]), .out(hex1_buf));

    // Text rendering logic
    always_comb begin
        // Default HEX outputs
        HEX5 = 7'b1111111;
        HEX4 = HEX5;
        HEX3 = HEX5;
        HEX2 = HEX5;
        HEX1 = hex1_buf;
        if (bcd[7:4] == 2 & bcd[3:0] == 5) begin
            // Display FULL
            HEX5 = 7'b0001110;
            HEX4 = 7'b1000001;
            HEX3 = 7'b1000111;
            HEX2 = HEX3;
        end
        else if (bcd == 0) begin
            // Display CLEAR
            HEX5 = 7'b1000110;
            HEX4 = 7'b1000111;
            HEX3 = 7'b0000110;
            HEX2 = 7'b0001000;
            HEX1 = 7'b0101111;
        end
    end
endmodule

module counter_display_testbench();
    logic [7:0] bcd;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    counter_display dut(.bcd, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5);

    initial begin;
        #50;
        // Test CLEAR
        bcd = 0; #100;
        // Test FULL
        bcd[7:4] = 2; bcd[3:0] = 5; #100;
        // Test single digit
        bcd[7:4] = 0; bcd[3:0] = 7; #100;
    end
endmodule

// vim: set expandtab shiftwidth=4 softtabstop=4:
