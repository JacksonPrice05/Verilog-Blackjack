//Jackson Price & Richie Nadolny
//Inputs
//turn: 4bit, This is a turn tracker that maxes out at 12 because each player gets at max 6 turns.
// card1-11_in: 6-bit, Aderess of card
//Outputs
//card_out: 6-bits, Gives the adderess of the card with the same number as what turn is currently at. (if turn is 5, card_out = card5_in)
//
//The purpose of this module is to help us acsess the cards one at a time.

module selecter(turn, card0_in, card1_in, card2_in, card3_in, card4_in, card5_in, card6_in, card7_in, card8_in, card9_in, card10_in, card11_in, card_out);
	
	input logic [3:0] turn;
	
	input logic[5:0] card0_in, card1_in, card2_in, card3_in, card4_in, card5_in, 
		card6_in, card7_in, card8_in, card9_in, card10_in, card11_in;
	
	output logic[5:0] card_out;

	always_comb begin
			case (turn)
			  4'd0:  card_out = card0_in;
			  4'd1:  card_out = card1_in;
			  4'd2:  card_out = card2_in;
			  4'd3:  card_out = card3_in;
			  4'd4:  card_out = card4_in;
			  4'd5:  card_out = card5_in;
			  4'd6:  card_out = card6_in;
			  4'd7:  card_out = card7_in;
			  4'd8:  card_out = card8_in;
			  4'd9:  card_out = card9_in;
			  4'd10: card_out = card10_in;
			  4'd11: card_out = card11_in;
			  default: card_out = 6'd52;//blank card
		endcase
	end

endmodule
