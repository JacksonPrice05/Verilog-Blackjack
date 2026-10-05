`timescale 1ns/1ps

module AH_ROM #(parameter MIF_FILE = "BLANK.mif") (
	input  logic [13:0] address,
	input  logic        clock,
	output logic [0:0]  q
);
	always_comb begin
		if (MIF_FILE == "BLANK.mif")
			q = 1'b0;
		else if (MIF_FILE == "AH.mif")
			q = 1'b1;
		else
			q = address[0];
	end
endmodule


module writer2_tb();

	logic [5:0]  card;
	logic [3:0]  curr_turn;
	logic [10:0] x, y;
	logic        color;
	logic        clock, reset, card_recieved;

	writer2 dut (
		.card(card),
		.clock(clock),
		.reset(reset),
		.x(x),
		.y(y),
		.color(color),
		.card_recieved(card_recieved),
		.curr_turn(curr_turn)
	);

	parameter CLOCK_PERIOD = 20;

	initial begin
		clock = 1'b0;
		forever #(CLOCK_PERIOD / 2) clock = ~clock;
	end

	task tick;
		begin
			@(posedge clock);
			#1;
		end
	endtask

	task check_xy(input [10:0] exp_x, input [10:0] exp_y);
		begin
			if (x !== exp_x || y !== exp_y)
				$stop;
		end
	endtask

	initial begin
		card = 6'd0;
		curr_turn = 4'd0;
		card_recieved = 1'b0;
		reset = 1'b1;

		tick;
		reset = 1'b0;
		#1;

		check_xy(11'd0, 11'd0);
		if (color !== 1'b0)
			$stop;

		repeat (639) tick;
		check_xy(11'd639, 11'd0);

		tick;
		check_xy(11'd0, 11'd1);

		repeat (640 * 479 - 1) tick;
		check_xy(11'd639, 11'd479);

		tick;
		check_xy(11'd20, 11'd280);

		if (color !== 1'b1)
			$stop;

		tick;
		check_xy(11'd21, 11'd280);

		repeat (98) tick;
		check_xy(11'd119, 11'd280);

		tick;
		check_xy(11'd20, 11'd281);

		card_recieved = 1'b1;
		tick;
		card_recieved = 1'b0;
		check_xy(11'd20, 11'd280);

		curr_turn = 4'd1;
		card_recieved = 1'b1;
		tick;
		card_recieved = 1'b0;
		check_xy(11'd140, 11'd280);

		curr_turn = 4'd6;
		card_recieved = 1'b1;
		tick;
		card_recieved = 1'b0;
		check_xy(11'd380, 11'd280);

		curr_turn = 4'd11;
		card_recieved = 1'b1;
		tick;
		card_recieved = 1'b0;
		check_xy(11'd500, 11'd20);

		card = 6'd52;
		#1;
		if (color !== 1'b0)
			$stop;

		$stop;
	end

endmodule
