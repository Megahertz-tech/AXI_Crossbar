/// Multi-Cut Pipeline Module
///
/// This module inserts a configurable number of pipeline stages (cuts) between
/// AXI interfaces to break long combinatorial paths and improve timing closure.
/// Each cut consists of spill registers that can buffer transactions.
///
/// Features:
/// - Configurable number of pipeline stages
/// - Supports all AXI4 channels
/// - No throughput impact when properly configured
/// - Improves timing closure for high-frequency operation
///
/// TODO: Students should implement the pipeline stages using spill registers
/// to achieve the desired timing characteristics for 250MHz+ operation.

`include "common_cells/registers.svh"

module axi_multicut #(
  parameter int unsigned NoCuts    = 32'd1,     // Number of pipeline cuts
  parameter type         aw_chan_t = logic,     // AW channel type
  parameter type         w_chan_t  = logic,     // W channel type
  parameter type         b_chan_t  = logic,     // B channel type
  parameter type         ar_chan_t = logic,     // AR channel type
  parameter type         r_chan_t  = logic,     // R channel type
  parameter type         axi_req_t = logic,     // AXI request type
  parameter type         axi_resp_t = logic     // AXI response type
) (
  input  logic      clk_i,        // Clock
  input  logic      rst_ni,       // Asynchronous reset, active low
  input  axi_req_t  slv_req_i,    // Slave request input
  input  axi_resp_t mst_resp_i,   // Master response input
  output axi_req_t  mst_req_o,    // Master response output
  output axi_resp_t slv_resp_o    // Slave request output
);

  // TODO: Handle the case of no cuts (direct connection)
  if (NoCuts == 0) begin : gen_no_cuts
    assign mst_req_o = slv_req_i;
    assign slv_resp_o = mst_resp_i;

  end else begin : gen_cuts
    // TODO: Implement pipeline stages
    axi_req_t  [NoCuts:0] cut_req;
    axi_resp_t [NoCuts:0] cut_resp;

    // Connect endpoints
    //assign cut_req[0] = slv_req_i;
    //assign slv_resp_o = cut_resp[0];
    //assign mst_req_o = cut_req[NoCuts];
    //assign cut_resp[NoCuts] = mst_resp_i;
    assign cut_req[0]   = slv_req_i;
    assign cut_resp[0]  = mst_resp_i;
    assign slv_resp_o   = cut_resp[NoCuts];
    assign mst_req_o    = cut_req[NoCuts];

    // TODO: Generate pipeline cuts
      logic  b_ready[NoCuts];
      logic  r_ready[NoCuts];
    for (genvar i = 0; i < NoCuts; i++) begin : gen_pipeline
        axi_pipeline #(
            .Bypass     (       1'b0 ),
            .aw_chan_t  (  aw_chan_t ),
            .w_chan_t   (   w_chan_t ),
            .b_chan_t   (   b_chan_t ),
            .ar_chan_t  (  ar_chan_t ),
            .r_chan_t   (   r_chan_t ),
            .axi_req_t  (  axi_req_t ),
            .axi_resp_t ( axi_resp_t )
        ) i_pipeline (
            .clk_i,
            .rst_ni,
            .slv_req_i  ( cut_req[i]    ),
            .mst_resp_i ( cut_resp[i]   ),
            .mst_req_o  ( cut_req[i+1]  ),
            .slv_resp_o ( cut_resp[i+1] )
        );  
    end
  end

  // TODO: Add parameter validation
  // pragma translate_off
  `ifndef VERILATOR
  `ifndef XSIM
  initial begin : check_params
    assert (NoCuts >= 0) else
      $fatal(1, "Number of cuts must be >= 0");
  end
  `endif
  `endif
  // pragma translate_on

endmodule
