module Control (
	input [1:0] ctrl,
	output reg R,
	output reg W,
	output reg demux,
	output reg [3:0] op,
	output reg WE
);
	always @(*) begin
		case (ctrl)
			2'b00: begin
				R = 1'b0;
				W = 1'b0;
				demux = 1'b0;
				op = 4'b0010;
				WE = 1'b1;
			end
			2'b01: begin
				R = 1'b0;
				W = 1'b0;
				demux = 1'b0;
				op = 4'b0110;
				WE = 1'b1;
			end
			2'b10: begin
				R = 1'b0;
				W = 1'b0;
				demux = 1'b0;
				op = 4'b0111;
				WE = 1'b1;
			end
			2'b11: begin
				R = 1'b0;
				W = 1'b1;
				demux = 1'b1;
				op = 4'b0000;
				WE = 1'b0;
			end
			default: begin
				R = 1'b0;
				W = 1'b0;
				demux = 1'b0;
				op = 4'b1111;
				WE = 1'b0;
			end
		endcase
	end
endmodule
