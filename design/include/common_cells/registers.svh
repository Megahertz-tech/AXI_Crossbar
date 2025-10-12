// Common macros and utilities

`ifndef COMMON_CELLS_REGISTERS_SVH_
`define COMMON_CELLS_REGISTERS_SVH_

// FF with load enable and reset value
`define FFLARN(q, d, load, reset_value, clk, rst_n) \
  always_ff @(posedge clk or negedge rst_n) begin \
    if (!rst_n) begin \
      q <= reset_value; \
    end else if (load) begin \
      q <= d; \
    end \
  end

// FF with reset value
`define FFARN(q, d, reset_value, clk, rst_n) \
  always_ff @(posedge clk or negedge rst_n) begin \
    if (!rst_n) begin \
      q <= reset_value; \
    end else begin \
      q <= d; \
    end \
  end

 
`define REG_DFLT_CLK clk_i
`define REG_DFLT_RST rst_ni

// Flip-Flop with asynchronous active-low reset
// __q: Q output of FF
// __d: D input of FF
// __reset_value: value assigned upon reset
// (__clk: clock input)
// (__arst_n: asynchronous reset, active-low)
`define FF(__q, __d, __reset_value, __clk = `REG_DFLT_CLK, __arst_n = `REG_DFLT_RST) \
  always_ff @(posedge (__clk) or negedge (__arst_n)) begin                           \
    if (!__arst_n) begin                                                             \
      __q <= (__reset_value);                                                        \
    end else begin                                                                   \
      __q <= (__d);                                                                  \
    end                                                                              \
  end

`endif
