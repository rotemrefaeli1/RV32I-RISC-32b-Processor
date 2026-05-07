module id_stage (
    input  logic        clk,
    input  logic [31:0] instr,

    // Writeback stage inputs (Loops back from the end of the pipeline)
    input  logic        wb_reg_write,
    input  logic [4:0]  wb_rd_addr,
    input  logic [31:0] wb_rd_data,

    // Data outputs to Execute stage
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,
    output logic [31:0] imm_out,
    
    // Register addresses (Passed down for hazard detection/forwarding later)
    output logic [4:0]  rs1_addr_out,
    output logic [4:0]  rs2_addr_out,
    output logic [4:0]  rd_addr_out,

    // Control signals to Execute/Memory/Writeback stages
    output logic        branch,
    output logic        jump,
    output logic        mem_read,
    output logic        mem_to_reg,
    output logic [3:0]  alu_ctrl,
    output logic        mem_write,
    output logic        alu_src,
    output logic        reg_write
);

    // Internal wires connecting Decode to other ID components
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic [1:0] alu_op;
    
    // The Instruction Slicer
    decode u_decode (
        .instr(instr),
        .opcode(opcode),
        .rd(rd_addr_out),
        .funct3(funct3),
        .rs1(rs1_addr_out),
        .rs2(rs2_addr_out),
        .funct7(funct7)
    );

    // The Register File
    regfile u_regfile (
        .clk(clk),
        .we(wb_reg_write),
        .rs1_addr(rs1_addr_out),
        .rs2_addr(rs2_addr_out),
        .rd_addr(wb_rd_addr),
        .rd_data(wb_rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // The Immediate Generator
    imm_gen u_imm_gen (
        .instr(instr),
        .imm_out(imm_out)
    );

    // The Main Control Unit
    control_unit u_control_unit (
        .opcode(opcode),
        .branch(branch),
        .jump(jump),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    // The ALU Control
    alu_control u_alu_control (
        .alu_op(alu_op),
        .funct3(funct3),
        .funct7_5(funct7[5]), // We only need bit 5 of funct7 (which is bit 30 of instr)
        .alu_ctrl(alu_ctrl)
    );

endmodule