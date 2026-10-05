`timescale 1ns/1ps

module hand_tb();

	logic clk, reset, enable;
	logic [5:0] card_in;
	logic [5:0] card0, card1, card2, card3, card4, card5;
	logic [3:0] curr_turn;
	logic [6:0] score;
	logic card_recieved;

	hand dut (
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.card_in(card_in),
		.card0(card0),
		.card1(card1),
		.card2(card2),
		.card3(card3),
		.card4(card4),
		.card5(card5),
		.score(score),
		.card_recieved(card_recieved),
		.curr_turn(curr_turn)
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

	task check_reset_state;
		begin
			if (card0 !== 6'd52) $stop;
			if (card1 !== 6'd52) $stop;
			if (card2 !== 6'd52) $stop;
			if (card3 !== 6'd52) $stop;
			if (card4 !== 6'd52) $stop;
			if (card5 !== 6'd52) $stop;
			if (score !== 7'd0) $stop;
		end
	endtask

	task deal_card(input [3:0] turn, input [5:0] card);
		begin
			curr_turn = turn;
			card_in = card;
			enable = 1'b1;
			tick;          // idle -> finish
			enable = 1'b0;
			tick;          // finish stores card and score
			if (card_recieved !== 1'b1) $stop;
			tick;          // finish -> idle, card_recieved clears
			if (card_recieved !== 1'b0) $stop;
		end
	endtask

	initial begin
		enable = 1'b0;
		card_in = 6'd0;
		curr_turn = 4'd0;
		reset = 1'b1;

		tick;
		reset = 1'b0;
		#1;

		check_reset_state();

		// Card numbering:
		// 0 = Ace, 1 = 2, 8 = 9, 9 = 10, 10 = J, 11 = Q, 12 = K

		deal_card(4'd0, 6'd0);   // Ace -> 11, goes to card0
		if (card0 !== 6'd0) $stop;
		if (score !== 7'd11) $stop;

		deal_card(4'd1, 6'd8);   // 9 -> +9, goes to card1
		if (card1 !== 6'd8) $stop;
		if (score !== 7'd20) $stop;

		deal_card(4'd2, 6'd10);  // Jack -> +10, goes to card2
		if (card2 !== 6'd10) $stop;
		if (score !== 7'd30) $stop;

		// curr_turn % 6 should wrap player 2 slots to card0-card5.
		reset = 1'b1;
		tick;
		reset = 1'b0;
		tick;
		check_reset_state();

		deal_card(4'd6, 6'd13);  // Diamond Ace, turn 6 % 6 = 0
		if (card0 !== 6'd13) $stop;
		if (score !== 7'd11) $stop;

		deal_card(4'd11, 6'd25); // Diamond King, turn 11 % 6 = 5
		if (card5 !== 6'd25) $stop;
		if (score !== 7'd21) $stop;

		// Soft Ace reduction case:
		reset = 1'b1;
		tick;
		reset = 1'b0;
		tick;
		check_reset_state();

		deal_card(4'd0, 6'd9);   // 10 -> score 10
		if (score !== 7'd10) $stop;

		deal_card(4'd1, 6'd0);   // Ace would make 21, keep as 11
		if (score !== 7'd21) $stop;

		reset = 1'b1;
		tick;
		reset = 1'b0;
		tick;
		check_reset_state();

		deal_card(4'd0, 6'd9);   // 10
		deal_card(4'd1, 6'd8);   // 9, score 19
		deal_card(4'd2, 6'd0);   // Ace would make 30, reduce to +1 => 20
		if (score !== 7'd20) $stop;

		$stop;
	end

endmodule
