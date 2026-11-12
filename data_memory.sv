`timescale 1ns / 1ps

module data_memory (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [2:0]  funct3,        // 000 b, 001 h, 010 w, 100 bu, 101 hu
    input  logic [31:0] address,       // byte address from alu_out
    input  logic [31:0] write_data,    // rs2_data for stores
    output logic [31:0] read_data
);

    logic [31:0] dmem [0:255];         // 256 words = 1 KB

    logic [7:0]  word_idx;
    logic [1:0]  byte_off;
    logic [31:0] word;                 // word that holds the address

    assign word_idx = address[9:2];
    assign byte_off = address[1:0];
    assign word     = dmem[word_idx];

    // start everything at 0 so loads never return X in simulation
    initial begin
        for (int i = 0; i < 256; i++)
            dmem[i] = 32'b0;
    end

    // store: write on the clock edge
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (funct3[1:0])
                2'b00: begin                                   // sb
                    case (byte_off)
                        2'b00: dmem[word_idx][7:0]   <= write_data[7:0];
                        2'b01: dmem[word_idx][15:8]  <= write_data[7:0];
                        2'b10: dmem[word_idx][23:16] <= write_data[7:0];
                        2'b11: dmem[word_idx][31:24] <= write_data[7:0];
                    endcase
                end
                2'b01: begin                                   // sh
                    if (byte_off[1])
                        dmem[word_idx][31:16] <= write_data[15:0];
                    else
                        dmem[word_idx][15:0]  <= write_data[15:0];
                end
                2'b10: dmem[word_idx] <= write_data;           // sw
                default: ;
            endcase
        end
    end

    // load: combinational read with sign / zero extension
    always_comb begin
        read_data = 32'b0;

        if (mem_read) begin
            case (funct3)
                3'b000: begin                                  // lb
                    case (byte_off)
                        2'b00: read_data = {{24{word[7]}},  word[7:0]};
                        2'b01: read_data = {{24{word[15]}}, word[15:8]};
                        2'b10: read_data = {{24{word[23]}}, word[23:16]};
                        2'b11: read_data = {{24{word[31]}}, word[31:24]};
                    endcase
                end
                3'b001: begin                                  // lh
                    if (byte_off[1])
                        read_data = {{16{word[31]}}, word[31:16]};
                    else
                        read_data = {{16{word[15]}}, word[15:0]};
                end
                3'b010: read_data = word;                      // lw
                3'b100: begin                                  // lbu
                    case (byte_off)
                        2'b00: read_data = {24'b0, word[7:0]};
                        2'b01: read_data = {24'b0, word[15:8]};
                        2'b10: read_data = {24'b0, word[23:16]};
                        2'b11: read_data = {24'b0, word[31:24]};
                    endcase
                end
                3'b101: begin                                  // lhu
                    if (byte_off[1])
                        read_data = {16'b0, word[31:16]};
                    else
                        read_data = {16'b0, word[15:0]};
                end
                default: read_data = 32'b0;
            endcase
        end
    end

endmodule
