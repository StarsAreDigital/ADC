`timescale 1ns/1ns
module DPTR_TB ();
    reg [31:0] instr;
    wire TR_ZF;

    DPTR dptr(.instr(instr), .TR_ZF(TR_ZF));

    initial begin
        $readmemb("data", dptr.reg_bank.mem);

        instr = {6'b000000, 5'd15, 5'd02, 5'd03, 5'b00000, 6'b100010};
        #100;
        instr = {6'b000000, 5'd00, 5'd04, 5'd01, 5'b00000, 6'b100010};
        #100;
        instr = {6'b000000, 5'd20, 5'd06, 5'd12, 5'b00000, 6'b100000};
        #100;
        instr = {6'b000000, 5'd10, 5'd11, 5'd00, 5'b00000, 6'b100000};
        #100;
    end
endmodule