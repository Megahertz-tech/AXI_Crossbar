/* ***********************************************************
    document:       xbar_virtual_sequencer.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Sequencer group
**************************************************************/
`ifndef __XBAR_VIRTUAL_SEQUENCER_SV__
`define __XBAR_VIRTUAL_SEQUENCER_SV__

class xbar_virtual_sequencer extends uvm_sequencer; 
    
    axi_mst_sequencer   mst_sqr[tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE];
    axi_slv_sequencer   slv_sqr[tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE];

    `uvm_component_utils(xbar_virtual_sequencer)
    function new (string name = "xbar_virtual_sequencer", uvm_component parent);
        super.new(name, parent);
    endfunction


endclass 

`endif 
