// Detects cars entering and exiting the parking lot
// - a and b are the parking lot photo sensors. 1 if the sensors are
// 	 obstructed; 0 otherwise
// - enter is 1 for 1 clock cycle if a car has entered; otherwise 0
// - exit is 1 for 1 clock cycle if a car has exited; otherwise 0

module car_detector(clk, reset, a, b, enter, exit);
	input logic clk, reset, a, b;
	output logic enter, exit;

	enum {S_EMPTY, S_IN1, S_IN2, S_IN3, S_OUT1, S_OUT2, S_OUT3} ps, ns;

	// FSM combinational logic
	always_comb begin
		enter = 0;
		exit = 0;
		// For invalid sensor inputs, assume the state hasn't changed
		ns = ps;
		case (ps)
			S_EMPTY: begin
				if (a & ~b) ns = S_IN1;
				else if (~a & b) ns = S_OUT1;
			end
			S_IN1: begin
				if (a & b) ns = S_IN2;
			end
			S_IN2: begin
				if (~a & b) ns = S_IN3;
			end
			S_IN3: begin
				if (~a & ~b) begin
					ns = S_EMPTY;
					enter = 1;
				end
			end
			S_OUT1: begin
				if (a & b) ns = S_OUT2;
			end
			S_OUT2: begin
				if (a & ~b) ns = S_OUT3;
			end
			S_OUT3: begin
				if (~a & ~b) begin
					ns = S_EMPTY;
					exit = 1;
				end
			end
		endcase
	end

	// DFFs for FSM
	always_ff @(posedge clk) begin
		if (reset) ps <= S_EMPTY;
		else ps <= ns;
	end
endmodule

module car_detector_testbench();
	logic clk, reset, a, b, enter, exit;
	logic [1:0] inputs, outputs;
	assign {a, b} = inputs;
	assign outputs = {enter, exit};
	
	car_detector dut(.clk, .reset, .a, .b, .enter, .exit);

	// Clock
	parameter CLOCK_PERIOD=100;
	initial begin
		clk <= 0;
		forever #(CLOCK_PERIOD/2) clk <= ~clk;
	end
	
	initial begin
		inputs <= 2'b00;
		reset <= 1; @(posedge clk);
		reset <= 0; @(posedge clk);
		// Check that the FSM stays at empty
		@(posedge clk);
		@(posedge clk);
		// Check entering
		inputs <= 2'b10; @(posedge clk); assert(outputs == 0);
		inputs <= 2'b11; @(posedge clk); assert(outputs == 0);
		inputs <= 2'b01; @(posedge clk); assert(outputs == 0);
		inputs <= 2'b00; @(posedge clk); assert(outputs == 2'b10);
		inputs <= 2'b00; @(posedge clk); assert(outputs == 0);
		// Check exiting
		inputs <= 2'b01; @(posedge clk); assert(outputs == 0);
		inputs <= 2'b11; @(posedge clk); assert(outputs == 0);
		inputs <= 2'b10; @(posedge clk); assert(outputs == 0);
		inputs <= 2'b00; @(posedge clk); assert(outputs == 2'b01);
		inputs <= 2'b00; @(posedge clk); assert(outputs == 0);
		$stop;
	end
endmodule
