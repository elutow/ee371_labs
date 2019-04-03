// A full adder implementation
// a, b represent logic to sum
// cin is the carry to add while summing
// sum is the result, with cout being the carry of this sum

module full_adder(a, b, cin, sum, cout);
	input logic a, b, cin;
	output logic sum, cout;

	// Summing logic
	assign sum = a ^ b ^ cin;
	assign cout = a&b | cin & (a^b);
endmodule

module full_adder_testbench();
	logic a, b, cin, sum, cout;

	full_adder dut(.a, .b, .cin, .sum, .cout);

	int i;
	initial begin
		// Iterate through every possible combination of the inputs
		for (i=0; i<2**3, i++) begin
			{a, b, cin} = i; #10;
		end
		$stop;
	end //initial
endmodule
