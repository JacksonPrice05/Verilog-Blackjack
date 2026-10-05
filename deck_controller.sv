// Richard Nadolny & Jackson Price

// This module controls the exchange for card draw. It will only pass a valid card onto the current player,
// else requests a readeal.
// Inputs: 
//  - clk: clock signal, 1-bit
//  - reset: reset signal, 1-bit
//  - start: signal to begin verifying the current card, 1-bit
//  - new_card: interim start signal, only used for automation in redeal sequence, 1-bit
//  - valid: card validity from deck register, 1-bit
//  Outputs:
//  - redeal: signal to the dealer that the new card is invalid, and to request another draw, 1-bit
//  - pass_card: enable signal to the player hands that the offered card is valid, and they may take it, 1-bit
module deck_controller(clk, reset, start, new_card, redeal, pass_card, valid);
	input logic clk, reset, start, new_card, valid;
	output logic redeal, pass_card;
	
	enum logic {idle, active} ps, ns;
	
	always_ff @(posedge clk) ps <= (reset) ? idle : ns; 
	
	always_comb begin
	
		redeal   = 0;
		pass_card = 0;
		ns       = ps;  // default: stay in current state
	
		case (ps)
			idle: begin
				ns = (start) ? active : idle;
			end
			active: begin
				if (new_card) begin
					if (valid) begin 
						pass_card = 1;
						ns = idle;
					end 
					else begin
						redeal = 1;
						ns = active;
					end
				end
				else ns = active;
			end
		endcase
	end

endmodule
