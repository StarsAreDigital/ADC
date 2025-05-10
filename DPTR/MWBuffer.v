module MWBuffer ( // Memory Access/Write Back
    input clk_i,
 
    // Input control signals
	input memToReg_i,
	input regWrite_i,

    // Input from memory stage
    input [31:0] dataMem_i,
    input [31:0] aluResult_i,
    input [4:0] writeAddrReg_i,

    // Output control signals
    output reg memToReg_o,
    output reg regWrite_o,

    // Output to write back stage
    output reg [31:0] dataMem_o,
    output reg [31:0] aluResult_o,
    output reg [4:0] writeAddrReg_o
);

    always @(posedge clk_i) begin
        memToReg_o = memToReg_i;
        regWrite_o = regWrite_i;
        dataMem_o = dataMem_i;
        aluResult_o = aluResult_i;
        writeAddrReg_o = writeAddrReg_i;
    end

    
endmodule