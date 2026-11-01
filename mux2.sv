module mux2 #(
    parameter int WIDTH = 32
)(
    input  logic [WIDTH-1:0] a,   // selected when s = 0
    input  logic [WIDTH-1:0] b,   // selected when s = 1
    input  logic             s,
    output logic [WIDTH-1:0] y
);
    assign y = s ? b : a;
endmodule