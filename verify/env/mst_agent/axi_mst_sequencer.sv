/* ***********************************************************
    document:       axi_mst_sequencer.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_SEQUENCER_SV__
`define __AXI_MST_SEQUENCER_SV__

class axi_mst_sequencer extends uvm_sequencer #(uvm_sequence_item);
    
   `uvm_component_utils(axi_mst_sequencer)
    function new (string name = "axi_mst_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass






`endif 
