// Richard Nadolny & Jackson Price

// This module stores all of the encoded cards for each player, and calculates their score. 
// Inputs:
//  - clk: clock signal, 1-bit
//  - reset: reset signal, clears cards in hand, 1-bit
//  - card_in: current card encoding being offered by the dealer, 6-bit
//  - curr_turn: current turn case, 4-bit
//  Outputs:
//  - card (0-5): cards (encoded) being held by the player, 6-bits each
//  - score: this player's current score, 7-bit
//  - card_recieved: status signal asserted once this player as accepted a valid card from the dealer successfully, 1-bit
module hand(clk, reset, enable, card_in, card0, card1, card2, card3, card4, card5, score, card_recieved, curr_turn);
    input logic enable, clk, reset;
    input logic [5:0] card_in;
    output logic [5:0] card0, card1, card2, card3, card4, card5;
    input logic [3:0] curr_turn;
    output logic [6:0] score;
    output logic card_recieved;

    logic [2:0] turn_case;
    assign turn_case = curr_turn % 6;

	 // state logic for card_recieved
    enum logic {idle, finish} ps, ns;

    always_ff @(posedge clk) begin
        if (reset) ps <= idle;
        else       ps <= ns;
    end

    always_comb begin
        case (ps)
            idle:    ns = enable ? finish : idle;
            finish:  ns = idle;
            default: ns = idle;
        endcase
    end
	 // end state logic for card_recived (moore)

	 // combinational logic for which card "slot" to place the input card
    always_ff @(posedge clk) begin
        if (reset) begin
            card0 <= 6'd52; card1 <= 6'd52; card2 <= 6'd52;
            card3 <= 6'd52; card4 <= 6'd52; card5 <= 6'd52;
        end else if (ps == finish) begin
            case (turn_case)
                3'd0: card0 <= card_in;
                3'd1: card1 <= card_in;
                3'd2: card2 <= card_in;
                3'd3: card3 <= card_in;
                3'd4: card4 <= card_in;
                3'd5: card5 <= card_in;
            endcase
        end
    end

	 // moore assignment
    always_ff @(posedge clk)
        card_recieved <= (ps == finish);

    // Card value determination, decoding
    logic [3:0] rank;
    logic [6:0] cv; // combinational card value for current card_in

    assign rank = card_in % 13;

    always_comb begin
        case (rank)
            4'd0:                          cv = 7'd11; // Ace (low)
            4'd9, 4'd10, 4'd11, 4'd12:    cv = 7'd10; // T, J, Q, K
            default:                       cv = {3'd0, rank} + 7'd1; // 2–9
        endcase
    end

    // Score accumulator with automated choice for ace high/low
    logic [6:0] new_score;
    assign new_score = score + cv;

    always_ff @(posedge clk) begin
        if (reset)
            score <= 7'd0;
        else if (ps == finish) begin
            if (new_score > 7'd21 && cv == 7'd11) 
                score <= new_score - 7'd10;
            else
                score <= new_score;
        end
    end

endmodule
