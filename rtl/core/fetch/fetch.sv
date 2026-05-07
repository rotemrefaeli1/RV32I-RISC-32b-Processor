module fetch (
    input  logic        clk,
    input  logic        rst_n,
    
    // New inputs for branching
    input  logic        pc_src,
    input  logic [31:0] branch_target,
    
    // Outputs to the IF/ID pipeline register
    output logic [31:0] pc_out,
    output logic [31:0] instr_out
);

    logic [31:0] pc_next, pc_plus_4;

    // The PC Multiplexer: If pc_src is 1, jump. Otherwise, go to PC + 4.
    assign pc_plus_4 = pc_out + 4;
    assign pc_next   = (pc_src) ? branch_target : pc_plus_4;

    // Instantiate the Program Counter register
    pc_reg u_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(pc_next),
        .pc(pc_out)
    );

    // Instantiate the Instruction Memory
    instr_mem u_instr_mem (
        .addr(pc_out),
        .instr(instr_out)
    );

endmodule