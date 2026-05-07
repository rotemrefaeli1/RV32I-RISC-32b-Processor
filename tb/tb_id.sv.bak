module tb_id;

    // Inputs to ID stage
    logic        clk;
    logic [31:0] instr;
    logic        wb_reg_write;
    logic [4:0]  wb_rd_addr;
    logic [31:0] wb_rd_data;

    // Outputs from ID stage
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm_out;
    logic [4:0]  rs1_addr_out;
    logic [4:0]  rs2_addr_out;
    logic [4:0]  rd_addr_out;
    
    // Control outputs
    logic        branch, jump, mem_read, mem_to_reg;
    logic [3:0]  alu_ctrl;
    logic        mem_write, alu_src, reg_write;

    // Instantiate the ID wrapper
    id_stage u_id_stage (
        .clk(clk),
        .instr(instr),
        .wb_reg_write(wb_reg_write),
        .wb_rd_addr(wb_rd_addr),
        .wb_rd_data(wb_rd_data),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .imm_out(imm_out),
        .rs1_addr_out(rs1_addr_out),
        .rs2_addr_out(rs2_addr_out),
        .rd_addr_out(rd_addr_out),
        .branch(branch),
        .jump(jump),
        .mem_read(mem_read),
        .mem_to_reg(mem_to_reg),
        .alu_ctrl(alu_ctrl),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .reg_write(reg_write)
    );

    // Generate a 10ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD waveform dumping
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_id);
    end

    // The Test Sequence
    initial begin
        // 1. Initialize variables (Default to a NOP instruction)
        wb_reg_write = 0;
        wb_rd_addr   = 0;
        wb_rd_data   = 0;
        instr        = 32'h00000013; // addi x0, x0, 0
        #10;

        // 2. Fake the Writeback Stage: Write decimal 10 into register x1
        wb_reg_write = 1;
        wb_rd_addr   = 5'd1;        // Destination = x1
        wb_rd_data   = 32'd10;      // Value = 10
        #10;
        wb_reg_write = 0;           // Turn off write enable

        // 3. Fake the Writeback Stage: Write decimal 20 into register x2
        wb_reg_write = 1;
        wb_rd_addr   = 5'd2;        // Destination = x2
        wb_rd_data   = 32'd20;      // Value = 20
        #10;
        wb_reg_write = 0;

        // TEST A: R-Type Instruction (ADD x3, x1, x2)
        // Machine code: 002081b3
        instr = 32'h002081b3;
        #10;

        // TEST B: I-Type Load Instruction (LW x5, 4(x1))
        // Machine code: 0040a283 (Immediate = 4)
        instr = 32'h0040a283;
        #10;

        // TEST C: B-Type Branch Instruction (BEQ x1, x2, 8)
        // Machine code: 00208463 (Immediate = 8)
        instr = 32'h00208463;
        #10;

        $finish;
    end

endmodule