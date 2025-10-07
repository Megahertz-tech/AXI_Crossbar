/* ***********************************************************
    document:       xbar_virtual_sequencer.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Sequencer group
**************************************************************/
`ifndef __XBAR_VIRTUAL_SEQUENCER_SV__
`define __XBAR_VIRTUAL_SEQUENCER_SV__

class xbar_virtual_sequencer #(
    parameter int unsigned number_mst = 3;
    parameter int unsigned number_slv = 4;
) extends uvm_sequencer; 
    
    xbar_sequencer mst_sqr[number_mst];
    xbar_sequencer slv_sqr[number_slv];

    `uvm_component_utils(xbar_virtual_sequencer)
    function new (string name = "xbar_virtual_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction


endclass 

`endif 
