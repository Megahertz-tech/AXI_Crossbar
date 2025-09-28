`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
// Base Test
class base_test extends uvm_test;
    `uvm_component_utils(base_test)
    
    fifo_env env;
    fifo_sequence seq;
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
        seq = fifo_sequence::type_id::create("seq");
    endfunction
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask
endclass

