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
    bit[tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE-1:0]  enable_slv_b_channel = '0;
    `uvm_component_utils(xbar_test_base)
    xbar_env #(
        .NoMstPorts(tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE),
        .NoSlvPorts(tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE)
    ) env;
    //xbar_axi_slave_env #(tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE)   slv_env;
    function new (string name = "xbar_test_base", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
         env = xbar_env #(
            .NoMstPorts(tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE),
            .NoSlvPorts(tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE)
         )::type_id::create("env", this);
         //slv_env = xbar_axi_slave_env #(tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE)::type_id::create("slv_env", this);
         uvm_config_db#(int)::get(this,"", "enable_slv_b_channel",enable_slv_b_channel);
    endfunction 

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        foreach(env.slv_agt[i]) begin
            env.slv_agt[i].drv.enable_b_channel = this.enable_slv_b_channel[i];
            `uvm_info("TEST_CFG", $sformatf("No.%0d slave driver enable_b_channel: %b", i, env.slv_agt[i].drv.enable_b_channel), UVM_LOW)
        end
    endfunction

    /*
    function void init_vseq(xbar_virtual_sequence_base vseq);
        foreach(vseq.mst_sqr[i]) begin
            vseq.mst_sqr[i] = env.mst_agt[i].sqr;
            if(vseq.mst_sqr[i] == null)  `uvm_error("Init_Vseq", $sformatf("vseq.mst_sqr[%0d] is null",i))
        end
        foreach(vseq.slv_sqr[i]) begin
            vseq.slv_sqr[i] = env.slv_agt[i].sqr;
            if(vseq.slv_sqr[i] == null)  `uvm_error("Init_Vseq", $sformatf("vseq.slv_sqr[%0d] is null",i))
        end
        `uvm_info("init_vseq", "init done.", UVM_LOW)
    endfunction
    */

endclass

`endif 
