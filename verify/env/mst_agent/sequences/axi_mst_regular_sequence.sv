/* ***********************************************************
    document:       axi_mst_regualr_sequence.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MSt_REGULAR_SEQUENCE_SV__
`define __AXI_MSt_REGULAR_SEQUENCE_SV__
class axi_mst_regular_sequence extends uvm_sequence #(axi_mst_seq_item);
    
   `uvm_component_utils(axi_mst_regular_sequence)
    function new (string name = "axi_mst_regular_sequence");
        super.new(name);
    endfunction

    task body();
        axi_mst_seq_item req_item;
        int rand_delay;
        for(int i=0; i<10; i++) begin
            req_item = axi_mst_seq_item::type_id::create("req_item");
            start_item(req_item);  
            if(!req_item.randomize() with {
                access_type == AXI_WRITE_ACCESS;
                aw_addr == 8 * i;
            }) `uvm_error(get_type_name(), "randomization failure for item.")
            rand_delay = std::$urandom_range(20,2);
            #(rand_delay * 10ns);
            finish_item(req_item);
        end
    endtask

    

endclass






`endif 
