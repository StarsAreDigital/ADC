`timescale 1ns/1ns
module DataPathTB ();
    reg clk;
    DataPath dp(.clk_i(clk));

    initial begin
        clk = 0;

        $readmemb("instructions.mem", dp.im.memory);
        $readmemh("data.mem", dp.ram.memory);
    end
    always #1 clk = ~clk;
    always @(dp.reg_bank.memory[31]) begin
        $stop;
    end
endmodule
