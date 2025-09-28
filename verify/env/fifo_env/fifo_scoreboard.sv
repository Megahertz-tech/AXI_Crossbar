`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
// FIFO Scoreboard
class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)
    
    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) item_export;
    
    fifo_transaction write_q[$];
    fifo_transaction read_q[$];
    
    int write_count = 0;
    int read_count = 0;
    int match_count = 0;
    int mismatch_count = 0;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        item_export = new("item_export", this);
    endfunction
    
    function void write(fifo_transaction tx);
        if (tx.wr_en) begin
            write_q.push_back(tx);
            write_count++;
        end
        else if (tx.rd_en) begin
            read_q.push_back(tx);
            read_count++;
        end
    endfunction
    
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        // Compare write and read transactions
        while (write_q.size() > 0 && read_q.size() > 0) begin
            fifo_transaction write_tx = write_q.pop_front();
            fifo_transaction read_tx = read_q.pop_front();
            
            if (write_tx.data !== read_tx.data) begin
                `uvm_error("SCOREBOARD", $sformatf("Data mismatch! Expected: 0x%0h, Actual: 0x%0h", 
                          write_tx.data, read_tx.data))
                mismatch_count++;
            end
            else begin
                match_count++;
            end
        end
        
        // Check for transaction count mismatch
        if (write_count != read_count) begin
            `uvm_error("SCOREBOARD", $sformatf("Transaction count mismatch! Writes: %0d, Reads: %0d", 
                      write_count, read_count))
        end
        
        `uvm_info("SCOREBOARD", $sformatf("Scoreboard Results: Matches=%0d, Mismatches=%0d, Writes=%0d, Reads=%0d", 
                  match_count, mismatch_count, write_count, read_count), UVM_LOW)
    endfunction
endclass

