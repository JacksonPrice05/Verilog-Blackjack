`timescale 1ns/1ps

module deck_controller_tb();

	logic clk, reset;
	logic start, new_card, valid;
	logic redeal, pass_card;

	deck_controller dut (
		.clk(clk),
		.reset(reset),
		.start(start),
		.new_card(new_card),
		.redeal(redeal),
		.pass_card(pass_card),
		.valid(valid)
	);

	parameter CLOCK_PERIOD = 20;

	initial begin
		clk = 1'b0;
		forever #(CLOCK_PERIOD / 2) clk = ~clk;
	end

	task tick;
		begin
			@(posedge clk);
			#1;
		end
	endtask

	initial begin
		reset = 1'b1;
		start = 1'b0;
		new_card = 1'b0;
		valid = 1'b0;

		tick;

		reset = 1'b0;
		#1;

		// Idle state: no start means no outputs.
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b0) $stop;

		tick;

		// Start moves FSM from idle to active.
		start = 1'b1;
		#1;
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b0) $stop;

		tick;
		start = 1'b0;

		// Active, but no new card yet: no outputs.
		new_card = 1'b0;
		valid = 1'b0;
		#1;
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b0) $stop;

		tick;

		// Active + new_card + invalid: redeal should pulse.
		new_card = 1'b1;
		valid = 1'b0;
		#1;
		if (redeal !== 1'b1) $stop;
		if (pass_card !== 1'b0) $stop;

		tick;

		// Still active. new_card + valid: pass_card should pulse and return idle next.
		new_card = 1'b1;
		valid = 1'b1;
		#1;
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b1) $stop;

		tick;

		// Now back in idle. With start low, outputs should be zero.
		new_card = 1'b0;
		valid = 1'b0;
		#1;
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b0) $stop;

		tick;

		// Verify new_card in idle does not pass/redeal unless start first activates FSM.
		new_card = 1'b1;
		valid = 1'b1;
		#1;
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b0) $stop;

		tick;

		// Reset should force idle from any state.
		start = 1'b1;
		new_card = 1'b0;
		valid = 1'b0;
		tick;
		start = 1'b0;

		reset = 1'b1;
		tick;
		reset = 1'b0;

		new_card = 1'b1;
		valid = 1'b1;
		#1;
		if (redeal !== 1'b0) $stop;
		if (pass_card !== 1'b0) $stop;

		$stop;
	end

endmodule