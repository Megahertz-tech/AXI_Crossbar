/* ***********************************************************
    document:       axi_typedef_pkg.svh
    author:         Celine (He Zhao) 
    Date:           09/29/2025
    Description:    encapsulate common typedef definitions  
**************************************************************/
`ifndef __AXI_TYPEDEF_PKG_SVH__
`define __AXI_TYPEDEF_PKG_SVH__

package axi_typedef_pkg;

    /// AXI Transaction Burst Width.
    typedef logic [1:0]  burst_t;
    /// AXI Transaction Response Type.
    typedef logic [1:0]   resp_t;
    /// AXI Transaction Cacheability Type.
    typedef logic [3:0]  cache_t;
    /// AXI Transaction Protection Type.
    typedef logic [2:0]   prot_t;
    /// AXI Transaction Quality of Service Type.
    typedef logic [3:0]    qos_t;
    /// AXI Transaction Region Type.
    typedef logic [3:0] region_t;
    /// AXI Transaction Length Type.
    typedef logic [7:0]    len_t;
    /// AXI Transaction Size Type.
    typedef logic [2:0]   size_t;
    /// AXI5 Atomic Operation Type.
    typedef logic [5:0]   atop_t; // atomic operations
    /// AXI5 Non-Secure Address Identifier.
    typedef logic [3:0]  nsaid_t;

    //{{{ Celine add 
    typedef struct packed {
      int unsigned NoSlvPorts;         // Number of slave ports (master connections)
      int unsigned NoMstPorts;         // Number of master ports (slave connections)
      int unsigned MaxMstTrans;        // Max outstanding transactions per slave port
      int unsigned MaxSlvTrans;        // Max outstanding transactions per master port per ID
      bit          FallThrough;        // AW→W routing fall-through enable
      logic [9:0]  LatencyMode;        // Pipeline configuration per channel
      int unsigned AxiIdWidthSlvPorts; // Slave port ID width
      int unsigned AxiIdUsedSlvPorts;  // Used ID bits for ordering decisions
      bit          UniqueIds;          // ID uniqueness guarantee
      int unsigned AxiAddrWidth;       // Address width
      int unsigned AxiDataWidth;       // Data width
      int unsigned NoAddrRules;        // Number of address map rules
      int unsigned PipelineStages;     // Cross-connection pipeline depth
    } xbar_cfg_t;

    typedef struct packed {
        int unsigned idx;
        logic [31:0] start_addr;
        logic [31:0] end_addr;
        logic        support_atomic;
    } xbar_rule_32_t;

    //}}}

endpackage 

// import package into $unit
import axi_typedef_pkg::*;

`endif
