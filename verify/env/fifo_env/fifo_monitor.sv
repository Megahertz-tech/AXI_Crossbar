`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
// FIFO Monitor
class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)
    
    virtual fifo_if vif;
    uvm_analysis_port #(fifo_transaction) ap;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db#(virtual fifo_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal("NOVIF", "Virtual interface not set for monitor")
        end
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            fifo_transaction tx = fifo_transaction::type_id::create("tx");
            
            @(posedge vif.clk);
            if (vif.wr_en && !vif.full) begin
                tx.wr_en = 1;
                tx.rd_en = 0;
                tx.data = vif.data_in;
                ap.write(tx);
            end
            if (vif.rd_en && !vif.empty) begin
                tx = fifo_transaction::type_id::create("tx");
                tx.wr_en = 0;
                tx.rd_en = 1;
                tx.data = vif.data_out;
                ap.write(tx);
            end
        end
    endtask
endclass
