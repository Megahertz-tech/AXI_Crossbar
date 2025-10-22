/* ***********************************************************
    document:       fifo_v4.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __FIFO_V4_SV__
`define __FIFO_V4_SV__
module fifo_v4 #(
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
  input  logic  push_i,
  input  dtype  data_i,
  input  logic  pop_i,
  output dtype  data_o,
  output logic  full_o,
  output logic  empty_o,
  output logic[PONT_WIDTH-1:0]  usage_o
);

    // Local parameters
    localparam int unsigned ADDR_WIDTH = $clog2(DEPTH);

    //internal signals
    dtype [DEPTH-1:0]  mem;
    logic [PONT_WIDTH-1:0]  read_ptr, write_ptr, status_cnt;
    //logic [PONT_WIDTH-1:0]  out_ptr;

    //status 
    assign full_o  = (status_cnt == DEPTH);
    assign empty_o = (status_cnt == 0);

    //output
    assign data_o  = mem[read_ptr];
    //assign data_o  = mem[out_ptr];
    assign usage_o = status_cnt;
    
    /*
    logic data_i_delay;
    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        data_i_delay <= '0;
      end else begin
        data_i_delay <= data_i;
      end
    end
    */

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        //initiate
        //out_ptr    <= '0;
        read_ptr   <= '0;
        write_ptr  <= '0;
        status_cnt <= '0;
        mem        <= '0;
      end else if (flush_i) begin
        //out_ptr    <= '0;
        read_ptr  <= '0;
        write_ptr <= '0;
        status_cnt <= '0;
      end else begin
          //push
          if (push_i && !full_o) begin
              mem[write_ptr] <= data_i;
              //mem[write_ptr] <= data_i_delay;
              write_ptr <= (write_ptr + 1) % DEPTH;
              if (!pop_i || empty_o) begin 
                  status_cnt <= status_cnt + 1;
              end
          end
          //pop
          if (pop_i && !empty_o) begin
              //out_ptr  <= read_ptr;
              read_ptr <= (read_ptr + 1) % DEPTH;
              if (!push_i || full_o) begin 
                  status_cnt <= status_cnt - 1;
              end
          end
      end
    end


endmodule






`endif 
