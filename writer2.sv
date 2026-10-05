// Richard Nadolny & Jackson Price
//Inputs
//card: 6-bit, This is the address of the card
//clock: 1-bit, Controls the timing of the module
//reset: 1-bit, Sets the module back to a base state when turned on
//curr_turn: 4-bit, This is a turn tracker that maxes out at 12 because each player gets at max 6 turns.
//card_recived: 1-bit, Signal to represent that a card was recived 
//Outputs
// x & y: 11-bit, The coordinate of where we are drawing at any given time.
//color: 1-bit, represents if the pixel drawn should be black or white
//
//This modules purpose is to tell the VGA buffer what to draw based on the cards pixel data from the ROMS



module writer2(card, clock, reset, x, y, color, card_recieved, curr_turn);
	input  logic [5:0]  card;
	input  logic [3:0]  curr_turn;
	output logic [10:0] x, y;
	output logic        color;
	input  logic        clock, reset, card_recieved;

	// Card dimensions — must match MIF DEPTH = CARD_W * CARD_H
	localparam CARD_W   = 7'd100;
	localparam CARD_H   = 7'd100;
	localparam CARD_PIX = 14'd10000;  // 100 * 100


	// Card slot origin (top-left corner of each card position)

	logic [10:0] x0, y0;

	always_comb begin
		x0 = 11'd20;
		y0 = 11'd280;
		case (curr_turn)
			4'd0:  begin x0 = 11'd20;  y0 = 11'd280; end
			4'd1:  begin x0 = 11'd140; y0 = 11'd280; end
			4'd2:  begin x0 = 11'd20;  y0 = 11'd140; end
			4'd3:  begin x0 = 11'd140; y0 = 11'd140; end
			4'd4:  begin x0 = 11'd20;  y0 = 11'd20;  end
			4'd5:  begin x0 = 11'd140; y0 = 11'd20;  end
			4'd6:  begin x0 = 11'd380; y0 = 11'd280; end
			4'd7:  begin x0 = 11'd500; y0 = 11'd280; end
			4'd8:  begin x0 = 11'd380; y0 = 11'd140; end
			4'd9:  begin x0 = 11'd500; y0 = 11'd140; end
			4'd10: begin x0 = 11'd380; y0 = 11'd20;  end
			4'd11: begin x0 = 11'd500; y0 = 11'd20;  end
			default: begin x0 = 11'd0; y0 = 11'd0;   end
		endcase
	end

	// 2D pixel counter: col (0..CARD_W-1), row (0..CARD_H-1)

	logic [6:0]  col;        // 0-99
	logic [6:0]  row;        // 0-99
	logic [13:0] pixel_count; // col + row*CARD_W, used as ROM address
	logic drawing;

    logic clearing;
    logic [9:0] clear_x;
    logic [8:0] clear_y;
    logic [10:0] card_x, card_y;
    logic card_color;
    
    assign drawing = (row < CARD_H);
    assign card_x = x0 + {4'd0, col};
    assign card_y = y0 + {4'd0, row};
    assign x = clearing ? {1'b0, clear_x} : card_x;
    assign y = clearing ? {2'b0, clear_y} : card_y;
    assign pixel_count = {7'd0, row} * 14'd100 + {7'd0, col};


    always_ff @(posedge clock) begin
    	if (reset) begin
    		clearing <= 1'b1;
    		clear_x <= 10'd0;
    		clear_y <= 9'd0;
    		col <= 7'd0;
    		row <= 7'd0;
    	end else if (clearing) begin
    		if (clear_x == 10'd639) begin
    			clear_x <= 10'd0;
    			if (clear_y == 9'd479) begin
    				clear_y <= 9'd0;
    				clearing <= 1'b0;
    			end else begin
    				clear_y <= clear_y + 9'd1;
    			end
    		end else begin
    			clear_x <= clear_x + 10'd1;
    		end
    	end else if (card_recieved) begin
    		col <= 7'd0;
    		row <= 7'd0;
    	end else if (drawing) begin
    		if (col == CARD_W - 7'd1) begin
    			col <= 7'd0;
    			row <= row + 7'd1;
    		end else begin
    			col <= col + 7'd1;
    		end
    	end
    end

	// Card ROMs — all addressed by pixel_count (14-bit)
	logic QAH, Q2H, Q3H, Q4H, Q5H, Q6H, Q7H, Q8H, Q9H, QTH, QJH, QQH, QKH;
	logic QAD, Q2D, Q3D, Q4D, Q5D, Q6D, Q7D, Q8D, Q9D, QTD, QJD, QQD, QKD;
	logic QAS, Q2S, Q3S, Q4S, Q5S, Q6S, Q7S, Q8S, Q9S, QTS, QJS, QQS, QKS;
	logic QAC, Q2C, Q3C, Q4C, Q5C, Q6C, Q7C, Q8C, Q9C, QTC, QJC, QQC, QKC;
	logic QB;

	AH_ROM #(.MIF_FILE("AH.mif")) RAH(.address(pixel_count), .clock, .q(QAH));
	AH_ROM #(.MIF_FILE("2H.mif")) R2H(.address(pixel_count), .clock, .q(Q2H));
	AH_ROM #(.MIF_FILE("3H.mif")) R3H(.address(pixel_count), .clock, .q(Q3H));
	AH_ROM #(.MIF_FILE("4H.mif")) R4H(.address(pixel_count), .clock, .q(Q4H));
	AH_ROM #(.MIF_FILE("5H.mif")) R5H(.address(pixel_count), .clock, .q(Q5H));
	AH_ROM #(.MIF_FILE("6H.mif")) R6H(.address(pixel_count), .clock, .q(Q6H));
	AH_ROM #(.MIF_FILE("7H.mif")) R7H(.address(pixel_count), .clock, .q(Q7H));
	AH_ROM #(.MIF_FILE("8H.mif")) R8H(.address(pixel_count), .clock, .q(Q8H));
	AH_ROM #(.MIF_FILE("9H.mif")) R9H(.address(pixel_count), .clock, .q(Q9H));
	AH_ROM #(.MIF_FILE("TH.mif")) RTH(.address(pixel_count), .clock, .q(QTH));
	AH_ROM #(.MIF_FILE("JH.mif")) RJH(.address(pixel_count), .clock, .q(QJH));
	AH_ROM #(.MIF_FILE("QH.mif")) RQH(.address(pixel_count), .clock, .q(QQH));
	AH_ROM #(.MIF_FILE("KH.mif")) RKH(.address(pixel_count), .clock, .q(QKH));

	AH_ROM #(.MIF_FILE("AD.mif")) RAD(.address(pixel_count), .clock, .q(QAD));
	AH_ROM #(.MIF_FILE("2D.mif")) R2D(.address(pixel_count), .clock, .q(Q2D));
	AH_ROM #(.MIF_FILE("3D.mif")) R3D(.address(pixel_count), .clock, .q(Q3D));
	AH_ROM #(.MIF_FILE("4D.mif")) R4D(.address(pixel_count), .clock, .q(Q4D));
	AH_ROM #(.MIF_FILE("5D.mif")) R5D(.address(pixel_count), .clock, .q(Q5D));
	AH_ROM #(.MIF_FILE("6D.mif")) R6D(.address(pixel_count), .clock, .q(Q6D));
	AH_ROM #(.MIF_FILE("7D.mif")) R7D(.address(pixel_count), .clock, .q(Q7D));
	AH_ROM #(.MIF_FILE("8D.mif")) R8D(.address(pixel_count), .clock, .q(Q8D));
	AH_ROM #(.MIF_FILE("9D.mif")) R9D(.address(pixel_count), .clock, .q(Q9D));
	AH_ROM #(.MIF_FILE("TD.mif")) RTD(.address(pixel_count), .clock, .q(QTD));
	AH_ROM #(.MIF_FILE("JD.mif")) RJD(.address(pixel_count), .clock, .q(QJD));
	AH_ROM #(.MIF_FILE("QD.mif")) RQD(.address(pixel_count), .clock, .q(QQD));
	AH_ROM #(.MIF_FILE("KD.mif")) RKD(.address(pixel_count), .clock, .q(QKD));

	AH_ROM #(.MIF_FILE("AS.mif")) RAS(.address(pixel_count), .clock, .q(QAS));
	AH_ROM #(.MIF_FILE("2S.mif")) R2S(.address(pixel_count), .clock, .q(Q2S));
	AH_ROM #(.MIF_FILE("3S.mif")) R3S(.address(pixel_count), .clock, .q(Q3S));
	AH_ROM #(.MIF_FILE("4S.mif")) R4S(.address(pixel_count), .clock, .q(Q4S));
	AH_ROM #(.MIF_FILE("5S.mif")) R5S(.address(pixel_count), .clock, .q(Q5S));
	AH_ROM #(.MIF_FILE("6S.mif")) R6S(.address(pixel_count), .clock, .q(Q6S));
	AH_ROM #(.MIF_FILE("7S.mif")) R7S(.address(pixel_count), .clock, .q(Q7S));
	AH_ROM #(.MIF_FILE("8S.mif")) R8S(.address(pixel_count), .clock, .q(Q8S));
	AH_ROM #(.MIF_FILE("9S.mif")) R9S(.address(pixel_count), .clock, .q(Q9S));
	AH_ROM #(.MIF_FILE("TS.mif")) RTS(.address(pixel_count), .clock, .q(QTS));
	AH_ROM #(.MIF_FILE("JS.mif")) RJS(.address(pixel_count), .clock, .q(QJS));
	AH_ROM #(.MIF_FILE("QS.mif")) RQS(.address(pixel_count), .clock, .q(QQS));
	AH_ROM #(.MIF_FILE("KS.mif")) RKS(.address(pixel_count), .clock, .q(QKS));

	AH_ROM #(.MIF_FILE("AC.mif")) RAC(.address(pixel_count), .clock, .q(QAC));
	AH_ROM #(.MIF_FILE("2C.mif")) R2C(.address(pixel_count), .clock, .q(Q2C));
	AH_ROM #(.MIF_FILE("3C.mif")) R3C(.address(pixel_count), .clock, .q(Q3C));
	AH_ROM #(.MIF_FILE("4C.mif")) R4C(.address(pixel_count), .clock, .q(Q4C));
	AH_ROM #(.MIF_FILE("5C.mif")) R5C(.address(pixel_count), .clock, .q(Q5C));
	AH_ROM #(.MIF_FILE("6C.mif")) R6C(.address(pixel_count), .clock, .q(Q6C));
	AH_ROM #(.MIF_FILE("7C.mif")) R7C(.address(pixel_count), .clock, .q(Q7C));
	AH_ROM #(.MIF_FILE("8C.mif")) R8C(.address(pixel_count), .clock, .q(Q8C));
	AH_ROM #(.MIF_FILE("9C.mif")) R9C(.address(pixel_count), .clock, .q(Q9C));
	AH_ROM #(.MIF_FILE("TC.mif")) RTC(.address(pixel_count), .clock, .q(QTC));
	AH_ROM #(.MIF_FILE("JC.mif")) RJC(.address(pixel_count), .clock, .q(QJC));
	AH_ROM #(.MIF_FILE("QC.mif")) RQC(.address(pixel_count), .clock, .q(QQC));
	AH_ROM #(.MIF_FILE("KC.mif")) RKC(.address(pixel_count), .clock, .q(QKC));

	AH_ROM #(.MIF_FILE("BLANK.mif")) RB(.address(pixel_count), .clock, .q(QB));

	// -------------------------------------------------------
	// Color mux
	// -------------------------------------------------------
	always_comb begin
		color = clearing ? 1'b0 : QB; // default = blank
		case (card)
			6'd0:  color = QAH;
			6'd1:  color = Q2H;
			6'd2:  color = Q3H;
			6'd3:  color = Q4H;
			6'd4:  color = Q5H;
			6'd5:  color = Q6H;
			6'd6:  color = Q7H;
			6'd7:  color = Q8H;
			6'd8:  color = Q9H;
			6'd9:  color = QTH;
			6'd10: color = QJH;
			6'd11: color = QQH;
			6'd12: color = QKH;

			6'd13: color = QAD;
			6'd14: color = Q2D;
			6'd15: color = Q3D;
			6'd16: color = Q4D;
			6'd17: color = Q5D;
			6'd18: color = Q6D;
			6'd19: color = Q7D;
			6'd20: color = Q8D;
			6'd21: color = Q9D;
			6'd22: color = QTD;
			6'd23: color = QJD;
			6'd24: color = QQD;
			6'd25: color = QKD;

			6'd26: color = QAS;
			6'd27: color = Q2S;
			6'd28: color = Q3S;
			6'd29: color = Q4S;
			6'd30: color = Q5S;
			6'd31: color = Q6S;
			6'd32: color = Q7S;
			6'd33: color = Q8S;
			6'd34: color = Q9S;
			6'd35: color = QTS;
			6'd36: color = QJS;
			6'd37: color = QQS;
			6'd38: color = QKS;

			6'd39: color = QAC;
			6'd40: color = Q2C;
			6'd41: color = Q3C;
			6'd42: color = Q4C;
			6'd43: color = Q5C;
			6'd44: color = Q6C;
			6'd45: color = Q7C;
			6'd46: color = Q8C;
			6'd47: color = Q9C;
			6'd48: color = QTC;
			6'd49: color = QJC;
			6'd50: color = QQC;
			6'd51: color = QKC;

			6'd52: color = QB;
			default: color = QB;
		endcase
		if (clearing)
	    color = 1'b0;
	end

endmodule
