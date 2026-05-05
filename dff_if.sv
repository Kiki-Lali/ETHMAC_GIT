// DFF SystemVerilog Interface
interface dff_if (input clk);
  logic       reset;
  logic       data_in;
  logic       data_out;
  logic       valid;

  // Clocking block for testbench
  clocking cb @(posedge clk);
    default input #1ns output #1ns;
    output reset;
    output data_in;
    input  data_out;
    input  valid;
  endclocking

  // Modport for driver
  modport driver (clocking cb, output reset, output data_in);

  // Modport for monitor
  modport monitor (input clk, input reset, input data_in, input data_out, input valid);

endinterface
