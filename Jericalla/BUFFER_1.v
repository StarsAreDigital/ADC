module BUFFER_1 (
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
	wire [76:0] i_aaaa;
	reg [76:0] o_aaaa;
	
	assign i_aaaa = {i_R, i_W, i_demux, i_op, i_WE, i_DR1, i_DR2, i_WA};
	assign {o_R, o_W, o_demux, o_op, o_WE, o_DR1, o_DR2, o_WA} = o_aaaa;

	always @(posedge CLK) begin
		o_aaaa = i_aaaa;
	end

endmodule
