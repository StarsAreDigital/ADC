module DEBuffer ( // Decode/Execute
    input clk_i,

    // Input control signals
    input regDst_i,
	input branch_i,
	input memToRead_i,
	input memToReg_i,
	input [3:0] aluOp_i,
	input memToWrite_i,
    input aluSrcA_i,
	input aluSrcB_i,
	input regWrite_i,

    // Input from decode stage
    input [31:0] nextInstrAddr_i,
    input [31:0] rsData_i,
    input [31:0] rtData_i,
    input [31:0] signExtend_i,
    input [4:0] rtAddr_i,
    input [4:0] rdAddr_i,
    input [5:0] funct_i,
    input [4:0] shamt_i,

    // Output control signals
	output reg regDst_o,
	output reg branch_o,
	output reg memToRead_o,
	output reg memToReg_o,
	output reg [3:0] aluOp_o,
	output reg memToWrite_o,
    output reg aluSrcA_o,
	output reg aluSrcB_o,
	output reg regWrite_o,

    // Output to execute stage
    output reg [31:0] nextInstrAddr_o,
    output reg [31:0] rsData_o,
    output reg [31:0] rtData_o,
    output reg [31:0] signExtend_o,
    output reg [4:0] rtAddr_o,
    output reg [4:0] rdAddr_o,
    output reg [5:0] funct_o,
    output reg [4:0] shamt_o
);

    always @(posedge clk_i) begin
        // Control signals
        regDst_o = regDst_i;
        branch_o = branch_i;
        memToRead_o = memToRead_i;
        memToReg_o = memToReg_i;
        aluOp_o = aluOp_i;
        memToWrite_o = memToWrite_i;
        aluSrcA_o = aluSrcA_i;
        aluSrcB_o = aluSrcB_i;
        regWrite_o = regWrite_i;

        nextInstrAddr_o = nextInstrAddr_i;
        rsData_o = rsData_i;
        rtData_o = rtData_i;
        signExtend_o = signExtend_i;
        rtAddr_o = rtAddr_i;
        rdAddr_o = rdAddr_i;
        funct_o = funct_i;
        shamt_o = shamt_i;
    end
    
endmodule