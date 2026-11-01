module instruction_memory (
    input  logic [31:0] address,
    output logic [31:0] instruction
);

    logic [31:0] imem [0:255];

    initial begin
        $readmemh("program.mem", imem);
    end

    // pc goes up by 4 so ignore the last 2 bits
    assign instruction = imem[address[9:2]];

endmodule