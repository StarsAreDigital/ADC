`timescale 1ns/1ns
module JERICALLA_TB ();
	reg [16:0] in;
	wire [31:0] out;
	wire ZF;
	
	JERICALLA mod(.in(in), .out(out), .ZF(ZF));
	
	initial begin
		in = {4'b0011, 4'b0010, 4'b0100, 4'b0110, 1'b1};
		#100;
		in = {4'b0011, 4'bxxxx, 4'bxxxx, 4'bxxxx, 1'b0};
		#100;
		
		in = {4'b0100, 4'b0000, 4'b0101, 4'b0111, 1'b1};
		#100;
		in = {4'b0100, 4'bxxxx, 4'bxxxx, 4'bxxxx, 1'b0};
		#100;
		
		in = {4'b0101, 4'b0001, 4'b1000, 4'b1010, 1'b1};
		#100;
		in = {4'b0101, 4'bxxxx, 4'bxxxx, 4'bxxxx, 1'b0};
		#100;
		
		in = {4'b0110, 4'b0110, 4'b1001, 4'b1011, 1'b1};
		#100;
		in = {4'b0110, 4'bxxxx, 4'bxxxx, 4'bxxxx, 1'b0};
		#100;
		
		in = {4'b0111, 4'b0111, 4'b1100, 4'b1110, 1'b1};
		#100;
		in = {4'b0111, 4'bxxxx, 4'bxxxx, 4'bxxxx, 1'b0};
		#100;
		
		in = {4'b1000, 4'b0101, 4'b1101, 4'b1111, 1'b1};
		#100;
		in = {4'b1000, 4'bxxxx, 4'bxxxx, 4'bxxxx, 1'b0};
		#100;
	end
endmodule