module Control (
	input [5:0] ctrl_i,
	output reg regDst_o,
	output reg branch_o,
	output reg memToRead_o,
	output reg memToReg_o,
	output reg [3:0] aluOp_o,
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
				aluOp_o = 4'b0010;
			end
			6'b001000: begin // addi
				regDst_o = 1'b0;
				aluSrc_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 4'b0011;
			end
			6'b001100: begin // andi
				regDst_o = 1'b0;
				aluSrc_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 4'b0100;
			end
			6'b001101: begin // ori
				regDst_o = 1'b0;
				aluSrc_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 4'b0101;
			end
			6'b001010: begin // slti
				regDst_o = 1'b0;
				aluSrc_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 4'b0110;
			end
			6'b100011: begin // lw
				regDst_o = 1'b0;
				aluSrc_o = 1'b1;
				memToReg_o = 1'b1;
				regWrite_o = 1'b1;
				memToRead_o = 1'b1;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 4'b0000;
			end
			6'b101011: begin // sw
				aluSrc_o = 1'b1;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b1;
				branch_o = 1'b0;
				aluOp_o = 4'b0000;
			end
			6'b000100: begin // beq
				aluSrc_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b1;
				aluOp_o = 4'b0001;
			end
			default: begin
				regDst_o = 1'b0;
				aluSrc_o = 1'b0;
				memToReg_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branch_o = 1'b0;
				aluOp_o = 4'b0000;
			end
		endcase
	end
endmodule
