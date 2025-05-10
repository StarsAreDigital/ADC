module DataMemory (
	input readEnable_i,
	input writeEnable_i,
    input [31:0] address_i,
	input [31:0] dataWrite_i,
	output reg [31:0] dataRead_o
);
    reg [31:0] memory [0:1023];

	always @(*) begin
		if (writeEnable_i) memory[address_i] = dataWrite_i;
		if (readEnable_i) dataRead_o = memory[address_i];
	end
endmodule
