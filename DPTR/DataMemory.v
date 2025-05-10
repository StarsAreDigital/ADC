module DataMemory (
	input readEnable_i,
	input writeEnable_i,
    input [31:0] address_i,
	input [31:0] dataWrite_i,
	output reg [31:0] dataRead_o
);
    reg [7:0] memory [0:1023];

	always @(*) begin
		if (writeEnable_i) begin 
			memory[address_i] = dataWrite_i[31:24];
			memory[address_i + 1] = dataWrite_i[23:16];
			memory[address_i + 2] = dataWrite_i[15:8];
			memory[address_i + 3] = dataWrite_i[7:0];
		end
		if (readEnable_i) begin 
			dataRead_o = {
                memory[address_i],
                memory[address_i + 1],
                memory[address_i + 2],
                memory[address_i + 3]
			};
		end
	end
endmodule
