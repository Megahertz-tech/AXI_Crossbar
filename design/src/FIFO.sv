module FIFO #(
    // Parameter definitions
    parameter DATA_WIDTH = 32,          // Data width
    parameter FIFO_DEPTH = 16,          // FIFO depth
    parameter ALMOST_FULL_THRESH = 12,  // Almost full threshold
    parameter ALMOST_EMPTY_THRESH = 4   // Almost empty threshold
) (
    // Port definitions
    input logic                     clk,            // Clock signal
    input logic                     rst_n,          // Synchronous active-low reset
    
    input logic                     wr_en,          // Write enable
    input logic [DATA_WIDTH-1:0]    data_in,    // Input data bus
    input logic                     rd_en,          // Read enable
    
    output logic [DATA_WIDTH-1:0]   data_out,   // Output data bus
    output logic                    full,           // FIFO full flag
    output logic                    empty,          // FIFO empty flag
    output logic                    almost_full,    // FIFO almost full flag
    output logic                    almost_empty,   // FIFO almost empty flag
    output logic                    overflow,       // Overflow error flag
    output logic                    underflow       // Underflow error flag
);

    // Local parameters
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH);
    
    // Internal signals
    logic [ADDR_WIDTH-1:0] wr_ptr;        // Write pointer
    logic [ADDR_WIDTH-1:0] rd_ptr;        // Read pointer
    logic [ADDR_WIDTH:0]   count;         // FIFO count
    logic [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1]; // Memory array
    
    // Status flags
    assign full = (count == FIFO_DEPTH);
    assign empty = (count == 0);
    assign almost_full = (count >= ALMOST_FULL_THRESH);
    assign almost_empty = (count <= ALMOST_EMPTY_THRESH);
    
    // Error flags
    logic overflow_reg;
    logic underflow_reg;
    assign overflow = overflow_reg;
    assign underflow = underflow_reg;
    
    // Data output
    assign data_out = mem[rd_ptr];
    
    // Pointer and count update logic
    always_ff @(posedge clk) begin
        if (!rst_n) begin
            // Reset logic
            wr_ptr <= 0;
            rd_ptr <= 0;
            count <= 0;
            overflow_reg <= 0;
            underflow_reg <= 0;
        end
        else begin
            // Clear error flags
            overflow_reg <= 0;
            underflow_reg <= 0;
            
            // Write operation
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1;
                count <= count + 1;
            end
            else if (wr_en && full) begin
                overflow_reg <= 1;
            end
            
            // Read operation
            if (rd_en && !empty) begin
                rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
                count <= count - 1;
            end
            else if (rd_en && empty) begin
                underflow_reg <= 1;
            end
        end
    end
    
endmodule

