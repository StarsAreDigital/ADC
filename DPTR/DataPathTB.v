`timescale 1ns/1ns
module DataPathTB ();
    reg clk;
    DataPath dp(.clk_i(clk));

    initial begin
        clk = 0;

        $readmemb("instructions.mem", dp.im.memory);
        $readmemb("data.mem", dp.ram.memory);

        dp.reg_bank.memory[0] = 32'd0;
        dp.reg_bank.memory[1] = 32'd233;
        dp.reg_bank.memory[2] = 32'd123;
        dp.reg_bank.memory[3] = 32'd456;
        dp.reg_bank.memory[4] = 32'd789;
        dp.reg_bank.memory[5] = 32'd432;
        dp.reg_bank.memory[6] = 32'd654;
        dp.reg_bank.memory[7] = 32'd321;
        dp.reg_bank.memory[8] = 32'd567;
        dp.reg_bank.memory[9] = 32'd890;
    end
    always #5 clk = ~clk;
endmodule
