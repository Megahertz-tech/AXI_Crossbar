/* ***********************************************************
    document:       xbar_axi_slave_env.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Parameterized env for different numbers of
                    axi slave (acts as a responser) 
**************************************************************/
`ifndef __XBAR_AXI_MASTER_ENV_SV__
`define __XBAR_AXI_MASTER_ENV_SV__

`include "uvm_macros.svh"
import uvm_pkg::*;
                                // Number of slave ports (master connections)
class xbar_axi_slave_env #( parameter int unsigned NoSlvPorts = 4) extends uvm_component;
    `uvm_component_utils(xbar_axi_slave_env)
    
    virtual v_axi_inf   slv_vif[NoSlvPorts];
    axi_slv_agent       slv_agt[NoSlvPorts];

    function new (string name = "xbar_axi_slave_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        for(int i=0;i<NoSlvPorts;i++) begin
            slv_agt[i] = axi_slv_agent::type_id::create($sformatf("slv_agt_%d",i), this);
            //slv_agt[i] = axi_slv_agent::type_id::creat($sformatf("slv_agt_%s",i), this);
        end
        if(!uvm_config_db#(virtual v_axi_inf)::get(this, "", "svif", slv_vif)) begin
            `uvm_error("Get_Slv_Vif", "no virtual interface is assigned")
        end
    endfunction 

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        for(int i=0;i<NoSlvPorts;i++) begin
            slv_agt[i].vif = slv_vif[i];
        end
    endfunction

endclass: xbar_axi_slave_env 

`endif 
