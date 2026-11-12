`timescale 1ns / 1ps

module ex_stage (
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    input  logic [31:0] address,       // current PC
    input  logic        branch,
    input  logic        alu_src,       // 0 = rs2_data, 1 = imm_out
    input  logic        fn7_5,
    input  logic        mux_inp,       // 1 = JALR
    input  logic [2:0]  fn3,
    input  logic [6:0]  imm11_5,       // not used, imm_out has the full immediate
    input  logic [2:0]  aluop,
    input  logic [6:0]  opcode,
    output logic        and_out_ex,    // branch / jump taken
    output logic [31:0] alu_out,
    output logic [31:0] pc_ex_out      // branch / jump target
);

    logic [31:0] alu_a, alu_b;
    logic [31:0] branch_target, jalr_target;
    logic [4:0]  alu_ctrl;
    logic        branch_taken;
    logic        jal;

    assign jal = (opcode == 7'b1101111);

    // operand A: zero for lui, pc for auipc, otherwise rs1
    always_comb begin
        case (opcode)
            7'b0110111: alu_a = 32'b0;       // lui
            7'b0010111: alu_a = address;     // auipc
            default:    alu_a = rs1_data;
        endcase
    end

    // operand B: rs2 or immediate
    assign alu_b = alu_src ? imm_out : rs2_data;

    alu_control ac (
        .alu_op   (aluop[1:0]),
        .funct3   (fn3),
        .funct7_5 (fn7_5),
        .alu_ctrl (alu_ctrl)
    );

    alu u_alu (
        .a            (alu_a),
        .b            (alu_b),
        .alu_ctrl     (alu_ctrl),
        .result       (alu_out),
        .zero         (),                // not used
        .branch_taken (branch_taken)
    );

    // targets
    assign branch_target = address + imm_out;               // branch and jal
    assign jalr_target   = (rs1_data + imm_out) & ~32'b1;   // jalr clears bit 0
    assign pc_ex_out     = mux_inp ? jalr_target : branch_target;

    // take the branch / jump?
    assign and_out_ex = jal | mux_inp | (branch & branch_taken);

endmodule
