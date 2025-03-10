module ROM (
	input [3:0] dir1,
	input [3:0] dir2,
	output reg [31:0] data1,
	output reg [31:0] data2
);
	reg [31:0] mem [0:15];
	
	initial begin
		$readmemb("data", mem);
	end
	
	always @(*) begin
		data1 = mem[dir1];
		data2 = mem[dir2];
	end
endmodule

