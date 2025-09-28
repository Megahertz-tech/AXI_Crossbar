`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;

// Basic Test
class basic_test extends base_test;
    `uvm_component_utils(basic_test)
    
    function new(string name = "basic_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info(get_type_name(), "Starting basic FIFO test", UVM_LOW)
        
        seq.start(env.agent.sequencer);
        
        // Wait for all transactions to complete
        #200;
        
        phase.drop_objection(this);
    endtask
endclass

