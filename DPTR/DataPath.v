module DataPath (input clk_i);
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
    PC pc(.clk_i(clk_i), .next_i(next_instr_addr), .pc_o(instr_addr));
    PCIncrement pc_inc(.pc_i(instr_addr), .pc_o(next_instr_addr));

    assign {OP, RS, RT, RD, Shamt, funct} = instr;

    Control ctrl(
        .ctrl_i(OP), 
        .memToReg_o(MemToReg), 
        .memToRead_o(MemToRead), 
        .memToWrite_o(MemToWrite), 
        .aluOp_o(ALUOp), 
        .regWrite_o(RegWrite)
    );
    ALUControl alu_ctrl(.aluOp_i(ALUOp), .funct_i(funct), .sel_o(C4));
    ALU alu(.a_i(C2), .b_i(C1), .op_i(C4), .res_o(C3), .zf_o(TR_ZF));
    Registers reg_bank(
        .readAddr1_i(RS),
        .readAddr2_i(RT),
        .writeAddr_i(RD),
        .dataWrite_i(C6), 
        .writeEnable_i(RegWrite), 
        .dataRead1_o(C2),
        .dataRead2_o(C1)
    );
    DataMemory ram(
        .readEnable_i(MemToRead),
        .writeEnable_i(MemToWrite), 
        .address_i(C3),
        .dataWrite_i(C1),
        .dataRead_o(C5)
    );
    MUX mux(.data0_i(C3), .data1_i(C5), .sel_i(MemToReg), .data_o(C6));

endmodule
