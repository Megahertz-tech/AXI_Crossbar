`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;

// FIFO Sequence
class fifo_sequence extends uvm_sequence #(fifo_transaction);
    `uvm_object_utils(fifo_sequence)
    
    rand int num_transactions = 20;
    fifo_transaction transactions[$];
    
    function new(string name = "fifo_sequence");
        super.new(name);
    endfunction
    
    task body();
        // First fill the FIFO
        for (int i = 0; i < 16; i++) begin
            fifo_transaction tx;
            `uvm_create(tx)
            tx.wr_en = 1;
            tx.rd_en = 0;
            assert(tx.randomize());
            transactions.push_back(tx);
            `uvm_send(tx)
        end
        
        // Wait for FIFO to be full
        #100;
        
        // Then empty the FIFO
        for (int i = 0; i < 16; i++) begin
            fifo_transaction tx;
            `uvm_create(tx)
            tx.wr_en = 0;
            tx.rd_en = 1;
            tx.data = 0; // Data doesn't matter for reads
            transactions.push_back(tx);
            `uvm_send(tx)
        end
    endtask
endclass


