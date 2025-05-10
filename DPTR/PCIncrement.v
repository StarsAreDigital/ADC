module PCIncrement (
    input [31:0] pc_i,
    output [31:0] pc_o
);
    assign pc_o = pc_i + 4;
endmodule
