module tb_ex;

    // Inputs to EX stage
    logic [31:0] pc;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm_out;
    logic        alu_src;
    logic [3:0]  alu_ctrl;

    // Outputs from EX stage
    logic [31:0] alu_result;
    logic        zero;
    logic [31:0] write_data;
    logic [31:0] branch_target;

    // Instantiate the EX wrapper
    ex_stage u_ex_stage (
        .pc(pc),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_out),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .alu_result(alu_result),
        .zero(zero),
        .write_data(write_data),
        .branch_target(branch_target)
    );

    // VCD waveform dumping
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_ex);
    end

    // The Test Sequence
    initial begin
        // Initialize basic state
        pc       = 32'h00000040; // Set PC = 64
        rs1_data = 32'd15;       // rs1 contains decimal 15
        rs2_data = 32'd10;       // rs2 contains decimal 10
        imm_out  = 32'd20;       // Extracted immediate is 20
        #10;

        // ---------------------------------------------------------
        // TEST A: R-Type ADD (15 + 10 = 25)
        // ---------------------------------------------------------
        alu_src  = 1'b0;    // Use rs2_data
        alu_ctrl = 4'b0000; // Command: ADD
        #10;

        // ---------------------------------------------------------
        // TEST B: R-Type SUB (15 - 10 = 5)
        // ---------------------------------------------------------
        alu_src  = 1'b0;    // Use rs2_data
        alu_ctrl = 4'b1000; // Command: SUB
        #10;

        // ---------------------------------------------------------
        // TEST C: I-Type ADDI (15 + 20 = 35)
        // ---------------------------------------------------------
        alu_src  = 1'b1;    // Use imm_out instead of rs2
        alu_ctrl = 4'b0000; // Command: ADD
        #10;

        // ---------------------------------------------------------
        // TEST D: B-Type Branch (BEQ) where rs1 equals rs2
        // ---------------------------------------------------------
        rs2_data = 32'd15;  // Change rs2 so rs1 == rs2 (15 == 15)
        imm_out  = 32'd8;   // Branch forward by 8 bytes
        alu_src  = 1'b0;    // Branch uses rs2 for comparison
        alu_ctrl = 4'b1000; // Command: SUB (15 - 15 = 0)
        #10;

        $finish;
    end

endmodule