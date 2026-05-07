module wb_stage (
    // Data Inputs
    input  logic [31:0] alu_result,
    input  logic [31:0] read_data,
    
    // Control Signal from ID Stage
    input  logic        mem_to_reg,
    
    // Final Output (Loops back to the Register File)
    output logic [31:0] writeback_data
);

    // The final stage functions as a multiplexer
    // If mem_to_reg is 1, use the memory data. Otherwise, use the ALU result.
    assign writeback_data = (mem_to_reg) ? read_data : alu_result;

endmodule