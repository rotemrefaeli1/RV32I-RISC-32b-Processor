module rv32i_core (
    input logic clk,
    input logic rst_n
);

    // =========================================================================
    // 1. INSTRUCTION FETCH (IF) STAGE
    // =========================================================================
    logic [31:0] if_pc, if_instr;
    
    // PC Source logic (Does the EX stage tell us to jump/branch?)
    logic pc_src;
    logic [31:0] ex_branch_target; // Comes from EX stage

    fetch u_fetch (
        .clk(clk),
        .rst_n(rst_n),
        .pc_src(pc_src),
        .branch_target(ex_branch_target),
        .pc_out(if_pc),
        .instr_out(if_instr)
    );

    // =========================================================================
    // PIPELINE REGISTER: IF/ID
    // =========================================================================
    logic [31:0] id_pc, id_instr;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_pc    <= 32'b0;
            id_instr <= 32'h00000013; // NOP (addi x0, x0, 0)
        end else begin
            id_pc    <= if_pc;
            id_instr <= if_instr;
        end
    end

    // =========================================================================
    // 2. INSTRUCTION DECODE (ID) STAGE
    // =========================================================================
    // Signals coming BACK from Writeback stage
    logic        wb_reg_write;
    logic [4:0]  wb_rd_addr;
    logic [31:0] wb_writeback_data;

    // Outputs from ID stage
    logic [31:0] id_rs1_data, id_rs2_data, id_imm_out;
    logic [4:0]  id_rs1_addr, id_rs2_addr, id_rd_addr;
    logic        id_branch, id_jump, id_mem_read, id_mem_to_reg;
    logic [3:0]  id_alu_ctrl;
    logic        id_mem_write, id_alu_src, id_id_reg_write;

    id_stage u_id_stage (
        .clk(clk),
        .instr(id_instr),
        .wb_reg_write(wb_reg_write),
        .wb_rd_addr(wb_rd_addr),
        .wb_rd_data(wb_writeback_data),
        .rs1_data(id_rs1_data),
        .rs2_data(id_rs2_data),
        .imm_out(id_imm_out),
        .rs1_addr_out(id_rs1_addr),
        .rs2_addr_out(id_rs2_addr),
        .rd_addr_out(id_rd_addr),
        .branch(id_branch),
        .jump(id_jump),
        .mem_read(id_mem_read),
        .mem_to_reg(id_mem_to_reg),
        .alu_ctrl(id_alu_ctrl),
        .mem_write(id_mem_write),
        .alu_src(id_alu_src),
        .reg_write(id_id_reg_write)
    );

    // =========================================================================
    // PIPELINE REGISTER: ID/EX
    // =========================================================================
    logic [31:0] ex_pc, ex_rs1_data, ex_rs2_data, ex_imm_out;
    logic [4:0]  ex_rd_addr;
    logic        ex_branch, ex_jump, ex_mem_read, ex_mem_to_reg;
    logic [3:0]  ex_alu_ctrl;
    logic        ex_mem_write, ex_alu_src, ex_reg_write;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ex_reg_write <= 1'b0; ex_mem_write <= 1'b0; ex_branch <= 1'b0; ex_jump <= 1'b0;
        end else begin
            ex_pc         <= id_pc;
            ex_rs1_data   <= id_rs1_data;
            ex_rs2_data   <= id_rs2_data;
            ex_imm_out    <= id_imm_out;
            ex_rd_addr    <= id_rd_addr;
            
            // Pass along control signals
            ex_branch     <= id_branch;
            ex_jump       <= id_jump;
            ex_mem_read   <= id_mem_read;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_alu_ctrl   <= id_alu_ctrl;
            ex_mem_write  <= id_mem_write;
            ex_alu_src    <= id_alu_src;
            ex_reg_write  <= id_id_reg_write;
        end
    end

    // =========================================================================
    // 3. EXECUTE (EX) STAGE
    // =========================================================================
    logic [31:0] ex_alu_result, ex_write_data;
    logic        ex_zero;

    ex_stage u_ex_stage (
        .pc(ex_pc),
        .rs1_data(ex_rs1_data),
        .rs2_data(ex_rs2_data),
        .imm_out(ex_imm_out),
        .alu_src(ex_alu_src),
        .alu_ctrl(ex_alu_ctrl),
        .alu_result(ex_alu_result),
        .zero(ex_zero),
        .write_data(ex_write_data),
        .branch_target(ex_branch_target)
    );

    // Branch Decision Logic: Jump if it's a JAL, OR if it's a Branch and Zero is true
    assign pc_src = ex_jump | (ex_branch & ex_zero);

    // =========================================================================
    // PIPELINE REGISTER: EX/MEM
    // =========================================================================
    logic [31:0] mem_alu_result, mem_write_data;
    logic [4:0]  mem_rd_addr;
    logic        mem_reg_write, mem_mem_read, mem_mem_write, mem_mem_to_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_reg_write <= 1'b0; mem_mem_write <= 1'b0;
        end else begin
            mem_alu_result <= ex_alu_result;
            mem_write_data <= ex_write_data;
            mem_rd_addr    <= ex_rd_addr;
            
            mem_reg_write  <= ex_reg_write;
            mem_mem_read   <= ex_mem_read;
            mem_mem_write  <= ex_mem_write;
            mem_mem_to_reg <= ex_mem_to_reg;
        end
    end

    // =========================================================================
    // 4. MEMORY (MEM) STAGE
    // =========================================================================
    logic [31:0] mem_read_data, mem_alu_result_out;

    mem_stage u_mem_stage (
        .clk(clk),
        .alu_result(mem_alu_result),
        .write_data(mem_write_data),
        .mem_read(mem_mem_read),
        .mem_write(mem_mem_write),
        .read_data(mem_read_data),
        .alu_result_out(mem_alu_result_out)
    );

    // =========================================================================
    // PIPELINE REGISTER: MEM/WB
    // =========================================================================
    logic [31:0] wb_read_data, wb_alu_result;
    logic        wb_mem_to_reg;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wb_reg_write <= 1'b0;
        end else begin
            wb_read_data  <= mem_read_data;
            wb_alu_result <= mem_alu_result_out;
            wb_rd_addr    <= mem_rd_addr;
            
            wb_reg_write  <= mem_reg_write;
            wb_mem_to_reg <= mem_mem_to_reg;
        end
    end

    // =========================================================================
    // 5. WRITEBACK (WB) STAGE
    // =========================================================================
    wb_stage u_wb_stage (
        .alu_result(wb_alu_result),
        .read_data(wb_read_data),
        .mem_to_reg(wb_mem_to_reg),
        .writeback_data(wb_writeback_data)
    );

endmodule