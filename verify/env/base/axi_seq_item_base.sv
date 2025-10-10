/* ***********************************************************
    document:       axi_seq_item_base.sv
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    base sequence_item 
**************************************************************/
`ifndef __AXI_SEQ_ITEM_BASE_SV__
`define __AXI_SEQ_ITEM_BASE_SV__
`include "axi_typedef_pkg.svh"
class axi_seq_item_base #(
    parameter int unsigned AXI_ADDR_WIDTH = tb_xbar_param_pkg::AXI_ADDR_WIDTH_IN_USE,
    parameter int unsigned AXI_DATA_WIDTH = tb_xbar_param_pkg::AXI_DATA_WIDTH_IN_USE,
    parameter int unsigned AXI_ID_WIDTH   = tb_xbar_param_pkg::AXI_ID_WIDTH_IN_USE,
    parameter int unsigned AXI_USER_WIDTH = tb_xbar_param_pkg::AXI_USER_WIDTH_IN_USE
)extends uvm_sequence_item;
    localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

    typedef logic [AXI_ID_WIDTH-1:0]   id_t;
    typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0] data_t;
    typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
    typedef logic [AXI_USER_WIDTH-1:0] user_t;
    
    /*
    //{{{ AW channel 
    rand id_t              aw_id     ;
    rand addr_t            aw_addr   ;
    rand logic             aw_lock;
    rand logic             aw_valid;
    rand logic             aw_ready;
    rand user_t            aw_user;
    //typedef from pkg
    rand len_t             aw_len;
    rand size_t            aw_size;
    rand burst_t           aw_burst;
    rand cache_t           aw_cache;
    rand prot_t            aw_prot;
    rand qos_t             aw_qos;
    rand region_t          aw_region;
    rand atop_t            aw_atop;
    //}}}
    //{{{ W channel 
    rand data_t            w_data[];
    rand strb_t            w_strb[];
    rand logic             w_last[];
    rand user_t            w_user;
    rand logic             w_valid;
    rand logic             w_ready;
    //}}}
   //{{{ B channel 
    rand id_t              b_id;
    rand user_t            b_user;
    rand logic             b_valid;
    rand logic             b_ready;
    //typedef from pkg
    rand resp_t            b_resp;
    //}}}
    //{{{ AR channel 
    rand id_t              ar_id;
    rand addr_t            ar_addr;
    rand logic             ar_lock;
    rand user_t            ar_user;
    rand logic             ar_valid;
    rand logic             ar_ready;
    //typedef from pkg
    rand len_t           ar_len;
    rand size_t          ar_size;
    rand burst_t         ar_burst;
    rand cache_t         ar_cache;
    rand prot_t          ar_prot;
    rand qos_t           ar_qos;
    rand region_t        ar_region;
    //}}}
    //{{{ R channel 
    rand id_t              r_id;
    rand data_t            r_data;
    rand logic             r_last;
    rand user_t            r_user;
    rand logic             r_valid;
    rand logic             r_ready;
    //typedef from pkg
    rand resp_t            r_resp;
    //}}}
    */

    global_cfg gcfg = global_cfg::get();
    axi_mst_regular_cfg = regular_cfg;
        
    `uvm_object_utils(axi_seq_item_base)
    function new (string name = "axi_seq_item_base");
        super.new();
    endfunction
        

endclass






`endif 
