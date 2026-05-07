module tb_fetch;

    logic        clk;
    logic        rst_n;
    logic [31:0] pc;
    logic [31:0] instr;

    // Instantiate the Fetch unit
    fetch u_fetch (
        .clk(clk),
        .rst_n(rst_n),
        .pc(pc),
        .instr(instr)
    );

    // Generate a 10ns clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // VCD waveform dumping
    initial begin
        $dumpfile("waves.vcd");
        $dumpvars(0, tb_fetch);
    end

    // Test sequence
    initial begin
        // Initialize reset
        rst_n = 0;
        
        // Wait a couple of clock cycles, then release reset
        #15 rst_n = 1;

        // Let it run for a few cycles to fetch our instructions
        #150;

        // End simulation
        $finish;
    end

endmodule