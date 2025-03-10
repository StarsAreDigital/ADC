module RAM (
	input [3:0] dir,
	input EN,
	input [31:0] data_in,
	output reg [31:0] data_out
);
	reg [31:0] mem [0:15];
	
	always @(*) begin
		if (EN) begin
			mem[dir] = data_in;
		end
		else begin
			data_out = mem[dir];
		end
	end
endmodule
