module JERICALLA (
	input [16:0] in,
	output [31:0] out,
	output ZF
);
	wire EN;
	wire [3:0] dir1;
	wire [3:0] dir2;
	wire [3:0] op;
	wire [3:0] dirR;
	
	wire [31:0] w1;
	wire [31:0] w2;
	wire [31:0] w3;
	
	assign EN = in[16];
	assign dir1 = in[15:12];
	assign dir2 = in[11:8];
	assign op = in[7:4];
	assign dirR = in[3:0];
	
	ROM rom(.dir1(dir1), .dir2(dir2), .data1(w1), .data2(w2));
	ALU alu(.A(w1), .B(w2), .op(op), .R(w3), .ZF(ZF));
	RAM ram(.dir(dirR), .EN(EN), .data_in(w3), .data_out(out));
endmodule
