module task2 #(parameter DATA_WIDTH=24) (clk, reset, dataIn, dataOut);
	input  logic clk, reset;
	input  logic signed [23:0] dataIn;
	output logic signed [23:0] dataOut;
	
	integer i;

	logic signed [23:0] fifo [7:0];
	
	always_ff @(posedge clk) begin
		if (reset) begin
			dataOut <= 0;
			for (i = 0; i < 8; i++) begin
				fifo[i] <= 24'b0;
			end
		end
		else begin
			dataOut <= (fifo[0] / 8) + (fifo[1] / 8) + (fifo[2] / 8) + (fifo[3] / 8) + 
						 (fifo[4] / 8) + (fifo[5] / 8) + (fifo[6] / 8) + (fifo[7] / 8);
			fifo[0] <= dataIn;
			for (i = 1; i < 8; i++) begin
				fifo[i] <= fifo[i - 1];
			end
		end
	end
endmodule

module task2_testbench();
	logic clk, reset;
	logic signed [23:0] dataIn;
	logic signed [23:0] dataOut;
	
	task2 #(24) dut (.clk, .reset, .dataIn, .dataOut);

	// Set up the clock with a period of 100 units and a 50% duty cycle
	// 50% duty cycle means the clock spends 50 time units ON and 50 units OFF
	parameter CLOCK_PERIOD=50;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	int i;
	initial begin
		dataIn <= 24'b0;
		reset <= 1; @(posedge clk); reset <= 0; @(posedge clk);
		for (i = 0; i < 256; i++) begin
			dataIn <= -1 * (i << 8); @(posedge clk);
		end
		@(posedge clk); @(posedge clk); @(posedge clk); @(posedge clk);
		$stop;
	end
endmodule

