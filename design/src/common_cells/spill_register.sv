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

    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_a_data
      if (!rst_ni)
        a_data_q <= T'('0);
      else if (a_fill)
        a_data_q <= data_i;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_a_full
      if (!rst_ni)
        a_full_q <= 0;
      else if (a_fill || a_drain)
        a_full_q <= a_fill;
    end

    // The B register.
    T b_data_q;
    logic b_full_q;
    logic b_fill, b_drain;

    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_b_data
      if (!rst_ni)
        b_data_q <= T'('0);
      else if (b_fill)
        b_data_q <= a_data_q;
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin : ps_b_full
      if (!rst_ni)
        b_full_q <= 0;
      else if (b_fill || b_drain)
        b_full_q <= b_fill;
    end

    // Fill the A register when the A or B register is empty. Drain the A register
    // whenever it is full and being filled, or if a flush is requested.
    assign a_fill = valid_i && ready_o ;
    assign a_drain = (a_full_q && !b_full_q) ;

    // Fill the B register whenever the A register is drained, but the downstream
    // circuit is not ready. Drain the B register whenever it is full and the
    // downstream circuit is ready, or if a flush is requested.
    assign b_fill = a_drain && (!ready_i);
    assign b_drain = (b_full_q && ready_i);

    // We can accept input as long as register B is not full.
    // Note: flush_i and valid_i must not be high at the same time,
    // otherwise an invalid handshake may occur
    assign ready_o = !a_full_q || !b_full_q;

    // The unit provides output as long as one of the registers is filled.
    assign valid_o = a_full_q | b_full_q;

    // We empty the spill register before the slice register.
    assign data_o = b_full_q ? b_data_q : a_data_q;


/*
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
*/
  end
endmodule
