module MUX (
    input [31:0] data0_i,
    input [31:0] data1_i,
    input sel_i,
    output [31:0] data_o
);
    assign data_o = sel_i ? data1_i : data0_i;
endmodule
