/* ***********************************************************
    document:       axi_spill_register.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SPILL_REGISTER_SV__
`define __AXI_SPILL_REGISTER_SV__
module spill_register #(
  parameter type T       = logic,
  parameter bit  Bypass  = 1'b0
) (
  input  logic clk_i,
  input  logic rst_ni,
  input  logic valid_i,
  output logic ready_o,
  input  T     data_i,
  output logic valid_o,
  input  logic ready_i,
  output T     data_o
);

  if (Bypass) begin : gen_bypass
    // Bypass mode - direct connection
    assign valid_o = valid_i;
    assign ready_o = ready_i;
    assign data_o  = data_i;
  end else begin : gen_spill_reg

    // lock data_o when ready_i is nor asserted. 
    logic   a_fill;
    logic   a_full_q;
    T       a_data_q;

    
    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_a_data
      if (!rst_ni)
        a_data_q <= T'('0);
      else if (a_fill)
        a_data_q <= data_i;
    end
    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_a_full
      if (!rst_ni)
        a_full_q <= 0;
      else 
        a_full_q <= a_fill;
    end
    
    

    assign a_fill  = valid_i; 

    assign ready_o = ready_i;
    assign valid_o = valid_i && a_full_q ;
    assign data_o  = a_data_q;


  end

endmodule 



`endif 
