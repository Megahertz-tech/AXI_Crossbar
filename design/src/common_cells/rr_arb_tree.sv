// Round-Robin Arbiter Tree
// Arbitrates between multiple requestors using round-robin policy

module rr_arb_tree #(
  parameter int unsigned NumIn      = 4,
  parameter type         DataType   = logic,
  parameter bit          AxiVldRdy  = 1'b0,
  parameter bit          LockIn     = 1'b0,
  parameter bit          FairArb    = 1'b1,
  parameter bit          ExtPrio    = 1'b0
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic                 flush_i,
  input  logic [NumIn-1:0]     rr_i,
  input  logic [NumIn-1:0]     req_i,
  input  DataType [NumIn-1:0]  data_i,
  input  logic                 gnt_i,
  output logic [NumIn-1:0]     gnt_o,
  output logic                 req_o,
  output DataType              data_o,
  output logic [$clog2(NumIn)-1:0] idx_o
);

  // Simple priority-based arbitration (candidate can improve to true round-robin)
  logic [NumIn-1:0] req_masked;
  logic [$clog2(NumIn)-1:0] winner_idx;

  // TODO: Implement proper round-robin arbitration
  // This is a simplified priority arbiter - candidate should enhance
  always_comb begin
    req_masked = req_i;
    winner_idx = 0;
    for (int i = NumIn-1; i >= 0; i--) begin
      if (req_masked[i]) winner_idx = i;
    end
  end

  assign idx_o = winner_idx;
  assign req_o = |req_i;
  assign data_o = data_i[winner_idx];

  always_comb begin
    gnt_o = '0;
    if (req_o && gnt_i) begin
      gnt_o[winner_idx] = 1'b1;
    end
  end

endmodule