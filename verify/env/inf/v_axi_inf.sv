/* ***********************************************************
    document:       v_axi_inf.sv
    author:         Celine (He Zhao) 
    Date:           09/29/2025
    Description:    AXI Interface Definitions for verification 
**************************************************************/
`ifndef __AXI_INF_SV__
`define __AXI_INF_SV__

`include "axi_typedef_pkg.svh"

interface v_axi_inf #(
  parameter int unsigned AXI_ADDR_WIDTH = 0,
  parameter int unsigned AXI_DATA_WIDTH = 0,
  parameter int unsigned AXI_ID_WIDTH   = 0,
  parameter int unsigned AXI_USER_WIDTH = 0
)(
  input bit     clk,
  input logic   rst_n
);

    localparam int unsigned AXI_STRB_WIDTH = AXI_DATA_WIDTH / 8;

    typedef logic [AXI_ID_WIDTH-1:0]   id_t;
    typedef logic [AXI_ADDR_WIDTH-1:0] addr_t;
    typedef logic [AXI_DATA_WIDTH-1:0] data_t;
    typedef logic [AXI_STRB_WIDTH-1:0] strb_t;
    typedef logic [AXI_USER_WIDTH-1:0] user_t;

    //{{{ AW channel 
    id_t              aw_id     ;
    addr_t            aw_addr   ;
    logic             aw_lock;
    logic             aw_valid;
    logic             aw_ready;
    user_t            aw_user;
    //typedef from pkg
    len_t             aw_len;
    size_t            aw_size;
    burst_t           aw_burst;
    cache_t           aw_cache;
    prot_t            aw_prot;
    qos_t             aw_qos;
    region_t          aw_region;
    atop_t            aw_atop;
    //}}}
    //{{{ W channel 
    data_t            w_data;
    strb_t            w_strb;
    logic             w_last;
    user_t            w_user;
    logic             w_valid;
    logic             w_ready;
    //}}}
   //{{{ B channel 
    id_t              b_id;
    user_t            b_user;
    logic             b_valid;
    logic             b_ready;
    //typedef from pkg
    resp_t            b_resp;
    //}}}
    //{{{ AR channel 
    id_t              ar_id;
    addr_t            ar_addr;
    logic             ar_lock;
    user_t            ar_user;
    logic             ar_valid;
    logic             ar_ready;
    //typedef from pkg
    len_t           ar_len;
    size_t          ar_size;
    burst_t         ar_burst;
    cache_t         ar_cache;
    prot_t          ar_prot;
    qos_t           ar_qos;
    region_t        ar_region;
    //}}}
    //{{{ R channel 
    id_t              r_id;
    data_t            r_data;
    logic             r_last;
    user_t            r_user;
    logic             r_valid;
    logic             r_ready;
    //typedef from pkg
    resp_t            r_resp;
    //}}}
    
    //{{{ Master_cb
    clocking Master_cb @(posedge clk, negedge rst_n);
         output  aw_id      ;
         output  aw_addr    ;
         output  aw_lock    ;
         output  aw_valid   ;
         input   aw_ready   ;
         output  aw_user    ;
         output  aw_len     ;
         output  aw_size    ;
         output  aw_burst   ;
         output  aw_cache   ;
         output  aw_prot    ;
         output  aw_qos     ;
         output  aw_region  ;
         output  aw_atop    ;
         output  w_data   ;  
         output  w_strb   ;  
         output  w_last   ;  
         output  w_user   ;  
         output  w_valid  ;  
         input   w_ready  ;  
         input   b_id     ;  
         input   b_user   ;  
         input   b_valid  ;  
         output  b_ready  ;  
         input   b_resp  ;   
         output  ar_id     ; 
         output  ar_addr   ; 
         output  ar_lock   ; 
         output  ar_user   ; 
         output  ar_valid  ; 
         input   ar_ready  ; 
         output  ar_len     ;
         output  ar_size    ;
         output  ar_burst   ;
         output  ar_cache   ;
         output  ar_prot    ;
         output  ar_qos     ;
         output  ar_region  ;
         input   r_id     ;  
         input   r_data   ;  
         input   r_last   ;  
         input   r_user   ;  
         input   r_valid  ;  
         output  r_ready  ;  
         input   r_resp  ;   
    endclocking
    //}}}
    //{{{ Slave cb
    clocking Slave_cb @(posedge clk, negedge rst_n);
         input  aw_id      ;
         input  aw_addr    ;
         input  aw_lock    ;
         input  aw_valid   ;
         output  aw_ready   ;
         input  aw_user    ;
         input  aw_len     ;
         input  aw_size    ;
         input  aw_burst   ;
         input  aw_cache   ;
         input  aw_prot    ;
         input  aw_qos     ;
         input  aw_region  ;
         input  aw_atop    ;
         input  w_data   ;  
         input  w_strb   ;  
         input  w_last   ;  
         input  w_user   ;  
         input  w_valid  ;  
         output  w_ready  ;  
         output  b_id     ;  
         output  b_user   ;  
         output  b_valid  ;  
         input  b_ready  ;  
         output  b_resp  ;   
         input  ar_id     ; 
         input  ar_addr   ; 
         input  ar_lock   ; 
         input  ar_user   ; 
         input  ar_valid  ; 
         output  ar_ready  ; 
         input  ar_len     ;
         input  ar_size    ;
         input  ar_burst   ;
         input  ar_cache   ;
         input  ar_prot    ;
         input  ar_qos     ;
         input  ar_region  ;
         output  r_id     ;  
         output  r_data   ;  
         output  r_last   ;  
         output  r_user   ;  
         output  r_valid  ;  
         input  r_ready  ;  
         output  r_resp  ;   
    endclocking

    //}}}
    //{{{ Monitor cb
    clocking Monitor_cb @(posedge clk, negedge rst_n);
         input  aw_id      ;
         input  aw_addr    ;
         input  aw_lock    ;
         input  aw_valid   ;
         input  aw_ready   ;
         input  aw_user    ;
         input  aw_len     ;
         input  aw_size    ;
         input  aw_burst   ;
         input  aw_cache   ;
         input  aw_prot    ;
         input  aw_qos     ;
         input  aw_region  ;
         input  aw_atop    ;
         input  w_data   ;  
         input  w_strb   ;  
         input  w_last   ;  
         input  w_user   ;  
         input  w_valid  ;  
         input  w_ready  ;  
         input  b_id     ;  
         input  b_user   ;  
         input  b_valid  ;  
         input  b_ready  ;  
         input  b_resp  ;   
         input  ar_id     ; 
         input  ar_addr   ; 
         input  ar_lock   ; 
         input  ar_user   ; 
         input  ar_valid  ; 
         input  ar_ready  ; 
         input  ar_len     ;
         input  ar_size    ;
         input  ar_burst   ;
         input  ar_cache   ;
         input  ar_prot    ;
         input  ar_qos     ;
         input  ar_region  ;
         input  r_id     ;  
         input  r_data   ;  
         input  r_last   ;  
         input  r_user   ;  
         input  r_valid  ;  
         input  r_ready  ;  
         input  r_resp  ;   
    endclocking
    //}}}
    
    


    modport Master (
      output aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, input aw_ready,
      output w_data, w_strb, w_last, w_user, w_valid, input w_ready,
      input b_id, b_resp, b_user, b_valid, output b_ready,
      output ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, input ar_ready,
      input r_id, r_data, r_resp, r_last, r_user, r_valid, output r_ready
    );

    modport Slave (
      input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, output aw_ready,
      input w_data, w_strb, w_last, w_user, w_valid, output w_ready,
      output b_id, b_resp, b_user, b_valid, input b_ready,
      input ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, output ar_ready,
      output r_id, r_data, r_resp, r_last, r_user, r_valid, input r_ready
    );

    modport Monitor (
      input aw_id, aw_addr, aw_len, aw_size, aw_burst, aw_lock, aw_cache, aw_prot, aw_qos, aw_region, aw_atop, aw_user, aw_valid, aw_ready,
            w_data, w_strb, w_last, w_user, w_valid, w_ready,
            b_id, b_resp, b_user, b_valid, b_ready,
            ar_id, ar_addr, ar_len, ar_size, ar_burst, ar_lock, ar_cache, ar_prot, ar_qos, ar_region, ar_user, ar_valid, ar_ready,
            r_id, r_data, r_resp, r_last, r_user, r_valid, r_ready
    );

endinterface

`endif 
