/* ***********************************************************
    document:       axi_mst_agent.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_AGENT_SV__
`define __AXI_MST_AGENT_SV__
`include "tb_axi_types_pkg.sv"

class axi_mst_agent extends uvm_agent;
typedef virtual axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    ) virt_axi_mst_inf;
    axi_mst_sequencer   sqr;
    axi_mst_driver      drv;
    //axi_mst_monitor     mon;
    //virtual v_axi_inf   vif;
    
    virtual axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )   vif;
    shortint            mst_id;
    
   `uvm_component_utils(axi_mst_agent)
    function new (string name = "axi_mst_agent", uvm_component parent);
        super.new(name, parent);
    endfunction
    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         `uvm_info(get_full_name(), "into build_phase", UVM_LOW)
         sqr = axi_mst_sequencer::type_id::create("sqr", this);
         drv = axi_mst_driver::type_id::create("drv", this);
        //mon = axi_mst_monitor::type_id::create("mon", this);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(), "into connect_phase", UVM_LOW)
        drv.seq_item_port.connect(sqr.seq_item_export);
        drv.set_interface(vif);
        drv.set_mst_id(this.mst_id);
    endfunction
    function void set_interface(virt_axi_mst_inf inf);
        if(inf == null) `uvm_fatal("Set_Inf", "interface handle is NULL, please check if target interface has been intantiated")
        else this.vif = inf;
    endfunction
    function void set_mst_id(shortint id);
        this.mst_id = id;
    endfunction

endclass 

`endif 
