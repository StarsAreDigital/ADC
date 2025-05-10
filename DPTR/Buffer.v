module Buffer #(parameter SIGW, parameter DELAY) (
    input clk_i,
    input [SIGW - 1:0] data_i,
    output reg [SIGW - 1:0] data_o
);
    reg [SIGW * (DELAY - 1) - 1:0] memory;

    always @(posedge clk_i) begin
        {data_o, memory} = {memory, data_i};
    end
endmodule