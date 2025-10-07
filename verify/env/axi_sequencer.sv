/* ***********************************************************
    document:       axi_sequencer.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Define the sequencer for axi master and slave 
**************************************************************/
`ifndef __AXI_SEQUENCER_SV__
`define __AXI_SEQUENCER_SV__

class axi_sequencer extends uvm_sequencer #(axi_seq_item);
    
    `uvm_component_utils(axi_sequencer)
    function new (string name = "axi_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction
    

endclass

`endif 
