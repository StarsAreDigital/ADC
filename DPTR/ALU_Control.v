module ALU_Control (
    input [1:0] ALUOp,
    input [5:0] funct,
    output reg [3:0] sel
);
    always @(*) begin
        case (ALUOp)
            2'b00: sel = 4'b0010;
            2'b01: sel = 4'b0110;
            2'b10: case (funct)
                6'b100000: sel = 4'b0010;
                6'b100010: sel = 4'b0110;
                6'b100100: sel = 4'b0000;
                6'b100101: sel = 4'b0001;
                6'b101010: sel = 4'b0111;
                default: sel = 4'b0000;
            endcase
            default: sel = 4'b0000;
        endcase
    end
endmodule