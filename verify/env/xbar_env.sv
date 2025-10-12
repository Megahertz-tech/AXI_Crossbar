/* ***********************************************************
    document:       xbar_env.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Parameterized env for different numbers of
                    axi master and slave
**************************************************************/
`ifndef __XBAR_ENV_SV__
`define __XBAR_ENV_SV__
import uvm_pkg::*;
`include "uvm_macros.svh"
`include "xbar_virtual_sequencer.sv"
class xbar_env #(
      parameter int unsigned NoMstPorts = 3,        // Number of master ports (slave connections)
      parameter int unsigned NoSlvPorts = 4
) extends uvm_env;
    
    virtual v_axi_inf #(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )mst_vif[NoMstPorts];
    axi_mst_agent               mst_agt[NoMstPorts];
    xbar_virtual_sequencer      virt_sqr;
    virtual v_axi_inf#(
        .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
        .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
        .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
        .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
    )   slv_vif[NoSlvPorts];
    axi_slv_agent       slv_agt[NoSlvPorts];

    `uvm_component_utils(xbar_env)
    function new (string name = "xbar_env", uvm_component parent);
        super.new(name, parent);
    endfunction
    //{{{ build_phase
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        `uvm_info(get_full_name(), "into build_phase", UVM_LOW)
        for(int i=0;i<NoMstPorts;i++) begin 
            mst_agt[i] = axi_mst_agent::type_id::create($sformatf("mst_agt_%0d",i), this);
        end
        for(int i=0;i<NoSlvPorts;i++) begin
            slv_agt[i] = axi_slv_agent::type_id::create($sformatf("slv_agt_%0d",i), this);
        end
        //{{{ uvm_config_db
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)     
            ))::get(this, "", "mst_vif[0]", mst_vif[0])) begin
                `uvm_error("Get_Mst_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get mvif_0", UVM_LOW)
        if(mst_vif[0]==null) `uvm_fatal("Get_Mst_Vif", "mst_vif[0] is null")
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)     
            ))::get(this, "", "mst_vif[1]", mst_vif[1])) begin
                `uvm_error("Get_Mst_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get mvif_1", UVM_LOW)
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_MASTER_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)     
            ))::get(this, "", "mst_vif[2]", mst_vif[2])) begin
                `uvm_error("Get_Mst_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get mvif_2", UVM_LOW)
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
            ))::get(this, "", "slv_vif[0]", slv_vif[0])) begin
                `uvm_error("Get_Slv_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get svif_0", UVM_LOW)
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
            ))::get(this, "", "slv_vif[1]", slv_vif[1])) begin
                `uvm_error("Get_Slv_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get svif_1", UVM_LOW)
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
            ))::get(this, "", "slv_vif[2]", slv_vif[2])) begin
                `uvm_error("Get_Slv_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get svif_2", UVM_LOW)
        if(!uvm_config_db#(virtual v_axi_inf #(
                .AXI_ADDR_WIDTH (tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE),
                .AXI_DATA_WIDTH (tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE),
                .AXI_ID_WIDTH   (tb_xbar_param_pkg::AXI_SLAVE_ID_WIDTH_IN_USE),
                .AXI_USER_WIDTH (tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE)
            ))::get(this, "", "slv_vif[3]", slv_vif[3])) begin
                `uvm_error("Get_Slv_Vif", "no virtual interface is assigned")
        end
        else `uvm_info(get_full_name(), "get svif_3", UVM_LOW)
                //}}}
        for(int i=0;i<NoMstPorts;i++) begin 
            mst_agt[i].set_interface(mst_vif[i]);            
            mst_agt[i].set_mst_id(i);
        end
        for(int i=0;i<NoSlvPorts;i++) begin
            slv_agt[i].set_interface(slv_vif[i]);
        end
        virt_sqr = xbar_virtual_sequencer::type_id::create("virt_sqr", this);
    endfunction 
    //}}}
    //{{{ connect_phase
    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        `uvm_info(get_full_name(), "into connect_phase", UVM_LOW)
        foreach(mst_agt[i]) begin
            virt_sqr.mst_sqr[i] = mst_agt[i].sqr;
            if(virt_sqr.mst_sqr[i] == null) `uvm_error("ENV CONNECT","attach virtual sequencer mst handle wrong!")
            else `uvm_info("ENV_CONNECT",mst_agt[i].sqr.get_full_name(),UVM_LOW)
        end
        foreach(slv_agt[i]) begin
            virt_sqr.slv_sqr[i] = slv_agt[i].sqr;
            if(virt_sqr.slv_sqr[i] == null) `uvm_error("ENV CONNECT","attach virtual sequencer slv handle wrong!")
            else `uvm_info("ENV_CONNECT",slv_agt[i].sqr.get_full_name(),UVM_LOW)
        end
        /*
        for(int i=0;i<NoMstPorts;i++) begin 
            mst_agt[i].set_interface(mst_vif[i]);
            //assert(mst_cfg[i].randomize()) else begin
            //    `uvm_error(get_full_name(), $psprintf("No.%d mst cfg randomize error", i))
            //end
            //mst_agt[i].cfg = mst_cfg[i];
            mst_agt[i].set_mst_id(i);
        end
        `uvm_info(get_full_name(), "mst_vif connection done", UVM_LOW)
        for(int i=0;i<NoSlvPorts;i++) begin
            slv_agt[i].set_interface(slv_vif[i]);
            //slv_agt[i].vif = slv_vif[i];
        end
        `uvm_info(get_full_name(), "slv_vif connection done", UVM_LOW)
        */
    endfunction
    //}}}
endclass: xbar_env
`endif 
