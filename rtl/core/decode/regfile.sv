module regfile (
    input  logic        clk,
    input  logic        we,        // Write Enable
    input  logic [4:0]  rs1_addr,  // Source register 1 address
    input  logic [4:0]  rs2_addr,  // Source register 2 address
    input  logic [4:0]  rd_addr,   // Destination register address
    input  logic [31:0] rd_data,   // Data to write to destination
    
    output logic [31:0] rs1_data,  // Data read from source 1
    output logic [31:0] rs2_data   // Data read from source 2
);

    // 32 registers, each 32 bits wide
    logic [31:0] registers [31:0];

    // Asynchronous read (reads happen instantly in the decode stage)
    assign rs1_data = (rs1_addr != 0) ? registers[rs1_addr] : 32'b0;
    assign rs2_data = (rs2_addr != 0) ? registers[rs2_addr] : 32'b0;

    // Synchronous write (writes happen on the clock edge during Writeback)
    always_ff @(posedge clk) begin
        // Only write if Write Enable is high AND we aren't trying to overwrite x0
        if (we && rd_addr != 0) begin
            registers[rd_addr] <= rd_data;
        end
    end

endmodule