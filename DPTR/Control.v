module Control (
	input [6:0] ctrl,
	output reg MemToReg,
	output reg MemToRead,
	output reg MemToWrite,
	output reg [1:0] ALUOp,
	output reg RegWrite
);
	always @(*) begin
		case (ctrl)
			6'b000000: begin // Tipo R
				MemToReg = 1'b0;
				MemToRead = 1'b0;
				MemToWrite = 1'b0;
				ALUOp = 2'b10;
				RegWrite = 1'b1;
			end
			default: begin
				
			end
		endcase
	end
endmodule
