/* ***********************************************************
    document:       axi_mst_agent.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_AGENT_SV__
`define __AXI_MST_AGENT_SV__

class axi_mst_agent extends uvm_agent;
    axi_mst_sequencer   sqr;
    axi_mst_driver      drv;
    //axi_mst_monitor     mon;
    virtual v_axi_inf   vif;
    
   `uvm_component_utils(axi_mst_agent)
    function new (string name = "axi_mst_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         sqr = axi_mst_sequencer::type_id::create("sqr", this);
         drv = axi_mst_driver::type_id::create("drv", this);
        //mon = axi_mst_monitor::type_id::create("mon", this);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        drv.vif = this.vif;
    endfunction

endclass 

`endif 
