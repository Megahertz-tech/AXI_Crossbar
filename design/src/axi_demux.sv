/// AXI4+ATOP Demultiplexer
///
/// This module demultiplexes one AXI4+ATOP slave port to multiple AXI4+ATOP master ports.
/// The AW and AR channels each have a `select` input to determine to which master port
/// the current request is sent. The `select` can be driven by an address decoding module
/// to map address ranges to different AXI slaves.
///
/// Key Features:
/// - Configurable number of master ports
/// - Address-based routing via select signals
/// - W channel routing based on AW decisions
/// - B/R response arbitration from master ports
/// - Support for atomic operations (ATOPs)
/// - Optional spill registers for timing closure
///
/// TODO: Students must implement the complete demultiplexer functionality
/// including proper transaction tracking, ID management, and response arbitration.

`include "common_cells/assertions.svh"
`include "common_cells/registers.svh"

module axi_demux #(
  parameter int unsigned AxiIdWidth     = 32'd0,
  parameter bit          AtopSupport    = 1'b1,
  parameter type         aw_chan_t      = logic,
  parameter type         w_chan_t       = logic,
  parameter type         b_chan_t       = logic,
  parameter type         ar_chan_t      = logic,
  parameter type         r_chan_t       = logic,
  parameter type         axi_req_t      = logic,
  parameter type         axi_resp_t     = logic,
  parameter int unsigned NoMstPorts     = 32'd0,
  parameter int unsigned MaxTrans       = 32'd8,
  parameter int unsigned AxiLookBits    = 32'd3,
  parameter bit          UniqueIds      = 1'b0,
  parameter bit          SpillAw        = 1'b1,
  parameter bit          SpillW         = 1'b0,
  parameter bit          SpillB         = 1'b0,
  parameter bit          SpillAr        = 1'b1,
  parameter bit          SpillR         = 1'b0,
  // Dependent parameters, DO NOT OVERRIDE!
  parameter int unsigned SelectWidth    = (NoMstPorts > 32'd1) ? $clog2(NoMstPorts) : 32'd1,
  parameter type         select_t       = logic [SelectWidth-1:0]
) (
  input  logic                          clk_i,
  input  logic                          rst_ni,
  input  logic                          test_i,
  // Slave Port
  input  axi_req_t                      slv_req_i,
  input  select_t                       slv_aw_select_i,
  input  select_t                       slv_ar_select_i,
  output axi_resp_t                     slv_resp_o,
  // Master Ports
  output axi_req_t    [NoMstPorts-1:0]  mst_reqs_o,
  input  axi_resp_t   [NoMstPorts-1:0]  mst_resps_i
);

  // TODO: Implement demultiplexer internal signals
  axi_req_t slv_req_cut;
  axi_resp_t slv_resp_cut;

  logic slv_aw_ready_chan, slv_aw_ready_sel;
  logic slv_aw_valid_chan, slv_aw_valid_sel;

  logic slv_ar_ready_chan, slv_ar_ready_sel;
  logic slv_ar_valid_chan, slv_ar_valid_sel;

  select_t slv_aw_select, slv_ar_select;

  // TODO: Implement spill registers for AW channel
  spill_register #(
    .T       ( aw_chan_t  ),
    .Bypass  ( ~SpillAw   )
  ) i_aw_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.aw_valid    ),
    .ready_o ( slv_aw_ready_chan     ),
    .data_i  ( slv_req_i.aw          ),
    .valid_o ( slv_aw_valid_chan     ),
    .ready_i ( slv_resp_cut.aw_ready ),
    .data_o  ( slv_req_cut.aw        )
  );

  // TODO: Implement spill registers for AR channel
  spill_register #(
    .T       ( ar_chan_t  ),
    .Bypass  ( ~SpillAr   )
  ) i_ar_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.ar_valid    ),
    .ready_o ( slv_ar_ready_chan     ),
    .data_i  ( slv_req_i.ar          ),
    .valid_o ( slv_ar_valid_chan     ),
    .ready_i ( slv_resp_cut.ar_ready ),
    .data_o  ( slv_req_cut.ar        )
  );

  // TODO: Implement spill registers for W channel
  spill_register #(
    .T       ( w_chan_t  ),
    .Bypass  ( ~SpillW   )
  ) i_w_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_req_i.w_valid    ),
    .ready_o ( slv_resp_o.w_ready   ),
    .data_i  ( slv_req_i.w          ),
    .valid_o ( slv_req_cut.w_valid  ),
    .ready_i ( slv_resp_cut.w_ready ),
    .data_o  ( slv_req_cut.w        )
  );

  // TODO: Implement spill registers for B channel
  spill_register #(
    .T       ( b_chan_t  ),
    .Bypass  ( ~SpillB   )
  ) i_b_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_resp_cut.b_valid ),
    .ready_o ( slv_resp_cut.b_ready ),
    .data_i  ( slv_resp_cut.b       ),
    .valid_o ( slv_resp_o.b_valid   ),
    .ready_i ( slv_req_i.b_ready    ),
    .data_o  ( slv_resp_o.b         )
  );

  // TODO: Implement spill registers for R channel
  spill_register #(
    .T       ( r_chan_t  ),
    .Bypass  ( ~SpillR   )
  ) i_r_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_resp_cut.r_valid ),
    .ready_o ( slv_resp_cut.r_ready ),
    .data_i  ( slv_resp_cut.r       ),
    .valid_o ( slv_resp_o.r_valid   ),
    .ready_i ( slv_req_i.r_ready    ),
    .data_o  ( slv_resp_o.r         )
  );

  // TODO: Implement select signal handling
  spill_register #(
    .T       ( select_t   ),
    .Bypass  ( ~SpillAw   )
  ) i_aw_select_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_aw_valid_sel     ),
    .ready_o ( slv_aw_ready_sel     ),
    .data_i  ( slv_aw_select_i      ),
    .valid_o ( /* unused */         ),
    .ready_i ( slv_resp_cut.aw_ready && slv_aw_valid_chan ),
    .data_o  ( slv_aw_select        )
  );

  spill_register #(
    .T       ( select_t   ),
    .Bypass  ( ~SpillAr   )
  ) i_ar_select_spill_reg (
    .clk_i,
    .rst_ni,
    .valid_i ( slv_ar_valid_sel     ),
    .ready_o ( slv_ar_ready_sel     ),
    .data_i  ( slv_ar_select_i      ),
    .valid_o ( /* unused */         ),
    .ready_i ( slv_resp_cut.ar_ready && slv_ar_valid_chan ),
    .data_o  ( slv_ar_select        )
  );

  // TODO: Implement ready/valid logic for select signals
  assign slv_aw_valid_sel = slv_req_i.aw_valid && slv_aw_ready_chan;
  assign slv_ar_valid_sel = slv_req_i.ar_valid && slv_ar_ready_chan;
  assign slv_resp_o.aw_ready = slv_aw_ready_chan && slv_aw_ready_sel;
  assign slv_resp_o.ar_ready = slv_ar_ready_chan && slv_ar_ready_sel;

  // TODO: Complete the demultiplexer implementation
  // Students need to implement:
  // 1. AW/AR channel demultiplexing based on select signals
  // 2. W channel routing using FIFO to track AW decisions
  // 3. B/R channel response arbitration
  // 4. Transaction tracking for ordering constraints
  // 5. Atomic operation support

  // PLACEHOLDER: Basic pass-through (students must replace with full implementation)
  always_comb begin
    // Default assignments
    for (int i = 0; i < NoMstPorts; i++) begin
      mst_reqs_o[i] = '0;
    end
    slv_resp_cut = '0;

    // TODO: Students must implement proper demultiplexing logic here
    // This is just a placeholder to prevent compilation errors
    if (NoMstPorts > 0) begin
      mst_reqs_o[0] = slv_req_cut;
      slv_resp_cut = mst_resps_i[0];
    end
  end

  // TODO: Add parameter validation assertions
  // pragma translate_off
  `ifndef VERILATOR
  `ifndef XSIM
  initial begin : check_params
    assert (NoMstPorts > 0) else
      $fatal(1, "Number of master ports must be > 0");
    assert (AxiIdWidth > 0) else
      $fatal(1, "AXI ID width must be > 0");
    assert (MaxTrans > 0) else
      $fatal(1, "Maximum transactions must be > 0");
    assert (AxiLookBits <= AxiIdWidth) else
      $fatal(1, "Look bits cannot exceed ID width");
  end
  `endif
  `endif
  // pragma translate_on

endmodule