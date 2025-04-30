`timescale 1ns/1ns
module DPTR_TB ();
    reg [31:0] instr;
    wire TR_ZF;

    DPTR dptr(.instr(instr), .TR_ZF(TR_ZF));

    initial begin
        instr = {6'b000000, 5'd4, 5'd0, 5'd0, 5'b00000, 6'b000000};
        #100;
        instr = {6'b000000, 5'd4, 5'd0, 5'd0, 5'b00000, 6'b000000};
        #100;
        instr = {6'b000000, 5'd4, 5'd0, 5'd0, 5'b00000, 6'b100000};
        #100;
        instr = {6'b000000, 5'd4, 5'd0, 5'd0, 5'b00000, 6'b100000};
        #100;
        instr = {6'b000000, 5'd4, 5'd0, 5'd0, 5'b00000, 6'b100000};
        #100;
    end
endmodule