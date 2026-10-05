//Jackson Price & Richie Nadolny
//Inputs
//curr_turn: 4bit, This is a turn tracker that maxes out at 12 because each player gets at max 6 turns.
// score1/score2: 7bit, This tracks the score of each player and is 7 bits to make sure it can store the maximum possible values
//Outputs
//HEX's: 7 bit, This module drives the HEX's to display the winner
//
//The purpose of this module is to take in the scores of each player and display the correct winner on the HEX displays

module victory(curr_turn, score1, score2, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);
	
	input logic [3:0] curr_turn;
	input logic [6:0] score1, score2;
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;

    always_comb begin
        // default: all HEX displays off
        HEX0 = 7'b1111111;
        HEX1 = 7'b1111111;
        HEX2 = 7'b1111111;
        HEX3 = 7'b1111111;
        HEX4 = 7'b1111111;
        HEX5 = 7'b1111111;

        // only display winner after turn 12
        if (curr_turn == 4'd12) begin

            // Player 1 busts, so Player 2 wins
            if (score1 > 7'd21) begin
                HEX5 = 7'b0001100; // P
                HEX4 = 7'b0100100; // 2
                HEX3 = 7'b1111111; // blank

                HEX2 = 7'b0100001; // d
                HEX1 = 7'b1100011; // U
                HEX0 = 7'b0000011; // b
            end

            // Player 2 busts, so Player 1 wins
            else if (score2 > 7'd21) begin
                HEX5 = 7'b0001100; // P
                HEX4 = 7'b1111001; // 1
                HEX3 = 7'b1111111; // blank

                HEX2 = 7'b0100001; // d
                HEX1 = 7'b1100011; // U
                HEX0 = 7'b0000011; // b
            end

            // Otherwise, higher score wins
            else if (score1 > score2) begin
                HEX5 = 7'b0001100; // P
                HEX4 = 7'b1111001; // 1
                HEX3 = 7'b1111111; // blank

                HEX2 = 7'b0100001; // d
                HEX1 = 7'b1100011; // U
                HEX0 = 7'b0000011; // b
            end

            // Otherwise Player 2 wins
            else begin
                HEX5 = 7'b0001100; // P
                HEX4 = 7'b0100100; // 2
                HEX3 = 7'b1111111; // blank

                HEX2 = 7'b0100001; // d
                HEX1 = 7'b1100011; // U
                HEX0 = 7'b0000011; // b
            end
        end
    end

endmodule
