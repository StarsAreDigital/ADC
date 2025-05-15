module ALUControl (
    input [3:0] aluOp_i,
    input [5:0] funct_i,
    output reg [3:0] sel_o
);
    always @(*) begin
        case (aluOp_i)
            4'b0000: sel_o = 4'b0010; // lw, sw
            4'b0001: sel_o = 4'b0110; // beq
            4'b0010: case (funct_i)   // type r
                6'b100000: sel_o = 4'b0010; // add
                6'b100010: sel_o = 4'b0110; // sub
                6'b100100: sel_o = 4'b0000; // and
                6'b100101: sel_o = 4'b0001; // or
                6'b101010: sel_o = 4'b0111; // slt
                6'b100110: sel_o = 4'b0011; // xor
                default: sel_o = 4'b0000;
            endcase
            4'b0011: sel_o = 4'b0010; // addi
            4'b0100: sel_o = 4'b0000; // andi
            4'b0101: sel_o = 4'b0001; // ori
            4'b0110: sel_o = 4'b0111; // slti
            4'b0111: sel_o = 4'b0011; // xori
            4'b1000: sel_o = 4'b0100; // sll
            4'b1001: sel_o = 4'b0101; // srl
            4'b1011: sel_o = 4'b1001; // rotr
            default: sel_o = 4'b0000;
        endcase
    end
endmodule