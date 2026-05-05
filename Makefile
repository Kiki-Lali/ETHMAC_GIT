# Makefile for DFF UVM Testbench

SIMULATOR ?= questa
TEST_NAME ?= dff_random_test
SEED ?= 1

# Source files
RTL_FILES = dff_rtl.v
SV_FILES = dff_if.sv dff_pkg.sv dff_tb_top.sv

# QUESTA/ModelSim
VLOG = vlog
VSIM = vsim
VLOG_FLAGS = -sv
VSIM_FLAGS = -c -do "run -all; quit"

# VCS
VCS = vcs
VCS_FLAGS = -sverilog -full64

# Xcelium
XMVLOG = xmvlog
XMSIM = xmsim
XMELAB = xmelab

.PHONY: help compile run_questa run_vcs run_xcelium clean gui

help:
	@echo "DFF UVM Testbench Makefile"
	@echo "=========================="
	@echo ""
	@echo "Usage: make [target] [SIMULATOR=questa|vcs|xcelium] [TEST_NAME=<test>] [SEED=<seed>]"
	@echo ""
	@echo "Targets:"
	@echo "  compile      - Compile the testbench (default: questa)"
	@echo "  run_questa   - Run with QuestaSim/ModelSim"
	@echo "  run_vcs      - Run with VCS"
	@echo "  run_xcelium  - Run with Xcelium"
	@echo "  gui          - Run with GUI (default: questa)"
	@echo "  clean        - Remove generated files"
	@echo ""
	@echo "Test Names:"
	@echo "  dff_random_test       - Random stimulus test"
	@echo "  dff_zeros_ones_test   - Zeros and ones pattern test"
	@echo ""
	@echo "Examples:"
	@echo "  make run_questa TEST_NAME=dff_random_test"
	@echo "  make run_vcs SEED=42"
	@echo "  make gui"

# QuestaSim/ModelSim compilation
compile:
	$(VLOG) $(VLOG_FLAGS) $(RTL_FILES) $(SV_FILES)

run_questa: compile
	$(VSIM) dff_tb_top $(VSIM_FLAGS) +UVM_TESTNAME=$(TEST_NAME) +UVM_SEED=$(SEED)

gui: compile
	$(VSIM) dff_tb_top -gui +UVM_TESTNAME=$(TEST_NAME) +UVM_SEED=$(SEED) &

# VCS compilation and simulation
vcs_compile:
	$(VCS) $(VCS_FLAGS) $(RTL_FILES) $(SV_FILES) -top dff_tb_top -o dff_sim

run_vcs: vcs_compile
	./dff_sim +UVM_TESTNAME=$(TEST_NAME) +UVM_SEED=$(SEED)

# Xcelium compilation and simulation
xcelium_compile:
	$(XMVLOG) $(RTL_FILES) $(SV_FILES)
	$(XMELAB) dff_tb_top

run_xcelium: xcelium_compile
	$(XMSIM) -access +rwc dff_tb_top +UVM_TESTNAME=$(TEST_NAME) +UVM_SEED=$(SEED)

# Clean up generated files
clean:
	rm -rf work *.shm *.vcd *.log *.history simv simv.daidir *.db *.wdb xcelium.d xcelium.key
	rm -f transcript vsim.wlf

all: run_questa
