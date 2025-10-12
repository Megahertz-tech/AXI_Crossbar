// Common assertions for SystemVerilog designs

`ifndef COMMON_CELLS_ASSERTIONS_SVH_
`define COMMON_CELLS_ASSERTIONS_SVH_

// Basic assertion macro
`define ASSERT_INIT(name, condition) \
  initial begin \
    assert (condition) else $fatal(1, "Assertion %s failed", `"name`"); \
  end

// Clock-based assertion macro
`define ASSERT(name, condition, clk, rst_n) \
  assert property (@(posedge clk) disable iff (!rst_n) condition) \
    else $error("Assertion %s failed", `"name`");

`endif