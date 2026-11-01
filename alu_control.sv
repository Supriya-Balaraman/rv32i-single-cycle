module alu_control (
    input  logic [1:0] alu_op,     // from main_control
    input  logic [2:0] funct3,
    input  logic       funct7_5,   // connect funct7[5] here
    output logic [3:0] alu_ctrl
);

    // alu_ctrl codes (the ALU uses the same ones)
    // 0000 add   0001 sub   0010 and   0011 or    0100 xor
    // 0101 sll   0110 srl   0111 sra   1000 slt   1001 sltu

    always_comb begin
        alu_ctrl = 4'b0000;   // default add, avoids latches

        case (alu_op)
            2'b00: alu_ctrl = 4'b0000;    // load, store, jalr, lui, auipc -> add

            2'b01: alu_ctrl = 4'b0001;    // branch -> sub

            2'b10: begin                  // R type
                case (funct3)
                    3'b000: alu_ctrl = funct7_5 ? 4'b0001 : 4'b0000;   // sub / add
                    3'b001: alu_ctrl = 4'b0101;                        // sll
                    3'b010: alu_ctrl = 4'b1000;                        // slt
                    3'b011: alu_ctrl = 4'b1001;                        // sltu
                    3'b100: alu_ctrl = 4'b0100;                        // xor
                    3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110;   // sra / srl
                    3'b110: alu_ctrl = 4'b0011;                        // or
                    3'b111: alu_ctrl = 4'b0010;                        // and
                endcase
            end

            2'b11: begin                  // I type alu
                case (funct3)
                    3'b000: alu_ctrl = 4'b0000;                        // addi (never sub)
                    3'b001: alu_ctrl = 4'b0101;                        // slli
                    3'b010: alu_ctrl = 4'b1000;                        // slti
                    3'b011: alu_ctrl = 4'b1001;                        // sltiu
                    3'b100: alu_ctrl = 4'b0100;                        // xori
                    3'b101: alu_ctrl = funct7_5 ? 4'b0111 : 4'b0110;   // srai / srli
                    3'b110: alu_ctrl = 4'b0011;                        // ori
                    3'b111: alu_ctrl = 4'b0010;                        // andi
                endcase
            end
        endcase
    end

endmodule