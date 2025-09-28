`timescale 1ns/1ps
`include "uvm_macros.svh"

// Top Module
module tb_fifo_top;
    import uvm_pkg::*;
    
    bit clk;
    bit rst_n;
    
    // Instantiate DUT interface
    fifo_if fif_if(clk);
    
    // Instantiate DUT
    FIFO #(
        .DATA_WIDTH(32),
        .FIFO_DEPTH(16),
        .ALMOST_FULL_THRESH(12),
        .ALMOST_EMPTY_THRESH(4)
    ) dut (
        .clk(clk),
        .rst_n(fif_if.rst_n),
        .wr_en(fif_if.wr_en),
        .data_in(fif_if.data_in),
        .rd_en(fif_if.rd_en),
        .data_out(fif_if.data_out),
        .full(fif_if.full),
        .empty(fif_if.empty),
        .almost_full(fif_if.almost_full),
        .almost_empty(fif_if.almost_empty),
        .overflow(fif_if.overflow),
        .underflow(fif_if.underflow)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Reset generation
    initial begin
        fif_if.rst_n = 0;
        #20 fif_if.rst_n = 1;
    end
    
    // UVM test setup
    initial begin
        uvm_config_db#(virtual fifo_if)::set(null, "uvm_test_top.env*", "vif", fif_if);
        run_test("basic_test");
    end
    
    // Final check
    final begin
        if (uvm_report_server::get_server().get_severity_count(UVM_FATAL) > 0) begin
            $display("Simulation finished with UVM_FATAL errors");
            $finish(2);
        end
        else if (uvm_report_server::get_server().get_severity_count(UVM_ERROR) > 0) begin
            $display("Simulation finished with UVM_ERROR errors");
            $finish(1);
        end
        else begin
            $display("Test passed successfully");
            $finish(0);
        end
    end
endmodule
