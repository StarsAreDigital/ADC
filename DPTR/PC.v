module PC (
    input clk_i,
    input [31:0] next_i,
    output reg [31:0] pc_o
);
    initial begin
        pc_o = 32'b0;
    end

    always @(posedge clk_i) begin
        pc_o = next_i;
    end

endmodule
