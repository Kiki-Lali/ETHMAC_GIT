# DFF UVM Testbench

A complete UVM testbench for verifying a D Flip-Flop (DFF) design with reset, data input/output, and valid signal.

## Project Structure

```
├── dff_rtl.v           - RTL design of the DFF
├── dff_if.sv           - SystemVerilog interface definition
├── dff_pkg.sv          - UVM package containing all testbench components
├── dff_tb_top.sv       - Top-level testbench module
└── README.md           - This file
```

## DFF RTL Specification

### Ports
- **clk**: Clock input (posedge triggered)
- **reset**: Active-low reset signal
- **data_in**: Single-bit data input
- **data_out**: Single-bit data output
- **valid**: Valid signal (asserted after reset)

### Behavior
- On reset (reset=0): Both `data_out` and `valid` are cleared to 0
- On clock edge: `data_out` captures `data_in`, `valid` is set to 1
- After reset release, the DFF operates normally, capturing data on each clock edge

## UVM Testbench Components

### 1. **dff_seq_item** (Transaction)
The basic transaction class that defines what is being driven and monitored:
- `data_in`: Input data (randomizable)
- `data_out`: Output data (from DUT)
- `valid`: Valid signal (from DUT)

### 2. **dff_driver**
- Drives inputs to the DUT
- Handles reset sequence at the beginning
- Sends `data_in` from generated sequences

### 3. **dff_monitor**
- Collects output transactions from the DUT
- Captures `data_out` and `valid` signals
- Writes collected data to analysis port for scoreboarding

### 4. **dff_scoreboard**
- Compares expected vs. actual output
- Tracks pass/fail statistics
- Reports results at end of simulation

### 5. **dff_env** (Environment)
- Integrates all components: sequencer, driver, monitor, scoreboard
- Manages connections between components

### 6. **Test Classes**
- **dff_base_test**: Base test class
- **dff_random_test**: Applies random input sequences
- **dff_zeros_ones_test**: Tests with alternating all-zeros and all-ones patterns

## Sequences

### dff_random_seq
Generates randomized input data for configurable number of cycles.

### dff_all_zeros_seq
Generates all-zero input patterns (5 cycles).

### dff_all_ones_seq
Generates all-one input patterns (5 cycles).

## Running the Testbench

### Using QuestaSim/ModelSim:
```bash
# Compile
vlog dff_rtl.v dff_if.sv dff_pkg.sv dff_tb_top.sv

# Run (default test - dff_base_test)
vsim dff_tb_top -c -do "run -all; quit"

# Run specific test
vsim dff_tb_top -c -do "run -all; quit" +UVM_TESTNAME=dff_random_test

# Run with GUI
vsim dff_tb_top
```

### Using VCS:
```bash
# Compile and simulate
vcs -sverilog -full64 dff_rtl.v dff_if.sv dff_pkg.sv dff_tb_top.sv -top dff_tb_top

# Run with test specification
./simv +UVM_TESTNAME=dff_random_test

# Run with GUI
./simv -gui +UVM_TESTNAME=dff_random_test
```

### Using Xcelium:
```bash
# Compile
xmvlog dff_rtl.v dff_if.sv dff_pkg.sv dff_tb_top.sv

# Elaborate and simulate
xmsim -access +rwc dff_tb_top +UVM_TESTNAME=dff_random_test
```

## Test Execution Examples

### Test 1: Random Test
```bash
vsim dff_tb_top -c -do "run -all; quit" +UVM_TESTNAME=dff_random_test
```
- Applies 20 random input sequences
- Good for general functionality verification

### Test 2: Zeros and Ones Test
```bash
vsim dff_tb_top -c -do "run -all; quit" +UVM_TESTNAME=dff_zeros_ones_test
```
- Tests pattern sensitivity
- Verifies DFF behavior with repeated values

## Expected Output

The testbench will generate output similar to:

```
UVM_INFO dff_pkg.sv(XXX) @ 0ns [PASS] Data match: expected=0, got=0
UVM_INFO dff_pkg.sv(XXX) @ 10ns [PASS] Data match: expected=0, got=0
UVM_INFO dff_pkg.sv(XXX) @ 20ns [PASS] Data match: expected=1, got=1
...
UVM_INFO dff_pkg.sv(XXX) [SCORE] Passed: 25, Failed: 0
```

## Coverage (Optional Enhancement)

To add functional coverage, extend the testbench with:
```systemverilog
class dff_coverage extends uvm_subscriber #(dff_seq_item);
  // Define covergroups for:
  // - data_in transitions (0->1, 1->0)
  // - data_out vs data_in correlation
  // - valid signal assertion
endclass
```

## Extension Points

1. **Add Assertions**: Add SVA properties for timing checks
2. **Add Coverage**: Implement covergroups to track functional coverage
3. **Add Functional Checks**: Extend scoreboard with timing verification
4. **Add More Sequences**: Create directed sequences for specific scenarios
5. **Add Formal Verification**: Create properties for formal analysis

## Files Summary

| File | Purpose |
|------|---------|
| dff_rtl.v | DFF RTL implementation |
| dff_if.sv | Interface with clocking blocks |
| dff_pkg.sv | UVM components package |
| dff_tb_top.sv | Testbench instantiation |
| README.md | Documentation |

## Key Features

✓ Complete UVM hierarchy (env, sequencer, driver, monitor, scoreboard)
✓ Multiple test cases with different stimulus patterns
✓ Functional verification with pass/fail tracking
✓ SystemVerilog interface with clocking blocks
✓ Proper reset sequence handling
✓ Analysis port for scoreboarding

## Notes

- The DFF is a simple 1-bit design; can be extended to N-bit design
- Clock period is 10ns (5ns high, 5ns low)
- Reset sequence uses 2 clock cycles
- Scoreboard compares previous cycle output with current output
