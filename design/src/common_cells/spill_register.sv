// Spill Register - Pipeline stage for timing closure
// Breaks combinatorial paths while maintaining AXI handshaking

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
    // Spill register mode
    logic a_full, b_full;
    T     a_data, b_data;

    // TODO: Implement proper spill register with full handshaking
    // This is a simplified version - candidate should implement full protocol
    // The A register.
    T a_data_q;
    logic a_full_q;
    logic a_fill, a_drain;

    always_ff @(posedge clk_i or negedge rst_ni) begin
      if (!rst_ni) begin
        a_full <= 1'b0;
        b_full <= 1'b0;
        a_data <= '0;
        b_data <= '0;
      end else begin
        // Simplified spill register logic
        if (valid_i && ready_o) begin
          if (!a_full) begin
            a_full <= 1'b1;
            a_data <= data_i;
          end else if (!b_full) begin
            b_full <= 1'b1;
            b_data <= data_i;
          end
        end

        if (valid_o && ready_i) begin
          if (b_full) begin
            b_full <= 1'b0;
            a_data <= b_data;
          end else if (a_full) begin
            a_full <= 1'b0;
          end
        end
      end
    end

    assign valid_o = a_full | b_full;
    //assign valid_o = a_full;
    assign ready_o = !a_full || (b_full && ready_i);
    //assign ready_o = !a_full || (!b_full && ready_i);
    //assign data_o  = a_data;
    assign data_o  = b_full ? b_data: (a_full? a_data : T'('0));
  end
endmodule
