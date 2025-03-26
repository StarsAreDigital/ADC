module Buffer1 (
	input CLK,

	input i_R,
	input i_W,
	input i_demux,
	input [3:0] i_op,
	input i_WE,
	input [31:0] i_DR1,
	input [31:0] i_DR2,
	input [4:0] i_WA,
	output o_R,
	output o_W,
	output o_demux,
	output [3:0] o_op,
	output o_WE,
	output [31:0] o_DR1,
	output [31:0] o_DR2,
	output [4:0] o_WA
);
	wire [76:0] i_signal;
	reg [76:0] o_signal;
	
	assign i_signal = {i_R, i_W, i_demux, i_op, i_WE, i_DR1, i_DR2, i_WA};
	assign {o_R, o_W, o_demux, o_op, o_WE, o_DR1, o_DR2, o_WA} = o_signal;

	always @(posedge CLK) o_signal = i_signal;

endmodule

module Buffer2 (
	input CLK,

	input i_R,
	input i_W,
	input i_WE,
	input [31:0] i_demux,
	input [31:0] i_data,
	input [31:0] i_alu,
	input [4:0] i_WA,
	output o_R,
	output o_W,
	output o_WE,
	output [31:0] o_demux,
	output [31:0] o_data,
	output [31:0] o_alu,
	output [4:0] o_WA
);
	wire [103:0] i_signal;
	reg [103:0] o_signal;
	
	assign i_signal = {i_R, i_W, i_WE, i_demux, i_data, i_alu, i_WA};
	assign {o_R, o_W, o_WE, o_demux, o_data, o_alu, o_WA} = o_signal;

	always @(posedge CLK) o_signal = i_signal;

endmodule

