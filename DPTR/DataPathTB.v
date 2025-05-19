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

    integer i;
    always @(dp.reg_bank.memory[31]) begin
        if (dp.reg_bank.memory[31] == -1) begin
            for (i = 0; i < 32; i = i + 1) begin
                $write("%x", dp.ram.memory[i]);
            end
            $write("\n");
            $stop;
        end
    end
endmodule
