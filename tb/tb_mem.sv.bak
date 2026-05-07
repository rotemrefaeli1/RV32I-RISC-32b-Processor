module tb_mem;

    // Inputs
    logic        clk;
    logic [31:0] alu_result;
    logic [31:0] write_data;
    logic        mem_read;
    logic        mem_write;

    // Outputs
    logic [31:0] read_data;
    logic [31:0] alu_result_out;

    // Instantiate the Memory wrapper
    mem_stage u_mem_stage (
        .clk(clk),
        .alu_result(alu_result),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .read_data(read_data),
        .alu_result_out(alu_result_out)
    );

    // Generate a 10ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD waveform dumping
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_mem);
    end

    // Test Sequence
    initial begin
        // Initialize
        mem_read   = 0;
        mem_write  = 0;
        alu_result = 0;
        write_data = 0;
        #15;

        // ---------------------------------------------------------
        // TEST A: Pass-through (Simulating an R-Type like ADD)
        // ---------------------------------------------------------
        alu_result = 32'h00000042; // Random ALU result
        #10;
        // alu_result_out should instantly mirror alu_result. read_data should be 0.

        // ---------------------------------------------------------
        // TEST B: Store Word (SW)
        // ---------------------------------------------------------
        // Write the hex value DEADBEEF to memory address 16 (Hex 10)
        mem_write  = 1;
        alu_result = 32'h00000010; 
        write_data = 32'hDEADBEEF;
        #10; // Wait one clock cycle for the synchronous write to occur
        mem_write  = 0;
        
        // ---------------------------------------------------------
        // TEST C: Load Word (LW)
        // ---------------------------------------------------------
        // Read back from memory address 16 to see if our data is there
        mem_read   = 1;
        alu_result = 32'h00000010;
        #10;
        mem_read   = 0;

        $finish;
    end

endmodule