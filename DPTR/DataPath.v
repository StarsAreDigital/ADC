module DataPath (input clk);
    wire [5:0] OP;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [4:0] RD;
    wire [4:0] Shamt;
    wire [5:0] funct;

    wire [31:0] C1, C2, C3, C5, C6;
    wire [3:0] C4;
    wire MemToReg, MemToRead, MemToWrite, RegWrite;
    wire [1:0] ALUOp;

    // Fetch cycle
    wire [31:0] instr;
    wire [31:0] instr_addr;
    wire [31:0] next_instr_addr;
    InstructionMemory im(.address_i(instr_addr), .instruction_o(instr));
    PC pc(.clk_i(clk), .next_i(next_instr_addr), .pc_o(instr_addr));
    PCIncrement pc_inc(.pc_i(instr_addr), .pc_o(next_instr_addr));

    assign {OP, RS, RT, RD, Shamt, funct} = instr;

    Control ctrl(.ctrl(OP), .MemToReg(MemToReg), .MemToRead(MemToRead), .MemToWrite(MemToWrite), .ALUOp(ALUOp), .RegWrite(RegWrite));
    ALU_Control alu_ctrl(.ALUOp(ALUOp), .funct(funct), .sel(C4));
    ALU alu(.A(C2), .B(C1), .op(C4), .R(C3), .ZF(TR_ZF));
    BR reg_bank(.RA1(RS), .RA2(RT), .WA(RD), .DW(C6), .WE(RegWrite), .DR1(C2), .DR2(C1));
    RAM ram(.R(MemToRead), .W(MemToWrite), .address(C3), .data_in(C1), .data_out(C5));
    MUX mux(.in0(C3), .in1(C5), .sel(MemToReg), .out(C6));

endmodule
