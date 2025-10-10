/* ***********************************************************
    document:       xbar_axi_master_env.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Parameterized env for different numbers of
                    axi master 
**************************************************************/
`ifndef __XBAR_AXI_MASTER_ENV_SV__
`define __XBAR_AXI_MASTER_ENV_SV__

class xbar_axi_master_env #(
//      parameter int unsigned NoSlvPorts         = 4,        // Number of slave ports (master connections)
      parameter int unsigned NoMstPorts         = 3        // Number of master ports (slave connections)
) extends uvm_env;
    
    virtual v_axi_inf           mst_vif[NoMstPorts];
    axi_mst_agent               mst_agt[NoMstPorts];
    axi_mst_regular_cfg         mst_cfg[NoMstPorts];

    `uvm_component_utils(xbar_axi_master_env)
    function new (string name = "xbar_axi_master_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        for(i=0;i<NoMstPorts;i++) begin 
            mst_agt[i] = axi_mst_agent::type_id::creat($psprintf("mst_agt_%s",i), this);
            mst_cfg[i] = axi_mst_regular_cfg::type_id::creat($psprintf("mst_cfg_%s",i));
        end
    endfunction 

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        for(i=0;i<NoMstPorts;i++) begin 
            mst_agt[i].vif = mst_vif[i];
            assert(mst_cfg[i].randomize()) else `uvm_error(get_full_name(), $psprintf("No.%d mst cfg randomize error", i));
            mst_agt[i].cfg = mst_cfg[i];
            mst_agt[i].set_mst_id(i);
        end
    endfunction


endclass 
`endif 
