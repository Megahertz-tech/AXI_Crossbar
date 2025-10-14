/* ***********************************************************
    document:       xbar_simple_sequence.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __XBAR_SIMPLE_SEQUENCE_SV__
`define __XBAR_SIMPLE_SEQUENCE_SV__

class xbar_simple_sequence extends xbar_virtual_sequence_base;
    
    `uvm_object_utils(xbar_simple_sequence)
    //`uvm_declare_p_sequencer(xbar_virtual_sequencer)
    function new (string name = "xbar_simple_sequence");
        super.new(name);
    endfunction

    task body();
        axi_slv_default_sequence        slv_default_seq[tb_xbar_param_pkg::TB_SLAVE_NUMBER_IN_USE];
        axi_mst_regular_sequence        mst_regular_seq[tb_xbar_param_pkg::TB_MASTER_NUMBER_IN_USE];
        super.body();
        `uvm_info("Main_Seq", "enter body", UVM_LOW)
        foreach(slv_default_seq[i]) begin
            slv_default_seq[i] = axi_slv_default_sequence::type_id::create($sformatf("slv_default_seq_%0d", i));
                `uvm_info("slv_default_seq",$sformatf("slv_default_seq_%0d create",i),UVM_LOW)
        end
        foreach(mst_regular_seq[i]) begin
            mst_regular_seq[i] = axi_mst_regular_sequence::type_id::create($sformatf("mst_regular_seq_%0d", i));
                `uvm_info("mst_regular_seq",$sformatf("mst_regular_seq_%0d create",i),UVM_LOW)
        end
        if(p_sequencer == null) `uvm_error("Main_Seq", "p_sequencer is null!")
        else begin
            fork
                fork
                    foreach(mst_regular_seq[i])begin
                    //fork
                        begin
                            $display($sformatf("No.%0d \n", i));
                            if(this.mst_sqr[i] == null) `uvm_error("Main_Seq", $sformatf("this.mst_sqr[%0d] is null!",i))
                            mst_regular_seq[i].set_sequencer(this.mst_sqr[i]);
                            mst_regular_seq[i].start(null);
                        end
                    //`uvm_do_on(mst_regular_seq[i], p_sequencer.mst_sqr[i])
                    //join_none
                    end 
                join
                fork
                    foreach(slv_default_seq[j])begin
                    //fork
                        begin
                            $display($sformatf("No.%0d \n", j));
                            if(this.slv_sqr[j] == null) `uvm_error("Main_Seq", $sformatf("this.slv_sqr[%0d] is null!",j))
                            slv_default_seq[j].set_sequencer(this.slv_sqr[j]);
                            slv_default_seq[j].start(null);
                        end
                    //`uvm_do_on(slv_default_seq[j], p_sequencer.slv_sqr[j])
                    //join_none
                    end
                join
            join
            wait fork;
        end
        /*
            foreach(this.mst_sqr[i])begin
                if(this.mst_sqr[i] == null) `uvm_error("Main_Seq 0", $sformatf("this.mst_sqr[%0d] is null",i))
                else begin
                    $display("mst_sqr");
                    fork 
                    begin
                        mst_regular_seq[i] = axi_mst_regular_sequence::type_id::create($sformatf("mst_regular_seq_%d", i));
                        mst_regular_seq[i].start(this.mst_sqr[i]);
                    end
                    join_none
                end
            end
            foreach(this.slv_sqr[j])begin
                if(this.slv_sqr[j] == null) `uvm_error("Main_Seq 0", $sformatf("this.slv_sqr[%0d] is null",j))
                else begin
                    $display("slv_sqr");
                    fork
                    begin
                        slv_default_seq[j] = axi_slv_default_sequence::type_id::create($sformatf("slv_default_seq_%d", j));
                        slv_default_seq[j].start(this.slv_sqr[j] );
                    end
                    join_none
                end
            end
            wait fork;
            */
            /*
        foreach(slv_default_seq[i]) begin
            slv_default_seq[i] = axi_slv_default_sequence::type_id::create($sformatf("slv_default_seq_%d", i));
                `uvm_info("slv_default_seq",$sformatf("slv_default_seq_%0d create",i),UVM_LOW)
        end
        foreach(mst_regular_seq[i]) begin
            mst_regular_seq[i] = axi_mst_regular_sequence::type_id::create($sformatf("mst_regular_seq_%d", i));
                `uvm_info("mst_regular_seq",$sformatf("mst_regular_seq_%0d create",i),UVM_LOW)
        end
        */
        /*
        fork
            foreach(this.mst_sqr[i])begin
                fork 
                begin
                if(this.mst_sqr[i] == null) `uvm_error("Main_Seq 1", $sformatf("this.mst_sqr[%0d] is null",i))
                mst_regular_seq[i] = axi_mst_regular_sequence::type_id::create($sformatf("mst_regular_seq_%d", i));
                mst_regular_seq[i].start(this.mst_sqr[i]);
                end
                join_none
            end
            foreach(this.slv_sqr[j])begin
                fork 
                begin
                if(this.slv_sqr[j] == null) `uvm_error("Main_Seq 1", $sformatf("this.slv_sqr[%0d] is null",j))
                slv_default_seq[j] = axi_slv_default_sequence::type_id::create($sformatf("slv_default_seq_%d", j));
                slv_default_seq[j].start(this.slv_sqr[j] );
                end
                join_none
            end
        join
        wait fork;
        */
        /*
        fork
            foreach(slv_default_seq[i]) begin
                fork
                begin
                if(this.slv_sqr[i] == null)  `uvm_error("Main_Seq", $sformatf("this.slv_sqr[%0d] is null",i))
                slv_default_seq[i].start(this.slv_sqr[i]);
                `uvm_info("slv_default_seq",$sformatf("slv_default_seq_%0d start",i),UVM_LOW)
                end
                join_none
            end
            foreach(mst_regular_seq[i]) begin
                fork
                begin
                if(this.mst_sqr[i] == null)  `uvm_error("Main_Seq", $sformatf("this.mst_sqr[%0d] is null",i))
                mst_regular_seq[i].start(this.mst_sqr[i]);
                `uvm_info("mst_regular_seq",$sformatf("mst_regular_seq_%0d start",i),UVM_LOW)
                end
                join_none
            end
        join
        */
    endtask




endclass 
`endif 
