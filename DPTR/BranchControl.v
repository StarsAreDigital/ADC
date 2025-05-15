module BranchControl (
    input [1:0] branchType_i,
    input zf_i,
    input sign_i,
    output reg branch_o
);
    always @(*) begin
        case (branchType_i)
            2'b00: branch_o = 1'b0; // No branch
            2'b01: branch_o = zf_i; // beq
            2'b10: branch_o = ~zf_i; // bne
            2'b11: branch_o = ~zf_i & ~sign_i; // bgtz
            default: branch_o = 1'b0;
        endcase
    end
endmodule