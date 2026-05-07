module instr_mem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    // 1KB of memory (256 words)
    logic [31:0] rom [0:255];

    // Load the compiled software into the ROM at simulation start
    initial begin
        $readmemh("../tb/program.hex", rom);
    end

    // Asynchronous read (Drop the bottom 2 bits for word alignment)
    assign instr = rom[addr[9:2]];

endmodule