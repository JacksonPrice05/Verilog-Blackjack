// Richard Nadolny & Jackson Price

// This module handles pulse detection from user input to interpret control signals for the rest
// of the top level circuit.
// Inputs:
//  - clk: clock signal, 1-bit
//  - draw: draw signal user input, 1-bit
//  - stay: stay signal user input, 1-bit
//  - curr_turn: current turn, 1-bit (true if it is this players turn)
//  Outputs:
//  - request: reqyest a card from the dealer, 1-bit
//  - change_turn: signal to stay at current cards, move onto next player, 1-bit
module play(clk, draw, stay, request, curr_turn, change_turn);
	
	output logic request, change_turn;
	input logic curr_turn, draw, stay, clk;
	logic draw_inter, draw_pulse, stay_inter, stay_pulse;
	
	// pulse detection register
	always_ff @(posedge clk) begin
		draw_inter <= draw;
		stay_inter <= stay;
	end
	
	// pulse detection logic
	assign draw_pulse = (curr_turn) ? (draw & ~draw_inter) : 1'b0;
	assign stay_pulse = (curr_turn) ? (stay & ~stay_inter) : 1'b0;
	
	// assign outputs to pulse detection
	assign request = draw_pulse;
	assign change_turn = stay_pulse;

endmodule
