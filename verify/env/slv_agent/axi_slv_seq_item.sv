/* ***********************************************************
    document:       axi_slv_seq_item.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:     
**************************************************************/
`ifndef __AXI_SLV_SEQ_ITEM_SV__
`define __AXI_SLV_SEQ_ITEM_SV__
class axi_slv_seq_item extends axi_slv_seq_item_base;
    bit is_aw, is_w, is_b, is_ar, is_r;
    //{{{ AW channel 
    id_t              aw_id     ;
    addr_t            aw_addr   ;
    logic             aw_lock;
    logic             aw_valid;
    //logic             aw_ready;
    user_t            aw_user;
    //typedef from pkg
    len_t             aw_len;
    //size_t            aw_size;
    //burst_t           aw_burst;
    cache_t           aw_cache;
    prot_t            aw_prot;
    qos_t             aw_qos;
    region_t          aw_region;
    atop_t            aw_atop;
    axi_burst_size    aw_size;
    axi_burst_type    aw_burst;            
    //}}}
    //{{{ W channel 
    data_t            w_data[];
    strb_t            w_strb[];
    logic             w_last[];
    user_t            w_user;
    logic             w_valid;
    //logic             w_ready;
    //}}}
   //{{{ B channel 
    rand id_t              b_id;
    rand user_t            b_user;
    rand logic             b_valid;
    //logic             b_ready;
    rand axi_response      b_resp;
    //}}}
    //{{{ AR channel 
    id_t              ar_id;
    addr_t            ar_addr;
    logic             ar_lock;
    user_t            ar_user;
    logic             ar_valid;
    //logic             ar_ready;
    //typedef from pkg
    len_t           ar_len;
    //size_t          ar_size;
    //burst_t         ar_burst;
    cache_t         ar_cache;
    prot_t          ar_prot;
    qos_t           ar_qos;
    region_t        ar_region;
    axi_burst_size    ar_size;
    axi_burst_type    ar_burst;
    //}}}
    //{{{ R channel 
    id_t              r_id;
    data_t            r_data[];
    logic             r_last[];
    rand user_t       r_user;
    logic             r_valid;
    //logic             r_ready;
    //typedef from pkg
    //rand resp_t            r_resp;
    rand axi_response      r_resp[];
    
    //}}}
    constraint c_user{
        b_user == '0;
        r_user == '0;
    }

    //{{{ uvm_object_utils_begin
    `uvm_object_utils_begin(axi_slv_seq_item)
        `uvm_field_int(is_aw, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_w, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_b, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_ar, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(is_r, UVM_DEFAULT | UVM_BIN)
        //`uvm_field_enum(axi_access_type, access_type, UVM_DEFAULT) 
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
        `uvm_field_int(ar_cache,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_prot,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_qos,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(ar_region,UVM_DEFAULT | UVM_HEX);
        `uvm_field_enum(axi_burst_size, ar_size,UVM_DEFAULT);
        `uvm_field_enum(axi_burst_type, ar_burst,UVM_DEFAULT);
        `uvm_field_int(r_id,UVM_DEFAULT | UVM_HEX);
        `uvm_field_array_int(r_data,UVM_DEFAULT | UVM_HEX);
        `uvm_field_array_int(r_last,UVM_DEFAULT | UVM_BIN);
        `uvm_field_int(r_user,UVM_DEFAULT | UVM_HEX);
        `uvm_field_int(r_valid,UVM_DEFAULT | UVM_BIN);
        `uvm_field_array_enum(axi_response, r_resp, UVM_DEFAULT);
    `uvm_object_utils_end
    //}}}
    function new (string name = "axi_slv_seq_item");
        super.new(name);
    endfunction

    function void pre_randomize();

    endfunction

    function string convert2string();
        string s;
        s = super.convert2string();
        if(is_aw)begin
            $sformat(s, "%sAW-channel\n", s);
            $sformat(s, "%saw_id \t%h\n", s, aw_id);
            $sformat(s, "%saw_addr \t%h\n", s, aw_addr);
            $sformat(s, "%saw_valid \t%b\n", s, aw_valid);
            $sformat(s, "%saw_len \t%d\n", s, aw_len);
            $sformat(s, "%saw_size \t%s\n", s, aw_size.name());
            $sformat(s, "%saw_burst \t%s\n", s, aw_burst.name());
            $sformat(s, "%saw_lock \t%b\n", s, aw_lock);
            $sformat(s, "%saw_user \t%h\n", s, aw_user);
            $sformat(s, "%saw_cache \t%h\n", s, aw_cache);
            $sformat(s, "%saw_prot \t%h\n", s, aw_prot);
            $sformat(s, "%saw_qos \t%h\n", s, aw_qos);
            $sformat(s, "%saw_region \t%h\n", s, aw_region);
            $sformat(s, "%saw_atop \t%h\n", s, aw_atop);
            //$sformat(s, "%sAW-channel\n aw_id \t%h\n aw_addr \t%h\n aw_lock \t%b\n aw_valid \t%b\n aw_len \t%d\n aw_size \t%s\n aw_burst \t$s\n aw_cache \t%b\n aw_prot \t%b\n aw_region \t%b\n aw_atop /t%h\n", s, aw_id, aw_addr, aw_lock, aw_valid, aw_len, aw_size.name(), aw_burst.name(), aw_cache, aw_prot, aw_region, aw_atop);
        end else if(is_w) 
            $sformat(s, "%sW-channel\n w_valid \t%b\n w_data \t%p\n w_strb \t%p\n w_last \t%p\n w_user \t%h\n", s, w_valid, w_data, w_strb, w_last, w_user);
        else if(is_b)
            $sformat(s, "%sB-channel\n b_id \t%h\n b_valid \t%b\n b_resp \t%s\n b_user \t%h\n", s, b_id, b_valid, b_resp.name(), b_user);
        else if(is_ar)
            $sformat(s, "%sAR-channel\n ar_id \t%h\n ar_valid \t%b\n ar_addr \t%h\n ar_len \t%d\n ar_size \t%s\n ar_burst \t%s\n ar_cache \t%b\n ar_lock \t%b\n ar_user \t%h\n ar_prot \t%h\n ar_qos \t%h\n ar_region \t%h\n", s, ar_id, ar_valid, ar_addr, ar_len, ar_size.name(), ar_burst.name(), ar_cache, ar_lock, ar_user, ar_prot, ar_qos, ar_region);
        else if(is_r)
            $sformat(s, "%sR-channel\n r_id \t%h\n r_valid \t%b\n r_data \t%p\n r_last \t%p\n r_resp \t%p\n r_user \t%h\n", s, r_id, r_valid, r_data, r_last, r_resp, r_user);
        else
            $sformat(s, "convert2string: WRONG!!");
    endfunction


endclass






`endif 
