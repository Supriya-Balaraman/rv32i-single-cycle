module pc_unit (
    input  logic        clk,
    input  logic        reset,
    input  logic        pc_src,       // 1 = take branch/jump
    input  logic [31:0] pc_target,    // branch/JAL: pc+imm, JALR: (rs1+imm)&~1
    output logic [31:0] pc,
    output logic [31:0] pc_plus4
);
    logic [31:0] pc_next;

    assign pc_plus4 = pc + 32'd4;
    assign pc_next  = pc_src ? pc_target : pc_plus4;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) pc <= 32'h0000_0000;
        else       pc <= pc_next;
    end
endmodule