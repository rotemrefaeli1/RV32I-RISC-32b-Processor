module control_unit (
    input  logic [6:0] opcode,
    
    output logic       branch,
    output logic       jump,
    output logic       mem_read,
    output logic       mem_to_reg,
    output logic [1:0] alu_op,
    output logic       mem_write,
    output logic       alu_src,
    output logic       reg_write
);

    always_comb begin
        // Default all signals to 0 to prevent latches and accidental writes
        branch     = 1'b0;
        jump       = 1'b0;
        mem_read   = 1'b0;
        mem_to_reg = 1'b0;
        alu_op     = 2'b00;
        mem_write  = 1'b0;
        alu_src    = 1'b0;
        reg_write  = 1'b0;

        case (opcode)
            // R-Type (ADD, SUB, AND, OR, etc.)
            7'b0110011: begin
                reg_write = 1'b1;
                alu_op    = 2'b10; // Tell ALU control to look at funct3/funct7
            end
            
            // I-Type ALU (ADDI, ORI, etc.)
            7'b0010011: begin
                alu_src   = 1'b1;  // Use immediate instead of rs2
                reg_write = 1'b1;
                alu_op    = 2'b11; // Custom alu_op for I-type math
            end
            
            // I-Type Load (LW)
            7'b0000011: begin
                alu_src   = 1'b1;  // Use immediate for address calculation
                mem_to_reg= 1'b1;  // Write memory output to register
                reg_write = 1'b1;
                mem_read  = 1'b1;
                alu_op    = 2'b00; // ALU needs to ADD for address calculation
            end
            
            // S-Type Store (SW)
            7'b0100011: begin
                alu_src   = 1'b1;  // Use immediate for address calculation
                mem_write = 1'b1;
                alu_op    = 2'b00; // ALU needs to ADD for address calculation
            end
            
            // B-Type Branch (BEQ, BNE, etc.)
            7'b1100011: begin
                branch    = 1'b1;
                alu_op    = 2'b01; // ALU needs to SUBTRACT to check for equality
            end
            
            // J-Type Jump (JAL)
            7'b1101111: begin
                jump      = 1'b1;
                reg_write = 1'b1;  // JAL saves return address to register
            end
            
            // U-Type (LUI)
            7'b0110111: begin
                alu_src   = 1'b1;
                reg_write = 1'b1;
                // ALU operation will just pass the upper immediate through
            end

            default: ; // Do nothing, keep defaults
        endcase
    end

endmodule