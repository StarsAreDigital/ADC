module DataPath (input clk_i);
    wire [5:0] OP;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [4:0] RD;
    wire [4:0] Shamt;
    wire [5:0] funct;

    wire [31:0] C1, C2, C3, C5, C6;
    wire [3:0] C4;

    // Control signals
    wire MemToReg, MemToRead, MemToWrite, RegWrite, regDst, branch, aluSrc;
    wire [1:0] ALUOp;

    // Fetch cycle
    wire mux4_sel, zf;
    wire [31:0] instr;
    wire [31:0] instr_addr;
    wire [31:0] next_instr_addr;
    wire [31:0] next_pc;

    
    assign mux4_sel = branch & zf;
    assign {OP, RS, RT, RD, Shamt, funct} = instr;

    // Fetch cycle
    InstructionMemory im(.address_i(instr_addr), .instruction_o(instr));
    PC pc(.clk_i(clk_i), .next_i(next_pc), .pc_o(instr_addr));
    PCIncrement pc_inc(.pc_i(instr_addr), .pc_o(next_instr_addr));

    wire [31:0] se_out;
    wire [31:0] bo_out;
    wire [31:0] alu_b_in;
    wire [4:0] writeAddrReg;

    Control ctrl(
        .ctrl_i(OP), 
	    .regDst_o(regDst),
	    .branch_o(branch),
	    .memToRead_o(MemToRead),
	    .memToReg_o(MemToReg),
	    .aluOp_o(ALUOp),
	    .memToWrite_o(MemToWrite),
	    .aluSrc_o(aluSrc),
	    .regWrite_o(RegWrite)
    );
    ALUControl alu_ctrl(.aluOp_i(ALUOp), .funct_i(funct), .sel_o(C4));
    ALU alu(.a_i(C2), .b_i(alu_b_in), .op_i(C4), .res_o(C3), .zf_o(zf));
    Registers reg_bank(
        .readAddr1_i(RS),
        .readAddr2_i(RT),
        .writeAddr_i(writeAddrReg),
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
    SignExtend se(.data_i(instr[15:0]), .data_o(se_out));
    BranchOffset bo(.pc_i(next_instr_addr), .offset_i(se_out), .pc_o(bo_out));
    MUX mux1(.data0_i(C3), .data1_i(C5), .sel_i(MemToReg), .data_o(C6));
    MUX #(5) mux2 (.data0_i(RT), .data1_i(RD), .sel_i(regDst), .data_o(writeAddrReg));
    MUX mux3(.data0_i(C1), .data1_i(se_out), .sel_i(aluSrc), .data_o(alu_b_in));
    MUX mux4(.data0_i(next_instr_addr), .data1_i(bo_out), .sel_i(mux4_sel), .data_o(next_pc));

endmodule
