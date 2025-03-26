module BR (
	input [4:0] RA1,
	input [4:0] RA2,
	input [4:0] WA,
	input [31:0] DW,
	input WE,
	output reg [31:0] DR1,
	output reg [31:0] DR2
);
	reg [31:0] mem [0:31];

	initial begin
		$readmemb("datos.txt", mem);
	end

	always @(*) begin
		if (WE) begin
			mem[WA] = DW;
		end
		else begin
			DR1 = mem[RA1];
			DR2 = mem[RA2];
		end
	end
endmodule

