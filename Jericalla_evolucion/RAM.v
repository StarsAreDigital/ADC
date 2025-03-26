module RAM (
	input R,
	input W,
	input [4:0] address,
	input [31:0] data_in,
	output reg [31:0] data_out
);
	reg [31:0] mem [0:31];

	always @(*) begin
		if (R) begin
			data_out = mem[address];
		end
		
		if (W) begin
			mem[address] = data_in;
		end
	end
endmodule
