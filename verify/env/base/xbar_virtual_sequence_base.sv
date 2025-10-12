/* ***********************************************************
    document:       xbar_virtual_sequence_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_VIRTUAL_SEQUENCE_BASE_SV__
`define __XBAR_VIRTUAL_SEQUENCE_BASE_SV__

`include "tb_xbar_param_pkg.svh"
typedef class xbar_virtual_sequencer;
class xbar_virtual_sequence_base extends uvm_sequence;
    axi_mst_sequencer mst_sqr[tb_xbar_param_pkg::AXI_MASTER_NUMBER_IN_USE];
    axi_slv_sequencer slv_sqr[tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE];

    `uvm_object_utils(xbar_virtual_sequence_base)
    `uvm_declare_p_sequencer(xbar_virtual_sequencer)
    function new (string name = "xbar_virtual_sequence_base");
        super.new(name);
    endfunction
    virtual task body();
        `uvm_info("sequence_base","enter body.",UVM_LOW)
        foreach(p_sequencer.mst_sqr[i]) begin
            this.mst_sqr[i] = p_sequencer.mst_sqr[i];
            if(this.mst_sqr[i] == null) `uvm_error("sequence_base",$sformatf("mst_sqr[%0d] null!!!!", i))
            else begin
                `uvm_info("sequence_base",$sformatf("mst_sqr[%0d] done", i),UVM_LOW)
                `uvm_info("sequence_base",mst_sqr[i].get_full_name(),UVM_LOW)
            end
        end
        foreach(p_sequencer.slv_sqr[i]) begin
            this.slv_sqr[i] = p_sequencer.slv_sqr[i];
            if(this.slv_sqr[i] == null) `uvm_error("sequence_base",$sformatf("slv_sqr[%0d] null!!!!", i))
            else begin
                `uvm_info("sequence_base",$sformatf("slv_sqr[%0d] done", i),UVM_LOW)
                `uvm_info("sequence_base",slv_sqr[i].get_full_name(),UVM_LOW)
            end
        end
    endtask


endclass

`endif 
