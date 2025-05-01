`timescale 1ns/1ns
module DPTR_TB ();
    reg [31:0] instr;
    wire TR_ZF;

    DPTR dptr(.instr(instr), .TR_ZF(TR_ZF));

    initial begin
        dptr.reg_bank.mem[0] = 32'd0;
        dptr.reg_bank.mem[1] = 32'd233;
        dptr.reg_bank.mem[2] = 32'd123;
        dptr.reg_bank.mem[3] = 32'd456;
        dptr.reg_bank.mem[4] = 32'd789;
        dptr.reg_bank.mem[5] = 32'd432;
        dptr.reg_bank.mem[6] = 32'd654;
        dptr.reg_bank.mem[7] = 32'd321;
        dptr.reg_bank.mem[8] = 32'd567;
        dptr.reg_bank.mem[9] = 32'd890;
        
        instr = {6'b000000, 5'd02, 5'd03, 5'd01, 5'b00000, 6'b100000};
        #100; 
        instr = {6'b000000, 5'd01, 5'd04, 5'd02, 5'b00000, 6'b100000};
        #100;
        instr = {6'b000000, 5'd01, 5'd07, 5'd04, 5'b00000, 6'b100010};
        #100;
        instr = {6'b000000, 5'd02, 5'd04, 5'd05, 5'b00000, 6'b100010};
        #100;    
        instr = {6'b000000, 5'd02, 5'd05, 5'd01, 5'b00000, 6'b100101};
        #100;
        instr = {6'b000000, 5'd01, 5'd06, 5'd02, 5'b00000, 6'b100101};
        #100;
        instr = {6'b000000, 5'd02, 5'd07, 5'd01, 5'b00000, 6'b100100};
        #100;
        instr = {6'b000000, 5'd01, 5'd08, 5'd03, 5'b00000, 6'b100100};
        #100;
        instr = {6'b000000, 5'd02, 5'd08, 5'd04, 5'b00000, 6'b101010};
        #100;
        instr = {6'b000000, 5'd01, 5'd09, 5'd08, 5'b00000, 6'b101010};
        #100;
    end
endmodule