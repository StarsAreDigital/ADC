module DataPath (input clk_i);
    /* Fetch stage */
    wire [31:0] instr;
    wire [31:0] instrAddr;
    wire [31:0] pcOut;
    wire [31:0] nextPc;
    InstructionMemory im(.address_i(instrAddr), .instruction_o(instr));
    PC pc(.clk_i(clk_i), .next_i(nextPc), .pc_o(instrAddr));
    PCIncrement pc_inc(.pc_i(instrAddr), .pc_o(pcOut));
    

    /* Fetch/Decode buffer */
    wire [31:0] instrOut;
    wire [31:0] nextInstrAddr;
    FDBuffer fd_buf(
        .clk_i(clk_i),
        .instr_i(instr),
        .nextInstrAddr_i(pcOut),
        .instr_o(instrOut),
        .nextInstrAddr_o(nextInstrAddr)
    );


    /* Decode stage */
    // Instruction segments
    wire [5:0] op;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [4:0] rd;
    wire [4:0] shamt;
    wire [5:0] funct;
    wire [15:0] immediate;
    assign {op, rs, rt, rd, shamt, funct} = instrOut;
    assign immediate = instr[15:0];

    // Control signals
    wire memToReg, memToRead, memToWrite, regWrite, regDst, branch, aluSrc;
    wire [1:0] aluOp;
    Control ctrl(
        .ctrl_i(op), 
	    .regDst_o(regDst),
	    .branch_o(branch),
	    .memToRead_o(memToRead),
	    .memToReg_o(memToReg),
	    .aluOp_o(aluOp),
	    .memToWrite_o(memToWrite),
	    .aluSrc_o(aluSrc),
	    .regWrite_o(regWrite)
    );

    wire [31:0] dataRead1, dataRead2, dataWrite;
    wire [31:0] seOut;
    wire [4:0] writeAddrReg;
    Registers reg_bank(
        .readAddr1_i(rs),
        .readAddr2_i(rt),
        .writeAddr_i(writeAddrReg),
        .dataWrite_i(dataWrite), 
        .writeEnable_i(regWrite), 
        .dataRead1_o(dataRead1),
        .dataRead2_o(dataRead2)
    );
    SignExtend se(.data_i(immediate), .data_o(seOut));


    /* Decode/Execute buffer */
    wire memToRegEx, memToReadEx, memToWriteEx, regWriteEx, regDstEx, branchEx, aluSrcEx;
    wire [1:0] aluOpEx;
    wire [31:0] nextInstrAddrEx, rsDataEx, rtDataEx, signExtendEx;
    wire [4:0] rtAddrEx, rdAddrEx;
    wire [5:0] functEx;

    DEBuffer de_buf(
        .clk_i(clk_i),

        // Input control signals
        .regDst_i(regDst),
        .branch_i(branch),
        .memToRead_i(memToRead),
        .memToReg_i(memToReg),
        .aluOp_i(aluOp),
        .memToWrite_i(memToWrite),
        .aluSrc_i(aluSrc),
        .regWrite_i(regWrite),

        // Input from decode stage
        .nextInstrAddr_o(nextInstrAddr),
        .rsData_i(dataRead1),
        .rtData_i(dataRead2),
        .signExtend_i(seOut),
        .rtAddr_i(rt),
        .rdAddr_i(rd),
        .funct_i(funct),

        // Output control signals
        .regDst_o(regDstEx),
        .branch_o(branchEx),
        .memToRead_o(memToReadEx),
        .memToReg_o(memToRegEx),
        .aluOp_o(aluOpEx),
        .memToWrite_o(memToWriteEx),
        .aluSrc_o(aluSrcEx),
        .regWrite_o(regWriteEx),

        // Output to execute stage
        .nextInstrAddr_o(nextInstrAddrEx),
        .rsData_o(rsDataEx),
        .rtData_o(rtDataEx),
        .signExtend_o(signExtendEx),
        .rtAddr_o(rtaddrEx),
        .rdAddr_o(rdAddrEx),
        .funct_o(functEx)
    );


    /* Execute stage */
    wire [31:0] boOut;
    wire [4:0] writeAddrRegEx;
    wire [31:0] aluB, aluResult;
    wire [1:0] aluSel;
    wire zf;

    MUX #(5) muxRegDst (.data0_i(rtAddrEx), .data1_i(rdAddrEx), .sel_i(regDstEx), .data_o(writeAddrRegEx));
    MUX muxAluSrc(.data0_i(rtDataEx), .data1_i(signExtendEx), .sel_i(aluSrcEx), .data_o(aluB));
    BranchOffset branchOffset(.pc_i(nextInstrAddrEx), .offset_i(signExtendEx), .pc_o(boOut));
    ALUControl aluCtrl(.aluOp_i(aluOpEx), .funct_i(functEx), .sel_o(aluSel));
    ALU alu(.a_i(rsDataEx), .b_i(aluB), .op_i(aluSel), .res_o(aluResult), .zf_o(zf));


    /* Execute/Memory buffer */
    wire branchMem, memToReadMem, memToRegMem, memToWriteMem, regWriteMem, zfMem;
    wire [31:0] branchAddrMem, aluResultMem, rtDataMem;
    wire [4:0] writeAddrRegMem;

    EMBuffer em_buf(
        .clk_i(clk_i),

        // Input control signals
        .branch_i(branchEx),
        .memToRead_i(memToReadEx),
        .memToReg_i(memToRegEx),
        .memToWrite_i(memToWriteEx),
        .regWrite_i(regWriteEx),
        .zf_i(zf),

        // Input from execute stage
        .branchAddr_i(boOut),
        .aluResult_i(aluResult),
        .rtData_i(rtDataEx),
        .writeAddrReg_i(writeAddrRegEx),

        // Output control signals
        .branch_o(branchMem),
        .memToRead_o(memToReadMem),
        .memToReg_o(memToRegMem),
        .memToWrite_o(memToWriteMem),
        .regWrite_o(regWriteMem),
        .zf_o(zfMem),

        // Output to memory stage
        .branchAddr_o(branchAddrMem),
        .aluResult_o(aluResultMem),
        .rtData_o(rtDataMem),
        .writeAddrReg_o(writeAddrRegMem)
    );


    /* Memory access stage */
    wire pcSrc;
    assign pcSrc = branchMem & zfMem;

    DataMemory ram(
        .readEnable_i(memToReadMem),
        .writeEnable_i(memToWriteMem), 
        .address_i(aluResultMem),
        .dataWrite_i(rtDataMem),
        .dataRead_o(C5)
    );
    MUX muxPcSrc(.data0_i(), .data1_i(), .sel_i(pcSrc), .data_o());


    MUX muxMemToReg(.data0_i(C3), .data1_i(C5), .sel_i(memToReg), .data_o(C6));

endmodule
