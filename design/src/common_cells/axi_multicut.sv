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
  output axi_resp_t slv_resp_o,   // Slave response output
  output axi_req_t  mst_req_o,    // Master request output
  input  axi_resp_t mst_resp_i    // Master response input
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
    assign cut_req[0] = slv_req_i;
    assign slv_resp_o = cut_resp[0];
    assign mst_req_o = cut_req[NoCuts];
    assign cut_resp[NoCuts] = mst_resp_i;

    // TODO: Generate pipeline cuts
    for (genvar i = 0; i < NoCuts; i++) begin : gen_cut
      // AW channel cut
      spill_register #(
        .T      ( aw_chan_t ),
        .Bypass ( 1'b0      )
      ) i_aw_cut (
        .clk_i,
        .rst_ni,
        .valid_i ( cut_req[i].aw_valid    ),
        .ready_o ( cut_resp[i].aw_ready   ),
        .data_i  ( cut_req[i].aw          ),
        .valid_o ( cut_req[i+1].aw_valid  ),
        .ready_i ( cut_resp[i+1].aw_ready ),
        .data_o  ( cut_req[i+1].aw        )
      );

      // W channel cut
      spill_register #(
        .T      ( w_chan_t ),
        .Bypass ( 1'b0     )
      ) i_w_cut (
        .clk_i,
        .rst_ni,
        .valid_i ( cut_req[i].w_valid    ),
        .ready_o ( cut_resp[i].w_ready   ),
        .data_i  ( cut_req[i].w          ),
        .valid_o ( cut_req[i+1].w_valid  ),
        .ready_i ( cut_resp[i+1].w_ready ),
        .data_o  ( cut_req[i+1].w        )
      );

      // B channel cut (response direction)
      spill_register #(
        .T      ( b_chan_t ),
        .Bypass ( 1'b0     )
      ) i_b_cut (
        .clk_i,
        .rst_ni,
        .valid_i ( cut_resp[i+1].b_valid ),
        .ready_o ( cut_resp[i+1].b_ready ),
        .data_i  ( cut_resp[i+1].b       ),
        .valid_o ( cut_resp[i].b_valid   ),
        .ready_i ( cut_req[i].b_ready    ),
        .data_o  ( cut_resp[i].b         )
      );

      // AR channel cut
      spill_register #(
        .T      ( ar_chan_t ),
        .Bypass ( 1'b0      )
      ) i_ar_cut (
        .clk_i,
        .rst_ni,
        .valid_i ( cut_req[i].ar_valid    ),
        .ready_o ( cut_resp[i].ar_ready   ),
        .data_i  ( cut_req[i].ar          ),
        .valid_o ( cut_req[i+1].ar_valid  ),
        .ready_i ( cut_resp[i+1].ar_ready ),
        .data_o  ( cut_req[i+1].ar        )
      );

      // R channel cut (response direction)
      spill_register #(
        .T      ( r_chan_t ),
        .Bypass ( 1'b0     )
      ) i_r_cut (
        .clk_i,
        .rst_ni,
        .valid_i ( cut_resp[i+1].r_valid ),
        .ready_o ( cut_resp[i+1].r_ready ),
        .data_i  ( cut_resp[i+1].r       ),
        .valid_o ( cut_resp[i].r_valid   ),
        .ready_i ( cut_req[i].r_ready    ),
        .data_o  ( cut_resp[i].r         )
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