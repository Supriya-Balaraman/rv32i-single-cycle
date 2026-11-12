`timescale 1ns/1ps

module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [4:0]  alu_ctrl,
    output logic [31:0] result,
    output logic        branch_taken   // 1 when the branch condition is true
);

    always_comb begin
        result       = 32'b0;   // defaults so no latches
        branch_taken = 1'b0;

        case (alu_ctrl)
            5'b00000: result = a + b;                                        // ADD
            5'b00001: result = a - b;                                        // SUB
            5'b00010: result = a ^ b;                                        // XOR
            5'b00011: result = a | b;                                        // OR
            5'b00100: result = a & b;                                        // AND
            5'b00101: result = a << b[4:0];                                  // SLL
            5'b00110: result = a >> b[4:0];                                  // SRL
            5'b00111: result = $signed(a) >>> b[4:0];                        // SRA
            5'b01000: result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;    // SLT
            5'b01001: result = (a < b) ? 32'd1 : 32'd0;                      // SLTU

            // branch compares: result is unused, only branch_taken matters
            5'b01010: branch_taken = (a == b);                               // BEQ
            5'b01011: branch_taken = (a != b);                               // BNE
            5'b01100: branch_taken = ($signed(a) <  $signed(b));             // BLT
            5'b01101: branch_taken = ($signed(a) >= $signed(b));             // BGE
            5'b01110: branch_taken = (a <  b);                               // BLTU
            5'b01111: branch_taken = (a >= b);                               // BGEU

            default: begin
                result       = 32'b0;
                branch_taken = 1'b0;
            end
        endcase
    end

endmodule
