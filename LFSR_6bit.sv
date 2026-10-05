// Richard Nadolny & Jackson Price
//Inputs
//clk: 1-bit, Controls the timing of the module
//seed: 6-bits, The puesdo random seed
//reset: 1-bit, when turned on the module is set back to the seed
//req: 1-bit, Signal representing that a card is requested
//Outputs
//out: 6-bit, Outputs a random number which will be a cards address
//
//The purpose of this module is too generate randomness for our cards

module LFSR_6bit(clk, out, seed, reset, req); 

	input logic clk, reset, req;
	input logic[5:0] seed;
	output logic [5:0] out;
	logic in, Q0, Q1, Q2, Q3, Q4, Q5;
	
	xnor sim(in, Q4, Q5); // xnor selector pseudorandom
	
	always_ff @(posedge clk)
		Q0 <= (reset) ? seed[0] : in;
		
	always_ff @(posedge clk)
		Q1 <= (reset) ? seed[1] : Q0;
		
	always_ff @(posedge clk)
		Q2 <= (reset) ? seed[2] : Q1;
		
	always_ff @(posedge clk)
		Q3 <= (reset) ? seed[3] : Q2;
		
	always_ff @(posedge clk)
		Q4 <= (reset) ? seed[4] : Q3;
		
	always_ff @(posedge clk)
		Q5 <= (reset) ? seed[5] : Q4;
		
	always_ff @(posedge clk)
		out <= (req) ? {Q0, Q1, Q2, Q3, Q4, Q5} : out;

endmodule 