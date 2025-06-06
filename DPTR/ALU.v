module ALU (
	input [31:0] a_i,
	input [31:0] b_i,
	input [3:0] op_i,
	output reg [31:0] res_o,
	output zf_o,
	output sign_o
);
	assign zf_o = res_o == 32'b0;
	assign sign_o = res_o[31];

	always @(*)
	begin
		case (op_i)
			4'b0000: res_o = a_i & b_i;
			4'b0001: res_o = a_i | b_i;
			4'b0010: res_o = a_i + b_i;
			4'b0011: res_o = a_i ^ b_i;
			4'b0100: res_o = b_i << a_i;
			4'b0101: res_o = b_i >> a_i;
			4'b0110: res_o = a_i - b_i;
			4'b0111: res_o = a_i < b_i ? 32'b1 : 32'b0;
			4'b1001: res_o = (b_i >> a_i) | (b_i << (32'd32 - a_i)); // rotate right
			4'b1100: res_o = ~(a_i | b_i);
			default: res_o = 32'b0;
		endcase
	end
endmodule
