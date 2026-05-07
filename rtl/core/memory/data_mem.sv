module data_mem (
    input  logic        clk,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    
    output logic [31:0] read_data
);

    // Create an array of 256 32-bit words (1KB total memory)
    logic [31:0] memory [0:255];

    // Word-aligned Asynchronous Read
    // If mem_read is high, grab the data. We drop the bottom 2 bits [1:0] of the address
    assign read_data = (mem_read) ? memory[addr[9:2]] : 32'b0;

    // Synchronous Write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            memory[addr[9:2]] <= write_data;
        end
    end

endmodule