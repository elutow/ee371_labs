// Metastability filter for raw inputs.
// - direct_in is the raw input signal
// - filtered_out is the stable output signal
//
// On reset, the module will use the current value of direct_in as the default
// value.
//
// Modular dependencies: N/A

module metastability_filter(clk, reset, direct_in, filtered_out);
	input logic clk, reset, direct_in;
	output logic filtered_out;
	logic input_buffer;

	// Metastability DFFs
	always_ff @(posedge clk) begin
		if (reset) begin
			input_buffer <= direct_in;
			filtered_out <= direct_in;
		end
		else begin
			input_buffer <= direct_in;
			filtered_out <= input_buffer;
		end
	end
endmodule

module metastability_filter_testbench();
	logic direct_in;
	logic filtered_out;
	logic clk, reset;

	metastability_filter dut(.clk, .reset, .direct_in, .filtered_out);

	// Clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		direct_in <= 1; @(posedge clk);
		direct_in <= 0; @(posedge clk);
		@(posedge clk);
		@(posedge clk);
		@(posedge clk);
		$stop;
	end
endmodule
