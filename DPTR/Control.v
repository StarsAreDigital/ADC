module Control (
	input [5:0] ctrl_i,
	input [5:0] funct_i,
	input rotation_i,
	output reg regDst_o,
	output reg [1:0] branchType_o,
	output reg jump_o,
	output reg memToRead_o,
	output reg memToReg_o,
	output reg [3:0] aluOp_o,
	output reg memToWrite_o,
	output reg aluSrcA_o,
	output reg aluSrcB_o,
	output reg regWrite_o
);
	initial branchType_o = 2'b00;
	initial jump_o = 1'b0;
	always @(*) begin
		case (ctrl_i)
			6'b000000: begin // Tipo R
				jump_o = 1'b0;
				regDst_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				case (funct_i)
					6'b00000: begin // sll
						aluSrcA_o = 1'b1;
						aluSrcB_o = 1'b0;
						aluOp_o = 4'b1000;
					end
					6'b00010: begin
						aluSrcA_o = 1'b1;
						aluSrcB_o = 1'b0;
						if (rotation_i) begin // rotr
							aluOp_o = 4'b1011;
						end else begin // srl
							aluOp_o = 4'b1001;
						end
					end
					default: begin
						aluSrcA_o = 1'b0;
						aluSrcB_o = 1'b0;
						aluOp_o = 4'b0010;
					end
				endcase
			end
			6'b001000: begin // addi
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0011;
			end
			6'b001100: begin // andi
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0100;
			end
			6'b001101: begin // ori
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0101;
			end
			6'b001010: begin // slti
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0110;
			end
			6'b001110: begin // xori
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				memToReg_o = 1'b0;
				regWrite_o = 1'b1;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0111;
			end
			6'b100011: begin // lw
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				memToReg_o = 1'b1;
				regWrite_o = 1'b1;
				memToRead_o = 1'b1;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0000;
			end
			6'b101011: begin // sw
				jump_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b1;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b1;
				branchType_o = 2'b00;
				aluOp_o = 4'b0000;
			end
			6'b000100: begin // beq
				jump_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b01;
				aluOp_o = 4'b0001;
			end
			6'b000101: begin // bne
				jump_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b10;
				aluOp_o = 4'b0001;
			end
			6'b000111: begin // bgtz
				jump_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b11;
				aluOp_o = 4'b0001;
			end
			6'b000010: begin // j
				jump_o = 1'b1;
				branchType_o = 2'b00;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				memToReg_o = 1'b0;
			end
			default: begin
				jump_o = 1'b0;
				regDst_o = 1'b0;
				aluSrcA_o = 1'b0;
				aluSrcB_o = 1'b0;
				memToReg_o = 1'b0;
				regWrite_o = 1'b0;
				memToRead_o = 1'b0;
				memToWrite_o = 1'b0;
				branchType_o = 2'b00;
				aluOp_o = 4'b0000;
			end
		endcase
	end
endmodule
