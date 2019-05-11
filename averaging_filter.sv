// Implements a N-sample moving average FIR filter
// - enable specifies if new data should be read and written. When zero,
//   the input is ignored and the output is held to the last value.
//
// Modular dependencies:
// - fifo
module averaging_filter #(
		// Specifies the window size for averaging
		parameter N = 8,
		// Specifies the data width
		parameter DATA_WIDTH = 24
	)
	(
		input logic clk, reset, enable,
		input logic signed [DATA_WIDTH-1:0] data_in,
		output logic signed [DATA_WIDTH-1:0] data_out
	);

	// Accumulator DFF
	logic signed [DATA_WIDTH-1:0] sum, next_sum;
	// The current sample after normalizing against N
	logic signed [DATA_WIDTH-1:0] sample;
	// FIFO signals and data prots
	logic fifo_rd, fifo_wr;
	logic fifo_full;
	logic signed [DATA_WIDTH-1:0] fifo_out;
	// FSM states
	enum {STATE_INIT, STATE_DONE} ps, ns;

	// Ensure window size is a power of two
	initial assert(2**$clog2(N) == N)
		else $error("Window size is not a power of 2: %d", N);

	// Controller logic
	assign sample = DATA_WIDTH'(data_in / N);
	always_comb begin
		case (ps)
			STATE_INIT: begin
				// Initialize accumulator and FIFO
				fifo_rd = 0;
				fifo_wr = 0;
				next_sum = DATA_WIDTH'(0);
				ns = STATE_DONE;
			end
			STATE_DONE: begin
				fifo_wr = 0;
				fifo_rd = 0;
				next_sum = sum;
				ns = STATE_DONE;
				if (enable) begin
					fifo_wr = 1;
					if (fifo_full) begin
						// Slide averaging window
						fifo_rd = 1;
						next_sum = sum + sample - fifo_out;
					end
					else begin
						// Fill FIFO until full, and populate accumulator
						fifo_rd = 0;
						next_sum = sum + sample;
					end
				end
			end
		endcase
	end
	always_ff @(posedge clk) begin
		if (reset) ps <= STATE_INIT;
		else ps <= ns;
	end

	// Datapath logic
	fifo #(.DATA_WIDTH(DATA_WIDTH), .ADDR_WIDTH($clog2(N))) window_buffer(
		.clk, .reset, .rd(fifo_rd), .wr(fifo_wr),
		.w_data(sample), .r_data(fifo_out),
		.empty(), .full(fifo_full));
	always_ff @(posedge clk) begin
		sum <= next_sum;
	end
	assign data_out = sum;
endmodule

module averaging_filter_testbench();
	parameter N = 4;
	parameter DATA_WIDTH = 8;
	logic clk, reset, enable;
	logic signed [DATA_WIDTH-1:0] data_in;
	logic signed [DATA_WIDTH-1:0] data_out;
	enum {STATE_INIT, STATE_DONE} ps, ns;

	averaging_filter #(.N(N), .DATA_WIDTH(DATA_WIDTH)) dut(
		.clk, .reset, .enable, .data_in, .data_out);

	// Clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end

	initial begin
		data_in <= 8'd4; enable <= 1;
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
			assert(dut.ps == STATE_INIT);
			assert(dut.sum == 8'd0);
			assert(dut.next_sum == 8'd0);
		// Fill FIFO
		@(posedge clk);
			assert(dut.ps == STATE_DONE);
			// FIFO: 1
			assert(dut.next_sum == 8'd1);
		data_in <= -8'd8; @(posedge clk);
			// FIFO: 1, -2
			assert(dut.next_sum == -8'd1);
		data_in <= 8'd12; @(posedge clk);
			// FIFO: 1, -2, 3
			assert(dut.next_sum == 8'd2);
		data_in <= -8'd16; @(posedge clk);
			// FIFO: 1, -2, 3, -4
			assert(dut.next_sum == -8'd2);
		// FIFO should be full now
		data_in <= 8'd20; @(posedge clk);
			// FIFO: -2, 3, -4, 5
			assert(dut.next_sum == 8'd2);
		data_in <= -8'd24; @(posedge clk);
			// FIFO: 3, -4, 5, -6
			assert(dut.next_sum == -8'd2);
		data_in <= 8'd28; @(posedge clk);
			// FIFO: -4, 5, -6, 7
			assert(dut.next_sum == 8'd2);
		data_in <= -8'd32; @(posedge clk);
			// FIFO: 5, -6, 7, -8
			assert(dut.next_sum == -8'd2);
		// By this clock edge, the FIFO should have gone full circle
		// This ensures simultaneous read and write works when the FIFO is
		// full
		data_in <= 8'd36; @(posedge clk);
			// FIFO: -6, 7, -8, 9
			assert(dut.next_sum == 8'd2);
		// Test enable
		enable <= 0;
		data_in <= -8'd40; @(posedge clk);
			assert(dut.next_sum == 8'd2);
		enable <= 1; @(posedge clk);
			// FIFO: 7, -8, 9, -10
			assert(dut.next_sum == -8'd2);
		$stop;
	end
endmodule
