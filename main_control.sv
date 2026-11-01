module main_control (
    input  logic [6:0] opcode,
    output logic       reg_write,
    output logic       alu_src,    // 0 = rs2, 1 = imm
    output logic [1:0] a_sel,      // 00 rs1, 01 pc, 10 zero
    output logic       mem_read,
    output logic       mem_write,
    output logic [1:0] wb_sel,     // 00 alu, 01 load, 10 pc+4
    output logic       branch,
    output logic       jal,
    output logic       jalr,
    output logic [1:0] alu_op      // 00 add, 01 branch, 10 R, 11 I
);

    always_comb begin
        // defaults first so no latches
        reg_write = 0;
        alu_src   = 0;
        a_sel     = 2'b00;
        mem_read  = 0;
        mem_write = 0;
        wb_sel    = 2'b00;
        branch    = 0;
        jal       = 0;
        jalr      = 0;
        alu_op    = 2'b00;

        case (opcode)
            7'b0110011: begin           // R type
                reg_write = 1;
                alu_op    = 2'b10;
            end
            7'b0010011: begin           // I type alu
                reg_write = 1;
                alu_src   = 1;
                alu_op    = 2'b11;
            end
            7'b0000011: begin           // load
                reg_write = 1;
                alu_src   = 1;
                mem_read  = 1;
                wb_sel    = 2'b01;
            end
            7'b0100011: begin           // store
                alu_src   = 1;
                mem_write = 1;
            end
            7'b1100011: begin           // branch
                branch = 1;
                alu_op = 2'b01;
            end
            7'b1101111: begin           // jal
                reg_write = 1;
                jal       = 1;
                wb_sel    = 2'b10;
            end
            7'b1100111: begin           // jalr
                reg_write = 1;
                alu_src   = 1;
                jalr      = 1;
                wb_sel    = 2'b10;
            end
            7'b0110111: begin           // lui
                reg_write = 1;
                alu_src   = 1;
                a_sel     = 2'b10;
            end
            7'b0010111: begin           // auipc
                reg_write = 1;
                alu_src   = 1;
                a_sel     = 2'b01;
            end
            default: ;
        endcase
    end

endmodule