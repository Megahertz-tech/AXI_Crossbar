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
    function new (string name = "xbar_simple_sequence");
        super.new(name);
    endfunction

    task body();
        axi_slv_default_sequence        slv_default_seq[tb_xbar_param_pkg::AXI_SLAVE_NUMBER_IN_USE];
        axi_mst_regular_sequence        mst_regular_seq[tb_xbar_param_pkg::AXI_MASTER_NUMBER_IN_USE];
        foreach(slv_default_seq[i]) begin
            slv_default_seq[i] = axi_slv_default_sequence::type_id::create($sformatf("slv_default_seq_%d", i));
        end
        foreach(mst_regular_seq[i]) begin
            mst_regular_seq[i] = axi_mst_regular_sequence::type_id::create($sformatf("mst_regular_seq_%d", i));
        end
        fork
            foreach(slv_default_seq[i]) begin
                slv_default_seq[i].start(slv_sqr[i]);
            end
            foreach(mst_regular_seq[i]) begin
                mst_regular_seq[i].start(slv_sqr[i]);
            end
        join
    endtask




endclass 
`endif 
