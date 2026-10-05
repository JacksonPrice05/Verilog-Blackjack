/* Top level module of the FPGA that takes the onboard resources 
 * as input and outputs the lines drawn from the VGA port.
 *
 * Inputs:
 *   KEY 			- On board keys of the FPGA
 *   SW 			- On board switches of the FPGA
 *   CLOCK_50 		- On board 50 MHz clock of the FPGA
 *
 * Outputs:
 *   HEX 			- On board 7 segment displays of the FPGA
 *   LEDR 			- On board LEDs of the FPGA
 *   VGA_R 			- Red data of the VGA connection
 *   VGA_G 			- Green data of the VGA connection
 *   VGA_B 			- Blue data of the VGA connection
 *   VGA_BLANK_N 	- Blanking interval of the VGA connection
 *   VGA_CLK 		- VGA's clock signal
 *   VGA_HS 		- Horizontal Sync of the VGA connection
 *   VGA_SYNC_N 	- Enable signal for the sync of the VGA connection
 *   VGA_VS 		- Vertical Sync of the VGA connection
 */
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW, CLOCK_50, 
	VGA_R, VGA_G, VGA_B, VGA_BLANK_N, VGA_CLK, VGA_HS, VGA_SYNC_N, VGA_VS);
	
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0] LEDR;
	input logic [3:0] KEY;
	input logic [9:0] SW;
	input CLOCK_50;
	output [7:0] VGA_R;
	output [7:0] VGA_G;
	output [7:0] VGA_B;
	output VGA_BLANK_N;
	output VGA_CLK;
	output VGA_HS;
	output VGA_SYNC_N;
	output VGA_VS;
	
	assign LEDR[8:0] = SW[8:0];
	
	logic [10:0] x, y;
	logic reset;
	logic color;
	logic card_recieved;
	
	VGA_framebuffer fb (
		.clk50			(CLOCK_50), 
		.reset			(reset), 
		.x, 
		.y,
		.pixel_color	(color), 
		.pixel_write	(1'b1),
		.VGA_R, 
		.VGA_G, 
		.VGA_B, 
		.VGA_CLK, 
		.VGA_HS, 
		.VGA_VS,
		.VGA_BLANK_n	(VGA_BLANK_N), 
		.VGA_SYNC_n		(VGA_SYNC_N));
	
	//Blackjack code begins here
	logic draw_p1, stay_p1, draw_p2, stay_p2;
	logic [5:0] seed;
	logic [5:0] deal;
	logic enable_deal, redeal, p1_hit, p2_hit, deal_valid;
	
	assign enable_deal = (redeal | p1_hit | p2_hit);
	assign seed = SW[5:0];
	assign reset = SW[9];
	assign LEDR[9] = reset;
	
	//metastability
	userDouble DP1(CLOCK_50, KEY[3], draw_p1);
	userDouble SP1(CLOCK_50, KEY[2], stay_p1);
	userDouble DP2(CLOCK_50, KEY[1], draw_p2);
	userDouble SP2(CLOCK_50, KEY[0], stay_p2);
	
	logic overwrite, next, finish_game, p1_turn, p2_turn, pass_card;
	logic [3:0] curr_turn;
	
	// this register tracks / stores current turn 0-5 = p1, 6-11 = p2;
    always_ff @(posedge CLOCK_50) begin
    	if      (reset)       curr_turn <= 4'd0;
    	else if (finish_game) curr_turn <= 4'd12;
    	else if (next)        curr_turn <= 4'd6;
    	else if (card_recieved) curr_turn <= curr_turn + 4'd1;
    end
	
	assign p1_turn = (curr_turn < 4'd6);
	assign p2_turn = (curr_turn >= 4'd6) & (curr_turn < 4'd12);
	
	logic  card_rec1, card_rec2;
	assign card_recieved = (card_rec1 | card_rec2);
	
	
	// dealer + deck instantiation
	logic [63:0] deck_valid;
	assign deal_valid = (deal < 6'd52) & deck_valid[deal];
	
	// deck register for card validity, adapted from RAM
	always_ff @(posedge CLOCK_50) begin
		if (reset) deck_valid <= 64'h000FFFFFFFFFFFFF;
		else if (card_recieved) deck_valid[deal] <= 1'b0;
	end

	LFSR_6bit dealer(.clk(CLOCK_50), .out(deal), .seed, .reset, .req(enable_deal));
	detect_NC new_card_overwrite(.clk(CLOCK_50), .card(deal), .overwrite);
	deck_controller DC(.clk(CLOCK_50), .reset, .start(p1_hit | p2_hit), .new_card(overwrite), .redeal, .pass_card, .valid(deal_valid));

	// create each player + hand
	play player_1(.clk(CLOCK_50), .draw(draw_p1), .stay(stay_p1), .request(p1_hit), .curr_turn(p1_turn), .change_turn(next));
	play player_2(.clk(CLOCK_50), .draw(draw_p2), .stay(stay_p2), .request(p2_hit), .curr_turn(p2_turn), .change_turn(finish_game));
	
	logic hand_mask1, hand_mask2;
	assign hand_mask1 = pass_card & p1_turn;
	assign hand_mask2 = pass_card & p2_turn;
	
	logic[5:0] p1_card0, p1_card1, p1_card2, p1_card3, p1_card4, p1_card5;
	logic[5:0] p2_card0, p2_card1, p2_card2, p2_card3, p2_card4, p2_card5;
	logic[6:0] score1, score2;
	
	hand hand1(.clk(CLOCK_50), .reset, .enable(hand_mask1), .card_in(deal), 
		.card0(p1_card0), .card1(p1_card1), .card2(p1_card2), .card3(p1_card3), .card4(p1_card4), .card5(p1_card5), 
		.score(score1), .card_recieved(card_rec1), .curr_turn);
	hand hand2(.clk(CLOCK_50), .reset, .enable(hand_mask2), .card_in(deal), 
		.card0(p2_card0), .card1(p2_card1), .card2(p2_card2), .card3(p2_card3), .card4(p2_card4), .card5(p2_card5), 
		.score(score2), .card_recieved(card_rec2), .curr_turn);
		
    logic[5:0] card_out;
    logic[5:0] draw_card;
    logic[3:0] draw_turn;
	
	// Display / writing logic
	selecter card_mux(.turn(curr_turn), .card0_in(p1_card0), .card1_in(p1_card1), .card2_in(p1_card2), .card3_in(p1_card3), .card4_in(p1_card4),
		.card5_in(p1_card5), .card6_in(p2_card0), .card7_in(p2_card1), .card8_in(p2_card2), .card9_in(p2_card3), .card10_in(p2_card4), .card11_in(p2_card5),
		.card_out);
		
	// turn logic 	
	always_ff @(posedge CLOCK_50) begin
    	if (reset) begin
    		draw_card <= 6'd52;
    		draw_turn <= 4'd0;
    	end else if (card_recieved) begin
    		draw_card <= card_out;
    		draw_turn <= curr_turn;
    	end
    end

    writer2 card_write(.card(draw_card), .clock(CLOCK_50), .reset, .x, .y, .color, .card_recieved, .curr_turn(draw_turn));

	victory vic(.*);
	    
endmodule  // DE1_SoC
