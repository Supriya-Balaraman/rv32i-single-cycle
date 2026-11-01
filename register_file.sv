module register_file (
    input  logic        clk,
    input  logic        reset,
    input  logic [4:0]  rs1_sel,
    input  logic [4:0]  rs2_sel,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    input  logic [4:0]  rd_sel,
    input  logic [31:0] wb_data,
    input  logic        reg_write
);

    logic [31:0] rf [0:31];

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < 32; i++) begin
                rf[i] <= 32'b0;
            end
        end else if (reg_write && (rd_sel != 5'd0)) begin
            rf[rd_sel] <= wb_data;
        end
    end

    assign rs1_data = (rs1_sel == 5'd0) ? 32'b0 : rf[rs1_sel];
    assign rs2_data = (rs2_sel == 5'd0) ? 32'b0 : rf[rs2_sel];

endmodule