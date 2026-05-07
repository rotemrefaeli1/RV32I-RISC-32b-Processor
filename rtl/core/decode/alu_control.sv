module alu_control (
    input  logic [1:0] alu_op,   // From Main Control Unit
    input  logic [2:0] funct3,   // From instruction slicing
    input  logic       funct7_5, // Bit 30 of the instruction
    
    output logic [3:0] alu_ctrl  // 4-bit command sent to the actual ALU
);

    always_comb begin
        case (alu_op)
            // 00: Load/Store (We need the ALU to ADD the base address and the offset)
            2'b00: alu_ctrl = 4'b0000; // Command for ADD
            
            // 01: Branch (We need the ALU to SUBTRACT to compare two registers)
            2'b01: alu_ctrl = 4'b1000; // Command for SUB
            
            // 10 & 11: R-Type or I-Type Math (Look at funct3 and funct7 to know what to do)
            2'b10, 2'b11: begin
                case (funct3)
                    3'b000: begin
                        // If R-type (alu_op==10) AND bit 30 is 1, then SUBTRACT.
                        // Otherwise, it's an ADD or ADDI.
                        if (alu_op == 2'b10 && funct7_5 == 1'b1)
                            alu_ctrl = 4'b1000; // SUB
                        else
                            alu_ctrl = 4'b0000; // ADD
                    end
                    
                    3'b001: alu_ctrl = 4'b0001; // SLL  (Shift Left Logical)
                    3'b010: alu_ctrl = 4'b0010; // SLT  (Set Less Than)
                    3'b011: alu_ctrl = 4'b0011; // SLTU (Set Less Than Unsigned)
                    3'b100: alu_ctrl = 4'b0100; // XOR
                    
                    3'b101: begin
                        // If bit 30 is 1, Arithmetic Shift. Otherwise, Logical Shift.
                        if (funct7_5 == 1'b1)
                            alu_ctrl = 4'b1101; // SRA (Shift Right Arithmetic)
                        else
                            alu_ctrl = 4'b0101; // SRL (Shift Right Logical)
                    end
                    
                    3'b110: alu_ctrl = 4'b0110; // OR
                    3'b111: alu_ctrl = 4'b0111; // AND
                endcase
            end
            
            // Default catch-all
            default: alu_ctrl = 4'b0000;
        endcase
    end

endmodule