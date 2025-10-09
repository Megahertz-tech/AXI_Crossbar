/* ***********************************************************
    document:       xbar_axi_slave_env.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Parameterized env for different numbers of
                    axi slave (acts as a responser) 
**************************************************************/
`ifndef __XBAR_AXI_MASTER_ENV_SV__
`define __XBAR_AXI_MASTER_ENV_SV__

class xbar_axi_slave_env #(
      parameter int unsigned NoSlvPorts         = 4,        // Number of slave ports (master connections)
//      parameter int unsigned NoMstPorts         = 3,        // Number of master ports (slave connections)
      parameter int unsigned AxiIdWidthSlvPorts = 6,        // Slave port ID width       
      parameter int unsigned AxiIdUsedSlvPorts  = 6,        // Used ID bits for ordering decisions      
      parameter int unsigned AxiAddrWidth       = 32,       // Address width
      parameter int unsigned AxiDataWidth       = 64       // Data width
) extends uvm_env;
    
    virtual v_axi_inf   slv_vif[NoSlvPorts];
    axi_slv_agent       slv_agt[NoSlvPorts];

    `uvm_component_utils(xbar_axi_slave_env)
    function new (string name = "xbar_axi_slave_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        for(i=0;i<NoSlvPorts;i++) begin
            slv_agt[i] = axi_slv_agent::type_id::creat($psprintf("slv_agt_%s",i), this);
        end
    endfunction 

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        for(i=0;i<NoSlvPorts;i++) begin
            slv_agt.vif = slv_vif[i];
        end
    endfunction


endclass 
`endif 
