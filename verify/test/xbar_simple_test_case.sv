/* ***********************************************************
    document:       xbar_simple_test_case.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_SIMPLE_TEST_CASE_SV__
`define __XBAR_SIMPLE_TEST_CASE_SV__

class xbar_simple_test_case extends xbar_test_base;
        axi_slv_default_sequence        slv_default_seq[tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE];
        axi_mst_regular_sequence        mst_regular_seq[tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE];
    
    `uvm_component_utils(xbar_simple_test_case)
    function new (string name = "xbar_simple_test_case", uvm_component parent);
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

        foreach(slv_default_seq[i]) begin
            slv_default_seq[i] = axi_slv_default_sequence::type_id::create($sformatf("slv_default_seq_%0d", i));
                `uvm_info("slv_default_seq",$sformatf("slv_default_seq_%0d create",i),UVM_LOW)
        end
        foreach(mst_regular_seq[i]) begin
            mst_regular_seq[i] = axi_mst_regular_sequence::type_id::create($sformatf("mst_regular_seq_%0d", i));
                `uvm_info("mst_regular_seq",$sformatf("mst_regular_seq_%0d create",i),UVM_LOW)
        end
        
        fork
            mst_regular_seq[0].start(env.virt_sqr.mst_sqr[0]);    
            mst_regular_seq[1].start(env.virt_sqr.mst_sqr[1]);    
            mst_regular_seq[2].start(env.virt_sqr.mst_sqr[2]);    
            slv_default_seq[0].start(env.virt_sqr.slv_sqr[0]);
            slv_default_seq[1].start(env.virt_sqr.slv_sqr[1]);
            slv_default_seq[2].start(env.virt_sqr.slv_sqr[2]);
            slv_default_seq[3].start(env.virt_sqr.slv_sqr[3]);

        join
        /*
        fork
            begin
                foreach(slv_default_seq[i]) begin
                    fork
                        slv_default_seq[i].start(env.virt_sqr.slv_sqr[i]);
                    join_none
                end
            end
            begin
                foreach(mst_regular_seq[j]) begin
                    fork
                        mst_regular_seq[j].start(env.virt_sqr.mst_sqr[j]);
                    join_none
                end
            end
            begin
                #100ns;
            end
        join
        wait fork;
        */


            /*
            init_vseq(simple_seq);
            foreach(simple_seq.mst_sqr[i])begin
                if(simple_seq.mst_sqr[i] == null) `uvm_error("test_case", $sformatf("simple_seq.mst_sqr[%0d] is null",i))
            end
            foreach(simple_seq.slv_sqr[i])begin
                if(simple_seq.slv_sqr[i] == null) `uvm_error("test_case", $sformatf("simple_seq.slv_sqr[%0d] is null",i))
            end
            */
            //simple_seq.start(env.virt_sqr);
        phase.drop_objection(this);
    endtask


endclass
`endif 
