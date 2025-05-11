module EMBuffer ( // Execute/Memory Access
    input clk_i,

    // Input control signals
	input branch_i,
	input memToRead_i,
	input memToReg_i,
	input memToWrite_i,
	input regWrite_i,
    input zf_i,

    // Input from execute stage
    input [31:0] branchAddr_i,
    input [31:0] aluResult_i,
    input [31:0] rtData_i,
    input [4:0] writeAddrReg_i,

    // Output control signals
	output reg branch_o,
	output reg memToRead_o,
	output reg memToReg_o,
	output reg memToWrite_o,
	output reg regWrite_o,
    output reg zf_o,

    // Output to memory stage
    output reg [31:0] branchAddr_o,
    output reg [31:0] aluResult_o,
    output reg [31:0] rtData_o,
    output reg [4:0] writeAddrReg_o
);
    initial zf_o = 1'b0;
    always @(posedge clk_i) begin
        branch_o = branch_i;
        memToRead_o = memToRead_i;
        memToReg_o = memToReg_i;
        memToWrite_o = memToWrite_i;
        regWrite_o = regWrite_i;
        zf_o = zf_i;

        branchAddr_o = branchAddr_i;
        aluResult_o = aluResult_i;
        rtData_o = rtData_i;
        writeAddrReg_o = writeAddrReg_i;
    end
endmodule