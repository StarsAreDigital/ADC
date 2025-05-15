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
    wire [25:0] jumpAddr;
    wire rotation;
    assign {op, rs, rt, rd, shamt, funct} = instrOut;
    assign immediate = instrOut[15:0];
    assign rotation = instrOut[21];
    assign jumpAddr = instrOut[25:0];

    // Control signals
    wire memToReg, memToRead, memToWrite, regWrite, regDst, jump;
    wire aluSrcA, aluSrcB;
    wire [1:0] branchType;
    wire [3:0] aluOp;
    Control ctrl(
        .ctrl_i(op),
        .funct_i(funct),
        .rotation_i(rotation),
	    .regDst_o(regDst),
	    .branchType_o(branchType),
        .jump_o(jump),
	    .memToRead_o(memToRead),
	    .memToReg_o(memToReg),
	    .aluOp_o(aluOp),
	    .memToWrite_o(memToWrite),
        .aluSrcA_o(aluSrcA),
	    .aluSrcB_o(aluSrcB),
	    .regWrite_o(regWrite)
    );

    wire [31:0] dataRead1, dataRead2, dataWriteWb;
    wire [31:0] seOut;
    wire [4:0] writeAddrRegWb;
    wire regWriteWb;
    Registers reg_bank(
        .readAddr1_i(rs),
        .readAddr2_i(rt),
        .writeAddr_i(writeAddrRegWb),
        .dataWrite_i(dataWriteWb), 
        .writeEnable_i(regWriteWb), 
        .dataRead1_o(dataRead1),
        .dataRead2_o(dataRead2)
    );
    SignExtend se(.data_i(immediate), .data_o(seOut));


    /* Decode/Execute buffer */
    wire memToRegEx, memToReadEx, memToWriteEx, regWriteEx, regDstEx, jumpEx;
    wire aluSrcAEx, aluSrcBEx;
    wire [1:0] branchTypeEx;
    wire [3:0] aluOpEx;
    wire [31:0] nextInstrAddrEx, rsDataEx, rtDataEx, signExtendEx;
    wire [4:0] rtAddrEx, rdAddrEx;
    wire [5:0] functEx;
    wire [4:0] shamtEx;
    wire [25:0] jumpAddrEx;

    DEBuffer de_buf(
        .clk_i(clk_i),

        // Input control signals
        .regDst_i(regDst),
        .branchType_i(branchType),
        .jump_i(jump),
        .memToRead_i(memToRead),
        .memToReg_i(memToReg),
        .aluOp_i(aluOp),
        .memToWrite_i(memToWrite),
        .aluSrcA_i(aluSrcA),
        .aluSrcB_i(aluSrcB),
        .regWrite_i(regWrite),

        // Input from decode stage
        .nextInstrAddr_i(nextInstrAddr),
        .rsData_i(dataRead1),
        .rtData_i(dataRead2),
        .signExtend_i(seOut),
        .rtAddr_i(rt),
        .rdAddr_i(rd),
        .funct_i(funct),
        .shamt_i(shamt),
        .jumpAddr_i(jumpAddr),

        // Output control signals
        .regDst_o(regDstEx),
        .branchType_o(branchTypeEx),
        .jump_o(jumpEx),
        .memToRead_o(memToReadEx),
        .memToReg_o(memToRegEx),
        .aluOp_o(aluOpEx),
        .memToWrite_o(memToWriteEx),
        .aluSrcA_o(aluSrcAEx),
        .aluSrcB_o(aluSrcBEx),
        .regWrite_o(regWriteEx),

        // Output to execute stage
        .nextInstrAddr_o(nextInstrAddrEx),
        .rsData_o(rsDataEx),
        .rtData_o(rtDataEx),
        .signExtend_o(signExtendEx),
        .rtAddr_o(rtAddrEx),
        .rdAddr_o(rdAddrEx),
        .funct_o(functEx),
        .shamt_o(shamtEx),
        .jumpAddr_o(jumpAddrEx)
    );


    /* Execute stage */
    wire [31:0] fullJumpAddr;
    wire [31:0] boOut;
    wire [4:0] writeAddrRegEx;
    wire [31:0] shamtExtended;
    wire [31:0] aluA, aluB, aluResult;
    wire [3:0] aluSel;
    wire zf, sign;
    assign shamtExtended = {27'b0, shamtEx};

    JumpOffset jo(
        .jumpAddr_i(jumpAddrEx),
        .pcAlign_i(nextInstrAddrEx[31:28]),
        .jumpAddr_o(fullJumpAddr)
    );

    MUX #(5) muxRegDst (.data0_i(rtAddrEx), .data1_i(rdAddrEx), .sel_i(regDstEx), .data_o(writeAddrRegEx));

    MUX muxAluSrcA(.data0_i(rsDataEx), .data1_i(shamtExtended), .sel_i(aluSrcAEx), .data_o(aluA));
    MUX muxAluSrcB(.data0_i(rtDataEx), .data1_i(signExtendEx), .sel_i(aluSrcBEx), .data_o(aluB));

    BranchOffset branchOffset(.pc_i(nextInstrAddrEx), .offset_i(signExtendEx), .pc_o(boOut));
    ALUControl aluCtrl(.aluOp_i(aluOpEx), .funct_i(functEx), .sel_o(aluSel));
    ALU alu(.a_i(aluA), .b_i(aluB), .op_i(aluSel), .res_o(aluResult), .zf_o(zf), .sign_o(sign));


    /* Execute/Memory buffer */
    wire memToReadMem, memToRegMem, memToWriteMem, regWriteMem, zfMem, signMem, jumpMem;
    wire [1:0] branchTypeMem;
    wire [31:0] branchAddrMem, aluResultMem, rtDataMem, jumpAddrMem;
    wire [4:0] writeAddrRegMem;

    EMBuffer em_buf(
        .clk_i(clk_i),

        // Input control signals
        .branchType_i(branchTypeEx),
        .jump_i(jumpEx),
        .memToRead_i(memToReadEx),
        .memToReg_i(memToRegEx),
        .memToWrite_i(memToWriteEx),
        .regWrite_i(regWriteEx),
        .zf_i(zf),
        .sign_i(sign),

        // Input from execute stage
        .branchAddr_i(boOut),
        .aluResult_i(aluResult),
        .rtData_i(rtDataEx),
        .writeAddrReg_i(writeAddrRegEx),
        .jumpAddr_i(fullJumpAddr),

        // Output control signals
        .branchType_o(branchTypeMem),
        .jump_o(jumpMem),
        .memToRead_o(memToReadMem),
        .memToReg_o(memToRegMem),
        .memToWrite_o(memToWriteMem),
        .regWrite_o(regWriteMem),
        .zf_o(zfMem),
        .sign_o(signMem),

        // Output to memory stage
        .branchAddr_o(branchAddrMem),
        .aluResult_o(aluResultMem),
        .rtData_o(rtDataMem),
        .writeAddrReg_o(writeAddrRegMem),
        .jumpAddr_o(jumpAddrMem)
    );


    /* Memory access stage */
    wire pcSrc;
    wire [31:0] dataMemOut, muxBranchOut;

    BranchControl branchCtrl(
        .branchType_i(branchTypeMem),
        .zf_i(zfMem),
        .sign_i(signMem),
        .branch_o(pcSrc)
    );
    DataMemory ram(
        .readEnable_i(memToReadMem),
        .writeEnable_i(memToWriteMem), 
        .address_i(aluResultMem),
        .dataWrite_i(rtDataMem),
        .dataRead_o(dataMemOut)
    );
    MUX muxPcSrcBranch(.data0_i(pcOut), .data1_i(branchAddrMem), .sel_i(pcSrc), .data_o(muxBranchOut));
    MUX muxPcSrcJump(.data0_i(muxBranchOut), .data1_i(jumpAddrMem), .sel_i(jumpMem), .data_o(nextPc));


    /* Memory/Write back buffer */
    wire memToRegWb;
    wire [31:0] dataMemOutWb, aluResultWb;

    MWBuffer mw_buf(
        .clk_i(clk_i),

        // Input control signals
        .memToReg_i(memToRegMem),
        .regWrite_i(regWriteMem),

        // Input from memory stage
        .dataMem_i(dataMemOut),
        .aluResult_i(aluResultMem),
        .writeAddrReg_i(writeAddrRegMem),

        // Output control signals
        .memToReg_o(memToRegWb),
        .regWrite_o(regWriteWb),

        // Output to write back stage
        .dataMem_o(dataMemOutWb),
        .aluResult_o(aluResultWb),
        .writeAddrReg_o(writeAddrRegWb)
    );


    /* Write back stage */
    MUX muxMemToReg(.data0_i(aluResultWb), .data1_i(dataMemOutWb), .sel_i(memToRegWb), .data_o(dataWriteWb));

endmodule
