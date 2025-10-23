/* ***********************************************************
    document:       xbar_addr_random_test_case.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_ADDR_RANDOM_TEST_CASE_SV__
`define __XBAR_ADDR_RANDOM_TEST_CASE_SV__

class xbar_addr_random_test_case extends xbar_test_base;
        axi_slv_default_sequence        slv_seq[tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE];
        axi_mst_addr_random_sequence        mst_seq[tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE];
    
    `uvm_component_utils(xbar_addr_random_test_case)
    function new (string name = "xbar_addr_random_test_case", uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        `uvm_info("TEST_CASE", "Enter run_phase.", UVM_LOW)
        foreach(env.virt_sqr.mst_sqr[i]) begin
            if(env.virt_sqr.mst_sqr[i] == null) `uvm_error("TEST_CHECK","attach virtual sequencer mst handle wrong!")
        end
        foreach(env.virt_sqr.slv_sqr[i]) begin
            if(env.virt_sqr.slv_sqr[i] == null) `uvm_error("TEST_CHECK","attach virtual sequencer slv handle wrong!")
        end

        foreach(slv_seq[i]) begin
            slv_seq[i] = axi_slv_default_sequence::type_id::create($sformatf("slv_seq_%0d", i));
                `uvm_info("TEST_CASE",$sformatf("slv_default_seq_%0d create",i),UVM_LOW)
        end
        foreach(mst_seq[i]) begin
            mst_seq[i] = axi_mst_addr_random_sequence::type_id::create($sformatf("mst_seq_%0d", i));
                `uvm_info("TEST_CASE",$sformatf("mst_regular_seq_%0d create",i),UVM_LOW)
        end
        
        fork
            mst_seq[0].start(env.virt_sqr.mst_sqr[0]);    
            mst_seq[1].start(env.virt_sqr.mst_sqr[1]);    
            mst_seq[2].start(env.virt_sqr.mst_sqr[2]);    
            slv_seq[0].start(env.virt_sqr.slv_sqr[0]);
            slv_seq[1].start(env.virt_sqr.slv_sqr[1]);
            slv_seq[2].start(env.virt_sqr.slv_sqr[2]);
            slv_seq[3].start(env.virt_sqr.slv_sqr[3]);

        join
        
        phase.drop_objection(this);
    endtask


endclass
`endif 
