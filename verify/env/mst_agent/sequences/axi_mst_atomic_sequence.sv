/* ***********************************************************
    document:       axi_mst_atomic_sequence.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_ATOMIC_SEQUENCE_SV__
`define __AXI_MST_ATOMIC_SEQUENCE_SV__
class axi_mst_atomic_sequence extends uvm_sequence #(axi_mst_seq_item);
    axi_mst_regular_cfg     cfg;
   `uvm_object_utils(axi_mst_atomic_sequence)
    function new (string name = "axi_mst_atomic_sequence");
        super.new(name);
    endfunction

    task body();
        axi_mst_seq_item    req;
        int rand_delay;
        int addr_off, No_slice;
        `uvm_info("MST_SEQ","enter body()",UVM_LOW)
        #50ns;
        cfg = axi_mst_regular_cfg::type_id::create("cfg");
        if(!cfg.randomize()) `uvm_error(get_type_name(), "randomization failure for cfg.")
        for(int i=0; i<5; i++) begin
            `uvm_create(req)
            No_slice = $urandom_range(cfg.ADDR_SLICES-1,0);
            addr_off = cfg.ADDR_OFFSET * No_slice;
            if(!req.randomize() with {
                access_type == AXI_WRITE_ACCESS;
                aw_addr == 8 * i + addr_off;
                aw_len  == cfg.burst_length - 1;
                aw_atop == AXI_ATOMIC_STORE;
            }) `uvm_error(get_type_name(), "randomization failure for req.")
            req.set_one_transfer_transaction_atomic_aw();
            rand_delay = $urandom_range(20,2);
            #(rand_delay * 10ns);
            `uvm_send(req)
        end
        #200ns;
        for(int i=0; i<5; i++) begin
            `uvm_create(req)
            No_slice = $urandom_range(cfg.ADDR_SLICES-1,0);
            addr_off = cfg.ADDR_OFFSET * No_slice;
            if(!req.randomize() with {
                access_type == AXI_WRITE_ACCESS;
                aw_addr == 8 * i + addr_off;
                aw_len  == cfg.burst_length - 1;
                aw_atop == AXI_ATOMIC_LOAD;
            }) `uvm_error(get_type_name(), "randomization failure for req.")
            req.set_one_transfer_transaction_atomic_aw();
            rand_delay = $urandom_range(20,2);
            #(rand_delay * 10ns);
            `uvm_send(req)
        end
    endtask

endclass






`endif 
