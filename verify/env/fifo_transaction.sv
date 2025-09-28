`timescale 1ns/1ps
`include "uvm_macros.svh"

import uvm_pkg::*;
// FIFO Transaction Item
class fifo_transaction extends uvm_sequence_item;
    rand bit [31:0] data;
    rand bit wr_en;
    rand bit rd_en;
    
    `uvm_object_utils_begin(fifo_transaction)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(wr_en, UVM_ALL_ON)
        `uvm_field_int(rd_en, UVM_ALL_ON)
    `uvm_object_utils_end
    
    function new(string name = "fifo_transaction");
        super.new(name);
    endfunction
    
    constraint valid_ops {
        wr_en != rd_en;
    }
endclass
