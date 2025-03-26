module ALU (
	input [31:0] A,
	input [31:0] B,
	input [3:0] op,
	output reg [31:0] R,
	output reg ZF
);
	
	assign ZF = !R;
	
	always @(*)
	begin
		case (op)
			4'b0000: R = A & B;
			4'b0001: R = A | B;
			4'b0010: R = A + B;
			4'b0110: R = A - B;
			4'b0111: R = A < B ? 32'b1 : 32'b0;
			4'b1100: R = ~(A | B);
			default: R = 32'b0;
		endcase
	end
endmodule
