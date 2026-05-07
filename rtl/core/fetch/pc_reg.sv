module pc_reg (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [31:0] next_pc,
    output logic [31:0] pc
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin           // If rst is active, set PC to 0
            pc <= 32'b0;
        end else begin              // Set next PC value
            pc <= next_pc;
        end
    end

endmodule