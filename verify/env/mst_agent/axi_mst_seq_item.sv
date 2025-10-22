/* ***********************************************************
    document:       axi_mst_seq_item.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_MST_SEQ_ITEM_SV__
`define __AXI_MST_SEQ_ITEM_SV__
class axi_mst_seq_item extends axi_mst_seq_item_base;
    rand axi_access_type    access_type;

    //{{{ AW channel 
    rand id_t              aw_id     ;
    rand addr_t            aw_addr   ;
    rand logic             aw_lock;
    rand logic             aw_valid;
                //rand logic             aw_ready;
    rand user_t            aw_user;
    //typedef from pkg
    rand len_t             aw_len;
    rand cache_t           aw_cache;
    rand prot_t            aw_prot;
    rand qos_t             aw_qos;
    rand region_t          aw_region;
    rand atop_t            aw_atop;
    //
    rand axi_burst_size    aw_size;
    rand axi_burst_type    aw_burst;
    //}}}
    //{{{ W channel 
    data_t            w_data[];
    strb_t            w_strb[];
    logic             w_last[];
    rand user_t            w_user;
    rand logic             w_valid;
                //rand logic             w_ready;
    //}}}
    //{{{ B channel 
    id_t              b_id;
    user_t            b_user;
    logic             b_valid;
    //logic             b_ready;
    axi_response      b_resp;
    //}}}
    //{{{ AR channel 
    rand id_t              ar_id;
    rand addr_t            ar_addr;
    rand logic             ar_lock;
    rand user_t            ar_user;
    rand logic             ar_valid;
                //rand logic             ar_ready;
    //typedef from pkg
    rand len_t           ar_len;
    //rand size_t          ar_size;
    //rand burst_t         ar_burst;
    rand cache_t         ar_cache;
    rand prot_t          ar_prot;
    rand qos_t           ar_qos;
    rand region_t        ar_region;
    rand axi_burst_size    ar_size;
    rand axi_burst_type    ar_burst;
    //}}}    

    // drv delay
    rand bit[2:0] aw2w_delay;


    //{{{ uvm_object_utils_begin
    `uvm_object_utils_begin(axi_mst_seq_item)
        `uvm_field_enum(axi_access_type, access_type, UVM_DEFAULT) 
        `uvm_field_int(aw_id,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_addr,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_lock,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_valid,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_user,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_len,UVM_DEFAULT | UVM_HEX);
        `uvm_field_enum(axi_burst_size, aw_size,UVM_DEFAULT);
        `uvm_field_enum(axi_burst_type, aw_burst,UVM_DEFAULT);
        `uvm_field_int(aw_cache,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_cache,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_prot,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_qos,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_region,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(aw_atop,UVM_DEFAULT | UVM_HEX);
        `uvm_field_array_int(w_data, UVM_DEFAULT | UVM_HEX)
        `uvm_field_array_int(w_strb, UVM_DEFAULT | UVM_BIN)
        `uvm_field_array_int(w_last, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(w_user,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(w_valid,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_id,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_addr,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_lock,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_user,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_valid,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_len, UVM_DEFAULT | UVM_DEC);
        `uvm_field_enum(axi_burst_size, ar_size,UVM_DEFAULT);
        `uvm_field_enum(axi_burst_type, ar_burst,UVM_DEFAULT);
        `uvm_field_int(ar_cache,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_prot,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_qos,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_region,UVM_DEFAULT | UVM_HEX);
    `uvm_object_utils_end
    //}}}
    function new (string name = "axi_mst_seq_item");
        super.new(name);
    endfunction
    //{{{ set_one_transfer_transaction_w
    function void set_one_transfer_transaction_w();
        int data;
        if(access_type == AXI_WRITE_ACCESS) begin 
            `uvm_info("TRANS",$sformatf("Set W data (len: %0d)", aw_len+1),UVM_LOW)
            w_data = new[aw_len+1];
            w_strb = new[aw_len+1];
            w_last = new[aw_len+1];
            w_valid = 1'b1;
            foreach(w_data[i]) begin
                assert(std::randomize(data));
                w_data[i] = data;
            end
            foreach(w_strb[i]) begin
                w_strb[i] = '1;
            end
            foreach(w_last[i]) begin
                w_last[i] = 0;
            end
            w_last[aw_len] = 1;
        end
    endfunction
    //}}}
    //{{{ set_one_transfer_transaction_awr
    function void set_one_transfer_transaction_awr();
        `uvm_info("TRANS",$sformatf("Set ARW (access_type: %s)", access_type.name()),UVM_LOW)
        if(access_type == AXI_WRITE_ACCESS) begin
            aw_valid = 1;  
            aw_size = AXI_BURST_SIZE_8_BYTES;
            aw_burst = AXI_INCREMENTING_BURST;
            //aw_len = 0;
            aw_cache = 4'b0001; // Bufferable
            aw_prot = 3'b000;   // Unprivileged access
            aw_lock = 1'b0;     // Normal access
            aw_qos = 0;         // not participating in any QoS scheme
            aw_user = 0;
            aw_region = 0;      // no additional address regions
            aw_atop = 0;        //Non-atomic operation
        end
        else begin
            ar_valid = 1'b1; 
            ar_lock = 0; 
            ar_user = 0;
            //ar_len = 0;
            ar_size = AXI_BURST_SIZE_8_BYTES;
            ar_burst = AXI_INCREMENTING_BURST;
            ar_cache = 4'b0001; // Bufferable
            ar_prot = 3'b000;   // Unprivileged access
            ar_qos = 0;         // not participating in any QoS scheme
            ar_region =  0;      // no additional address regions
        end
    endfunction
    //}}}
    
    

endclass






`endif 
