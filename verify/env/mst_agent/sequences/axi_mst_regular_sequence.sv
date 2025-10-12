/* ***********************************************************
    document:       axi_mst_regualr_sequence.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_REGULAR_SEQUENCE_SV__
`define __AXI_MST_REGULAR_SEQUENCE_SV__
`include "axi_mst_sequencer.sv"
`include "uvm_macros.svh"
class axi_mst_regular_sequence extends uvm_sequence #(axi_mst_seq_item);
    
   `uvm_object_utils(axi_mst_regular_sequence)
   //`uvm_declare_p_sequencer(axi_mst_sequencer)
    function new (string name = "axi_mst_regular_sequence");
        super.new(name);
    endfunction

    task body();
        axi_mst_seq_item req;
        //uvm_sequence_item tmp;
        int rand_delay;
        `uvm_info("MST_SEQ","enter body()",UVM_LOW)
        #50ns;
        for(int i=0; i<10; i++) begin
            `uvm_create(req)
            if(!req.randomize() with {
                access_type == AXI_WRITE_ACCESS;
                aw_addr == 8 * i;
            }) `uvm_error(get_type_name(), "randomization failure for req.")
            req.set_one_transfer_transaction_awr();
            req.set_one_transfer_transaction_w();
            rand_delay = $urandom_range(20,2);
            #(rand_delay * 10ns);
            `uvm_send(req)
        end
        //if(p_sequencer==null) `uvm_error("MST_SEQ","p_sequencer is null !!!!!!")
        //else `uvm_info("MST_SEQ",p_sequencer.get_full_name(),UVM_LOW)
        /*
        for(int i=0; i<10; i++) begin
            tmp = create_item(axi_mst_seq_item::get_type(), p_sequencer, "req");
            //req_item = axi_mst_seq_item::type_id::create("req_item");
            assert($cast(req_item, tmp));
            start_item(req_item);
            if(!req_item.randomize() with {
                access_type == AXI_WRITE_ACCESS;
                aw_addr == 8 * i;
            }) `uvm_error(get_type_name(), "randomization failure for item.")
            rand_delay = $urandom_range(20,2);
            #(rand_delay * 10ns);
            finish_item(req_item);
        end
        */
    endtask

    

endclass






`endif 
