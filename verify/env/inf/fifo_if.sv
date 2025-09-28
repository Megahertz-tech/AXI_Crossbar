// Interface for FIFO DUT
interface fifo_if(input bit clk);
    logic rst_n;
    logic wr_en;
    logic [31:0] data_in;
    logic rd_en;
    logic [31:0] data_out;
    logic full;
    logic empty;
    logic almost_full;
    logic almost_empty;
    logic overflow;
    logic underflow;
endinterface
