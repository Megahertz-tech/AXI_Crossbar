/* ***********************************************************
    document:       axi_mst_agent.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_AGENT_SV__
`define __AXI_MST_AGENT_SV__

class axi_mst_agent extends uvm_agent;
    axi_sequencer sqr;
    axi_driver drv;
    axi_monitor mon;
    virtual v_axi_inf vif;
    
   `uvm_component_utils(axi_mst_agent)
    function new (string name = "axi_mst_agent", uvm_component parent);
        super.new(name, parent);
    endfunction


endclass 

`endif 
