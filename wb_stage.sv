`timescale 1ns / 1ps

module wb_stage (
    input  logic [6:0]  opcode,
    input  logic [31:0] alu_out,      // R-type, I-type ALU
    input  logic [31:0] pc_new,       // pc + 4, return address for jal / jalr
    input  logic [31:0] imm_out,      // from imm generator, for lui
    input  logic [31:0] pc_ex_out,    // address + imm_out, for auipc
    input  logic [31:0] read_data,    // from data memory
    input  logic        memtoreg,     // 1 = load instruction
    output logic [31:0] wb_data
);

    logic [31:0] first_mux;

    // first mux, chosen by opcode
    always_comb begin
        case (opcode)
            7'b1101111,                        // jal
            7'b1100111: first_mux = pc_new;    // jalr -> return address
            7'b0110111: first_mux = imm_out;   // lui
            7'b0010111: first_mux = pc_ex_out; // auipc
            default:    first_mux = alu_out;   // everything else
        endcase
    end

    // second mux, chosen by memtoreg
    assign wb_data = memtoreg ? read_data : first_mux;

endmodule
