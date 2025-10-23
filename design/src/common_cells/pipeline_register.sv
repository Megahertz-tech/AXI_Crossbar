/* ***********************************************************
    document:       pipeline_register.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __PIPELINE_REGISTER_SV__
`define __PIPELINE_REGISTER_SV__
module  pipeline_register#(
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
  end else begin : gen_pipeline_reg
    assign ready_o = ready_i;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(!rst_ni) begin
            valid_o <= 1'b0;
            data_o  <= '0;
        end
        else begin 
            valid_o <= valid_i;
            data_o  <= data_i;
        end
    end
  end

endmodule 



`endif 
