module DPTR (
    input [31:0] instr
);
    wire [5:0] OP;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [4:0] RD;
    wire [4:0] Shamt;
    wire [5:0] Func;

    assign {OP, RD, RT, RD, Shamt, Func} = instr;

    wire [31:0] C1, C2, C3;
    wire [3:0] C4;
    wire [31:0] C5;
endmodule