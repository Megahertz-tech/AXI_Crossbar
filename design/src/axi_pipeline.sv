/* ***********************************************************
    document:       axi_pipeline.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_PIPELINE_SV__
`define __AXI_PIPELINE_SV__
 module axi_pipeline #(
    // bypass enable
    parameter bit  Bypass     = 1'b0,    
    // AXI channel structs
    parameter type  aw_chan_t = logic,
    parameter type   w_chan_t = logic,
    parameter type   b_chan_t = logic,
    parameter type  ar_chan_t = logic,
    parameter type   r_chan_t = logic,
    // AXI request & response structs
    parameter type  axi_req_t = logic,
    parameter type axi_resp_t = logic
 )(
    input logic       clk_i,
    input logic       rst_ni,
    // salve port
    input  axi_req_t  slv_req_i,
    output axi_resp_t slv_resp_o,
    // master port
    output axi_req_t  mst_req_o,
    input  axi_resp_t mst_resp_i
 );
    // a spill register for each channel
   
    
  pipeline_register #(
    .T       ( aw_chan_t ),
    .Bypass  ( Bypass    )
  ) i_reg_aw (
    .clk_i   ( clk_i               ),
    .rst_ni  ( rst_ni              ),
    .valid_i ( slv_req_i.aw_valid  ),
    .ready_o ( slv_resp_o.aw_ready ),
    .data_i  ( slv_req_i.aw        ),
    .valid_o ( mst_req_o.aw_valid  ),
    .ready_i ( mst_resp_i.aw_ready ),
    .data_o  ( mst_req_o.aw        )
  );

  pipeline_register #(
    .T       ( w_chan_t ),
    .Bypass  ( Bypass   )
  ) i_reg_w  (
    .clk_i   ( clk_i              ),
    .rst_ni  ( rst_ni             ),
    .valid_i ( slv_req_i.w_valid  ),
    .ready_o ( slv_resp_o.w_ready ),
    .data_i  ( slv_req_i.w        ),
    .valid_o ( mst_req_o.w_valid  ),
    .ready_i ( mst_resp_i.w_ready ),
    .data_o  ( mst_req_o.w        )
  );

  pipeline_register #(
    .T       ( b_chan_t ),
    .Bypass  ( Bypass   )
  ) i_reg_b  (
    .clk_i   ( clk_i              ),
    .rst_ni  ( rst_ni             ),
    .valid_i ( mst_resp_i.b_valid ),
    .ready_o ( mst_req_o.b_ready  ),
    .data_i  ( mst_resp_i.b       ),
    .valid_o ( slv_resp_o.b_valid ),
    .ready_i ( slv_req_i.b_ready  ),
    .data_o  ( slv_resp_o.b       )
  );

  pipeline_register #(
    .T       ( ar_chan_t ),
    .Bypass  ( Bypass    )
  ) i_reg_ar (
    .clk_i   ( clk_i               ),
    .rst_ni  ( rst_ni              ),
    .valid_i ( slv_req_i.ar_valid  ),
    .ready_o ( slv_resp_o.ar_ready ),
    .data_i  ( slv_req_i.ar        ),
    .valid_o ( mst_req_o.ar_valid  ),
    .ready_i ( mst_resp_i.ar_ready ),
    .data_o  ( mst_req_o.ar        )
  );

  pipeline_register #(
    .T       ( r_chan_t ),
    .Bypass  ( Bypass   )
  ) i_reg_r  (
    .clk_i   ( clk_i              ),
    .rst_ni  ( rst_ni             ),
    .valid_i ( mst_resp_i.r_valid ),
    .ready_o ( mst_req_o.r_ready  ),
    .data_i  ( mst_resp_i.r       ),
    .valid_o ( slv_resp_o.r_valid ),
    .ready_i ( slv_req_i.r_ready  ),
    .data_o  ( slv_resp_o.r       )
  );
endmodule

`endif 
