// DFF Top-Level Testbench
`include "dff_pkg.sv"

module dff_tb_top ();
  import uvm_pkg::*;
  import dff_pkg::*;

  // Clock generation
  logic clk = 1'b0;
  always #5ns clk = ~clk;

  // Interface instantiation
  dff_if dff_if_inst (clk);

  // DUT instantiation
  dff dut (
    .clk       (dff_if_inst.clk),
    .reset     (dff_if_inst.reset),
    .data_in   (dff_if_inst.data_in),
    .data_out  (dff_if_inst.data_out),
    .valid     (dff_if_inst.valid)
  );

  // Initial block to run simulation
  initial begin
    // Configure virtual interface in UVM config database
    uvm_config_db #(virtual dff_if.driver)::set(null, "uvm_test_top.env.driver", "vif", dff_if_inst);
    uvm_config_db #(virtual dff_if.monitor)::set(null, "uvm_test_top.env.monitor", "vif", dff_if_inst);

    // Enable waveform dumping (optional)
    // $dumpfile("dff_tb.vcd");
    // $dumpvars(0, dff_tb_top);

    // Run UVM test
    run_test();
  end

  // Optional: Add waveform viewer directives
  initial begin
    $timeformat(-9, 2, "ns", 10);
  end

endmodule
