/* ***********************************************************
    document:       axi_slv_agent.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_AGENT_SV__
`define __AXI_SLV_AGENT_SV__
class axi_slv_agent extends uvm_agent;
    axi_slv_driver      drv;
    axi_slv_sequencer   sqr;
    virtual v_axi_inf   vif;
    
   `uvm_component_utils(axi_slv_agent)
    function new (string name = "axi_slv_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         drv = axi_slv_driver::type_id::create("drv", this);
         sqr = axi_slv_sequencer::type_id::create("sqr", this);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        drv.seq_item_port.connect(sqr.seq_item_export);
        drv.vif = this.vif;
    endfunction

endclass






`endif 
