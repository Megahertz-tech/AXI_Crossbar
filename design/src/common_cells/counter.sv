/// Counter Module
///
/// A simple parameterizable counter with configurable width, clear, enable,
/// load, and direction control. Used in various AXI modules for beat counting
/// and transaction tracking.
///
/// Features:
/// - Configurable counter width
/// - Clear, enable, and load functionality
/// - Up/down counting support
/// - Overflow detection
/// - Optional sticky enable (latch enable signal)
///
/// TODO: Students should implement the counter logic with proper
/// control signal handling and overflow detection.

module counter #(
  parameter int unsigned WIDTH     = 4,       // Counter width in bits
  parameter bit          STICKY_EN = 1'b0     // Enable latching (1) or direct enable (0)
) (
  input  logic             clk_i,       // Clock
  input  logic             rst_ni,      // Asynchronous reset, active low
  input  logic             clear_i,     // Synchronous clear (reset to 0)
  input  logic             en_i,        // Enable counting
  input  logic             load_i,      // Load counter with value from d_i
  input  logic             down_i,      // Count direction: 1=down, 0=up   
  input  logic [WIDTH-1:0] d_i,         // Data input for load operation
  output logic [WIDTH-1:0] q_o,         // Counter output value
  output logic             overflow_o   // Overflow flag
);

  // TODO: Implement counter state
  logic [WIDTH-1:0] count_q, count_d;
  logic enable_q, enable_d;

  // TODO: Handle sticky enable if configured
  if (STICKY_EN) begin : gen_sticky_enable
    // Latch enable signal until clear
    assign enable_d = clear_i ? 1'b0 : (en_i || enable_q);
    //`FF(enable_q, enable_d, 1'b0)
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) enable_q <= '0;
        else        enable_q <= enable_d;
    end
  end else begin : gen_direct_enable
    // Use enable signal directly
    assign enable_q = en_i;
  end
  

  // TODO: Implement counter logic
  always_comb begin
    count_d = count_q;
    overflow_o = 1'b0;

    if (clear_i) begin
      // Clear takes priority
      count_d = '0;
    end else if (load_i) begin
      // Load operation
      count_d = d_i;
    end else if (enable_q) begin
      // Count operation
      if (down_i) begin
        // Count down
        if (count_q == '0) begin
          count_d = '1;  // Wrap to maximum value
          overflow_o = 1'b1;
        end else begin
          count_d = count_q - 1'b1;
        end
      end else begin
        // Count up
        if (count_q == '1) begin
          count_d = '0;  // Wrap to zero
          overflow_o = 1'b1;
        end else begin
          count_d = count_q + 1'b1;
        end
      end
    end
  end

  // TODO: Register the counter value
  `FF(count_q, count_d, '0)
  always_ff @(posedge clk_i or negedge rst_ni) begin
        if(~rst_ni) count_q <= '0;
        else        count_q <= count_d;
    end

  // Output assignment
  assign q_o = count_q;

  // TODO: Add parameter validation
  // pragma translate_off
  `ifndef VERILATOR
  `ifndef XSIM
  initial begin : check_params
    assert (WIDTH > 0) else
      $fatal(1, "Counter width must be > 0");
  end
  `endif
  `endif
  // pragma translate_on

endmodule
