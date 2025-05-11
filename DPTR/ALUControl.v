module ALUControl (
    input [1:0] aluOp_i,
    input [5:0] funct_i,
    output reg [3:0] sel_o
);
    always @(*) begin
        case (aluOp_i)
            2'b00: sel_o = 4'b0010; // lw, sw
            2'b01: sel_o = 4'b0110; // beq
            2'b10: case (funct_i)   // type r
                6'b100000: sel_o = 4'b0010;
                6'b100010: sel_o = 4'b0110;
                6'b100100: sel_o = 4'b0000;
                6'b100101: sel_o = 4'b0001;
                6'b101010: sel_o = 4'b0111;
                default: sel_o = 4'b0000;
            endcase
            default: sel_o = 4'b0000;
        endcase
    end
endmodule