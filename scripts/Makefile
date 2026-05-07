# --- rv32i_core/scripts/Makefile ---

# Directory mapping
ROOT_DIR = ..
RTL_DIR  = $(ROOT_DIR)/rtl
TB_DIR   = $(ROOT_DIR)/tb
WORK_DIR = $(ROOT_DIR)/work

# Find all Verilog and SystemVerilog files
RTL_SRC = $(wildcard $(RTL_DIR)/core/*/*.sv $(RTL_DIR)/top/*.sv)
TB_SRC  = $(wildcard $(TB_DIR)/*.sv $(TB_DIR)/*.v)

# Output files
SIM_BIN = $(WORK_DIR)/sim.vvp
WAVES   = $(WORK_DIR)/waves.vcd

# Make targets
.PHONY: all compile simulate waves clean

all: simulate

compile:
	@mkdir -p $(WORK_DIR)
	@echo "Compiling design..."
	iverilog -g2012 -o $(SIM_BIN) $(RTL_SRC) $(TB_SRC)

simulate: compile
	@echo "Running simulation..."
	cd $(WORK_DIR) && vvp sim.vvp

waves:
	@echo "Opening GTKWave..."
	gtkwave $(WAVES) &

clean:
	@echo "Cleaning workspace..."
	rm -rf $(WORK_DIR)/*
