module SignExtend (
    input [15:0] data_i,
    output reg [31:0] data_o
);
    always @(*) begin
        if (data_i[15] == 1'b1) begin
            data_o = {16'b1111111111111111, data_i};
        end else begin
            data_o = {16'b0000000000000000, data_i};
        end
    end
endmodule