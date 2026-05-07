# RISC-V RV32I Pipelined Processor Core

## Overview
This project implements a 32-bit RISC-V processor core targeting the RV32I Base Integer Instruction Set. The architecture is designed around a classic 5-stage RISC pipeline (Fetch, Decode, Execute, Memory, Writeback). 

The design is written in modern SystemVerilog, emphasizing clean separation between sequential state elements and combinational logic. Verification is handled via unit testbenches using Icarus Verilog (`iverilog`) and GTKWave.

## Directory Architecture
The workspace is strictly organized to separate RTL, verification, and build artifacts:

    rv32i_core/
    ├── docs/       # Architecture diagrams and technical documentation
    ├── rtl/        # Synthesizable SystemVerilog design files
    │   ├── core/
    │   │   ├── fetch/      # Program Counter and Instruction Memory
    │   │   ├── decode/     # Register File, Control, and Immediate Generation
    │   │   ├── execute/    # ALU and Branch Target Calculation
    │   │   ├── memory/     # Data Memory and Access Logic
    │   │   └── writeback/  # Register Writeback Multiplexers
    │   └── top/            # Top-level integration and Pipeline Registers
    ├── tb/         # SystemVerilog Unit Testbenches and Hex Software
    └── scripts/    # Makefiles for automated compilation and simulation

## Implemented Instruction Set (RV32I Base)
The core currently decodes and executes the following instruction types:
* **R-Type (Register-to-Register):** `add`, `sub`, `sll`, `slt`, `sltu`, `xor`, `srl`, `sra`, `or`, `and`
* **I-Type (Immediate ALU):** `addi`, `ori`, etc. (using sign-extended 12-bit immediate)
* **I-Type (Load):** `lw` (Load Word)
* **S-Type (Store):** `sw` (Store Word)
* **B-Type (Branch):** `beq`, `bne`, etc. (Branch calculation supported in EX stage)
* **J-Type / U-Type:** `jal`, `lui` (Jump and Link, Load Upper Immediate)

*(Note: The M-Extension for Hardware Multiplication/Division is intentionally excluded to maintain single-cycle execution within the EX stage).*

---

## Pipeline Stage Breakdown

### 1. Instruction Fetch (IF) Stage
**Location:** `rtl/core/fetch/`
Responsible for maintaining the instruction pointer and fetching machine code.
* **`pc_reg.sv`:** A synchronous 32-bit Program Counter register with an active-low asynchronous reset. 
* **`instr_mem.sv`:** A 1KB word-aligned Read-Only Memory (ROM) block. It uses asynchronous reads to fetch the 32-bit instruction at `PC[9:2]`. Loads compiled machine code (`program.hex`) at initialization.
* **`fetch.sv`:** The stage wrapper. Includes a dedicated +4 adder for sequential execution and a multiplexer to route jump/branch targets coming from the Execute stage.

### 2. Instruction Decode (ID) Stage
**Location:** `rtl/core/decode/`
The central nervous system of the processor. It slices the 32-bit instruction, reads registers, and generates all control signals for downstream stages.
* **`decode.sv`:** Pure combinational logic that statically slices the RISC-V instruction into `opcode`, `rd`, `funct3`, `rs1`, `rs2`, and `funct7` fields.
* **`regfile.sv`:** A 32x32-bit dual-port synchronous register file. Features instantaneous asynchronous reads for `rs1` and `rs2`. Register `x0` is hardwired to zero.
* **`imm_gen.sv`:** Combinational logic that extracts and sign-extends immediate values based on the instruction format (I, S, B, U, J) dictated by the opcode.
* **`control_unit.sv`:** The main decoder. Reads the 7-bit opcode and sets global flags (`alu_src`, `mem_write`, `reg_write`, etc.). Outputs a 2-bit `alu_op` code to categorize the math operation.
* **`alu_control.sv`:** The secondary decoder. Takes the `alu_op`, `funct3`, and bit 30 of the instruction (`funct7[5]`) to output a strict 4-bit command to the ALU.
* **`id_stage.sv`:** The structural wrapper that connects the slicing logic, register file, and control units together.

### 3. Execute (EX) Stage
**Location:** `rtl/core/execute/`
A purely combinational stage that performs all mathematical, logical, and address calculations.
* **`alu.sv`:** The Arithmetic Logic Unit. Executes operations based on the 4-bit `alu_ctrl` signal. Includes a `zero` flag output for branch evaluations.
* **`ex_stage.sv`:** Wraps the ALU and includes the `ALUSrc` multiplexer (choosing between `rs2` or the immediate value). Also contains a dedicated adder to calculate the `branch_target` by adding the immediate to the current PC.

### 4. Memory (MEM) Stage
**Location:** `rtl/core/memory/`
Handles RAM interactions for Load and Store instructions.
* **`data_mem.sv`:** A 1KB word-aligned Read/Write memory array. Features synchronous writes (on the clock edge) and asynchronous reads.
* **`mem_stage.sv`:** Wraps the memory block and provides a clean pass-through wire for `alu_result` for instructions that do not require memory access.

### 5. Writeback (WB) Stage
**Location:** `rtl/core/writeback/`
The final routing stage that closes the loop back to the Instruction Decode stage.
* **`wb_stage.sv`:** A combinational wrapper containing a 2-to-1 multiplexer controlled by the `mem_to_reg` signal. It selects between the raw ALU computation or the data retrieved from RAM to be written back into the Register File.

---

## Top-Level Integration & Pipeline Registers
**Location:** `rtl/top/`
The disparate combinational and sequential stages are unified in `rv32i_core.sv`. 

To achieve true pipelined execution, synchronous Pipeline Registers (`always_ff` blocks) are inserted between every stage (IF/ID, ID/EX, EX/MEM, MEM/WB). These registers capture the data and control signals at the end of a clock cycle and hold them stable for the next stage, allowing up to five separate instructions to be in flight simultaneously.

## Hazard Management (Current Architecture)
This implementation represents a "raw" pipeline. It currently does not feature a hardware Data Forwarding Network or a Hazard Detection/Stall Unit. 

* **Data Hazards (Read-After-Write):** Must be resolved in software. The compiler (or assembly programmer) is responsible for inserting 3 `NOP` instructions between an instruction that writes to a register and a subsequent instruction that reads from it.
* **Control Hazards:** Because branch decisions are resolved in the EX stage, the processor aggressively fetches the next sequential instructions. The compiler must insert 2 `NOP` instructions immediately following a branch to prevent unverified "ghost" instructions from altering the processor state while the PC rewinds.

---

## Verification Methodology
Verification is performed via bottom-up unit testing. Each pipeline stage wrapper is tested in isolation before full system integration.

* **Toolchain:** Icarus Verilog (`iverilog`) for compilation/simulation, and GTKWave for `.vcd` waveform inspection.
* **Linting:** Verilator is utilized for strict, enterprise-grade semantic checks and synthesizability verification prior to simulation.
* **Automation:** A unified `Makefile` drives the compile-simulate-view process.

### Test Suites:
* `tb_fetch.sv`: Verifies PC incrementing and correct hex-code fetching.
* `tb_id.sv`: Injects faked register writebacks and verifies proper opcode decoding and immediate sign-extension.
* `tb_ex.sv`: Isolates the ALU to verify combinational math, multiplexer routing, and branch target generation.
* `tb_mem.sv`: Verifies synchronous writes and asynchronous reads to the data RAM.
* **`tb_core.sv`:** The top-level system testbench. It boots the fully integrated processor, clocks the pipeline, and executes compiled C/Assembly code loaded from `program.hex`, verifying terminal state through register and memory array inspection.