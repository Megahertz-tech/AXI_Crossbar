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
      parameter int unsigned NoMstPorts         = 3,        // Number of master ports (slave connections)
      parameter int unsigned AxiIdWidthSlvPorts = 6,        // Slave port ID width       
      parameter int unsigned AxiIdUsedSlvPorts  = 6,        // Used ID bits for ordering decisions      
      parameter int unsigned AxiAddrWidth       = 32,       // Address width
      parameter int unsigned AxiDataWidth       = 64       // Data width
) extends uvm_env;
    
    virtual v_axi_inf mst_vifs[NoMstPorts];

    mst_agent mst_agt[NoMstPorts];

    `uvm_component_utils(xbar_axi_master_env)
    function new (string name = "xbar_axi_master_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        for(i=0;i<NoMstPorts;i++) begin 
            mst_agt[i] = mst_agent::type_id::creat($psprintf("mst_agt_%s",i), this);
        end
    endfunction 

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        for(i=0;i<NoMstPorts;i++) begin 
            mst_agt[i].vif = mst_vifs[i];
        end
    endfunction


endclass 
`endif 
