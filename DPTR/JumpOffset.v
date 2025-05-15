module JumpOffset (
    input [25:0] jumpAddr_i,
    input [3:0] pcAlign_i,
    output [31:0] jumpAddr_o
);
    assign jumpAddr_o = {pcAlign_i, jumpAddr_i, 2'b00};
endmodule
