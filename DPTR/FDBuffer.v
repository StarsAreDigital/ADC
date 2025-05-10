module FDBuffer ( // Fetch/Decode
    input clk_i,

    input [31:0] nextInstrAddr_i,
    input [31:0] instr_i,
    
    output reg [31:0] nextInstrAddr_o,
    output reg [31:0] instr_o
);

    always @(posedge clk_i) begin
        nextInstrAddr_o = nextInstrAddr_i;
        instr_o = instr_i;
    end
endmodule