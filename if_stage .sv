module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input  logic        pc_src,
    input  logic [31:0] pc_target,
    output logic [31:0] pc,
    output logic [31:0] pc_plus4,
    output logic [31:0] instruction
);

    interface_module pc_block (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_src(pc_src),
        .pc_target(pc_target),
        .address(pc),
        .pc_plus4(pc_plus4)
    );

    instruction_memory imem_block (
        .address(pc),
        .instruction(instruction)
    );

endmodule