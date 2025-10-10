/* ***********************************************************
    document:       xbar_virtual_sequence_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_VIRTUAL_SEQUENCE_BASE_SV__
`define __XBAR_VIRTUAL_SEQUENCE_BASE_SV__

`include "tb_xbar_param_pkg.sv"
class xbar_virtual_sequence_base extends uvm_sequence;
    axi_mst_sequencer mst_sqr[tb_xbar_param_pkg::AXI_MASTER_NUMBER_IN_USE];
    axi_slv_sequencer slv_sqr[tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE];

    `uvm_object_utils(xbar_virtual_sequence_base)
    function new (string name = "xbar_virtual_sequence_base");
        super.new(name);
    endfunction


endclass

`endif 
