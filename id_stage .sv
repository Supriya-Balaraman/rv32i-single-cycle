module id_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] instruction,
    input  logic [31:0] wb_data,

    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_output,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,

    output logic        alu_src,
    output logic [1:0]  a_sel,
    output logic        mem_read,
    output logic        mem_write,
    output logic [1:0]  wb_sel,
    output logic        branch,
    output logic        jal,
    output logic        jalr,
    output logic [1:0]  alu_op
);

    logic [4:0]  rs1, rs2, rd;
    logic [6:0]  opcode;
    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    logic        reg_write;

    decoder_interface decoder (
        .instruction(instruction),
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j)
    );

    imm_generator imm_gen (
        .opcode(opcode),
        .funct3(funct3),
        .imm_i(imm_i),
        .imm_s(imm_s),
        .imm_b(imm_b),
        .imm_u(imm_u),
        .imm_j(imm_j),
        .imm_output(imm_output)
    );

    main_control ctrl (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .a_sel(a_sel),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .wb_sel(wb_sel),
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .alu_op(alu_op)
    );

    register_file regs (
        .clk(clk),
        .reset(reset),
        .rs1_sel(rs1),
        .rs2_sel(rs2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_sel(rd),
        .wb_data(wb_data),
        .reg_write(reg_write)
    );

endmodule