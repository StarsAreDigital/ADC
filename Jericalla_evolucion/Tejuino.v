module Tejuino (
	input clk,

	input [16:0] instr,
	output [31:0] out
);
	wire [1:0] opcode;
	wire [4:0] RD, RS1, RS2;
	assign {opcode, RD, RS1, RS2} = instr;

	// Salidas alu
	wire alu_ZF;
	wire [31:0] alu_R;

	// Salidas banco regs
	wire [31:0] br_DR1, br_DR2;

	// Salidas control
	wire ctrl_R, ctrl_W, ctrl_demux, ctrl_WE;
	wire [3:0] ctrl_op;

	// Salidas demux
	wire [31:0] dem_out0, dem_out1;

	// Salidas buffer1
	wire b1_R, b1_W, b1_demux, b1_WE;
	wire [3:0] b1_op;
	wire [31:0] b1_DR1, b1_DR2;
	wire [4:0] b1_WA;

	// Salidas buffer2
	wire b2_R, b2_W, b2_WE;
	wire [31:0] b2_demux, b2_data, b2_alu;
	wire [4:0] b2_WA;

	ALU alu(.A(dem_out0), .B(b1_DR2), .op(b1_op), .R(alu_R), .ZF(alu_ZF));
	BR regs(.RA1(RS1), .RA2(RS2), .WA(b2_WA), .DW(b2_alu), .WE(b2_WE), .DR1(br_DR1), .DR2(br_DR2));
	RAM ram(.R(b2_R), .W(b2_W), .address(b2_demux), .data_in(b2_data), .data_out(out));
	Control ctrl(.ctrl(opcode), .R(ctrl_R), .W(ctrl_W), .demux(ctrl_demux), .op(ctrl_op), .WE(ctrl_WE));
	Demux dem(.select(b1_demux), .in(b1_DR1), .out_0(dem_out0), .out_1(dem_out1));
	Buffer1 buff1(
		.CLK(clk),
		.i_R(ctrl_R),
		.i_W(ctrl_W),
		.i_demux(ctrl_demux),
		.i_op(ctrl_op),
		.i_WE(ctrl_WE),
		.i_DR1(br_DR1),
		.i_DR2(br_DR2),
		.i_WA(RD),
		.o_R(b1_R),
		.o_W(b1_W),
		.o_demux(b1_demux),
		.o_op(b1_op),
		.o_WE(b1_WE),
		.o_DR1(b1_DR1),
		.o_DR2(b1_DR2),
		.o_WA(b1_WA)
	);
	Buffer2 buff2(
		.CLK(clk),
		.i_R(b1_R),
		.i_W(b1_W),
		.i_WE(b1_WE),
		.i_demux(dem_out1),
		.i_data(b1_DR2),
		.i_alu(alu_R),
		.i_WA(b1_WA),
		.o_R(b2_R),
		.o_W(b2_W),
		.o_WE(b2_WE),
		.o_demux(b2_demux),
		.o_data(b2_data),
		.o_alu(b2_alu),
		.o_WA(b2_WA)
	);

endmodule