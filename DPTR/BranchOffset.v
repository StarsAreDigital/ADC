module BranchOffset (
    input [31:0] pc_i,
    input [31:0] offset_i,
    output [31:0] pc_o
);
    assign pc_o = pc_i + (offset_i << 2);
endmodule