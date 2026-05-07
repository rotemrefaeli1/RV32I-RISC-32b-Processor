module alu (
    input  logic [31:0] a,
    input  logic [31:0] b,
    input  logic [3:0]  alu_ctrl,
    
    output logic [31:0] result,
    output logic        zero
);

    always @(*) begin
        case (alu_ctrl)
            4'b0000: result = a + b;                             // ADD
            4'b1000: result = a - b;                             // SUB
            4'b0001: result = a << b[4:0];                       // SLL (Shift Left Logical)
            4'b0010: result = ($signed(a) < $signed(b)) ? 1 : 0; // SLT (Set Less Than)
            4'b0011: result = (a < b) ? 1 : 0;                   // SLTU (Unsigned)
            4'b0100: result = a ^ b;                             // XOR
            4'b0101: result = a >> b[4:0];                       // SRL (Shift Right Logical)
            4'b1101: result = $signed(a) >>> b[4:0];             // SRA (Shift Right Arithmetic)
            4'b0110: result = a | b;                             // OR
            4'b0111: result = a & b;                             // AND
            default: result = 32'b0;
        endcase
    end

    // The zero flag is critical for Branch instructions (e.g., BEQ)
    assign zero = (result == 32'b0);

endmodule