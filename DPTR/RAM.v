module RAM (
	input R,
	input W,
    input [31:0] address,
	input [31:0] data_in,
	output reg [31:0] data_out
);
    reg [31:0] mem [0:1023];

	always @(*) begin
		if (R) data_out = mem[address];
		if (W) mem[address] = data_in;
	end
endmodule
