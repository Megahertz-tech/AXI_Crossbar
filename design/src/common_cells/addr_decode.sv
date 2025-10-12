/// Address Decoder
///
/// This module decodes an input address and outputs the index of the range in the address map
/// that matches the address. If the address does not match any range, the decode error flag
/// is asserted and optionally a default index can be returned.
///
/// Requirements:
/// - Address map rules must be ordered by priority (higher index = higher priority)
/// - Address ranges are inclusive of start address, exclusive of end address
/// - addr >= start_addr && addr < end_addr for a match
///
/// TODO: Students should implement the address decoding logic including
/// priority handling and default routing for unmapped addresses.

module addr_decode #(
  parameter int unsigned NoIndices = 32'd0,    // Number of indices to decode to
  parameter int unsigned NoRules   = 32'd0,    // Number of rules in the address map
  parameter type         addr_t    = logic,    // Address type
  parameter type         rule_t    = logic     // Rule type with idx, start_addr, end_addr fields
) (
  input  addr_t                        addr_i,            // Address to decode
  input  rule_t     [NoRules-1:0]      addr_map_i,        // Address map rules
  output logic      [$clog2(NoIndices)-1:0] idx_o,        // Decoded index
  output logic                         dec_valid_o,       // Valid decode (address matched a rule)
  output logic                         dec_error_o,       // Decode error (no rule matched)
  input  logic                         en_default_idx_i,  // Enable default index for unmatched addresses
  input  logic      [$clog2(NoIndices)-1:0] default_idx_i // Default index for unmatched addresses
);

  // TODO: Implement address decode logic
  logic [NoRules-1:0] rule_matches;
  logic [NoRules-1:0] rule_enables;
  logic [$clog2(NoRules)-1:0] matched_rule_idx;
  logic any_rule_match;

  // TODO: Check each rule for address match
  for (genvar i = 0; i < NoRules; i++) begin : gen_rule_check
    assign rule_matches[i] = (addr_i >= addr_map_i[i].start_addr) &&
                            (addr_i < addr_map_i[i].end_addr);
  end

  // TODO: Priority encoder to find highest priority matching rule
  // Higher index rules have higher priority
  always_comb begin
    rule_enables = '0;
    matched_rule_idx = '0;
    any_rule_match = 1'b0;

    // Find highest priority match (search from highest to lowest index)
    for (int i = NoRules-1; i >= 0; i--) begin
      if (rule_matches[i]) begin
        rule_enables[i] = 1'b1;
        matched_rule_idx = i;
        any_rule_match = 1'b1;
        break;
      end
    end
  end

  // TODO: Output logic
  always_comb begin
    if (any_rule_match) begin
      // Address matched a rule
      idx_o = addr_map_i[matched_rule_idx].idx;
      dec_valid_o = 1'b1;
      dec_error_o = 1'b0;
    end else if (en_default_idx_i) begin
      // No rule matched, but default is enabled
      idx_o = default_idx_i;
      dec_valid_o = 1'b1;
      dec_error_o = 1'b0;
    end else begin
      // No rule matched and no default
      idx_o = '0;
      dec_valid_o = 1'b0;
      dec_error_o = 1'b1;
    end
  end

  // TODO: Add assertions for parameter validation
  // pragma translate_off
  `ifndef VERILATOR
  `ifndef XSIM
  initial begin : check_params
    assert (NoIndices > 0) else
      $fatal(1, "Number of indices must be > 0");
    assert (NoRules > 0) else
      $fatal(1, "Number of rules must be > 0");
  end

  // Check address map consistency
  for (genvar i = 0; i < NoRules; i++) begin : gen_rule_check_assert
    assert property (@(posedge 1'b1) disable iff (1'b0)
      addr_map_i[i].start_addr <= addr_map_i[i].end_addr)
      else $error("Rule %0d: start address must be <= end address", i);

    assert property (@(posedge 1'b1) disable iff (1'b0)
      addr_map_i[i].idx < NoIndices)
      else $error("Rule %0d: index %0d exceeds maximum %0d",
                  i, addr_map_i[i].idx, NoIndices-1);
  end
  `endif
  `endif
  // pragma translate_on

endmodule