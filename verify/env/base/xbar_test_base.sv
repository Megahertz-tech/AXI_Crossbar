/* ***********************************************************
    document:       xbar_test_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_TEST_BASE_SV__
`define __XBAR_TEST_BASE_SV__
`include "tb_xbar_param_pkg.svh"
`include "uvm_macros.svh"
import uvm_pkg::*;

class xbar_test_base extends uvm_test;
    `uvm_component_utils(xbar_test_base)
    xbar_env #(tb_xbar_param_pkg::AXI_MASTER_NUMBER_IN_USE) env;
    //xbar_axi_slave_env #(tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE)   slv_env;
    function new (string name = "xbar_test_base", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         env = xbar_env #(tb_xbar_param_pkg::AXI_MASTER_NUMBER_IN_USE)::type_id::create("env", this);
         //slv_env = xbar_axi_slave_env #(tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE)::type_id::create("slv_env", this);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
    endfunction

    function void init_vseq(xbar_virtual_sequence_base vseq);
        foreach(vseq.mst_sqr[i]) begin
            vseq.mst_sqr[i] = env.mst_agt[i].sqr;
        end
        foreach(vseq.slv_sqr[i]) begin
            vseq.slv_sqr[i] = env.slv_agt[i].sqr;
        end
        `uvm_info("init_vseq", "init done.", UVM_LOW)
    endfunction

endclass

`endif 
