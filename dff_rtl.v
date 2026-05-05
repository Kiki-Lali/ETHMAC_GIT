// DFF RTL Module
module dff (
  input  clk,
  input  reset,
  input  data_in,
  output reg data_out,
  output reg valid
);

  always @(posedge clk or negedge reset) begin
    if (!reset) begin
      data_out <= 1'b0;
      valid    <= 1'b0;
    end else begin
      data_out <= data_in;
      valid    <= 1'b1;
    end
  end

endmodule
