`timescale 1ns / 1ps

module tb_single_cycle;

    logic clk;
    logic reset;

    int errors = 0;

    single_cycle_rv32i dut (
        .clk(clk),
        .reset(reset)
    );

    // 10 ns clock
    initial clk = 0;
    always #5 clk = ~clk;

    // compare one register with what we expect
    task check_reg(input int n, input logic [31:0] expected);
        logic [31:0] actual;
        begin
            actual = dut.decode.regs.rf[n];
            if (actual === expected)
                $display("PASS  x%0d = 0x%08h", n, actual);
            else begin
                $display("FAIL  x%0d = 0x%08h, expected 0x%08h", n, actual, expected);
                errors++;
            end
        end
    endtask

    initial begin
        reset = 1;
        #22;
        reset = 0;

        // 18 instructions run, the last is an infinite loop. 40 cycles is plenty.
        repeat (40) @(posedge clk);
        #1;

        $display("---- checking registers ----");
        check_reg(1,  32'd5);
        check_reg(2,  32'd10);
        check_reg(3,  32'd15);          // add
        check_reg(4,  32'd5);           // sub
        check_reg(5,  32'd15);          // sw then lw
        check_reg(6,  32'd0);           // skipped by beq
        check_reg(7,  32'h0000_0024);   // jal return address
        check_reg(8,  32'd0);           // skipped by jal
        check_reg(9,  32'h1234_5000);   // lui
        check_reg(10, 32'hFFFF_FFFF);   // addi -1
        check_reg(12, 32'h0000_0040);
        check_reg(13, 32'h0000_0038);   // jalr return address
        check_reg(14, 32'd0);           // skipped by jalr
        check_reg(15, 32'd1);           // reached after jalr
        check_reg(0,  32'd0);           // x0 stays zero

        if (errors == 0) $display("ALL TESTS PASSED");
        else             $display("%0d TEST(S) FAILED", errors);

        $finish;
    end

endmodule
