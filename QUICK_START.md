# DFF UVM Testbench - Quick Start Guide

## What's Included

A complete UVM testbench for a D Flip-Flop with the following files:

### Core Design Files
- **dff_rtl.v** - RTL implementation of DFF with clk, reset, data_in, data_out, valid
- **dff_if.sv** - SystemVerilog interface for communication

### UVM Testbench Files
- **dff_pkg.sv** - All UVM components (driver, monitor, scoreboard, sequences, tests)
- **dff_tb_top.sv** - Top-level testbench that ties everything together

### Build & Documentation
- **Makefile** - Automated build and run targets
- **DFF_TESTBENCH_README.md** - Detailed documentation
- **QUICK_START.md** - This file

## Quick Start

### Option 1: Using Makefile (Recommended)

```bash
# Run default random test
make run_questa

# Run specific test
make run_questa TEST_NAME=dff_zeros_ones_test

# Run with GUI
make gui

# Clean generated files
make clean
```

### Option 2: Manual Run (QuestaSim)

```bash
# Compile
vlog -sv dff_rtl.v dff_if.sv dff_pkg.sv dff_tb_top.sv

# Run
vsim dff_tb_top -c -do "run -all; quit" +UVM_TESTNAME=dff_random_test
```

### Option 3: Using VCS

```bash
# Compile and link
vcs -sverilog -full64 dff_rtl.v dff_if.sv dff_pkg.sv dff_tb_top.sv -top dff_tb_top

# Run
./simv +UVM_TESTNAME=dff_random_test
```

## Available Tests

### 1. **dff_random_test** (Default)
- Applies 20 random input patterns
- Good for general functionality check
- Command: `make run_questa TEST_NAME=dff_random_test`

### 2. **dff_zeros_ones_test**
- Tests all-zeros pattern (5 cycles)
- Tests all-ones pattern (5 cycles)
- Good for edge case verification
- Command: `make run_questa TEST_NAME=dff_zeros_ones_test`

## Expected Results

Successful test run output:
```
UVM_INFO ... [PASS] Data match: expected=0, got=0
UVM_INFO ... [PASS] Data match: expected=0, got=1
...
UVM_INFO ... [SCORE] Passed: 20, Failed: 0
```

## File Descriptions

| File | Lines | Purpose |
|------|-------|---------|
| dff_rtl.v | 18 | DFF RTL module |
| dff_if.sv | 22 | SystemVerilog interface |
| dff_pkg.sv | 280+ | Complete UVM package |
| dff_tb_top.sv | 30 | Testbench top module |

## DFF Ports

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
| clk | input | 1 | Clock (posedge triggered) |
| reset | input | 1 | Active-low async reset |
| data_in | input | 1 | Input data |
| data_out | output | 1 | Output data (delayed by 1 clock) |
| valid | output | 1 | Valid indicator (0 during reset) |

## DFF Behavior

```
Reset Sequence:
  reset=0 -> data_out=0, valid=0
  reset=1 (released)
  Next clock -> data_out captures data_in, valid=1

Normal Operation:
  Each clock edge: data_out <= data_in
                   valid <= 1
```

## How to Modify

### Add a New Test
1. Add a class in dff_pkg.sv extending `dff_base_test`
2. Implement `run_phase` with desired sequences
3. Run with: `+UVM_TESTNAME=your_test_name`

### Add a New Sequence
1. Create class in dff_pkg.sv extending `dff_base_seq`
2. Implement `body()` task with desired transaction generation
3. Instantiate and run in test's run_phase

### Modify DFF RTL
1. Edit dff_rtl.v to add/change functionality
2. Recompile: `vlog -sv dff_rtl.v`
3. Re-run tests

## Troubleshooting

### Compilation Error: "Unknown interface"
- Make sure dff_if.sv is compiled before dff_tb_top.sv
- Use: `vlog -sv dff_rtl.v dff_if.sv dff_pkg.sv dff_tb_top.sv`

### Test Shows All Failures
- Verify DFF RTL is correct
- Check reset sequence in dff_driver
- Enable waveform dumping (uncomment in dff_tb_top.sv)

### Undefined Test Name
- Check spelling: `dff_random_test` or `dff_zeros_ones_test`
- Make sure test class is registered with `uvm_component_utils`

## Next Steps

1. **Run the default test**: `make run_questa`
2. **Try other test**: `make run_questa TEST_NAME=dff_zeros_ones_test`
3. **View detailed documentation**: See `DFF_TESTBENCH_README.md`
4. **Extend the testbench**: Add coverage, assertions, or more tests

## Support Files

For detailed information, refer to:
- Architecture: See "UVM Testbench Components" in DFF_TESTBENCH_README.md
- Compilation: See "Running the Testbench" section
- Adding coverage: See "Extension Points" section

---

**Note**: All files use SystemVerilog. Ensure your simulator supports SV (ModelSim, QuestaSim, VCS, Xcelium, etc.)
