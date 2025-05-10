module InstructionMemory (
    input [31:0] address_i,
    output reg [31:0] instruction_o
);
    reg [7:0] memory [0:1023];
    
    always @(*) begin
        if (address_i % 4 == 0) begin
            instruction_o = {
                memory[address_i],
                memory[address_i + 1],
                memory[address_i + 2],
                memory[address_i + 3]
            };
        end else begin
            instruction_o = 32'b0;
        end
    end

endmodule
