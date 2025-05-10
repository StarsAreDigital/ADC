module PCIncrement (
    input [31:0] pc_i,
    output reg [31:0] pc_o
);
    always @(*) begin
        pc_o = pc_i + 32'b100; // pc <- pc + 4
    end

    initial begin
        pc_o = 32'b0;
    end
endmodule
