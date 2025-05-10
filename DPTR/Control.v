module Control (
	input [5:0] ctrl_i,
	output reg regDst_o,
	output reg branch_o,
	output reg memToRead_o,
	output reg memToReg_o,
	output reg [1:0] aluOp_o,
	output reg memToWrite_o,
	output reg aluSrc_o,
	output reg regWrite_o
);
	always @(*) begin
		case (ctrl_i)
			6'b000000: begin // Tipo R
				regDst_o = 1'b1;
				aluSrc_o = 1'b0;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 2'b10;
			end
			6'b100011: begin // lw
				regDst_o = 1'b0;
				aluSrc_o = 1'b1;
				memToReg_o = 1'b1;
				regWrite_o = 1'b1;
				memToRead_o = 1'b1;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 2'b00;
			end
			6'b101011: begin // sw
				aluSrc_o = 1'b1;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b1;
				branch_o = 1'b0;
				aluOp_o = 2'b00;
			end
			6'b000100: begin // beq
				aluSrc_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b1;
				aluOp_o = 2'b01;
			end
		endcase
	end
endmodule
