`timescale 1ns / 1ps

module single_cycle_rv32i (
    input logic clk,
    input logic reset
);

    // IF
    logic [31:0] address, pc_new, instruction;

    // ID
    logic [31:0] rs1_data, rs2_data, imm_output;
    logic [6:0]  opcode, funct7;
    logic [2:0]  funct3, aluop;
    logic        alu_src, mem_read, mem_write, memtoreg, branch, jalr;

    // EX
    logic [31:0] alu_out, pc_ex_out;
    logic        and_out_ex;

    // MEM and WB
    logic [31:0] read_data, wb_data;

    if_stage fetch (
        .clk(clk),
        .reset(reset),
        .stall(1'b0),                    // no stalls in single cycle
        .and_out(and_out_ex),
        .pc_signed_offset(pc_ex_out),
        .address(address),
        .pc_new(pc_new),
        .instruction(instruction)
    );

    id_stage decode (
        .clk(clk),
        .reset(reset),
        .instruction(instruction),
        .wb_data(wb_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_output(imm_output),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .memtoreg(memtoreg),
        .branch(branch),
        .jalr(jalr),
        .aluop(aluop)
    );

    ex_stage execute (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_output),
        .address(address),
        .branch(branch),
        .alu_src(alu_src),
        .fn7_5(funct7[5]),
        .mux_inp(jalr),
        .fn3(funct3),
        .imm11_5(funct7),                // unused inside ex_stage
        .aluop(aluop),
        .opcode(opcode),
        .and_out_ex(and_out_ex),
        .alu_out(alu_out),
        .pc_ex_out(pc_ex_out)
    );

    data_memory dm (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .address(alu_out),
        .write_data(rs2_data),
        .read_data(read_data)
    );

    wb_stage writeback (
        .opcode(opcode),
        .alu_out(alu_out),
        .pc_new(pc_new),
        .imm_out(imm_output),
        .pc_ex_out(pc_ex_out),
        .read_data(read_data),
        .memtoreg(memtoreg),
        .wb_data(wb_data)
    );

endmodule
