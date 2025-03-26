module Demux(
	input select,
	input [31:0] in,
	output [31:0] out_0,
	output [31:0] out_1
);
	assign {out_0, out_1} = (select == 0) ? {in, 32'b0} : {32'b0, in};
endmodule

