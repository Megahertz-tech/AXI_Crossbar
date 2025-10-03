/* ***********************************************************
    document:       axi_macro_assign.svh
    author:         Celine (He Zhao) 
    Date:           10/03/2025
    Description:    Macros to assign AXI Interfaces and Structs 
**************************************************************/
`ifndef __AXI_MACRO_ASSIGN_SVH__
`define __AXI_MACRO_ASSIGN_SVH__

////////////////////////////////////////////////////////////////////////////////////////////////////
// Internal implementation for assigning one AXI struct or interface to another struct or interface.
// The path to the signals on each side is defined by the `__sep*` arguments.  The `__opt_as`
// argument allows to use this standalone (with `__opt_as = assign`) or in assignments inside
// processes (with `__opt_as` void).
`define __AXI_TO_AW(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``atop   = __rhs``__rhs_sep``atop;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_W(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``strb   = __rhs``__rhs_sep``strb;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_B(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_AR(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)   \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``addr   = __rhs``__rhs_sep``addr;       \
  __opt_as __lhs``__lhs_sep``len    = __rhs``__rhs_sep``len;        \
  __opt_as __lhs``__lhs_sep``size   = __rhs``__rhs_sep``size;       \
  __opt_as __lhs``__lhs_sep``burst  = __rhs``__rhs_sep``burst;      \
  __opt_as __lhs``__lhs_sep``lock   = __rhs``__rhs_sep``lock;       \
  __opt_as __lhs``__lhs_sep``cache  = __rhs``__rhs_sep``cache;      \
  __opt_as __lhs``__lhs_sep``prot   = __rhs``__rhs_sep``prot;       \
  __opt_as __lhs``__lhs_sep``qos    = __rhs``__rhs_sep``qos;        \
  __opt_as __lhs``__lhs_sep``region = __rhs``__rhs_sep``region;     \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
`define __AXI_TO_R(__opt_as, __lhs, __lhs_sep, __rhs, __rhs_sep)    \
  __opt_as __lhs``__lhs_sep``id     = __rhs``__rhs_sep``id;         \
  __opt_as __lhs``__lhs_sep``data   = __rhs``__rhs_sep``data;       \
  __opt_as __lhs``__lhs_sep``resp   = __rhs``__rhs_sep``resp;       \
  __opt_as __lhs``__lhs_sep``last   = __rhs``__rhs_sep``last;       \
  __opt_as __lhs``__lhs_sep``user   = __rhs``__rhs_sep``user;
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Assign an AXI4+ATOP interface `slv` to a request struct `req`.
`define AXI_ASSIGN_TO_REQ(req, axi)                        \
  `__AXI_TO_AW(assign, req.aw, ., axi.aw_, )               \
  assign req.aw_valid = axi.aw_valid;                      \
  `__AXI_TO_W(assign, req.w, ., axi.w_, )                  \
  assign req.w_valid  = axi.w_valid;                       \
  assign req.b_ready  = axi.b_ready;                       \
  `__AXI_TO_AR(assign, req.ar, ., axi.ar_, )               \
  assign req.ar_valid = axi.ar_valid;                      \
  assign req.r_ready  = axi.r_ready;

// Assign a response struct `resp` to an AXI4+ATOP interface `mst`.
`define AXI_ASSIGN_FROM_RESP(axi, resp)                    \
  assign axi.aw_ready = resp.aw_ready;                     \
  assign axi.ar_ready = resp.ar_ready;                     \
  assign axi.w_ready  = resp.w_ready;                      \
  assign axi.b_valid  = resp.b_valid;                      \
  `__AXI_TO_B(assign, axi.b_, , resp.b, .)                \
  assign axi.r_valid  = resp.r_valid;                      \
  `__AXI_TO_R(assign, axi.r_, , resp.r, .)

// Assign a request struct `req` to an AXI4+ATOP interface `mst`.
`define AXI_ASSIGN_FROM_REQ(axi, req)                      \
  `__AXI_TO_AW(assign, axi.aw_, , req.aw, .)               \
  assign axi.aw_valid = req.aw_valid;                      \
  `__AXI_TO_W(assign, axi.w_, , req.w, .)                  \
  assign axi.w_valid  = req.w_valid;                       \
  assign axi.b_ready  = req.b_ready;                       \
  `__AXI_TO_AR(assign, axi.ar_, , req.ar, .)               \
  assign axi.ar_valid = req.ar_valid;                      \
  assign axi.r_ready  = req.r_ready;

// Assign an AXI4+ATOP interface `mst` to a response struct `resp`.
`define AXI_ASSIGN_TO_RESP(resp, axi)                      \
  assign resp.aw_ready = axi.aw_ready;                     \
  assign resp.ar_ready = axi.ar_ready;                     \
  assign resp.w_ready  = axi.w_ready;                      \
  assign resp.b_valid  = axi.b_valid;                      \
  `__AXI_TO_B(assign, resp.b, ., axi.b_, )                \
  assign resp.r_valid  = axi.r_valid;                      \
  `__AXI_TO_R(assign, resp.r, ., axi.r_, )
////////////////////////////////////////////////////////////////////////////////////////////////////

`endif 
