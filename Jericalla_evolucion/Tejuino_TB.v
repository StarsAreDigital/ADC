`timescale 1ns/1ns
module Tejuino_TB();
    reg clk;
    reg [16:0] instr;
    wire [31:0] out;

    Tejuino t(.clk(clk), .instr(instr), .out(out));

    initial begin
        clk = 1'b0;
        forever begin
            #5 clk = ~clk;
        end
    end

    initial begin
        instr = {2'b00, 5'h4, 5'h0, 5'h1};
        #100;
        instr = {2'b01, 5'h5, 5'h1, 5'h2};
        #100;
        instr = {2'b10, 5'h6, 5'h2, 5'h3};
        #100;
        instr = {2'b11, 5'hx, 5'h7, 5'h4};
        #100;
        instr = {2'b11, 5'hx, 5'h8, 5'h5};
        #100;
        instr = {2'b11, 5'hx, 5'h9, 5'h6};
        #100;
        $stop;
    end
endmodule
