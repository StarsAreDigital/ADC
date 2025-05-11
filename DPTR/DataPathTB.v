`timescale 1ns/1ns
module DataPathTB ();
    reg clk;
    DataPath dp(.clk_i(clk));

    initial begin
        clk = 0;

        $readmemb("instructions.mem", dp.im.memory);
        $readmemb("data.mem", dp.ram.memory);
    end
    always #1 clk = ~clk;
endmodule
