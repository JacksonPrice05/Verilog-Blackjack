`timescale 1ns/1ps

module play_tb();

	logic clk;
	logic draw, stay;
	logic curr_turn;
	logic request, change_turn;

	play dut (
		.clk(clk),
		.draw(draw),
		.stay(stay),
		.request(request),
		.curr_turn(curr_turn),
		.change_turn(change_turn)
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
		draw = 1'b0;
		stay = 1'b0;
		curr_turn = 1'b0;

		tick;

		// Not current player's turn: draw/stay should do nothing.
		draw = 1'b1;
		#1;
		if (request !== 1'b0) $stop;

		stay = 1'b1;
		#1;
		if (change_turn !== 1'b0) $stop;

		tick;
		draw = 1'b0;
		stay = 1'b0;
		tick;

		// Current player's turn: rising edge of draw creates request pulse.
		curr_turn = 1'b1;
		draw = 1'b1;
		#1;
		if (request !== 1'b1) $stop;
		if (change_turn !== 1'b0) $stop;

		tick;
		if (request !== 1'b0) $stop;

		// Holding draw high should not keep requesting.
		tick;
		if (request !== 1'b0) $stop;

		// Drop draw, then raise again for another pulse.
		draw = 1'b0;
		tick;
		draw = 1'b1;
		#1;
		if (request !== 1'b1) $stop;

		tick;
		draw = 1'b0;
		tick;

		// Rising edge of stay creates change_turn pulse.
		stay = 1'b1;
		#1;
		if (change_turn !== 1'b1) $stop;
		if (request !== 1'b0) $stop;

		tick;
		if (change_turn !== 1'b0) $stop;

		// Holding stay high should not keep change_turn high.
		tick;
		if (change_turn !== 1'b0) $stop;

		// If turn goes false, no pulses should be generated.
		stay = 1'b0;
		tick;
		curr_turn = 1'b0;
		draw = 1'b1;
		stay = 1'b1;
		#1;
		if (request !== 1'b0) $stop;
		if (change_turn !== 1'b0) $stop;

		$stop;
	end

endmodule
