module imm_gen (
    input  logic [31:0] instr,
    output logic [31:0] imm_out
);

    logic [6:0] opcode;
    assign opcode = instr[6:0];

    // Bypassing the compiler bug: Slice the bits using continuous assignments OUTSIDE the always block
    logic [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;
    
    assign imm_i = {{20{instr[31]}}, instr[31:20]};
    assign imm_s = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    assign imm_b = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    assign imm_u = {instr[31:12], 12'b0};
    assign imm_j = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};

    // Now use the always_comb block simply to select the pre-sliced wire
    always_comb begin
        case (opcode)
            7'b0000011, 7'b0010011, 7'b1100111: imm_out = imm_i; // I-type
            7'b0100011:                         imm_out = imm_s; // S-type
            7'b1100011:                         imm_out = imm_b; // B-type
            7'b0110111, 7'b0010111:             imm_out = imm_u; // U-type
            7'b1101111:                         imm_out = imm_j; // J-type
            default:                            imm_out = 32'b0;
        endcase
    end

endmodule