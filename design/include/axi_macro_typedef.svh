/* ***********************************************************
    document:       axi_macro_typedef.svh
    author:         Celine (He Zhao) 
    Date:           09/29/2025
    Description:    encapsulate common Macros defination to  
                    define AXI Channel and Request/Response Structs  
**************************************************************/
`ifndef __AXI_MACRO_TYPEDEF_SVH__
`define __AXI_MACRO_TYPEDEF_SVH__

`include "axi_typedef_pkg.svh"
////////////////////////////////////////////////////////////////////////////////////////////////////
// AXI4+ATOP Channel and Request/Response Structs
//
// Usage Example:
// `AXI_TYPEDEF_AW_CHAN_T(axi_aw_t, axi_addr_t, axi_id_t, axi_user_t)
// `AXI_TYPEDEF_W_CHAN_T(axi_w_t, axi_data_t, axi_strb_t, axi_user_t)
// `AXI_TYPEDEF_B_CHAN_T(axi_b_t, axi_id_t, axi_user_t)
// `AXI_TYPEDEF_AR_CHAN_T(axi_ar_t, axi_addr_t, axi_id_t, axi_user_t)
// `AXI_TYPEDEF_R_CHAN_T(axi_r_t, axi_data_t, axi_id_t, axi_user_t)
// `AXI_TYPEDEF_REQ_T(axi_req_t, axi_aw_t, axi_w_t, axi_ar_t)
// `AXI_TYPEDEF_RESP_T(axi_resp_t, axi_b_t, axi_r_t)

//{{{ AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)
`define AXI_TYPEDEF_AW_CHAN_T(aw_chan_t, addr_t, id_t, user_t)  \
    typedef struct packed {                                       \
        id_t       id;                                       \
        addr_t     addr;                                     \
        len_t      len;                                      \
        size_t     size;                                     \
        burst_t    burst;                                    \
        logic      lock;                                     \
        cache_t    cache;                                    \
        prot_t     prot;                                     \
        qos_t      qos;                                      \
        region_t   region;                                   \
        atop_t     atop;                                     \
        user_t     user;                                     \
    } aw_chan_t;
//}}}

//{{{ AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)
`define AXI_TYPEDEF_W_CHAN_T(w_chan_t, data_t, strb_t, user_t)  \
    typedef struct packed {                                       \
        data_t data;                                                \
        strb_t strb;                                                \
        logic  last;                                                \
        user_t user;                                                \
    } w_chan_t;
//}}}

//{{{ AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)
`define AXI_TYPEDEF_B_CHAN_T(b_chan_t, id_t, user_t)  \
    typedef struct packed {                             \
        id_t            id;                               \
        resp_t          resp;                             \
        user_t          user;                             \
    } b_chan_t;
//}}} 

//{{{ AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)
`define AXI_TYPEDEF_AR_CHAN_T(ar_chan_t, addr_t, id_t, user_t)  \
    typedef struct packed {                                       \
      id_t     id;                                       \
      addr_t   addr;                                     \
      len_t    len;                                      \
      size_t   size;                                     \
      burst_t  burst;                                    \
      logic    lock;                                     \
      cache_t  cache;                                    \
      prot_t   prot;                                     \
      qos_t    qos;                                      \
      region_t region;                                   \
      user_t   user;                                     \
    } ar_chan_t;
//}}}

//{{{ AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)
`define AXI_TYPEDEF_R_CHAN_T(r_chan_t, data_t, id_t, user_t)  \
    typedef struct packed {                                     \
      id_t            id;                                       \
      data_t          data;                                     \
      resp_t          resp;                                     \
      logic           last;                                     \
      user_t          user;                                     \
    } r_chan_t;
//}}}

//{{{ AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)
`define AXI_TYPEDEF_REQ_T(req_t, aw_chan_t, w_chan_t, ar_chan_t)  \
    typedef struct packed {                                         \
      aw_chan_t     aw;                                                 \
      logic         aw_valid;                                           \
      w_chan_t      w;                                                  \
      logic         w_valid;                                            \
      logic         b_ready;                                            \
      ar_chan_t     ar;                                                 \
      logic         ar_valid;                                           \
      logic         r_ready;                                            \
    } req_t;
//}}}

//{{{ AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)
`define AXI_TYPEDEF_RESP_T(resp_t, b_chan_t, r_chan_t)  \
    typedef struct packed {                               \
      logic     aw_ready;                                 \
      logic     ar_ready;                                 \
      logic     w_ready;                                  \
      logic     b_valid;                                  \
      b_chan_t  b;                                        \
      //logic     b_ready;    \
      logic     r_valid;                                  \
      r_chan_t  r;                                        \
    } resp_t;
//}}}
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// All AXI4+ATOP Channels and Request/Response Structs in One Macro - Custom Type Name Version
//
// This can be used whenever the user is not interested in "precise" control of the naming of the
// individual channels.
//
// Usage Example:
// `AXI_TYPEDEF_ALL_CT(axi, axi_req_t, axi_rsp_t, addr_t, id_t, data_t, strb_t, user_t)
//
// This defines `axi_req_t` and `axi_rsp_t` request/response structs as well as `axi_aw_chan_t`,
// `axi_w_chan_t`, `axi_b_chan_t`, `axi_ar_chan_t`, and `axi_r_chan_t` channel structs.
`define AXI_TYPEDEF_ALL_CT(__name, __req, __rsp, __addr_t, __id_t, __data_t, __strb_t, __user_t) \
  `AXI_TYPEDEF_AW_CHAN_T(__name``_aw_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_W_CHAN_T(__name``_w_chan_t, __data_t, __strb_t, __user_t)                         \
  `AXI_TYPEDEF_B_CHAN_T(__name``_b_chan_t, __id_t, __user_t)                                     \
  `AXI_TYPEDEF_AR_CHAN_T(__name``_ar_chan_t, __addr_t, __id_t, __user_t)                         \
  `AXI_TYPEDEF_R_CHAN_T(__name``_r_chan_t, __data_t, __id_t, __user_t)                           \
  `AXI_TYPEDEF_REQ_T(__req, __name``_aw_chan_t, __name``_w_chan_t, __name``_ar_chan_t)           \
  `AXI_TYPEDEF_RESP_T(__rsp, __name``_b_chan_t, __name``_r_chan_t)
////////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////////
// All AXI4+ATOP Channels and Request/Response Structs in One Macro
//
// This can be used whenever the user is not interested in "precise" control of the naming of the
// individual channels.
//
// Usage Example:
// `AXI_TYPEDEF_ALL(axi, addr_t, id_t, data_t, strb_t, user_t)
//
// This defines `axi_req_t` and `axi_resp_t` request/response structs as well as `axi_aw_chan_t`,
// `axi_w_chan_t`, `axi_b_chan_t`, `axi_ar_chan_t`, and `axi_r_chan_t` channel structs.
`define AXI_TYPEDEF_ALL(__name, __addr_t, __id_t, __data_t, __strb_t, __user_t)                                \
  `AXI_TYPEDEF_ALL_CT(__name, __name``_req_t, __name``_resp_t, __addr_t, __id_t, __data_t, __strb_t, __user_t)
////////////////////////////////////////////////////////////////////////////////////////////////////




`endif
