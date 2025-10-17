// FIFO v3 - Simple FIFO implementation
// Basic FIFO for storing and retrieving data

module fifo_v3 #(
  parameter bit          FALL_THROUGH = 1'b0,
  parameter int unsigned DEPTH        = 8,
  parameter type         dtype        = logic [31:0],
  // Dependent parameters, DO NOT OVERRIDE!
  parameter int unsigned PONT_WIDTH  = axi_math_pkg::is_pow2(DEPTH) ? $clog2(DEPTH) + 1 : $clog2(DEPTH)
) (
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic  flush_i,
  input  logic  testmode_i,
  output logic  full_o,
  output logic  empty_o,
  input  dtype  data_i,
  input  logic  push_i,
  output dtype  data_o,
  input  logic  pop_i,
  output logic[PONT_WIDTH-1:0]  usage_o
);

    // Local parameters
    localparam int unsigned ADDR_WIDTH = $clog2(DEPTH);

    //internal signals
    dtype [ADDR_WIDTH-1:0]  mem;
    logic [PONT_WIDTH-1:0]  read_ptr, write_ptr, status_cnt;

    //status 
    assign full_o  = (status_cnt == DEPTH);
    assign empty_o = (status_cnt == 0);

    //output
    assign data_o  = mem[read_ptr];
    assign usage_o = status_cnt;


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
          //push
          if (push_i && !full_o) begin
              mem[write_ptr] <= data_i;
              write_ptr <= (write_ptr + 1) % DEPTH;
              if (!pop_i || empty_o) begin 
                  status_cnt <= status_cnt + 1;
              end
          end
          //pop
          if (pop_i && !empty_o) begin
              read_ptr <= (read_ptr + 1) % DEPTH;
              if (!push_i || full_o) begin 
                  status_cnt <= status_cnt - 1;
              end
          end
      end
    end


endmodule
