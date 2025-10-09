/* ***********************************************************
    document:       axi_slv_sequencer.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_SEQUENCER_SV__
`define __AXI_SLV_SEQUENCER_SV__
class axi_slv_sequencer extends uvm_sequencer #(uvm_sequence_item);
    
   `uvm_component_utils(axi_slv_sequencer)
    function new (string name = "axi_slv_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction

endclass






`endif 
