module mem_stage (
    input  logic        clk,
    
    // Data from Execute Stage
    input  logic [31:0] alu_result,
    input  logic [31:0] write_data, // This is rs2_data from the EX stage
    
    // Control Signals from ID Stage
    input  logic        mem_read,
    input  logic        mem_write,
    
    // Outputs to Writeback Stage
    output logic [31:0] read_data,
    output logic [31:0] alu_result_out // Passed straight through for R-Type math
);

    // Pass the ALU result straight through (for instructions that don't use memory)
    assign alu_result_out = alu_result;

    // Instantiate the Data Memory
    data_mem u_data_mem (
        .clk(clk),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .addr(alu_result),
        .write_data(write_data),
        .read_data(read_data)
    );

endmodule