// FIFO v3 - Simple FIFO implementation
// Basic FIFO for storing and retrieving data

module fifo_v3 #(
  parameter bit          FALL_THROUGH = 1'b0,
  parameter int unsigned DEPTH        = 8,
  parameter type         dtype        = logic [31:0]
) (
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic  flush_i,
  input  logic  testmode_i,
  output logic  full_o,
  output logic  empty_o,
  output logic [$clog2(DEPTH+1)-1:0] usage_o,
  input  dtype  data_i,
  input  logic  push_i,
  output dtype  data_o,
  input  logic  pop_i
);

  dtype [DEPTH-1:0] mem;
  logic [$clog2(DEPTH+1)-1:0] read_ptr, write_ptr, status_cnt;

  // TODO: Implement proper FIFO with all features
  // This is a basic implementation - candidate should enhance for production use

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      read_ptr  <= '0;
      write_ptr <= '0;
      status_cnt <= '0;
    end else if (flush_i) begin
      read_ptr  <= '0;
      write_ptr <= '0;
      status_cnt <= '0;
    end else begin
      if (push_i && !full_o) begin
        mem[write_ptr] <= data_i;
        write_ptr <= (write_ptr + 1) % DEPTH;
        if (!pop_i || empty_o) status_cnt <= status_cnt + 1;
      end
      if (pop_i && !empty_o) begin
        read_ptr <= (read_ptr + 1) % DEPTH;
        if (!push_i || full_o) status_cnt <= status_cnt - 1;
      end
    end
  end

  assign data_o  = mem[read_ptr];
  assign full_o  = (status_cnt == DEPTH);
  assign empty_o = (status_cnt == 0);
  assign usage_o = status_cnt;

endmodule