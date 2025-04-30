module Buffer #(parameter SIGW, parameter DELAY) (
    input CLK,
    input [SIGW - 1:0] in,
    output reg [SIGW - 1:0] out
);
    reg [SIGW * (DELAY - 1) - 1:0] mem;

    always @(posedge CLK) begin
        {out, mem} = {mem, in};
    end
endmodule