module Registers (
	input [4:0] readAddr1_i,
	input [4:0] readAddr2_i,
	input [4:0] writeAddr_i,
	input [31:0] dataWrite_i,
	input writeEnable_i,
	output reg [31:0] dataRead1_o,
	output reg [31:0] dataRead2_o
);
	reg [31:0] memory [0:31];
	
	initial memory[0] = 32'b0;
	always @(*) begin
		if (writeEnable_i && writeAddr_i != 5'b0) begin
			memory[writeAddr_i] = dataWrite_i;	
		end
		dataRead1_o = memory[readAddr1_i];
		dataRead2_o = memory[readAddr2_i];
	end
endmodule

