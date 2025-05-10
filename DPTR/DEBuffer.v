module DEBuffer ( // Decode/Execute
    input clk_i,

    // Input control signals
    input regDst_o,
	input branch_o,
	input memToRead_o,
	input memToReg_o,
	input [1:0] aluOp_o,
	input memToWrite_o,
	input aluSrc_o,
	input regWrite_o,

    // Input from decode stage
    input [31:0] nextInstrAddr_o,
    input [31:0] rsData_i,
    input [31:0] rtData_i,
    input [31:0] signExtend_i,
    input [4:0] rtAddr_i,
    input [4:0] rdAddr_i,
    input [5:0] funct_i,

    // Output control signals
	output reg regDst_o,
	output reg branch_o,
	output reg memToRead_o,
	output reg memToReg_o,
	output reg [1:0] aluOp_o,
	output reg memToWrite_o,
	output reg aluSrc_o,
	output reg regWrite_o

    // Output to execute stage
    output reg [31:0] nextInstrAddr_o,
    output reg [31:0] rsData_o,
    output reg [31:0] rtData_o,
    output reg [31:0] signExtend_o,
    output reg [4:0] rtAddr_o,
    output reg [4:0] rdAddr_o,
    output reg [5:0] funct_o
);

    always @(posedge clk_i) begin
        // Control signals
        regDst_o = regDst_o;
        branch_o = branch_o;
        memToRead_o = memToRead_o;
        memToReg_o = memToReg_o;
        aluOp_o = aluOp_o;
        memToWrite_o = memToWrite_o;
        aluSrc_o = aluSrc_o;
        regWrite_o = regWrite_o;

        nextInstrAddr_o = nextInstrAddr_o;
        rsData_o = rsData_i;
        rtData_o = rtData_i;
        signExtend_o = signExtend_i;
        rtAddr_o = rtAddr_i;
        rdAddr_o = rdAddr_i;
        funct_o = funct_i;
    end
    
endmodule