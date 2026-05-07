module tb_core;

    logic clk;
    logic rst_n;

    // Instantiate the Top-Level Processor
    rv32i_core u_core (
        .clk(clk),
        .rst_n(rst_n)
    );

    // Generate a 10ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Generate VCD waveforms
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_core);
    end

    // The Reset Sequence and Execution
    initial begin
        rst_n = 0; // Hold processor in reset
        #15;
        rst_n = 1; // Release reset, let it run!
        
        // Let the pipeline run for 500 nanoseconds to finish the loop
        #500;
        
        // ---------------------------------------------------------
        // TERMINAL OUTPUT
        // ---------------------------------------------------------
        $display("\n========================================");
        $display("   RISC-V PIPELINE EXECUTION COMPLETE   ");
        $display("========================================");
        
        // If the branch worked perfectly, x1 should have counted down to exactly 0.
        $display("Final value of x1: %0d (Expected: 0)", u_core.u_id_stage.u_regfile.registers[1]);
        
        $display("========================================\n");
        
        $finish;
    end

endmodule