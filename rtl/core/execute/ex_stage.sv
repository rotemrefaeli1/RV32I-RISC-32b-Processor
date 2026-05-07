module ex_stage (
    input  logic [31:0] pc,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm_out,
    
    // Control Signals from ID Stage
    input  logic        alu_src,
    input  logic [3:0]  alu_ctrl,
    
    // Outputs to Memory/Writeback Stages
    output logic [31:0] alu_result,
    output logic        zero,
    output logic [31:0] write_data,
    output logic [31:0] branch_target
);

    logic [31:0] alu_b_input;
    
    // The ALUSrc Multiplexer
    // If alu_src is 1 (I-Type/Load/Store), use the immediate. 
    // If 0 (R-Type/Branch), use rs2_data.
    assign alu_b_input = (alu_src) ? imm_out : rs2_data;
    
    // Branch Target Adder
    // Calculates where to jump if a branch is taken (PC + Immediate)
    assign branch_target = pc + imm_out;
    
    // Write Data Pass-through
    // For Store instructions (SW), the data we want to write to memory is always in rs2
    assign write_data = rs2_data;
    
    // Instantiate the ALU
    alu u_alu (
        .a(rs1_data),
        .b(alu_b_input),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero)
    );

endmodule