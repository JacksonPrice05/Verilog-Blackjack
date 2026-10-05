// Richard Nadolny & Jackson Price 

// This module recognizes a change in the current card being shown to the top level system
// Inputs:
//  - clk: clock signal, 1-bit
//  - card: current card being shown, 6-bits
//  Outputs:
//  - overwrite: true for one clock cycle when just after the card as changed
module detect_NC(clk, card, overwrite);
	input logic clk;
	input logic [5:0] card;
	output logic overwrite;
	logic [5:0] old_card, inter;
	
	// pulse detection
	always_ff @(posedge clk) begin
		old_card <= card;
	end
		
	assign overwrite = (card != old_card);
	
endmodule 