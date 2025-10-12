/* ***********************************************************
    document:       axi_slv_agent.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_AGENT_SV__
`define __AXI_SLV_AGENT_SV__
`include "tb_axi_types_pkg.sv"
class axi_slv_agent extends uvm_agent;
typedef virtual v_axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    ) virt_axi_slv_inf;
    axi_slv_driver      drv;
    axi_slv_sequencer   sqr;
    //virtual v_axi_inf   vif;
    virtual v_axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )   vif;
    
   `uvm_component_utils(axi_slv_agent)
    function new (string name = "axi_slv_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         `uvm_info(get_full_name(), "into build_phase", UVM_LOW)
         drv = axi_slv_driver::type_id::create("drv", this);
         sqr = axi_slv_sequencer::type_id::create("sqr", this);
        drv.set_interface(vif);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(), "into connect_phase", UVM_LOW)
        drv.seq_item_port.connect(sqr.seq_item_export);
        //drv.vif = this.vif;
    endfunction
    function void set_interface(virt_axi_slv_inf inf);
        if(inf == null) `uvm_fatal("Set_Inf", "interface handle is NULL, please check if target interface has been intantiated")
        else this.vif = inf;
    endfunction

endclass






`endif 
