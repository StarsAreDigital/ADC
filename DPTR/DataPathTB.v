`timescale 1ns/1ns
module DataPathTB ();
    reg clk;
    DataPath dp(.clk(clk));

    initial begin
        clk = 0;

        $readmemb("instructions.mem", dp.im.memory);
        $readmemb("data.mem", dp.ram.mem);

        dp.reg_bank.mem[0] = 32'd0;
        dp.reg_bank.mem[1] = 32'd233;
        dp.reg_bank.mem[2] = 32'd123;
        dp.reg_bank.mem[3] = 32'd456;
        dp.reg_bank.mem[4] = 32'd789;
        dp.reg_bank.mem[5] = 32'd432;
        dp.reg_bank.mem[6] = 32'd654;
        dp.reg_bank.mem[7] = 32'd321;
        dp.reg_bank.mem[8] = 32'd567;
        dp.reg_bank.mem[9] = 32'd890;
    end
    always #5 clk = ~clk;
endmodule
